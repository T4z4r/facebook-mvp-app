import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/friend_provider.dart';
import 'providers/message_provider.dart';
import 'providers/group_provider.dart';
import 'screens.dart/home_screen.dart';
import 'screens.dart/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook MVP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return FutureBuilder(
            future: authProvider.tryAutoLogin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return authProvider.user != null ? HomeScreen() : LoginScreen();
            },
          );
        },
      ),
    );
  }
}
