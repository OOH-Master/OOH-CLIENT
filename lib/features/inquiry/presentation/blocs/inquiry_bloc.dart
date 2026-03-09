import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/role.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/inquiry.dart';

// Events
abstract class InquiryEvent {}

class LoadInquiries extends InquiryEvent {
  final Role role;
  LoadInquiries(this.role);
}

class LoadInquiryDetail extends InquiryEvent {
  final int id;
  final Role role;
  LoadInquiryDetail(this.id, this.role);
}

class UpdateAdminNotes extends InquiryEvent {
  final int inquiryId;
  final String notes;
  final Role role;
  UpdateAdminNotes(this.inquiryId, this.notes, this.role);
}

class UpdateQuotedPrice extends InquiryEvent {
  final int inquiryId;
  final int itemId;
  final double price;
  final Role role;
  UpdateQuotedPrice(this.inquiryId, this.itemId, this.price, this.role);
}

class CreateInquiry extends InquiryEvent {
  final Map<String, dynamic> data;
  CreateInquiry(this.data);
}

// States
abstract class InquiryState {}

class InquiryInitial extends InquiryState {}

class InquiryLoading extends InquiryState {}

class InquiriesLoaded extends InquiryState {
  final List<Inquiry> inquiries;
  InquiriesLoaded(this.inquiries);
}

class InquiryDetailLoaded extends InquiryState {
  final Inquiry inquiry;
  InquiryDetailLoaded(this.inquiry);
}

class InquiryActionSuccess extends InquiryState {
  final String message;
  InquiryActionSuccess(this.message);
}

class InquiryError extends InquiryState {
  final String message;
  InquiryError(this.message);
}

class InquirySubmitting extends InquiryState {}

class InquirySubmitSuccess extends InquiryState {
  final String message;
  InquirySubmitSuccess(this.message);
}

// Bloc
class InquiryBloc extends Bloc<InquiryEvent, InquiryState> {
  final InquiryRepository _repository;

  InquiryBloc(this._repository) : super(InquiryInitial()) {
    on<LoadInquiries>(_onLoadInquiries);
    on<LoadInquiryDetail>(_onLoadInquiryDetail);
    on<UpdateAdminNotes>(_onUpdateAdminNotes);
    on<UpdateQuotedPrice>(_onUpdateQuotedPrice);
    on<CreateInquiry>(_onCreateInquiry);
  }

  Future<void> _onLoadInquiries(
    LoadInquiries event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquiryLoading());
    try {
      final inquiries = await _repository.getInquiries(event.role);
      emit(InquiriesLoaded(inquiries));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onLoadInquiryDetail(
    LoadInquiryDetail event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquiryLoading());
    try {
      final inquiry = await _repository.getInquiryById(event.id, event.role);
      emit(InquiryDetailLoaded(inquiry));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onUpdateAdminNotes(
    UpdateAdminNotes event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      await _repository.updateAdminNotes(event.inquiryId, event.notes);
      emit(InquiryActionSuccess('Notes updated'));
      // Reload detail
      add(LoadInquiryDetail(event.inquiryId, event.role));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onUpdateQuotedPrice(
    UpdateQuotedPrice event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      await _repository.updateQuotedPrice(
        event.inquiryId,
        event.itemId,
        event.price,
      );
      emit(InquiryActionSuccess('Price updated'));
      // Reload detail
      add(LoadInquiryDetail(event.inquiryId, event.role));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onCreateInquiry(
    CreateInquiry event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquirySubmitting());
    try {
      await _repository.createInquiry(event.data);
      emit(InquirySubmitSuccess('Inquiry submitted successfully'));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }
}
