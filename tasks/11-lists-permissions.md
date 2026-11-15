# Кабинет клиента, панель механика, права
- GET /api/bookings/my/?scope=current|history&page= — брони текущего клиента (current: created/confirmed в будущем; history: остальное).
- GET /api/bookings/{id}/ — только своя бронь у клиента, только «своя» у механика, любая у admin; иначе 404.
- GET /api/staff/bookings/?date=YYYY-MM-DD — брони текущего механика на день (роль mechanic).
Тесты: клиент A запрашивает бронь клиента B -> 404; клиент A отменяет бронь B -> 404; клиент на staff/bookings -> 403; механик видит только свои брони.
