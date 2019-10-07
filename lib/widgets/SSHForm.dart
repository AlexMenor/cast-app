import 'package:cast/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SSHForm extends StatefulWidget {
  @override
  _SSHFormState createState() => _SSHFormState();
}

class _SSHFormState extends State<SSHForm> {
  final TextEditingController _address =
      TextEditingController(text: '192.168.0.');
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _port = TextEditingController(text: '22');
  bool isInit = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return CircularProgressIndicator();
        else {
          final prefs = snapshot.data;
          if (prefs.containsKey('ssh_address') && !isInit) {
            _address.text = prefs.getString('ssh_address');
            _name.text = prefs.getString('ssh_username');
            _password.text = prefs.getString('ssh_password');
            _port.text = prefs.getInt('ssh_port').toString();
          }
          isInit = true;
          return Container(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('IP Address'),
                  TextFormField(
                    controller: _address,
                    keyboardType: TextInputType.number,
                  ),
                  Text('Username'),
                  TextFormField(
                    controller: _name,
                  ),
                  Text('Password'),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                  ),
                  Text('Port'),
                  TextFormField(
                    controller: _port,
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RaisedButton.icon(
                        icon: Icon(Icons.save),
                        label: Text('Save'),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('ssh_address', _address.text);
                          prefs.setString('ssh_username', _name.text);
                          prefs.setString('ssh_password', _password.text);
                          prefs.setInt('ssh_port', int.parse(_port.text));
                          if (!Navigator.of(context).canPop())
                            Navigator.of(context).pushReplacementNamed(
                                HomeScreen.HomeScreenRoute);
                          else
                            Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
