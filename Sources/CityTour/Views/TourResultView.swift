import SwiftUI

struct TourResultView: View {
    @Bindable var viewModel: TourViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    tourHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 20)

                    tourContent
                        .padding(.horizontal, 20)

                    bottomActions
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Ваш маршрут")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.reset()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .foregroundStyle(.cyan)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.cyan)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [viewModel.generatedTour])
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.08, green: 0.12, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var tourHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundStyle(.cyan)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.settings.city)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    Label(viewModel.settings.duration.rawValue, systemImage: "clock")
                    Label(viewModel.settings.transport.rawValue, systemImage: viewModel.settings.transport.icon)
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
            }

            Spacer()
        }
        .padding(16)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var tourContent: some View {
        Text(viewModel.generatedTour)
            .font(.body)
            .foregroundStyle(.white.opacity(0.9))
            .lineSpacing(6)
            .padding(20)
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var bottomActions: some View {
        VStack(spacing: 12) {
            Button {
                showShareSheet = true
            } label: {
                Label("Поделиться маршрутом", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(.white.opacity(0.08))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
            }

            Button {
                viewModel.reset()
                dismiss()
            } label: {
                Label("Создать новый тур", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .cyan.opacity(0.3), radius: 10)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        TourResultView(viewModel: {
            let vm = TourViewModel()
            vm.settings.city = "Барселона"
            vm.settings.duration = .fullDay
            vm.generatedTour = """
            🌟 Добро пожаловать в Барселону — город, где архитектура превращается в искусство! Знаете ли вы, что Барселона была основана около 2000 лет назад римлянами под названием Barcino?

            📍 **1. Саграда Фамилия**
            Невероятный собор Антонио Гауди, строительство которого началось в 1882 году и продолжается по сей день. Каждый фасад рассказывает свою историю: Рождество, Страсти и слава.

            💡 Интересный факт: По завещанию Гауди, собор должен быть выше горы Монтжуик, которую считают символом города.

            ⏱ Рекомендуемое время: 1.5-2 часа
            """
            return vm
        }())
    }
}
