import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omegalogin/services/auth/bloc/auth_bloc.dart';
import 'package:omegalogin/services/auth/bloc/auth_event.dart';
import 'package:omegalogin/services/auth/bloc/auth_state.dart';
import '../services/auth/auth_exceptions.dart';
import '../utilities/dialogs/error_dialog.dart';
import 'login_header.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException ||
              state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, "Cannot find user with entered Credentials");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Authentication Error");
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        //appBar: AppBar(title: const Text('Login'),
        //),
        body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.orange,
              Colors.yellow,
              Colors.red,
          ]),
        ),
          child: Column(children: <Widget>[
              SizedBox(height: 80,),
              Header(),
              Expanded(child: Container(
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
                )
                ),

                  child: Padding(
                  padding: EdgeInsets.all(30),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 40,),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey),
                                  )
                              ),
                              child: TextField(
                                enableSuggestions: false,
                                autocorrect: false,
                                keyboardType: TextInputType.emailAddress,
                                controller: _email,
                                decoration: InputDecoration(
                                    hintText: "Enter your email",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey),
                                  )
                              ),
                              child: TextField(
                                controller: _password,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration:
                                const InputDecoration(
                                  hintText: "Enter your password",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0,
                            right: 0.0,
                            top: 40.0,
                            bottom: 5.0,
                         ),
                        child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 45,
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: TextButton(
                                  onPressed: () async {
                                    final email = _email.text;
                                    final password = _password.text;
                                    context.read<AuthBloc>().add(
                                      AuthEventLogin(
                                        email,
                                        password,
                                      ),
                                    );
                                  },
                                  child: const Text('Login', style: TextStyle(
                                      color:  Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 45,
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      const AuthEventShouldRegister(),
                                    );
                                  },
                                  child: const Text('Register for an account', style: TextStyle(
                                      color:  Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 45,
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      const AuthEventForgotPassword(),
                                    );
                                  },
                                  child: const Text('Forgot Password?', style: TextStyle(
                                      color:  Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                    ),
                      ),
                  ],
                ),
              ),
              ),
              ),
            ],
            ),
        ),
      ),
    );
  }
}

