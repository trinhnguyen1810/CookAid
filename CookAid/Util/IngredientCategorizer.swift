import Foundation

struct IngredientCategorizer {
    // Standard categories used throughout the app
    static let categories = [
        "Fruits & Vegetables",
        "Proteins",
        "Dairy & Dairy Alternatives",
        "Grains and Legumes",
        "Spices, Seasonings and Herbs",
        "Sauces and Condiments",
        "Baking Essentials",
        "Others"
    ]
    
    // Main function to categorize an ingredient by name
    static func categorize(_ name: String) -> String {
        let lowercaseName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check each category based on keywords
        if matchesFruitsAndVegetables(lowercaseName) {
            return categories[0]
        } else if matchesProteins(lowercaseName) {
            return categories[1]
        } else if matchesDairyAndAlternatives(lowercaseName) {
            return categories[2]
        } else if matchesGrainsAndLegumes(lowercaseName) {
            return categories[3]
        } else if matchesSpicesAndHerbs(lowercaseName) {
            return categories[4]
        } else if matchesSaucesAndCondiments(lowercaseName) {
            return categories[5]
        } else if matchesBakingEssentials(lowercaseName) {
            return categories[6]
        }
        
        // Default category if no match is found
        return categories[7] // "Others"
    }
    
    // MARK: - Category Matching Helpers
    
    private static func matchesFruitsAndVegetables(_ name: String) -> Bool {
        let keywords = [
            // Fruits
            "apple", "banana", "orange", "grape", "strawberry", "berry", "blueberry", "raspberry",
            "blackberry", "pear", "peach", "plum", "apricot", "cherry", "mango", "papaya",
            "pineapple", "watermelon", "melon", "cantaloupe", "kiwi", "fig", "date", "pomegranate",
            "guava", "lychee", "passion fruit", "grapefruit", "lime", "lemon", "citrus","dragonfruit",
            
            // Vegetables
            "carrot", "broccoli", "spinach", "kale", "lettuce", "cabbage", "cauliflower",
            "cucumber", "zucchini", "squash", "pumpkin", "eggplant", "aubergine", "pepper",
            "bell pepper", "chili", "jalapeño", "mushroom", "asparagus", "celery", "leek",
            "turnip", "parsnip", "radish", "beet", "beetroot", "potato", "sweet potato",
            "yam", "onion", "garlic", "shallot", "spring onion", "scallion", "tomato",
            "avocado", "corn", "artichoke", "brussels sprout", "bok choy", "pea", "green bean",
            "snow pea", "snap pea", "okra", "arugula", "rocket", "collard green"
        ]
        
        return keywords.contains { name.contains($0) }
    }
    
    private static func matchesProteins(_ name: String) -> Bool {
        let keywords = [
            // Meats
            "chicken", "beef", "pork", "lamb", "veal", "mutton", "steak", "filet",
            "ribeye", "sirloin", "mince", "ground", "sausage", "bacon", "ham", "prosciutto",
            "salami", "pepperoni", "hot dog", "frankfurter", "turkey", "duck", "goose",
            "venison", "bison", "rabbit", "liver", "kidney", "tripe", "tongue",
            
            // Seafood
            "fish", "salmon", "tuna", "cod", "trout", "bass", "haddock", "tilapia",
            "snapper", "swordfish", "mackerel", "herring", "anchovy", "sardine",
            "shrimp", "prawn", "lobster", "crab", "scallop", "clam", "mussel", "oyster",
            "squid", "calamari", "octopus",
            
            // Vegetarian proteins
            "tofu", "tempeh", "seitan", "quorn", "egg", "eggs", "tvp", "textured vegetable protein"
        ]
        
        return keywords.contains { name.contains($0) }
    }
    
    private static func matchesDairyAndAlternatives(_ name: String) -> Bool {
        let keywords = [
            // Dairy
            "milk", "cream", "heavy cream", "whipping cream", "sour cream", "half and half",
            "butter", "ghee", "cheese", "cheddar", "mozzarella", "parmesan", "ricotta",
            "cottage cheese", "brie", "camembert", "feta", "gouda", "goat cheese", "blue cheese",
            "yogurt", "yoghurt", "greek yogurt", "kefir", "buttermilk", "ice cream", "custard",
            
            // Dairy alternatives
            "almond milk", "soy milk", "oat milk", "coconut milk", "rice milk", "cashew milk",
            "vegan butter", "vegan cheese", "vegan yogurt", "vegan cream"
        ]
        
        return keywords.contains { name.contains($0) }
    }
    
    private static func matchesGrainsAndLegumes(_ name: String) -> Bool {
        let keywords = [
            // Grains
            "rice", "brown rice", "white rice", "basmati", "jasmine", "arborio", "wild rice",
            "oat", "oats", "oatmeal", "corn", "maize", "cornmeal", "polenta", "barley",
            "quinoa", "bulgur", "couscous", "farro", "millet", "spelt", "rye", "wheat", "kamut",
            "buckwheat", "amaranth", "sorghum", "teff",
            
            // Pasta & Noodles
            "pasta", "spaghetti", "penne", "fusilli", "rigatoni", "macaroni", "lasagna",
            "fettuccine", "linguine", "tagliatelle", "orzo", "noodle", "ramen", "udon", "soba",
            
            // Bread & Flour
            "bread", "loaf", "baguette", "roll", "pita", "naan", "tortilla", "flatbread",
            "ciabatta", "focaccia", "sourdough", "flour", "all-purpose flour", "bread flour",
            "cake flour", "pastry flour", "whole wheat flour", "rye flour", "cornflour", "cornstarch",
            
            // Legumes
            "bean", "beans", "black bean", "kidney bean", "pinto bean", "navy bean", "cannellini",
            "chickpea", "garbanzo", "lentil", "split pea", "black-eyed pea", "edamame", "soybean"
        ]
        
        return keywords.contains { name.contains($0) }
    }
    
    private static func matchesSpicesAndHerbs(_ name: String) -> Bool {
        let keywords = [
            // Spices
            "salt", "pepper", "black pepper", "white pepper", "cumin", "coriander", "turmeric",
            "paprika", "cinnamon", "nutmeg", "clove", "allspice", "cardamom", "star anise",
            "peppercorn", "saffron", "fennel seed", "mustard seed", "sesame seed", "poppy seed",
            "cayenne", "chili powder", "curry powder", "garam masala", "five spice", "za'atar",
            "sumac", "fenugreek", "juniper berry", "caraway", "anise", "mace", "bay leaf",
            
            // Herbs
            "oregano", "basil", "thyme", "rosemary", "sage", "mint", "dill", "parsley",
            "cilantro", "coriander", "chive", "tarragon", "bay leaf", "marjoram", "savory",
            "lemongrass", "lavender", "chervil"
        ]
        
        return keywords.contains { name.contains($0) }
    }
    
    private static func matchesSaucesAndCondiments(_ name: String) -> Bool {
        let keywords = [
            // Oils
            "oil", "olive oil", "vegetable oil", "canola oil", "sunflower oil", "sesame oil",
            "coconut oil", "peanut oil", "grapeseed oil", "avocado oil",
            
            // Vinegars
            "vinegar", "balsamic", "red wine vinegar", "white wine vinegar", "apple cider vinegar",
            "rice vinegar", "malt vinegar",
            
            // Sauces
            "sauce", "ketchup", "tomato sauce", "marinara", "soy sauce", "tamari", "fish sauce",
            "oyster sauce", "hoisin", "sriracha", "hot sauce", "tabasco", "barbecue", "bbq sauce",
            "worcestershire", "teriyaki", "pesto", "salsa", "chutney", "relish", "aioli",
            
            // Condiments
            "mustard", "dijon", "mayo", "mayonnaise", "dressing", "honey", "syrup", "maple syrup",
            "molasses", "jam", "jelly", "preserves", "marmalade", "nutella", "peanut butter",
            "almond butter", "tahini"
        ]
        
        return keywords.contains { name.contains($0) }
    }
    
    private static func matchesBakingEssentials(_ name: String) -> Bool {
        let keywords = [
            "baking powder", "baking soda", "yeast", "sugar", "brown sugar", "powdered sugar",
            "icing sugar", "confectioners sugar", "caster sugar", "granulated sugar", "vanilla",
            "vanilla extract", "almond extract", "chocolate", "chocolate chip", "cocoa powder",
            "cacao", "gelatin", "pectin", "cream of tartar", "food coloring", "sprinkles",
            "coconut flake", "dried fruit", "raisin", "cranberry", "apricot", "date", "prune",
            "nut", "walnut", "pecan", "almond", "hazelnut", "peanut", "pistachio", "cashew",
            "macadamia", "pine nut", "seed", "pumpkin seed", "sunflower seed", "flax seed",
            "chia seed", "hemp seed"
        ]
        
        return keywords.contains { name.contains($0) }
    }
}
