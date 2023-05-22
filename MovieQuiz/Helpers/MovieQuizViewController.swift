import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        
        alertPresenter = AlertPresenter()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func disableImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func enableAnswerButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func disableAnswerButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
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
            
            showLoadingIndicator()
            presenter.restartGame()
            view.isUserInteractionEnabled = true
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
}
