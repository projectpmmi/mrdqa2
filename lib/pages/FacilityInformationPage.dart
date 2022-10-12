import 'package:flutter/material.dart';
import 'package:mrdqa_tool/menus/MenuManager.dart';
import 'package:mrdqa_tool/routes/Routes.dart';
import 'package:mrdqa_tool/services/ConfigManager.dart';
import 'package:mrdqa_tool/services/DhisManager.dart';
import 'package:mrdqa_tool/models/Facility.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/cupertino.dart';

class FacilityInformationPage extends StatefulWidget {
  static String routeName = '/facility_information';
  final ConfigManager configManager;

  FacilityInformationPage(this.configManager);

  @override
  _FacilityInformationPageState createState() =>
      _FacilityInformationPageState(this.configManager);
}

class _FacilityInformationPageState extends State<FacilityInformationPage> {

  DhisManager _dhisManager;
  String _configType;
  final ConfigManager configManager;

  List<Facility> facilities = [
    Facility(
        id: 1,
        name: 'Diao Health Center',
        countryId: 'guinea',
        townVillage: 'Timbi madina',
        district: 'Pita',
        region: 'Mamou',
        facilityTypeId: 1,
        phone: '623909413',
        email: 'exemple@gmail.come'),
    Facility(
        id: 2,
        name: 'Hafia Health Center',
        countryId: 'guinea',
        townVillage: 'Hafia',
        district: 'Labe',
        region: 'Labe',
        facilityTypeId: 2,
        phone: '623909413',
        email: 'exemple@gmail.come'),
    Facility(
        id: 3,
        name: 'Dixinn Health Center',
        countryId: 'guinea',
        townVillage: 'Dixinn',
        district: 'Dixinn',
        region: 'Conakry',
        facilityTypeId: 1,
        phone: '623909413',
        email: 'exemple@gmail.come'),
    Facility(
        id: 4,
        name: 'Diountou Health Center',
        countryId: 'guinea',
        townVillage: 'Diountou',
        district: 'Lelouma',
        region: 'Labe',
        facilityTypeId: 1,
        phone: '623909413',
        email: 'exemple@gmail.come'),
  ];

  _FacilityInformationPageState(this.configManager);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Facilities"),
      ),
      drawer: Drawer(
        child: MenuManager(context, Routes(), this.configManager).getDrawer(),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: _facilitiesView(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _searchFacilities(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _facilitiesView() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(label: Text('Id')),
              DataColumn(label: Text('Name')),
            ],
            rows: facilities
                .map((facility) => DataRow(cells: <DataCell>[
              DataCell(Container(
                  width: 60, //SET width
                  child: Text(facility.id.toString()))),
              DataCell(Container(child: Text(facility.name))),
            ]))
                .toList(),
          )),
    );
  }

  Future<void> _searchFacilities(BuildContext context) async {

    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: _buildSearchPage(),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

 Widget _buildSearchPage() {
   return new Container(
     child: new SafeArea(
         child: SearchBar(
           searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
           onSearch: _search,
           onItemFound: (dynamic obj, int index){
             return new Container(
                 child: new SingleChildScrollView(
                   child: new Column(
                     children: [
                       new CheckboxListTile(
                         title: new Text(obj.name),
                         value: obj.isSupervisable,
                         onChanged: (bool value){
                           setState(() {
                             obj.isSupervisable = value;
                             if (value) { // INSERT IN FACILITY
                             }
                             else { // DELETE FROM FACILITY
                               //_configManager.clearFacility(obj.id);
                             }
                           });
                         },
                       )
                     ],
                   ),
                 )
             );
           },
           listPadding: EdgeInsets.symmetric(horizontal: 10),
           placeHolder: new Text("placeholder"),
           cancellationWidget: new Text("Cancel"),
           emptyWidget: new Text("empty"),
           onCancelled: () {
             print('Cancelled****');
           },
           mainAxisSpacing: 10,
           crossAxisSpacing: 10,
           crossAxisCount: 2,
         )
     ),
   );
 }

  Future<List<dynamic>> _search(String search) async {

    List<Object> searchResults = new List<Object>();
    var config = await configManager.getConfig();
    Map<String, String> configs = new Map();
    configs['baseUrl'] = config.getBaseUrl();
    configs['username'] = config.getUsername();
    configs['password'] = config.getPassword();
    _dhisManager = new DhisManager(configs);

      var sea = await _dhisManager.searchFacilities(search);
      if(sea.isNotEmpty && sea.length > 0){
        sea.asMap().forEach((key, value) {
          if(_ifSupervisable(value.id.toString()) != null){
            sea[key].isSupervisable = true;
          }
        });
        return sea;
      }
      return searchResults;
  }

  dynamic _ifSupervisable(String id) {
    var fac = facilities.firstWhere((element) => element.id == id, orElse: () => null);
    return fac;
  }
}
