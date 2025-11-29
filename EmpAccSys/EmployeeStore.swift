import Foundation

protocol EmployeePersisting {
    func load() throws -> [Employee]
    func save(_ employees: [Employee]) throws
}

final class PlistEmployeeStore: EmployeePersisting {
    private let fileURL: URL
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()

    init(filename: String = "employees.plist") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent(filename)
        encoder.outputFormat = .xml
    }

    func load() throws -> [Employee] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([Employee].self, from: data)
    }

    func save(_ employees: [Employee]) throws {
        let data = try encoder.encode(employees)
        try data.write(to: fileURL, options: [.atomic])
    }
}
