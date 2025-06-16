import 'package:event_bnb/screens/email_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(),
    ),

    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return EmailVerificationScreen(
          email: data['email']!,
          password: data['password']!,
        );
      },
    ),



  ],
);


