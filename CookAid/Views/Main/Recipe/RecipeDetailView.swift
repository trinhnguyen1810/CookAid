import SwiftUI

struct RecipeDetailView: View {
   var recipeId: Int
   @State private var recipeDetail: RecipeDetail?
   @State private var errorMessage: String?
   @State private var isLoading = false
   
   private func formatNumber(_ number: Double) -> String {
       return number.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", number) : String(format: "%.2f", number)
   }
   
   var body: some View {
       ScrollView {
           VStack(alignment: .leading, spacing: 16) {
               if isLoading {
                   ProgressView()
                       .frame(maxWidth: .infinity, maxHeight: .infinity)
                       .padding(.top, 100)
               } else if let recipe = recipeDetail {
                   // Title
                   Text(recipe.title)
                       .font(.custom("Cochin", size: 22))
                       .fontWeight(.bold)
                       .frame(maxWidth: .infinity, alignment: .leading)
                       .padding(.horizontal)
                   
                   // Image
                   AsyncImage(url: URL(string: recipe.image)) { image in
                       image
                           .resizable()
                           .scaledToFit()
                           .frame(maxWidth: .infinity)
                           .cornerRadius(12)
                           .shadow(radius: 4)
                   } placeholder: {
                       ProgressView()
                   }
                   .padding(.horizontal)
                   
                   // Tags
                   ScrollView(.horizontal, showsIndicators: false) {
                       HStack(spacing: 8) {
                           if recipe.vegetarian {
                               TagView(tag: "Vegetarian")
                           }
                           if recipe.vegan {
                               TagView(tag: "Vegan")
                           }
                           if recipe.glutenFree {
                               TagView(tag: "Gluten Free")
                           }
                           if recipe.dairyFree {
                               TagView(tag: "Dairy Free")
                           }
                       }
                       .padding(.horizontal)
                   }
                   
                   // Ingredients Section
                   VStack(alignment: .leading, spacing: 8) {
                       Text("Ingredients")
                           .font(.custom("Cochin", size: 20))
                           .fontWeight(.bold)
                       
                       ForEach(recipe.extendedIngredients, id: \.id) { ingredient in
                           Text("\(formatNumber(ingredient.amount)) \(ingredient.unit) \(ingredient.name)")
                               .font(.custom("Cochin", size: 16))
                       }
                   }
                   .padding(.horizontal)
                   
                   // Instructions Section using analyzedInstructions
                   VStack(alignment: .leading, spacing: 8) {
                       Text("Instructions")
                           .font(.custom("Cochin", size: 20))
                           .fontWeight(.bold)
                       
                       if let instructions = recipe.analyzedInstructions.first?.steps {
                           ForEach(instructions, id: \.number) { step in
                               Text("\(step.number). \(step.step)")
                                   .font(.custom("Cochin", size: 16))
                                   .padding(.bottom, 4)
                           }
                       } else {
                           Text("No instructions available.")
                               .font(.custom("Cochin", size: 16))
                       }
                   }
                   .padding(.horizontal)
                   
               } else if let errorMessage = errorMessage {
                   Text(errorMessage)
                       .foregroundColor(.red)
                       .padding()
               }
           }
           .padding(.vertical)
       }
       .navigationTitle("Recipe Details")
       .onAppear {
           fetchRecipeDetails()
       }
   }
   
   private func fetchRecipeDetails() {
       // Reset state
       isLoading = true
       errorMessage = nil
       recipeDetail = nil
       
       // Get API headers from the APIConfig service
       let headers = APIConfig.shared.headers(for: .spoonacular)
       
       // Build the URL
       guard let url = URL(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/\(recipeId)/information") else {
           errorMessage = "Invalid URL"
           isLoading = false
           return
       }
       
       // Build the request
       var request = URLRequest(url: url)
       request.httpMethod = "GET"
       request.allHTTPHeaderFields = headers
       
       // Log request for debugging
       print("Fetching recipe details for ID: \(recipeId)")
       
       // Execute the request
       URLSession.shared.dataTask(with: request) { data, response, error in
           // Handle network error
           if let error = error {
               DispatchQueue.main.async {
                   isLoading = false
                   errorMessage = "Error fetching recipe details: \(error.localizedDescription)"
                   print("Network error: \(error)")
               }
               return
           }
           
           // Check HTTP status code
           if let httpResponse = response as? HTTPURLResponse {
               print("HTTP Response Status Code: \(httpResponse.statusCode)")
               
               // Handle non-200 responses
               if httpResponse.statusCode != 200 {
                   DispatchQueue.main.async {
                       isLoading = false
                       errorMessage = "Server error: HTTP \(httpResponse.statusCode)"
                   }
                   return
               }
           }
           
           // Check if we received data
           guard let data = data else {
               DispatchQueue.main.async {
                   isLoading = false
                   errorMessage = "No data received from server"
               }
               return
           }
           
           // Debug: Print raw response (only in development builds)
           #if DEBUG
           if let rawString = String(data: data, encoding: .utf8) {
               print("Raw data (first 500 chars): \(String(rawString.prefix(500)))...")
           }
           #endif
           
           // Try to decode the response
           do {
               let decoder = JSONDecoder()
               let recipeDetail = try decoder.decode(RecipeDetail.self, from: data)
               
               DispatchQueue.main.async {
                   isLoading = false
                   self.recipeDetail = recipeDetail
                   self.errorMessage = nil
               }
           } catch {
               print("Decoding error: \(error)")
               
               DispatchQueue.main.async {
                   isLoading = false
                   errorMessage = "Error decoding recipe details: \(error.localizedDescription)"
               }
           }
       }.resume()
   }
   
   struct TagView: View {
       var tag: String
       
       var body: some View {
           Text(tag)
               .font(.custom("Cochin", size: 14))
               .padding(.horizontal, 12)
               .padding(.vertical, 6)
               .background(Color.gray.opacity(0.2))
               .cornerRadius(8)
       }
   }
}
