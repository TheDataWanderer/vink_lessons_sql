### **Лекция 2: Сортировка, группировка и агрегатные функции в SQL**

  
**Цель:**

- Разобрать, как сортировать и группировать данные.
- Понять, как использовать агрегатные функции на практике.
- Научиться фильтровать сгруппированные данные. Разобраться в нюансах фильтрации.
- Оптимизировать SQL-запросы для работы с большими объемами данных.

---  

**Темы:**
## **1. Введение**

 **Ключевые вопросы:**
- Почему сортировка, группировка, фильтрация и агрегаты важны в аналитике?
- Как это используется в отчетах, дашбордах, BI-системах?

## **2. Сортировка данных - `ORDER BY`**

- Как работает `ORDER BY` и какие у него параметры?
- В чем разница между `ASC` и `DESC`?
- Как сортировать по нескольким столбцам?
- Что делать, если в данных есть `NULL`?
- Как сортировать по вычисляемому значению (`разница во времени вылета и прилета`)?
- Как сортировать строки с числами корректно (например, "AB10" и "AB2")?
- Как использовать `CASE` в `ORDER BY`, чтобы задать кастомный порядок сортировки?

## **3. Группировка данных - `GROUP BY`**

- Почему `GROUP BY` важен для аналитики?
- Почему нельзя использовать столбцы без агрегатных функций в `SELECT`, если есть `GROUP BY`?
- Как группировать по нескольким столбцам?
- Когда `DISTINCT ON` полезнее `GROUP BY`?

## **4. Фильтрация данных - `WHERE` vs `HAVING`**

- Почему `WHERE` нельзя использовать с агрегатными функциями?
- Как `HAVING` помогает фильтровать сгруппированные данные?
- Как правильно применять `HAVING` для поиска групп с определенными характеристиками?
- Как найти группы, в которых меньше `N` записей?
- Как использовать `HAVING` для поиска дубликатов в данных?
  
## **5. Агрегатные функции: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`**

- Чем отличается `COUNT(*)` от `COUNT(column_name)`?
- Как правильно считать средние значения (`AVG`), если есть `NULL`?
- Как комбинировать агрегатные функции (например, `SUM` и `COUNT`)?
- Как вычислить процент от общего количества записей в группе?  

## **6. Группировка с `ROLLUP`, `CUBE`, `GROUPING SETS` (расширенные возможности группировки)**

- Что такое расширенная группировка?
- `ROLLUP`: Итоговые значения и подытоги
- `CUBE`: Все возможные комбинации группировки
- `GROUPING SETS`: Выборочные комбинации группировки
- Как понять, когда использовать `ROLLUP`, `CUBE` или `GROUPING SETS`?
- Как понять, какая строка является итоговой (`GROUPING()`)?
---

### **1. Введение**

#### **Почему сортировка, группировка, фильтрация и агрегаты важны в аналитике?**

Работа аналитика — это не только извлечение данных из базы, а еще и умение представить их в удобном и понятном виде. Без сортировки сложно выявить тренды, без группировки — анализировать сегменты, без агрегатных функций — подводить итоги.

SQL позволяет работать с большими объемами данных, но не все операции выполняются одинаково быстро. Например, сортировка может быть дорогой, а фильтрация сгруппированных данных требует понимания различий между `WHERE` и `HAVING`.

#### **Как это используется в отчетах, дашбордах, BI-системах?**

- `ORDER BY` позволяет выстраивать данные в нужном порядке, например, для рейтинговых отчетов.
- `GROUP BY` помогает агрегировать данные, например, чтобы посчитать продажи по категориям.
- `HAVING` позволяет фильтровать сгруппированные данные, например, отбирать только тех клиентов, у которых было более 10 заказов.
- Агрегатные функции (`SUM`, `AVG`, `COUNT`) помогают анализировать показатели, такие как средний чек, выручка по регионам, количество заказов в день.

### **2. Сортировка данных — `ORDER BY`**

#### **Как работает `ORDER BY` и какие у него параметры?**

Оператор `ORDER BY` сортирует строки в результирующем наборе данных. По умолчанию сортировка выполняется по возрастанию (`ASC`), но можно задать и порядок убывания (`DESC`).

```sql
SELECT * 
FROM bookings.flights
ORDER BY actual_departure DESC;
```

Этот запрос сортирует вылеты по дате и времени фактического вылета в порядке убывания

#### **В чем разница между `ASC` и `DESC`?**

- `ASC` (по умолчанию) — сортирует от меньшего к большему (`1, 2, 3` или `A, B, C`).
- `DESC` — сортирует от большего к меньшему (`3, 2, 1` или `C, B, A`).

#### **Как сортировать по нескольким столбцам?**

Иногда нам нужно задать приоритет сортировки. Например, сначала сортировать по статусу вылета, а затем по дате прибытия.

```sql
SELECT *
FROM bookings.flights
ORDER BY status ASC, actual_arrival DESC;
```

Этот запрос сначала сортирует вылеты по статусу в алфавитном порядке (от "A" до "Z"), а затем в пределах каждого статуса по дате и времени прибытия в порядке убывания.

#### **Что делать, если в данных есть `NULL`?**

В PostgreSQL `NULL` сортируется как наименьшее значение при `ASC` и как наибольшее при `DESC`.

Если нужно явно задать порядок сортировки `NULL`, можно использовать `NULLS FIRST` или `NULLS LAST`:

```sql
SELECT * 
FROM bookings.flights
ORDER BY actual_arrival DESC NULLS FIRST;
```

Этот запрос сначала выведет `NULL`, а вылеты с датами, сортированными в алфавитном порядке, отправит в конец.

#### **Как сортировать по вычисляемому значению (`разница во времени вылета и прилета`)?**

Можно сортировать рейсы по продолжительности полёта (разница между фактическим временем вылета и прилёта):

```sql
SELECT *, actual_arrival - actual_departure AS flight_duration
FROM bookings.flights
ORDER BY flight_duration DESC;
```

SQL позволяет не указывать `AS flight_duration` в `ORDER BY`, можно написать так:

```sql
ORDER BY actual_arrival - actual_departure DESC;
```

#### **Как сортировать строки с числами корректно (например, "AB10" и "AB2")?**

Номера рейсов (`flight_no`) состоят из букв и цифр. Лексикографически `AB10` идёт раньше `AB2`, что неправильно. Для корректной сортировки по числовому значению, можно использовать `CAST`:

```sql
SELECT flight_no
FROM bookings.flights
ORDER BY CAST(regexp_replace(flight_no, '\D', '', 'g') AS INTEGER);
```

Этот запрос удаляет все нечисловые символы из `flight_no` и приводит его к числу.

#### **Как использовать `CASE` в `ORDER BY`, чтобы задать кастомный порядок?**

Иногда нужно задать свой порядок сортировки, (например, «Departed» и «Arrived»), приоритетные статусы должны идти первыми.

```sql
SELECT * 
FROM bookings.flights 
ORDER BY 
  CASE status
    WHEN 'Departed' THEN 1
    WHEN 'Arrived' THEN 2
    WHEN 'Delayed' THEN 3
    WHEN 'On Time' THEN 4
    WHEN 'Scheduled' THEN 5
    ELSE 6 -- 'Cancelled' или другие статусы
  END, scheduled_departure DESC;
```

Так рейсы с более высоким приоритетом статуса будут выше, а в рамках одного статуса сортировка пойдёт по времени вылета.

### **3. Группировка данных — `GROUP BY`**

#### **Почему `GROUP BY` важен для аналитики?**

Группировка данных позволяет анализировать совокупные показатели. Вместо того чтобы работать с отдельными строками, мы объединяем их по заданному критерию и применяем агрегатные функции (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`).

##### Примеры использования:

- Подсчет количества рейсов по аэропортам отправления.
- Определение средней продолжительности полетов по направлениям.
- Нахождение самого загруженного самолета (по количеству выполненных рейсов).
- Анализ количества рейсов по месяцам.

#### **Как работает `GROUP BY`?**

Когда мы применяем `GROUP BY`, SQL объединяет строки с одинаковыми значениями в указанном столбце и затем выполняет агрегатные операции.

##### **Пример: Подсчет количества рейсов по аэропортам отправления**

```sql
SELECT departure_airport, COUNT(*) AS flight_count
FROM bookings.flights
GROUP BY departure_airport;
```

Здесь `GROUP BY departure_airport` группирует рейсы по аэропортам отправления, а `COUNT(*)` считает количество рейсов из каждого аэропорта.
##### **Пример: Подсчет общего времени в воздухе по типам самолетов**

```sql
SELECT aircraft_code, 
       SUM(actual_arrival - actual_departure) AS total_flight_time
FROM bookings.flights
WHERE actual_departure IS NOT NULL AND actual_arrival IS NOT NULL
GROUP BY aircraft_code;
```

Этот запрос покажет общее время полетов по каждому типу самолета.
#### **Почему нельзя использовать столбцы без агрегатных функций в `SELECT`, если есть `GROUP BY`?**

В `SELECT` можно указывать только:

1. Столбцы из `GROUP BY`
2. Агрегатные функции (`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`)

##### **Неверный запрос:**

```sql
SELECT departure_airport, scheduled_departure
FROM bookings.flights
GROUP BY departure_airport;
```

 `scheduled_departure` не входит в `GROUP BY` и не является агрегатной функцией.

##### **Правильный вариант:**

```sql
SELECT departure_airport, AVG(actual_departure - scheduled_departure) AS avg_delay_min
FROM bookings.flights
WHERE actual_departure IS NOT NULL
GROUP BY departure_airport;
```

Этот запрос показывает среднюю задержку вылета по каждому аэропорту.
#### **Можно ли группировать по нескольким столбцам?**

Да, можно. SQL создаст группы по уникальным комбинациям значений.

##### **Пример: Количество рейсов по статусу и аэропорту отправления

```sql
SELECT departure_airport, status, COUNT(*) AS flight_count
FROM bookings.flights
GROUP BY departure_airport, status;
```

Этот запрос вернет количество рейсов для каждой комбинации аэропорт + статус (`On Time`, `Delayed`, `Cancelled` и т. д.).

#### **Когда `DISTINCT ON` полезнее `GROUP BY`?**

Если нужно выбрать **одну строку из группы**, `DISTINCT ON` работает эффективнее, чем `GROUP BY`.

##### **Пример: Самый последний рейс для каждого аэропорта отправления**

```sql
SELECT DISTINCT ON (departure_airport) flight_id, flight_no, scheduled_departure
FROM bookings.flights
ORDER BY departure_airport, scheduled_departure DESC;
```

- `DISTINCT ON (departure_airport)` оставляет только одну строку для каждого аэропорта.
- `ORDER BY departure_airport, scheduled_departure DESC` сортирует рейсы по аэропорту и времени вылета в убывающем порядке, так что для каждого аэропорта будет выбран самый последний рейс.
*В отличие от `GROUP BY`, нам не нужны агрегатные функции.

### **4. Фильтрация данных — `WHERE` vs `HAVING`**

#### **Почему важна фильтрация в аналитике?**

Фильтрация данных — это ключевой инструмент аналитика, позволяющий работать только с нужными записями. SQL предлагает два основных способа фильтрации:

- `WHERE` — фильтрует **отдельные строки** перед группировкой.
- `HAVING` — фильтрует **уже сгруппированные данные** после `GROUP BY`.

Понимание разницы между `WHERE` и `HAVING` помогает писать эффективные запросы и оптимизировать производительность.

---

### **Разница между `WHERE` и `HAVING`**

| Критерий                                  | `WHERE`                                   | `HAVING`                            |
| ----------------------------------------- | ----------------------------------------- | ----------------------------------- |
| Когда выполняется?                        | До `GROUP BY`, фильтрует отдельные строки | После `GROUP BY`, фильтрует группы  |
| Можно ли использовать агрегатные функции? | Нет                                       | Да                                  |

#### **Пример: Фильтрация рейсов по статусу (`WHERE`)**

```sql
SELECT * 
FROM bookings.flights
WHERE status = 'Delayed';
```

`WHERE` фильтрует строки до применения группировки, оставляя только те рейсы, которые имеют статус "Delayed".
#### **Пример: Фильтрация рейсов по средней задержке (`HAVING`)

```sql
SELECT departure_airport, AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure)))
FROM bookings.flights
WHERE actual_departure IS NOT NULL
GROUP BY departure_airport
HAVING AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))) > 4;
```

- Сначала фильтруются рейсы с фактическим временем отправления (`actual_departure IS NOT NULL`).
- После группировки по аэропортам (`GROUP BY departure_airport`), с помощью `HAVING` фильтруются только те аэропорты, где средняя задержка по рейсам превышает 4 минуты.

---

### **Почему `WHERE` нельзя использовать с агрегатными функциями?**

Ошибка в SQL возникает, если мы попытаемся использовать `AVG(price) > 1000` в `WHERE`:

```sql
SELECT departure_airport, AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))) > 4 AS avg_delay_min
FROM bookings.flights
WHERE AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))) > 4  -- Ошибка!
GROUP BY departure_airport;
```

**Ошибка:** `WHERE` не может фильтровать агрегатные функции. Агрегатные функции, такие как `AVG()`, вычисляются после группировки, поэтому они должны быть использованы в `HAVING`, а не в `WHERE`.

**Правильный вариант:**

```sql
SELECT departure_airport, AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))) > 4 AS avg_delay_min
FROM bookings.flights
WHERE actual_departure IS NOT NULL
GROUP BY departure_airport
HAVING AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))) > 4;
```

Теперь `HAVING` фильтрует результат **после** `GROUP BY`.

---

#### **Как правильно комбинировать `WHERE` и `HAVING`?**

Часто `WHERE` и `HAVING` используются вместе:

- `WHERE` **отбрасывает ненужные строки перед группировкой** → уменьшает объем данных.
- `HAVING` **фильтрует группы после агрегирования**.

##### **Пример 3: Фильтрация рейсов с низкой задержкой и только из крупных аэропортов**

```sql
SELECT departure_airport, COUNT(*) AS flight_count, AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))) AS avg_delay_min
FROM bookings.flights
WHERE status = 'Departed'
GROUP BY departure_airport
HAVING AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))) > 4;
```

- **`WHERE status = 'Departed'`** фильтрует только те рейсы, которые уже отправились (статус "Departed").
- **`EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))`** вычисляет разницу между фактическим временем отправления и запланированным временем в минутах.
- **`HAVING`** фильтрует аэропорты, где средняя задержка превышает 4 минуты.

---

#### **Как найти группы, в которых меньше N записей?**

Допустим, мы хотим найти аэропорты, где вылетает менее 500 рейсов

```sql
SELECT departure_airport, COUNT(*) AS flight_count
FROM bookings.flights
GROUP BY departure_airport
HAVING COUNT(*) < 500;
```

Здесь `HAVING COUNT(*) < 500` оставляет только те аэропорты, где количество рейсов меньше 500.

#### **Как использовать `HAVING` для поиска дубликатов?**

Один из частых кейсов в аналитике — поиск дубликатов.

##### **Пример: Найти товары, у которых одинаковые названия встречаются более одного раза**

```sql
SELECT aircraft_code, COUNT(*) AS duplicate_count
FROM flights
GROUP BY aircraft_code
HAVING COUNT(*) > 1;
```

Этот запрос покажет все судна, у которых одинаковые названия **встречаются более 1 раза**

### **5. Агрегатные функции в SQL: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`**

#### **Что такое агрегатные функции и зачем они нужны?**

Агрегатные функции позволяют **анализировать большие объемы данных** и получать обобщенные результаты. Они принимают множество строк и возвращают одно значение.

Применяются в:  
**Отчетах** — средний чек, сумма продаж, количество клиентов.  
**BI-системах** — построение сводных таблиц, дашбордов.  
**Фильтрации (`HAVING`)** — поиск категорий с высокой суммой продаж.  
**Группировке (`GROUP BY`)** — подсчет заказов на клиента.

#### **Основные агрегатные функции**

|Функция|Описание|Пример использования|
|---|---|---|
|`COUNT(*)`|Считает количество строк|Количество заказов|
|`SUM(column)`|Суммирует значения|Общая сумма покупок|
|`AVG(column)`|Вычисляет среднее значение|Средний чек клиента|
|`MIN(column)`|Находит минимальное значение|Самый дешевый товар|
|`MAX(column)`|Находит максимальное значение|Самая высокая зарплата|

**Важно:** Агрегатные функции **игнорируют `NULL`** (кроме `COUNT(*)`).

---

### **1. Функция `COUNT()` — Подсчет количества строк**

Используется для подсчета количества записей.

##### **Пример: Общее количество рейсов в базе**

```sql
SELECT COUNT(*) AS total_flights
FROM bookings.flights;
```

`COUNT(*)` **считает все строки**, включая те, где есть `NULL`.

##### **Пример: Количество отменённых рейсов**

```sql
SELECT COUNT(*) AS cancelled_flights
FROM bookings.flights
WHERE status = 'Cancelled';
```

`COUNT(price)` **не учитывает `NULL`-значения** (если у заказа нет цены, он не считается).

##### **Пример: Количество уникальных направлений (городов прибытия)**

```sql
SELECT COUNT(DISTINCT arrival_airport) AS unique_destinations
FROM bookings.flights;
```

`COUNT(DISTINCT column)` считает только уникальные значения.

---

### **2. Функция `SUM()` — Сумма значений**

Используется для расчета общей суммы по колонке.

##### **Пример: Общая выручка с каждого рейса**

```sql
SELECT flight_id, SUM(amount) AS total_revenue
FROM bookings.ticket_flights
GROUP BY flight_id;
```

Здесь SUM(amount) суммирует стоимость всех проданных билетов по каждому рейсу. **игнорируя `NULL`**.

##### **Пример: Общая выручка по классам обслуживания**

```sql
SELECT fare_conditions, SUM(amount) AS revenue_by_class
FROM bookings.ticket_flights
GROUP BY fare_conditions;
```

Этот запрос показывает, сколько денег заработано на каждом классе билетов: Economy, Comfort и Business.  

---

### **3. Функция `AVG()` — Среднее значение**

Используется для расчета среднего значения.

##### **Пример: Средняя задержка вылета по аэропортам**

```sql
SELECT departure_airport, AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))) AS avg_departure_delay
FROM bookings.flights
WHERE actual_departure IS NOT NULL
GROUP BY departure_airport;
```

`AVG(price)` **игнорирует `NULL`**.
Используем `EXTRACT(MINUTE FROM ...)`, чтобы получить среднюю задержку в минутах.
##### **Пример: Средняя длительность полёта по маршрутам**

```sql
SELECT departure_airport, arrival_airport, 
       AVG(EXTRACT(MINUTE FROM (actual_arrival - actual_departure))) AS avg_flight_time
FROM bookings.flights
WHERE actual_departure IS NOT NULL AND actual_arrival IS NOT NULL
GROUP BY departure_airport, arrival_airport;
```

Средний показатель полезен для сравнительного анализа.

**Как учитывать `NULL` в среднем?**  
Чтобы избежать искажений из-за `NULL`, можно заменить `NULL` на `0`:

```sql
SELECT AVG(COALESCE(EXTRACT(MINUTE FROM (actual_arrival - actual_departure)), 0)) AS avg_price
FROM bookings.flights;
```

`COALESCE(поле, 0)` заменяет `NULL` на `0`, чтобы учесть все строки.

---

### **4. Функции `MIN()` и `MAX()` — Минимум и максимум**

Используются для нахождения **наименьшего и наибольшего значений**.

##### **Пример: Самый долгий и самый короткий полёт**

```sql
SELECT 
    MIN(EXTRACT(MINUTE FROM (actual_arrival - actual_departure))) AS shortest_flight,
    MAX(EXTRACT(MINUTE FROM (actual_arrival - actual_departure))) AS longest_flight
FROM bookings.flights
WHERE actual_departure IS NOT NULL AND actual_arrival IS NOT NULL;
```

`MIN()` и `MAX()` **игнорируют `NULL`**.

##### **Пример: Самая ранняя и самая поздняя дата запланированных рейсов**

```sql
SELECT 
    MIN(scheduled_departure) AS first_scheduled_flight, 
    MAX(scheduled_departure) AS last_scheduled_flight
FROM bookings.flights;
```

 Работает не только с числами, но и с датами!

---

### **5. Как комбинировать агрегатные функции?**

Часто в аналитике **используется несколько агрегатных функций в одном запросе**.

##### **Пример: Общая статистика по рейсам**

```sql
SELECT 
    COUNT(*) AS total_flights,
    COUNT(*) FILTER (WHERE status = 'Cancelled') AS cancelled_flights,
    AVG(EXTRACT(MINUTE FROM (actual_departure - scheduled_departure))) AS avg_departure_delay,
    MIN(EXTRACT(MINUTE FROM (actual_arrival - actual_departure))) AS shortest_flight,
    MAX(EXTRACT(MINUTE FROM (actual_arrival - actual_departure))) AS longest_flight
FROM bookings.flights
WHERE actual_departure IS NOT NULL AND actual_arrival IS NOT NULL;
```

Запрос сразу показывает все ключевые метрики

---

### **6. Как считать процент отменённых рейсов?**

Частая задача — рассчитать процентное распределение.

##### **Пример: Доля отменённых рейсов от общего числа**

```sql
SELECT 
    COUNT(*) AS total_flights, 
    COUNT(*) FILTER (WHERE status = 'Cancelled') AS cancelled_flights,
    COUNT(*) FILTER (WHERE status = 'Cancelled') * 100.0 / COUNT(*) AS cancelled_percentage
FROM bookings.flights;
```

В данном случае можно использовать и `case`. Но метод с `FILTER` более читаемый и работает быстрее, чем `SUM(CASE WHEN ...)`, так как сразу фильтрует нужные строки внутри агрегатной функции.

### 6. **Группировка с `ROLLUP`, `CUBE`, `GROUPING SETS` (расширенные возможности)**

#### **1. Что такое расширенная группировка?**

Обычный `GROUP BY` позволяет группировать данные по одному или нескольким столбцам, но иногда нам нужны промежуточные итоги, общие суммы или разные комбинации группировок без выполнения нескольких отдельных запросов.

Расширенные возможности группировки (`ROLLUP`, `CUBE`, `GROUPING SETS`) помогают:

- **Добавлять промежуточные итоги** (например, сумму по месяцам и общую сумму за год).
- **Анализировать данные по разным комбинациям группировок** (например, по аэропорту, городу и общему количеству).
- **Избежать использования `UNION ALL` для объединения нескольких группировок** в одном запросе.

---

### **2. `ROLLUP`: Итоговые значения и подытоги**

`ROLLUP` создает иерархию группировки, начиная с детализированных данных и добавляя подытоги по уровням.

##### **Пример 1: Подсчет количества рейсов по аэропортам + общий итог**

```sql
SELECT departure_airport, arrival_airport, COUNT(*) AS total_flights
FROM bookings.flights
GROUP BY ROLLUP (departure_airport, arrival_airport);
```

**Что делает `ROLLUP`?**

- Считает количество рейсов по каждому направлению (аэропорт вылета → аэропорт прилета).
- Добавляет строки с итогами по каждому аэропорту вылета.
- Добавляет строку с общим итогом по всем рейсам.

**Результат:**

|departure_airport|arrival_airport|total_flights|
|---|---|---|
|DME|LED|120|
|DME|SVO|90|
|DME|NULL|210|
|LED|SVO|100|
|LED|NULL|100|
|NULL|NULL|310|

`NULL` в колонках означает, что это уровень агрегации (например, общий итог).

##### **Пример 2: Сумма продаж по месяцам + итог за год**

```sql
SELECT DATE_TRUNC('month', book_date) AS month, SUM(total_amount) AS total_sales
FROM bookings.bookings
GROUP BY ROLLUP (month);
```

**Результат:**

|month|total_sales|
|---|---|
|2024-01|50000|
|2024-02|42000|
|2024-03|38000|
|NULL|130000|

---

### **3. `CUBE`: Все возможные комбинации группировки**

`CUBE` делает все возможные комбинации группировки, включая независимые подытоги по каждому измерению.

##### **Пример 3: Количество рейсов по всем возможным комбинациям (аэропорт вылета и прилета)**

```sql
SELECT departure_airport, arrival_airport, COUNT(*) AS total_flights
FROM bookings.flights
GROUP BY CUBE (departure_airport, arrival_airport);
```

**Что делает `CUBE`?**

- Считает количество рейсов для каждой пары аэропортов.
- Добавляет подытоги для каждого аэропорта отдельно (и для вылета, и для прилета).
- Добавляет общий итог по всем рейсам.

**Результат:**

|departure_airport|arrival_airport|total_flights|
|---|---|---|
|DME|LED|120|
|DME|SVO|90|
|DME|NULL|210|
|LED|SVO|100|
|LED|NULL|100|
|NULL|SVO|190|
|NULL|LED|120|
|NULL|NULL|310|

`CUBE` генерирует больше строк, чем `ROLLUP`, так как он учитывает все возможные комбинации.

---

### **4. `GROUPING SETS`: Выборочные комбинации группировки**

`GROUPING SETS` позволяет явно задать, какие именно комбинации нам нужны (в отличие от `ROLLUP` и `CUBE`, которые строят иерархии автоматически).

##### **Пример 4: Только конкретные итоги (по аэропорту вылета и общий итог)**

```sql
SELECT departure_airport, COUNT(*) AS total_flights
FROM bookings.flights
GROUP BY GROUPING SETS ((departure_airport), ());
```

**Что делает `GROUPING SETS`?**

- Выдает количество рейсов по каждому аэропорту вылета.
- Добавляет только общий итог.

**Результат:**

|departure_airport|total_flights|
|---|---|
|DME|210|
|LED|100|
|NULL|310|

##### **Пример 5: Количество рейсов по двум разным уровням группировки**

```sql
SELECT departure_airport, arrival_airport, COUNT(*) AS total_flights
FROM bookings.flights
GROUP BY GROUPING SETS ((departure_airport), (arrival_airport));
```

**Что делает `GROUPING SETS`?**

- Выдает количество рейсов по каждому аэропорту вылета.
- Отдельно считает количество рейсов по каждому аэропорту прибытия.
- Не делает полный `CUBE`, то есть не добавляет итогов по комбинациям.

**Результат:**

|departure_airport|arrival_airport|total_flights|
|---|---|---|
|DME|NULL|210|
|LED|NULL|100|
|NULL|SVO|190|
|NULL|LED|120|

---

### **5. Как понять, когда использовать `ROLLUP`, `CUBE` или `GROUPING SETS`?**

**Используйте `ROLLUP`, если нужны подытоги в иерархии (например, аэропорт → страна → мир).**  
**Используйте `CUBE`, если хотите все возможные комбинации агрегатов (например, продажи по продуктам и городам).**  
**Используйте `GROUPING SETS`, если нужны только конкретные комбинации итогов.**

---

### **6. Как понять, какая строка является итоговой (`GROUPING()`)?**

Иногда итоговые строки выглядят так же, как обычные, но можно использовать `GROUPING()`, чтобы определить, какие значения были агрегированы.

```sql
SELECT departure_airport, arrival_airport, COUNT(*) AS total_flights,
       GROUPING(departure_airport) AS is_total_departure,
       GROUPING(arrival_airport) AS is_total_arrival
FROM bookings.flights
GROUP BY CUBE (departure_airport, arrival_airport);
```

**Результат:**

|departure_airport|arrival_airport|total_flights|is_total_departure|is_total_arrival|
|---|---|---|---|---|
|DME|LED|120|0|0|
|DME|NULL|210|0|1|
|NULL|SVO|190|1|0|
|NULL|NULL|310|1|1|

Если `GROUPING()` вернул `1`, значит, это итоговая строка.

---

**Вывод:**  
`ROLLUP`, `CUBE` и `GROUPING SETS` позволяют гибко агрегировать данные, избегая множества `UNION ALL` и сложных подзапросов.