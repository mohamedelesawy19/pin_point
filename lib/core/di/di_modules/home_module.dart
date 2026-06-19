// Package imports:
import 'package:flutter/foundation.dart';

// Core imports:
import '/core/di/service_locator.dart';

// Feature imports:
import '/features/home/presentation/bloc/session_cubit.dart';
import '/features/party/domain/usecases/restore_party_session_usecase.dart';

class HomeModule {
  HomeModule._();

  static void register() {
    ServiceLocator.registerSingleton<SessionCubit>(
      SessionCubit(
        restorePartySession: ServiceLocator.get<RestorePartySessionUseCase>(),
      ),
    );

    // Note: RestorePartySessionUseCase is registered in the PartyModule,
    // so we don't need to register it here.

    debugPrint('✅ Home feature dependencies registered');
  }
}
