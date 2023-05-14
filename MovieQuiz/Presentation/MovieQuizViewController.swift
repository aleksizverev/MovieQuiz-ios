import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate{
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var quizesPlayed = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        alertPresenter = AlertPresenter()
        statisticService = StatisticServiceImplementation()
        
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadImage(with error: Error) {
        showAlert(title: "Ошибка",
                  message: "Не удалось загрузить изображение",
                  buttonText: "Попробовать снова"){ [weak self] _ in
            guard let self = self else { return }
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showAlert(title: String,
                           message: String,
                           buttonText: String,
                           completion: ((UIAlertAction)->Void)?){
        
        let alertModel = AlertModel(
            title: title,
            message: message,
            buttonText: buttonText,
            completion: completion)
        
        alertPresenter?.showAlert(on: self, with: alertModel)
    }
    
    private func showNetworkError(message: String) {
        view.isUserInteractionEnabled = false
        hideLoadingIndicator()
        
        showAlert(title: "Ошибка",
                  message: message,
                  buttonText: "Попробовать еще раз"){ [weak self] _ in
            guard let self = self else {return}
            
            currentQuestionIndex = 0
            correctAnswers = 0
            showLoadingIndicator()
            questionFactory?.loadData()
            view.isUserInteractionEnabled = true
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionsAmount - 1 {
            quizesPlayed += 1
            
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            guard let gamesCount = statisticService?.gamesCount,
                  let totalAccuracy = statisticService?.totalAccuracy,
                  let recordGame = statisticService?.bestGame
            else {
                return
            }
            
            let results = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(gamesCount)
            Рекод: \(recordGame.correct)/\(recordGame.total) (\(recordGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
            
            showAlert(title: "Этот раунд окончен!",
                      message: results,
                      buttonText: "Сыграть еще раз"){ [weak self] _ in
                guard let self = self else { return }
                
                currentQuestionIndex = 0
                correctAnswers = 0
                questionFactory?.requestNextQuestion()
            }
        } else {
            questionFactory?.requestNextQuestion()
            currentQuestionIndex += 1
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            showNextQuestionOrResults()
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
}
