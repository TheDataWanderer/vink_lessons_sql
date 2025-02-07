## 1. Вывести список всех пассажиров (их имена и фамилии)

### Ошибка большинства:

Если запрос выполняется просто как:

```sql
SELECT passenger_name FROM bookings.tickets;
```

то он вернёт **все строки** из таблицы `passengers`, включая дубликаты, если у пассажиров одинаковые имена и фамилии.

### Как получить уникальные записи?

Есть два способа:

#### **1. DISTINCT**

```sql
SELECT DISTINCT passenger_name FROM bookings.tickets;
```

**Плюсы:**  
Легко использовать, сразу удаляет дублирующиеся строки по указанным столбцам.

**Минусы:**  
Работает медленно на больших таблицах, т.к. требует полной проверки на уникальность.  
Может не подойти, если нужны дополнительные данные (например, ID пассажира).

---

#### **2. GROUP BY**

```sql
SELECT passenger_name 
FROM bookings.tickets
GROUP BY 1
```

**Плюсы:**  
Работает аналогично `DISTINCT`, но позволяет добавлять агрегатные функции (`COUNT()`, `MAX()`, `MIN()` и т.д.).

**Минусы:**  
Без агрегатных функций смысла мало (кроме больших таблиц) — это просто `DISTINCT` с лишними шагами.

---

## 2. Регистрозависимость в `WHERE`

PostgreSQL **учитывает регистр** при сравнении строк.  
Пример:

```sql
SELECT * 
FROM bookings.flights f 
WHERE f.status = 'scheduled'
```

Этот запрос **не найдёт** строки, где `status = 'Scheduled'` или `SCHEDULED'`.

### Как решить проблему?

#### **1. Если таблица небольшая**

Можно вручную посмотреть уникальные значения через `Filter by value` в DBEAVER.

#### **2. Использовать `DISTINCT` или `GROUP BY` для просмотра значений**

```sql
SELECT DISTINCT f.status 
FROM bookings.flights f
```

#### **3. Приводить текст к нижнему или верхнему регистру (`LOWER()` или `UPPER()`)**

```sql
SELECT *
FROM bookings.flights f 
WHERE LOWER(f.status) = 'scheduled'
```

или

```sql
SELECT *
FROM bookings.flights f 
WHERE UPPER(f.status) = 'scheduled'
```

#### **4. Использовать не точное сопоставление (`LIKE`)**

- `%` — заменяет любое количество символов
- `_` — заменяет один символ

```sql
SELECT *
FROM bookings.flights f 
WHERE f.status LIKE '%chedu%'
```

Этот запрос найдёт все варианты`Scheduled`.

#### **5. Игнорировать регистр с `ILIKE` (альтернатива `LIKE`)**

```sql
SELECT *
FROM bookings.flights f 
WHERE f.status ILIKE 'scheduled'
```

`ILIKE` — это `LIKE`, но без учёта регистра.

---

## 3. Понимание "первых" и "последних" записей

### **1. Вывести первые 10 записей из таблицы**

Если сделать:

```sql
SELECT * FROM passengers LIMIT 10;
```

то получим **первые 10 строк**, но без явного порядка. **Порядок строк в таблице не определён!**

#### **Как задать порядок?**

Добавить `ORDER BY`:

```sql
SELECT * FROM passengers ORDER BY id LIMIT 10;
```

Если `id` автоинкрементный, то это будет **первые 10 пассажиров, добавленных в базу**.

---

### **2. Вывести топ-5 самых последних прибывших**

Здесь "самые последние" значит, что нужно упорядочить по дате прибытия (`arrival_time`).

```sql
SELECT * FROM passengers ORDER BY arrival_time DESC LIMIT 5;
```

- `ORDER BY arrival_time DESC` — сортирует от новых к старым
- `LIMIT 5` — берём только 5 самых последних

Если нужно, чтобы при одинаковом `arrival_time` сортировка была по `id`:

```sql
SELECT * FROM passengers ORDER BY arrival_time DESC, id DESC LIMIT 5;
```