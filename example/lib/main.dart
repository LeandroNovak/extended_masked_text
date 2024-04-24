// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:example/pages/masked_text_sample.dart';
import 'package:example/pages/money_masked_text_sample.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  final String title;
  const MyHomePage({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
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
                    builder: (context) => MaskedTextSample(),
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
