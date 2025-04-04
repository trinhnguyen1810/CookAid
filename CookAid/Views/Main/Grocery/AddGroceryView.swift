import SwiftUI

struct AddGroceryView: View {
    @ObservedObject var groceryManager: GroceryManager
    @State private var name: String = ""
    @State private var category: String = "Others" // Default category
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode
    
    let categories = [
        "Fruits & Vegetables",
        "Proteins",
        "Dairy & Dairy Alternatives",
        "Grains and Legumes",
        "Spices, Seasonings and Herbs",
        "Sauces and Condiments",
        "Baking Essentials",
        "Others"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Grocery Item")) {
                    TextField("Grocery Name", text: $name)
                        .font(.custom("Cochin", size: 18))

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.custom("Cochin", size: 18))
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.custom("Cochin", size: 16))
                            .foregroundColor(.red)
                    }
                }

                Button("Add Grocery") {
                    addGrocery()
                }
                .font(.custom("Cochin", size: 18))
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .navigationTitle("Add Grocery")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func addGrocery() {
        // Trim whitespace and check for empty string
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Grocery name cannot be empty"
            return
        }
        
        // Check for minimum length
        guard trimmedName.count >= 2 else {
            errorMessage = "Grocery name must be at least 2 characters long"
            return
        }
        
        // Check for maximum length
        guard trimmedName.count <= 50 else {
            errorMessage = "Grocery name is too long (max 50 characters)"
            return
        }
        
        // Check for valid characters (optional, but can prevent special inputs)
        let validNameRegex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9 '-]+$")
        guard let regex = validNameRegex,
              regex.firstMatch(in: trimmedName, range: NSRange(location: 0, length: trimmedName.utf16.count)) != nil else {
            errorMessage = "Invalid characters in grocery name"
            return
        }
        
        let newGrocery = GroceryItem(
            id: UUID().uuidString,
            name: trimmedName,
            category: category
        )
        
        groceryManager.addGroceryItem(newGrocery)
        
        // Clear error message and dismiss view
        errorMessage = nil
        presentationMode.wrappedValue.dismiss()
    }
}
