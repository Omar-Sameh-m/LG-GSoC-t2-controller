import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lg_flutter_app/logic/cubit/lg_cubit.dart';
import 'package:lg_flutter_app/logic/cubit/lg_state.dart';
import 'package:lg_flutter_app/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ipController = TextEditingController(
    text: AppConstants.defaultIp,
  );
  final TextEditingController _portController = TextEditingController(
    text: AppConstants.defaultPort.toString(),
  );
  final TextEditingController _userController = TextEditingController(
    text: AppConstants.defaultUser,
  );
  final TextEditingController _passController = TextEditingController(
    text: AppConstants.defaultPass,
  );

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LgCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("LG Controller - Cairo")),
      body: BlocListener<LgCubit, LgState>(
        listener: (context, state) {
          if (state is LgConnecting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: Text('Connecting to LG...')),
                  ],
                ),
                duration: const Duration(seconds: 10),
              ),
            );
          } else if (state is LgConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Connected to LG'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is LgError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LgActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlocBuilder<LgCubit, LgState>(
                builder: (context, state) {
                  final connected = state is LgConnected;
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildBtn(
                        "Send LG Logo",
                        Icons.image,
                        Colors.blue,
                        connected ? () => cubit.sendLogos() : null,
                      ),
                      _buildBtn(
                        "Send Pyramid (Cairo)",
                        Icons.account_balance,
                        Colors.orange,
                        connected ? () => cubit.sendPyramid() : null,
                      ),
                      _buildBtn(
                        "Fly to Home (Cairo)",
                        Icons.flight,
                        Colors.indigo,
                        connected ? () => cubit.flyToCairo() : null,
                      ),
                      _buildBtn(
                        "Clean Logos",
                        Icons.cleaning_services,
                        Colors.grey,
                        connected ? () => cubit.cleanLogos() : null,
                      ),
                      _buildBtn(
                        "Clean KMLs",
                        Icons.delete,
                        Colors.red,
                        connected ? () => cubit.cleanKml() : null,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Connection inputs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Connection (IP / Port / User / Pass)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ipController,
                              decoration: const InputDecoration(
                                labelText: 'IP',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 110,
                            child: TextField(
                              controller: _portController,
                              decoration: const InputDecoration(
                                labelText: 'Port',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _userController,
                              decoration: const InputDecoration(
                                labelText: 'User',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _passController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.link),
                        label: const Text('Save & Connect'),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                            'ip',
                            _ipController.text.trim(),
                          );
                          await prefs.setString(
                            'port',
                            _portController.text.trim(),
                          );
                          await prefs.setString(
                            'username',
                            _userController.text.trim(),
                          );
                          await prefs.setString(
                            'password',
                            _passController.text,
                          );
                          cubit.connectToLg();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(
    String text,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return SizedBox(
      width: 180,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(text, style: const TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onTap,
      ),
    );
  }
}
