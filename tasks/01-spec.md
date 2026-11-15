# Спецификация и правила для агента
Кода не пиши. Создай два файла.

1. docs/SPEC.md — спецификация проекта «Запись в автосервис»:
- Стек: React (Vite), Django + DRF, MySQL 8, JWT через SimpleJWT с token_blacklist.
- Роли: client (владелец машины), mechanic (сотрудник), admin. При регистрации всегда client.
- Бронируется время механика. Особое правило: длительность записи = длительность услуги, записи одного механика не пересекаются.
- Таблицы (6 своих): users (кастомный AbstractUser с полем role), services (name, duration_min, price, is_active), mechanics (user nullable, name, specialization, bio, image_url, is_active), mechanic_services (M2M), bookings (client, mechanic, service, start_at, end_at, status, price, comment), booking_events (booking, actor, from_status, to_status, note, created_at).
- Статусы: created -> confirmed|cancelled; confirmed -> completed|cancelled; completed и cancelled конечные. Кто какой переход может делать.
- Создание брони: transaction.atomic, первым запросом select_for_update строки механика, проверка пересечений только среди created/confirmed, конфликт -> 409.
- Опиши API (auth, каталог, брони клиента, панель механика, админ, отчёт + CSV, журнал), коды ошибок, экраны React, демо-данные (seed), вне рамок (оплата, email, деплой).

2. CONVENTIONS.md — короткие правила для тебя же: секреты только из .env; user только из request.user; чужой объект -> 404, не та роль -> 403; переходы статусов только в bookings/status.py; смена статуса и запись журнала в одной транзакции; отчёты SQL-агрегацией; миграции не редактировать; тесты только на MySQL; на каждом экране React состояния загрузки, пустого списка и ошибки.
