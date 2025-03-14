**1. Таблица `bookings.bookings` (Бронирования):**

- **book_ref** (bpchar(6)) — Номер бронирования.
- **book_date** (timestamptz) — Дата и время бронирования.
- **total_amount** (numeric(10, 2)) — Общая стоимость бронирования.

---

**2. Таблица `bookings.airports_data` (Данные аэропортов):**

- **airport_code** (bpchar(3)) — Код аэропорта.
- **airport_name** (jsonb) — Название аэропорта.
- **city** (jsonb) — Город.
- **coordinates** (point) — Координаты аэропорта (долгота и широта).
- **timezone** (text) — Часовой пояс аэропорта.

---

**3. Таблица `bookings.ticket_flights` (Билеты на рейсы):**

- **ticket_no** (bpchar(13)) — Номер билета.
- **flight_id** (int4) — ID рейса.
- **fare_conditions** (varchar(10)) — Условия тарифа.
- **amount** (numeric(10, 2)) — Стоимость билета.

---

**4. Таблица `bookings.boarding_passes` (Посадочные талоны):**

- **ticket_no** (bpchar(13)) — Номер билета.
- **flight_id** (int4) — ID рейса.
- **boarding_no** (int4) — Номер посадочного талона.
- **seat_no** (varchar(4)) — Номер места.

---

**5. Таблица `bookings.seats` (Места):**

- **aircraft_code** (bpchar(3)) — Код самолета.
- **seat_no** (varchar(4)) — Номер места.
- **fare_conditions** (varchar(10)) — Условия тарифа.

---

**6. Таблица `bookings.flights` (Рейсы):**

- **flight_id** (serial4) — ID рейса.
- **flight_no** (bpchar(6)) — Номер рейса.
- **scheduled_departure** (timestamptz) — Запланированное время вылета.
- **scheduled_arrival** (timestamptz) — Запланированное время прибытия.
- **departure_airport** (bpchar(3)) — Аэропорт вылета.
- **arrival_airport** (bpchar(3)) — Аэропорт прибытия.
- **status** (varchar(20)) — Статус рейса.
- **aircraft_code** (bpchar(3)) — Код самолета.
- **actual_departure** (timestamptz) — Фактическое время вылета.
- **actual_arrival** (timestamptz) — Фактическое время прибытия.

---

**7. Таблица `bookings.aircrafts_data` (Данные самолетов):**

- **aircraft_code** (bpchar(3)) — Код самолета.
- **model** (jsonb) — Модель самолета.
- **range** (int4) — Максимальный дальность полета (км).

---

**8. Представление `bookings.routes` (Маршруты)**

Это представление агрегирует данные о рейсах, предоставляя информацию о маршрутах, которые соединяют два аэропорта с учетом дней недели, на которых выполняются рейсы. Оно собирает данные о рейсах из таблицы `flights` и информации о аэропортах из таблицы `airports`.

*   **flight_no** (bpchar(6)) — Номер рейса.
*   **departure_airport** (bpchar(3)) — Аэропорт вылета (код аэропорта).
*   **departure_airport_name** (varchar) — Название аэропорта вылета.
*   **departure_city** (varchar) — Город, в котором находится аэропорт вылета.
*   **arrival_airport** (bpchar(3)) — Аэропорт прибытия (код аэропорта).
*   **arrival_airport_name** (varchar) — Название аэропорта прибытия.
*   **arrival_city** (varchar) — Город, в котором находится аэропорт прибытия.
*   **aircraft_code** (bpchar(3)) — Код самолета, выполняющего рейс.
*   **duration** (interval) — Продолжительность рейса (разница между временем запланированного прибытия и вылета).
*   **days_of_week** (integer[]) — Массив чисел, представляющих дни недели, в которые выполняется рейс (например, 1 для понедельника, 2 для вторника и т.д.).

---

**9. Представление `bookings.aircrafts` (Самолеты)**

Это представление извлекает информацию о самолетах из таблицы `aircrafts_data`, включая код самолета, модель и его дальность полета.

*   **aircraft_code** (bpchar(3)) — Код самолета.
*   **model** (varchar) — Модель самолета, извлеченная из поля `model` в формате JSON в зависимости от текущего языка (используется функция `lang()` для выбора соответствующего языка).
*   **range** (integer) — Дальность полета самолета.

---
**10. Представление `bookings.airports` (Аэропорты)**

Это представление извлекает информацию о аэропортах из таблицы `airports_data`, включая код аэропорта, название, город, координаты и часовой пояс. Названия аэропортов и городов локализуются в зависимости от языка пользователя.

*   **airport_code** (bpchar(3)) — Код аэропорта.
*   **airport_name** (varchar) — Название аэропорта, извлеченное из поля `airport_name` в формате JSON, с учетом текущего языка (используется функция `lang()` для выбора соответствующего языка).
*   **city** (varchar) — Город, в котором находится аэропорт, извлеченный из поля `city` в формате JSON, с учетом текущего языка.
*   **coordinates** (varchar) — Координаты аэропорта.
*   **timezone** (varchar) — Часовой пояс аэропорта.

---
**11. Представление `bookings.flights_v` (рейсы)**

Это представление объединяет данные из таблиц `flights` (рейсы) и `airports` (аэропорты), преобразуя их в удобный для анализа формат. Оно позволяет получить информацию о рейсах с учётом часовых поясов и продолжительности полетов, а также фактические времена вылетов и прибытия.

*   **flight_id** (int4) — ID рейса.
*   **flight_no** (bpchar(6)) — Номер рейса.
*   **scheduled_departure** (timestamptz) — Запланированное время вылета.
*   **scheduled_departure_local** (timestamptz) — Запланированное время вылета в локальной временной зоне аэропорта вылета.
*   **scheduled_arrival** (timestamptz) — Запланированное время прибытия.
*   **scheduled_arrival_local** (timestamptz) — Запланированное время прибытия в локальной временной зоне аэропорта прибытия.
*   **scheduled_duration** (interval) — Продолжительность запланированного рейса (разница между временем запланированного прибытия и вылета).
*   **departure_airport** (bpchar(3)) — Аэропорт вылета (код аэропорта).
*   **departure_airport_name** (varchar) — Название аэропорта вылета.
*   **departure_city** (varchar) — Город, в котором находится аэропорт вылета.
*   **arrival_airport** (bpchar(3)) — Аэропорт прибытия (код аэропорта).
*   **arrival_airport_name** (varchar) — Название аэропорта прибытия.
*   **arrival_city** (varchar) — Город, в котором находится аэропорт прибытия.
*   **status** (varchar(20)) — Статус рейса (например, "вылетел", "прибыл" и т.д.).
*   **aircraft_code** (bpchar(3)) — Код самолета.
*   **actual_departure** (timestamptz) — Фактическое время вылета.
*   **actual_departure_local** (timestamptz) — Фактическое время вылета в локальной временной зоне аэропорта вылета.
*   **actual_arrival** (timestamptz) — Фактическое время прибытия.
*   **actual_arrival_local** (timestamptz) — Фактическое время прибытия в локальной временной зоне аэропорта прибытия.
*   **actual_duration** (interval) — Фактическая продолжительность рейса (разница между фактическим временем прибытия и вылета).


