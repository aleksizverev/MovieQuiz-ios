import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    private var presenter: MovieQuizPresenter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        

        alertPresenter = AlertPresenter()
        statisticService = StatisticServiceImplementation()
        presenter = MovieQuizPresenter(viewController: self)
        
        
        showLoadingIndicator()
//        questionFactory?.loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showAlert(title: String,
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
    
    func showNetworkError(message: String) {
        view.isUserInteractionEnabled = false
        hideLoadingIndicator()
        
        showAlert(title: "Ошибка",
                  message: message,
                  buttonText: "Попробовать еще раз"){ [weak self] _ in
            guard let self = self else {return}
            
            presenter.restartGame()
            showLoadingIndicator()
//            questionFactory?.loadData()
            view.isUserInteractionEnabled = true
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
//    private func showNextQuestionOrResults() {
//        imageView.layer.borderWidth = 0
//        if presenter.isLastQuestion() {
//            quizesPlayed += 1
//
//            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
//
//            guard let gamesCount = statisticService?.gamesCount,
//                  let totalAccuracy = statisticService?.totalAccuracy,
//                  let recordGame = statisticService?.bestGame
//            else {
//                return
//            }
//
//            let results = """
//            Ваш результат: \(correctAnswers)/10
//            Количество сыгранных квизов: \(gamesCount)
//            Рекод: \(recordGame.correct)/\(recordGame.total) (\(recordGame.date.dateTimeString))
//            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
//            """
//
//            showAlert(title: "Этот раунд окончен!",
//                      message: results,
//                      buttonText: "Сыграть еще раз"){ [weak self] _ in
//                guard let self = self else { return }
//
//                presenter.resetQuestionIndex()
//                correctAnswers = 0
//                questionFactory?.requestNextQuestion()
//            }
//        } else {
//            questionFactory?.requestNextQuestion()
//            presenter.switchToNextQuestion()
//        }
//    }
    
    func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            presenter.showNextQuestionOrResults()
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
}
