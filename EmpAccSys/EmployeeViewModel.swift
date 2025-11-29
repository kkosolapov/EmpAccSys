import Foundation
import Combine

@MainActor
final class EmployeeViewModel: ObservableObject {
    @Published private(set) var employees: [Employee] = []
    @Published var searchText: String = ""

    private let store: EmployeePersisting

    init(store: EmployeePersisting) {
        self.store = store
        load()
    }

    convenience init() {
        self.init(store: PlistEmployeeStore())
    }

    func load() {
        do {
            employees = try store.load()
        } catch {
            employees = []
            print("Failed to load employees: \(error)")
        }
    }

    func add(_ employee: Employee) {
        employees.append(employee)
        persist()
    }

    func remove(at offsets: IndexSet, in department: Department) {
        let idsToRemove = offsets.compactMap { index in
            groupedByDepartment[department]?[index].id
        }
        employees.removeAll { idsToRemove.contains($0.id) }
        persist()
    }

    private func persist() {
        do {
            try store.save(employees)
        } catch {
            print("Failed to save employees: \(error)")
        }
    }

    var filteredEmployees: [Employee] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return employees }
        return employees.filter {
            $0.firstName.localizedCaseInsensitiveContains(trimmed) ||
            $0.lastName.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var groupedByDepartment: [Department: [Employee]] {
        Dictionary(grouping: filteredEmployees, by: { $0.department })
            .mapValues { $0.sorted { $0.lastName.localizedCompare($1.lastName) == .orderedAscending } }
    }

    struct DepartmentStats: Equatable {
        let count: Int
        let averageSalary: Double
    }

    func stats(for department: Department) -> DepartmentStats {
        let list = groupedByDepartment[department] ?? []
        let count = list.count
        let average = count > 0 ? list.map { $0.salary }.reduce(0, +) / Double(count) : 0
        return DepartmentStats(count: count, averageSalary: average)
    }

    var allDepartmentsWithData: [Department] {
        Department.allCases.filter { (groupedByDepartment[$0] ?? []).isEmpty == false }
    }
}
