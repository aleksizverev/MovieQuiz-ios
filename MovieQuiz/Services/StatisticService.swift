import Foundation

final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccuracy: Double {
        get {
            let correctAnswers = userDefaults.double(forKey: Keys.correct.rawValue)
            let totalAnswers = userDefaults.double(forKey: Keys.total.rawValue)
            return Double(correctAnswers/totalAnswers*100)
        }
    }
    
    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)}
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let otherGame = GameRecord(correct: count, total: amount, date: Date())
        if bestGame.hasLessCorrectAnswers(than: otherGame){
            self.bestGame = otherGame
        }
        gamesCount += 1
        
        let correctAnswers = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        let totalAnswers = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        
        userDefaults.set(correctAnswers, forKey: Keys.correct.rawValue)
        userDefaults.set(totalAnswers, forKey: Keys.total.rawValue)
    }
}
