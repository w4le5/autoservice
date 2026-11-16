# Project Specification: Car Service Booking System

## Tech Stack
- **Frontend**: React (Vite)
- **Backend**: Django + Django REST Framework (DRF)
- **Database**: MySQL 8
- **Authentication**: JWT via `djangorestframework-simplejwt` with `token_blacklist` enabled.

## Database Schema (6 Custom Tables)

1.  **users** (Custom `AbstractUser`)
    - `id`: BigInt (Primary Key, Auto-increment)
    - `username`: VarChar(150) (Unique, Not Null)
    - `password`: VarChar(128) (Not Null)
    - `email`: VarChar(254) (Not Null)
    - `first_name`: VarChar(150)
    - `last_name`: VarChar(150)
    - `role`: Enum('client', 'mechanic', 'admin') (Not Null, Default: 'client')
    - `is_active`: Boolean (Default: True)
    - `is_staff`: Boolean (Default: False)
    - `date_joined`: DateTime (Not Null)

2.  **services**
    - `id`: BigInt (Primary Key, Auto-increment)
    - `name`: VarChar(255) (Not Null)
    - `duration_min`: Integer (Not Null, Positive)
    - `price`: Decimal(10, 2) (Not Null, Positive)
    - `is_active`: Boolean (Default: True)

3.  **mechanics**
    - `id`: BigInt (Primary Key, Auto-increment)
    - `user_id`: BigInt (Foreign Key to `users`, Nullable, Unique)
    - `name`: VarChar(255) (Not Null)
    - `specialization`: VarChar(255) (Not Null)
    - `bio`: Text (Nullable)
    - `image_url`: VarChar(500) (Nullable)
    - `is_active`: Boolean (Default: True)

4.  **mechanic_services** (Many-to-Many Join Table)
    - `id`: BigInt (Primary Key, Auto-increment)
    - `mechanic_id`: BigInt (Foreign Key to `mechanics`, Not Null)
    - `service_id`: BigInt (Foreign Key to `services`, Not Null)
    - *Constraint*: Unique together (`mechanic_id`, `service_id`)

5.  **bookings**
    - `id`: BigInt (Primary Key, Auto-increment)
    - `client_id`: BigInt (Foreign Key to `users`, Not Null)
    - `mechanic_id`: BigInt (Foreign Key to `mechanics`, Not Null)
    - `service_id`: BigInt (Foreign Key to `services`, Not Null)
    - `start_at`: DateTime (Not Null)
    - `end_at`: DateTime (Not Null)
    - `status`: Enum('created', 'confirmed', 'completed', 'cancelled') (Not Null, Default: 'created')
    - `price`: Decimal(10, 2) (Not Null) - Snapshot of service price at booking time
    - `comment`: Text (Nullable)
    - `created_at`: DateTime (Auto-now-add)
    - `updated_at`: DateTime (Auto-now)

6.  **booking_events** (Audit Log)
    - `id`: BigInt (Primary Key, Auto-increment)
    - `booking_id`: BigInt (Foreign Key to `bookings`, Not Null)
    - `actor_id`: BigInt (Foreign Key to `users`, Not Null)
    - `from_status`: VarChar(20) (Not Null)
    - `to_status`: VarChar(20) (Not Null)
    - `note`: Text (Nullable)
    - `created_at`: DateTime (Auto-now-add)

## Booking Statuses and Transitions

### Transitions and Permissions

| From Status | To Status | Allowed Roles | Conditions |
| :--- | :--- | :--- | :--- |
| `created` | `confirmed` | Mechanic, Admin | Mechanic must be the one assigned to the booking. |
| `created` | `cancelled` | Client, Mechanic, Admin | Client must be the owner and `start_at` must be in the future. |
| `confirmed` | `completed` | Mechanic, Admin | Mechanic must be the one assigned to the booking. |
| `confirmed` | `cancelled` | Mechanic, Admin | Mechanic must be the one assigned to the booking. |

- **Terminal States**: `completed`, `cancelled`. No further transitions allowed from these states.

### Error Handling for Status Updates
- **404 Not Found**: Attempting to update a booking that does not exist or belongs to another client (if the requester is a Client).
- **403 Forbidden**: The user's role is not permitted to perform the requested transition (e.g., Client trying to `confirm` a booking).
- **409 Conflict**: The requested transition is logically invalid (e.g., `completed` -> `cancelled` or `created` -> `completed`).

## API Endpoints

### Auth
- `POST /api/auth/register/`
    - **Description**: Register a new client user.
    - **Access**: Public
    - **Errors**: `400 Bad Request` (Validation errors, e.g., username taken).
- `POST /api/auth/login/`
    - **Description**: Obtain JWT access and refresh tokens.
    - **Access**: Public
    - **Errors**: `401 Unauthorized` (Invalid credentials).
- `POST /api/auth/refresh/`
    - **Description**: Refresh the access token using a refresh token.
    - **Access**: Public
    - **Errors**: `401 Unauthorized` (Invalid or expired refresh token).
- `POST /api/auth/logout/`
    - **Description**: Blacklist the refresh token.
    - **Access**: Authenticated
    - **Errors**: `401 Unauthorized`, `400 Bad Request` (Invalid token).
- `GET /api/auth/me/`
    - **Description**: Get current user profile details.
    - **Access**: Authenticated
    - **Errors**: `401 Unauthorized`.

### Catalog
- `GET /api/services/`
    - **Description**: List all active services.
    - **Access**: Public
    - **Errors**: None.
- `GET /api/mechanics/`
    - **Description**: List active mechanics with optional search and filtering.
    - **Access**: Public
    - **Params**: 
        - `search`: Search by name or specialization.
        - `service_id`: Filter by service offered.
        - `page`: Pagination.
    - **Errors**: `400 Bad Request` (Invalid parameters).
- `GET /api/mechanics/{id}/`
    - **Description**: Get detailed information for a specific mechanic.
    - **Access**: Public
    - **Errors**: `404 Not Found`.
- `GET /api/mechanics/{id}/availability/`
    - **Description**: Get busy time slots for a mechanic on a specific date.
    - **Access**: Public
    - **Params**: `date` (Required, format: YYYY-MM-DD).
    - **Errors**: `404 Not Found`, `400 Bad Request` (Missing or invalid date).

### Bookings
- `POST /api/bookings/`
    - **Description**: Create a new booking.
    - **Access**: Client
    - **Errors**: `400 Bad Request`, `401 Unauthorized`, `409 Conflict` (Time slot overlap).
- `GET /api/bookings/`
    - **Description**: List bookings. Clients see their own; Mechanics see their assigned; Admins see all.
    - **Access**: Authenticated
    - **Params**: `date` (optional, filter by day).
    - **Errors**: `401 Unauthorized`.
- `GET /api/bookings/{id}/`
    - **Description**: Get booking details.
    - **Access**: Owner (Client), Assigned Mechanic, or Admin.
    - **Errors**: `401 Unauthorized`, `404 Not Found`.
- `PATCH /api/bookings/{id}/status/`
    - **Description**: Update booking status (Confirm, Complete, Cancel).
    - **Access**: Role-based (see Transitions table).
    - **Body**: `{ "status": "..." }`
    - **Errors**: `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict`.

### Admin API
- **Services Management**
    - `GET /api/admin/services/`: List all services.
    - `POST /api/admin/services/`: Create service.
    - `GET/PUT/PATCH/DELETE /api/admin/services/{id}/`: Manage specific service.
    - **Access**: Admin
    - **Errors**: `401 Unauthorized`, `403 Forbidden`, `404 Not Found`.
- **Mechanics Management**
    - `GET /api/admin/mechanics/`: List all mechanics.
    - `POST /api/admin/mechanics/`: Create mechanic.
    - `GET/PUT/PATCH/DELETE /api/admin/mechanics/{id}/`: Manage specific mechanic.
    - **Access**: Admin
    - **Errors**: `401 Unauthorized`, `403 Forbidden`, `404 Not Found`.
- **User Management**
    - `GET /api/admin/users/`
        - **Description**: List all users.
        - **Access**: Admin
    - `PATCH /api/admin/users/{id}/role/`
        - **Description**: Change user role.
        - **Access**: Admin
        - **Body**: `{ "role": "client" | "mechanic" | "admin" }`
    - `PATCH /api/admin/users/{id}/block/`
        - **Description**: Toggle user `is_active` status.
        - **Access**: Admin
        - **Body**: `{ "is_active": boolean }`
- **Audit Log**
    - `GET /api/admin/audit-log/`
        - **Description**: View action journal (all `booking_events`).
        - **Access**: Admin

### Reports
- `GET /api/reports/mechanic-load/`
    - **Description**: Get mechanic utilization statistics for a period.
    - **Access**: Admin
    - **Params**: `start_date`, `end_date`.
    - **Format**: JSON
- `GET /api/reports/cancellations/`
    - **Description**: Get cancellation statistics for a period.
    - **Access**: Admin
    - **Params**: `start_date`, `end_date`.
    - **Format**: JSON
- `GET /api/reports/export-csv/`
    - **Description**: Export report data (load and cancellations) to CSV.
    - **Access**: Admin
    - **Params**: `start_date`, `end_date`.
    - **Format**: CSV

## React Screens

All screens must implement:
- **Loading State**: Spinner or Skeleton loaders while fetching data.
- **Empty State**: Friendly message when no data is returned (e.g., "No mechanics found").
- **Error State**: Alert or notification showing the error message from the API.

### 1. Authentication
- **Login**: Form (username, password).
    - *States*: Submitting (disabled button), Error (invalid credentials).
- **Registration**: Form (username, email, password, names).
    - *States*: Submitting, Error (validation messages).

### 2. Client Screens
- **Mechanic Catalog**: Search bar, Service filter, Paginated list of mechanic cards.
    - *States*: Skeleton cards while loading, "No mechanics match your search" empty state.
- **Mechanic Profile & Booking**: Mechanic details (bio, specialization) + Date/Time picker showing availability.
    - *States*: Loading availability, Error (404 if mechanic inactive), Success/Conflict feedback on booking submission.
- **My Bookings**: List of user's bookings with status badges and "Cancel" button for eligible bookings.
    - *States*: Loading list, "You have no bookings yet" empty state.

### 3. Mechanic Screens
- **Daily Schedule**: List of bookings assigned to the mechanic for the selected date.
    - *States*: Loading, "No bookings for this day" empty state.
- **Booking Management**: Detail view of a booking with action buttons (Confirm, Complete, Cancel) based on current status.
    - *States*: Updating status (loading), Error (403/409).

### 4. Admin Screens
- **Admin Dashboard**: Tabs for Users, Services, and Mechanics management.
    - *States*: Loading data for each tab, Empty lists, CRUD error feedback.
- **Reports Page**: Date range picker, visualization of mechanic load and cancellation rates.
    - *States*: Loading report, Error (invalid range), CSV download trigger.
- **Audit Log (Action Journal)**: Table of `booking_events` showing who changed what and when.
    - *States*: Loading, Empty log, Error.

## Demo Data (Seed)

The system includes a management command `python manage.py seed` to populate the database with:
- **Users**:
    - 1 Admin (`admin` / `admin`)
    - 1 Mechanic (`mechanic` / `password`)
    - 1 Client (`client` / `password`)
- **Mechanics**: 20 mechanic profiles with varied specializations and bios.
- **Services**: 5-10 services (e.g., Oil Change, Brake Repair, Engine Diagnostics) with different durations and prices.
- **Bookings**: 30+ records distributed across:
    - Different statuses: `created`, `confirmed`, `completed`, `cancelled`.
    - Different timeframes: Past (completed/cancelled), Today (confirmed/created), Future (created).
    - Various clients and mechanics.

## Backend Test Plan

### Authentication & JWT
1.  **Registration**: Successful client registration creates a user with 'client' role.
2.  **Login**: Valid credentials return both `access` and `refresh` tokens.
3.  **Token Rotation**: Using a `refresh` token returns a new pair; the old `refresh` token is invalidated.
4.  **Logout**: Blacklists the `refresh` token; subsequent refresh attempts fail with 401.
5.  **Unauthorized Access**: Accessing protected endpoints without a token returns 401.

### Permissions & Access Control
6.  **Role Restriction**: A user with 'client' role receives 403 when accessing `/api/admin/*` endpoints.
7.  **Object Isolation**: Client A receives 404 (or 403) when trying to view or patch a booking belonging to Client B.
8.  **Mechanic Isolation**: Mechanic A receives 403 when trying to confirm a booking assigned to Mechanic B.

### Booking Logic & Constraints
9.  **Duration Calculation**: Creating a booking for a 60-min service at 10:00 correctly sets `end_at` to 11:00.
10. **Overlap Prevention**: Attempting to book 10:30-11:30 for a mechanic who is busy 10:00-11:00 returns 409 Conflict.
11. **Back-to-Back Booking**: Booking 11:00-12:00 for a mechanic who finishes another job at 11:00 is successful (no gap required).
12. **Cancelled Slot Re-use**: A slot previously occupied by a `cancelled` booking is available for new bookings.

### Status Transitions
13. **Valid Flow**: Mechanic can transition a booking from `created` to `confirmed`.
14. **Invalid Transition**: Attempting to transition `created` directly to `completed` returns 409 Conflict.
15. **Terminal State Protection**: Attempting to transition a `cancelled` or `completed` booking to any other status returns 409.

### Concurrency & Reports
16. **Race Condition**: Sending 10 simultaneous requests for the same mechanic/slot results in exactly 1 success (201) and 9 failures (409).
17. **Report Accuracy**: Mechanic load report correctly aggregates hours worked and cancellation counts for the specified period.
18. **Audit Logging**: Every status change via `PATCH` creates a corresponding entry in the `booking_events` table.
