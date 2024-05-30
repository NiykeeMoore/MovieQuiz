import UIKit

class AlertPresenter: AlertPresenterProtocol {

    weak var delegate: AlertPresenterDelegate?
    
    func alertPresent(alertModel: AlertModel, onView: UIViewController) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default) { _ in
                self.delegate?.startNewGame()
            }
        
        alert.addAction(action)
        DispatchQueue.main.async {
            onView.present(alert, animated: true, completion: nil)
        }
    }
}
