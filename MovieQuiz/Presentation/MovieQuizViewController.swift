import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol, AlertPresenterDelegate {
    // MARK: - IB Outlets
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak var buttonNo: UIButton!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var alertPresenter = AlertPresenter()
    
    private var quizPresenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quizPresenter = MovieQuizPresenter(viewController: self)
        
        alertPresenter.delegate = self
        showLoadingIndicator()
        
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
        buttonNo.isExclusiveTouch = true
        buttonYes.isExclusiveTouch = true
        imageView.layer.cornerRadius = 20
        buttonNo.layer.cornerRadius = 15
        buttonYes.layer.cornerRadius = 15
        
    }
    
    // MARK: - Private functions
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        changeStateButtons(isEnabled: true)
    }
    
    func convertAlertData(_ model: StatisticServiceImplementation?) -> AlertModel {
        guard let bestGame = model?.bestGame else {
            return AlertModel(title: "Ошибка", message: "Загрузка данных для алерта статистики", buttonText: "В ад")
        }
        
        let gamesCount = model?.gamesCount ?? 0
        let gamesAccuracy = model?.totalAccuracy ?? 0.0
        
        let recordCorrect = bestGame.correct
        let recordDate = bestGame.date
        
        return AlertModel(
            title: "Этот раунд окончен!",
            message: """
            Ваш результат: \(quizPresenter.correctAnswers) / \(quizPresenter.questionsAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(recordCorrect) / \(quizPresenter.questionsAmount) (\(recordDate.dateTimeString))
            Средняя точность: \(String(format: "%.2f", gamesAccuracy))%
            """,
            buttonText: "Сыграть еще раз")
        
    }
    
    private func changeStateButtons(isEnabled: Bool) {
        buttonNo.isEnabled = isEnabled
        buttonYes.isEnabled = isEnabled
        buttonNo.backgroundColor = isEnabled ? UIColor.white : UIColor.gray
        buttonYes.backgroundColor = isEnabled ? UIColor.white : UIColor.gray
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypColorGreen.cgColor : UIColor.ypColorRed.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.color = .black // серый индикатор на сером фоне imageview не видно
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз")
        
        alertPresenter.alertPresent(alertModel: model)
    }
    
    //MARK: - AlertPresenterDelegate
    
    func startNewGame() {
        quizPresenter?.restartGame()
    }
    
    func sendAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        changeStateButtons(isEnabled: false)
        quizPresenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        changeStateButtons(isEnabled: false)
        quizPresenter?.yesButtonClicked()
    }
}
