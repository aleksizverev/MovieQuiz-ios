import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() throws {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"].label
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel, "2/10")
    }

    func testNoButton() throws {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"].label
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel, "2/10")
    }
    
    func testRoundEndAlert() throws {
        for _ in 0...9 {
            sleep(2)
            app.buttons["Yes"].tap()
        }
        sleep(2)
        
        let alert = app.alerts["Этот раунд окончен!"].firstMatch
        let alertExists = alert.exists
        
        XCTAssertTrue(alertExists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }
    
    func testAlertDismiss() throws {
        for _ in 0...9 {
            sleep(2)
            app.buttons["Yes"].tap()
        }
        sleep(2)
        
        let alert = app.alerts["Этот раунд окончен!"].firstMatch
        alert.buttons.firstMatch.tap()
        
        XCTAssertFalse(alert.exists)
        sleep(2)
        XCTAssertEqual(app.staticTexts["Index"].label, "1/10")
    }
    
}
