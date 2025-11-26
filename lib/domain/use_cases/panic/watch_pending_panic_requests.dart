import '../../entities/panic_request.dart';
import '../../../data/repositories/panic_repository.dart';

class WatchPendingPanicRequests {
  final PanicRepository _panicRepository;

  WatchPendingPanicRequests(this._panicRepository);

  Stream<List<PanicRequest>> call() {
    return _panicRepository.watchPendingRequests();
  }
}
