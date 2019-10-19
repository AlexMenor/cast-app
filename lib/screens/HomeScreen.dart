import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cast/screens/SetSSHScreen.dart';
import 'package:cast/widgets/VideoThumbnail.dart';
import 'package:cast/pi.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const HomeScreenRoute = '/Home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const platform = const MethodChannel('app.channel.shared.data');
  String _extractedUrl;
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
      _extractedUrl = _extractUrl(sharedData);
      pi.startStreaming(_extractedUrl);
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  VideoThumbnail(_extractedUrl),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          children: <Widget>[
                            if (!pi.isLiveStreaming)
                              Container(
                                margin: const EdgeInsets.only(bottom: 28.0),
                                child:
                                    Text(pi.timeElapsed + ' / ' + pi.duration),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                if (!pi.isLiveStreaming)
                                  IconButton(
                                    icon: Icon(Icons.replay_30),
                                    onPressed: () {
                                      pi.sendCommand(StreamCommand.BACKWARD);
                                    },
                                  ),
                                FloatingActionButton(
                                  splashColor: Theme.of(context).primaryColor,
                                  child: Icon(pi.state == PiState.PLAYING
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                  onPressed: () {
                                    pi.sendCommand(StreamCommand.PLAY);
                                  },
                                ),
                                if (!pi.isLiveStreaming)
                                  IconButton(
                                    icon: Icon(Icons.forward_30),
                                    onPressed: () {
                                      pi.sendCommand(StreamCommand.FORWARD);
                                    },
                                  ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.stop),
                                    color: Theme.of(context).errorColor,
                                    onPressed: () {
                                      pi.sendCommand(StreamCommand.STOP);
                                    },
                                  ),
                                  Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.volume_down),
                                        onPressed: () {
                                          pi.sendCommand(
                                              StreamCommand.VOLUMEDOWN);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.volume_up),
                                        onPressed: () {
                                          pi.sendCommand(
                                              StreamCommand.VOLUMEUP);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
