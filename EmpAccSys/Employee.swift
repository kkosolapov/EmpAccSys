import Foundation

enum Gender: String, CaseIterable, Codable, Identifiable {
    case male = "Чоловіча"
    case female = "Жіноча"

    var id: String { rawValue }
}

enum Department: String, CaseIterable, Codable, Identifiable {
    case engineering = "Інженерія"
    case sales = "Продажі"
    case marketing = "Маркетинг"
    case hr = "HR"
    case finance = "Фінанси"
    case support = "Підтримка"
    case other = "Інший"

    var id: String { rawValue }
}

struct Employee: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var firstName: String
    var lastName: String
    var gender: Gender
    var birthDate: Date
    var salary: Double
    var department: Department

    var fullName: String { "\(firstName) \(lastName)" }
}
