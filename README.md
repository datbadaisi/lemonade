# Lemonade

A Flutter client for [Lemmy](https://join-lemmy.org) with a clean, minimal, and simple interface.

---

## Screenshots

<p align="center">
  <img src="docs/images/lemmy-world/screenshot-01.png" alt="Lemonade home feed" width="30%" />
  <img src="docs/images/lemmy-world/screenshot-02.png" alt="Lemonade post view" width="30%" />
  <img src="docs/images/lemmy-world/screenshot-03.png" alt="Lemonade community view" width="30%" />
</p>
<p align="center">
  <img src="docs/images/lemmy-world/screenshot-04.png" alt="Lemonade search" width="30%" />
  <img src="docs/images/lemmy-world/screenshot-05.png" alt="Lemonade comments" width="30%" />
  <img src="docs/images/lemmy-world/screenshot-06.png" alt="Lemonade account" width="30%" />
</p>
<p align="center">
  <img src="docs/images/lemmy-world/screenshot-07.png" alt="Lemonade settings" width="30%" />
  <img src="docs/images/lemmy-world/screenshot-08.png" alt="Lemonade dark theme" width="30%" />
  <img src="docs/images/lemmy-world/screenshot-09.png" alt="Lemonade profile" width="30%" />
</p>

---

## Getting Started

```bash
flutter run
```

---

## Configuration (Optional)

To configure production AdMob, RevenueCat, or custom support email:

1. Copy [`config.example.json`](config.example.json) to `config.json`:
   ```bash
   cp config.example.json config.json
   ```
2. Fill in your keys in `config.json`.
3. Run with:
   ```bash
   flutter run --dart-define-from-file=config.json
   ```

---

## Release Build

For building a signed Android App Bundle (AAB):
```bash
flutter build appbundle --release --dart-define-from-file=config.json
```
*(Signing keys are configured in `android/key.properties`, see [`android/key.properties.example`](android/key.properties.example)).*

---

## License

GNU General Public License v3.0 (GPL-3.0). See [LICENSE](LICENSE).

*App branding and logo in `assets/branding/` are proprietary trademarks.*

---

## Contributors LLMs

This project is developed with assistance from various large language models (LLMs).
