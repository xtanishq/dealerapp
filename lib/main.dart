import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/notification/notification_bloc.dart';
import 'blocs/theme/theme_cubit.dart';
import 'data/services/api_service.dart';
import 'data/services/storage_service.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final storageService = StorageService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),

        BlocProvider(
          create: (context) =>
              AuthBloc(apiService: apiService, storageService: storageService),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
      ],

      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Dealer App',
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.grey[50],
            ),

            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.grey[900],
            ),

            themeMode: themeMode,

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
