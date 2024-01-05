## **MovieQuiz**.

MovieQuiz is an app with quizzes about the top 250 rated films and the most popular films according to IMDb.

## **References**

[Figma Layout](https://www.figma.com/file/l0IMG3Eys35fUrbvArtwsR/YP-Quiz?node-id=34%3A243)

[IMDb API](https://imdb-api.com/api#Top250Movies-header)

[Fonts](https://code.s3.yandex.net/Mobile/iOS/Fonts/MovieQuizFonts.zip)

## **Application Description**

- A one-page app with quizzes about films from IMDb's top 250 ranking and most popular films. The app user sequentially answers questions about the rating of the film. At the end of each round of the game, statistics about the number of correct answers and the user's best results are shown. The goal of the game is to correctly answer all 10 questions of the round.

## **Functional Requirements**

- Splash screen is shown when the application is launched;
- After launching the app, a question screen is shown with the question text, a picture and two answer choices, "Yes" and "No", only one of them is correct;
- The quiz question is composed relative to the IMDb rating of the film on a 10-point scale, e.g.: "Is this film's rating greater than 6?";
- You can click on one of the options to answer a question and get feedback on whether it is correct or not, and the picture frame will change colour to match;
- After selecting an answer to a question, the next question automatically appears after 1 second;
- After completing a round of 10 questions, an alert appears with the user's statistics and an opportunity to play again;
- The statistics contains: the result of the current round (the number of correct answers from 10 questions), the number of played quizzes, the record (the best result of the round for the session, the date and time of this round), the statistics of played quizzes in percentage (average accuracy);
- The user can start a new round by clicking on the "Play Again" button in the alerter;
- If the data cannot be downloaded, the user sees an alert with a message that something went wrong and a button that can be clicked to repeat the network request.

## **Technical Requirements**

- The application must support iPhone devices with iOS 13, only portrait mode is provided;
- UI elements are adapted to iPhone screen resolutions starting from X - no layout for SE and iPad;
- The screens correspond to the layout - the right fonts of the right sizes are used, all inscriptions are in the right place, the position of all elements, button sizes and indents are exactly the same as in the layout.
