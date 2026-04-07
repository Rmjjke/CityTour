import SwiftUI
import Observation

@Observable
@MainActor
final class TourViewModel {
    var settings = TourSettings()
    var generatedTour: GeneratedTour?
    var isLoading = false
    var errorMessage: String?
    var showResult = false

    private let service = ClaudeService()
    private let store: TourStore

    init(store: TourStore) {
        self.store = store
    }

    func generateTour() async {
        isLoading = true
        errorMessage = nil
        generatedTour = nil

        do {
            let tour = try await service.generateTour(settings: settings)
            generatedTour = tour
            store.save(tour)
            showResult = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func reset() {
        showResult = false
        generatedTour = nil
        errorMessage = nil
    }
}
