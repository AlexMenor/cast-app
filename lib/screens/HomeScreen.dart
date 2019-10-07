import 'package:flutter/material.dart';
import 'package:cast/screens/SetSSHScreen.dart';

class HomeScreen extends StatelessWidget {
  static const HomeScreenRoute = '/Home';
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
        child: Text('hey'),
      ),
    );
  }
}
