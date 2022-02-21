import 'package:fanpage/common_widgets/form_submit_button.dart';
import 'package:fanpage/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


enum EmailSignInFormType { signIn, register }

class EmailSignInForm extends StatefulWidget {
  EmailSignInForm({@required this.auth});
  final AuthBase auth;


  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final CollectionReference _users = FirebaseFirestore.instance.collection('users');

  String get _email => _emailController.text;
  String get _password => _passwordController.text;
  EmailSignInFormType _formType = EmailSignInFormType.signIn;

  void _submit() async {
    try {
      if (_formType == EmailSignInFormType.signIn) {
        await widget.auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await widget.auth.createUserWithEmailAndPassword(_email, _password);
        final String fname = _firstNameController.text;
        final String lname = _lastNameController.text;
        if (fname != null && lname != null) {
          await _users.add({
            "first_name": fname,
            "last_name": lname,
            "created_on": DateTime
                .now()
                .millisecondsSinceEpoch,
            "role":"customer"
          });

          // Clear the text fields
          _emailController.text = '';
          _passwordController.text = '';
          _firstNameController.text = '';
          _lastNameController.text = '';
        }
      }
      Navigator.of(context).pop();
    } catch (e) {
      print(e.toString());
    }
  }

  void _toggleFormType() {
    setState(() {
      _formType = _formType == EmailSignInFormType.signIn ?
          EmailSignInFormType.register : EmailSignInFormType.signIn;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren() {
    final primaryText = _formType == EmailSignInFormType.signIn
        ? 'Sign in'
        : 'Create an account';
    final secondaryText = _formType == EmailSignInFormType.signIn
        ? 'Need an account? Register'
        : 'Have an account? Sign in';

    return [
      TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'test@test.com',
        ),
      ),
      SizedBox(height: 8.0),
      TextField(
        controller: _passwordController,
        decoration: const InputDecoration(
          labelText: 'Password',
        ),
        obscureText: true,
      ),
      SizedBox(height: 8.0),
      if(_formType == EmailSignInFormType.register) TextField(
          controller: _firstNameController,
          decoration: const InputDecoration(
          labelText: 'First Name',
      ),
        obscureText: true,
      ),
      const SizedBox(height: 8.0),
      if(_formType == EmailSignInFormType.register) TextField(
        controller: _lastNameController,
        decoration: const InputDecoration(
          labelText: 'Last Name',
        ),
        obscureText: true,
      ),
      FormSubmitButton(
        text: primaryText,
        onPressed: _submit,
      ),
      const SizedBox(height: 8.0),
      FlatButton(
        child: Text(secondaryText),
        onPressed: _toggleFormType,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _buildChildren(),
        ),
      ),
    );

  }
}
