import 'package:flutter/material.dart';

class SupervisionForm extends StatefulWidget {
  static String routeName = '/supervisions/add';

  @override
  _SupervisionFormState createState() => _SupervisionFormState();
}

class _SupervisionFormState extends State<SupervisionForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adding supervision"),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          },
        ),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    final _formKey = GlobalKey<FormState>();
    return Container(
        padding: EdgeInsets.all(8.0),
          child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                // Add TextFormFields and ElevatedButton here.
                TextFormField(
                  decoration: InputDecoration(labelText: 'Designation'),
                  autofocus: true,
                  maxLength: 70,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'The Supervision should have a designation';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Period'),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'The Supervision should have a period';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, otherwise false.
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        // Test if selections are saved.
                        // Navigator.pushReplacementNamed(
                        //     context, Routes().supervisions);
                       // Navigator.pop(context);
                      });
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Fill details')));
                    }
                  },
                  child: Text('Validate'),
                ),
              ])),
    );
  }
}
