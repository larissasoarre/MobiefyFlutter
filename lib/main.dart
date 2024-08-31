import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/views/home.dart';
import 'package:mobiefy_flutter/views/loading_screen.dart';
import 'package:mobiefy_flutter/views/login_screen.dart';
import 'package:mobiefy_flutter/views/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase
  );
  runApp(const MyApp()); // Run the app after Firebase is initialized
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobiefy',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasCompletedSetup = prefs.getBool('hasCompletedSetup') ?? false;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (!hasCompletedSetup) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    } else if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}
