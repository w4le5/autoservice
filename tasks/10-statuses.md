# Статусы и журнал действий
- bookings/status.py: словарь TRANSITIONS (created -> confirmed, cancelled; confirmed -> completed, cancelled) и правила, какая роль что может: confirm/complete — механик этой брони или admin; cancel — клиент-владелец (только до start_at), механик этой брони, admin. Проверки только здесь, не во views.
- POST /api/bookings/{id}/status/ с телом {status, note} и POST /api/bookings/{id}/cancel/ для клиента.
- Недопустимый переход -> 409, роль не может -> 403, чужая бронь -> 404.
- Смена статуса и запись BookingEvent в одном transaction.atomic() с select_for_update на бронь.
Тесты: created->confirmed механиком и событие в журнале; completed->cancelled 409; клиент не может завершить бронь 403; чужой механик 404; если запись события падает, статус не меняется.
