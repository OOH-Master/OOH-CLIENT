import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/currency_totals.dart';
import '../blocs/inquiry_bloc.dart';
import '../utils/inquiry_errors.dart';
import '../widgets/inquiry_layout.dart';
import '../widgets/inquiry_unit_row.dart';
import '../widgets/pdf_download_button.dart';
import '../widgets/status_pills.dart';

class OfferReviewPage extends StatelessWidget {
  final String inquiryId;

  const OfferReviewPage({super.key, required this.inquiryId});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final role =
        authState is AuthAuthenticated ? authState.user.role : Role.brand;
    return BlocProvider(
      create: (context) => InquiryBloc(context.read<InquiryRepository>())
        ..add(LoadOffer(int.tryParse(inquiryId) ?? 0)),
      child: _OfferReviewView(inquiryId: inquiryId, role: role),
    );
  }
}

class _OfferReviewView extends StatefulWidget {
  final String inquiryId;
  final Role role;

  const _OfferReviewView({required this.inquiryId, required this.role});

  @override
  State<_OfferReviewView> createState() => _OfferReviewViewState();
}

class _OfferReviewViewState extends State<_OfferReviewView> {
  OfferData? _offer;
  bool _deciding = false;

  int get _id => int.tryParse(widget.inquiryId) ?? 0;

  void _reload() => context.read<InquiryBloc>().add(LoadOffer(_id));

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/app/inquiries');
    }
  }

  void _accept() {
    setState(() => _deciding = true);
    context.read<InquiryBloc>().add(AcceptOffer(_id));
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Odbijanje ponude'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Razlog odbijanja dobija stručnjak za lokacije.',
                  style:
                      AppTypography.bodySmall.copyWith(color: AppColors.text2),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  minLines: 3,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Razlog odbijanja',
                    hintText: 'Npr. cena iznad budžeta, drugi period kampanje…',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Otkaži'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() => _deciding = true);
                context.read<InquiryBloc>().add(
                      RejectOffer(_id, reasonController.text),
                    );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: Colors.white,
              ),
              child: const Text('Odbij ponudu'),
            ),
          ],
        );
      },
    ).whenComplete(reasonController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InquiryBloc, InquiryState>(
      listener: (context, state) {
        if (state is OfferAccepted) {
          showInquirySnack(
              context, 'Ponuda je prihvaćena. Kampanja je kreirana.',
              success: true);
          if (state.campaignId != null) {
            context.go('/app/campaigns/${state.campaignId}');
          } else {
            _leave();
          }
        }
        if (state is InquiryActionSuccess) {
          showInquirySnack(context, state.message);
          _leave();
        }
        if (state is InquiryError) {
          setState(() => _deciding = false);
          if (_offer != null) {
            showInquirySnack(context, InquiryErrors.describe(state.message),
                error: true);
          }
        }
      },
      builder: (context, state) {
        if (state is OfferLoaded) _offer = state.offer;
        final offer = _offer;
        final wide = InquiryLayout.isWide(context);

        final Widget body;
        if (offer == null) {
          body = state is InquiryError
              ? InquiryErrorView(
                  error: state.message,
                  onRetry: _reload,
                  title: 'Ponuda nije učitana',
                )
              : const InquiryLoadingView();
        } else {
          body = _buildContent(offer);
        }

        final showBar = !wide && offer != null && offer.awaitsDecision;
        return InquiryScaffold(
          title: 'Ponuda za upit #$_id',
          body: body,
          bottomBar: showBar
              ? _DecisionBar(
                  children: [
                    Expanded(child: _rejectButton()),
                    const SizedBox(width: 12),
                    Expanded(child: _acceptButton()),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _acceptButton() {
    return FilledButton.icon(
      onPressed: _deciding ? null : _accept,
      icon: _deciding
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.check_rounded, size: 19),
      label: const Text('Prihvati ponudu'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.success.withValues(alpha: 0.55),
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _rejectButton() {
    return OutlinedButton(
      onPressed: _deciding ? null : _showRejectDialog,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.destructive,
        side: BorderSide(color: AppColors.destructive.withValues(alpha: 0.45)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: const Text('Odbij ponudu'),
    );
  }

  Widget _buildContent(OfferData offer) {
    final wide = InquiryLayout.isWide(context);
    return LayoutBuilder(builder: (context, constraints) {
      final gutter = InquiryLayout.gutter(constraints.maxWidth, wide: wide);
      final contentWidth = constraints.maxWidth - 2 * gutter;
      final twoColumns = contentWidth >= 1000;

      final groups = _OwnerGroups(offer: offer);
      final total = _TotalCard(offer: offer);
      final Widget decision = offer.awaitsDecision
          ? _DecisionCard(
              accept: _acceptButton(),
              reject: _rejectButton(),
              pdf: PdfDownloadButton(
                  inquiryId: _id, role: widget.role, expand: true),
            )
          : _OutcomeCard(
              offer: offer,
              pdf: PdfDownloadButton(
                  inquiryId: _id, role: widget.role, expand: true),
            );

      final List<Widget> content;
      if (twoColumns) {
        content = [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: groups),
              const SizedBox(width: 24),
              SizedBox(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [total, const SizedBox(height: 16), decision],
                ),
              ),
            ],
          ),
        ];
      } else {
        content = [
          groups,
          const SizedBox(height: 16),
          total,
          const SizedBox(height: 16),
          if (wide || !offer.awaitsDecision)
            decision
          else
            PdfDownloadButton(inquiryId: _id, role: widget.role, expand: true),
        ];
      }

      return ListView(
        padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 40),
        children: [
          const InquiryHeader(title: 'Pregled ponude', showBack: true),
          _SummaryCard(offer: offer, inquiryId: _id),
          const SizedBox(height: 20),
          ...content,
        ],
      );
    });
  }
}

/// Tamna kartica na vrhu: upit, period, broj površina, vlasnika i gradova,
/// klijent i ukupan iznos po valuti.
class _SummaryCard extends StatelessWidget {
  final OfferData offer;
  final int inquiryId;

  const _SummaryCard({required this.offer, required this.inquiryId});

  @override
  Widget build(BuildContext context) {
    final totals = CurrencyTotals.labels(offer.totals);
    final days = offer.days;
    // "16.11. – 29.11.2026. (14 dana)"
    final dates = SrFormat.period(offer.startDate, offer.endDate);
    final period = offer.startDate == null && offer.endDate == null
        ? null
        : days == null
            ? dates
            : '$dates (${SrFormat.daysLabel(days)})';
    // "4 površine, 2 vlasnika medija, 2 grada"
    final counts = [
      SrFormat.count(offer.unitCount, 'površina', 'površine', 'površina'),
      if (offer.ownerCount > 0)
        SrFormat.count(offer.ownerCount, 'vlasnik medija', 'vlasnika medija',
            'vlasnika medija'),
      if (offer.citiesCount > 0)
        SrFormat.count(offer.citiesCount, 'grad', 'grada', 'gradova'),
    ].join(', ');
    final client = offer.requesterName ?? '';
    final line = AppTypography.bodyMedium.copyWith(color: AppColors.inkText);

    return LayoutBuilder(builder: (context, constraints) {
      final roomy = constraints.maxWidth >= 640;
      final info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OfferStatusPill(status: offer.status),
              if (offer.generatedAt != null)
                Text(
                  'Pripremljena ${SrFormat.date(offer.generatedAt)}',
                  style:
                      AppTypography.caption.copyWith(color: AppColors.inkMuted),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Objedinjena ponuda za upit #$inquiryId',
            style: (roomy ? AppTypography.h3 : AppTypography.h4)
                .copyWith(color: Colors.white),
          ),
          if (period != null) ...[
            const SizedBox(height: 6),
            Text(period, style: line),
          ],
          if (offer.unitCount > 0) ...[
            const SizedBox(height: 14),
            Text(counts, style: line),
          ],
          if (client.isNotEmpty) ...[
            SizedBox(height: offer.unitCount > 0 ? 2 : 14),
            Text(client, style: line),
          ],
        ],
      );

      final total = Column(
        crossAxisAlignment:
            roomy ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Ukupno',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 4),
          if (totals.isEmpty)
            Text('—',
                style: AppTypography.money
                    .copyWith(color: Colors.white, fontSize: 34))
          else
            for (final label in totals)
              Text(
                label,
                style: AppTypography.money.copyWith(
                    color: Colors.white,
                    fontSize: roomy ? 34 : 30,
                    height: 1.15),
              ),
          if (offer.budget != null) ...[
            const SizedBox(height: 6),
            Text(
              'Budžet ${SrFormat.money(offer.budget, 'EUR')}',
              style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      );

      return Container(
        padding: EdgeInsets.all(roomy ? 28 : 20),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.inkLine),
        ),
        child: roomy
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: info),
                  const SizedBox(width: 24),
                  total,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [info, const SizedBox(height: 20), total],
              ),
      );
    });
  }
}

/// Stavke ponude grupisane po vlasniku medija.
class _OwnerGroups extends StatelessWidget {
  final OfferData offer;

  const _OwnerGroups({required this.offer});

  @override
  Widget build(BuildContext context) {
    final groups = offer.groups;
    if (groups.isEmpty) {
      return const SectionCard(
        child: EmptyState(
          compact: true,
          icon: Icons.view_quilt_outlined,
          title: 'Ponuda još nema stavki',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var g = 0; g < groups.length; g++) ...[
          if (g > 0) const SizedBox(height: 16),
          SectionCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OwnerGroupHeader(
                  name: groups[g].displayName,
                  countLabel: SrFormat.count(groups[g].items.length, 'površina',
                      'površine', 'površina'),
                  totals: CurrencyTotals.labels(groups[g].totals),
                ),
                const SizedBox(height: 10),
                const Divider(),
                for (var i = 0; i < groups[g].items.length; i++) ...[
                  if (i > 0) const Divider(color: AppColors.borderSoft),
                  _OfferItemRow(item: groups[g].items[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _OfferItemRow extends StatelessWidget {
  final OfferItemData item;

  const _OfferItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final price = item.finalPrice;
    return InquiryUnitRow(
      unit: item.summary,
      trailing: (context, narrow) => PriceColumn(
        amount: price == null
            ? 'Cena nije potvrđena'
            : SrFormat.money(price, item.priceCurrency),
        caption: price == null
            ? null
            : SrFormat.cyclesLabel(item.cycles, item.effectiveCycleType),
        muted: price == null,
      ),
    );
  }
}

/// Ukupno po valuti; iznosi u različitim valutama se ne sabiraju.
class _TotalCard extends StatelessWidget {
  final OfferData offer;

  const _TotalCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final totals = offer.totals;
    return SectionCard(
      title: 'Ukupno',
      subtitle: [
        SrFormat.count(offer.unitCount, 'površina', 'površine', 'površina'),
        if (offer.ownerCount > 0)
          SrFormat.count(offer.ownerCount, 'vlasnik medija', 'vlasnika medija',
              'vlasnika medija'),
      ].join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (totals.isEmpty)
            Text('Cene još nisu potvrđene',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.mutedForeground))
          else
            for (final entry in totals.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      CurrencyTotals.displayCurrency(entry.key) ?? 'Iznos',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.mutedForeground),
                    ),
                    const Spacer(),
                    Text(
                      SrFormat.money(entry.value,
                          CurrencyTotals.displayCurrency(entry.key)),
                      style: AppTypography.money.copyWith(fontSize: 24),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// Odluka klijenta: odbij ili prihvati ponudu, i PDF ponude.
class _DecisionCard extends StatelessWidget {
  final Widget accept;
  final Widget reject;
  final Widget pdf;

  const _DecisionCard(
      {required this.accept, required this.reject, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Odluka',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: reject),
              const SizedBox(width: 12),
              Expanded(child: accept),
            ],
          ),
          const SizedBox(height: 12),
          pdf,
        ],
      ),
    );
  }
}

/// Ishod kada je o ponudi već odlučeno: naslov, jedna kratka rečenica i
/// dugmad.
class _OutcomeCard extends StatelessWidget {
  final OfferData offer;
  final Widget pdf;

  const _OutcomeCard({required this.offer, required this.pdf});

  @override
  Widget build(BuildContext context) {
    final (String title, String? text) = offer.isAccepted
        ? ('Ponuda je prihvaćena', 'Kampanja je kreirana.')
        : offer.isRejected
            ? ('Ponuda je odbijena', 'Kampanja nije kreirana.')
            : ('Ponuda je u pripremi', null);

    return SectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (text != null) ...[
            Text(text,
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.text2)),
            const SizedBox(height: 12),
          ],
          if (offer.isAccepted && offer.campaignId != null) ...[
            FilledButton(
              onPressed: () =>
                  context.push('/app/campaigns/${offer.campaignId}'),
              child: const Text('Otvori kampanju'),
            ),
            const SizedBox(height: 12),
          ],
          pdf,
        ],
      ),
    );
  }
}

/// Donja traka sa odlukom na telefonu.
class _DecisionBar extends StatelessWidget {
  final List<Widget> children;

  const _DecisionBar({required this.children});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
              color: Color(0x14111433), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: children),
        ),
      ),
    );
  }
}
