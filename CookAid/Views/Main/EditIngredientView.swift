import SwiftUI

struct EditIngredientView: View {
    @Binding var ingredients: [Ingredient]
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String
    @State private var category: String
    @State private var dateBought: Date?
    
    // The ingredient being edited
    var ingredient: Ingredient

    init(ingredients: Binding<[Ingredient]>, ingredient: Ingredient) {
        self._ingredients = ingredients
        self.ingredient = ingredient
        self._name = State(initialValue: ingredient.name)
        self._category = State(initialValue: ingredient.category)
        self._dateBought = State(initialValue: ingredient.dateBought)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Ingredient")) {
                    TextField("Ingredient Name", text: $name)
                        .font(.custom("Cochin", size: 18))

                    Picker("Category", selection: $category) { // Removed the extra comma here
                        ForEach(["Proteins", "Dairy & Dairy Alternatives", "Grains and Legumes", "Fruits & Vegetables", "Spices, Seasonings and Herbs", "Sauces and Condiments", "Cooking Essentials", "Others"], id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.custom("Cochin", size: 18)) // Set font for the Picker

                    DatePicker("Date Bought (optional)", selection: Binding(
                        get: { dateBought ?? Date() },
                        set: { dateBought = $0 }
                    ), displayedComponents: .date)
                    .font(.custom("Cochin", size: 18))
                }

                HStack {
                    Spacer()
                    Button("Edit") {
                        updateIngredient()
                    }
                    .font(.custom("Cochin", size: 18))
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("Delete") {
                        deleteIngredient()
                    }
                    .font(.custom("Cochin", size: 18))
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Ingredient")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func updateIngredient() {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            // Update the ingredient
            ingredients[index] = Ingredient(id: ingredient.id, name: name, dateBought: dateBought, category: category)
            presentationMode.wrappedValue.dismiss() // Dismiss the view after updating
        }
    }

    private func deleteIngredient() {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients.remove(at: index) // Remove from local array
            presentationMode.wrappedValue.dismiss() // Dismiss the view after deleting
        }
    }
}
