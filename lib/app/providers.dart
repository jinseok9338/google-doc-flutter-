import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/app/constants.dart';
import 'package:google_docs_clone/app/firebase.dart';
import 'package:google_docs_clone/app/state/state.dart';
import 'package:google_docs_clone/repositories/repositories.dart';

abstract class Dependency {
  static Provider<FirebaseFirestore> get database => _databaseProvider;
  static Provider<FirebaseAuth> get account => _accountProvider;
  static Provider<FirebaseFirestore> get realtime => _realtimeProvider;
}

abstract class Repository {
  static Provider<AuthRepository> get auth => AuthRepository.provider;
  static Provider<DatabaseRepository> get database =>
      DatabaseRepository.provider;
}

abstract class AppState {
  static StateNotifierProvider<AuthService, AuthState> get auth =>
      AuthService.provider;
}

final _databaseProvider = Provider<FirebaseFirestore>((ref) => firestore);

final _accountProvider = Provider<FirebaseAuth>((ref) => firebaseAuth);

final _realtimeProvider = Provider<FirebaseFirestore>((ref) => firestore);
