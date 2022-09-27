import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final receivePort = ReceivePort();
          final isolate = await Isolate.spawn(countNum, receivePort.sendPort);
          Stream subscription = receivePort.asBroadcastStream();

          /// send data to function
          SendPort newIsolateSendPort = await subscription.first as SendPort;
          newIsolateSendPort.send("did you get this?");

          subscription.listen((message) {
            log(message);
            receivePort.close();
            isolate.kill();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void countNum(SendPort mainIsolateSendPort) {
  /// new isolate
  final receiveIsolate = ReceivePort();

  mainIsolateSendPort.send(receiveIsolate.sendPort);
  receiveIsolate.listen((message) {
    log(message);
  });
  var counting = 0;
  for (var i = 1; i <= 1000000000; i++) {
    counting = i;
  }
  mainIsolateSendPort.send('$counting! Ready or not, here I come!');
}