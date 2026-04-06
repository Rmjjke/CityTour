import SwiftUI
import Observation

@Observable
final class TourViewModel {
    var settings = TourSettings()
    var generatedTour: String = ""
    var isLoading = false
    var errorMessage: String?
    var showResult = false

    private let service = ClaudeService()

    func generateTour() async {
        isLoading = true
        errorMessage = nil
        generatedTour = ""

        do {
            let result = try await service.generateTour(settings: settings)
            generatedTour = result
            showResult = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func reset() {
        showResult = false
        generatedTour = ""
        errorMessage = nil
    }
}
