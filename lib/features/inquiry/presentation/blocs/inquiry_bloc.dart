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

class TransitionInquiryStatus extends InquiryEvent {
  final int inquiryId;
  final String newStatus;
  final Role role;
  TransitionInquiryStatus(this.inquiryId, this.newStatus, this.role);
}

class RequestQuotes extends InquiryEvent {
  final int inquiryId;
  RequestQuotes(this.inquiryId);
}

class SendOffer extends InquiryEvent {
  final int inquiryId;
  SendOffer(this.inquiryId);
}

class LoadMediaOwnerQuotes extends InquiryEvent {}

class SubmitQuote extends InquiryEvent {
  final int quoteId;
  SubmitQuote(this.quoteId);
}

class DeclineQuote extends InquiryEvent {
  final int quoteId;
  DeclineQuote(this.quoteId);
}

class UpdateQuoteItemPrice extends InquiryEvent {
  final int quoteId;
  final int itemId;
  final double price;
  UpdateQuoteItemPrice(this.quoteId, this.itemId, this.price);
}

class LoadOffer extends InquiryEvent {
  final int inquiryId;
  LoadOffer(this.inquiryId);
}

class AcceptOffer extends InquiryEvent {
  final int inquiryId;
  AcceptOffer(this.inquiryId);
}

class RejectOffer extends InquiryEvent {
  final int inquiryId;
  final String? reason;
  RejectOffer(this.inquiryId, [this.reason]);
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

class MediaOwnerQuotesLoaded extends InquiryState {
  final List<QuoteData> quotes;
  MediaOwnerQuotesLoaded(this.quotes);
}

class OfferLoaded extends InquiryState {
  final OfferData offer;
  OfferLoaded(this.offer);
}

class OfferAccepted extends InquiryState {
  final int? campaignId;
  OfferAccepted({this.campaignId});
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
    on<TransitionInquiryStatus>(_onTransitionStatus);
    on<RequestQuotes>(_onRequestQuotes);
    on<SendOffer>(_onSendOffer);
    on<LoadMediaOwnerQuotes>(_onLoadMediaOwnerQuotes);
    on<SubmitQuote>(_onSubmitQuote);
    on<DeclineQuote>(_onDeclineQuote);
    on<UpdateQuoteItemPrice>(_onUpdateQuoteItemPrice);
    on<LoadOffer>(_onLoadOffer);
    on<AcceptOffer>(_onAcceptOffer);
    on<RejectOffer>(_onRejectOffer);
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

  Future<void> _onTransitionStatus(
    TransitionInquiryStatus event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      await _repository.transitionStatus(event.inquiryId, event.newStatus);
      emit(InquiryActionSuccess('Status promenjen'));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onRequestQuotes(
    RequestQuotes event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      await _repository.requestQuotes(event.inquiryId);
      emit(InquiryActionSuccess('Zahtev za ponude poslat'));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onSendOffer(
    SendOffer event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      await _repository.sendOffer(event.inquiryId);
      emit(InquiryActionSuccess('Ponuda poslata'));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onLoadMediaOwnerQuotes(
    LoadMediaOwnerQuotes event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquiryLoading());
    try {
      final quotes = await _repository.getMediaOwnerQuotes();
      emit(MediaOwnerQuotesLoaded(quotes));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onSubmitQuote(
    SubmitQuote event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      await _repository.submitQuote(event.quoteId);
      emit(InquiryActionSuccess('Ponuda poslata'));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onDeclineQuote(
    DeclineQuote event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      await _repository.declineQuote(event.quoteId);
      emit(InquiryActionSuccess('Ponuda odbijena'));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onUpdateQuoteItemPrice(
    UpdateQuoteItemPrice event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      await _repository.updateQuoteItem(
        event.quoteId,
        event.itemId,
        {'price': event.price},
      );
      // Don't emit action success for individual item updates
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onLoadOffer(
    LoadOffer event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquiryLoading());
    try {
      // Try brand first, then agency
      try {
        final offer = await _repository.getOffer(event.inquiryId, Role.brand);
        emit(OfferLoaded(offer));
      } catch (_) {
        final offer = await _repository.getOffer(event.inquiryId, Role.agency);
        emit(OfferLoaded(offer));
      }
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onAcceptOffer(
    AcceptOffer event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      int? campaignId;
      try {
        campaignId = await _repository.acceptOffer(event.inquiryId, Role.brand);
      } catch (_) {
        campaignId = await _repository.acceptOffer(event.inquiryId, Role.agency);
      }
      emit(OfferAccepted(campaignId: campaignId));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> _onRejectOffer(
    RejectOffer event,
    Emitter<InquiryState> emit,
  ) async {
    try {
      // Try brand first, then agency
      try {
        await _repository.rejectOffer(event.inquiryId, event.reason, Role.brand);
      } catch (_) {
        await _repository.rejectOffer(event.inquiryId, event.reason, Role.agency);
      }
      emit(InquiryActionSuccess('Ponuda odbijena'));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }
}
