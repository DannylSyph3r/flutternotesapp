import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omegalogin/constants/routes.dart';
import 'package:omegalogin/services/auth/auth_service.dart';
import 'package:omegalogin/services/auth/bloc/auth_bloc.dart';
import 'package:omegalogin/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  _VerifyEmailViewState createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text('We have already sent a verification link to your email!'),
          const Text('Use it to verify your email!'),
          const Text("Haven't received the email? Use the button below"),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                  const AuthEventSendEmailVerification(),
              );
            },
            child: const Text('Send email verification'),
          ),
          TextButton(onPressed: () {
            context.read<AuthBloc>().add(
              const AuthEventLogOut(),
            );
          }, child: const Text('Restart')
          )
        ],
      ),
    );
  }
}
