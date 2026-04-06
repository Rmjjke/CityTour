import SwiftUI

struct ContentView: View {
    @State private var viewModel = TourViewModel()
    @State private var navigateToSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                VStack(spacing: 32) {
                    Spacer()

                    headerSection

                    citySearchSection

                    if !viewModel.settings.city.isEmpty {
                        continueButton
                    }

                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                TourSettingsView(viewModel: viewModel)
            }
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

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "map.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.4), radius: 20)

            Text("CityTour")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Ваш персональный AI-гид\nв любом городе мира")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }

    private var citySearchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Куда едем?")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.5))

                TextField("", text: $viewModel.settings.city, prompt: Text("Введите город...").foregroundStyle(.white.opacity(0.35)))
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .onSubmit {
                        if !viewModel.settings.city.isEmpty {
                            navigateToSettings = true
                        }
                    }

                if !viewModel.settings.city.isEmpty {
                    Button {
                        viewModel.settings.city = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            .padding(16)
            .background(.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
        }
    }

    private var continueButton: some View {
        Button {
            navigateToSettings = true
        } label: {
            HStack {
                Text("Настроить тур")
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
            }
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
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .cyan.opacity(0.3), radius: 12)
        }
    }
}

#Preview {
    ContentView()
}
