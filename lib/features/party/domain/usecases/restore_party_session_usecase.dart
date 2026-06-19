// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/party/domain/entities/party_entity.dart';
import '/features/party/domain/repositories/party_repository.dart';

class RestorePartySessionUseCase
    implements UseCase<String?, SingleParam<String>> {
  const RestorePartySessionUseCase({required this._partyRepository});

  final PartyRepository _partyRepository;

  @override
  Future<Either<Failure, String?>> call(SingleParam<String> params) async {
    // ── 1. Read locally-persisted session code ────────────────────────────
    final codeResult = await _partyRepository.getActivePartyCode();
    if (codeResult.isLeft()) return codeResult;
    final code = codeResult.getOrElse(() => null);
    if (code == null) return const Right(null);

    // ── 2. Verify the party still exists in Firestore ─────────────────────
    final partyResult = await _partyRepository.getParty(code);
    Failure? fetchFailure;
    PartyEntity? party;
    partyResult.fold((f) => fetchFailure = f, (p) => party = p);
    if (fetchFailure != null) return Left(fetchFailure!);

    // ── 3. Apply business rules ───────────────────────────────────────────
    final p = party;
    final isValid =
        p != null &&
        p.status == PartyStatus.waiting &&
        p.players.any((player) => player.uid == params.value);

    if (!isValid) {
      await _partyRepository.clearActivePartyCode();
      return const Right(null);
    }

    return Right(code);
  }
}
