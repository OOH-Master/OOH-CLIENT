import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';

/// Ilustracija tamnog panela: fotografija i opis za čitače ekrana.
class AuthArt {
  final String asset;
  final String title;
  final String place;
  final bool digital;

  const AuthArt(this.asset, this.title, this.place, {this.digital = false});

  static const ledSlavija = AuthArt(
    'assets/images/led-slavija.jpg',
    'Digitalni ekran',
    'Slavija, Beograd',
    digital: true,
  );

  static const citylight = AuthArt(
    'assets/images/citylight-knez-mihailova.jpg',
    'City light',
    'Knez Mihailova, Beograd',
  );

  static const bilbord = AuthArt(
    'assets/images/bilbord-brankov-most.jpg',
    'Bilbord',
    'Brankov most, Beograd',
  );
}

/// Okvir svih ekrana prijave: na širokom ekranu tamni panel sa porukom platforme
/// levo i bela forma desno; na telefonu jedna kolona sa malim zaglavljem.
class AuthShell extends StatelessWidget {
  final Widget child;
  final AuthArt art;
  final String headline;
  final String lead;

  /// Kada postoji, gore levo stoji "Nazad" umesto veze ka početnoj strani.
  final VoidCallback? onBack;
  final double maxFormWidth;

  const AuthShell({
    super.key,
    required this.child,
    this.art = AuthArt.ledSlavija,
    this.headline = 'Oglasne površine regiona na jednom mestu.',
    this.lead =
        'Pronađite lokaciju, proverite cenu za period zakupa i pošaljite upit vlasnicima medija.',
    this.onBack,
    this.maxFormWidth = 420,
  });

  static const double splitBreakpoint = 960;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= splitBreakpoint;

    final form = _FormSide(
      wide: wide,
      onBack: onBack,
      maxWidth: maxFormWidth,
      child: child,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: _BrandPanel(
                    art: art,
                    headline: headline,
                    lead: lead,
                  ),
                ),
                Expanded(flex: 6, child: form),
              ],
            )
          : form,
    );
  }
}

class _FormSide extends StatelessWidget {
  final bool wide;
  final VoidCallback? onBack;
  final double maxWidth;
  final Widget child;

  const _FormSide({
    required this.wide,
    required this.onBack,
    required this.maxWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Widget leading;
    if (onBack != null) {
      leading = TextButton.icon(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Nazad'),
        style: TextButton.styleFrom(foregroundColor: AppColors.text2),
      );
    } else if (wide) {
      leading = TextButton.icon(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Početna'),
        style: TextButton.styleFrom(foregroundColor: AppColors.text2),
      );
    } else {
      leading = InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.go('/'),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: BrandMark(size: 30),
        ),
      );
    }

    final hPad = wide ? 48.0 : 20.0;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 12, wide ? 32 : 12, 0),
            child: Row(
              children: [
                leading,
                const Spacer(),
                const _LocaleToggle(),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    hPad, wide ? 24 : 16, hPad, wide ? 48 : 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocaleToggle extends StatelessWidget {
  const _LocaleToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Tooltip(
          message: 'Jezik',
          child: TextButton(
            onPressed: () => context.read<LocaleCubit>().toggle(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mutedForeground,
              minimumSize: const Size(44, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text(
              locale.languageCode == 'sr' ? 'EN' : 'SR',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tamni panel: znak, poruka platforme, jedna rečenica i fotografija površine.
class _BrandPanel extends StatelessWidget {
  final AuthArt art;
  final String headline;
  final String lead;

  const _BrandPanel({
    required this.art,
    required this.headline,
    required this.lead,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink,
      child: SafeArea(
        right: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 520;
            final showArt = constraints.maxHeight >= 680;
            final hPad = narrow ? 36.0 : 56.0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 36, hPad, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BrandMark(onDark: true, size: 34),
                        const Spacer(),
                        const SizedBox(height: 32),
                        Text(
                          headline,
                          style: AppTypography.displaySmall.copyWith(
                            color: Colors.white,
                            fontSize: narrow ? 32 : 40,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Text(
                            lead,
                            style: AppTypography.bodyLarge
                                .copyWith(color: AppColors.inkMuted),
                          ),
                        ),
                        if (showArt) ...[
                          const SizedBox(height: 36),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: _ArtImage(art: art),
                          ).animate().fadeIn(duration: 450.ms),
                        ],
                        const Spacer(),
                        const SizedBox(height: 24),
                        Text(
                          'Srbija, Hrvatska, Bosna i Hercegovina',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Fotografija površine, ravna, sa tankom ivicom.
class _ArtImage extends StatelessWidget {
  final AuthArt art;

  const _ArtImage({required this.art});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inkLine),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            art.asset,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            semanticLabel: '${art.title}, ${art.place}',
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: AppColors.inkRaised),
          ),
        ),
      ),
    );
  }
}

/// Naslov forme i kratko objašnjenje (ili red sa vezom) ispod njega.
class AuthHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? below;

  const AuthHeading(
      {super.key, required this.title, this.subtitle, this.below});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h2.copyWith(fontSize: 28)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.mutedForeground),
          ),
        ],
        if (below != null) ...[const SizedBox(height: 8), below!],
      ],
    );
  }
}

/// Oznaka iznad polja forme, sa opcionim elementom desno (npr. veza).
class AuthFieldLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const AuthFieldLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Obaveštenje u formi: greška ili potvrda, u bledoj traci.
class AuthNotice extends StatelessWidget {
  final String message;
  final PillTone tone;

  const AuthNotice(
      {super.key, required this.message, this.tone = PillTone.danger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            tone == PillTone.success
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            size: 18,
            color: tone.foreground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: tone.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dugme sa indikatorom učitavanja; puna širina forme.
class AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}
