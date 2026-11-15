# Отчёт и CSV
GET /api/admin/reports/load/?from=YYYY-MM-DD&to=YYYY-MM-DD и то же с /load.csv.
По каждому механику: total_bookings и cancelled_bookings за период [from, to). Считать одной SQL-агрегацией (annotate с Count и filter, либо raw SQL с параметрами), без циклов по броням в Python. Механики без броней присутствуют с нулями. Некорректные даты -> 400. CSV: text/csv, заголовок колонок, Content-Disposition attachment.
Тесты: механик без броней есть в отчёте с нулями; отмены посчитаны верно; бронь вне периода не учитывается; CSV отдаёт правильный Content-Type; клиент получает 403.
