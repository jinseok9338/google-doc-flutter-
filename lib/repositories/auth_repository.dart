import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/app/providers.dart';
import 'package:google_docs_clone/repositories/repository_exception.dart';

final _authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.read));

class AuthRepository with RepositoryExceptionMixin {
  const AuthRepository(this._reader);

  static Provider<AuthRepository> get provider => _authRepositoryProvider;

  final Reader _reader;

  FirebaseAuth get _account => _reader(Dependency.account);

  Future<User> create({
    required String email,
    required String password,
    required String name,
  }) {
    return exceptionHandler(
      _createUser(
        email: email,
        password: password,
        name: name,
      ),
    );
  }

  Future<User?> _createUser({
    required String email,
    required String password,
    required String name,
  }) async {
    await _account.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _account.currentUser?.updateDisplayName(name);
    return _account.currentUser;
  }

  Future<UserCredential> createSession({
    required String email,
    required String password,
  }) {
    return exceptionHandler(
      _account.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<User?> get() async {
    return _account.currentUser;
  }

  Future<void> deleteSession() {
    return exceptionHandler(
      _account.signOut(),
    );
  }
}
