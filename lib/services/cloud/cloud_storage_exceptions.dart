class CloudStorageException implements Exception {
  const CloudStorageException();
}
//CRUD C(create)
class CouldNotCreateNoteException extends CloudStorageException {}
//CRUD R(read)
class CouldNotGetAllNotesException extends CloudStorageException {}
//CRUD U(update)
class CouldNotUpdateNoteException extends CloudStorageException {}
//CRUD D(delete)
class CouldNotDeleteNoteException extends CloudStorageException {}