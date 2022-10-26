import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/app/firebase.dart';
import 'package:google_docs_clone/app/providers.dart';
import 'package:google_docs_clone/app/state/state.dart';
import 'package:google_docs_clone/app/utils.dart';
import 'package:google_docs_clone/models/models.dart';
import 'package:google_docs_clone/repositories/repositories.dart';

final _authServiceProvider = StateNotifierProvider<AuthService, AuthState>(
    (ref) => AuthService(ref.read));

class AuthService extends StateNotifier<AuthState> {
  AuthService(this._read)
      : super(const AuthState.unauthenticated(isLoading: true)) {
    refresh();
  }

  static StateNotifierProvider<AuthService, AuthState> get provider =>
      _authServiceProvider;

  final Reader _read;

  get userName => null;

  Future<void> refresh() async {
    try {
      firebaseAuth.authStateChanges().listen((user) {
        if (user != null) {
          setUser(user);
        } else {
          logger.severe('Not authenticated');
          state = const AuthState.unauthenticated();
        }
      });
    } on RepositoryException catch (_) {
      logger.severe('Not authenticated');
      state = const AuthState.unauthenticated();
    }
  }
  // this is the problem listen to the auth state rather than doing it manually

  void setUser(User? user) {
    if (user != null) {
      var userName = user.displayName;
      logger.info('Authentication successful, setting $userName');
      state = state.copyWith(user: user, isLoading: false);
    } else {
      logger.severe('Authentication Failed');
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signOut() async {
    try {
      await _read(Repository.auth).deleteSession();
      logger.info('Sign out successful');
      state = const AuthState.unauthenticated();
    } on RepositoryException catch (e) {
      state = state.copyWith(error: AppError(message: e.message));
    }
  }
}

class AuthState extends StateBase {
  final User? user;
  final bool isLoading;

  const AuthState({
    this.user,
    this.isLoading = false,
    AppError? error,
  }) : super(error: error);

  const AuthState.unauthenticated({this.isLoading = false})
      : user = null,
        super(error: null);

  @override
  List<Object?> get props => [user, isLoading, error];

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    AppError? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}
