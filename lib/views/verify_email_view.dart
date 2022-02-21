import 'package:flutter/material.dart';
import 'package:omegalogin/constants/routes.dart';
import 'package:omegalogin/services/auth/auth_service.dart';

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
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send email verification'),
          ),
          TextButton(onPressed: () async{
            await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          }, child: const Text('Restart')
          )
        ],
      ),
    );
  }
}
