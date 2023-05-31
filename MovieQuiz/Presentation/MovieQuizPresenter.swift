import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var quizesPlayed = 0
    private var correctAnswers = 0
    private var currentQuestionIndex: Int = 0
    
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        
        viewController.showLoadingIndicator()
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func setCurrentQuestion(to question: QuizQuestion){
        currentQuestion = question
    }
    
    private func getCurrentQuestion() -> QuizQuestion? {
        return currentQuestion
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadImage(with error: Error) {
        viewController?.showAlert(title: "Ошибка",
                  message: "Не удалось загрузить изображение",
                  buttonText: "Попробовать снова"){ [weak self] _ in
            guard let self = self else { return }
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        setCurrentQuestion(to: question)
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        viewController?.enableAnswerButtons()
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.disableAnswerButtons()
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        viewController?.disableImageBorder()
        if self.isLastQuestion() {
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
            
            viewController?.showAlert(title: "Этот раунд окончен!",
                      message: results,
                      buttonText: "Сыграть еще раз"){ [weak self] _ in
                guard let self = self else { return }
                
                restartGame()
                correctAnswers = 0
                questionFactory?.requestNextQuestion()
            }
        } else {
            questionFactory?.requestNextQuestion()
            switchToNextQuestion()
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
}
