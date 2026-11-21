# Implementation Plan - Car Service Booking System

## Phase 1: Backend Foundation
- [ ] **Task 1: Backend Skeleton Setup**
    - Initialize Django project with DRF.
    - Configure MySQL connection and `.env` loading.
    - Setup basic project structure and `requirements.txt`.
    - *Verification*: `python manage.py runserver` starts without errors; database connection is successful.

- [ ] **Task 2: Custom User Model & Auth**
    - Implement custom `User` model with `role` (client, mechanic, admin).
    - Configure `djangorestframework-simplejwt` with token blacklisting.
    - Create endpoints: `/api/auth/register/`, `/api/auth/login/`, `/api/auth/refresh/`, `/api/auth/logout/`, `/api/auth/me/`.
    - *Tests*: Unit tests for registration, login, refresh, logout, and profile retrieval.
    - *Verification*: Register a user and obtain JWT tokens via `/api/auth/login/`.

- [ ] **Task 3: Database Models**
    - Implement models: `Service`, `Mechanic`, `Booking`, `BookingEvent`.
    - Setup M2M relationship for `mechanic_services`.
    - Run migrations.
    - *Tests*: Unit tests for model constraints and relationships.
    - *Verification*: Check MySQL tables to ensure all 6 custom tables and fields exist.

- [ ] **Task 4: Demo Data Seeding**
    - Create a management command `seed` to populate the database.
    - Requirements: 1 Admin, 1 Mechanic user, 1 Client user, 20 Mechanic profiles, 30+ Bookings across all statuses.
    - *Verification*: Run `python manage.py seed` and verify data in Django Admin.

## Phase 2: Core Booking Logic
- [ ] **Task 5: Mechanic Catalog API**
    - Create endpoints for active Mechanics with search (name/specialization), filtering by service, and pagination.
    - Implement availability logic (busy slots for a specific date).
    - *Tests*: Unit tests for search, filtering, and availability calculation.
    - *Verification*: `GET /api/mechanics/` returns filtered records with busy slots.

- [ ] **Task 6: Basic Booking Creation**
    - Implement `POST /api/bookings/` for clients.
    - Calculate `end_at` based on service duration.
    - Snapshot the price.
    - *Tests*: Unit tests for booking creation and price snapshotting.
    - *Verification*: Create a booking and check if `end_at` and `price` are correctly saved.

- [ ] **Task 7: Concurrency & Overlap Control**
    - Implement `transaction.atomic` and `select_for_update` on the Mechanic record.
    - Add logic to prevent overlapping bookings for the same mechanic.
    - Create a script `test_concurrency.py` to send 10 parallel requests for the same slot (expect 1x201 and 9x409).
    - *Tests*: Unit tests for overlap prevention logic.
    - *Verification*: Concurrency script results match expectations.

- [ ] **Task 8: Status Transition Logic**
    - Implement `PATCH /api/bookings/{id}/status/` with role-based transition rules.
    - Implement `booking_events` logging for every status change within a transaction.
    - *Tests*: Unit tests for all valid and invalid status transitions.
    - *Verification*: Attempt invalid transition (e.g., `created` -> `completed`) and ensure it fails with 409.

- [ ] **Task 9: Lists & Permissions**
    - Implement filtered booking lists: Client sees own, Mechanic sees assigned, Admin sees all.
    - Enforce object-level permissions (404 for unauthorized access to specific booking IDs).
    - *Tests*: Unit tests for role-based access control and object isolation.
    - *Verification*: Log in as Client A and try to access Client B's booking detail; should return 404.

## Phase 3: Admin & Reporting
- [ ] **Task 10: Admin Management API**
    - Create CRUD endpoints for Services and Mechanics.
    - Implement User Management: list users, change roles, toggle `is_active` (block).
    - Implement Global Audit Log (Action Journal) view for `booking_events`.
    - *Tests*: Unit tests for admin-only access and user management actions.
    - *Verification*: Admin can block a user or change a role via API.

- [ ] **Task 11: Reports & Aggregation**
    - Implement reports for Mechanic Load (utilization) and Cancellation counts for a period.
    - Create CSV export endpoint for report data.
    - *Tests*: Unit tests for aggregation logic and date range filtering.
    - *Verification*: `GET /api/reports/mechanic-load/` returns correct stats; CSV file downloads with data.

## Phase 4: Frontend Development
- [ ] **Task 12: Frontend Skeleton**
    - Initialize Vite + React project.
    - Setup Axios instance with JWT handling (interceptors for refresh/logout).
    - Setup React Router.
    - *Verification*: App renders and can make a basic request to the backend.

- [ ] **Task 13: Frontend Authentication**
    - Implement Login and Registration pages.
    - Handle token storage and protected routes.
    - *UI States*: Implement loading spinners and error alerts for failed attempts.
    - *Verification*: User can log in and is redirected to the dashboard; tokens persist on refresh.

- [ ] **Task 14: Mechanic Catalog & Booking Form**
    - Create mechanic catalog with search, service filtering, and pagination.
    - Display mechanic images and specializations.
    - Implement booking form with date/time picker and availability check.
    - *UI States*: Implement skeleton loaders for the list, "not found" message for empty results, and error notifications.
    - *Verification*: Client can search for a mechanic and submit a booking.

- [ ] **Task 15: Client Dashboard**
    - List "My Bookings" with status badges.
    - Implement "Cancel" button for eligible bookings.
    - *UI States*: Implement loading state, "no bookings" message, and error handling for cancellation failures.
    - *Verification*: Client sees their history and can cancel a `created` booking.

- [ ] **Task 16: Mechanic Dashboard**
    - Create schedule view for mechanics (daily bookings).
    - Implement status update buttons (Confirm, Complete, Cancel).
    - *UI States*: Implement loading state, "no tasks for today" message, and error handling for invalid transitions.
    - *Verification*: Mechanic logs in, sees assigned tasks, and changes status to `confirmed`.

- [ ] **Task 17: Admin Management UI**
    - Create tables for managing Services, Mechanics, and Users.
    - Add toggles for `is_active` and forms for editing/role changes.
    - *UI States*: Implement loading indicators for each table and error feedback for CRUD operations.
    - *Verification*: Admin can deactivate a mechanic or change a user role from the UI.

- [ ] **Task 18: Admin Reports UI**
    - Implement dashboard with statistics (load and cancellations) and "Download CSV" button.
    - *UI States*: Implement loading state for charts/stats and error alerts for failed data fetching.
    - *Verification*: Stats match the backend API data.

## Phase 5: Finalization
- [ ] **Task 19: Audit Log View**
    - Create a component to view `booking_events` (Action Journal).
    - *UI States*: Implement loading state, empty log message, and error handling.
    - *Verification*: View the history of who changed the status and when.

- [ ] **Task 20: Security Audit**
    - Review JWT implementation (rotation and blacklisting).
    - Verify role-based access control (RBAC) on all endpoints.
    - Check for potential SQL injection or XSS vulnerabilities.
    - *Verification*: Unauthorized requests are correctly blocked with 401/403/404.

- [ ] **Task 21: Documentation & README**
    - Update `README.md` with setup instructions and test credentials.
    - *Verification*: A fresh install can be performed following the README steps.
