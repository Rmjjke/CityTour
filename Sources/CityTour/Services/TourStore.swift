import Foundation
import Observation

@Observable
@MainActor
final class TourStore {
    private(set) var tours: [GeneratedTour] = []
    private let storageKey = "saved_tours_v1"

    init() {
        load()
    }

    func save(_ tour: GeneratedTour) {
        tours.insert(tour, at: 0)
        persist()
    }

    func delete(at offsets: IndexSet) {
        tours.remove(atOffsets: offsets)
        persist()
    }

    func delete(_ tour: GeneratedTour) {
        tours.removeAll { $0.id == tour.id }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(tours) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([GeneratedTour].self, from: data)
        else { return }
        tours = decoded
    }
}
