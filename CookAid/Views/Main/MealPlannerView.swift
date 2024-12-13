//
//  MealPlannerView.swift
//  CookAid
//
//  Created by Vivian Nguyen on 12/11/24.
//

import Foundation
import SwiftUI

struct MealPlannerView: View {
    @State private var currentWeekOffset = 0
    let mealTypes = ["Breakfast", "Lunch", "Dinner"]
    
    var body: some View {
        NavigationStack {
            ZStack {  // Add ZStack to layer BottomTabBar over content
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Meal Planner")
                        .font(.custom("Cochin", size: 22))
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.leading, 20)
                    
                    // Week Navigation
                    HStack {
                        Button(action: { currentWeekOffset -= 1 }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text(weekDateRange)
                            .font(.custom("Cochin", size: 18))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: { currentWeekOffset += 1 }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Weekly Plan
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(daysOfWeek, id: \.self) { day in
                                DayPlanView(day: day)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80) // Add padding to prevent content from being hidden behind BottomTabBar
                    }
                }
                .background(Color.white)
                
                // Add BottomTabBar
                VStack {
                    Spacer()
                    BottomTabBar()
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

struct DayPlanView: View {
    let day: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Day header
            Text(dayFormatter.string(from: day))
                .font(.custom("Cochin", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            // Meal sections
            ForEach(["Breakfast", "Lunch", "Dinner"], id: \.self) { mealType in
                VStack(alignment: .leading, spacing: 5) {
                    Text(mealType)
                        .font(.custom("Cochin", size: 18))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        // Add meal action
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add \(mealType)")
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
                }
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

