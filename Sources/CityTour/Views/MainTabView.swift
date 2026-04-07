import SwiftUI

struct MainTabView: View {
    @State private var store = TourStore()
    @State private var selectedTab: AppTab = .myTours
    @State private var showGenerateSheet = false

    enum AppTab { case myTours, statistics }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundGradient.ignoresSafeArea()

            // Content
            Group {
                switch selectedTab {
                case .myTours:
                    MyToursView(store: store, showGenerateSheet: $showGenerateSheet)
                case .statistics:
                    StatisticsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .sheet(isPresented: $showGenerateSheet) {
            GenerateFlowView(store: store)
        }
    }

    private var customTabBar: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // Мои туры
            TabBarButton(
                icon: "bookmark.fill",
                label: "Мои туры",
                isSelected: selectedTab == .myTours
            ) { selectedTab = .myTours }

            Spacer()

            // Center generate button
            Button {
                showGenerateSheet = true
            } label: {
                ZStack {

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: .cyan.opacity(0.5), radius: 16)

                    Image(systemName: "sparkles")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }
            .accessibilityIdentifier("generate_tab_button")
            .offset(y: -16)

            Spacer()

            // Статистика
            TabBarButton(
                icon: "chart.bar.fill",
                label: "Статистика",
                isSelected: selectedTab == .statistics
            ) { selectedTab = .statistics }
        }
        .padding(.horizontal, 32)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Divider().opacity(0.2)
                }
                .ignoresSafeArea(edges: .bottom)
        )
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
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isSelected ? .cyan : .white.opacity(0.4))
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

struct GenerateFlowView: View {
    let store: TourStore
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TourViewModel

    init(store: TourStore) {
        self.store = store
        _viewModel = State(initialValue: TourViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ContentView(viewModel: viewModel, onDismiss: { dismiss() })
        }
    }
}
