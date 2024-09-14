import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(
    String uid,
    String fullName,
    String email,
    bool performanceAnalyticsAgreement,
  ) async {
    try {
      await _db.collection('users').doc(uid).set({
        'full_name': fullName,
        'email': email,
        'performance_analytics_agreement': performanceAnalyticsAgreement,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error creating user in Firestore: $e");
      }
      rethrow;
    }
  }

  Future<void> updateUserDetails(
    String uid,
    String? dateOfBirth,
    String? gender,
    String? city,
    String? disability,
  ) async {
    try {
      await _db.collection('users').doc(uid).update({
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null) 'gender': gender,
        if (city != null) 'city': city,
        if (disability != null) 'disability': disability,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user details in Firestore: $e");
      }
      rethrow;
    }
  }

  Future<void> addEmergencyContact(
    String uid,
    String? emergencyContactName,
    String? emergencyContactNumber,
  ) async {
    try {
      await _db.collection('users').doc(uid).update({
        if (emergencyContactName != null)
          'emergency_contact_name': emergencyContactName,
        if (emergencyContactNumber != null)
          'emergency_contact_number': emergencyContactNumber,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user details in Firestore: $e");
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot snapshot = await _db.collection('users').doc(uid).get();
      return snapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user details: $e");
      }
      return null;
    }
  }
}
