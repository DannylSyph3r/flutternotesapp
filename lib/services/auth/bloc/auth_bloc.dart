import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omegalogin/services/auth/bloc/auth_event.dart';
import 'package:omegalogin/services/auth/bloc/auth_state.dart';
import 'package:omegalogin/services/auth_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super( const AuthStateUninitialized(isLoading: true)) {
    //Send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    //Register
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
            email: email,
            password: password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
            exception: e,
            isLoading: false,
        ));
      }
    });
    //Initialize event
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if(user == null) {
        emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
        ),
        );
      } else if (!user.isEmailVerified){
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(
          user: user,
          isLoading: false,
        ));
      }
    });
    //Login event
    on<AuthEventLogin>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: "Please wait while i log you in",
      ),
      );
      await Future.delayed(const Duration(seconds: 2));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.login(
            email: email,
            password: password,
        );

        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
          ),
          );
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
          );
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
        ),
        );
      }
    });
    //Logout Event
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(
          const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ),
        );
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
            exception: e,
            isLoading: false,
        ),
        );
      }
    });
  }
}