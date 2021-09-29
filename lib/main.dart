import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final stateStream = StreamController<ScreenState>.broadcast();
    stateStream.stream.listen((event) {
      print("New state -> $event");
    });
    return MaterialApp(
      title: 'Dice Rolling',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'MyDice', states: stateStream),
    );
  }
}

const _dices = [
  Dice(4),
  Dice(6),
  Dice(8),
  Dice(10),
  Dice(12),
  Dice(20),
];

class MyHomePage extends StatelessWidget {
  MyHomePage({
    Key? key,
    required this.title,
    required this.states,
  }) : super(key: key);

  final String title;
  final StreamController<ScreenState> states;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: _dices
                  .map(
                    (dice) => OutlinedButton(
                      onPressed: () =>
                          states.sink.add(ScreenState(Selected(dice), 0)),
                      child: Text(dice.max.toString()),
                    ),
                  )
                  .toList(),
            ),
            StreamBuilder<ScreenState>(
              stream: states.stream,
              initialData: ScreenState.initial(),
              builder: (context, snapshot) {
                final data = snapshot.data;

                if (data != null) {
                  return Column(
                    children: [
                      Text(
                        '${data.number}',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      if (data.dice is Selected)
                        OutlinedButton(
                          onPressed: () => states.sink.add(data.roll()),
                          child: Text("Roll the dice"),
                        ),
                    ],
                  );
                }

                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}

abstract class DiceState {
  final Dice? dice;

  const DiceState(this.dice);

  @override
  String toString() {
    return "$runtimeType";
  }
}

class Empty extends DiceState {
  const Empty() : super(null);
}

class Selected extends DiceState {
  const Selected(Dice dice) : super(dice);

  int roll() {
    return Random().nextInt(dice!.max - 1) + 1;
  }

  @override
  String toString() {
    return "$runtimeType($dice)";
  }
}

class Dice {
  final int max;

  const Dice(this.max);

  @override
  String toString() {
    return "$runtimeType($max)";
  }
}

class ScreenState {
  final DiceState dice;
  final int number;

  ScreenState(this.dice, this.number);

  ScreenState.initial() : this(Empty(), 0);

  ScreenState roll() {
    final dice = this.dice;
    if (dice is! Selected) throw Exception("Incosistent state");
    return ScreenState(dice, dice.roll());
  }

  @override
  String toString() {
    return "$runtimeType($dice, $number)";
  }
}
