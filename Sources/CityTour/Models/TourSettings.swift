import Foundation

enum TourDuration: String, CaseIterable, Identifiable, Codable {
    case twoHours = "2 часа"
    case halfDay = "Полдня (4 ч)"
    case fullDay = "Целый день (8 ч)"
    case weekend = "Выходные (2 дня)"

    var id: String { rawValue }

    var hours: Int {
        switch self {
        case .twoHours: 2
        case .halfDay: 4
        case .fullDay: 8
        case .weekend: 16
        }
    }

    var stopCount: Int {
        switch self {
        case .twoHours: 3
        case .halfDay: 5
        case .fullDay: 8
        case .weekend: 12
        }
    }
}

enum TransportMode: String, CaseIterable, Identifiable, Codable {
    case walking = "Пешком"
    case car = "На авто"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .walking: "figure.walk"
        case .car: "car.fill"
        }
    }
}

struct TourSettings: Codable {
    var city: String = ""
    var duration: TourDuration = .halfDay
    var transport: TransportMode = .walking
    var includeMeals: Bool = true
    var withChildren: Bool = false
}
