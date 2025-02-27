import SwiftUI
// Для iOS 16+: import Charts

struct StatsView: View {
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
                Text("Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                    .padding(.top, 20)
                
                Spacer().frame(height: 20)
                
                // Красивые «карточки» со статистикой
                statCard(title: "Total Races", value: "\(gameData.totalRaces)")
                statCard(title: "Wins", value: "\(gameData.wins)")
                statCard(title: "Losses", value: "\(gameData.losses)")
                
                statCard(title: "x2 Boosters Owned", value: "\(gameData.x2Boosters)")
                statCard(title: "100% Boosters Owned", value: "\(gameData.guaranteedBoosters)")
                statCard(title: "Backgrounds Purchased", value: "\(gameData.purchasedBackgrounds.count)")
                
                if gameData.selectedBackgroundIndex < gameData.allBackgrounds.count {
                    statCard(title: "Current Background",
                             value: gameData.allBackgrounds[gameData.selectedBackgroundIndex].name)
                }
                
                
                Spacer()
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(GrayButtonStyle())
                .padding(.bottom, 90)
            }
        }
    }
    
    // Вспомогательная карточка
    @ViewBuilder
    private func statCard(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.4))
        .cornerRadius(12)
        .padding(.horizontal, 60)
    }
}
