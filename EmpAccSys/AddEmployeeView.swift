import SwiftUI

struct AddEmployeeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmployeeViewModel

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var gender: Gender = .male
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var salaryText: String = ""
    @State private var department: Department = .engineering

    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Особисті дані") {
                    TextField("Ім’я", text: $firstName)
                    TextField("Прізвище", text: $lastName)
                    Picker("Стать", selection: $gender) {
                        ForEach(Gender.allCases) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    DatePicker("Дата народження", selection: $birthDate, displayedComponents: .date)
                }
                Section("Робоча інформація") {
                    TextField("Заробітна плата", text: $salaryText)
                    #if os(iOS) || os(tvOS) || os(watchOS)
                        .keyboardType(.decimalPad)
                    #endif
                    Picker("Відділ", selection: $department) {
                        ForEach(Department.allCases) { d in
                            Text(d.rawValue).tag(d)
                        }
                    }
                }
            }
            .navigationTitle("Новий співробітник")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") { save() }
                        .disabled(!canSave)
                }
            }
            .alert("Помилка валідації", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }

    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(salaryText.replacingOccurrences(of: ",", with: ".")) != nil
    }

    private func save() {
        guard canSave else {
            validationMessage = "Перевірте правильність заповнення полів."
            showValidationAlert = true
            return
        }
        let salary = Double(salaryText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let employee = Employee(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            gender: gender,
            birthDate: birthDate,
            salary: salary,
            department: department
        )
        viewModel.add(employee)
        dismiss()
    }
}

#Preview {
    AddEmployeeView(viewModel: EmployeeViewModel())
}
