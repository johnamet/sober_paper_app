import '../../entities/panic_request.dart';
import '../../../data/repositories/panic_repository.dart';

class CreatePanicRequest {
  final PanicRepository _panicRepository;

  CreatePanicRequest(this._panicRepository);

  Future<PanicRequest> call({
    required String requesterId,
    required String requesterName,
    required int requesterDayCount,
    ConnectionType connectionType = ConnectionType.chat,
  }) async {
    if (requesterId.isEmpty) {
      throw ArgumentError('Requester ID cannot be empty');
    }

    return await _panicRepository.createRequest(
      requesterId: requesterId,
      requesterName: requesterName,
      requesterDayCount: requesterDayCount,
      connectionType: connectionType,
    );
  }
}
