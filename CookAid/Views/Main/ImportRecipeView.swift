import SwiftUI
import Foundation

struct ImportRecipeView: View {
    // State variables for managing import process
    @State private var recipeURL = ""
    @State private var isImporting = false
    @State private var importedRecipe: ImportedRecipeDetail?
    @State private var errorMessage: String?
    @State private var showingCollectionSelection = false
    
    // Managers for recipe import and collection management
    @StateObject private var recipeImportManager = RecipeImportManager()
    @StateObject private var collectionsManager = CollectionsManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // URL Input Section
                urlInputSection
                
                // Import Button
                importButton
                
                // Loading and Error States
                loadingAndErrorSection
                
                // Imported Recipe Preview
                importedRecipePreview
            }
            .navigationTitle("Import Recipe")
            .padding()
            .sheet(isPresented: $showingCollectionSelection) {
                collectionSelectionSheet
            }
        }
    }
    
    // URL Input Section
    private var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Import Recipe from Web")
                .font(.custom("Cochin", size: 22))
                .fontWeight(.bold)
            
            Text("Paste a recipe URL from a supported website")
                .font(.custom("Cochin", size: 16))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.gray)
                
                TextField("Enter recipe URL", text: $recipeURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
    }
    
    // Import Button
    private var importButton: some View {
        Button(action: importRecipe) {
            Text("Import Recipe")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(recipeURL.isEmpty || isImporting)
    }
    
    // Loading and Error Section
    private var loadingAndErrorSection: some View {
        Group {
            if isImporting {
                ProgressView()
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    // Imported Recipe Preview
    private var importedRecipePreview: some View {
        Group {
            if let recipe = importedRecipe {
                ScrollView {
                    ImportedRecipePreviewView(
                        recipe: recipe,
                        onAddToCollection: {
                            showingCollectionSelection = true
                        }
                    )
                }
            }
        }
    }
    
    // Collection Selection Sheet
    private var collectionSelectionSheet: some View {
        Group {
            if let recipe = importedRecipe {
                ImportToCollectionView(
                    recipe: recipe,
                    collectionsManager: collectionsManager
                )
            }
        }
    }
    
    // Import Recipe Function
    private func importRecipe() {
        // Reset previous state
        isImporting = true
        errorMessage = nil
        importedRecipe = nil
        
        // Perform import
        recipeImportManager.extractRecipeFromURL(urlString: recipeURL) { result in
            DispatchQueue.main.async {
                isImporting = false
                
                switch result {
                case .success(let recipe):
                    importedRecipe = recipe
                case .failure(let error):
                    errorMessage = handleImportError(error)
                }
            }
        }
    }
    
    // Error Handling Function
    private func handleImportError(_ error: Error) -> String {
        switch error {
        case let nsError as NSError where nsError.domain == NSURLErrorDomain:
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet:
                return "No internet connection. Please check your network."
            case NSURLErrorTimedOut:
                return "Connection timed out. Please try again."
            default:
                return "Network error. Please try again."
            }
        default:
            return error.localizedDescription
        }
    }
}

// Preview for Import Recipe View
struct ImportRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        ImportRecipeView()
    }
}
