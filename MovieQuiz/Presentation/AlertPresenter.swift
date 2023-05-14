import UIKit

class AlertPresenter{
    func showAlert(on controller: UIViewController, with alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: alertModel.completion)
        
        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
}
