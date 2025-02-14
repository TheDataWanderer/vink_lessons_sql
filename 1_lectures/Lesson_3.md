## **Лекция 6: Объединение таблиц — JOIN в PostgreSQL**

### **1. Введение**

В реляционных базах данных информация хранится в разных таблицах. Например, в схеме `bookings` есть:

- `bookings.bookings` — информация о бронированиях.
- `bookings.airports_data` — данные аэропортов.
- `bookings.flights` — данные о рейсах.
- `bookings.ticket_flights` — билеты на рейсы.
- `bookings.boarding_passes` — посадочные талоны.

Часто нам нужно объединять данные из нескольких таблиц. SQL предоставляет инструмент для этого — **JOIN**.

---

### **2. Виды JOIN**

#### **2.1 INNER JOIN — Только совпадающие записи**

INNER JOIN возвращает только те строки, которые имеют соответствие в обеих таблицах.

Пример: Получить список бронирований с билетами и их стоимостью.

```sql
SELECT t.book_ref, t.ticket_no, b.book_date
FROM bookings.bookings b
INNER JOIN bookings.tickets t ON b.book_ref = t.book_ref 
```

**Как это работает?**

- PostgreSQL соединяет `bookings.bookings` и `bookings.ticket_flights` по `book_ref = ticket_no`.
- Возвращает только записи, у которых есть совпадение.

**Когда использовать?**

- Когда нужны только связанные данные (например, бронирования, у которых есть билет).

---

#### **2.2 LEFT JOIN — Все из левой таблицы, плюс совпадения**

Этот JOIN берет **все строки** из левой таблицы и дополняет их совпадениями из правой.

Пример: Получить список всех бронирований и, если есть, номера рейсов по билетам.

```sql
SELECT t.book_ref, t.ticket_no, b.book_date
FROM bookings.bookings b
LEFT JOIN bookings.tickets t ON b.book_ref = t.book_ref;
```

**Как это работает?**

- PostgreSQL берет **все бронирования** (`bookings.bookings`).
- Если у бронирования есть билет, подтягивает `flight_id`.
- Если билета нет, в `flight_id` будет `NULL`.

**Когда использовать?**

- Когда нужно сохранить все строки из одной таблицы, даже если нет совпадений.

---

#### **2.3 RIGHT JOIN — Все из правой таблицы, плюс совпадения**

Это зеркальный случай `LEFT JOIN`.

Пример: Получить все билеты и, если есть, информацию о бронировании.

```sql
SELECT t.ticket_no, t.book_ref, b.book_date
FROM bookings.tickets t
RIGHT JOIN bookings.bookings b ON b.book_ref = t.book_ref;
```

**Когда использовать?**

- Когда важны **все записи из правой таблицы**, даже если в левой нет совпадений.

---

#### **2.4 FULL JOIN — Все строки из обеих таблиц**

Этот тип соединения берет **все строки** из обеих таблиц. Если нет совпадений — вставляет `NULL`.

Пример: Получить все бронирования и все билеты (даже если нет связи).

```sql
SELECT b.book_ref, t.ticket_no, b.book_date
FROM bookings.bookings b
FULL JOIN bookings.tickets t ON b.book_ref = t.book_ref;
```

**Когда использовать?**

- Когда нужно объединить **все данные** из двух таблиц.

---

### **3. Как задавать условия соединения?**

#### **3.1 ON — явное указание условий**

Чаще всего соединения делаются по `ON`, указывая, какие столбцы связаны.

Пример: Получить список рейсов с аэропортами вылета и прибытия.

```sql
SELECT f.flight_no, f.scheduled_departure, a1.airport_name AS departure_airport, a2.airport_name AS arrival_airport
FROM bookings.flights f
JOIN bookings.airports a1 ON f.departure_airport = a1.airport_code
JOIN bookings.airports a2 ON f.arrival_airport = a2.airport_code;
```

**Когда использовать ON?**

- Когда соединяем таблицы по разным столбцам.

---

#### **3.2 USING — упрощенный вариант ON**

Если имена колонок в обеих таблицах **совпадают**, можно использовать `USING`.

Пример:

```sql
SELECT t.book_ref, t.ticket_no, b.book_date
FROM bookings.bookings b
LEFT JOIN bookings.tickets t USING (book_ref)
```

**Когда использовать?**

- Если ключи в обеих таблицах **называются одинаково**.

---

### **4. Подзапросы и CTE в JOIN**

#### **4.1 Подзапрос в JOIN**

Иногда удобнее подготовить данные в подзапросе.

Пример: Найти количество бронирований по каждому аэропорту вылета.

```sql
SELECT a.airport_name, b.booking_count
FROM bookings.airports a
LEFT JOIN (
    SELECT f.departure_airport, COUNT(*) AS booking_count
    FROM bookings.flights f
    JOIN bookings.ticket_flights tf ON f.flight_id = tf.flight_id
    GROUP BY f.departure_airport
) b ON a.airport_code = b.departure_airport;
```

---

#### **4.2 CTE (Common Table Expressions) в JOIN**
_обобщенное табличное выражение_
CTE (`WITH`) делает SQL-код **читаемее**.

Пример: Найти пользователей с общей суммой платежей выше 5000.

```sql
WITH total_payments AS (
    SELECT tf.ticket_no, SUM(tf.amount) AS total_spent
    FROM bookings.ticket_flights tf
    GROUP BY tf.ticket_no
)
SELECT tf.ticket_no, tp.total_spent
FROM bookings.ticket_flights tf
JOIN total_payments tp ON tf.ticket_no = tp.ticket_no
WHERE tp.total_spent > 5000;
```

---

### **5. Оптимизация JOIN**

**Индексы**

```sql
CREATE INDEX idx_ticket_flights_flight_id ON bookings.ticket_flights (flight_id);
```

**Фильтры перед JOIN**

```sql
SELECT * FROM
(SELECT * FROM bookings.flights WHERE status = 'Scheduled') f
JOIN bookings.airports_data a ON f.departure_airport = a.airport_code;
```

**LIMIT**

```sql
SELECT * FROM bookings.flights f
JOIN bookings.airports_data a ON f.departure_airport = a.airport_code
LIMIT 1000;
```

---

### **Выводы**

- `INNER JOIN` — только совпадающие строки.
- `LEFT JOIN` — все строки из левой таблицы + совпадения.   
- `RIGHT JOIN` — все строки из правой таблицы + совпадения.    
- `FULL JOIN` — все строки из обеих таблиц.    
- `CROSS JOIN` — **Осторожно!** Может создать миллионы строк.    
- **Оптимизируйте JOIN-запросы** с помощью индексов, фильтров и LIMIT.
- `ON` и `USING` управляют соединением.  
- CTE делают код чище.  
