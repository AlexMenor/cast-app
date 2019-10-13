import 'package:ssh/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pi {
  // Singleton

  Pi._internal();
  static final Pi _pi = Pi._internal();

  factory Pi() {
    return _pi;
  }

  // SSH PREFERENCES
  String _ip;
  String _username;
  String _password;
  int _port;

  _updatePrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _ip = prefs.getString('ssh_address');
    _username = prefs.getString('ssh_username');
    _password = prefs.getString('ssh_password');
    _port = prefs.getInt('ssh_port');
  }

  SSHClient _getSSHClient() {
    return new SSHClient(
      host: _ip,
      username: _username,
      passwordOrKey: _password,
      port: _port,
    );
  }

  castVideo(String videoUrl) async {
    await _updatePrefs();
    final client = _getSSHClient();
    await client.connect();

    client.execute('omxplayer \$(youtube-dl -g $videoUrl -f best)');
  }
}
