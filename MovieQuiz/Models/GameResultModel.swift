import Foundation

struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterRecord(_ currentGame: GameResult) -> Bool {
        self.correct > currentGame.correct
    }
}
