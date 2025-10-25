import 'package:injectable/injectable.dart';

import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

@injectable
class WatchAuthState implements StreamUseCase<User?, NoParams> {
  final AuthRepository repository;

  WatchAuthState(this.repository);

  @override
  Stream<User?> call(NoParams params) {
    return repository.authStateChanges;
  }
}
