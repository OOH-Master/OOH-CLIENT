/// Srpski nazivi za vrednosti koje stižu iz API-ja na engleskom ili kao enum
/// (statusi, tipovi površina, okruženje, države, gradovi). Jedno mesto, da nijedan
/// ekran ne prikaže "OTHER", "BRAND", "Quotes Requested" ili "4 weeks".
class SrLabels {
  SrLabels._();

  static const Map<String, String> _countries = {
    'serbia': 'Srbija',
    'croatia': 'Hrvatska',
    'bosnia and herzegovina': 'Bosna i Hercegovina',
    'bosnia & herzegovina': 'Bosna i Hercegovina',
    'montenegro': 'Crna Gora',
    'slovenia': 'Slovenija',
    'north macedonia': 'Severna Makedonija',
    'macedonia': 'Severna Makedonija',
    'hungary': 'Mađarska',
    'romania': 'Rumunija',
    'bulgaria': 'Bugarska',
  };

  // Gradovi iz uvoza su bez dijakritika ili na engleskom.
  static const Map<String, String> _cities = {
    'belgrade': 'Beograd',
    'nis': 'Niš',
    'novi sad': 'Novi Sad',
    'kragujevac': 'Kragujevac',
    'varazdin': 'Varaždin',
    'cakovec': 'Čakovec',
    'siroki brijeg': 'Široki Brijeg',
    'ljubuski': 'Ljubuški',
    'sibenik': 'Šibenik',
    'pozega': 'Požega',
    'kraljevo': 'Kraljevo',
    'cacak': 'Čačak',
    'sabac': 'Šabac',
    'zrenjanin': 'Zrenjanin',
    'subotica': 'Subotica',
    'pancevo': 'Pančevo',
    'krizevci': 'Križevci',
    'vinkovci': 'Vinkovci',
    'bihac': 'Bihać',
    'zenica': 'Zenica',
    'brcko': 'Brčko',
    'bijeljina': 'Bijeljina',
    'gradiska': 'Gradiška',
    'trebinje': 'Trebinje',
    'podgorica': 'Podgorica',
  };

  static String country(String? name) {
    if (name == null || name.isEmpty) return '';
    return _countries[name.toLowerCase().trim()] ?? name;
  }

  static String city(String? name) {
    if (name == null || name.isEmpty) return '';
    return _cities[name.toLowerCase().trim()] ?? name;
  }

  /// "Beograd, Srbija"
  static String place(String? city, String? country) {
    final c = SrLabels.city(city);
    final k = SrLabels.country(country);
    if (c.isEmpty) return k;
    if (k.isEmpty) return c;
    return '$c, $k';
  }

  static bool isDigital(String? unitType) {
    final v = (unitType ?? '').toLowerCase();
    return v.contains('digital') ||
        v.contains('led') ||
        v.contains('hybrid') ||
        v.contains('rotating');
  }

  /// Tip površine: "Statična", "Digitalna", "Hibridna", "Rotaciona".
  static String unitType(String? name) {
    final v = (name ?? '').toLowerCase();
    if (v.isEmpty) return '';
    if (v.contains('hybrid')) return 'Hibridna';
    if (v.contains('rotating') || v.contains('scrolling')) return 'Rotaciona';
    if (v.contains('audio only')) return 'Digitalna, zvuk';
    if (v.contains('digital')) return 'Digitalna';
    if (v.contains('static')) return 'Statična';
    return name!;
  }

  /// Format: "Bilbord", "City light", "Digitalni zid"...
  static String format(String? name) {
    final raw = (name ?? '').trim();
    final v = raw.toLowerCase();
    if (v.isEmpty) return '';
    const exact = {
      'clp': 'City light',
      'citylight': 'City light',
      'city light': 'City light',
      'digi-wall': 'Digitalni zid',
      'dep': 'Ekran u liftu',
      'street furniture': 'Urbani mobilijar',
      'digital': 'LED bilbord',
      'analog': 'Analogni',
      'digital/led': 'Digitalni / LED',
      'lcd': 'LCD ekran',
      'scroll': 'Skrol panel',
      'giant poster': 'Monumentalni plakat',
      'billboard': 'Bilbord',
    };
    if (exact.containsKey(v)) return exact[v]!;
    // redosled je bitan: duži, određeniji nazivi pre opštijih
    const contains = [
      ['double-sided digital citylight', 'Dvostrani digitalni city light'],
      ['digital citylight', 'Digitalni city light'],
      ['digital city light', 'Digitalni city light'],
      ['backlight', 'Osvetljeni panel'],
      ['digital wall', 'Digitalni zid'],
      ['digital screen', 'Digitalni ekran'],
      ['elevator', 'Ekran u liftu'],
      ['totem', 'Digitalni totem'],
      ['giant poster', 'Monumentalni plakat'],
      ['monumental', 'Monumentalni plakat'],
      ['megaboard', 'Megabord'],
      ['wideboard', 'LED vajdbord'],
      ['tower', 'Digitalni toranj'],
      ['banner', 'Digitalni baner'],
      ['neon', 'Neonski natpis'],
      ['led billboard', 'LED bilbord'],
      ['digital billboard', 'LED bilbord'],
      ['digital marof', 'LED bilbord'],
      ['tomahawk', 'Tomahavk'],
    ];
    for (final rule in contains) {
      if (v.contains(rule[0])) return rule[1];
    }
    if (v.startsWith('billboard')) {
      final dims = RegExp(r'(\d+\s*[x×]\s*\d+)').firstMatch(raw)?.group(1);
      return dims == null ? 'Bilbord' : 'Bilbord ${dims.replaceAll('x', '×')}';
    }
    return raw;
  }

  /// Okruženje (venue type ili enum environment): "Pored puta", "Tržni centar"...
  static String venue(String? name) {
    final v = (name ?? '').toLowerCase().trim();
    if (v.isEmpty) return '';
    if (v.contains('roadside')) return 'Pored puta';
    if (v.contains('mall')) return 'Tržni centar';
    if (v.contains('airport')) return 'Aerodrom';
    if (v.contains('transit') || v == 'bus') return 'Javni prevoz';
    if (v.contains('office')) return 'Poslovni prostor';
    if (v.contains('pedestrian')) return 'Pešačka zona';
    if (v.contains('indoor')) return 'Zatvoreni prostor';
    if (v.contains('place-based') || v == 'other') return 'Javni prostor';
    return name!;
  }

  /// Osvetljenje: "Osvetljena", "Pozadinsko osvetljenje"...
  static String illumination(String? value) {
    final v = (value ?? '').toLowerCase().replaceAll('_', ' ').trim();
    if (v.isEmpty || v == 'unknown') return '';
    if (v.contains('not')) return 'Bez osvetljenja';
    if (v.contains('back')) return 'Pozadinsko osvetljenje';
    if (v.contains('front')) return 'Prednje osvetljenje';
    if (v.contains('ambient')) return 'Ambijentalno osvetljenje';
    if (v.contains('illuminated')) return 'Osvetljena';
    return value!;
  }

  /// "4 × 3 m"
  static String dimensions(num? width, num? height, String? unit) {
    if (width == null || height == null || width <= 0 || height <= 0) return '';
    String n(num x) => x == x.roundToDouble()
        ? x.toInt().toString()
        : x.toString().replaceAll('.', ',');
    return '${n(width)} × ${n(height)} ${unit ?? 'm'}';
  }

  static String requesterType(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'BRAND':
        return 'Brend';
      case 'AGENCY':
        return 'Agencija';
      default:
        return raw ?? '';
    }
  }

  static String inquiryType(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'UNIT_SELECTION':
        return 'Izbor površina';
      case 'BRIEF':
        return 'Brif kampanje';
      default:
        return raw ?? '';
    }
  }

  static String inquiryStatus(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'SUBMITTED':
        return 'Podnet';
      case 'IN_PROGRESS':
        return 'U obradi';
      case 'QUOTES_REQUESTED':
        return 'Čeka cene vlasnika';
      case 'PRICING_READY':
        return 'Cene spremne';
      case 'OFFER_SENT':
        return 'Ponuda poslata';
      case 'ACCEPTED_BY_CLIENT':
        return 'Prihvaćeno';
      case 'REJECTED_BY_CLIENT':
        return 'Odbijeno';
      case 'REALIZED':
        return 'Realizovano';
      case 'CLOSED':
        return 'Zatvoreno';
      default:
        return raw ?? '';
    }
  }

  static String quoteStatus(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'NEW':
        return 'Novi zahtev';
      case 'IN_PROGRESS':
        return 'U izradi';
      case 'SUBMITTED':
        return 'Cene poslate';
      case 'DECLINED':
        return 'Odbijeno';
      default:
        return raw ?? '';
    }
  }

  static String offerStatus(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'DRAFT':
        return 'U pripremi';
      case 'SENT':
        return 'Čeka odluku';
      case 'ACCEPTED':
        return 'Prihvaćena';
      case 'REJECTED':
        return 'Odbijena';
      default:
        return raw ?? '';
    }
  }

  static String campaignStatus(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'DRAFT':
        return 'Nacrt';
      case 'IN_NEGOTIATION':
        return 'U pregovorima';
      case 'BOOKED':
        return 'Zakupljena';
      case 'RUNNING':
        return 'U toku';
      case 'FINISHED':
        return 'Završena';
      case 'CANCELLED':
        return 'Otkazana';
      default:
        return raw ?? '';
    }
  }

  /// Uloga korisnika: API ime enuma ("brand", "mediaOwner", "MEDIA_OWNER"...).
  static String role(String? raw) {
    final v = (raw ?? '').toLowerCase().replaceAll('_', '');
    switch (v) {
      case 'brand':
        return 'Brend';
      case 'agency':
        return 'Agencija';
      case 'mediaowner':
        return 'Vlasnik medija';
      case 'admin':
      case 'internaladmin':
        return 'Stručnjak za lokacije';
      default:
        return raw ?? '';
    }
  }
}
