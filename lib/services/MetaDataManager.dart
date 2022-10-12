import 'SqliteDatabaseManager.dart';

class MetaDataManager {
  final _sqliteDb = SqliteDatabaseManager.instance;

  Future<void> deleteCompletenessMetadata(String completenessType, int id, int supervisionId) async{
    _sqliteDb.removeCompletenessMetadata(completenessType, id, supervisionId);
  }
}