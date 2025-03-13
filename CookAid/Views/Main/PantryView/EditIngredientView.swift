import SwiftUI
import Firebase

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

                    Picker("Category", selection: $category) {
                        ForEach(["Proteins", "Dairy & Dairy Alternatives", "Grains and Legumes", "Fruits & Vegetables", "Spices, Seasonings and Herbs", "Sauces and Condiments", "Cooking Essentials", "Others"], id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.custom("Cochin", size: 18))

                    DatePicker("Date Bought (optional)", selection: Binding(
                        get: { dateBought ?? Date() },
                        set: { dateBought = $0 }
                    ), displayedComponents: .date)
                    .font(.custom("Cochin", size: 18))
                }

                HStack(spacing: 20) {
                    Spacer()
                    Button("Update") {
                        print("Update button pressed - starting update")
                        DispatchQueue.main.async {
                            updateIngredient()
                        }
                    }
                    .buttonStyle(PlainButtonStyle()) // Add this to prevent overlap
                    .font(.custom("Cochin", size: 18))
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("Delete") {
                        print("Delete button pressed - starting delete")
                        DispatchQueue.main.async {
                            deleteIngredient()
                        }
                    }
                    .buttonStyle(PlainButtonStyle()) // Add this to prevent overlap
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
        print("Updating ingredient: \(name) in category: \(category)")
        guard !name.isEmpty else {
            print("Cannot update: Name is empty")
            return
        }
        
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            let updatedIngredient = Ingredient(
                id: ingredient.id,
                name: name,
                dateBought: dateBought,
                category: category
            )
            
            ingredients[index] = updatedIngredient
            saveIngredientToFirestore(ingredient: updatedIngredient)
            
            print("Ingredient updated at index \(index)")
            presentationMode.wrappedValue.dismiss()
        } else {
            print("Ingredient not found for update.")
        }
    }

    private func deleteIngredient() {
        print("Deleting ingredient: \(name)")
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            let ingredientToDelete = ingredients[index]
            ingredients.remove(at: index)
            deleteIngredientFromFirestore(ingredient: ingredientToDelete)
            print("Ingredient deleted at index \(index)")
            presentationMode.wrappedValue.dismiss()
        } else {
            print("Ingredient not found for deletion.")
        }
    }

    private func saveIngredientToFirestore(ingredient: Ingredient) {
        let db = Firestore.firestore()
        do {
            let _ = try db.collection("users").document(Auth.auth().currentUser!.uid).collection("ingredients").document(ingredient.id).setData(from: ingredient)
            print("Ingredient updated successfully in Firestore!")
        } catch {
            print("Error updating ingredient in Firestore: \(error.localizedDescription)")
        }
    }

    private func deleteIngredientFromFirestore(ingredient: Ingredient) {
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("ingredients").document(ingredient.id).delete() { error in
            if let error = error {
                print("Error deleting ingredient from Firestore: \(error.localizedDescription)")
            } else {
                print("Ingredient deleted successfully from Firestore!")
            }
        }
    }
}
