import 'package:flutter/widgets.dart';
import 'package:ssh/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _handleShellOutput(dynamic line) {
    print(line);
    RegExp regExp = new RegExp(r"^Video codec");

    if (regExp.hasMatch(line)) {
      _state = PiState.PLAYING;
      notifyListeners();
    }
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
        .writeToShell('omxplayer \$(youtube-dl -g $videoUrl -f best)\n');
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
