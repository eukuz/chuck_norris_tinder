import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteJokes extends StatelessWidget {
  const FavoriteJokes({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Favorite Jokes'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400.0,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('jokes').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final jokes = snapshot.data!.docs
                .map((doc) => Joke.fromSnapshot(doc))
                .toList();
            if (jokes.isEmpty) {
              return const Center(child: Text('No favorite jokes yet.'));
            }
            return ListView.separated(
              itemCount: jokes.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(jokes[index].joke),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Joke'),
                          content: const Text(
                              'Are you sure you want to delete this joke?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('jokes')
                                    .doc(jokes[index].id)
                                    .delete();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class Joke {
  final String id;
  final String joke;

  Joke({required this.id, required this.joke});

  factory Joke.fromSnapshot(DocumentSnapshot snapshot) {
    return Joke(
      id: snapshot.id,
      joke: (snapshot.data() as Map<String, dynamic>)['joke'] ?? '',
    );
  }
}
