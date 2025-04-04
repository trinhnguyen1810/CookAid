import Foundation
import SwiftUI

// Simple loading state enum
enum LoadingState {
    case idle
    case loading
    case error(String)
    case success
}

// Protocol for error handling
protocol NetworkErrorHandler {
    func handleNetworkError(_ error: Error) -> String
    func handleHTTPError(_ statusCode: Int) -> String
}

// Default implementation of error handling
extension NetworkErrorHandler {
    func handleNetworkError(_ error: Error) -> String {
        let nsError = error as NSError
        
        // Handle only the most common error cases
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet:
                return "No internet connection"
            case NSURLErrorTimedOut:
                return "Request timed out"
            default:
                return "Network error"
            }
        }
        
        return "Something went wrong"
    }
    
    func handleHTTPError(_ statusCode: Int) -> String {
        switch statusCode {
        case 401:
            return "API key error"
        case 404:
            return "Recipe not found"
        case 400...499:
            return "Request error"
        case 500...599:
            return "Server error"
        default:
            return "Unknown error"
        }
    }
}

// Simple loading indicator view
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading...")
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.gray)
        }
        .frame(width: 120, height: 120)
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// Simple error message view
struct ErrorMessageView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text(message)
                .font(.custom("Cochin", size: 18))
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                retryAction()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// Empty state view for when no recipes are found
struct NoRecipesView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "fork.knife")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No recipes found")
                .font(.custom("Cochin", size: 20))
                .fontWeight(.bold)
            
            Text(message)
                .font(.custom("Cochin", size: 16))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
