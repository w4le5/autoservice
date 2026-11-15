# Каркас backend
Создай Django-проект в папке backend/ (пакет настроек config), приложения accounts, catalog, bookings.
- Настройки читают .env из корня репозитория через python-dotenv: DJANGO_SECRET_KEY, DJANGO_DEBUG, DJANGO_ALLOWED_HOSTS, DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT. Никаких значений по умолчанию для секретов.
- БД MySQL (mysqlclient), USE_TZ=True, TIME_ZONE="Asia/Almaty", подключи rest_framework, corsheaders (разрешить http://localhost:5173), django_filters.
- accounts.User на AbstractUser с полем role (client/mechanic/admin, default client) и phone. AUTH_USER_MODEL задать сразу.
- Единый формат ошибок API: {"code": "...", "detail": "..."}.
- Создай миграции. Пакеты уже установлены, requirements.txt создай для справки.
Проверка: python manage.py migrate и python manage.py check проходят.
