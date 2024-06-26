import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - IB Outlets
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var buttonNo: UIButton!
    @IBOutlet weak private var buttonYes: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var quizPresenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        quizPresenter = MovieQuizPresenter(viewController: self)
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
    }
    
    // MARK: - Public Functions
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        changeStateButtons(isEnabled: true)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypColorGreen.cgColor : UIColor.ypColorRed.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    func showLoadingIndicator() {
        activityIndicator.color = .black // серый индикатор на сером фоне imageview не видно
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз")
        
        quizPresenter.alertPresenter.alertPresent(alertModel: model)
    }
    
    // MARK: - Private functions
    
    private func setupView() {
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
        buttonNo.isExclusiveTouch = true
        buttonYes.isExclusiveTouch = true
        imageView.layer.cornerRadius = 20
        buttonNo.layer.cornerRadius = 15
        buttonYes.layer.cornerRadius = 15
    }
    
    private func changeStateButtons(isEnabled: Bool) {
        buttonNo.isEnabled = isEnabled
        buttonYes.isEnabled = isEnabled
        buttonNo.backgroundColor = isEnabled ? UIColor.white : UIColor.gray
        buttonYes.backgroundColor = isEnabled ? UIColor.white : UIColor.gray
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
