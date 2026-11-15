# Модели каталога и броней
По docs/SPEC.md создай модели: catalog.Service, catalog.Mechanic (M2M services через MechanicService, user OneToOne nullable, image_url), bookings.Booking, bookings.BookingEvent.
- Статусы Booking — TextChoices: created, confirmed, completed, cancelled.
- Индексы: (mechanic, start_at), (client, start_at), status.
- Имена таблиц через db_table: services, mechanics, mechanic_services, bookings, booking_events.
- Зарегистрируй модели в Django admin. Создай миграции.
