// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:example/pages/masked_text_sample.dart';
import 'package:example/pages/money_masked_text_sample.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Masked Text Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(title: 'Extended Masked Text Demo'),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MaskedTextSample(),
                  ),
                ),
                child: const Text('Masked Controller'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MoneyMaskedTextSample(),
                  ),
                ),
                child: const Text('Money Masked Controller'),
              )
            ],
          ),
        ),
      );
}
