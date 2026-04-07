import Foundation

actor ClaudeService {
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-sonnet-4-6"

    func generateTour(settings: TourSettings) async throws -> GeneratedTour {
        let apiKey = APIConfig.claudeAPIKey
        guard !apiKey.isEmpty else { throw ClaudeError.missingAPIKey }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        struct Msg: Encodable { let role: String; let content: String }
        struct Body: Encodable {
            let model: String
            let max_tokens: Int
            let messages: [Msg]
        }
        let body = Body(model: model, max_tokens: 4096,
                        messages: [Msg(role: "user", content: buildPrompt(settings: settings))])
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        request.httpBody = try encoder.encode(body)
        request.timeoutInterval = 120

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw ClaudeError.invalidResponse }
        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw ClaudeError.apiError(statusCode: http.statusCode, message: body)
        }

        let decoded = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        let raw = decoded.content.first?.text ?? ""
        return try parseTour(from: raw, settings: settings)
    }

    private func parseTour(from raw: String, settings: TourSettings) throws -> GeneratedTour {
        // Strip possible markdown code fences
        var json = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if json.hasPrefix("```") {
            json = json
                .components(separatedBy: "\n")
                .dropFirst()
                .joined(separator: "\n")
        }
        if json.hasSuffix("```") {
            json = String(json.dropLast(3))
        }
        json = json.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = json.data(using: .utf8) else { throw ClaudeError.parseError }

        struct RawTour: Decodable {
            let title: String
            let intro: String
            let stops: [TourStop]
            let restaurants: [TourRestaurant]?
            let tips: String
        }

        let raw = try JSONDecoder().decode(RawTour.self, from: data)
        return GeneratedTour(
            city: settings.city,
            settings: settings,
            title: raw.title,
            intro: raw.intro,
            stops: raw.stops,
            restaurants: raw.restaurants ?? [],
            tips: raw.tips
        )
    }

    private func buildPrompt(settings: TourSettings) -> String {
        let mealsInstruction = settings.includeMeals
            ? "Включи 2-3 ресторана или кафе в массив restaurants."
            : "Оставь массив restaurants пустым []."

        let childrenInstruction = settings.withChildren
            ? "Для каждой точки заполни поле childrenNote — совет о том, подходит ли место детям."
            : "Поле childrenNote оставь null для каждой точки."

        return """
        Ты — опытный гид. Создай туристический маршрут по городу \(settings.city).

        Параметры:
        - Продолжительность: \(settings.duration.rawValue) (\(settings.duration.hours) ч)
        - Передвижение: \(settings.transport.rawValue)
        - Приёмы пищи: \(settings.includeMeals ? "да" : "нет")
        - С детьми: \(settings.withChildren ? "да" : "нет")

        Верни ТОЛЬКО валидный JSON, без markdown, без пояснений. Ровно в таком формате:
        {
          "title": "Короткое название тура (до 40 символов)",
          "intro": "Вступление 2-3 предложения с ярким фактом о городе",
          "stops": [
            {
              "name": "Название места",
              "description": "Живое описание 2-3 предложения",
              "fact": "Один интересный факт",
              "duration": "1–1.5 часа",
              "address": "Полный адрес для навигации, \(settings.city)",
              "childrenNote": null
            }
          ],
          "restaurants": [],
          "tips": "Финальный совет о городе"
        }

        \(mealsInstruction)
        \(childrenInstruction)
        Количество точек: \(settings.duration.stopCount).
        Учитывай передвижение \(settings.transport == .walking ? "пешком — компактный маршрут" : "на авто — можно охватить больше").
        """
    }
}

enum ClaudeError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case parseError
    case apiError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "API-ключ не настроен"
        case .invalidResponse: return "Некорректный ответ от сервера"
        case .parseError: return "Не удалось разобрать ответ AI"
        case .apiError(let code, let msg): return "Ошибка API (\(code)): \(msg)"
        }
    }
}

private struct ClaudeResponse: Decodable {
    let content: [ContentBlock]
    struct ContentBlock: Decodable { let text: String }
}
