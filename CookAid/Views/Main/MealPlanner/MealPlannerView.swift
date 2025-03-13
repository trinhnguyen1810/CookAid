import SwiftUI

struct MealPlannerView: View {
    @State private var currentWeekOffset = 0
    @EnvironmentObject var mealPlanManager: MealPlanManager
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var showingRecipeSelection = false
    @State private var selectedDate: Date?
    @State private var selectedMealType: MealType?
    @State private var draggedItem: MealItem?
    
    var body: some View {
        NavigationStack {
            ZStack {  // ZStack to layer BottomTabBar over content
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Meal Planner")
                        .font(.custom("Cochin", size: 22))
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.leading, 20)
                    
                    // Week Navigation
                    HStack {
                        Button {
                            currentWeekOffset -= 1
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text(weekDateRange)
                            .font(.custom("Cochin", size: 18))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button {
                            currentWeekOffset += 1
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Weekly Plan
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(daysOfWeek, id: \.self) { day in
                                DayPlanView(
                                    day: day,
                                    mealPlanManager: mealPlanManager,
                                    onAddMeal: { date, mealType in
                                        print("MealPlannerView: Add meal callback received for \(mealType.rawValue) on \(date)")
                                        selectedDate = date
                                        selectedMealType = mealType
                                        showingRecipeSelection = true
                                    },
                                    draggedItem: $draggedItem
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80) // Prevent content being hidden behind BottomTabBar
                    }
                    
                    // Debug button to test sheet presentation
                    Button {
                        selectedDate = Date()
                        selectedMealType = .breakfast
                        showingRecipeSelection = true
                        print("Debug button pressed, showingRecipeSelection: \(showingRecipeSelection)")
                    } label: {
                        Text("Test Sheet Presentation")
                            .font(.custom("Cochin", size: 16))
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color.white)
                
                // Add BottomTabBar
                VStack {
                    Spacer()
                    BottomTabBar()
                }
            }
            .onChange(of: showingRecipeSelection) { newValue in
                print("showingRecipeSelection changed to: \(newValue)")
                if newValue {
                    print("Selected date: \(String(describing: selectedDate))")
                    print("Selected meal type: \(String(describing: selectedMealType?.rawValue))")
                }
            }
            .sheet(isPresented: $showingRecipeSelection) {
                if let date = selectedDate, let mealType = selectedMealType {
                    RecipeSelectionView(date: date, mealType: mealType)
                        .environmentObject(collectionsManager)
                        .environmentObject(mealPlanManager)
                } else {
                    // Fallback view in case date or mealType is nil
                    Text("Please select a meal time")
                        .font(.custom("Cochin", size: 18))
                }
            }
        }
    }
    
    var weekDateRange: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let weekStart = calendar.date(byAdding: .day, value: currentWeekOffset * 7, to: today),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        return "\(dateFormatter.string(from: weekStart)) - \(dateFormatter.string(from: weekEnd))"
    }
    
    var daysOfWeek: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let weekStart = calendar.date(byAdding: .day, value: currentWeekOffset * 7, to: today) else {
            return []
        }
        
        return (0...6).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: weekStart)
        }
    }
}
