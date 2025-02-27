import SwiftUI
import UIKit
import ImageIO

// MARK: - AnimatedGIFView
struct AnimatedGIFView: UIViewRepresentable {
    let gifName: String
    var isPaused: Bool = false  // Если true, анимация останавливается

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        // Проверяем наличие файла
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            imageView.image = UIImage.animatedImage(withAnimatedGIFData: data)
            imageView.startAnimating()
        }
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        if isPaused {
            uiView.stopAnimating()
        } else {
            if !uiView.isAnimating {
                uiView.startAnimating()
            }
        }
    }
}

extension UIImage {
    static func animatedImage(withAnimatedGIFData data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()
        var duration: Double = 0.0
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let frameDuration = UIImage.frameDuration(at: i, source: source)
                duration += frameDuration
                images.append(UIImage(cgImage: cgImage))
            }
        }
        
        if duration == 0 { duration = 1.0 }
        return UIImage.animatedImage(with: images, duration: duration)
    }
    
    static func frameDuration(at index: Int, source: CGImageSource) -> Double {
        let defaultFrameDuration = 0.1
        guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
              let gifProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any] else {
            return defaultFrameDuration
        }
        
        if let unclampedDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double,
           unclampedDelay > 0 {
            return unclampedDelay
        }
        if let delay = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double,
           delay > 0 {
            return delay
        }
        return defaultFrameDuration
    }
}

// MARK: - RaceView
struct RaceView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedChicken: Int? = nil
    @State private var raceInProgress = false
    @State private var raceFinished = false
    @State private var winner: Int? = nil
    
    // Время забега (для расчёта анимации)
    @State private var chicken1Time: Double = 0
    @State private var chicken2Time: Double = 0
    
    // Усилители
    @State private var useX2 = false
    @State private var useGuaranteedWin = false
    
    // Позиции куриц по оси X
    @State private var chicken1X: CGFloat = 0
    @State private var chicken2X: CGFloat = 0
    
    // Флаги остановки анимации для каждой курицы
    @State private var chicken1Finished: Bool = false
    @State private var chicken2Finished: Bool = false
    
    var body: some View {
        ZStack {
            // Фон и полупрозрачный слой
            Image(gameData.selectedBackgroundName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            if !raceInProgress && !raceFinished {
                preRaceView
            } else {
                raceTrackView
                if raceFinished {
                    postRaceOverlay
                }
            }
        }
    }
    
    // MARK: Pre-Race View
    private var preRaceView: some View {
        VStack(spacing: 30) {
            Text("Choose your Champion!")
                .font(.title)
                .foregroundColor(.white)
                .shadow(radius: 2)
                .padding(.top, 40)
            
            VStack(spacing: 16) {
                HStack(spacing: 40) {
                    ChickenSelectionView(chickenNumber: 1,
                                         selectedChicken: $selectedChicken,
                                         gifName: "chicken1")
                    ChickenSelectionView(chickenNumber: 2,
                                         selectedChicken: $selectedChicken,
                                         gifName: "chicken2")
                }
            }
            
            VStack(spacing: 15) {
                Toggle("Use x2 (\(gameData.x2Boosters))", isOn: $useX2)
                    .toggleStyle(SwitchToggleStyle(tint: .yellow))
                    .disabled(gameData.x2Boosters == 0)
                    .foregroundColor(.white)
                Toggle("100% Win (\(gameData.guaranteedBoosters))", isOn: $useGuaranteedWin)
                    .toggleStyle(SwitchToggleStyle(tint: .yellow))
                    .disabled(gameData.guaranteedBoosters == 0)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.4))
            .cornerRadius(12)
            
            // Кнопка запуска гонки с изображением
            Button(action: {
                guard selectedChicken != nil else { return }
                startRace()
            }) {
                Image("select")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back to Main Menu")
                    .font(.subheadline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 100)
            
            Spacer()
        }
    }
    
    // MARK: Race Track View
    private var raceTrackView: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Дорожка для первой курицы
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Text("Chicken 1")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                                .padding(),
                            alignment: .topLeading
                        )
                    AnimatedGIFView(gifName: "chicken1", isPaused: chicken1Finished)
                        .frame(width: 50, height: 50)
                        .offset(x: chicken1X, y: 0)
                        .animation(.linear(duration: chicken1Time), value: chicken1X)
                }
                .frame(height: geometry.size.height / 2)
                
                // Дорожка для второй курицы
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Text("Chicken 2")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                                .padding(),
                            alignment: .topLeading
                        )
                    AnimatedGIFView(gifName: "chicken2", isPaused: chicken2Finished)
                        .frame(width: 50, height: 50)
                        .offset(x: chicken2X, y: 0)
                        .animation(.linear(duration: chicken2Time), value: chicken2X)
                }
                .frame(height: geometry.size.height / 2)
            }
            .onAppear {
                // Вычисляем максимальное смещение (учитывая ширину гифки)
                let maxDistance = geometry.size.width - 60
                // Запускаем анимацию перемещения куриц от левого края до maxDistance
                withAnimation {
                    chicken1X = maxDistance
                }
                withAnimation {
                    chicken2X = maxDistance
                }
                // По окончании времени анимации для каждой курицы ставим флаг остановки
                DispatchQueue.main.asyncAfter(deadline: .now() + chicken1Time) {
                    chicken1Finished = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + chicken2Time) {
                    chicken2Finished = true
                }
                // После максимального времени анимации определяем победителя
                let delay = max(chicken1Time, chicken2Time)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    determineWinner()
                }
            }
        }
    }
    
    // MARK: Post Race Overlay
    private var postRaceOverlay: some View {
        VStack(spacing: 30) {
            Spacer()
            if let w = winner {
                if w == selectedChicken {
                    Text("You Won!")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .shadow(radius: 3)
                } else {
                    Text("You Lost!")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .shadow(radius: 3)
                }
            }
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back to Main Menu")
                    .font(.subheadline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 100)
            Spacer()
        }
    }
    
    // MARK: Start Race
    private func startRace() {
        raceInProgress = true
        raceFinished = false
        winner = nil
        chicken1Finished = false
        chicken2Finished = false
        
        // Курицы стартуют с левого края
        chicken1X = 0
        chicken2X = 0
        
        // Случайное время забега для каждой курицы
        chicken1Time = Double.random(in: 3...20)
        chicken2Time = Double.random(in: 3...20)
        
        // Применяем усилители, если они активны
        if useGuaranteedWin && gameData.guaranteedBoosters > 0 {
            gameData.useGuaranteedBooster()
            if selectedChicken == 1 {
                chicken1Time = 3
                chicken2Time = Double.random(in: 4...20)
            } else {
                chicken2Time = 3
                chicken1Time = Double.random(in: 4...20)
            }
        }
        
        if useX2 && gameData.x2Boosters > 0 {
            gameData.useX2Booster()
        }
    }
    
    // MARK: Determine Winner
    private func determineWinner() {
        if chicken1Time < chicken2Time {
            winner = 1
        } else if chicken2Time < chicken1Time {
            winner = 2
        } else {
            // Ничья — выбираем случайно
            winner = Bool.random() ? 1 : 2
        }
        
        raceFinished = true
        raceInProgress = false
        
        // Обновляем статистику и начисляем очки
        if let w = winner, let selected = selectedChicken {
            let didWin = (w == selected)
            gameData.startRace(didWin: didWin)
            if didWin {
                var earnedPoints = 50
                if useX2 { earnedPoints *= 2 }
                gameData.addPoints(earnedPoints)
            }
        }
        
        // Сброс усилителей
        useX2 = false
        useGuaranteedWin = false
    }
}

// MARK: - ChickenSelectionView
struct ChickenSelectionView: View {
    let chickenNumber: Int
    @Binding var selectedChicken: Int?
    let gifName: String
    
    var body: some View {
        VStack(spacing: 10) {
            AnimatedGIFView(gifName: gifName)
                .frame(width: 60, height: 60)
            Button(action: {
                selectedChicken = chickenNumber
            }) {
                Image("play") // Используем select1Button или select2Button
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 40) // Настройте размеры по необходимости
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedChicken == chickenNumber ? Color.green : Color.clear, lineWidth: 2)
                    )
            }
        }
        .frame(width: 100)
    }
}

// MARK: - GrayButtonStyle
struct GrayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(Color.gray.opacity(configuration.isPressed ? 0.6 : 0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 2)
    }
}
