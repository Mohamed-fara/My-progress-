import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _email = "";
  String _password = "";
  bool _isLoginPage = true; // Changed default to true for login

  void _beginAuth() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      _submitToFirebase(_email, _password, _username);
    }
  }

  Future<void> _submitToFirebase(String email, String password, String username) async {
    final auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential;
      if (_isLoginPage) {
        userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
        print("UserCredential $userCredential");
        String uid=userCredential.user!.uid;
        print("UserCredential $uid");

        await FirebaseFirestore.instance.collection("user").doc(uid).set({''
            'username':username,
          'email':email,
        });
      }
      print("User ID: ${userCredential.user?.uid}");
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? "Authentication Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isLoginPage)
                TextFormField(
                  key: ValueKey("username"),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 4) {
                      return "Enter at least 4 characters";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value!;
                  },
                  decoration: InputDecoration(
                    hintText: "Username",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              SizedBox(height: 12),
              TextFormField(
                key: ValueKey("email"),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains("@")) {
                    return "Enter a valid email";
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                key: ValueKey("password"),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return "Enter at least 6 characters";
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 18),
              SizedBox(
                height: 46,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _beginAuth,
                  child: _isLoginPage ? Text("Login") : Text("Sign Up"),
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginPage = !_isLoginPage;
                  });
                },
                child: _isLoginPage
                    ? Text("Don't have an account? Sign Up")
                    : Text("Already have an account? Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}