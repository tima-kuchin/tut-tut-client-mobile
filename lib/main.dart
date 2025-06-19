import 'package:flutter/material.dart';
import 'package:turtut_dev/screens/tours/edit_route_info_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/news/news_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/avatar_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/profile/favorites_screen.dart';
import 'screens/tours/tours_screen.dart';
import 'screens/tours/my_tours_screen.dart';
import 'screens/tours/create_route_form_screen.dart';
import 'screens/tours/create_route_map_screen.dart';
import 'screens/tours/route_detail_screen.dart';
import 'screens/tours/route_map_viewer_screen.dart';

void main() {
  runApp(const TurTutApp());
}

class TurTutApp extends StatelessWidget {
  const TurTutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurTut',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        '/login'           : (_) => const LoginScreen(),
        '/register'        : (_) => const RegisterScreen(),
        '/forgot'          : (_) => const ForgotPasswordScreen(),
        '/home'            : (_) => const HomeScreen(),
        '/tours'           : (_) => const ToursScreen(),
        '/myTours'         : (_) => const MyToursScreen(),
        '/create_route'    : (_) => const CreateRouteFormScreen(),
        '/route_map'       : (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments as String;
          return EditRouteMapScreen(routeId: args);
        },
        '/edit_route_info': (ctx) {
          final id = ModalRoute.of(ctx)!.settings.arguments as String;
          return EditRouteInfoScreen(routeId: id);
        },
        '/route_detail'    : (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments as String;
          return RouteDetailScreen(routeId: args);
        },
        '/edit_route_map': (context) {
          final routeId = ModalRoute.of(context)!.settings.arguments as String;
          return EditRouteMapScreen(routeId: routeId);
        },
        '/route_map_viewer': (context) {
          final routeId = ModalRoute.of(context)!.settings.arguments as String;
          return RouteMapViewerScreen(routeId: routeId);
        },
        '/newsDetail'      : (_) => const NewsDetailScreen(
          title: '',
          imagePath: '',
          author: '',
          date: '',
          content: '',
          tags: [],
        ),
        '/profile'         : (_) => const ProfileScreen(),
        '/edit_profile'    : (_) => const EditProfileScreen(),
        '/edit_avatar'     : (_) => const AvatarScreen(),
        '/change_password' : (_) => const ChangePasswordScreen(),
        '/favorites'       : (_) => const FavoritesScreen(),
      },
    );
  }
}
