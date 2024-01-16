# Connect4 iOS Game

---

A UIKIT application project for my CompSci MSc Swift module.

We were tasked with creating a Connect 4 game using the provided Alpha-0C4 deep learning bot. It was necessary to implement a UI so that a user can play against the bot.
It was also necessary to implement persistence using Core Data in order to allow the saving and continuing of games.

The game followed the Model-View-Controller (MVC) pattern, with a data model created to manage the the bot's API and ease the enabling of persistence. Multiple views 
were naturally created for each of the UI jobs necessary to play the game and view history. Several different ViewControllers were created to manage these views. Some duplication was possible, especially in the replayVC which reflects the gameVC to a great degree.

In this app I have made use of Core Data, Navigation and Tab Bar Controllers, the NotifcationCenter API. BezierPath was used frequently to draw custom views.
Please examine the source code and Report.pdf for more detailed notes on the apps functionality.

**Please note, I do not have the rights to publish the Alpha-0C4 library. To run this application, another similar bot may be used in its place**

---

#### UIKIT Storyboard:
<img width="787" alt="image" src="https://github.com/jamesclackett/iOS-Connect4-Game/assets/55019466/12ddb5ca-f164-4ed6-86a2-97c60ad5bdf8">

---

### User Interface:

#### _Compact Screen Size_

<img width="600" alt="image" src="https://github.com/jamesclackett/iOS-Connect4-Game/assets/55019466/badf86f3-16e4-4b3e-9d2b-980ce136fd9c">

#### _Large Screen Size_

<img width="600" alt="image" src="https://github.com/jamesclackett/iOS-Connect4-Game/assets/55019466/d5bccef2-4b76-4824-b122-896d891328b3">

---


