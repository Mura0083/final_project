import 'package:final_project/utils/app_state.dart';
import 'package:final_project/utils/http_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vote_movie_screen.dart';

const double kDefaultPadding = 8.0;

class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({super.key});

  @override
  State<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  String code = '';

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Share Code',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48.0),
              Text(
                code,
                style: const TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Share this code with your friends to start the session',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Roboto',
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoteMovieScreen(),
                    ),
                  );
                },
                child: Text(
                  'Begin Voting',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startSession() async {
    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;
    if (deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device ID not set. Cannot start session.'),
        ),
      );
      return;
    }

    try {
      final response = await HttpHelper.startSession(deviceId);
      final sessionId = response['data']['session_id'];
      final codeValue = response['data']['code'];

      setState(() {
        code = codeValue;
      });
      Provider.of<AppState>(context, listen: false).setSessionId(sessionId);
      if (kDebugMode) {
        print('Session ID set: $sessionId');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start session. Please try again.'),
        ),
      );
    }
  }
}
