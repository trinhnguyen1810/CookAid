import SwiftUI

struct DietFilterView: View {
    @Binding var selectedDiets: [String]
    @Binding var selectedIntolerances: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    let diets = [
        "Gluten Free", "Ketogenic", "Vegetarian", "Lacto-Vegetarian", "Ovo-Vegetarian",
        "Vegan", "Pescetarian", "Paleo", "Primal", "Low FODMAP", "Whole30"
    ]
    
    let intolerances = [
        "Dairy", "Egg", "Gluten", "Grain", "Peanut", "Seafood",
        "Sesame", "Shellfish", "Soy", "Sulfite", "Tree Nut", "Wheat"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom segmented control
                HStack(spacing: 0) {
                    ForEach(["Diet", "Intolerance"], id: \.self) { tab in
                        Button(action: {
                            withAnimation {
                                selectedTab = tab == "Diet" ? 0 : 1
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(tab)
                                    .font(.custom("Cochin", size: 18))
                                    .fontWeight(selectedTab == (tab == "Diet" ? 0 : 1) ? .semibold : .regular)
                                    .foregroundColor(selectedTab == (tab == "Diet" ? 0 : 1) ? .black : .gray)
                                    .frame(maxWidth: .infinity)
                                
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(selectedTab == (tab == "Diet" ? 0 : 1) ? .black : .clear)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Diet tab
                    List {
                        ForEach(diets, id: \.self) { diet in
                            Button(action: {
                                if selectedDiets.contains(diet) {
                                    selectedDiets.removeAll { $0 == diet }
                                } else {
                                    selectedDiets.append(diet)
                                }
                            }) {
                                HStack {
                                    Text(diet)
                                        .font(.custom("Cochin", size: 17))
                                        .foregroundColor(.black)
                                    Spacer()
                                    if selectedDiets.contains(diet) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .tag(0)
                    
                    // Intolerances tab
                    List {
                        ForEach(intolerances, id: \.self) { intolerance in
                            Button(action: {
                                if selectedIntolerances.contains(intolerance) {
                                    selectedIntolerances.removeAll { $0 == intolerance }
                                } else {
                                    selectedIntolerances.append(intolerance)
                                }
                            }) {
                                HStack {
                                    Text(intolerance)
                                        .font(.custom("Cochin", size: 17))
                                        .foregroundColor(.black)
                                    Spacer()
                                    if selectedIntolerances.contains(intolerance) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Summary footer
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            if !selectedDiets.isEmpty {
                                Text("Diets: \(selectedDiets.count)")
                                    .font(.custom("Cochin", size: 16))
                                    .fontWeight(.medium)
                            }
                            
                            if !selectedIntolerances.isEmpty {
                                Text("Intolerances: \(selectedIntolerances.count)")
                                    .font(.custom("Cochin", size: 16))
                                    .fontWeight(.medium)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if selectedTab == 0 {
                                selectedDiets.removeAll()
                            } else {
                                selectedIntolerances.removeAll()
                            }
                        }) {
                            Text("Clear")
                                .font(.custom("Cochin", size: 16))
                                .foregroundColor(.red)
                        }
                        .opacity(selectedTab == 0 ? (selectedDiets.isEmpty ? 0.5 : 1) : (selectedIntolerances.isEmpty ? 0.5 : 1))
                        .disabled(selectedTab == 0 ? selectedDiets.isEmpty : selectedIntolerances.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Apply Filters")
                            .font(.custom("Cochin", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .opacity((selectedDiets.isEmpty && selectedIntolerances.isEmpty) ? 0.6 : 1)
                }
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
            }
            .navigationTitle("Dietary Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("Cochin", size: 17))
                }
            }
        }
    }
}

struct DietFilterView_Previews: PreviewProvider {
    static var previews: some View {
        DietFilterView(
            selectedDiets: .constant(["Vegetarian", "Gluten Free"]),
            selectedIntolerances: .constant(["Dairy"])
        )
    }
}
