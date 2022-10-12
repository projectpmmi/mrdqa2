import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database service containing helper functions.
class SqliteDatabaseManager {
  static final DATABASE_NAME = "mrdqa_v1.9.db";
  static final DATABASE_VERSION = 1;

  SqliteDatabaseManager._privateConstructor();

  static final SqliteDatabaseManager instance = SqliteDatabaseManager._privateConstructor();
  static Database _database;

  /// Creates the database in-case it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), DATABASE_NAME);
    print(path);
    return await openDatabase(path, version: DATABASE_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    //The Assessment Table is for testing purposes ONLY
    await db.execute('''
          CREATE TABLE COUNTRIES (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT NOT NULL,
            name TEXT NOT NULL
          )
          ''');

    await db.execute('''
      CREATE TABLE FACILITIES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        name TEXT NOT NULL,
        country_id TEXT,
        town_village TEXT,
        district TEXT,
        region TEXT,
        facility_type_id,
        phone TEXT,
        email TEXT,
        is_dhis_facility TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE configuration (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        base_url TEXT NOT NULL,
        dhis_username TEXT NOT NULL,
        dhis_password TEXT NOT NULL,
        level CHAR(15) NOT NULL,
        program CHAR(20),
        program_name TEXT,
        program_period_type TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE DATA_ELEMENTS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid CHAR(35) NOT NULL,
        name TEXT NOT NULL,
        country_id INTEGER,
        type_de INTEGER,
        is_dhis_data_element TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE INDICATORS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid CHAR(15) NOT NULL,
        name TEXT NOT NULL,
        country_id INTEGER,
        cat_opt_combo CHAR(35),
        is_dhis_data_element TEXT,
        cat_opt_combo_name TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE PLANNING (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        period TEXT NOT NULL,
        sup_uid TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE METADATA_MAPPING (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        code TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE CONSISTENCY_OVER_TIME (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        indicatorid INTEGER NOT NULL,
        supervisionid INTEGER NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE CROSS_CHECK (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        primarydatasourceid INTEGER NOT NULL,
        secondarydatasourceid INTEGER NOT NULL,
        supervisionid INTEGER NOT NULL,
        type TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE DATA_ELEMENT_COMPLETENESS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dataelementid INTEGER NOT NULL,
        supervisionid INTEGER NOT NULL,
        number INTEGER
      )
      ''');

    await db.execute('''
      CREATE TABLE SOURCE_DOCUMENT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid CHAR(35) NOT NULL,
        name TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE SELECTED_INDICATORS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        indicatorid INTEGER NOT NULL,
        number INTEGER,
        supervisionid INTEGER NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE SOURCE_DOCUMENT_COMPLETENESS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sourcedocumentid INTEGER NOT NULL,
        number INTEGER,
        supervisionid INTEGER NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE SUPERVISIONS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        period String NOT NULL,
        countryid INTEGER,
        usepackage TEXT,
        uid TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE SUPERVISION_FACILITIES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE SUPERVISION_INDICATORS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        indicatorid INTEGER NOT NULL,
        type TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE SUPERVISION_PERIODS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        periodnumber INTEGER NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE SUPERVISION_SECTIONS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        sectionnumber INTEGER NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE VISITS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        date String NOT NULL,
        teamlead TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE PERIODS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number INTEGER NOT NULL,
        uid CHAR(35) NOT NULL,
        description TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE SECTIONS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid CHAR(35) NOT NULL,
        number INTEGER NOT NULL,
        description TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_COMPLETENESS_MONTHLY_REPORT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        expectedcells INTEGER,
        completedcells INTEGER,
        percent REAL,
        comment TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_TIMELINESS_MONTHLY_REPORT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        submittedmonth1 INTEGER,
        submittedmonth2 INTEGER,
        submittedmonth3 INTEGER,
        percent REAL,
        comment TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_CONSISTENCY_OVER_TIME (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        indicatorid INTEGER NOT NULL,
        currentmonthValue REAL,
        currentmonthvaluecomment TEXT,
        currentmonthyearagovalue REAL,
        currentmonthyearagovaluecomment TEXT,
        annualratio REAL,
        annualratiocomment TEXT,
        monthtomonthvalue1 REAL,
        monthtomonthvalue2 REAL,
        monthtomonthvalue3 REAL,
        monthtomonthvaluelastmonth REAL,
        monthtomonthratio REAL,
        monthtomonthratiocomment REAL,
        reasonfordiscrepancycomment TEXT,
        otherreasonfordiscrepancy TEXT,
        otherreasonfordiscrepancycomment TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_DISCREPANCIES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_CONSISTENCY_OVER_TIME_DISCREPANCIES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        entrydiscrepanciesid INTEGER NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_SOURCE_DOCUMENT_COMPLETENESS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        sourcedocumentid INTEGER NOT NULL,
        availabe int,
        uptodate int,
        standardform int,
        availaberesult REAL,
        uptodateresult REAL,
        standardformresult REAL,
        comment TEXT,
        type TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_DATA_ELEMENT_COMPLETENESS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        dataelementid INTEGER NOT NULL,
        missingcasesdata int,
        percent REAL,
        type TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_CROSS_CHECK_AB (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTERGER NOT NULL,
        facilityid INTEGER NOT NULL,
        primarydatasourceid INTEGER NOT NULL,
        secondarydatasourceid INTEGER NOT NULL,
        casessimpledfromprimary INTEGER,
        primarycomment TEXT,
    correspondingmachinginsecondary INTEGER,
    secondarycomment TEXT,
    secondaryreliabilityrate REAL,
    reliabilitycomment TEXT,
    type TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_CROSS_CHECK_C (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTERGER NOT NULL,
        facilityid INTEGER NOT NULL,
        primarydatasourceid INTEGER NOT NULL,
        secondarydatasourceid INTEGER NOT NULL,
        initialstock INTEGER,
        initialstockcomment TEXT,
    receivedstock INTEGER,
    receivedstockcomment TEXT,
    closingstock INTEGER,
    closingstockcomment TEXT,
    usedstock INTEGER,
    usedstockcomment TEXT,
    ratio REAL,
    ratiocomment TEXT,
    reasonfordiscrepancycomment TEXT,
    otherreasonfordiscrepancy TEXT,
    otherreasonfordiscrepancycomment TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_CROSS_CHECK_C_DISCREPANCIES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        primarydatasourceid INTEGER NOT NULL,
        secondarydatasourceid INTEGER NOT NULL,
        entrydiscrepanciesid INTEGER not null
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_DATA_ACCURACY (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        indicatorid INTEGER NOT NULL,
        sourcedocumentrecount1 INTEGER,
        sourcedocumentrecount2 INTEGER,
        sourcedocumentrecount3 INTEGER,
        sourcedocumentrecounttotal INTEGER not null,
        sourcedocumentrecountcomment TEXT,
        hmismonthlyreportvalue1 INTEGER,
        hmismonthlyreportvalue2 INTEGER,
        hmismonthlyreportvalue3 INTEGER,
        hmismonthlyreportvaluetotal INTEGER,
        hmismonthlyreportvaluecomment TEXT, 
        dhismonthlyvalue1 INTEGER,
        dhismonthlyvalue2 INTEGER,
        dhismonthlyvalue3 INTEGER,
        dhismonthlyvaluetotal INTEGER,
        dhismonthlyvaluecomment TEXT,
        monthlyreportvf1 REAL,
        monthlyreportvf2 REAL,
        monthlyreportvf3 REAL,
        monthlyreportvftotal REAL,
        monthlyreportvfcomment TEXT,
        dhisvf1 REAL,
        dhisvf2 REAL,
        dhisvf3 REAL,
        dhisvftotal REAL,
        dhisvfcomment TEXT,
        reasonfordiscrepancycomment TEXT,
        otherreasonfordiscrepancy1 TEXT,
        otherreasonfordiscrepancy2 TEXT,
        otherreasonfordiscrepancy3 TEXT,
        otherreasonfordiscrepancycomment TEXT,
        type TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_DATA_ACCURACY_DISCREPANCIES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        indicatorid INTEGER NOT NULL,
        entrydiscrepancyid INTEGER NOT NULL,
        month INTEGER not null
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_DQ_IMPROVEMENT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        weaknesses TEXT,
        actionpointdescription TEXT,
        responsibles TEXT,
        timeline String,
        comment TEXT,
        type TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ENTRY_SYSTEM_ASSESSMENT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supervisionid INTEGER NOT NULL,
        facilityid INTEGER NOT NULL,
        questionv1 TEXT,
        questionv1comment TEXT,
        questionv2 TEXT,
        questionv2comment TEXT,
        questionv3 TEXT,
        questionv3comment TEXT,
        questionv4 TEXT,
        questionv4comment TEXT,
        questionv5 TEXT,
        questionv5comment TEXT,
        questionv6 TEXT,
        questionv6comment TEXT,
        questionv7 TEXT,
        questionv7comment TEXT,
        questionv8 TEXT,
        questionv8comment TEXT,
        questionv9 TEXT,
        questionv9comment TEXT,
        questionv10 TEXT,
        questionv10comment TEXT,
        questionv11 TEXT,
        questionv11comment TEXT,
        questionv12 TEXT,
        questionv12comment TEXT,
        systemreadiness REAL
      )
      ''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    switch(oldVersion){
      case 1:
        print("OLD: $oldVersion");
        print("NEW: $newVersion");
        //db.execute("ALTER TABLE configuration ADD program_name TEXT;");
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    Database db = await instance.database;
    int created = await db.insert(table, data);
    return created;
  }

  Future<int> update(String table, Map<String, dynamic> data) async {
    Database db = await instance.database;
    int updated;
    switch (table) {
      case 'SUPERVISIONS':
        updated =
            await db.rawUpdate('''UPDATE $table SET description = ?, period = ?, usepackage = ? WHERE id = ? ''', [data['description'], data['period'], data['usepackage'], data['id']]);
        break;

      case 'VISITS':
        updated = await db.rawUpdate('''UPDATE $table SET date = ?, teamlead = ? WHERE id = ? ''', [data['date'], data['teamlead'], data['id']]);
        break;

      case 'ENTRY_COMPLETENESS_MONTHLY_REPORT':
        updated = await db.rawUpdate('''UPDATE $table SET expectedcells = ?, completedcells = ?, percent = ?, comment = ? WHERE id = ? ''',
            [data['expectedcells'], data['completedcells'], data['percent'], data['comment'], data['id']]);
        break;

      case 'ENTRY_TIMELINESS_MONTHLY_REPORT':
        updated = await db.rawUpdate(
            '''UPDATE $table SET submittedmonth1 = ?, submittedmonth2 = ?, submittedmonth3 = ?, percent = ?, comment = ? WHERE id = ? ''',
            [data['submittedmonth1'], data['submittedmonth2'], data['submittedmonth3'], data['percent'], data['comment'], data['id']]);
        break;

      case 'ENTRY_DATA_ELEMENT_COMPLETENESS':
        updated = await db.rawUpdate('''UPDATE $table SET missingcasesdata = ?, percent = ?, type = ? WHERE id = ? ''',
            [data['missingcasesdata'], data['percent'], data['type'], data['id']]);
        break;

      case 'ENTRY_SOURCE_DOCUMENT_COMPLETENESS':
        updated = await db.rawUpdate(
            '''UPDATE $table SET availabe = ?, uptodate = ?, standardform = ?, availaberesult = ?, uptodateresult = ?, standardformresult = ?, comment = ?, type = ? WHERE id = ? ''',
            [
              data['availabe'],
              data['uptodate'],
              data['standardform'],
              data['availaberesult'],
              data['uptodateresult'],
              data['standardformresult'],
              data['comment'],
              data['type'],
              data['id']
            ]);
        break;

      case 'ENTRY_DATA_ACCURACY':
        updated = await db.rawUpdate(
            '''UPDATE $table SET sourcedocumentrecount1 = ?, sourcedocumentrecount2 = ?, sourcedocumentrecount3 = ?, sourcedocumentrecounttotal = ?,
        sourcedocumentrecountcomment = ?, hmismonthlyreportvalue1 = ?, hmismonthlyreportValue2 = ?, hmismonthlyreportvalue3 = ?, hmismonthlyreportvaluetotal = ?, hmismonthlyreportvaluecomment = ?, 
        dhismonthlyvalue1 = ?, dhismonthlyvalue2 = ?, dhismonthlyvalue3 = ?, dhismonthlyvaluetotal = ?, dhismonthlyvaluecomment = ?, 
        monthlyreportvf1 = ?, monthlyreportvf2 = ?, monthlyreportvf3 = ?, monthlyreportvftotal = ?, monthlyreportvfcomment = ?,
        dhisvf1 = ?, dhisvf2 = ?, dhisvf3 = ?, dhisvftotal = ?, dhisvfcomment = ?, reasonfordiscrepancycomment = ?, 
        otherreasonfordiscrepancy1 = ?, otherreasonfordiscrepancy2 = ?, otherreasonfordiscrepancy3 = ?, otherreasonfordiscrepancycomment = ?, 
        type = ? WHERE id = ? ''',
            [
              data['sourcedocumentrecount1'],
              data['sourcedocumentrecount2'],
              data['sourcedocumentrecount3'],
              data['sourcedocumentrecounttotal'],
              data['sourcedocumentrecountcomment'],
              data['hmismonthlyreportvalue1'],
              data['hmismonthlyreportValue2'],
              data['hmismonthlyreportvalue3'],
              data['hmismonthlyreportvaluetotal'],
              data['hmismonthlyreportvaluecomment'],
              data['dhismonthlyvalue1'],
              data['dhismonthlyvalue2'],
              data['dhismonthlyvalue3'],
              data['dhismonthlyvaluetotal'],
              data['dhismonthlyvaluecomment'],
              data['monthlyreportvf1'],
              data['monthlyreportvf2'],
              data['monthlyreportvf3'],
              data['monthlyreportvftotal'],
              data['monthlyreportvfcomment'],
              data['dhisvf1'],
              data['dhisvf2'],
              data['dhisvf3'],
              data['dhisvftotal'],
              data['dhisvfcomment'],
              data['reasonfordiscrepancycomment'],
              data['otherreasonfordiscrepancy1'],
              data['otherreasonfordiscrepancy2'],
              data['otherreasonfordiscrepancy3'],
              data['otherreasonfordiscrepancycomment'],
              data['type'],
              data['id']
            ]);
        break;

      case 'ENTRY_CROSS_CHECK_AB':
        updated = await db.rawUpdate('''UPDATE $table SET casessimpledfromprimary = ?, primarycomment = ?, correspondingmachinginsecondary = ?, 
        secondarycomment = ?, secondaryreliabilityrate = ?, reliabilitycomment = ?, type = ? WHERE id = ? ''', [
          data['casessimpledfromprimary'],
          data['primarycomment'],
          data['correspondingmachinginsecondary'],
          data['secondarycomment'],
          data['secondaryreliabilityrate'],
          data['reliabilitycomment'],
          data['type'],
          data['id']
        ]);
        break;

      case 'ENTRY_CROSS_CHECK_C':
        updated = await db.rawUpdate('''UPDATE $table SET initialstock = ?, initialstockcomment = ?, receivedstock = ?, 
        receivedstockcomment = ?, closingstock = ?, closingstockcomment = ?, usedstock = ?, usedstockcomment = ?, 
        ratio = ?, ratiocomment = ?, reasonfordiscrepancycomment = ?, 
        otherreasonfordiscrepancy = ?, otherreasonfordiscrepancycomment = ? WHERE id = ? ''', [
          data['initialstock'],
          data['initialstockcomment'],
          data['receivedstock'],
          data['receivedstockcomment'],
          data['closingstock'],
          data['closingstockcomment'],
          data['usedstock'],
          data['usedstockcomment'],
          data['ratio'],
          data['ratiocomment'],
          data['reasonfordiscrepancycomment'],
          data['otherreasonfordiscrepancy'],
          data['otherreasonfordiscrepancycomment'],
          data['id']
        ]);
        break;

      case 'ENTRY_CONSISTENCY_OVER_TIME':
        updated = await db.rawUpdate('''UPDATE $table SET currentmonthValue = ?, currentmonthvaluecomment = ?, currentmonthyearagovalue = ?, 
        currentmonthyearagovaluecomment = ?, annualratio = ?, annualratiocomment = ?, monthtomonthvalue1 = ?, monthtomonthvalue2 = ?, 
        monthtomonthvalue3 = ?, monthtomonthvaluelastmonth = ?, monthtomonthratio = ?, 
        monthtomonthratiocomment = ?, reasonfordiscrepancycomment = ?, otherreasonfordiscrepancy = ?, otherreasonfordiscrepancycomment = ?
         WHERE id = ? ''', [
          data['currentmonthValue'],
          data['currentmonthvaluecomment'],
          data['currentmonthyearagovalue'],
          data['currentmonthyearagovaluecomment'],
          data['annualratio'],
          data['annualratiocomment'],
          data['monthtomonthvalue1'],
          data['monthtomonthvalue2'],
          data['monthtomonthvalue3'],
          data['monthtomonthvaluelastmonth'],
          data['monthtomonthratio'],
          data['monthtomonthratiocomment'],
          data['reasonfordiscrepancycomment'],
          data['otherreasonfordiscrepancy'],
          data['otherreasonfordiscrepancycomment'],
          data['id']
        ]);
        break;

      case 'ENTRY_SYSTEM_ASSESSMENT':
        updated = await db.rawUpdate('''UPDATE $table SET questionv1 = ?, questionv1comment = ?, questionv2 = ?, questionv2comment = ?,
        questionv3 = ?, questionv3comment = ?, questionv4 = ?, questionv4comment = ?, questionv5 = ?, questionv5comment = ?, 
        questionv6 = ?, questionv6comment = ?, questionv7 = ?, questionv7comment = ?, questionv8 = ?, 
        questionv8comment = ?, questionv9 = ?, questionv9comment = ?, questionv10 = ?, questionv10comment = ?,
        questionv11 = ?, questionv11comment = ?, questionv12 = ?, questionv12comment = ?, systemreadiness = ? WHERE id = ? ''', [
          data['questionv1'],
          data['questionv1comment'],
          data['questionv2'],
          data['questionv2comment'],
          data['questionv3'],
          data['questionv3comment'],
          data['questionv4'],
          data['questionv4comment'],
          data['questionv5'],
          data['questionv5comment'],
          data['questionv6'],
          data['questionv6comment'],
          data['questionv7'],
          data['questionv7comment'],
          data['questionv8'],
          data['questionv8comment'],
          data['questionv9'],
          data['questionv9comment'],
          data['questionv10'],
          data['questionv10comment'],
          data['questionv11'],
          data['questionv11comment'],
          data['questionv12'],
          data['questionv12comment'],
          data['systemreadiness'],
          data['id']
        ]);
        break;

      case 'ENTRY_DQ_IMPROVEMENT':
        updated = await db.rawUpdate('''UPDATE $table SET weaknesses = ?, actionpointdescription = ?, responsibles = ?, timeline = ?,
        comment = ?, type = ? WHERE id = ? ''',
            [data['weaknesses'], data['actionpointdescription'], data['responsibles'], data['timeline'], data['comment'], data['type'], data['id']]);
        break;
    }

    return updated;
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    var res = await db.query(table);
    return res;
  }

  Future<List<Map<String, dynamic>>> queryRow(String table, String uid) async {
    Database db = await instance.database;
    var res = await db.rawQuery("SELECT * FROM $table WHERE uid = '$uid'");
    return res;
  }

  Future<void> clearTable(String table) async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM ${table}");
  }

  Future<void> clearConfig(String table, String uid) async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM $table WHERE uid = '$uid'");
  }

  Future<void> removeCompletenessMetadata(String table, int id, int supId) async {
    Database db = await instance.database;
    switch (table) {
      case "DATA_ELEMENT_COMPLETENESS":
        await db.rawQuery("DELETE FROM $table WHERE dataelementid = '$id' and supervisionid = '$supId'");
        break;
      case 'SOURCE_DOCUMENT_COMPLETENESS':
        await db.rawQuery("DELETE FROM $table WHERE sourcedocumentid = '$id' and supervisionid = '$supId'");
        break;
      case 'SELECTED_INDICATORS':
        await db.rawQuery("DELETE FROM $table WHERE indicatorid = '$id' and supervisionid = '$supId'");
        break;
      case 'CROSS_CHECK':
        await db.rawQuery("DELETE FROM $table WHERE id = '$id' and supervisionid = '$supId'");
        break;
    }
  }

  Future<void> clearRowOfSupervisionFacility(String table, int supervisionId, int facilityId) async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM $table WHERE supervisionid = '$supervisionId' AND facilityid = '$facilityId'");
  }

  Future<void> clearRowsOfSupervision(String table, int supervisionId) async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM $table WHERE supervisionid = '$supervisionId'");
  }

  Future<List<Map<String, dynamic>>> queryRowById(String table, int id) async {
    Database db = await instance.database;
    var res = await db.rawQuery("SELECT * FROM $table WHERE id = '$id'");
    return res;
  }

  Future<List<Map<String, dynamic>>> queryRowsBySupervisionAndFacility(String table, int supervisionId, int facilityId) async {
    Database db = await instance.database;
    var res = await db.rawQuery("SELECT * FROM $table WHERE supervisionid = '$supervisionId' AND facilityid = '$facilityId'");
    return res;
  }

  Future<List<Map<String, dynamic>>> queryRowsBySupervision(String table, int supervisionId) async {
    Database db = await instance.database;
    var res = await db.rawQuery("SELECT * FROM $table WHERE supervisionid = '$supervisionId'");
    return res;
  }

  Future<List<Map<String, dynamic>>> queryRowsByCountry(String table, int countryId) async {
    Database db = await instance.database;
    var res = await db.rawQuery("SELECT * FROM $table WHERE countryid = '$countryId'");
    return res;
  }

  Future<List<Map<String, dynamic>>> queryRowsBySupervisionFacilityAndId(String table, int supervisionId, int facilityId, id) async {
    Database db = await instance.database;
    var res = await db.rawQuery("SELECT * FROM $table WHERE supervisionid = '$supervisionId' AND facilityid = '$facilityId' AND indicatorid = '$id'");
    return res;
  }

  Future<List<Map<String, dynamic>>> countRows(String table, int supervisionId) async {
    Database db = await instance.database;
    var res = await db.rawQuery("SELECT COUNT(*) AS count FROM $table WHERE supervisionid = '$supervisionId'");
    return res;
  }

  Future<List<Map<String, dynamic>>> countFacilityRows(String table, int supervisionId, int facilityId) async {
    Database db = await instance.database;
    var res = await db.rawQuery("SELECT COUNT(*) AS count FROM $table WHERE supervisionid = '$supervisionId' AND facilityid = '$facilityId'");
    return res;
  }
}
