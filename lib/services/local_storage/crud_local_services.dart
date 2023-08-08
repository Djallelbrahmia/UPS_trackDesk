import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:ups_trackdesk/services/local_storage/crud_exceptions.dart';

class LabelService {
  Database? _db;
  List<DataBaseBordereau> _labels = [];
  static final LabelService _shared = LabelService._sharedInstance();
  LabelService._sharedInstance();
  factory LabelService() => _shared;
  final _bordereauStreamController =
      StreamController<List<DataBaseBordereau>>.broadcast();
  Stream<List<DataBaseBordereau>> get getAllLabels =>
      _bordereauStreamController.stream;
  Future<void> _cacheBordereau() async {
    await _ensureDbIsOpen();
    final allBordereau = await getAllBordereau();

    _labels = allBordereau.toList();
    _bordereauStreamController.add(_labels);
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenedException {}
  }

  Future<Iterable<DataBaseBordereau>> getAllBordereau() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(bordereauTable);
    return notes.map((noteRow) => DataBaseBordereau.fromRow(noteRow));
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenedException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      // create the user table
      await db.execute(createUserTable);
      // create label table
      await db.execute(createLabelTable);
      _db = db;
      await _cacheBordereau();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<DataBaseBordereau> updateBordereau({
    required DataBaseBordereau bordereau,
    required userId,
    required nameExp,
    required adressExp,
    required villeexp,
    required zipExp,
    required nameDest,
    required adressDest,
    required villeDest,
    required zipDest,
    required numbreOfitems,
    required packageWeight,
    required typeDeLivraison,
    required typeDePayment,
    required bordoreauUrl,
    required ackReceipt,
    required addedDate,
    required isSync,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getBordereau(bareCode: bordereau.bareCode);
    final updateCount = await db.update(bordereauTable, {
      userIdColumn: bordereau.userId,
      nameExpColumn: nameExp,
      adressExpColumn: adressExp,
      villeexpColumn: adressExp,
      zipExpColumn: zipExp,
      nameDestColumn: nameDest,
      adressDestColumn: adressDestColumn,
      villeDestColumn: villeDest,
      zipDestColumn: zipDest,
      packageWeightColumn: packageWeight,
      numbreOfitemsColumn: numbreOfitems,
      typeDeLivraisonColumn: typeDeLivraison,
      typeDePaymentColumn: typeDePayment,
      bareCodeColumn: bordereau.bareCode,
      bordoreauUrlColumn: bordoreauUrl,
      ackReceiptColumn: ackReceipt,
      isSyncColumn: isSync,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateBordereau();
    } else {
      final updateBordereau = await getBordereau(bareCode: bordereau.bareCode);
      _labels.removeWhere((thisbordereau) => thisbordereau.id == bordereau.id);
      _labels.add(updateBordereau);
      _bordereauStreamController.add(_labels);
      return updateBordereau;
    }
  }

  Future<DataBaseUser> getOrCreateUser(
      {required String userId,
      required String profilPic,
      required String userName}) async {
    await _ensureDbIsOpen();
    try {
      final user = await getUser(userId: userId);
      return user;
    } on CouldNoteFindUser {
      final createdUser = await createUser(
          userId: userId, profilPic: profilPic, userName: userName);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser({required String userId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount =
        await db.delete(userTable, where: 'userId=?', whereArgs: [userId]);
    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> deleteBordereau({required String barecode}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final deleteCount = await db
        .delete(bordereauTable, where: 'barecode = ?', whereArgs: [barecode]);
    if (deleteCount != 1) {
      throw CouldNoteDeleteBordereau();
    } else {
      final countBefore = _labels.length;
      _labels.removeWhere((bordereau) => bordereau.bareCode == barecode);
      if (_labels.length != countBefore) {
        _bordereauStreamController.add(_labels);
      }
    }
  }

  Future<DataBaseUser> getUser({required String userId}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final results = await db
        .query(userTable, limit: 1, where: 'userId = ?', whereArgs: [userId]);
    if (results.isEmpty) {
      throw CouldNoteFindUser();
    } else {
      return DataBaseUser.fromRow(results.first);
    }
  }

  Future<DataBaseBordereau> getBordereau({required String bareCode}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final results = await db.query(bordereauTable,
        limit: 1, where: 'bareCode = ?', whereArgs: [bareCode]);
    if (results.isEmpty) {
      throw CouldNoteFindBordereau();
    } else {
      final bordereau = DataBaseBordereau.fromRow(results.first);
      _labels.removeWhere((bordereau) => bordereau.bareCode == bareCode);
      _labels.add(bordereau);
      _bordereauStreamController.add(_labels);
      return bordereau;
    }
  }

  Future<DataBaseUser> createUser({
    required String userId,
    required String profilPic,
    required String userName,
  }) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final results = await db
        .query(userTable, limit: 1, where: 'userId = ?', whereArgs: [userId]);
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final id = await db.insert(userTable, {
      userIdColumn: userId,
      profilPicColumn: profilPic,
      userNameColumn: userName
    });
    return DataBaseUser(
        id: id, profilPic: profilPic, userName: userName, userId: userId);
  }

  Future<DataBaseBordereau> createBordereau(
      {required DataBaseUser owner,
      required userId,
      required nameExp,
      required adressExp,
      required villeexp,
      required zipExp,
      required nameDest,
      required adressDest,
      required villeDest,
      required zipDest,
      required numbreOfitems,
      required packageWeight,
      required typeDeLivraison,
      required typeDePayment,
      required bordoreauUrl,
      required ackReceipt,
      required addedDate,
      required isSync,
      required bareCode}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final user = await getUser(userId: owner.userId);
    if (owner != user) {
      throw CouldNoteFindUser();
    }
    final results = await db
        .query(bordereauTable, where: 'bareCode=?', whereArgs: [bareCode]);
    if (results.isNotEmpty) {
      throw BordereauAlreadyExist();
    } else {
      final id = await db.insert(bordereauTable, {
        userIdColumn: owner.userId,
        nameExpColumn: nameExp,
        adressExpColumn: adressExp,
        villeexpColumn: adressExp,
        zipExpColumn: zipExp,
        nameDestColumn: nameDest,
        adressDestColumn: adressDestColumn,
        villeDestColumn: villeDest,
        zipDestColumn: zipDest,
        packageWeightColumn: packageWeight,
        numbreOfitemsColumn: numbreOfitems,
        typeDeLivraisonColumn: typeDeLivraison,
        typeDePaymentColumn: typeDePayment,
        bareCodeColumn: bareCode,
        bordoreauUrlColumn: bordoreauUrl,
        ackReceiptColumn: ackReceipt,
        isSyncColumn: isSync,
        addedDateColumn: addedDate
      });
      final bordoreau = DataBaseBordereau(
          id: id,
          userId: owner.userId,
          nameExp: nameExp,
          adressExp: adressExp,
          villeexp: villeexp,
          zipExp: zipExp,
          nameDest: nameDest,
          adressDest: adressDest,
          villeDest: villeDest,
          zipDest: zipDest,
          numbreOfitems: numbreOfitems,
          packageWeight: packageWeight,
          typeDeLivraison: typeDeLivraison,
          typeDePayment: typeDePayment,
          bordoreauUrl: bordoreauUrl,
          ackReceipt: ackReceipt,
          addedDate: addedDate,
          isSync: isSync,
          bareCode: bareCode);
      _labels.add(bordoreau);
      _bordereauStreamController.add(_labels);
      return bordoreau;
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

@immutable
class DataBaseUser {
  final int id;
  final String profilPic;
  final String userName;
  final String userId;

  const DataBaseUser(
      {required this.id,
      required this.profilPic,
      required this.userName,
      required this.userId});
  DataBaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        profilPic = map[profilPicColumn] as String,
        userName = map[userNameColumn] as String,
        userId = map[userIdColumn] as String;
  @override
  String toString() {
    return ' Username : $userName';
  }

  @override
  bool operator ==(covariant DataBaseUser other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DataBaseBordereau {
  final int id;
  final String userId;
  final String nameExp;
  final String adressExp;
  final String villeexp;
  final String zipExp;
  final String nameDest;
  final String adressDest;
  final String zipDest;

  final String villeDest;
  final String numbreOfitems;
  final String packageWeight;
  final String typeDeLivraison;
  final String typeDePayment;
  final String bordoreauUrl;
  final String ackReceipt;
  final String addedDate;
  final bool isSync;
  final String bareCode;
  DataBaseBordereau(
      {required this.id,
      required this.userId,
      required this.nameExp,
      required this.adressExp,
      required this.villeexp,
      required this.zipExp,
      required this.nameDest,
      required this.adressDest,
      required this.villeDest,
      required this.zipDest,
      required this.numbreOfitems,
      required this.packageWeight,
      required this.typeDeLivraison,
      required this.typeDePayment,
      required this.bordoreauUrl,
      required this.ackReceipt,
      required this.addedDate,
      required this.isSync,
      required this.bareCode});

  DataBaseBordereau.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as String,
        nameExp = map[nameExpColumn] as String,
        adressExp = map[adressExpColumn] as String,
        villeexp = map[villeexpColumn] as String,
        zipExp = map[zipExpColumn] as String,
        nameDest = map[nameDestColumn] as String,
        adressDest = map[adressDestColumn] as String,
        villeDest = map[villeDestColumn] as String,
        zipDest = map[zipDestColumn] as String,
        numbreOfitems = map[numbreOfitemsColumn] as String,
        packageWeight = map[packageWeightColumn] as String,
        typeDeLivraison = map[typeDeLivraisonColumn] as String,
        typeDePayment = map[typeDePaymentColumn] as String,
        bordoreauUrl = map[bordoreauUrlColumn] as String,
        ackReceipt = map[ackReceiptColumn] as String,
        addedDate = map[addedDateColumn] as String,
        bareCode = map[bareCodeColumn] as String,
        isSync = (map[isSyncColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return "Nom d'expéditeur $nameExp , Nom de déstinateur $nameDest,Tracking $bareCode";
  }

  @override
  bool operator ==(covariant DataBaseBordereau other) {
    return (id == other.id) && (bareCode == other.bareCode);
  }

  @override
  int get hashCode => id.hashCode;
}

const String createUserTable = ''' 
CREATE TABLE IF NOT EXISTS "User" (
	"id"	INTEGER NOT NULL,
	"profilPic"	TEXT UNIQUE,
	"userName"	TEXT NOT NULL,
	"userId"	TEXT NOT NULL UNIQUE,
	FOREIGN KEY("userId") REFERENCES "User"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';
const String createLabelTable = ''' 
CREATE TABLE IF NOT EXISTS "bordereau" (
	"id"	INTEGER NOT NULL,
	"userId"	TEXT NOT NULL,
	"NameExp"	TEXT NOT NULL,
	"adressExp"	TEXT NOT NULL,
	"villeexp"	TEXT NOT NULL,
	"zipExp"	TEXT NOT NULL,
	"nameDest"	TEXT NOT NULL,
	"adressDest"	TEXT NOT NULL,
	"villeDest"	TEXT NOT NULL,
	"zipDest"	TEXT NOT NULL,
	"numbreOfItems"	TEXT NOT NULL,
	"packageWeight"	TEXT NOT NULL,
	"typeDeLivraison"	TEXT NOT NULL,
	"typeDePayment"	TEXT NOT NULL,
	"bordoreauUrl"	TEXT NOT NULL,
	"ackOfReceipt"	TEXT NOT NULL,
	"addedDate"	TEXT NOT NULL,
	"isSync"	INTEGER DEFAULT 0,
	"bareCode"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';
const dbName = 'notes.db';
const userTable = 'User';
const bordereauTable = 'bordereau';
const idColumn = "id";
const profilPicColumn = "profilPic";
const userNameColumn = "userName";
const userIdColumn = "userId";
const String bareCodeColumn = 'bareCode';
const String nameExpColumn = "NameExp";
const String adressExpColumn = "adressExp";
const String villeexpColumn = "villeexp";
const String zipExpColumn = "zipExp";
const String nameDestColumn = "nameDest";
const String adressDestColumn = "adressDest";
const String villeDestColumn = "villeDest";
const String zipDestColumn = "zipDest";
const String numbreOfitemsColumn = "numbreOfItems";
const String packageWeightColumn = "packageWeight";
const String typeDeLivraisonColumn = "typeDeLivraison";
const String typeDePaymentColumn = "typeDePayment";
const String bordoreauUrlColumn = "bordoreauUrl";
const String ackReceiptColumn = "ackOfReceipt";
const String addedDateColumn = "addedDate";
const String isSyncColumn = "isSync";
