import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'worker_registration_screen.dart';
import 'client_dashboard.dart';
import 'worker_dashboard.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTermsDialog();
    });
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Terms of Service"),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome to SHAGHLNY",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text("By using this app, you agree to:"),
                SizedBox(height: 8),
                Text("• Provide accurate information"),
                Text("• Respect other users"),
                Text("• Pay for services rendered"),
                Text("• Follow safety guidelines"),
                SizedBox(height: 12),
                Text("Please read our full Terms of Service and Privacy Policy."),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text("Decline", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _termsAccepted = true;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text("Accept"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    if (!_termsAccepted) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_repair_service,
                size: 80,
                color: Color(0xFF2196F3),
              ),
              const SizedBox(height: 24),
              const Text(
                "Welcome to SHAGHLNY",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Connect with trusted service providers",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final error = await auth.signInWithGoogle();
                        if (error != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(error)));
                        } else {
                          _routeUser(context);
                        }
                      },
                icon: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login),
                label: const Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final error = await auth.signInAsGuest();
                        if (error != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(error)));
                        } else {
                          _routeUser(context);
                        }
                      },
                icon: const Icon(Icons.person_outline),
                label: const Text("Continue as Guest"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                "Are you a service provider?",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _showWorkerLoginDialog(context);
                    },
                    child: const Text(
                      "Worker Sign In",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text("or"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerRegistrationScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkerLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Worker Sign In"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          try {
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                            
                            // ADDED: Load worker data from Firestore
                            final auth = Provider.of<AuthService>(context, listen: false);
                            await auth.refreshUserData();
                            
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            _routeUser(context);
                          } on FirebaseAuthException catch (e) {
                            String message = "Login failed";
                            if (e.code == 'user-not-found') {
                              message = "No account found with this email";
                            } else if (e.code == 'wrong-password') {
                              message = "Wrong password";
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                          setState(() => isLoading = false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Sign In"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _routeUser(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    if (auth.userModel?.role == "worker") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WorkerDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientDashboard()),
      );
    }
  }
}