import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omegalogin/services/auth/bloc/auth_bloc.dart';
import 'package:omegalogin/services/auth/bloc/auth_event.dart';
import 'package:omegalogin/services/auth/bloc/auth_state.dart';
import '../services/auth/auth_exceptions.dart';
import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Weak Password.");
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, "Email is already in use");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Failed to register");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid Email");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Please type in your email address and preferred password"),
            TextField(
              enableSuggestions: false,
              autocorrect: false,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              controller: _email,
              decoration:
              const InputDecoration(hintText: "Enter your email"),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration:
              const InputDecoration(hintText: "Enter your password"),
            ),
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      context.read<AuthBloc>().add(AuthEventRegister(
                          email,
                          password,
                      ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                  TextButton(onPressed: () {
                    context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
                  },
                    child: const Text('Already registered? Login here'),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}