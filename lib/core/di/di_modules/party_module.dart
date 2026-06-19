// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/storage/secure_storage.dart';

// Features imports:
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/party/data/datasources/party_local_datasource.dart';
import '/features/party/data/datasources/party_remote_datasource.dart';
import '/features/party/data/repositories/party_repository_impl.dart';
import '/features/party/domain/repositories/party_repository.dart';
import '/features/party/domain/usecases/create_party_usecase.dart';
import '/features/party/domain/usecases/join_party_usecase.dart';
import '/features/party/domain/usecases/kick_player_usecase.dart';
import '/features/party/domain/usecases/leave_party_usecase.dart';
import '/features/party/domain/usecases/restore_party_session_usecase.dart';
import '/features/party/domain/usecases/start_game_usecase.dart';
import '/features/party/domain/usecases/watch_party_usecase.dart';
import '/features/party/presentation/bloc/party_bloc.dart';

class PartyModule {
  PartyModule._();

  static Future<void> register() async {
    // Data Sources
    ServiceLocator.registerLazySingleton<PartyRemoteDataSource>(
      () => PartyRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
    );

    ServiceLocator.registerLazySingleton<PartyLocalDataSource>(
      () => PartyLocalDataSourceImpl(
        secureStorage: ServiceLocator.get<SecureStorage>(),
      ),
    );

    // Repositories
    ServiceLocator.registerLazySingleton<PartyRepository>(
      () => PartyRepositoryImpl(
        remoteDataSource: ServiceLocator.get<PartyRemoteDataSource>(),
        localDataSource: ServiceLocator.get<PartyLocalDataSource>(),
      ),
    );

    // Use Cases
    ServiceLocator.registerFactory<CreatePartyUseCase>(
      () => CreatePartyUseCase(
        partyRepository: ServiceLocator.get<PartyRepository>(),
        authRepository: ServiceLocator.get<AuthRepository>(),
      ),
    );

    ServiceLocator.registerFactory<JoinPartyUseCase>(
      () => JoinPartyUseCase(
        partyRepository: ServiceLocator.get<PartyRepository>(),
        authRepository: ServiceLocator.get<AuthRepository>(),
      ),
    );

    ServiceLocator.registerFactory<KickPlayerUseCase>(
      () => KickPlayerUseCase(
        partyRepository: ServiceLocator.get<PartyRepository>(),
        authRepository: ServiceLocator.get<AuthRepository>(),
      ),
    );

    ServiceLocator.registerFactory<LeavePartyUseCase>(
      () => LeavePartyUseCase(
        partyRepository: ServiceLocator.get<PartyRepository>(),
        authRepository: ServiceLocator.get<AuthRepository>(),
      ),
    );

    ServiceLocator.registerFactory<RestorePartySessionUseCase>(
      () => RestorePartySessionUseCase(
        partyRepository: ServiceLocator.get<PartyRepository>(),
      ),
    );

    ServiceLocator.registerFactory<StartGameUseCase>(
      () => StartGameUseCase(
        partyRepository: ServiceLocator.get<PartyRepository>(),
        authRepository: ServiceLocator.get<AuthRepository>(),
      ),
    );

    ServiceLocator.registerFactory<WatchPartyUseCase>(
      () => WatchPartyUseCase(ServiceLocator.get<PartyRepository>()),
    );

    // Presentation BLoCs
    ServiceLocator.registerSingleton<PartyBloc>(
      PartyBloc(
        createParty: ServiceLocator.get<CreatePartyUseCase>(),
        joinParty: ServiceLocator.get<JoinPartyUseCase>(),
        kickPlayer: ServiceLocator.get<KickPlayerUseCase>(),
        leaveParty: ServiceLocator.get<LeavePartyUseCase>(),
        startGame: ServiceLocator.get<StartGameUseCase>(),
        watchParty: ServiceLocator.get<WatchPartyUseCase>(),
      ),
    );

    debugPrint('✅ Party feature dependencies registered');
  }
}
