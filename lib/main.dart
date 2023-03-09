import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'Chuck Norris tinder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _rate = 0;
  bool _enableButtons = false;
  var _joke = '';
  Uri url = Uri.parse('https://api.chucknorris.io/jokes/random');

  @override
  initState() {
    super.initState();
    _nextJoke();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _rate++;
    });

    _nextJoke();
  }

  Future<void> _nextJoke() async {
    var response = await http.get(url);
    setState(() {
      _joke = json.decode(response.body)['value'];
      _enableButtons = true;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter++;
    });
    _nextJoke();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: SafeArea(
        bottom: true,
        top: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex:1,
                child: Text(
                  '$_rate/$_counter of Chuck Jokes were fun',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
            ),
            Expanded(
                flex:6,
                child: NorrisFace(_counter, _rate)
            ),
            Expanded(
                flex:4,
                child:  Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    style: Theme.of(context).textTheme.bodyMedium,
                    _joke,
                  ),
                )
            ),
            Expanded(
                flex:1,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _enableButtons ? _decrementCounter : null,
                        child: const Icon(Icons.thumb_down),
                      ),
                      // This trailing comma makes auto-formatting nicer for build methods.
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _enableButtons ? _incrementCounter : null,
                        child: const Icon(Icons.thumb_up),
                      ),
                    )
                    // This trailing comma makes auto-formatting nicer for build methods.
                  ],
                )
            ),
          ],
        ),
      )),
    );
  }
}

class NorrisFace extends StatefulWidget {
  final int counter;
  final int rate;

  const NorrisFace(this.counter, this.rate);

  @override
  State<StatefulWidget> createState() => _NorrisFaceState();
}

class _NorrisFaceState extends State<NorrisFace> {
  int getValue() {
    if (widget.counter == 0 || widget.rate / widget.counter >= 0.80) {
      return 80;
    } else if (widget.rate / widget.counter >= 0.60) {
      return 60;
    } else if (widget.rate / widget.counter >= 0.40) {
      return 40;
    } else if (widget.rate / widget.counter >= 0.20) {
      return 20;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/${getValue()}.webp');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
