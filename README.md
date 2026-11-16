# Автосервис — запись к механику

Финальный проект по AI Driven Development. Вариант: **Автосервис**.

Стек: React · Django + DRF · MySQL · JWT. Агент: Aider.

Спецификация: [docs/SPEC.md](docs/SPEC.md) · план: [docs/PLAN.md](docs/PLAN.md) · история промптов: [docs/prompts/](docs/prompts/)

## Запуск

### Бэкенд
1. Установите зависимости: `pip install -r requirements.txt`
2. Настройте `.env` (см. `.env.example`)
3. Выполните миграции: `python manage.py migrate`
4. Заполните базу демо-данными: `python manage.py seed`
5. Запустите сервер: `python manage.py runserver`

### Фронтенд
1. Установите зависимости: `npm install`
2. Запустите проект: `npm run dev`

## Тестовые логины
Вход через `/api/auth/login/`.

| Роль | Логин | Пароль |
|---|---|---|
| Клиент | client | password |
| Механик | mechanic | password |
| Админ | admin | admin |
