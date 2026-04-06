import Foundation

actor ClaudeService {
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-opus-4-6"

    func generateTour(settings: TourSettings) async throws -> String {
        let apiKey = APIConfig.claudeAPIKey
        guard !apiKey.isEmpty else {
            throw ClaudeError.missingAPIKey
        }

        let prompt = buildPrompt(settings: settings)

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 4096,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ClaudeError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        let decoded = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        return decoded.content.first?.text ?? ""
    }

    private func buildPrompt(settings: TourSettings) -> String {
        """
        Ты — опытный гид и составитель маршрутов. Создай подробный туристический маршрут по городу \(settings.city).

        Параметры тура:
        - Продолжительность: \(settings.duration.rawValue) (\(settings.duration.hours) часов)
        - Передвижение: \(settings.transport.rawValue)
        - Включить приёмы пищи: \(settings.includeMeals ? "Да" : "Нет")
        - Путешествие с детьми: \(settings.withChildren ? "Да" : "Нет")

        Составь маршрут в следующем формате:

        1. Начни с яркого вступления о городе (2-3 предложения с интересным фактом)
        2. Для каждой точки маршрута укажи:
           - 📍 Название места
           - Описание (2-3 предложения, живым языком)
           - 💡 Интересный факт
           - ⏱ Рекомендуемое время пребывания
           \(settings.withChildren ? "- 👶 Подходит ли для детей и почему" : "")
        3. \(settings.includeMeals ? "Включи рекомендации по кафе и ресторанам между точками с указанием кухни и ценового сегмента" : "")
        4. Завершающий совет о городе

        Пиши живо, интересно, с эмоциями. Используй эмодзи для структурирования.
        Учитывай, что передвижение \(settings.transport == .walking ? "пешком, выбирай компактный маршрут" : "на авто, можно охватить больше площадь города").
        \(settings.withChildren ? "Учитывай интересы детей: интерактивные места, парки, не слишком длинные переходы." : "")
        """
    }
}

enum ClaudeError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API-ключ не настроен. Добавьте ключ Claude в APIConfig.swift"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .apiError(let code, let message):
            return "Ошибка API (\(code)): \(message)"
        }
    }
}

struct ClaudeResponse: Decodable {
    let content: [ContentBlock]

    struct ContentBlock: Decodable {
        let text: String
    }
}
