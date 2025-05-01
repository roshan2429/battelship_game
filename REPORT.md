
Note :

1. The app fails on Chrome due to a 403 Forbidden response from https://battleships-app.onrender.com/login or register because Cloudflare is blocking the proxy’s HttpClient requests, likely due to bot protection or server restrictions. I tried to use proxy but it did not work out

2. However it is working perfectly on IOS/Android simulator simulator
   
# MP Report

## Student information

- Name: Roshan Hyalij
- AID: A20547441

## Self-Evaluation Checklist

Tick the boxes (i.e., fill them with 'X's) that apply to your submission:

- [X] The app builds without error
- [X] I tested the app in at least one of the following platforms (check all
      that apply):
  - [X] iOS simulator
  - [X] Android emulator
- [X] Users can register and log in to the server via the app
- [X] Session management works correctly; i.e., the user stays logged in after
      closing and reopening the app, and token expiration necessitates re-login
- [X] The game list displays required information accurately (for both active
      and completed games), and can be manually refreshed
- [X] A game can be started correctly (by placing ships, and sending an
      appropriate request to the server)
- [X] The game board is responsive to changes in screen size
- [X] Games can be started with human and all supported AI opponents
- [X] Gameplay works correctly (including ship placement, attacking, and game
      completion)

## Summary and Reflection

The development of a modern visual user interface pleased me especially because I got to experiment with gradients and animations to build the nautical theme that matched Battleship. 

Debugging the iOS build failure because of the missing http import presented the biggest challenge since I needed to learn about Dart’s import system and enforce file consistency. The setup of Android emulator required substantial time because I needed to use Android Studio’s AVD Manager before fixing SDK issues. The struggles during testing would have been shortened if I had acquired earlier understanding of how Flutter handles platform builds together with emulator configuration. My next development step includes working on ship crash sound feedback while I also plan to address lower-end device compatibility to reach more users.
