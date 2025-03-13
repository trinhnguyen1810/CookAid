# CookAid

CookAid is a comprehensive iOS application designed to simplify meal planning and recipe management. The app helps users discover recipes based on ingredients they have on hand, create shopping lists, organize recipes in collections, and plan meals for the week.

## Features

### User Authentication
- User registration and login using Firebase Authentication
- Profile management with customizable profile pictures

### Pantry Management
- Add, edit, and delete ingredients in your pantry
- Categorize ingredients for easy organization
- Search functionality for finding specific items
- Date tracking for ingredient freshness

### Recipe Discovery
- Find recipes based on ingredients in your pantry
- Search for recipes by name, ingredients, or preferences
- Filter recipes by dietary restrictions (vegetarian, vegan, gluten-free, etc.)
- Quick meal suggestions for fast, easy cooking options

### Recipe Collections
- Create custom collections to organize recipes
- Add recipes from search results to your collections
- Import recipes from web URLs
- Create your own custom recipes
- View detailed recipe information including ingredients, instructions, and nutritional info

### Meal Planning
- Plan meals for the week with a visual calendar interface
- Drag and drop recipes between days and meal types
- Easily add recipes from your collections to your meal plan
- Organize meals by breakfast, lunch, dinner, and snacks

### Grocery List
- Create shopping lists for needed ingredients
- Categorize grocery items for efficient shopping
- Add missing ingredients directly from recipes
- Mark items as purchased
- Add grocery items to your pantry once purchased

## Technologies Used

- **SwiftUI**: Modern UI framework for building the application interface
- **Firebase Authentication**: For user authentication and account management
- **Firestore Database**: For storing user data, ingredients, and shopping lists
- **Firebase Storage**: For storing user profile images
- **Spoonacular API**: For recipe search and information
- **Combine Framework**: For reactive programming patterns
- **Swift's Codable Protocol**: For data encoding and decoding

## Project Structure

The project follows the MVVM (Model-View-ViewModel) architecture:

- **Models**: Data structures that represent the core components (users, ingredients, recipes, etc.)
- **Views**: UI components organized by feature
- **ViewModels**: Business logic that connects the models to the views
- **Services**: API clients and data managers

## Setup Instructions

### Prerequisites
- Xcode 14.0 or later
- iOS 16.0+ target
- Swift 5.7+
- CocoaPods (for managing dependencies)

### Installation

1. Clone the repository:
```
git clone https://github.com/your-username/CookAid.git
```

2. Navigate to the project directory:
```
cd CookAid
```

3. Install dependencies:
```
pod install
```

4. Open the workspace:
```
open CookAid.xcworkspace
```

5. Configure Firebase:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add an iOS app to your Firebase project
   - Download the `GoogleService-Info.plist` file
   - Add the file to your Xcode project

6. Configure Spoonacular API:
   - Sign up for a Spoonacular API key at [Spoonacular](https://spoonacular.com/food-api)
   - Replace the API key in `RecipeAPIManager.swift` with your own key

7. Build and run the application in Xcode.

## Usage

1. **First Launch**: Create an account or login with existing credentials
2. **Pantry Setup**: Add ingredients you have available
3. **Recipe Discovery**: Search for recipes based on your pantry items
4. **Collections**: Organize favorite recipes into collections
5. **Meal Planning**: Plan your weekly meals using your saved recipes
6. **Grocery List**: Create shopping lists based on recipes or manual entry
