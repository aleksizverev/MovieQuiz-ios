import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func hasLessCorrectAnswers(than otherGame: GameRecord) -> Bool {
        return self.correct < otherGame.correct
    }
}
