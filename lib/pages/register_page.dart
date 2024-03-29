import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  static const String id = 'register_page';

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  // FirebaseAuth inisialisasi
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(),
            Hero(
              tag: 'Dicoding Chatting',
              child: Text(
                'Dicoding Chatting',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              'Create your account',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email',
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                hintText: 'Password',
              ),
            ),
            SizedBox(height: 24.0),
            MaterialButton(
              child: Text('Register'),
              color: Theme.of(context).primaryColor,
              textTheme: ButtonTextTheme.primary,
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  final email = _emailController.text;
                  final password = _passwordController.text;

                  final newUser = await _auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  if (newUser != null) {
                    Navigator.pop(context);
                  }

                } catch (e) {
                  final snackbar = SnackBar(
                    content: Text(e.toString()),
                  );
                  _scaffoldKey.currentState.showSnackBar(snackbar);
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
            TextButton(
              child: Text('Already have an account? Login'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
