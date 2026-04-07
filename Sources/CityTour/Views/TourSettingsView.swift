import SwiftUI

struct TourSettingsView: View {
    @Bindable var viewModel: TourViewModel
    var onDismiss: (() -> Void)?
    @State private var navigateToResult = false

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                VStack(spacing: 24) {
                    cityHeader
                    durationSection
                    transportSection
                    extrasSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .safeAreaInset(edge: .bottom) {
                generateButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
            }
        }
        .navigationTitle("Настройки тура")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToResult) {
            if let tour = viewModel.generatedTour {
                TourResultView(tour: tour, onDismiss: onDismiss)
            }
        }
        .task(id: viewModel.showResult) {
            if viewModel.showResult { navigateToResult = true }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.08, green: 0.12, blue: 0.25)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var cityHeader: some View {
        HStack {
            Image(systemName: "location.fill").foregroundStyle(.cyan)
            Text(viewModel.settings.city)
                .font(.title2.bold()).foregroundStyle(.white)
            Spacer()
        }
        .padding(16)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var durationSection: some View {
        SettingsSection(title: "Продолжительность", icon: "clock.fill") {
            VStack(spacing: 8) {
                ForEach(TourDuration.allCases) { duration in
                    DurationRow(duration: duration, isSelected: viewModel.settings.duration == duration) {
                        viewModel.settings.duration = duration
                    }
                }
            }
        }
    }

    private var transportSection: some View {
        SettingsSection(title: "Способ передвижения", icon: "arrow.triangle.swap") {
            HStack(spacing: 12) {
                ForEach(TransportMode.allCases) { mode in
                    TransportButton(mode: mode, isSelected: viewModel.settings.transport == mode) {
                        viewModel.settings.transport = mode
                    }
                }
            }
        }
    }

    private var extrasSection: some View {
        SettingsSection(title: "Дополнительно", icon: "slider.horizontal.3") {
            VStack(spacing: 0) {
                ToggleRow(title: "Приёмы пищи", subtitle: "Кафе и рестораны в маршруте",
                          icon: "fork.knife", isOn: $viewModel.settings.includeMeals)
                Divider().background(.white.opacity(0.1))
                ToggleRow(title: "Путешествую с детьми", subtitle: "Детские места и активности",
                          icon: "figure.and.child.holdinghands", isOn: $viewModel.settings.withChildren)
            }
        }
    }

    private var generateButton: some View {
        VStack(spacing: 12) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                Task { await viewModel.generateTour() }
            } label: {
                HStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView().tint(.white).scaleEffect(0.9)
                        Text("Генерирую маршрут...")
                    } else {
                        Image(systemName: "sparkles")
                        Text("Сгенерировать мой тур").fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(18)
                .background(
                    Group {
                        if viewModel.isLoading {
                            LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                        } else {
                            LinearGradient(colors: [.cyan, .blue, .indigo], startPoint: .leading, endPoint: .trailing)
                        }
                    }
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: viewModel.isLoading ? .clear : .cyan.opacity(0.4), radius: 16)
                .animation(.easeInOut, value: viewModel.isLoading)
            }
            .accessibilityIdentifier("generate_tour_button")
            .disabled(viewModel.isLoading)
        }
    }
}

// MARK: - Subviews

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundStyle(.cyan).font(.subheadline)
                Text(title).font(.headline).foregroundStyle(.white)
            }
            content
                .padding(16)
                .background(.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct DurationRow: View {
    let duration: TourDuration
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .cyan : .white.opacity(0.3))
                    .font(.title3)
                Text(duration.rawValue).foregroundStyle(.white)
                Spacer()
                Text("\(duration.hours) ч").foregroundStyle(.white.opacity(0.4)).font(.caption)
            }
        }
    }
}

struct TransportButton: View {
    let mode: TransportMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: mode.icon)
                Text(mode.rawValue).fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.06))
            .foregroundStyle(isSelected ? .cyan : .white.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? Color.cyan.opacity(0.6) : Color.clear, lineWidth: 1.5))
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundStyle(.cyan).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).foregroundStyle(.white)
                Text(subtitle).foregroundStyle(.white.opacity(0.45)).font(.caption)
            }
            Spacer()
            Toggle("", isOn: $isOn).tint(.cyan)
        }
        .padding(.vertical, 10)
    }
}
