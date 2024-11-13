import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Screen/SigninScreen/SigninScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isRememberMeChecked = false;
  bool isButtonEnabled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_validateFields);
    emailController.addListener(_validateFields);
    phoneController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      isButtonEnabled = nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
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

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
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

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
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

  void createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: emailController.text)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('An account with this email already exists.')),
          );
        } else {
          await FirebaseFirestore.instance.collection('users').add({
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'password': passwordController.text,
            'rememberMe': isRememberMeChecked,
            'createdAt': FieldValue.serverTimestamp(),
          });

          nameController.clear();
          emailController.clear();
          phoneController.clear();
          passwordController.clear();
          setState(() {
            isRememberMeChecked = false;
            isButtonEnabled = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account created successfully!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
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
          "Sign Up",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Don't worry, only you can see your personal \ndata.No one else will be able to see it.",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: validateName,
                    ),
                    const SizedBox(height: 20),
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
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: validatePhone,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? createAccount : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        isButtonEnabled ? Colors.blue : Colors.grey[400],
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(isButtonEnabled ? 1.0 : 0.7),
                            fontWeight: FontWeight.bold,
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
