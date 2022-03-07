import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omegalogin/constants/routes.dart';
import 'package:omegalogin/helpers/loading/loading_screen.dart';
import 'package:omegalogin/services/auth/bloc/auth_bloc.dart';
import 'package:omegalogin/services/auth/bloc/auth_event.dart';
import 'package:omegalogin/services/auth/bloc/auth_state.dart';
import 'package:omegalogin/services/auth/firebase_auth_provider.dart';
import 'package:omegalogin/views/login_view.dart';
import 'package:omegalogin/views/notes/create_update_note_view.dart';
import 'package:omegalogin/views/notes/notes_view.dart';
import 'package:omegalogin/views/register_view.dart';
import 'package:omegalogin/views/verify_email_view.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}
 
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingScreen().show(
                context: context,
                text: state.loadingText ?? "Please wait just a moment",
            );
          } else {
            LoadingScreen().hide();
          }
        },
        builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const NotesView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    },
    );
  }
}


