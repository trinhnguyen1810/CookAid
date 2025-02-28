import SwiftUI
import Foundation



struct CollectionListView: View {
    var collections: [RecipeCollection]
    var onDelete: (RecipeCollection) -> Void
    
    var body: some View {
        List {
            ForEach(collections) { collection in
                NavigationLink(destination: CollectionDetailView(collection: collection)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(collection.name)
                            .font(.custom("Cochin", size: 20))
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("\(collection.recipes.count) Recipes")
                                .font(.custom("Cochin", size: 16))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatDate(collection.dateCreated))
                                .font(.custom("Cochin", size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        onDelete(collection)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
