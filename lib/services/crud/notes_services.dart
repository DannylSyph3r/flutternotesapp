import "package:path/path.dart" show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'crud_exceptions.dart';



class NotesService {
  Database? _db;

  Future<DatabaseNotes> updateNote({required DatabaseNotes notes, required String text}) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: notes.id);
    final updatesCount = await db.update(notesTable, {
      notesTextColumn: text,
      cloudSyncedColumn: 0,
    });

    if(updatesCount == 0){
      throw CouldNotUpdateNotes();
    } else {
      return await getNote(id: notes.id);
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable,);
    return notes.map((noteRow) => DatabaseNotes.fromRow(noteRow));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      notesTable,
      limit: 1,
      where: 'id =?',
      whereArgs: [id],
    );
    if (notes.isEmpty){
      throw CouldNotFindNote();
    } else {
      return DatabaseNotes.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db =_getDatabaseOrThrow();
    return await db.delete(notesTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db =_getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if(deleteCount == 0){
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    //Making sure owner exists in the database with the correct id
    if (dbUser != owner){
      throw CouldNotFindUser();
    }
    const text = '';
    //Create the notes
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      notesTextColumn: text,
      cloudSyncedColumn: 1,
    });
    final note = DatabaseNotes(
        id: noteId,
        userId: owner.id,
        notesText: text,
        cloudSynced: true,
    );
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty){
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }


  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn : email.toLowerCase(),
    });
    return DatabaseUser(
      id: userId,
      email: email,
    );
}

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1){
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null){
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async{
    final db = _db;
    if (db == null){
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null){
      throw DatabaseAlreadyOpenedException();
    } try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create user table
      await db.execute(createUserTable);
      //create notes table
      await db.execute(createNotesTable);

    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();

    }
  }
}

class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int, email = map[idColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email $email';

  @override bool operator ==(covariant DatabaseUser other) => id ==other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String notesText;
  final bool cloudSynced;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.notesText,
    required this.cloudSynced,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        notesText = map[notesTextColumn] as String,
        cloudSynced = (map[cloudSyncedColumn] as int) == 1 ? true : false;

  @override
  String toString() => 'Note, ID = $id, userId = $userId, cloudSynced = $cloudSynced, notesText = $notesText';


  @override bool operator ==(covariant DatabaseNotes other) => id ==other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const notesTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const notesTextColumn = 'notes_text';
const cloudSyncedColumn = 'cloud_synced';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';
const createNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"notes_text"	TEXT,
	"cloud_synced"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';

