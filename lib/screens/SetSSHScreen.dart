import 'package:flutter/material.dart';
import 'package:cast/widgets/SSHForm.dart';

class SetSSHScreen extends StatelessWidget {
  static const SetSSHScreenRoute = '/SetSSH';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración de SSH'),
      ),
      body: Card(
          child: Container(
            padding: EdgeInsets.all(20),
            child: SSHForm(),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.all(20)),
    );
  }
}
