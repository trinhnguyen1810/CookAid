import SwiftUI

public struct TabBarButton<Destination: View>: View {
    var imageName: String
    var label: String
    var destination: () -> Destination // Closure that returns Destination
    
    public var body: some View {
        NavigationLink(destination: destination()) { // Call the closure to get the view
            VStack {
                Image(systemName: imageName)
                    .foregroundColor(.black)
                Text(label)
                    .font(.custom("Cochin", size: 14))
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(PlainButtonStyle()) // Prevent default button style
    }
}

