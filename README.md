# CookAid: iOS Recipe Management App

## Project Overview
CookAid is a comprehensive iOS application developed to address the challenges college students face with meal planning and food waste. The app provides an intuitive solution by recommending recipes based on ingredients already in your pantry, helping users discover new meal ideas while reducing food waste.

The app integrates several key features: smart pantry management to track available ingredients, personalized recipe discovery with dietary filters, customizable recipe collections, an intuitive meal planner, and an intelligent grocery list system. These features work together seamlessly to help users manage their entire cooking workflow from ingredient storage to meal preparation.

Built with SwiftUI and Firebase, CookAid delivers a modern, responsive experience with real-time data synchronization. The application employs intelligent categorization systems and filters to accommodate various dietary preferences and restrictions, making it accessible to diverse users like busy students, eco-conscious individuals, and fitness enthusiasts.

## Setup Instructions

### Prerequisites
- **Mac computer** - Required for running Xcode
- **Xcode** - Latest version (download from the Mac App Store)
- **Spoonacular API key** - For recipe search functionality
- **Firebase account** - For authentication and data storage

### Step 1: Install Xcode
1. Open the Mac App Store
2. Search for "Xcode" and install it
3. Launch Xcode and complete the initial setup

### Step 2: Set Up Firebase
The app requires Firebase for user authentication and Firestore database functionality:

1. Sign in to the [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use an existing one)
3. Add an iOS app to your Firebase project
   * Use the bundle ID: `com.vivian.CookAid` (or check the actual bundle ID in the Xcode project)
4. Download the `GoogleService-Info.plist` file
5. Add the file to the `CookAid/CookAid/` directory within the project
6. After opening the project in Xcode, drag the file into the project navigator (make sure "Copy items if needed" is selected)

### Step 3: Configure API Key
1. Open the file `CookAid/CookAid/APIKeys.plist` in a text editor (or navigate to it in Xcode after opening the project)
2. Add your Spoonacular API key between the `<string></string>` tags:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>RAPIDAPI_KEY</key>
    <string>your-api-key-here</string>
</dict>
</plist>
```

### Step 4: Open and Run the Project
1. Launch Xcode
2. Open the project by selecting the `CookAid.xcodeproj` file
3. Once Xcode opens the project, simply click the ▶️ (Play) button in the top-left corner to build and run the app
4. Select an iOS simulator when prompted (iPhone 14 Pro recommended)
5. Note: The application may take a few minutes to build on first launch

Note: If you encounter any build errors related to dependencies, you may need to install CocoaPods:
```bash
sudo gem install cocoapods
cd path/to/CookAid  # Navigate to project directory
pod install
```
Then open the `.xcworkspace` file instead of the `.xcodeproj` file.

## App Features

### 1. User Authentication System
- **Account Creation**: Email/password registration with secure Firebase authentication
- **Profile Management**: Update name and profile picture
- **Secure Data Storage**: User-specific data stored securely in Firebase
- **Session Management**: Persistent login sessions

### 2. Smart Pantry Management
- **Ingredient Tracking**: Add, edit, and remove ingredients in your pantry
- **Intelligent Categorization**: Automatic categorization using `IngredientCategorizer`
- **Expiry Tracking**: Optional date tracking for ingredients
- **Real-time Sync**: Firebase Firestore integration for real-time data updates
- **Category Filtering**: Filter pantry items by category
- **Bulk Operations**: Clear all ingredients or clear by category

### 3. Advanced Recipe Discovery
- **Ingredient-Based Search**: Find recipes based on ingredients you already have
- **Filtering System**: Comprehensive dietary filters (vegetarian, vegan, gluten-free, etc.)
- **Quick Meals**: Special filter for recipes that can be prepared quickly
- **Detailed Search Results**: Visual display of search results with images
- **Search History**: Track previous searches
- **Diet & Intolerance Filters**: Support for multiple dietary preferences and restrictions

### 4. Recipe Collections Management
- **Custom Collections**: Create and manage recipe collections with custom names and descriptions
- **Recipe Storage**: Save favorite recipes to collections
- **Web Recipe Import**: Import recipes from websites using URL
- **Recipe Editing**: Customize imported or created recipes
- **Recipe Details**: View comprehensive recipe information including ingredients, instructions, and dietary info
- **Recipe Tags**: Add and manage tags for better organization
- **Image Support**: Add images to recipes

### 5. Comprehensive Meal Planning
- **Weekly Calendar View**: Plan meals across the week
- **Meal Type Organization**: Organize by breakfast, lunch, dinner, and snacks
- **Drag-and-Drop Interface**: Intuitive drag-and-drop recipe placement
- **Recipe Integration**: Seamless integration with saved recipes
- **Flexible Planning**: Add multiple recipes to each meal slot
- **Week Navigation**: Navigate between weeks with arrow controls

### 6. Intelligent Grocery Management
- **Auto-Generated Lists**: Generate grocery lists from recipes
- **Manual Additions**: Add items manually with automatic categorization
- **Completion Tracking**: Check off items as you shop
- **Category Organization**: Items organized by department for efficient shopping
- **Editing Capabilities**: Edit or delete grocery items
- **Bulk Operations**: Clear all or completed items
- **Pantry Integration**: Add grocery items directly to pantry after purchase

### 7. Additional Features
- **Custom UI Components**: Tailored UI components for consistent UX
- **Error Handling**: Robust error handling with user-friendly messages
- **Loading States**: Intuitive loading indicators during API calls
- **Network Service**: Efficient API service with built-in caching
- **Local Storage**: User preferences saved locally
- **Dynamic Content Updates**: Real-time UI updates when data changes
- **Intelligent Auto-categorization**: Smart categorization of ingredients and grocery items

## Technical Implementation

### Architecture
- **MVVM Pattern**: Clear separation of concerns with Model-View-ViewModel architecture
- **SwiftUI Framework**: Modern declarative UI built with SwiftUI
- **Firebase Integration**: Authentication, Firestore database, and Storage
- **RESTful API Integration**: Communication with Spoonacular API
- **Combine Framework**: Reactive programming for data flow

### Key Components
- **Models**: Well-structured data models with proper encoding/decoding
- **ViewModels**: Business logic separation with observable objects
- **Services**: Dedicated service layer for API communication
- **Managers**: Specialized managers for collections, groceries, ingredients, etc.
- **Utilities**: Helper functions and extensions

### Performance Optimization
- **Async/Await Pattern**: Modern concurrency for smooth performance
- **Lazy Loading**: Efficient resource utilization with lazy loading
- **Memory Management**: Proper resource cleanup and memory management
- **Network Caching**: Reduced API calls through intelligent caching

## Testing the App
1. Create a test account or use the provided credentials
2. Add ingredients to your pantry and test the auto-categorization
3. Search for recipes based on your pantry ingredients
4. Create collections and save recipes
5. Import recipes from the web
6. Create a weekly meal plan
7. Generate grocery lists and test the check-off functionality

## Troubleshooting
- If you encounter build errors, check the Xcode console for details
- For Firebase-related issues, verify the `GoogleService-Info.plist` file
- For recipe search issues, confirm the API key is correctly set
