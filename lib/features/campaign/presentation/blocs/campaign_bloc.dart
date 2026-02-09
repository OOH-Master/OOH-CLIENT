import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/dto/campaign_dto.dart';
import '../../data/repository/campaign_repository.dart';

// Events
abstract class CampaignEvent {}

class LoadCampaigns extends CampaignEvent {}

class CreateCampaign extends CampaignEvent {
  final Map<String, dynamic> data;
  CreateCampaign(this.data);
}

// States
abstract class CampaignState {}

class CampaignInitial extends CampaignState {}

class CampaignLoading extends CampaignState {}

class CampaignsLoaded extends CampaignState {
  final List<CampaignDto> campaigns;
  CampaignsLoaded(this.campaigns);
}

class CampaignFormSuccess extends CampaignState {
  final String message;
  CampaignFormSuccess(this.message);
}

class CampaignError extends CampaignState {
  final String message;
  CampaignError(this.message);
}

// Bloc
class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final CampaignRepository _repository;

  CampaignBloc(this._repository) : super(CampaignInitial()) {
    on<LoadCampaigns>(_onLoadCampaigns);
    on<CreateCampaign>(_onCreateCampaign);
  }

  Future<void> _onLoadCampaigns(
    LoadCampaigns event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      final campaigns = await _repository.getCampaigns();
      emit(CampaignsLoaded(campaigns));
    } catch (e) {
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> _onCreateCampaign(
    CreateCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      await _repository.createCampaign(event.data);
      emit(CampaignFormSuccess('Campaign created'));
    } catch (e) {
      emit(CampaignError(e.toString()));
    }
  }
}
