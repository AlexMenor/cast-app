import 'package:flutter/widgets.dart';
import 'package:ssh/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

enum StreamCommand { PLAY, STOP }
enum PiState { LOADING, STOPPED, PLAYING, PAUSED }

class Pi with ChangeNotifier {
  // Singleton

  Pi._internal();
  static final Pi _pi = Pi._internal();

  factory Pi() {
    return _pi;
  }

  // SSH CLIENT
  SSHClient _client;

  //State
  PiState _state = PiState.STOPPED;
  Duration _videoDuration;
  Duration _timeElapsed;

  _updatePrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final ip = prefs.getString('ssh_address');
    final username = prefs.getString('ssh_username');
    final password = prefs.getString('ssh_password');
    final port = prefs.getInt('ssh_port');

    _client = new SSHClient(
      host: ip,
      username: username,
      passwordOrKey: password,
      port: port,
    );
  }

  PiState get state {
    return _state;
  }

  String get hoursDuration {
    return _videoDuration.inHours.toString();
  }

  String get minutesDuration {
    return (_videoDuration.inMinutes % 60).toString();
  }

  String get secondsDuration {
    return (_videoDuration.inSeconds % 60).toString();
  }

  String get hoursElapsed {
    return _timeElapsed.inHours.toString();
  }

  String get minutesElapsed {
    return (_timeElapsed.inHours % 60).toString();
  }

  String get secondsElapsed {
    return (_timeElapsed.inSeconds % 60).toString();
  }

  void _refreshElapsedTime(timer) {
    if (_state == PiState.PLAYING) {
      _timeElapsed += Duration(seconds: 1);
      notifyListeners();
    } else if (_state == PiState.STOPPED) timer.cancel();
  }

  void _setTimer() {
    _timeElapsed = Duration();
    Timer.periodic(Duration(seconds: 1), _refreshElapsedTime);
  }

  void _handleShellOutput(dynamic line) {
    print(line);
    RegExp regExpPlaying = new RegExp(r"^Video codec");
    RegExp regExpDuration =
        new RegExp(r"\bDuration:\s(\d{2}):(\d{2}):(\d{2})\.");

    if (regExpPlaying.hasMatch(line)) {
      _state = PiState.PLAYING;
      _setTimer();
    } else if (regExpDuration.hasMatch(line)) {
      final match = regExpDuration.firstMatch(line);

      final hours = int.parse(match[1]);
      final minutes = int.parse(match[2]);
      final seconds = int.parse(match[3]);
      _videoDuration =
          Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    notifyListeners();
  }

  _cleanConnection() async {
    // closeShell is not working at the moment
    await _client.disconnect();
  }

  startStreaming(String videoUrl) async {
    await _updatePrefs();
    await _client.connect();

    await _client.startShell(callback: _handleShellOutput);

    await _client
        .writeToShell('omxplayer -I \$(youtube-dl -g $videoUrl -f best)\n');
    _state = PiState.LOADING;
    notifyListeners();
  }

  sendCommand(StreamCommand cmd) async {
    if (_state != PiState.PLAYING && _state != PiState.PAUSED)
      throw ("There's no stream live");
    else {
      if (cmd == StreamCommand.PLAY) {
        await _client.writeToShell('p');
        _state = _state == PiState.PLAYING ? PiState.PAUSED : PiState.PLAYING;
      } else if (cmd == StreamCommand.STOP) {
        await _client.writeToShell('q');
        await _cleanConnection();
        _state = PiState.STOPPED;
      }
      notifyListeners();
    }
  }
}
