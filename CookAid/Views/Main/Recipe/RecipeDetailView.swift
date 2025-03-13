import SwiftUI

struct RecipeDetailView: View {
   var recipeId: Int
   @State private var recipeDetail: RecipeDetail?
   @State private var errorMessage: String?
   
   private func formatNumber(_ number: Double) -> String {
       return number.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", number) : String(format: "%.2f", number)
   }
   
   var body: some View {
       ScrollView {
           VStack(alignment: .leading, spacing: 16) {
               if let recipe = recipeDetail {
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
               } else {
                   ProgressView()
               }
           }
           .padding(.vertical)
       }
       .navigationTitle("Recipe Details")
       .onAppear {
           fetchRecipeDetails()
       }
   }
   
   private func cleanHTML(_ input: String) -> String {
       var output = input.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
       output = output.replacingOccurrences(of: "&quot;", with: "\"")
       output = output.replacingOccurrences(of: "&amp;", with: "&")
       output = output.replacingOccurrences(of: "&lt;", with: "<")
       output = output.replacingOccurrences(of: "&gt;", with: ">")
       output = output.replacingOccurrences(of: "\\n", with: "\n")
       return output
   }
   
   private func fetchRecipeDetails() {
       let apiKey = "f1c8e26a6f554159ab2714022bbee9c7"
       let urlString = "https://api.spoonacular.com/recipes/\(recipeId)/information?apiKey=\(apiKey)"
       
       guard let url = URL(string: urlString) else {
           errorMessage = "Invalid URL"
           return
       }
       
       let config = URLSessionConfiguration.default
       config.timeoutIntervalForRequest = 30 // Set timeout to 30 seconds
       let session = URLSession(configuration: config)
       
       session.dataTask(with: url) { data, response, error in
           if let error = error {
               DispatchQueue.main.async {
                   errorMessage = "Error fetching recipe details: \(error.localizedDescription)"
               }
               return
           }
           
           if let httpResponse = response as? HTTPURLResponse {
               print("HTTP Response Status Code: \(httpResponse.statusCode)")
               if httpResponse.statusCode != 200 {
                   DispatchQueue.main.async {
                       errorMessage = "Error: Received HTTP \(httpResponse.statusCode)"
                   }
                   return
               }
           }
           
           guard let data = data else {
               DispatchQueue.main.async {
                   errorMessage = "No data received"
               }
               return
           }
           
           if let rawString = String(data: data, encoding: .utf8) {
               print("Raw data: \(rawString)")
           }
           
           do {
               let decoder = JSONDecoder()
               let recipeDetail = try decoder.decode(RecipeDetail.self, from: data)
               DispatchQueue.main.async {
                   self.recipeDetail = recipeDetail
                   self.errorMessage = nil
               }
           } catch {
               print("Decoding error: \(error)")
               DispatchQueue.main.async {
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
