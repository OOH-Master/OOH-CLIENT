# OOH Mobile

Flutter aplikacija za Out-of-Home (OOH) advertising platformu.

## Quick Start

```bash
flutter pub get
flutter gen-l10n
flutter run -d chrome
```

## Struktura

```
lib/
├── app/          # App, DI (GetIt), Router (GoRouter)
├── core/         # Theme, l10n, responsive, widgets, api config
└── features/
    ├── admin/              # Admin konfiguracija (šifarnici)
    ├── agency/             # Agencija - upravljanje brendovima
    ├── auth/               # JWT autentikacija
    ├── campaign/           # Kampanje
    ├── dashboard/          # Role-based dashboard
    ├── discover/           # Javna pretraga inventara
    ├── inquiry/            # Upiti
    ├── inventory_management/ # Upravljanje inventarom
    ├── landing/            # Landing stranica
    ├── profile/            # Korisnički profil
    └── shell/              # Responsive navigation (sidebar/bottom nav)
```

## Dokumentacija

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Detaljna arhitektura
- [STYLING.md](docs/STYLING.md) - Design system
- [WIDGETS.md](docs/WIDGETS.md) - Komponente
- [SETUP.md](docs/SETUP.md) - Setup uputstvo

## Jezici

- Srpski (default)
- English
