import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  Future<bool> signup({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Sign up was successful
    } catch (e) {
      if (kDebugMode) {
        print("Login falhou: $e");
      }
      return false; // Sign up failed
    }
  }
}
