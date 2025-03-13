import SwiftUI

struct DayPlanView: View {
    let day: Date
    @ObservedObject var mealPlanManager: MealPlanManager
    var onAddMeal: (Date, MealType) -> Void
    @Binding var draggedItem: MealItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Day header
            Text(dayFormatter.string(from: day))
                .font(.custom("Cochin", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            // Meal sections
            ForEach(MealType.allCases, id: \.self) { mealType in
                MealSectionView(
                    day: day,
                    mealType: mealType,
                    mealPlanManager: mealPlanManager,
                    onAddMeal: onAddMeal,
                    draggedItem: $draggedItem
                )
            }
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
}

// Separate view for each meal section
struct MealSectionView: View {
    let day: Date
    let mealType: MealType
    @ObservedObject var mealPlanManager: MealPlanManager
    var onAddMeal: (Date, MealType) -> Void
    @Binding var draggedItem: MealItem?
    @State private var isTargeted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(mealType.rawValue)
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.gray)
            
            if mealPlanManager.getMeals(for: day, mealType: mealType).isEmpty {
                emptyMealView
            } else {
                populatedMealView
            }
        }
    }
    
    // View for empty meal slot
    private var emptyMealView: some View {
        Button {
            print("Add \(mealType.rawValue) button tapped for \(day)")
            onAddMeal(day, mealType)
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                Text("Add \(mealType.rawValue)")
            }
            .font(.custom("Cochin", size: 18))
            .foregroundColor(.black)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
    
    // View for populated meal slot
    private var populatedMealView: some View {
        VStack(spacing: 8) {
            ForEach(mealPlanManager.getMeals(for: day, mealType: mealType)) { meal in
                MealItemView(meal: meal, date: day, mealType: mealType)
                    .onDrag {
                        self.draggedItem = meal
                        return NSItemProvider(object: meal.id.uuidString as NSString)
                    }
            }
            
            // Add more button
            Button {
                print("Add More button tapped for \(mealType.rawValue) on \(day)")
                onAddMeal(day, mealType)
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add More")
                }
                .font(.custom("Cochin", size: 16))
                .foregroundColor(.gray)
                .padding(8)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
        }
        .padding(8)
        .background(isTargeted ? Color.blue.opacity(0.1) : Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        // Handle drop
        .onDrop(of: [.text], isTargeted: $isTargeted) { providers, _ in
            handleDrop()
        }
    }
    
    // Handle drop operation
    private func handleDrop() -> Bool {
        guard let draggedItem = self.draggedItem else { return false }
        
        // Find the source of the dragged item
        var foundSourceDate: Date?
        var foundMealType: MealType?
        
        outerLoop: for date in mealPlanManager.mealPlans.keys {
            for type in MealType.allCases {
                if mealPlanManager.getMeals(for: date, mealType: type).contains(where: { $0.id == draggedItem.id }) {
                    foundSourceDate = date
                    foundMealType = type
                    break outerLoop
                }
            }
        }
        
        if let sourceDate = foundSourceDate, let sourceMealType = foundMealType {
            mealPlanManager.moveRecipe(
                item: draggedItem,
                fromDate: sourceDate,
                fromMealType: sourceMealType,
                toDate: day,
                toMealType: mealType
            )
            
            self.draggedItem = nil
            return true
        }
        
        return false
    }
}
