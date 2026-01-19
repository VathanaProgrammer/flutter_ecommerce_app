import 'package:ecommersflutter_new/providers/cart_provider.dart';
import 'package:ecommersflutter_new/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/user_provider.dart';
import './screens/profiles/profile_screen.dart';
import './screens/home/home.dart';
import 'screens/auth/login.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const MyApp());
}

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => LoginScreen(),
  '/profile': (context) => ProfileScreen(),
  '/home': (context) => HomeScreen()
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider())
      ],
      child: MaterialApp(
        scaffoldMessengerKey: messengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Luxeshop',
        theme: ThemeData(
          primaryColor: Colors.orange,
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        routes: routes,

        initialRoute: '/home',
      ),
    );
  }
}
