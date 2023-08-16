import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class ClientDbService {
  Database? _db;

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenedException {}
  }

  List<ClientDb> _client = [];
  static final ClientDbService _shared = ClientDbService._sharedInstance();
  ClientDbService._sharedInstance() {
    _clientStreamController = StreamController<List<ClientDb>>.broadcast(
      onListen: () {
        _clientStreamController.sink.add(_client);
      },
    );
  }
  factory ClientDbService() => _shared;
  late final StreamController<List<ClientDb>> _clientStreamController;
  Stream<List<ClientDb>> get getevryClient => _clientStreamController.stream;
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<ClientDb> getClient({required String id}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final results =
        await db.query(clienTable, limit: 1, where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) {
      throw CouldNoteFindClient();
    } else {
      final client = ClientDb.fromRow(results.first);
      _client.removeWhere((client) => client.id == id);
      _client.add(client);
      _clientStreamController.add(_client);
      return client;
    }
  }

  Future<ClientDb> updateClien({
    required ClientDb client,
    required String name,
    required String adress,
    required String ville,
    required String zip,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getClient(id: client.id);
    final updateCount = await db.update(
        clienTable,
        {
          adressColumn: adress,
          nameColumn: name,
          villeColumn: ville,
          zipColumnt: zip,
        },
        where: '$idColumn = ?',
        whereArgs: [client.id]);

    if (updateCount == 0) {
      throw CouldNotUpdateClient();
    } else {
      final updatedClient = ClientDb(
        id: client.id,
        name: name,
        adress: adress,
        ville: ville,
        zip: zip,
      );

      _client.removeWhere((thisClient) => thisClient.id == client.id);
      _client.add(updatedClient);
      _clientStreamController.add(_client);
      return updatedClient;
    }
  }

  Future<List<ClientDb>> getSuggestion(String id) async {
    final client = await getAllClients();
    final searchResult = client.where((element) => element.id == id).toList();
    return searchResult;
  }

  Future<ClientDb> createBordereau({
    required String id,
    required String name,
    required String adress,
    required String ville,
    required String zip,
  }) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();

    final results = await db.query(clienTable, where: 'id=?', whereArgs: [id]);
    if (results.isNotEmpty) {
      final exiting = await getClient(id: id);
      return await updateClien(
          client: exiting, name: name, adress: adress, ville: ville, zip: zip);
    } else {
      await db.insert(clienTable, {
        idColumn: id,
        nameColumn: name,
        adressColumn: adress,
        villeColumn: ville,
        zipColumnt: zip,
      });
      final client = ClientDb(
        id: id,
        name: name,
        adress: adress,
        ville: ville,
        zip: zip,
      );
      _client.add(client);
      _clientStreamController.add(_client);
      return client;
    }
  }

  Future<void> _cacheClient() async {
    await _ensureDbIsOpen();
    final allClient = await getAllClients();

    _client = allClient.toList();
    _clientStreamController.add(_client);
  }

  Future<Iterable<ClientDb>> getAllClients() async {
    final db = _getDatabaseOrThrow();
    final clients = await db.query(clienTable);
    return clients.map((clientRow) => ClientDb.fromRow(clientRow));
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenedException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, "ClientDb");
      final db = await openDatabase(dbPath);
      await db.execute(createClient);
      _db = db;
      _cacheClient();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> close() async {
    var db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

class ClientDb {
  final String id, name, ville, adress, zip;

  ClientDb(
      {required this.id,
      required this.name,
      required this.ville,
      required this.adress,
      required this.zip});
  ClientDb.fromRow(Map<String, dynamic> map)
      : id = map[idColumn] as String,
        name = map[nameColumn],
        adress = map[adressColumn] as String,
        ville = map[villeColumn] as String,
        zip = map[zipColumnt] as String;
  @override
  String toString() {
    return "$adress | $name | $adress | $ville | $zip";
  }

  @override
  operator ==(covariant ClientDb other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

const String zipColumnt = 'ZIP';
const String villeColumn = 'Ville';
const String adressColumn = 'Adress';
const String nameColumn = 'Name';
const String idColumn = 'id';
const String clienTable = 'client';
const String createClient = '''CREATE TABLE IF NOT EXISTS "client" (
	"id"	TEXT NOT NULL UNIQUE,
	"Name"	TEXT NOT NULL,
	"Adress"	TEXT NOT NULL,
	"Ville"	TEXT NOT NULL,
	"ZIP"	TEXT NOT NULL,
	PRIMARY KEY("ID")
); ''';
