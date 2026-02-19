import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lg_flutter_app/logic/cubit/lg_cubit.dart';
import 'package:lg_flutter_app/logic/cubit/lg_state.dart';
import 'package:lg_flutter_app/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main screen of the LG Controller app.
///
/// This screen provides the user interface for controlling a Liquid Galaxy
/// rig. It has two main sections:
///
/// 1. Action Buttons (top): Send Logo, Send Pyramid, Fly to Cairo, Clean
///    - These buttons are enabled only when connected to LG
///    - Each button triggers a specific action via the LgCubit
///
/// 2. Connection Form (bottom): IP, Port, Username, Password
///    - Pre-filled with default values from AppConstants
///    - "Save & Connect" button saves credentials and establishes SSH connection
///
/// State Management:
/// - Uses BlocListener to react to state changes (showing snackbars for errors/success)
/// - Uses BlocBuilder to conditionally enable/disable buttons based on connection state
/// - Text controllers hold connection form input values
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State class for HomeScreen.
///
/// Manages the lifecycle of TextEditingControllers and builds the UI.
/// The controllers are initialized with default values and disposed
/// when the screen is destroyed to prevent memory leaks.
class _HomeScreenState extends State<HomeScreen> {
  /// Controller for IP address input field.
  /// Initialized with default IP from AppConstants.
  final TextEditingController _ipController = TextEditingController(
    text: AppConstants.defaultIp,
  );

  /// Controller for port input field.
  /// Initialized with default port (22) from AppConstants.
  final TextEditingController _portController = TextEditingController(
    text: AppConstants.defaultPort.toString(),
  );

  /// Controller for username input field.
  /// Initialized with default user ('lg') from AppConstants.
  final TextEditingController _userController = TextEditingController(
    text: AppConstants.defaultUser,
  );

  /// Controller for password input field.
  /// Initialized with default password ('lg') from AppConstants.
  final TextEditingController _passController = TextEditingController(
    text: AppConstants.defaultPass,
  );

  /// Clean up controllers when the widget is destroyed.
  ///
  /// This prevents memory leaks by disposing all TextEditingControllers
  /// when the screen is removed from the widget tree.
  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /// Builds the main UI of the home screen.
  ///
  /// The layout consists of:
  /// - AppBar with title
  /// - BlocListener for handling state changes (snackbars)
  /// - Scrollable content with action buttons and connection form
  @override
  Widget build(BuildContext context) {
    // Get the LgCubit from the widget tree (provided by main.dart)
    final cubit = context.read<LgCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("LG Controller - Cairo")),
      body: BlocListener<LgCubit, LgState>(
        // Listen to state changes and show appropriate UI feedback
        listener: (context, state) {
          if (state is LgConnecting) {
            // Show loading indicator while connecting
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
            // Show success when connected
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Connected to LG'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is LgError) {
            // Show error message in red
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LgActionSuccess) {
            // Show success message for completed actions
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
              // Action Buttons Section
              // Uses BlocBuilder to enable/disable based on connection state
              BlocBuilder<LgCubit, LgState>(
                builder: (context, state) {
                  // Buttons are only enabled when connected
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

              // Connection Form Section
              // Card containing IP, Port, Username, Password fields
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
                      // IP and Port row
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
                      // Username and Password row
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
                              obscureText: true, // Hide password input
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Connect button saves credentials and initiates connection
                      ElevatedButton.icon(
                        icon: const Icon(Icons.link),
                        label: const Text('Save & Connect'),
                        onPressed: () async {
                          // Save connection settings to device storage
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
                          // Initiate SSH connection via cubit
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

  /// Helper method to build consistent action buttons.
  ///
  /// Creates a styled ElevatedButton with:
  /// - Fixed width of 180 pixels for uniform appearance
  /// - Icon and text label
  /// - Custom background color
  /// - Disabled state when onTap is null (not connected)
  ///
  /// [text] - Button label text
  /// [icon] - Icon to display before text
  /// [color] - Background color of the button
  /// [onTap] - Callback when pressed (null = disabled)
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
