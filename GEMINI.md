# GEMINI.md - Buss App Recreation Documentation

This document describes the design, implementation, and directory structure of the **Buss App**, created from the custom Zenith/BusGo specifications.

---

## Refactored App Structure & Layout

The project has been refactored to follow a flat layered architecture grouping components by their functional roles (screens, widgets, layouts, models) rather than feature domains.

### Directory Mapping
- **`lib/main.dart`**: Entry point of the application. Initializes database and remote API configs, and mounts the `MainNavigationContainer`.
- **`lib/core/`**: Custom styling, global database helpers, and shared connection managers.
  - **`theme/app_theme.dart`**: Configures the achromatic light-mode theme using the geometric `Plus Jakarta Sans` Google font, with default styles for inputs, cards, and text hierarchy.
  - **`database/local_database.dart`**: Wrapper around `sqflite` initializing the SQL tables (`stations`, `buses`, `bookings`) and inserting seed data. Features a transparent Web fallback that uses in-memory lists if run target is the Web (`kIsWeb`).
  - **`api/supabase_client.dart`**: Connects to the Supabase client API. Contains a safety handler that prevents crash blocks if anon keys are not defined, falling back to database caching mock simulations.
- **`lib/models/`**: Shared entity data models.
  - `trip_model.dart`: Trip details for home exploration.
  - `station_model.dart`: Station locations and timetables.
  - `bus_model.dart`: Public transit fleet models.
  - `booking_model.dart`: Private transport request parameters.
- **`lib/screens/`**: Staging of the 4 main application panels.
  - `home_screen.dart`: General trip feed explorer.
  - `map_screen.dart`: Nearby station list and location markers.
  - `buses_screen.dart`: Bus fleets directories.
  - `private_transport_screen.dart`: Form actions to book executive travel.
- **`lib/widgets/`**: Standalone UI views and elements.
  - `trip_card.dart`, `station_card.dart`, `bus_unit_card.dart`, `booking_form.dart`: Specific detail cards.
  - **`widgets/common/`**: Reusable base styling elements:
    - `custom_button.dart`: Exports `PrimaryButton` (stadium border black action button), `SecondaryButton` (light grey selection action), and `ContactButton` (WhatsApp green service trigger).
    - `custom_text_field.dart`: Exports `SearchTextField` (with settings filter icons) and standard labeled inputs.
- **`lib/layout/`**: Shell containers and bottom navigators.
  - `bottom_nav_bar.dart`: Floating translucent nav bar representing a blurred zinc glassmorphic pill shape.
  - `main_layout.dart`: Houses the `MainNavigationContainer` that manages screen swaps using an `IndexedStack`.

---

## Database Schemas

SQLite local schemas are defined inside [local_database.dart](file:///C:/Users/mgutierrez/Documents/Personal/flutterproyect/buss_app/lib/core/database/local_database.dart):
1. **`stations`**: Stores geographical nearby terminals, distance counts, and next arrival timelines.
2. **`buses`**: Contains public transport models, passenger capacities, operating hours, and contact details.
3. **`bookings`**: Stores local booking request history containing pickup locations, dates, times, and quote states.

---

## Sync Mechanism & Fallback Design

1. **Local-First Caching**: The application queries SQLite first to deliver instant offline loading.
2. **API Handlers**: Background requests upload new quotes to Supabase tables.
3. **Web Compatibility**: On target platforms where Native SQLite is unavailable (e.g. Chrome Web), the helper transparently seeds in-memory collections so the code compiles and runs with 100% feature parity.
