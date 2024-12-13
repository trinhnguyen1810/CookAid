//
//  RecipeCard.swift
//  CookAid
//
//  Created by Vivian Nguyen on 12/11/24.
//

import Foundation
import SwiftUI

struct RecipeCard: View {
    var recipe: String
    var image: String
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: image)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .cornerRadius(8)
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            Text(recipe)
                .font(.custom("Cochin", size: 18))
                .fontWeight(.medium)
                .foregroundColor(.black)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .frame(height: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Spacer()
                Button(action: {
                    // Handle 3 dots actions (add/delete/save)
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
    }
}
