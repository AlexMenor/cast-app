import 'package:cast/screens/SetSSHScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cast/screens/HomeScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? MaterialApp(
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: snapshot.data.containsKey('ssh_address')
                    ? HomeScreen()
                    : SetSSHScreen(),
                routes: {
                  HomeScreen.HomeScreenRoute: (ctx) => HomeScreen(),
                  SetSSHScreen.SetSSHScreenRoute: (ctx) => SetSSHScreen(),
                },
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }
}
