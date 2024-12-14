import 'package:final_project/utils/app_state.dart';
import 'package:final_project/utils/http_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'vote_movie_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  Future<void> _submitCode() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    String code = _controller.text;
    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;

    if (deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device ID not set. Please try again.'),
        ),
      );
      return;
    }

    try {
      final response = await HttpHelper.joinSession(deviceId, int.parse(code));
      if (response.containsKey('data') &&
          response['data'].containsKey('session_id')) {
        String sessionId = response['data']['session_id'];
        Provider.of<AppState>(context, listen: false).setSessionId(sessionId);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VoteMovieScreen(),
          ),
        );
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join session: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the code shared by your friend to join the session',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter 4-digit code',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the code';
                  } else if (value.length != 4) {
                    return 'Code must be 4 digits';
                  } else if (int.tryParse(value) == null) {
                    return 'Code must be a number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: _submitCode,
                  child: Text(
                    'Begin voting',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
