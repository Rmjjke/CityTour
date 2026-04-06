# CityTour — AI-гид по городам мира

iOS-приложение для генерации персонализированных туристических маршрутов с помощью Claude AI.

## Возможности

- Поиск любого города мира
- Настройка продолжительности тура (2 часа — 2 дня)
- Выбор способа передвижения (пешком / на авто)
- Включение приёмов пищи в маршрут
- Режим путешествия с детьми
- Генерация подробного маршрута через Claude AI
- Поделиться маршрутом

## Настройка

1. Откройте `Sources/CityTour/Services/APIConfig.swift`
2. Вставьте ваш API-ключ Claude:
   ```swift
   static let claudeAPIKey: String = "sk-ant-..."
   ```
   Получить ключ: [console.anthropic.com](https://console.anthropic.com)

## Запуск

```bash
xcodegen generate
open CityTour.xcodeproj
```

Запустите на симуляторе или реальном устройстве (iOS 17+).

## Стек

- SwiftUI + Swift 6
- Observation framework
- Claude API (claude-opus-4-6)
- Native iOS, без зависимостей
