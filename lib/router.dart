import 'package:event_bnb/screens/email_verification_screen.dart';
import 'package:event_bnb/screens/event_detail_user_screen.dart';
import 'package:event_bnb/screens/forgot_password_screen.dart';
import 'package:event_bnb/screens/home_screen.dart';
import 'package:event_bnb/screens/login_screen.dart';
import 'package:event_bnb/screens/profile_screen.dart';
import 'package:event_bnb/screens/reset_password_screen.dart';
import 'package:event_bnb/screens/signup_screen.dart';
import 'package:event_bnb/screens/splash_screen.dart';
import 'package:event_bnb/screens/user_event_sections.dart';
import 'package:event_bnb/session/session_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:event_bnb/screens/event_detail_organizer_screen.dart';

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
    GoRoute(
      path: '/event-organizer/:id',
      builder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return EventDetailOrganizerScreen(eventId: eventId);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/my-events',
      builder: (_, __) => const MyEventsScreen(),
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final email = data['email'] as String;
        final password = data['password'] as String;
        return EmailVerificationScreen(email: email, password: password);
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
