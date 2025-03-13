import SwiftUI

struct FilterChip: View {
    let label: String
    let type: FilterType
    let onRemove: () -> Void
    
    enum FilterType {
        case diet, intolerance
        
        var color: Color {
            switch self {
            case .diet:
                return Color.blue
            case .intolerance:
                return Color.orange
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.custom("Cochin", size: 14))
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(type.color.opacity(0.8))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(type.color.opacity(0.2))
        .foregroundColor(type.color)
        .cornerRadius(8)
    }
}

struct FilterChipsView: View {
    let diets: [String]
    let intolerances: [String]
    let onRemoveDiet: (String) -> Void
    let onRemoveIntolerance: (String) -> Void
    let onClearAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Active filters:")
                    .font(.custom("Cochin", size: 15))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if !diets.isEmpty || !intolerances.isEmpty {
                    Button("Clear All") {
                        onClearAll()
                    }
                    .font(.custom("Cochin", size: 14))
                    .foregroundColor(.red)
                }
            }
            
            if !diets.isEmpty || !intolerances.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(diets, id: \.self) { diet in
                            FilterChip(label: diet, type: .diet) {
                                onRemoveDiet(diet)
                            }
                        }
                        
                        ForEach(intolerances, id: \.self) { intolerance in
                            FilterChip(label: intolerance, type: .intolerance) {
                                onRemoveIntolerance(intolerance)
                            }
                        }
                        
                        Spacer() // Push all chips to the left
                    }
                    .padding(.horizontal, 0) // Remove horizontal padding inside scroll view
                }
            } else {
                Text("No active filters")
                    .font(.custom("Cochin", size: 14))
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding(.horizontal, 20) // Change to specific horizontal padding
        .padding(.leading, 5) // Add extra leading padding to align with other elements
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct FilterButtonsView: View {
    @Binding var showDietFilter: Bool
    let dietCount: Int
    let intoleranceCount: Int
    
    var body: some View {
        HStack(spacing: 10) {
            // Main filters button - fixed size whether selected or not
            Button(action: {
                showDietFilter.toggle()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 12))
                    Text("Filters")
                        .font(.custom("Cochin", size: 14))
                    
                    // Badge for count
                    if dietCount + intoleranceCount > 0 {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 18, height: 18)
                            
                            Text("\(dietCount + intoleranceCount)")
                                .font(.custom("Cochin", size: 11))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .frame(height: 30) // Fixed height to maintain consistency
                .background(Color.white)
                .foregroundColor(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .cornerRadius(20)
            }
            
            // Diet filter count chip
            if dietCount > 0 {
                HStack(spacing: 4) {
                    Text("Diets")
                        .font(.custom("Cochin", size: 14))
                    
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 18, height: 18)
                        
                        Text("\(dietCount)")
                            .font(.custom("Cochin", size: 11))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(height: 30) // Fixed height to match main button
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(20)
            }
            
            // Intolerance filter count chip
            if intoleranceCount > 0 {
                HStack(spacing: 4) {
                    Text("Intolerances")
                        .font(.custom("Cochin", size: 14))
                    
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 18, height: 18)
                        
                        Text("\(intoleranceCount)")
                            .font(.custom("Cochin", size: 11))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(height: 30) // Fixed height to match main button
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(20)
            }
            
            Spacer() // Push everything to the left
        }
        .padding(.horizontal, 20)
    }
}


struct FilterCountChip: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.custom("Cochin", size: 14))
            Text("\(count)")
                .font(.custom("Cochin", size: 14))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}

struct FilterComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            FilterChip(label: "Vegetarian", type: .diet) {}
            FilterChip(label: "Dairy", type: .intolerance) {}
            
            FilterChipsView(
                diets: ["Vegetarian", "Gluten Free"],
                intolerances: ["Dairy", "Soy"],
                onRemoveDiet: { _ in },
                onRemoveIntolerance: { _ in },
                onClearAll: {}
            )
            
            FilterButtonsView(
                showDietFilter: .constant(false),
                dietCount: 2,
                intoleranceCount: 1
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
