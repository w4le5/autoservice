# API каталога
- GET /api/services/ — активные услуги.
- GET /api/mechanics/?search=&service=&page= — поиск по name и specialization, фильтр по услуге, пагинация по 10 на стороне сервера, только активные.
- GET /api/mechanics/{id}/ — карточка с услугами и image_url.
- GET /api/mechanics/{id}/busy/?date=YYYY-MM-DD — занятые интервалы (start_at, end_at) активных броней (created, confirmed) на день, требует авторизации.
Тесты: поиск, фильтр по услуге, пагинация, в busy нет отменённых броней.
