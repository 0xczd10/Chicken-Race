import SwiftUI

struct BoosterStoreView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Image(gameData.selectedBackgroundName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Booster Store")
                    .font(.largeTitle)
                    .padding(.top, 50)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                
                Spacer().frame(height: 20)
                
                // Карточка для x2 Booster
                boosterCard(
                    title: "x2 Multiplier",
                    description: "Double your race reward",
                    price: 50,
                    owned: gameData.x2Boosters
                ) {
                    if gameData.points >= 50 {
                        gameData.spendPoints(50)
                        gameData.buyX2Booster()
                    }
                }
                
                // Карточка для 100% Booster
                boosterCard(
                    title: "100% Win",
                    description: "Guarantees your chicken wins",
                    price: 40,
                    owned: gameData.guaranteedBoosters
                ) {
                    if gameData.points >= 40 {
                        gameData.spendPoints(40)
                        gameData.buyGuaranteedBooster()
                    }
                }
                
                Spacer()
                
                Text("Current Points: \(gameData.points)")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .shadow(radius: 2)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(GrayButtonStyle())
                .padding(.bottom, 50)
            }
        }
    }
    
    // Вспомогательная вью для вывода карточки бустера
    @ViewBuilder
    private func boosterCard(
        title: String,
        description: String,
        price: Int,
        owned: Int,
        buyAction: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .foregroundColor(.white)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            HStack {
                Text("Price: \(price)")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                Spacer()
                Text("Owned: \(owned)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Button("Buy") {
                    buyAction()
                }
                .buttonStyle(StoreButtonStyle())
                .disabled(gameData.points < price)
            }
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(12)
        .padding(.horizontal, 30)
    }
}
