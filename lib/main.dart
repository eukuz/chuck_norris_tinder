import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';

import 'favs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Chuck Norris tinder'),
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
  int _counter = 0;
  int _rate = 0;
  final CardSwiperController controller = CardSwiperController();
  List<Joke> jokes = [Joke(
      joke: "Welcome to the chuck Norris tinder!\r\nSwipe right if you like the PUNCHline\r\n👊👊👊👊👊👊👊👊",
      id: '')];
  Uri url = Uri.parse('https://api.chucknorris.io/jokes/random');
  List<Container> cards = [];

  @override
  initState() {
    _addCard(jokes.last.joke);
    _addJoke();
    super.initState();
  }

  void _addCard(String joke) {
    cards.add(Container(
        alignment: Alignment.center,
        color: Colors.pink,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(flex: 2, child: NorrisFace(_counter, _rate)),
              Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        joke,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      )))
            ])));
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _rate++;
    });
  }

  Future<String> _addJoke() async {
    var response = await http.get(url);
    var text = json.decode(response.body)['value'];
    setState(() {
      jokes.add(Joke(id: json.decode(response.body)['id'], joke: text));
    });
    return text;
  }

  void _decrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _createNextCard() {
    _addCard(jokes.last.joke);
    if (cards.isNotEmpty) {
      cards.removeAt(0);
    }
    _addJoke();
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
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: Text(
                                '$_rate/$_counter of Chuck jokes were fun',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black45,
                                ),
                              )),
                          Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (_) =>
                                          const AlertDialog(
                                            title: Text('Developer info'),
                                            content: DeveloperInfo(),
                                          ));
                                    },
                                    icon: const Icon(Icons.account_circle),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => const FavoriteJokes(),
                                      );
                                    },
                                    icon: const Icon(Icons.star),
                                  )
                                ],
                              ))
                        ],
                      ),
                    )),
                Expanded(
                  flex: 10,
                  child: CardSwiper(
                    controller: controller,
                    cards: cards,
                    isVerticalSwipingEnabled: false,
                    onSwipe: _swipe,
                    padding: const EdgeInsets.all(24.0),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.swipeLeft();
                                },
                                child: const Icon(Icons.thumb_down),
                              ),
                              // This trailing comma makes auto-formatting nicer for build methods.
                            )),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.swipeRight();
                                },
                                child: const Icon(Icons.thumb_up),
                              ),
                            )),
                      ],
                    )),
              ],
            ),
          )),
    );
  }

  Future<void> _swipe(int index, CardSwiperDirection direction) async {
    _createNextCard();
    switch (direction) {
      case CardSwiperDirection.right:
        if (jokes.length > _counter && jokes[_counter].id.isNotEmpty ) {
          if (!await (jokeExists(jokes[_counter].id))) {
            FirebaseFirestore.instance.collection('jokes').add(
                {'joke': jokes[_counter].joke, 'id': jokes[_counter].id});
          }
        }

        _incrementCounter();
        break;
      default:
        _decrementCounter();
    }
  }

  Future<bool> jokeExists(String jokeId) async {
    final snapshot =
    await FirebaseFirestore.instance.collection('jokes').doc(jokeId).get();
    return snapshot.exists;
  }
}

class NorrisFace extends StatefulWidget {
  final int counter;
  final int rate;

  const NorrisFace(this.counter, this.rate, {super.key});

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
}

class DeveloperInfo extends StatelessWidget {
  const DeveloperInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 200,
      color: Colors.white,
      child: Column(
        children: [
          const Expanded(
            flex: 3,
            child: Text('Hello! my name is Eugene, thanks for using my app',
                style: TextStyle(fontSize: 25)),
          ),
          const Expanded(
              child: Text('Telegram @eukuz', style: TextStyle(fontSize: 20))),
          Expanded(
              child: InkWell(
                onTap: () =>
                    launchUrl(
                        Uri.parse(
                            'mailto:e.kuzyakhmetov@innopolis.university')),
                child: const Text(
                  'Or email me here !',
                  style: TextStyle(
                      decoration: TextDecoration.underline, color: Colors.blue),
                ),
              )),
        ],
      ),
    );
  }
}
