import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showNetworkError(message: String)
    func showAlert(title: String,
                   message: String,
                   buttonText: String,
                   completion: ((UIAlertAction)->Void)?)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func disableImageBorder()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func enableAnswerButtons()
    func disableAnswerButtons()
}
