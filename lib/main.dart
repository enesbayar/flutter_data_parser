import 'package:data_parser/service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'model/comment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Dio _dio = Dio(
      BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com/comments'));
  late final APIClient _apiClient = APIClient(_dio);

  final List<Comment> comments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: comments.isNotEmpty
          ? ListView.separated(
              shrinkWrap: true,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 32,
                      ),
                      Text(
                        comments[index].email ?? '',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        comments[index].body ?? '',
                      )
                    ],
                  ),
                );
              }),
              separatorBuilder: (context, index) => const SizedBox(
                height: 20,
              ),
              itemCount: comments.length,
            )
          : const SizedBox(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        tooltip: 'fetch data',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _fetchData() async {
    comments.clear();
    final response = await _apiClient.getComments(isolate: true);
    final result = response?.result;
    if (result != null) {
      comments.addAll(result);
      setState(() {});
    }
  }
}
