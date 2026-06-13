// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Core imports:
import '/core/di/service_locator.dart';

// Features imports:
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/party/data/datasources/party_remote_datasource.dart';
import '/features/party/data/repositories/party_repository_impl.dart';
import '/features/party/domain/repositories/party_repository.dart';
import '/features/party/domain/usecases/create_party_usecase.dart';
import '/features/party/domain/usecases/join_party_usecase.dart';
import '/features/party/domain/usecases/kick_player_usecase.dart';
import '/features/party/domain/usecases/leave_party_usecase.dart';
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

    // Repositories
    ServiceLocator.registerLazySingleton<PartyRepository>(
      () => PartyRepositoryImpl(
        dataSource: ServiceLocator.get<PartyRemoteDataSource>(),
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
