# Development Conventions

## Backend (Django/DRF)
- **Secrets**: All sensitive data (keys, DB credentials) must be loaded from `.env`.
- **Security**: 
    - Always use `request.user` to identify the actor.
    - Return `404 Not Found` if a user tries to access an object they don't own.
    - Return `403 Forbidden` if a user has the wrong role for an action.
- **Business Logic**:
    - Status transition logic must reside in `bookings/status.py`.
    - Every status change must be wrapped in a transaction with a corresponding `booking_events` entry.
- **Database**:
    - Use SQL aggregation for reports.
    - Do not manually edit migration files.
    - Tests must be executed against a MySQL database.

## Frontend (React)
- **UI States**: Every data-fetching component must handle:
    1. **Loading**: Spinner or skeleton.
    2. **Empty**: Message when no data is returned.
    3. **Error**: User-friendly error message.
- **API**: Use a centralized Axios instance or similar for JWT handling.
