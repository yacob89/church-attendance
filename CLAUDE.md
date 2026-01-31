# Church Attendance App Context

This document describes the architecture and structure of the `church_attendance` Flutter application.

## Overview
A minimalist app for tracking church attendance using Supabase for the backend.

## Architecture
- **Layered Architecture**: `core`, `features`.
- **State Management**: standard `StatefulWidget` + Repository pattern.
- **Navigation**: `go_router`.
- **Backend**: `supabase_flutter`.

## Project Structure
```
lib/
├── core/
│   ├── constants/       # App constants (Supabase credentials)
│   ├── models/          # Data models (Saint, Tag, Meeting)
│   └── theme/           # App theme definitions
├── features/
│   ├── auth/            # Login logic
│   ├── dashboard/       # Main scaffold & drawer
│   ├── meetings/        # Meeting CRUD & Attendance
│   ├── saints/          # Saint CRUD & Tag assignment
│   └── tags/            # Tag CRUD
└── main.dart            # Entry point & Routing
```

## Key Conventions
- **Models**: Simple Dart classes with `fromJson`/`toJson`.
- **Repositories**: Handle all direct Supabase interactions.
- **UI**: Material Design 3. Minimalist.
- **Routing**: Defined in `main.dart` using `GoRouter`.

## Database Schema
Refer to `README.md` for the full SQL schema.
