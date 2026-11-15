# Project Specification: Car Service Booking System

## Tech Stack
- **Frontend**: React (Vite)
- **Backend**: Django + Django REST Framework (DRF)
- **Database**: MySQL 8
- **Authentication**: JWT via `djangorestframework-simplejwt` with `token_blacklist` enabled.

## Roles and Permissions
- **Client**: Car owner. Can browse services/mechanics and book appointments. Default role upon registration.
- **Mechanic**: Service provider. Can view their schedule and manage booking statuses.
- **Admin**: Full access to manage services, mechanics, and view reports.

## Core Logic
- **Booking**: Users book a specific mechanic for a specific service.
- **Duration**: The duration of a booking is exactly the `duration_min` defined in the selected service.
- **No Overlap**: A mechanic cannot have two bookings that overlap in time.
- **Concurrency Control**: Booking creation must use `transaction.atomic` and `select_for_update` on the Mechanic record to prevent race conditions. Overlap checks only consider `created` and `confirmed` bookings. Conflict results in a `409 Conflict` response.

## Database Schema (6 Custom Tables)
1. **users**: Custom `AbstractUser` with a `role` field (client, mechanic, admin).
2. **services**: `name`, `duration_min`, `price`, `is_active`.
3. **mechanics**: `user` (FK to users, nullable), `name`, `specialization`, `bio`, `image_url`, `is_active`.
4. **mechanic_services**: M2M relationship between mechanics and services.
5. **bookings**: `client` (FK), `mechanic` (FK), `service` (FK), `start_at`, `end_at`, `status`, `price` (snapshot at time of booking), `comment`.
6. **booking_events**: Audit log. `booking` (FK), `actor` (FK), `from_status`, `to_status`, `note`, `created_at`.

## Booking Statuses and Transitions
- **Statuses**: `created`, `confirmed`, `completed`, `cancelled`.
- **Transitions**:
    - `created` -> `confirmed` (Mechanic/Admin)
    - `created` -> `cancelled` (Client/Mechanic/Admin)
    - `confirmed` -> `completed` (Mechanic/Admin)
    - `confirmed` -> `cancelled` (Mechanic/Admin)
- **Terminal States**: `completed`, `cancelled`.

## API Endpoints
- **Auth**: Register (client only), Login (JWT), Logout (blacklist), Profile.
- **Catalog**: List active services and mechanics.
- **Client Bookings**: Create booking, list my bookings, cancel my booking.
- **Mechanic Panel**: List my schedule, update booking status.
- **Admin API**: CRUD for services/mechanics, view all bookings.
- **Reports**: Aggregated statistics (revenue, booking counts) + CSV export.
- **Audit Log**: View `booking_events` for a specific booking.

## React Screens
- **Public**: Landing, Login, Registration.
- **Client**: Service Catalog, Booking Form, My Bookings.
- **Mechanic**: Dashboard (Schedule), Booking Detail.
- **Admin**: Service Management, Mechanic Management, Global Reports.

## Out of Scope
- Payment gateway integration.
- Email/SMS notifications.
- Deployment configurations (CI/CD).
