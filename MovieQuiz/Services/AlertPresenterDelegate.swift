import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func startNewGame()
    func sendAlert(alert: UIAlertController)
}
