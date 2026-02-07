import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lg_flutter_app/data/ssh_service.dart';
import 'package:lg_flutter_app/logic/cubit/lg_cubit.dart';
import 'package:lg_flutter_app/presentation/views/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (context) => SshService())],
      child: BlocProvider(
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
