import 'package:flutter/material.dart';
import 'package:mrdqa_tool/models/Supervision.dart';
import 'package:mrdqa_tool/pages/SupervisionPage.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';

import '../menus/MenuManager.dart';
import '../routes/Routes.dart';
import 'package:intl/intl.dart';

class SupervisionPlanningList extends StatefulWidget {
  static const String routeName = '/supervisions_planning_list';
  final ConfigManager configManager;

  SupervisionPlanningList(this.configManager);

  _SupervisionPlanningListState createState() => _SupervisionPlanningListState(this.configManager);
}

class _SupervisionPlanningListState extends State<SupervisionPlanningList> {
  final ConfigManager configManager;

  Routes routes;
  List<Supervision> _supervisions;

  _SupervisionPlanningListState(this.configManager);

  @override
  void initState() {
    super.initState();
    configManager.getSupervisionConfig('supervision').then((value) {
      if (value != null && value.length > 0) {
        setState(() {
          _supervisions = value;
        });
      } else {
        setState(() {
          _supervisions = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supervisions'),
      ),
      drawer: Drawer(
        child: new MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),
      body: _supervisions != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200, childAspectRatio: 3 / 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
                  itemCount: _supervisions.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SupervisionPage(this.configManager, _supervisions[index]),
                              ),
                            );
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: ListTile(
                            title: _supervisions[index].description != null ? Text(_supervisions[index].description) : Text('Empty'),
                            subtitle: _supervisions[index].period != null
                                ? Text(' ${DateFormat.yMMM('en_US').format(_supervisions[index].period)}')
                                : Text('Empty'),
                          ),
                          decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(15)),
                        ));
                  }),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.red,
                    ),
                    Text(
                        'This is a list of planned and past supervisions. Select a supervision to edit the details or click the “+” sign to create a new supervision.'),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SupervisionPage(this.configManager, null),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
