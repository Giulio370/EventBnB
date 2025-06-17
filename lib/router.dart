

import 'package:event_bnb/screens/event_detail_user_screen.dart';
import 'package:event_bnb/screens/home_screen.dart';
import 'package:event_bnb/screens/login_screen.dart';
import 'package:event_bnb/screens/signup_screen.dart';
import 'package:event_bnb/screens/splash_screen.dart';
import 'package:event_bnb/session/session_manager.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
      redirect: (context, state) async {
        final session = SessionManager();
        return await session.isLoggedIn() ? null : '/login';
      },
    ),
    GoRoute(
      path: '/event/:id',
      builder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return EventDetailUserScreen(eventId: eventId);
      },
    ),






  ],
);




/*
import 'package:event_bnb/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'session/session_manager.dart';

GoRouter router(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        redirect: (context, state) async {
          final session = SessionManager();
          return await session.isLoggedIn() ? null : '/login';
        },
      ),
    ],
  );
}
*/
