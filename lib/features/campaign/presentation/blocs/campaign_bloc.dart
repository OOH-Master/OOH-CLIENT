import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/dto/campaign_dto.dart';
import '../../data/repository/campaign_repository.dart';

// Events
abstract class CampaignEvent {}

class LoadCampaigns extends CampaignEvent {}

class LoadCampaignDetail extends CampaignEvent {
  final int id;
  LoadCampaignDetail(this.id);
}

class CreateCampaign extends CampaignEvent {
  final Map<String, dynamic> data;
  CreateCampaign(this.data);
}

class UpdateCampaign extends CampaignEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateCampaign(this.id, this.data);
}

class DeleteCampaign extends CampaignEvent {
  final int id;
  DeleteCampaign(this.id);
}

class ChangeStatus extends CampaignEvent {
  final int id;
  final String status;
  ChangeStatus(this.id, this.status);
}

// States
abstract class CampaignState {}

class CampaignInitial extends CampaignState {}

class CampaignLoading extends CampaignState {}

class CampaignsLoaded extends CampaignState {
  final List<CampaignDto> campaigns;
  CampaignsLoaded(this.campaigns);
}

class CampaignDetailLoaded extends CampaignState {
  final CampaignDto campaign;
  CampaignDetailLoaded(this.campaign);
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
    on<LoadCampaignDetail>(_onLoadCampaignDetail);
    on<CreateCampaign>(_onCreateCampaign);
    on<UpdateCampaign>(_onUpdateCampaign);
    on<DeleteCampaign>(_onDeleteCampaign);
    on<ChangeStatus>(_onChangeStatus);
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

  Future<void> _onLoadCampaignDetail(
    LoadCampaignDetail event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      final campaign = await _repository.getCampaignById(event.id);
      emit(CampaignDetailLoaded(campaign));
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
      emit(CampaignFormSuccess('Kampanja kreirana'));
    } catch (e) {
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> _onUpdateCampaign(
    UpdateCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      await _repository.updateCampaign(event.id, event.data);
      emit(CampaignFormSuccess('Kampanja azurirana'));
    } catch (e) {
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> _onDeleteCampaign(
    DeleteCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      await _repository.deleteCampaign(event.id);
      emit(CampaignFormSuccess('Kampanja obrisana'));
    } catch (e) {
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> _onChangeStatus(
    ChangeStatus event,
    Emitter<CampaignState> emit,
  ) async {
    try {
      final campaign = await _repository.changeStatus(event.id, event.status);
      emit(CampaignFormSuccess('Status promenjen'));
      emit(CampaignDetailLoaded(campaign));
    } catch (e) {
      emit(CampaignError(e.toString()));
    }
  }
}
