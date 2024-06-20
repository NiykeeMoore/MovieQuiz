import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // MARK: - IB Outlets
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak var buttonNo: UIButton!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private lazy var alertPresenter = AlertPresenter()
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory(moviesLoader: MoviesLoader())
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticServiceImplementation()
        alertPresenter.delegate = self
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
        buttonNo.isExclusiveTouch = true
        buttonYes.isExclusiveTouch = true
        imageView.layer.cornerRadius = 20
        buttonNo.layer.cornerRadius = 15
        buttonYes.layer.cornerRadius = 15
        
    }
    
    // MARK: - Private functions
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        changeStateButtons(isEnabled: true)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypColorGreen.cgColor : UIColor.ypColorRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            imageView.layer.borderColor = UIColor.clear.cgColor
            showNextQuestionOrResults()
        }
    }
    
    private func convertAlertData(_ model: StatisticServiceImplementation?) -> AlertModel {
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
            Ваш результат: \(correctAnswers) / \(questionsAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(recordCorrect) / \(questionsAmount) (\(recordDate.dateTimeString))
            Средняя точность: \(String(format: "%.2f", gamesAccuracy))%
            """,
            buttonText: "Сыграть еще раз")
        
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            let currentResult = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
            statisticService?.store(payload: currentResult)
            
            let model = convertAlertData(StatisticServiceImplementation())
            alertPresenter.alertPresent(alertModel: model)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func changeStateButtons(isEnabled: Bool) {
        buttonNo.isEnabled = isEnabled
        buttonYes.isEnabled = isEnabled
        buttonNo.backgroundColor = isEnabled ? UIColor.white : UIColor.gray
        buttonYes.backgroundColor = isEnabled ? UIColor.white : UIColor.gray
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.color = .black // серый индикатор на сером фоне imageview не видно
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз")
        
        alertPresenter.alertPresent(alertModel: model)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    //MARK: - AlertPresenterDelegate
    
    func startNewGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }
    
    func sendAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        changeStateButtons(isEnabled: false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        changeStateButtons(isEnabled: false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
