import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validation_utils.dart';
import '../../bloc/auth/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(gradient: AppTheme.blueGradient),
            child: Center(
              child: Text(
                'Sign Up',
                style: AppTheme.montserratStyle(45, Colors.white),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 1.4,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.status == AuthStatus.authenticated) {
                    Navigator.of(context).pop();
                  }
                },
                builder: (context, state) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.7,
                          child: TextFormField(
                            controller: _nameController,
                            style: AppTheme.montserratStyle(18, Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Name',
                              prefixIcon: const Icon(Icons.person),
                              hintStyle: AppTheme.ralewayStyle(
                                16,
                                Colors.grey,
                                FontWeight.w400,
                              ),
                            ),
                            validator: ValidationUtils.validateName,
                            enabled: state.status != AuthStatus.loading,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.7,
                          child: TextFormField(
                            controller: _emailController,
                            style: AppTheme.montserratStyle(18, Colors.black),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              hintStyle: AppTheme.ralewayStyle(
                                16,
                                Colors.grey,
                                FontWeight.w400,
                              ),
                            ),
                            validator: ValidationUtils.validateEmail,
                            enabled: state.status != AuthStatus.loading,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.7,
                          child: TextFormField(
                            controller: _passwordController,
                            style: AppTheme.montserratStyle(18, Colors.black),
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              hintStyle: AppTheme.ralewayStyle(
                                16,
                                Colors.grey,
                                FontWeight.w400,
                              ),
                            ),
                            validator: ValidationUtils.validatePassword,
                            enabled: state.status != AuthStatus.loading,
                          ),
                        ),
                        const SizedBox(height: 40),
                        if (state.status == AuthStatus.loading)
                          const CircularProgressIndicator()
                        else
                          InkWell(
                            onTap: _onSignUpPressed,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: AppTheme.blueGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Sign Up',
                                  style: AppTheme.ralewayStyle(
                                    25,
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
