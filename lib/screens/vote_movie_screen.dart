import 'dart:convert';
import 'package:final_project/utils/app_state.dart';
import 'package:final_project/utils/http_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class VoteMovieScreen extends StatefulWidget {
  const VoteMovieScreen({super.key});

  @override
  State<VoteMovieScreen> createState() => _VoteMovieScreenState();
}

class _VoteMovieScreenState extends State<VoteMovieScreen> {
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  List movies = [];
  int currentMovie = 0;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      final uri =
          'https://api.themoviedb.org/3/movie/popular?&page=$currentPage';
      final response = await http.get(
        Uri.parse(uri),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['results'] == null || data['results'].isEmpty) {
          throw Exception('No movies found in API response');
        }

        setState(() {
          movies.addAll(data['results']);
          currentPage++;
        });
      } else {
        if (kDebugMode) {
          print('Failed to load movies');
        }
        throw Exception('Failed to load movies: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load movies: $e'),
        ),
      );
    }
  }

  Future<void> _voteMovie(bool vote) async {
    final sessionId = Provider.of<AppState>(context, listen: false).sessionId;
    final movieId = movies[currentMovie]['id'];

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session ID not set. Please try again.'),
        ),
      );
      return;
    }

    try {
      final response = await HttpHelper.voteMovie(sessionId, movieId, vote);
      if (response['data']['match'] == true) {
        _showMatchDialog(movies[currentMovie]);
      } else {
        _loadNextMovie();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to vote: $e'),
        ),
      );
    }
  }

  void _showMatchDialog(movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('There goes a match!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
              ),
              const SizedBox(height: 16.0),
              Text(movie['title']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _loadNextMovie() {
    setState(() {
      currentMovie++;
      if (currentMovie >= movies.length) {
        _fetchMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final currentMovieData = movies[currentMovie];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Choice'),
        backgroundColor: Colors.blue,
      ),
      body: Dismissible(
        key: ValueKey(currentMovieData['id'].toString()),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          _voteMovie(direction == DismissDirection.startToEnd ? false : true);
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16.0),
          child: const Icon(
            Icons.thumb_down,
            color: Colors.black,
            size: 48.0,
          ),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16.0),
          child: const Icon(
            Icons.thumb_up,
            color: Colors.black,
            size: 48.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              currentMovieData['poster_path'] != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500${currentMovieData['poster_path']}')
                  : Image.asset('assets/images/poster-placeholder.png'),
              const SizedBox(height: 16.0),
              Text(
                currentMovieData['title'],
                style: const TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Release Date: ${currentMovieData['release_date']}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Rating: ${currentMovieData['vote_average']}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
