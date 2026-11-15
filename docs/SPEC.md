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
- `POST /api/auth/register/`: Client registration. (Public)
- `POST /api/auth/login/`: Obtain JWT tokens. (Public)
- `POST /api/auth/refresh/`: Refresh JWT token. (Public)
- `POST /api/auth/logout/`: Blacklist refresh token. (Authenticated)
- `GET /api/auth/me/`: Current user profile. (Authenticated)

### Catalog
- `GET /api/mechanics/`: List active mechanics.
    - *Params*: `search` (name/specialization), `service_id` (filter), `page`, `date` (to check availability).
    - *Response*: Paginated list with mechanic details and busy slots for the requested `date`.

### Bookings
- `POST /api/bookings/`: Create booking. (Client)
    - *Errors*: `409 Conflict` (Overlap), `400 Bad Request` (Invalid data).
- `GET /api/bookings/`: List bookings. (Client: own, Mechanic: assigned, Admin: all)
- `GET /api/bookings/{id}/`: Detail view. (Permissions enforced)
- `PATCH /api/bookings/{id}/status/`: Update status. (Role-based transitions)

### Admin API
- `GET/POST/PUT/DELETE /api/admin/users/`: User management.
- `GET/POST/PUT/DELETE /api/admin/services/`: Service management.
- `GET/POST/PUT/DELETE /api/admin/mechanics/`: Mechanic management.
- `GET /api/admin/audit-log/`: View all `booking_events`.

### Reports
- `GET /api/reports/mechanic-load/`: Stats on mechanic utilization for a period.
- `GET /api/reports/cancellations/`: Stats on cancellation rates.
- `GET /api/reports/export-csv/`: Download report data as CSV.

## React Screens
- **Public**: Landing (Hero + Service list), Login, Registration.
- **Client**: Mechanic Catalog (Search/Filter), Booking Form (Date/Time picker), My Bookings (List + Cancel).
- **Mechanic**: Dashboard (Daily Schedule), Booking Detail (Status update buttons).
- **Admin**: User Management, Service Management, Mechanic Management, Global Audit Log, Reports Dashboard.

## Demo Data (Seed)
- 1 Admin user.
- 1 Mechanic user + 1 Client user.
- 20 Mechanics total (some with associated users, some without).
- 30+ Bookings across various statuses and dates.

## Backend Test Plan (15+ Tests)
1.  **Auth**: Successful registration of a client.
2.  **Auth**: Login returns valid access/refresh tokens.
3.  **Auth**: Refresh token generates new access token.
4.  **Auth**: Logout blacklists the refresh token.
5.  **Catalog**: Filter mechanics by service ID.
6.  **Catalog**: Search mechanics by name.
7.  **Booking**: Create booking calculates correct `end_at`.
8.  **Booking**: Create booking snapshots the current service price.
9.  **Concurrency**: Prevent two bookings for the same mechanic at the same time (409).
10. **Status**: Mechanic can confirm a `created` booking.
11. **Status**: Client can cancel their own `created` booking.
12. **Status**: Prevent invalid transition (e.g., `created` -> `completed`).
13. **Permissions**: Client cannot view another client's booking (404).
14. **Admin**: Admin can create a new service.
15. **Reports**: Mechanic load report returns correct counts.
16. **Audit**: Changing status creates a `booking_event` record.
