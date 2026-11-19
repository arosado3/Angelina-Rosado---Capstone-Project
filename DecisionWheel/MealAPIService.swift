import Foundation

// MARK: - Codable API Models (TheMealDB)
nonisolated struct MealAPIResponse: Codable, Sendable {
    let meals: [MealAPIItem]?
}

nonisolated struct MealAPIItem: Codable, Sendable {
    let strMeal: String
    let strCategory: String?
}

// MARK: - API Service
class MealAPIService {
    static let shared = MealAPIService()
    private init() {}
    
    // Everyday decision-making prompts
    private let customDecisionQuestions: [String] = [
        "Where should we eat tonight?",
        "What movie should we watch?",
        "What should we do this weekend?",
        "Who has to pay for dinner?",
        "What takeout should we order?",
        "Which game should we play next?",
        "Where should we go for coffee?",
        "What should I cook for dinner?"
    ]
    
    /// Connects to a public API via URLSession and mixes live meal suggestions
    /// with custom decision-making questions using an @escaping closure.
    func fetchRandomQuestion(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(MealAPIResponse.self, from: data)
                var questionPool = self.customDecisionQuestions
                
                // Turn the live API result into a natural decision-wheel question
                if let meal = decodedResponse.meals?.first {
                    questionPool.append("Should we eat \(meal.strMeal) tonight?")
                    if let category = meal.strCategory {
                        questionPool.append("What \(category.lowercased()) dish should we get?")
                    }
                }
                
                let chosenQuestion = questionPool.randomElement() ?? "Where should we eat tonight?"
                
                DispatchQueue.main.async {
                    completion(.success(chosenQuestion))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
