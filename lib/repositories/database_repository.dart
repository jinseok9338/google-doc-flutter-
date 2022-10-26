import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/app/constants.dart';
import 'package:google_docs_clone/app/providers.dart';
import 'package:google_docs_clone/app/utils.dart';
import 'package:google_docs_clone/models/models.dart';
import 'package:google_docs_clone/repositories/repository_exception.dart';

final _databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepository(ref.read);
});

class DatabaseRepository with RepositoryExceptionMixin {
  DatabaseRepository(this._read);

  final Reader _read;

  static Provider<DatabaseRepository> get provider =>
      _databaseRepositoryProvider;

  FirebaseFirestore get _realtime => _read(Dependency.realtime);

  FirebaseFirestore get _database => _read(Dependency.database);

  Future<void> createNewPage({
    required String documentId,
    required String owner,
  }) async {
    return exceptionHandler(
        _createPageAndDelta(owner: owner, documentId: documentId));
  }

  Future<void> _createPageAndDelta({
    required String documentId,
    required String owner,
  }) async {
    Future.wait([
      _database.collection(CollectionNames.pages).doc(documentId).set({
        'owner': owner,
        'title': null,
        'content': null,
      }),
      _database
          .collection(CollectionNames.delta)
          .doc(documentId)
          .set({'delta': null, 'user': null, 'deviceId': null}),
    ]);
  }

  Future<DocumentPageData> getPage({
    required String documentId,
  }) {
    return exceptionHandler(_getPage(documentId));
  }

  Future<DocumentPageData> _getPage(String documentId) async {
    final docRef = _database.collection(CollectionNames.pages).doc(documentId);
    final doc = await docRef.get();
    return DocumentPageData.fromMap(doc.data()!);
  }

  Future<List<DocumentPageData>> getAllPages(String userId) async {
    return exceptionHandler(_getAllPages(userId));
  }

  Future<List<DocumentPageData>> _getAllPages(String userId) async {
    final resultDocs = await _database
        .collection(CollectionNames.pages)
        .where('owner', isEqualTo: userId);
    final result = await resultDocs.get();
    return result.docs.map((element) {
      return DocumentPageData.fromMap(element.data());
    }).toList();
  }

  Future<void> updatePage(
      {required String documentId,
      required DocumentPageData documentPage}) async {
    return exceptionHandler(
      _database.collection(CollectionNames.pages).doc(documentId).set(
            documentPage.toMap(),
          ),
    );
  }

  Future<void> updateDelta({
    required String pageId,
    required DeltaData deltaData,
  }) {
    return exceptionHandler(
      _database.collection(CollectionNames.delta).doc(pageId).set(
            deltaData.toMap(),
          ),
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> subscribeToPage(
      {required String pageId}) {
    try {
      final docRef = _realtime.collection(CollectionNames.delta).doc(pageId);
      return docRef.snapshots();
    } on FirebaseException catch (e) {
      logger.warning(e.message, e);
      throw RepositoryException(
          message: e.message ?? 'An undefined error occured');
    } on Exception catch (e, st) {
      logger.severe('Error subscribing to page changes', e, st);
      throw RepositoryException(
          message: 'Error subscribing to page changes',
          exception: e,
          stackTrace: st);
    }
  }
}
