import SwiftUI
import MapKit

struct TourResultView: View {
    let tour: GeneratedTour
    var onDismiss: (() -> Void)?

    @State private var showMapPicker = false
    @State private var isGeocodingForMaps = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.08, green: 0.12, blue: 0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    tourHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 24)

                    introSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)

                    stopsSection
                        .padding(.bottom, 28)

                    if !tour.restaurants.isEmpty {
                        restaurantsSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 28)
                    }

                    tipsSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                }
            }
        }
        .navigationTitle("Ваш маршрут")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { onDismiss?() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                        Text("Закрыть")
                    }
                    .foregroundStyle(.cyan)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let text = buildShareText()
                    let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows.first?.rootViewController?
                        .present(av, animated: true)
                } label: {
                    Image(systemName: "square.and.arrow.up").foregroundStyle(.cyan)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            buildRouteButton
        }
        .confirmationDialog("Открыть маршрут в", isPresented: $showMapPicker, titleVisibility: .visible) {
            Button("Apple Maps") { openAppleMaps() }
            Button("Google Maps") { openGoogleMaps() }
            Button("Отмена", role: .cancel) {}
        }
    }

    // MARK: - Sections

    private var tourHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                Image(systemName: "map.fill").font(.title2).foregroundStyle(.cyan)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(tour.city).font(.title2.bold()).foregroundStyle(.white)
                Text(tour.title).font(.subheadline).foregroundStyle(.white.opacity(0.6))
                HStack(spacing: 10) {
                    Label(tour.settings.duration.rawValue, systemImage: "clock")
                    Label(tour.settings.transport.rawValue, systemImage: tour.settings.transport.icon)
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            }
            Spacer()
        }
        .padding(16)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("О городе", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundStyle(.cyan)
            Text(tour.intro)
                .font(.body)
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(5)
        }
        .padding(18)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var stopsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label("Маршрут", systemImage: "mappin.and.ellipse")
                    .font(.headline)
                    .foregroundStyle(.cyan)
                Spacer()
                Text("\(tour.stops.count) точки")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            ForEach(Array(tour.stops.enumerated()), id: \.element.id) { index, stop in
                StopCard(stop: stop, index: index + 1, city: tour.city, isLast: index == tour.stops.count - 1)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
    }

    private var restaurantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Где поесть", systemImage: "fork.knife")
                .font(.headline)
                .foregroundStyle(.cyan)

            ForEach(tour.restaurants) { restaurant in
                RestaurantCard(restaurant: restaurant)
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Совет", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(.yellow)
            Text(tour.tips)
                .font(.body)
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(5)
        }
        .padding(18)
        .background(.yellow.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.yellow.opacity(0.2), lineWidth: 1))
    }

    private var buildRouteButton: some View {
        Button { showMapPicker = true } label: {
            HStack(spacing: 10) {
                if isGeocodingForMaps {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                }
                Text("Построить маршрут").fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(LinearGradient(colors: [Color(red: 0.1, green: 0.7, blue: 0.4), Color(red: 0.0, green: 0.5, blue: 0.9)], startPoint: .leading, endPoint: .trailing))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .green.opacity(0.3), radius: 12)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
        .disabled(isGeocodingForMaps)
    }

    // MARK: - Maps

    private func openAppleMaps() {
        isGeocodingForMaps = true
        Task {
            let geocoder = CLGeocoder()
            var items: [MKMapItem] = []
            for stop in tour.stops {
                let query = "\(stop.name), \(tour.city)"
                if let results = try? await geocoder.geocodeAddressString(query),
                   let loc = results.first?.location {
                    let placemark = MKPlacemark(coordinate: loc.coordinate)
                    let item = MKMapItem(placemark: placemark)
                    item.name = stop.name
                    items.append(item)
                }
            }
            await MainActor.run {
                isGeocodingForMaps = false
                let mode = tour.settings.transport == .walking
                    ? MKLaunchOptionsDirectionsModeWalking
                    : MKLaunchOptionsDirectionsModeDriving
                MKMapItem.openMaps(with: items, launchOptions: [MKLaunchOptionsDirectionsModeKey: mode])
            }
        }
    }

    private func openGoogleMaps() {
        let stops = tour.stops.map { "\($0.name), \(tour.city)" }
            .compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) }
            .joined(separator: "/")
        let mode = tour.settings.transport == .walking ? "walking" : "driving"
        let urlString = "https://www.google.com/maps/dir/\(stops)/?travelmode=\(mode)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func buildShareText() -> String {
        var text = "🗺 \(tour.title) — \(tour.city)\n\n"
        text += tour.intro + "\n\n"
        for (i, stop) in tour.stops.enumerated() {
            text += "📍 \(i + 1). \(stop.name)\n\(stop.description)\n💡 \(stop.fact)\n\n"
        }
        text += "✨ \(tour.tips)"
        return text
    }
}

// MARK: - Stop Card

struct StopCard: View {
    let stop: TourStop
    let index: Int
    let city: String
    let isLast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo
            WikiPhotoView(query: "\(stop.name) \(city)")
                .frame(height: 180)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 16, bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0, topTrailingRadius: 16
                ))
                .overlay(alignment: .topLeading) {
                    // Stop number badge
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 36, height: 36)
                        Text("\(index)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(12)
                }

            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text(stop.name)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text(stop.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineSpacing(4)

                // Fact
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                        .padding(.top, 2)
                    Text(stop.fact)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineSpacing(3)
                }
                .padding(10)
                .background(.yellow.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                HStack(spacing: 16) {
                    Label(stop.duration, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                    if !stop.address.isEmpty {
                        Label(stop.address, systemImage: "mappin")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                            .lineLimit(1)
                    }
                }

                if let note = stop.childrenNote {
                    Label(note, systemImage: "figure.and.child.holdinghands")
                        .font(.caption)
                        .foregroundStyle(.green.opacity(0.9))
                        .lineSpacing(3)
                }
            }
            .padding(16)
            .background(.white.opacity(0.06))
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0, bottomLeadingRadius: 16,
                bottomTrailingRadius: 16, topTrailingRadius: 0
            ))

            // Connector line
            if !isLast {
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(LinearGradient(colors: [.cyan.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
                        .frame(width: 2, height: 24)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Restaurant Card

struct RestaurantCard: View {
    let restaurant: TourRestaurant

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.orange.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "fork.knife").foregroundStyle(.orange)
            }
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(restaurant.name).font(.headline).foregroundStyle(.white)
                    Spacer()
                    Text(restaurant.priceRange).font(.caption).foregroundStyle(.orange)
                }
                Text(restaurant.cuisine).font(.caption).foregroundStyle(.white.opacity(0.5))
                Text(restaurant.description).font(.caption).foregroundStyle(.white.opacity(0.65)).lineLimit(2)
            }
        }
        .padding(14)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Wikipedia Photo

struct WikiPhotoView: View {
    let query: String
    @State private var photoURL: URL?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.15, blue: 0.3), Color(red: 0.05, green: 0.1, blue: 0.2)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            if let url = photoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        photoPlaceholder
                    default:
                        ProgressView().tint(.white)
                    }
                }
            } else {
                photoPlaceholder
            }
        }
        .task(id: query) {
            photoURL = await fetchWikiPhoto(query: query)
        }
    }

    private var photoPlaceholder: some View {
        Image(systemName: "photo")
            .font(.largeTitle)
            .foregroundStyle(.white.opacity(0.2))
    }

    private func fetchWikiPhoto(query: String) async -> URL? {
        let encoded = query
            .replacingOccurrences(of: " ", with: "_")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? query
        guard let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encoded)") else { return nil }

        struct Wiki: Decodable {
            struct Thumb: Decodable { let source: String }
            let thumbnail: Thumb?
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let wiki = try? JSONDecoder().decode(Wiki.self, from: data),
              let src = wiki.thumbnail?.source else { return nil }
        return URL(string: src)
    }
}
