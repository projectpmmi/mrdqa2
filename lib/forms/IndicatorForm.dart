import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';

class IndicatorForm extends StatefulWidget {
  static String routeName = '/indicators/add_indicator';

  @override
  _IndicatorFormState createState() => _IndicatorFormState();
}

class _IndicatorFormState extends State<IndicatorForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adding Indicator"),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    final _formKey = GlobalKey<FormState>();
    final List<Map<String, dynamic>> _items = [
      {
        'value': "type01",
        'label': 'Type 1',
      },
      {
        'value': "type2",
        'label': 'Type 2',
      },
      {
        'value': "type3",
        'label': 'Type 3',
      },
    ];
    return Column(children: [
      Padding(
          padding: EdgeInsets.all(8.0),
          child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                // Add TextFormFields and ElevatedButton here.
                TextFormField(
                  decoration: InputDecoration(labelText: 'Indicator id'),
                  autofocus: true,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'The Indicator should have an id';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Indicator name'),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'The Indicator should have a name';
                    }
                    return null;
                  },
                ),
                SelectFormField(
                  type: SelectFormFieldType.dropdown,
                  // or can be dialog
                  icon: Icon(Icons.local_hospital),
                  labelText: 'Indicator type',
                  items: _items,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'The Indicator should have a Type';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, otherwise false.
                    if (_formKey.currentState.validate()) {
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Creating Indicator')));
                    }
                  },
                  child: Text('Create'),
                ),
              ])))
    ]);
  }
}
