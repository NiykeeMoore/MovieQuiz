import UIKit

class AlertPresenter {
    weak var viewController: UIViewController?
    
    func alertPresent(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default) { [weak self] _ in
                guard let viewController = self?.viewController as? MovieQuizViewController else { return }
                viewController.startNewGame()
            }
        
        alert.addAction(action)
        DispatchQueue.main.async {
            self.viewController?.present(alert, animated: true, completion: nil)
        }
    }
}
