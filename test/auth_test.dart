import 'package:flutter_test/flutter_test.dart';
import 'package:omegalogin/services/auth/auth_exceptions.dart';
import 'package:omegalogin/services/auth/auth_user.dart';
import 'package:omegalogin/services/auth_provider.dart';

void main(){
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', (){
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', (){
      expect(provider.logOut(), throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to be initialized', () async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize after 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    },
    timeout: const Timeout(Duration(seconds: 2))
    );
    
    test('Create user should delegates to login ', () async {
      final badEmailUser = provider.createUser(
        email: 'sypher@sleth.com',
        password: 'passcode',
      );
      expect(badEmailUser, throwsA(const TypeMatcher<NotInitializedException>()));

      final badPasswordUser = provider.createUser(
          email: 'someone@sleth.com',
          password: 'sypher123',
      );
      expect(badPasswordUser, throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: 'sypher',
        password: 'sleth',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', (){
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.login(
          email: 'email',
          password: 'password',
      );
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser?_user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(
      email: email,
      password: password,
    );
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'sypher@sleth.com') throw UserNotFoundAuthException();
    if (password == 'sypher123') throw WrongPasswordAuthException();
    const user =AuthUser(isEmailVerified: false, email: 'sypher@sleth.com',);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: 'sypher@sleth.com',);
    _user = newUser;
  }
}
