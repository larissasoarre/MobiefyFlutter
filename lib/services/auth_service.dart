import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static String signupError = '';

  Future<bool> signup({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Sign up was successful
    } catch (e) {
      if (kDebugMode) {
        print("Cadastro falhou: $e");
      }
      return false; // Sign up failed
    }
  }

  Future<bool> signin({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Sign in was successful
    } catch (e) {
      if (e is FirebaseAuthException) {
        signupError = 'E-mail ou senha incorretos.';
      } else {
        signupError = 'Ocorreu um erro desconhecido.';
      }
      return false; // Sign in failed
    }
  }
}
