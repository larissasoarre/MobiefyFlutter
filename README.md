# Mobiefy Flutter 🛵

This project is a mobile application developed in Kotlin, aimed at providing a comprehensive solution for urban mobility. The [Mobiefy](https://mobiefy.netlify.app) app integrates multimodal routes, allowing users to combine various modes of transportation available in the cities. Users have the 
flexibility to adjust their routes according to their mobility needs, including options adapted for individuals with reduced mobility.

Accessibility is a priority for us, and Mobify has been designed to be accessible to everyone. The app includes features that facilitate the daily lives of individuals with reduced mobility, ensuring an inclusive user experience.

By using Mobify, users have access to detailed information about routes and vehicle availability through an intuitive interface. This eliminates the need for multiple apps to plan routes, centralizing all information in a single location.

## Features ✨
Features already available in the software:

**Welcome screen**: it's possible to view basic information about the application.

**Location Authorization screen**: where it's possible to grant permission for the app to access the user's location.

**Terms of Use and Privacy Policy screen**: where it's possible to read and accept the Terms of Use and Privacy Policy in order to proceed with using the app. 

**Registration screen**: where it's possible to create a new user's registration.

**Login screen**: where it's possible to provide the email and password to access the application.

**Main Screen**: where it's possible to search for your destination, choose it, and view all available routes for your trip. You can select the most convenient transportation option and, with a click, see all the trip details, including the estimated time and arrival time.

**Profile Settings screen**: it's possible to add more information to your account, such as date of birth, gender, pronoun, city, and whether you have any disabilities.

**Emergency Contact screen**: where it's possible to add an emergency contact to facilitate communication in critical situations.

**Emergency Button**: it's possible to quickly call emergency services or your emergency contact by clicking the emergency button, enhancing safety during your travels.

**MobieClub screen**: where it's possible to view the benefits and prices of MobieClub subscriptions, as well as access a FAQ with frequently asked questions about the subscription.

**Logout**: it's possible to log out of the current account, ensuring the security of your personal information by ending the session in the app.


<!-- ## Pre Requirements ‼️ -->


## How to Install ⚙️

To install in developer mode, follow the step-by-step:

1. Clone the repository on your computer
```
    git clone <repository_url>
```

2. Access the directory where you downloaded this project and run the command below *install dependencies*
```
    flutter pub get
```

## Firebase Setup 🖥
To integrate Firebase services such as Firestore and Authentication with Email in your Flutter project, you will need to:

1. Go to [Firebase Console]() and create a new project. Simply follow the step-by-step given to you on the screen.

2. Activate Email/Password as a login method in your Firebase Authentication settings.

3. Create a new database on Firestore, and add a ``users`` collection to it. 

If you encounter any issues during the setup, you can always check out Firebase's [official documentation](https://firebase.google.com/docs/flutter/setup?platform=ios).

## Google Maps API Setup 🌎
To enable Google Maps functionality in the app, you will need to:

1. Go to the [Google Cloud Console](https://console.cloud.google.com/) and generate a Google Maps API key.

2. In your Android project, create a ```secrets.properties``` file in the android directory.

3. Insert the following line in the ```secrets.properties``` file:
```
    GOOGLE_MAPS_API=your_api_key_here
```
4. Create a ```.env``` file at the root of your project.

5. Add the following line to the ```.env``` file:
```
    GOOGLE_MAPS_API=your_api_key_here
```

## How to Run 🕹

### Building the Project
To create a production-ready build of the project, execute:
```
% flutter run
```

### Specific Device
To run the project on a specific device, use:
```
% flutter run -d <device_id>
```

### See the options and Choose the Device
To run the project and see the options and choose the device, use:
```
% flutter emulators
```

### Development Mode
For development purposes, where you can see changes in real-time as you edit the code, run:
```
% press play (Run Code) or press F5
```


## Design and Prototyping 🎨

Figma was chosen as the central tool in the challenge due to its real-time collaboration capabilities and intuitive interface for agile design and prototyping. Please access to view the app's creation [wireframe](https://www.figma.com/design/4Fj5dHkzcDBgtPvTKKAY0E/MaaS-App?node-id=2116-2025&t=dKvGq7BpwUmAtEh6-1) and [prototype](https://www.figma.com/design/4Fj5dHkzcDBgtPvTKKAY0E/MaaS-App?node-id=2116-2025&t=dKvGq7BpwUmAtEh6-1).


## Fun Facts ⭐

This challenge was developed as part of an orientation program at the [FIAP](https://www.fiap.com.br) in collaboration with [ManageEngine](https://www.manageengine.com).

## License
MIT © [Beatriz Nonato](https://www.linkedin.com/in/beatriznonato/) 👩🏻‍💻 and [Larissa Soares](https://www.linkedin.com/in/larissacsoares/) 👩🏼‍💻
