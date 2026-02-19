import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lg_flutter_app/data/ssh_service.dart';
import 'package:lg_flutter_app/logic/cubit/lg_cubit.dart';
import 'package:lg_flutter_app/presentation/views/home_screen.dart';

/// Entry point of the LG Controller Flutter application.
///
/// This app controls a Liquid Galaxy (LG) rig - a multi-screen display system
/// used for geographic visualization. The app connects to the LG master machine
/// via SSH and sends KML (Keyhole Markup Language) commands to control what
/// displays on the screens.
///
/// Architecture: Clean Architecture with BLoC pattern
/// - Data Layer: SSH service for network communication
/// - Logic Layer: Cubit for state management
/// - Presentation Layer: UI screens and widgets
void main() {
  runApp(const MyApp());
}

/// Root widget of the application.
///
/// Sets up dependency injection using RepositoryProvider and BlocProvider:
/// 1. Creates SshService as a singleton (lives throughout app lifecycle)
/// 2. Creates LgCubit that depends on SshService
///
/// This allows the SSH service to be shared across the app and makes
/// testing easier by allowing mock injection.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      // Provide SshService to the widget tree for dependency injection
      providers: [RepositoryProvider(create: (context) => SshService())],
      child: BlocProvider(
        // Create LgCubit with access to SshService from parent provider
        // context.read<SshService>() gets the service provided above
        create: (context) => LgCubit(context.read<SshService>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LG Controller',
          theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
