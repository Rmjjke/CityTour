import SwiftUI

struct StatisticsView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.08, green: 0.12, blue: 0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.15))
                Text("Статистика")
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.4))
                Text("Скоро здесь появится\nстатистика ваших путешествий")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.25))
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 80)
        }
    }
}
