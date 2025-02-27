import SwiftUI

struct BackgroundStoreView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    
    // Для создания адаптивной сетки
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // Фоновое изображение – отключаем обработку касаний
            Image(gameData.selectedBackgroundName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            // Затемняющий слой – тоже не перехватывает касания
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack {
                Text("Background Store")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                
                // Отображение текущих очков
                Text("Your Points: \(gameData.points)")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .shadow(radius: 2)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                
                Spacer().frame(height: 20)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(gameData.allBackgrounds) { background in
                            VStack {
                                // Изображение фона
                                Image(background.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 100)
                                    .clipped()
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                                
                                Text(background.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                
                                // Логика покупки или выбора фона
                                if background.id == 0 {
                                    // Бесплатный фон
                                    Button("Select") {
                                        gameData.selectBackground(background.id)
                                    }
                                    .disabled(gameData.selectedBackgroundIndex == background.id)
                                    .buttonStyle(StoreButtonStyle())
                                } else {
                                    if gameData.purchasedBackgrounds.contains(background.id) {
                                        Button("Select") {
                                            gameData.selectBackground(background.id)
                                        }
                                        .disabled(gameData.selectedBackgroundIndex == background.id)
                                        .buttonStyle(StoreButtonStyle())
                                    } else {
                                        Text("Price: \(background.price)")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .shadow(radius: 2)
                                        
                                        Button(action: {
                                            if gameData.points >= background.price {
                                                gameData.spendPoints(background.price)
                                                gameData.buyBackground(background.id)
                                                gameData.selectBackground(background.id)
                                            }
                                        }) {
                                            Text("Buy")
                                                .padding(6)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(StoreButtonStyle())
                                        // Кнопка блокируется, если очков недостаточно
                                        .disabled(gameData.points < background.price)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(12)
                            // Обеспечиваем, что область ячейки воспринимается как прямоугольник для касаний
                            .contentShape(Rectangle())
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
                Spacer()
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(GrayButtonStyle())
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Custom Button Styles
struct StoreButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(6)
            .background(Color.yellow.opacity(configuration.isPressed ? 0.6 : 0.8))
            .foregroundColor(.black)
            .cornerRadius(8)
            .shadow(radius: 2)
    }
}
