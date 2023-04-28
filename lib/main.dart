import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _images = <String>[];
  final String? clientID = dotenv.env['API_KEY'];

  Future<void> _getImages({String? search}) async {
    final String query = search ?? 'travel';
    final Uri uri = Uri.parse('https://api.unsplash.com/search/photos?query=$query');

    final Request request = Request('GET', uri);
    final Map<String, String> headers = <String, String>{'Accept-Version': 'v1'};
    request.headers.addAll(headers);
    final Response response = await get(uri, headers: <String, String>{'Authorization': 'Client-ID $clientID'});

    final Map<String, dynamic> map = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> imagesList = map['results'] as List<dynamic>;

    setState(() {
      for (int i = 0; i < imagesList.length; i++) {
        final Map<String, dynamic> image = imagesList[i] as Map<String, dynamic>;
        final Map<String, dynamic> imageUrl = image['urls'] as Map<String, dynamic>;
        _images.add(imageUrl['regular'] as String);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Searcher App'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _images.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == _images.length - 1 ? 0 : 16),
            child: Image.network(
              _images[index],
              height: 0.4 * MediaQuery.of(context).size.height,
              width: 0.2 * MediaQuery.of(context).size.width,
              fit: BoxFit.fitHeight,
            ),
          );
        },
      ),
    );
  }
}
