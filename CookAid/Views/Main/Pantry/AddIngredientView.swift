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
    
    // Emoji mapping for categories
    private func categoryEmoji(for category: String) -> String {
        switch category {
        case "Proteins": return "🥩 Proteins"
        case "Dairy & Dairy Alternatives": return "🥛 Dairy & Dairy Alternatives"
        case "Grains and Legumes": return "🌾 Grains and Legumes"
        case "Fruits & Vegetables": return "🍎 Fruits & Vegetables"
        case "Spices, Seasonings and Herbs": return "🌿 Spices, Seasonings and Herbs"
        case "Sauces and Condiments": return "🥫 Sauces and Condiments"
        case "Cooking Essentials": return "🧂 Cooking Essentials"
        default: return "📦 Others"
        }
    }

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
                    
                    // Picker with emojis
                    Picker("Category", selection: $category) {
                        ForEach(IngredientCategorizer.categories, id: \.self) { category in
                            HStack {
                                Text(categoryEmoji(for: category))
                            }
                            .tag(category)
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
            .alert(isPresented: $showDuplicateAlert) {
                Alert(
                    title: Text("Duplicate Ingredient"),
                    message: Text("An ingredient with this name already exists in your pantry."),
                    dismissButton: .default(Text("OK"))
                )
            }
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
