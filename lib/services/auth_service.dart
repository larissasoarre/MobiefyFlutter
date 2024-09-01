import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';

class AuthService {
  static String signupError = '';

  Future<bool> signup({
    required String email,
    required String password,
    required String fullName,
    required bool performanceAnalyticsAgreement,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store information in Firestore
      await FirestoreService().createUser(
        userCredential.user!.uid,
        fullName,
        email,
        performanceAnalyticsAgreement,
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
