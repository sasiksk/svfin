import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:svf/finance_provider.dart';
import 'package:svf/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(
    ProviderScope(
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Times New Roman',
        scaffoldBackgroundColor: Color.fromARGB(255, 243, 242, 241),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: isFirstLaunch ? const SplashScreen() : const HomeScreen(),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 241, 245, 245),
              Color.fromARGB(255, 95, 109, 101)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.2).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Image.asset(
                  'assets/app_icon.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Finance Name',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 226, 140, 12),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 91, 180, 136),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    prefixIcon:
                        const Icon(Icons.account_balance, color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25), // Rounded edges
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blueAccent,
                        Colors.blue,
                        Colors.lightBlueAccent
                      ],
                      stops: [0.2, 0.5, 0.9], // Creates the layered effect
                    ),
                  ),
                  padding: const EdgeInsets.all(2), // Border width
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue, // Text color
                      backgroundColor: Color.fromARGB(
                          255, 107, 241, 148), // Button background
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(25), // Matches container
                      ),
                      elevation: 5, // Adds shadow effect
                    ),
                    onPressed: () async {
                      if (_controller.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Color.fromARGB(255, 210, 240, 223),
                            title: const Text('Message'),
                            content:
                                const Text('Kindly Enter Your Finance Name',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Times New Roman',
                                    )),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('isFirstLaunch', false);
                        ref
                            .read(financeProvider.notifier)
                            .saveFinanceName(_controller.text);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      }
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Times New Roman',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
