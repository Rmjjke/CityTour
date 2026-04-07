import SwiftUI

struct MyToursView: View {
    let store: TourStore
    @Binding var showGenerateSheet: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.08, green: 0.12, blue: 0.25)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if store.tours.isEmpty {
                    emptyState
                } else {
                    tourList
                }
            }
            .navigationTitle("Мои туры")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 64))
                .foregroundStyle(.white.opacity(0.2))

            Text("Нет сохранённых туров")
                .font(.title3.bold())
                .foregroundStyle(.white.opacity(0.6))

            Text("Нажмите ✦ чтобы создать\nсвой первый маршрут")
                .font(.body)
                .foregroundStyle(.white.opacity(0.35))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 80)
    }

    private var tourList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(store.tours) { tour in
                    NavigationLink {
                        TourResultView(tour: tour)
                    } label: {
                        TourListCard(tour: tour)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
}

struct TourListCard: View {
    let tour: GeneratedTour

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: "ru_RU")
        return f
    }()

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundStyle(.cyan)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tour.city)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(tour.title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Label(tour.settings.duration.rawValue, systemImage: "clock")
                    Label(tour.settings.transport.rawValue, systemImage: tour.settings.transport.icon)
                }
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.35))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(tour.stops.count)")
                    .font(.title2.bold())
                    .foregroundStyle(.cyan)
                Text("точки")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(16)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.08), lineWidth: 1))
    }
}
