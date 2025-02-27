import SwiftUI
import AVFoundation

// MARK: - AudioManager
class AudioManager {
    static let shared = AudioManager()
    var audioPlayer: AVAudioPlayer?
    
    /// Воспроизводит короткий звук – ровно 0.4 секунды, затем останавливается.
    func playShortPressSound() {
        guard let url = Bundle.main.url(forResource: "buttonSound", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.currentTime = 0
            audioPlayer?.play()
            // Через 0.4 секунды звук останавливается
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.audioPlayer?.stop()
            }
        } catch {
            print("Error playing short press sound: \(error)")
        }
    }
    
    /// Воспроизводит полный звук.
    func playLongPressSound() {
        guard let url = Bundle.main.url(forResource: "buttonSound", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.currentTime = 0
            audioPlayer?.play()
        } catch {
            print("Error playing long press sound: \(error)")
        }
    }
}

// MARK: - SoundButton
/// Кастомная обёртка для кнопки, реализующая логику звукового сопровождения:
/// • Если нажали (коротко) – воспроизводится короткий звук (0.4 сек)
/// • Если нажали и удержали (более 0.5 сек) – начинается воспроизведение полного звука, который останавливается сразу при отпускании.
struct SoundButton<Label: View>: View {
    let action: () -> Void
    let label: () -> Label
    
    // Отслеживаем время нажатия
    @State private var pressStartTime: Date? = nil
    @State private var longSoundStarted = false
    // Порог длительного нажатия (0.5 сек)
    private let longPressThreshold: TimeInterval = 0.5
    
    var body: some View {
        Button(action: {}) {
            label()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if pressStartTime == nil {
                        pressStartTime = Date()
                    }
                    if let start = pressStartTime,
                       Date().timeIntervalSince(start) >= longPressThreshold,
                       !longSoundStarted {
                        longSoundStarted = true
                        AudioManager.shared.playLongPressSound()
                    }
                }
                .onEnded { _ in
                    if longSoundStarted {
                        AudioManager.shared.audioPlayer?.stop()
                    } else {
                        AudioManager.shared.playShortPressSound()
                    }
                    action()
                    pressStartTime = nil
                    longSoundStarted = false
                }
        )
    }
}

// MARK: - AnimatedButtonStyle
struct AnimatedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .rotationEffect(.degrees(configuration.isPressed ? 3 : 0))
            .animation(.spring(response: 0.3, dampingFraction: 0.4), value: configuration.isPressed)
    }
}

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var gameData: GameData
    
    @State private var showRaceView = false
    @State private var showStatsView = false
    @State private var showBackgroundStoreView = false
    @State private var showBoosterStoreView = false
    
    // Состояния для анимации появления содержимого
    @State private var contentVisible = false
    @State private var buttonsVisible = false
    
    var body: some View {
        ZStack {
            // Фон с плавным появлением
            Image(gameData.selectedBackgroundName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(contentVisible ? 1 : 0)
                .animation(.easeIn(duration: 1.0), value: contentVisible)
            
            VStack {
                // Верхняя плашка с очками
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your Points")
                            .font(.caption)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                        Text("\(gameData.points)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .shadow(radius: 2)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.top, 40)
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                .opacity(contentVisible ? 1 : 0)
                .animation(.easeIn(duration: 1.0).delay(0.2), value: contentVisible)
                
                Spacer() // Spacer до кнопок
                
                // Кнопки, которые плавно появляются с эффектом масштабирования и изменения прозрачности
                VStack(spacing: 20) {
                    SoundButton(action: {
                        withAnimation(.easeInOut(duration: 0.3)) { showRaceView = true }
                    }, label: {
                        Image("Race")
                            .resizable()
                            .frame(width: 150, height: 60)
                    })
                    .buttonStyle(AnimatedButtonStyle())
                    .fullScreenCover(isPresented: $showRaceView) { RaceView() }
                    
                    SoundButton(action: {
                        withAnimation(.easeInOut(duration: 0.3)) { showStatsView = true }
                    }, label: {
                        Image("Stats")
                            .resizable()
                            .frame(width: 150, height: 60)
                    })
                    .buttonStyle(AnimatedButtonStyle())
                    .sheet(isPresented: $showStatsView) { StatsView() }
                    
                    SoundButton(action: {
                        withAnimation(.easeInOut(duration: 0.3)) { showBackgroundStoreView = true }
                    }, label: {
                        Image("Bstore")
                            .resizable()
                            .frame(width: 150, height: 60)
                    })
                    .buttonStyle(AnimatedButtonStyle())
                    .sheet(isPresented: $showBackgroundStoreView) { BackgroundStoreView() }
                    
                    SoundButton(action: {
                        withAnimation(.easeInOut(duration: 0.3)) { showBoosterStoreView = true }
                    }, label: {
                        Image("Booster")
                            .resizable()
                            .frame(width: 150, height: 60)
                    })
                    .buttonStyle(AnimatedButtonStyle())
                    .sheet(isPresented: $showBoosterStoreView) { BoosterStoreView() }
                }
                .opacity(buttonsVisible ? 1 : 0)
                .scaleEffect(buttonsVisible ? 1 : 0.8)
                .animation(.easeOut(duration: 1.2), value: buttonsVisible)
                .onAppear { buttonsVisible = true }
                
                Spacer() // Spacer после кнопок
            }
            .opacity(contentVisible ? 1 : 0)
            .animation(.easeIn(duration: 1.0), value: contentVisible)
        }
        .onAppear {
            contentVisible = true
        }
    }
}
