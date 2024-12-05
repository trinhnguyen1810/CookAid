// CookAid/Views/Main/AddIngredientView.swift
import SwiftUI
import Firebase
import FirebaseFirestore

struct AddIngredientView: View {
    @Binding var ingredients: [Ingredient] // Binding to update the pantry
    @State private var name: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var category: String = ""
    @State private var dateBought: String = "" // Keep as String
    @State private var categories = ["Proteins", "Dairy & Dairy Alternatives", "Grains and Legumes", "Fruits & Vegetables", "Spices, Seasonings and Herbs", "Sauces and Condiments", "Cooking Essentials", "Others"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Ingredient")) {
                    TextField("Ingredient Name", text: $name)
                        .font(.custom("Cochin", size: 18))

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    TextField("Date Bought (optional)", text: $dateBought)
                        .font(.custom("Cochin", size: 18))
                }

                Button("Add Ingredient") {
                    addIngredient()
                }
                .font(.custom("Cochin", size: 18))
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func addIngredient() {
        // Set dateBought to nil if the input is empty
        let newIngredient = Ingredient(id: UUID().uuidString, name: name, dateBought: dateBought.isEmpty ? nil : dateBought, category: category)
        ingredients.append(newIngredient) // Update local state
        saveIngredientToFirestore(ingredient: newIngredient) // Save to Firestore
    }

    private func saveIngredientToFirestore(ingredient: Ingredient) {
        let db = Firestore.firestore()
        do {
            let _ = try db.collection("users").document(Auth.auth().currentUser!.uid).collection("ingredients").document(ingredient.id).setData(from: ingredient)
            print("Ingredient added successfully!")
            presentationMode.wrappedValue.dismiss() // Dismiss the view after adding
        } catch {
            print("Error adding ingredient: \(error.localizedDescription)")
        }
    }
}
