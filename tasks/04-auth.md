# Авторизация JWT
В accounts сделай на SimpleJWT + rest_framework_simplejwt.token_blacklist:
- POST /api/auth/register/ (роль всегда client, role из тела игнорируется), POST /api/auth/login/, POST /api/auth/refresh/, POST /api/auth/logout/ (refresh в blacklist), GET /api/auth/me/.
- Access 15 минут, refresh 7 дней, ROTATE_REFRESH_TOKENS и BLACKLIST_AFTER_ROTATION включены. В токен добавь только role.
- Permission-классы IsClient, IsMechanic, IsAdminRole в accounts/permissions.py. Заблокированный (is_active=False) пользователь войти не может.
Тесты (accounts/tests.py): регистрация с role=admin создаёт client; после logout refresh возвращает 401; старый refresh после ротации не работает; /me/ без токена 401.
