# SOCIAL MEDIA APP 📸  
Developed a fully functional social media application using Flutter, Dart, and Provider for state management, backed by Firebase and Supabase. This app offers a dynamic and engaging platform for users to share content, interact with others, and explore posts, featuring smooth navigation and responsive UI design.

# Key Features Implemented:
* 🔐 Firebase Authentication:
  * Secure user login and sign-up flow using Firebase Auth.
  * Supports email/password-based authentication with session management.

* 🖼️ Media Upload & Storage:
  * Integrated Supabase Storage to manage user-uploaded media (images, profile pictures).
  * Ensures fast and reliable media access.

* 🧩 State Management:
  * Utilizes Provider for clean and scalable state management across the app.
  * Ensures reactive UI updates with minimal boilerplate.

* 📰 Post Creation & Feed Display:
  * Users can create posts by uploading images and adding captions.
  * Dynamically loads and displays a real-time feed of user content.

* 💬 Comments and Interactions:
  * Users can comment on posts and engage with the community.
  * Clean UI to handle scrolling, refreshing, and real-time updates.

# Technologies Used:
* **Frontend**: Built with Flutter and Dart, using Provider for state management.
* **Backend Services**:
  * **Firebase**: Used for authentication and real-time database.
  * **Supabase**: Used for file storage (media content like images).

# Screenshots

# Run on your device:
* 🔧 Prerequisites  
  * Before starting, make sure you have:
    * ✅ Flutter SDK installed and configured  
    * ✅ Git installed  
    * ✅ Android Studio or Visual Studio Code (with Flutter & Dart plugins)  
    * ✅ A connected Android device or emulator  

* 📥 Step 1: Clone the Repository  
  * Open a terminal and run:
    * `git clone https://github.com/nikhilesh-7119/Social-Media-App.git`  
    * `cd social-media-app`  

* 📦 Step 2: Install Dependencies  
  * Run the following command to install all required packages:
    * `flutter pub get`

* 🔐 Step 3: Set Up Firebase & Supabase  
  * Create a Firebase project and configure Authentication  
  * Download and place the `google-services.json` file in `android/app/`  
  * Set up a Supabase project at [https://supabase.io](https://supabase.io)  
  * Configure Supabase keys and storage bucket as needed  
  * Create a `.env` or constants file to store Supabase credentials

* 🛠️ Step 4: Run the App  
  * Use the following command to launch the app:
    * `flutter run`

# 📃 License  
* This project is open-source and available under the MIT License.

