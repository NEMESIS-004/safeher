# SafeHer

## Problem Addressed: 
The primary problem addressed by "SafeHer" is the safety of women in various situations, especially in potentially dangerous scenarios. The goal is to empower women and provide them with a tool that enhances their safety and confidence while navigating through their daily lives.

## Some notable features of the SafeHer app:
**Threat Detection:** We have trained our ML model to detect threatful situations based on voice feeds received from users. Furthermore, we have integrated Bhashini API for language conversion allowing the app to be used in multiple languages, precisely in 19 regional languages. Apart from the voice feed the app also uses fall detection and high-pitch scream detection as other feeds to recognize threatful situations.

**Effect:** Swift automatic alerts are sent to emergency contacts, nearby police stations, and other app users within a 2-kilometer range, providing immediate assistance in emergencies.

**Video Evidence Generation:** In case of an alert, the app automatically captures a 30-second video recursively.Effect: Provides valuable evidence for incidents, aiding law enforcement and emergency contacts in understanding the situation and taking appropriate actions.

**Map and Emergency Services Information:** The app provides users with maps of the surrounding area and nearby emergency services.

**Effect:** Users can quickly locate and reach safety, enhancing their ability to respond effectively in emergencies.

## Tech Stack 📎

<div>
  <img src="https://skillicons.dev/icons?i=flutter,dart,python,gcp,fastapi"/>  
</div>


## Steps to run the Application

Clone this repository to your local machine

 ```bash
    git clone https://github.com/NEMESIS-004/safeher.git
 ```

1. Open the project inside any IDE that supports Flutter (VS Code for example):

2. Install the Flutter dependencies:

    ```bash
    flutter pub get
    ```
3. Connect your firebase project with the app using FlutterFire CLI, refer <a href="https://firebase.flutter.dev/docs/cli/">FlutterFire Docs</a>

4. Ensure you have a simulator/device connected or an emulator running.

5. Execute following command in terminal of the IDE or use the default runner of the IDE

    ```dart
    flutter run
    ```

   This will launch the application on your connected device.


## Contributing

If you would like to contribute to the project, please follow the standard Git workflow:

1. Fork the repository.
2. Create a new branch for your feature or bug fix: `git checkout -b feature/new-feature`.
3. Commit your changes: `git commit -m "Description of changes."`.
4. Push the branch to your fork: `git push origin feature/new-feature`.
5. Open a pull request with a detailed description of your changes.

Feel free to reach out if you have any questions or encounter issues.




A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
