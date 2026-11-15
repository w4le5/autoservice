# Создание брони с защитой от двойного бронирования
POST /api/bookings/ (только роль client). Тело: mechanic, service, start_at, comment.
- Валидация: механик активен и оказывает эту услугу, start_at в будущем. client берётся только из request.user. end_at и price считает сервер, из тела они игнорируются.
- Логику вынеси в bookings/services.py, функция create_booking: внутри transaction.atomic() ПЕРВЫМ запросом Mechanic.objects.select_for_update().get(pk=...), затем проверка пересечения среди броней этого механика со статусами created/confirmed (start_at < new_end и end_at > new_start), затем создание брони и события (from_status=None, to_status=created).
- Конфликт: 409 {"code": "slot_taken", "detail": "Это время у механика уже занято"}.
Тесты: успешное создание и end_at по длительности услуги; пересечение -> 409; встык (10:00–11:00 и 11:00–12:00) -> 201; отменённая бронь не блокирует; client_id из тела игнорируется; механик не оказывает услугу -> 400; без токена 401.
