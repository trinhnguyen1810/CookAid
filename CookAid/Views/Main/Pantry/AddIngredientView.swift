// CookAid/Views/Main/AddIngredientView.swift
import SwiftUI
import Firebase
import FirebaseFirestore

struct AddIngredientView: View {
    @Binding var ingredients: [Ingredient] // Binding to update the pantry
    @State private var name: String = ""
    @State private var showDuplicateAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var category: String = "Others"
    @State private var dateBought: Date? = Date()
    @State private var categories = ["Proteins", "Dairy & Dairy Alternatives", "Grains and Legumes", "Fruits & Vegetables", "Spices, Seasonings and Herbs", "Sauces and Condiments", "Cooking Essentials", "Others"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Ingredient")) {
                    TextField("Ingredient Name", text: $name)
                        .font(.custom("Cochin", size: 18))
                        .onChange(of: name) { newValue in
                            // Auto-categorize the ingredient as user types
                            if !newValue.isEmpty {
                                category = IngredientCategorizer.categorize(newValue)
                            }
                        }
                    
                    // Simple picker with pre-selected category
                    Picker("Category", selection: $category) {
                        ForEach(IngredientCategorizer.categories, id: \.self) { category in
                            Text(category)
                                .font(.custom("Cochin", size: 18))
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
        // Check if ingredient with same name already exists (case-insensitive comparison)
        let ingredientName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Don't add if name is empty
        guard !ingredientName.isEmpty else { return }
        
        // Check for duplicates (case-insensitive)
        if ingredients.contains(where: { $0.name.lowercased() == ingredientName.lowercased() }) {
            // Show alert for duplicate ingredient
            showDuplicateAlert = true
            return
        }
        
        let newIngredient = Ingredient(id: UUID().uuidString, name: ingredientName, dateBought: dateBought, category: category)
        ingredients.append(newIngredient)
        saveIngredientToFirestore(ingredient: newIngredient)
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
