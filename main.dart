import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:better_player/better_player.dart';

void main() {
  runApp(const UDPVideoPlayer());
}

class UDPVideoPlayer extends StatefulWidget {
  const UDPVideoPlayer({
    super.key,
  });
  @override
  State<UDPVideoPlayer> createState() => _UDPVideoPlayerState();
}

class _UDPVideoPlayerState extends State<UDPVideoPlayer> {
  late RawDatagramSocket _socket;
  late BetterPlayerController _playerController;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888);

    _socket.listen((event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = _socket.receive();
        var packetData = datagram?.data;
        setState(() {
          _playerController = BetterPlayerController(
            const BetterPlayerConfiguration(
              autoPlay: true,
              aspectRatio: 16 / 9,
            ),
            betterPlayerDataSource: BetterPlayerDataSource.memory(
              packetData ?? List.empty(),
              //videoFormat: BetterPlayerVideoFormat.hls,
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _playerController.dispose();
    _socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('UDP Video Player'),
        ),
        body: !_playerController.isNull
            ? AspectRatio(
                aspectRatio:
                    _playerController.videoPlayerController!.value.aspectRatio,
                child: BetterPlayer(controller: _playerController),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
