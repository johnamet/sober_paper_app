import '../../../data/repositories/panic_repository.dart';

class RespondToPanicRequest {
  final PanicRepository _panicRepository;

  RespondToPanicRequest(this._panicRepository);

  Future<void> call({
    required String requestId,
    required String responderId,
    required String responderName,
  }) async {
    if (requestId.isEmpty || responderId.isEmpty) {
      throw ArgumentError('Request ID and responder ID cannot be empty');
    }

    await _panicRepository.respondToRequest(
      requestId: requestId,
      volunteerId: responderId,
      response: 'Volunteer $responderName is responding',
    );
  }
}
