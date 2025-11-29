import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EmployeeViewModel()
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredEmployees.isEmpty {
                    ContentUnavailableView("Немає співробітників", systemImage: "person.3", description: Text("Додайте першого співробітника"))
                } else {
                    List {
                        ForEach(viewModel.allDepartmentsWithData) { department in
                            let employees = viewModel.groupedByDepartment[department] ?? []
                            Section {
                                ForEach(employees) { emp in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(emp.firstName) \(emp.lastName)")
                                                .font(.headline)
                                            Text(emp.gender.rawValue)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(String(format: "%.2f ₴", emp.salary))
                                            .monospacedDigit()
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .onDelete { indexSet in
                                    viewModel.remove(at: indexSet, in: department)
                                }
                            } header: {
                                let stats = viewModel.stats(for: department)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(department.rawValue)
                                    Text("К-сть: \(stats.count), Середня ЗП: \(String(format: "%.2f ₴", stats.averageSalary))")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Співробітники")
            .toolbar {

                ToolbarItem(placement: .automatic) {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("Додати", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEmployeeView(viewModel: viewModel)
            }
            .searchable(text: $viewModel.searchText, prompt: "Пошук за ім’ям або прізвищем")
        }
    }
}

#Preview {
    ContentView()
}
