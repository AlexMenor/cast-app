import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cast/screens/SetSSHScreen.dart';
import 'package:cast/pi.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const HomeScreenRoute = '/Home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const platform = const MethodChannel('app.channel.shared.data');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSharedData();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkSharedData();
  }

  _checkSharedData() async {
    final sharedData = await platform.invokeMethod('getSharedText');
    if (sharedData != null) {
      final pi = Pi();
      final urlExtracted = _extractUrl(sharedData);
      pi.startStreaming(urlExtracted);
    }
  }

  String _extractUrl(String str) {
    RegExp regExp = new RegExp(r"(http.+)(\s|$)");

    final match = regExp.firstMatch(str);
    return match.group(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cast'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.laptop),
            onPressed: () {
              Navigator.of(context).pushNamed(SetSSHScreen.SetSSHScreenRoute);
            },
          )
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: Pi(),
        child: Consumer<Pi>(
          builder: (context, pi, _) {
            if (pi.state == PiState.LOADING)
              return Center(child: CircularProgressIndicator());
            else if (pi.state == PiState.STOPPED)
              return Center(child: Text('Share a video to this app to start'));
            else {
              return Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(pi.state == PiState.PLAYING
                            ? Icons.pause
                            : Icons.play_arrow),
                        onPressed: () {
                          pi.sendCommand(StreamCommand.PLAY);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () {
                          pi.sendCommand(StreamCommand.STOP);
                        },
                      )
                    ],
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
