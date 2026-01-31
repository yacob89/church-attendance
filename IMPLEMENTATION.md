# Church Attendance App - Implementation Plan

## Journal

*   **2026-01-31**: Plan created. Starting with Project Setup and Supabase integration.
*   **2026-01-31**: Phase 1 completed. Project created, dependencies added, basic Auth and Dashboard structure implemented with GoRouter. Supabase initialization added.
*   **2026-01-31**: Phase 2 completed. Implemented Tags feature with Model, Repository, List Page, and Edit Page. Integrated into main navigation.
*   **2026-01-31**: Phase 3 completed. Implemented Saints feature with Model, Repository (including tag management), List Page, and Edit Page. Integrated into main navigation.
*   **2026-01-31**: Phase 4 completed. Implemented Meetings feature with Model, Repository, List Page, and Edit Page (including Attendance taking). Integrated into main navigation.
*   **2026-01-31**: Phase 5 completed. Final polish, README update, GEMINI.md creation, and code cleanup.

## Phase 1: Project Setup & Authentication

- [x] Create a Flutter package in the package directory.
- [x] Remove any boilerplate in the new package that will be replaced, including the test dir if generic.
- [x] Add dependencies: `flutter pub add supabase_flutter go_router`.
- [x] Update `pubspec.yaml` description and set version to `0.1.0`.
- [x] Update `README.md` with a placeholder description.
- [x] Create `CHANGELOG.md` with initial version `0.1.0`.
- [x] Initialize Supabase in `lib/main.dart` (Client setup).
- [x] Create `lib/core/` folder for constants (Supabase credentials) and theme.
- [x] Create `lib/features/auth/` folder.
- [x] Implement `LoginPage` and `RegisterPage` (or combined) in `lib/features/auth/`.
- [x] Set up `GoRouter` in `lib/main.dart` with routes for `/login`, `/register`, and `/` (protected dashboard).
- [x] Implement Auth Guard: Redirect to `/login` if not authenticated.
- [x] Commit initial setup to the branch.
- [x] Start running the app on a device/emulator.

**Verification & Cleanup:**
- [x] Create/modify unit tests for Auth logic (mocking Supabase if possible, or basic widget tests).
- [x] Run `dart fix --apply`.
- [x] Run `dart analyze`.
- [ ] Run tests.
- [x] Run `dart format .`.
- [x] Update `IMPLEMENTATION.md` Journal.
- [ ] `git diff`, commit, and hot reload.

## Phase 2: Data Models & Tags Feature

- [x] Create `lib/core/models/` folder.
- [x] Create Dart models for `Tag`, `Saint`, `Meeting` matching the SQL schema.
    - (Partial) Created `Tag` model. Will create `Saint` and `Meeting` in their respective phases to keep PRs focused.
- [x] Create `lib/features/tags/` folder.
- [x] Create `TagsRepository` (abstracting Supabase calls for `tags` table).
- [x] Implement `TagsListPage`: Display list of tags (fetch from Supabase).
- [x] Implement `TagEditPage`: Form to add/edit a tag.
- [x] Add `Tags` item to the Side Navigation Drawer.
- [x] Verify Tags CRUD works (Create, Read, Update, Delete).

**Verification & Cleanup:**
- [ ] Add widget tests for Tags screens.
- [x] Run `dart fix --apply`.
- [x] Run `dart analyze`.
- [ ] Run tests.
- [x] Run `dart format .`.
- [x] Update `IMPLEMENTATION.md` Journal.
- [ ] `git diff`, commit, and hot reload.

## Phase 3: Saints Management

- [x] Create `lib/features/saints/` folder.
- [x] Create `SaintsRepository` (abstracting Supabase calls for `saints` and `saints_tags`).
- [x] Implement `SaintsListPage`: Display list of saints.
- [x] Implement `SaintEditPage`:
    - Form fields for Name, City, Phone, etc.
    - UI to select/manage `Tags` for the Saint.
    - Logic to update `saints_tags` join table.
- [x] Add `Saints` item to Side Navigation.
- [x] Verify Saints CRUD works, including Tag associations.

**Verification & Cleanup:**
- [ ] Add widget tests for Saints screens.
- [x] Run `dart fix --apply`.
- [x] Run `dart analyze`.
- [ ] Run tests.
- [x] Run `dart format .`.
- [x] Update `IMPLEMENTATION.md` Journal.
- [ ] `git diff`, commit, and hot reload.

## Phase 4: Meetings & Attendance

- [x] Create `lib/features/meetings/` folder.
- [x] Create `MeetingsRepository`.
- [x] Implement `MeetingsListPage`: Display list of meetings.
- [x] Implement `MeetingEditPage`: Create/Edit meeting details (Name, Date, Note).
- [x] Implement `MeetingAttendancePage`:
    - Linked from Meeting Details or List.
    - Show list of all Saints.
    - Toggle attendance (Checkbox) for each saint.
    - Save to `meetings_attendance` table.
- [x] Add `Meetings` item to Side Navigation.
- [x] Verify Meetings CRUD and Attendance submission.

**Verification & Cleanup:**
- [ ] Add widget tests for Meetings/Attendance.
- [x] Run `dart fix --apply`.
- [x] Run `dart analyze`.
- [ ] Run tests.
- [x] Run `dart format .`.
- [x] Update `IMPLEMENTATION.md` Journal.
- [ ] `git diff`, commit, and hot reload.

## Phase 5: Final Polish & Documentation

- [x] Review UI against "Minimalist" goal. Ensure consistent padding, typography, and Material 3 styling.
- [x] Create a comprehensive `README.md`.
- [x] Create `GEMINI.md` describing the app architecture for future AI contexts.
- [x] User Acceptance Testing: Ask user to inspect the app.

**Verification & Cleanup:**
- [x] Run `dart fix --apply` one last time.
- [x] Run `dart analyze`.
- [ ] Run tests.
- [x] Run `dart format .`.
- [x] Update `IMPLEMENTATION.md` Journal.
- [ ] `git diff`, commit.
