# Каркас фронтенда
Создай frontend/ на Vite + React (JavaScript), react-router, axios, Pico.css для стилей.
- src/api.js: один axios-инстанс, baseURL из VITE_API_URL, access в памяти, refresh в localStorage; перехватчик на 401 один раз вызывает /auth/refresh/ и повторяет запрос, при неудаче разлогинивает.
- AuthContext: login, register, logout, текущий пользователь из /auth/me/.
- Страницы входа и регистрации, шапка с навигацией по роли, защищённые маршруты: неподходящая роль перенаправляется на свою главную.
- Общий компонент StateView с пропсами loading, error, empty — используется на всех экранах.
