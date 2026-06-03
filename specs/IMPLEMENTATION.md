# IMPLEMENTATION.md - Buss App Development Plan

This phased implementation plan guides the development of the **Buss App**. Each phase focuses on a specific layer, ending with code hygiene checks and a git commit.

---

## Phase 1: Setup & Initial Commit
*Setup the empty project baseline, update configurations, and commit.*

- [x] Remove default boilerplate in `lib/main.dart` and the `test` directory.
- [x] Update description in `pubspec.yaml` and set package version to `0.1.0`.
- [x] Create `CHANGELOG.md` with version `0.1.0` and a brief initial release note.
- [x] Update `README.md` with a placeholder project description.
- [x] Verify project builds, commit changes to `feature/buss-app-base` after user review.
- [x] Start running the application using the `launch_app` tool to verify deployment.

---

## Phase 2: Dependencies & Themes
*Add external libraries and establish the design system tokens.*

- [x] Add packages in `pubspec.yaml`:
  - `google_fonts: ^6.2.1` (for Plus Jakarta Sans)
  - `sqflite: ^2.3.3` (for local storage)
  - `path: ^1.9.0` (for local file paths)
  - `path_provider: ^2.1.3` (for SQLite folder directory)
  - `supabase_flutter: ^2.6.0` (for Cloud API connection)
  - `url_launcher: ^6.3.0` (for WhatsApp connection link)
- [x] Create core theme file `lib/core/theme/app_theme.dart` with design rules:
  - Background `#faf9fe`
  - Primary `#000000`
  - Secondary text `#5d5f5f`
  - Radius definitions (32px cards, 16px buttons/inputs)
- [x] Run `flutter pub get` and verify compilation.

---

## Phase 3: Data Access (SQLite & Supabase)
*Implement local databases, remote clients, repository layer, and seed data.*

- [x] Create `lib/core/database/local_database.dart` using `sqflite` to initialize tables:
  - `stations`
  - `buses`
  - `bookings`
- [x] Create seed data inside `local_database.dart` so the app is fully functional offline out-of-the-box.
- [x] Create `lib/core/api/supabase_client.dart` to initialize the Supabase client with placeholders (user-configurable keys).
- [x] Define shared models:
  - `features/home/data/trip_model.dart`
  - `features/map/data/station_model.dart`
  - `features/buses/data/bus_model.dart`
  - `features/private_transport/data/booking_model.dart`
- [x] Run analysis and tests to ensure database migrations work.

---

## Phase 4: Shared Reusable UI Components
*Build independent widgets for buttons, text fields, cards, and navigation.*

- [x] Build `lib/core/widgets/custom_button.dart`:
  - `PrimaryButton` (Solid black pill, white text)
  - `SecondaryButton` (Translucent light gray, black text)
  - `ContactButton` (WhatsApp green button with icon)
- [x] Build `lib/core/widgets/custom_text_field.dart`:
  - Search field style with prefix search icon
  - Standard input field with light gray container background
- [x] Build `lib/core/widgets/bottom_nav_bar.dart` (Translucent floating pill using backdrop blur).

---

## Phase 5: Feature Screens Development
*Implement the 4 screens with specific design layout elements.*

- [x] **Inicio Screen (`lib/features/home/presentation/home_screen.dart`):**
  - Search & filter bar, horizontal categories list.
  - Featured Bus Trip Cards with rating stars, bookmark icons, price/duration tags, and "View details" buttons.
- [x] **Mapa Screen (`lib/features/map/presentation/map_screen.dart`):**
  - High-fidelity map style overlay representation (minimalist/blue-toned visual header).
  - Floating my-location and zoom action buttons.
  - Nearby station card list showing distances (e.g. 0.4 km) and live countdown (e.g. 3 min).
  - Zenith Exclusive Live-tracked fleet banner.
- [x] **Autobuses Screen (`lib/features/buses/presentation/buses_screen.dart`):**
  - Grid/List of bus units.
  - Status badges ("En Servicio" with pulsing green indicator, "En Mantenimiento" in grayscale).
  - Phone, operating hours, capacity (Pax count), and active WhatsApp contact button.
- [x] **Transporte Privado Screen (`lib/features/private_transport/presentation/private_transport_screen.dart`):**
  - Hero image of luxury private van.
  - Features list (Luxury Vans, Pro Chauffeurs, Door-to-door).
  - Booking form with pick-up/drop-off text inputs, date picker, time picker, and "Request Quote" button (with calculating spin animation).
  - List of bookings loaded from local SQLite database showing status.

---

## Phase 6: Sync logic, Quality Assurance & Formatting
*Connect local storage saving to cloud database API, cleanup code, and finalize.*

- [x] Connect booking submission: save in local SQLite and asynchronously try to upload to Supabase database.
- [x] Run `dart_fix` and solve any lint issues.
- [x] Run `dart_format` to enforce visual consistency.
- [x] Perform manual run testing on Windows desktop device to ensure all 4 pages operate correctly.
- [x] Write `README.md` and `GEMINI.md` describing project layout, setup instructions, and database details.

---

## Journal
*A log of implementation progress, learnings, surprises, and plan adjustments.*

* **2026-06-03:** Initial plan created.
* **2026-06-03:** Added dependencies and configured theme.
* **2026-06-03:** Set up Local Database (SQLite with in-memory kIsWeb fallback for browser running) and Supabase client adapter.
- **2026-06-03:** Created reusable components and all 4 screens (Inicio, Mapa, Autobuses, Transporte Privado). Added WhatsApp launchers and booking quotes. Verified that project compiles with 0 analyzer errors and launched successfully on Chrome.
