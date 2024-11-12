import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Screen/HomeScreen/HomeScreen.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isRememberMeChecked = false;
  bool isButtonEnabled = false;
  bool isLoading = false; // New variable to show loading indicator

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      isButtonEnabled = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void toggleRememberMe() {
    setState(() {
      isRememberMeChecked = !isRememberMeChecked;
    });
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Show loading
      });

      try {
        // Query Firestore for the user document with the matching email
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: emailController.text)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Check if the password matches
          final userDoc = querySnapshot.docs.first;
          final storedPassword = userDoc['password'];

          if (storedPassword == passwordController.text) {
            // Credentials are correct, navigate to the HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with actual HomeScreen
            );
          } else {
            // Show error if password does not match
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Incorrect password.')),
            );
          }
        } else {
          // Show error if no user is found with the email
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No account found with this email.')),
          );
        }
      } catch (e) {
        // Handle Firestore errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in: $e')),
        );
      } finally {
        setState(() {
          isLoading = false; // Hide loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Sign In",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Please enter your email & password to sign in",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email Input
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 20),

                  // Password Input with Visibility Toggle
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: togglePasswordVisibility,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: validatePassword,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Remember Me Checkbox
            Row(
              children: [
                Checkbox(
                  value: isRememberMeChecked,
                  onChanged: (value) => toggleRememberMe(),
                ),
                const Text("Remember me"),
              ],
            ),
            const SizedBox(height: 30),

            // Continue Button with Loader
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonEnabled && !isLoading ? signIn : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: isButtonEnabled ? Colors.blue : Colors.grey[400],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white.withOpacity(isButtonEnabled ? 1.0 : 0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
