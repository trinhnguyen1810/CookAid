import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var recipe: CollectionRecipe
    @State private var editableIngredients: [EditableRecipeIngredient] = []
    @State private var currentImage: UIImage?
    let collectionId: UUID
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteConfirmation = false
    
    // Image selection states
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingSourceTypeActionSheet = false
    @State private var imageChanged = false
    
    // Add notification trigger for parent view
    var onSave: (() -> Void)?
    
    init(recipe: CollectionRecipe, collectionId: UUID, onSave: (() -> Void)? = nil) {
        self._recipe = State(initialValue: recipe)
        self.collectionId = collectionId
        self.onSave = onSave
        self._editableIngredients = State(initialValue: recipe.ingredients.map { EditableRecipeIngredient(from: $0) })
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Title", text: $recipe.title)
                    
                    // Photo selection
                    VStack(alignment: .leading) {
                        Button(action: {
                            showingSourceTypeActionSheet = true
                        }) {
                            HStack {
                                Text("Change Photo")
                                Spacer()
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                } else if let currentImage = currentImage {
                                    Image(uiImage: currentImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                } else if recipe.image != nil {
                                    // Placeholder while loading
                                    Image(systemName: "photo")
                                        .font(.system(size: 30))
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.gray)
                                } else {
                                    Image(systemName: "photo")
                                        .font(.system(size: 30))
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    // Tags field
                    VStack(alignment: .leading) {
                        Text("Tags (comma separated)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        let tagsBinding = Binding<String>(
                            get: { recipe.tags.joined(separator: ", ") },
                            set: { newValue in
                                let components = newValue.components(separatedBy: ",")
                                recipe.tags = components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                    .filter { !$0.isEmpty }
                            }
                        )
                        
                        TextField("Tags", text: tagsBinding)
                    }
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(editableIngredients.indices, id: \.self) { index in
                        HStack {
                            TextField("Amount", value: $editableIngredients[index].amount, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .frame(width: 60)
                            
                            TextField("Unit", text: $editableIngredients[index].unit)
                                .frame(width: 80)
                            
                            TextField("Ingredient", text: $editableIngredients[index].name)
                        }
                    }
                    .onDelete { indexSet in
                        editableIngredients.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Ingredient") {
                        editableIngredients.append(EditableRecipeIngredient.empty())
                    }
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(recipe.instructions.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.gray)
                            
                            TextField("Step", text: $recipe.instructions[index])
                        }
                    }
                    .onDelete { indexSet in
                        recipe.instructions.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Step") {
                        recipe.instructions.append("")
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        saveRecipe()
                    }
                    
                    Button("Delete Recipe", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert("Delete Recipe", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteRecipe()
                }
            } message: {
                Text("Are you sure you want to delete this recipe from the collection? This cannot be undone.")
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: imagePickerSourceType)
                    .onDisappear {
                        if selectedImage != nil {
                            imageChanged = true
                        }
                    }
            }
            .actionSheet(isPresented: $showingSourceTypeActionSheet) {
                ActionSheet(
                    title: Text("Select Photo Source"),
                    buttons: [
                        .default(Text("Camera")) {
                            imagePickerSourceType = .camera
                            showingImagePicker = true
                        },
                        .default(Text("Photo Library")) {
                            imagePickerSourceType = .photoLibrary
                            showingImagePicker = true
                        },
                        .destructive(Text("Remove Photo")) {
                            selectedImage = nil
                            imageChanged = true
                        },
                        .cancel()
                    ]
                )
            }
            .onAppear {
                loadExistingImage()
            }
        }
    }
    
    private func saveRecipe() {
        // Update the recipe with edited ingredients
        var updatedRecipe = recipe
        updatedRecipe.ingredients = editableIngredients.map { $0.toRecipeIngredient() }
        
        // Handle image changes if any
        if imageChanged {
            if let selectedImage = selectedImage {
                // Save the new image
                if let imagePath = saveImage(selectedImage) {
                    updatedRecipe.image = imagePath
                }
            } else {
                // Remove the image if user chose to delete it
                updatedRecipe.image = nil
            }
        }
        
        // Direct collection update for immediate effect
        if let index = collectionsManager.collections.firstIndex(where: { $0.id == collectionId }),
           let recipeIndex = collectionsManager.collections[index].recipes.firstIndex(where: { $0.id == recipe.id }) {
            
            // Update recipe directly in the collection
            collectionsManager.collections[index].recipes[recipeIndex] = updatedRecipe
            
            // Save to persistence
            collectionsManager.saveCollections()
            
            // Force UI refresh with explicit notification
            DispatchQueue.main.async {
                // Notify observers
                collectionsManager.objectWillChange.send()
                
                // Call the onSave callback if provided
                onSave?()
                
                // Create a small delay before dismissing to allow UI to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            // Fallback to using the CollectionsManager method
            collectionsManager.updateRecipe(
                recipeId: recipe.id,
                collectionId: collectionId,
                updatedRecipe: updatedRecipe
            )
            
            // Call the onSave callback if provided
            onSave?()
            
            // Dismiss the view
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func deleteRecipe() {
        // Direct collection update for immediate effect
        if let index = collectionsManager.collections.firstIndex(where: { $0.id == collectionId }) {
            // Remove recipe directly from collection
            collectionsManager.collections[index].recipes.removeAll { $0.id == recipe.id }
            
            // Save to persistence
            collectionsManager.saveCollections()
            
            // Force UI refresh with explicit notification
            DispatchQueue.main.async {
                // Notify observers
                collectionsManager.objectWillChange.send()
                
                // Call the onSave callback if provided
                onSave?()
                
                // Create a small delay before dismissing to allow UI to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            // Fallback to using the CollectionsManager method
            collectionsManager.removeRecipeFromCollection(
                recipeId: recipe.id,
                collectionId: collectionId
            )
            
            // Call the onSave callback if provided
            onSave?()
            
            // Dismiss the view
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func loadExistingImage() {
        if let imagePath = recipe.image {
            // Check if the image path is a URL
            if imagePath.hasPrefix("http") || imagePath.hasPrefix("https") {
                // Load remote image (not implemented here)
            } else {
                // Load local image
                if let uiImage = UIImage(contentsOfFile: imagePath) {
                    currentImage = uiImage
                }
            }
        }
    }
    
    private func saveImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
