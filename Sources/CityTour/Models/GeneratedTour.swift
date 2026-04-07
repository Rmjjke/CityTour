import Foundation

struct TourStop: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let fact: String
    let duration: String
    let address: String
    let childrenNote: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, fact, duration, address, childrenNote
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        description = try c.decode(String.self, forKey: .description)
        fact = try c.decode(String.self, forKey: .fact)
        duration = try c.decode(String.self, forKey: .duration)
        address = try c.decode(String.self, forKey: .address)
        childrenNote = try? c.decode(String.self, forKey: .childrenNote)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(description, forKey: .description)
        try c.encode(fact, forKey: .fact)
        try c.encode(duration, forKey: .duration)
        try c.encode(address, forKey: .address)
        try c.encodeIfPresent(childrenNote, forKey: .childrenNote)
    }
}

struct TourRestaurant: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let cuisine: String
    let priceRange: String
    let address: String

    enum CodingKeys: String, CodingKey {
        case id, name, description, cuisine, priceRange, address
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        description = try c.decode(String.self, forKey: .description)
        cuisine = (try? c.decode(String.self, forKey: .cuisine)) ?? ""
        priceRange = (try? c.decode(String.self, forKey: .priceRange)) ?? ""
        address = (try? c.decode(String.self, forKey: .address)) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(description, forKey: .description)
        try c.encode(cuisine, forKey: .cuisine)
        try c.encode(priceRange, forKey: .priceRange)
        try c.encode(address, forKey: .address)
    }
}

struct GeneratedTour: Identifiable, Codable {
    let id: UUID
    let city: String
    let settings: TourSettings
    let title: String
    let intro: String
    let stops: [TourStop]
    let restaurants: [TourRestaurant]
    let tips: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, city, settings, title, intro, stops, restaurants, tips, createdAt
    }

    init(id: UUID = UUID(), city: String, settings: TourSettings, title: String,
         intro: String, stops: [TourStop], restaurants: [TourRestaurant],
         tips: String, createdAt: Date = Date()) {
        self.id = id
        self.city = city
        self.settings = settings
        self.title = title
        self.intro = intro
        self.stops = stops
        self.restaurants = restaurants
        self.tips = tips
        self.createdAt = createdAt
    }
}
