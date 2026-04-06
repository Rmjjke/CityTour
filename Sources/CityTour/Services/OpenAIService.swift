import Foundation

actor OpenAIService {
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let model = "gpt-4o"

    func generateTour(settings: TourSettings) async throws -> String {
        let apiKey = APIConfig.openAIKey
        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }

        let prompt = buildPrompt(settings: settings)

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

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
            throw OpenAIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decoded.choices.first?.message.content ?? ""
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

enum OpenAIError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API-ключ не настроен. Добавьте ключ OpenAI в APIConfig.swift"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .apiError(let code, let message):
            return "Ошибка API (\(code)): \(message)"
        }
    }
}

struct OpenAIResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String
    }
}
