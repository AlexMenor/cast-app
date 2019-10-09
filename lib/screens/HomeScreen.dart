import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cast/screens/SetSSHScreen.dart';

class HomeScreen extends StatefulWidget {
  static const HomeScreenRoute = '/Home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const platform = const MethodChannel('app.channel.shared.data');
  String dataShared = 'noData';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getSharedText();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) getSharedText();
  }

  getSharedText() async {
    final sharedData = await platform.invokeMethod('getSharedText');
    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
      });
    }
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
      body: Center(
        child: Text(dataShared),
      ),
    );
  }
}
