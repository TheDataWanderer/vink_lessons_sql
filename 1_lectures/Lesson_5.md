# **Работа с объектами базы данных**  

## **1. Основные объекты базы данных**  

### **1.1. Таблицы (`TABLE`)**

Таблицы – основной объект хранения данных. Каждая строка таблицы представляет одну запись, а столбцы – её свойства.
  

Пример структуры таблицы можно увидеть запустив запрос и изменив название таблицы:
```sql
CREATE TABLE dwh_shared.nefatov_sales (
	id SERIAL PRIMARY KEY, -- Уникальный идентификатор
	sale_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Дата продажи
	customer_id UUID NOT NULL, -- Покупатель
	amount NUMERIC NOT NULL -- Сумма продажи
);
```
  
### **1.2. Представления (`VIEW`)**

Представления – это виртуальные таблицы, которые хранят SQL-запрос, но не данные. Они упрощают сложные запросы.

Пример:
```sql
CREATE VIEW dwh_shared.v_nefatov_sales_summary AS
SELECT sr.counteragent_id, SUM(sr.sum_sale) AS total_sales
FROM dwh_main_data.sales_row sr
GROUP BY sr.counteragent_id
```

  
Теперь можно обращаться к представлению как к таблице:

```sql
SELECT * FROM dwh_shared.v_nefatov_sales_summary;
```
  
### **1.3. Материализованные представления (`MATERIALIZED VIEW`)**

В отличие от обычных представлений, материализованные представления хранят данные, что ускоряет их выполнение. Однако их нужно вручную обновлять.  

Пример:
```sql
CREATE MATERIALIZED VIEW dwh_shared.vm_nefatov_sales_summary AS
SELECT sr.counteragent_id, SUM(sr.sum_sale) AS total_sales
FROM dwh_main_data.sales_row sr
GROUP BY sr.counteragent_id
```

Обновление данных:

```sql
REFRESH MATERIALIZED VIEW dwh_shared.vm_nefatov_sales_summary
```
  
### **1.4. Индексы (`INDEX`)**

Индексы ускоряют поиск данных, особенно по часто используемым столбцам.

Пример:
```sql
CREATE INDEX idx_sales_customer ON dwh_shared.nefatov_sales(sale_date);
```

Теперь поиск продаж по дате будет быстрее:

```sql
SELECT * FROM dwh_shared.nefatov_sales sr
WHERE sr.sale_date >= '2025-03-01'
```
 
---
## **2. Основные типы данных в SQL** (самые популярные)

### **2.1. Числовые типы**

- `INTEGER`, `BIGINT` – целые числа
- `NUMERIC`, `DECIMAL` – числа с плавающей точкой 
### **2.2. Строковые типы**

- `TEXT` – строка произвольной длины
- `VARCHAR(N)` – строка фиксированной длины
- `CHAR(N)` – строка точно N символов
### **2.3. Дата и время**

- `DATE` – только дата
- `TIMESTAMP` – дата + время
### **2.4. Логические типы**

- `BOOLEAN` – `TRUE`, `FALSE`, `NULL` 
### **2.5. Специальные типы**

- `UUID` – уникальные идентификаторы
- `JSONB` – хранение JSON
- `ARRAY` – массивы значений

---
## **3. Создание, наполнение и обновление объектов и таблиц**

### **3.1. Создание таблиц (`CREATE TABLE`)**

Пример:
```sql
CREATE TABLE dwh_shared.nefatov_sales (
	id SERIAL PRIMARY KEY, -- Уникальный идентификатор
	sale_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Дата продажи
	customer_id UUID NOT NULL, -- Покупатель
	amount NUMERIC NOT NULL CHECK (total_amount > 0) -- Сумма продажи
);
```

- `PRIMARY KEY` – уникальный идентификатор
- `DEFAULT` – значение по умолчанию
- `CHECK` – ограничение
### **3.2. Добавление данных в таблицу (`INSERT INTO`)**  
Чтобы добавить новые записи в таблицу `nefatov_sales`, используем команду `INSERT INTO`.  

**Простой пример вставки одной строки:**  
```sql
INSERT INTO dwh_shared.nefatov_sales (sale_date, customer_id, amount)
VALUES
    ('2024-03-14 12:00:00', '550e8400-e29b-41d4-a716-446655440001', 750.25)
```

**Добавление нескольких строк сразу:**  
```sql
INSERT INTO dwh_shared.nefatov_sales (sale_date, customer_id, amount)
VALUES
    ('2024-03-14 12:00:00', '550e8400-e29b-41d4-a716-446655440001', 750.25),
    ('2024-03-14 13:00:00', '550e8400-e29b-41d4-a716-446655440002', 450.75);
```

**Особенности:**
- Нужно явно указать те столбцы, которые будете заполнять.
- Если для столбца не задано значение, вставляются значения `NULL`

### **3.3. Обновление данных (`UPDATE`)**

Чтобы изменить существующие данные, используем `UPDATE`.

**Пример: изменим сумму продажи**
```sql
UPDATE dwh_shared.nefatov_sales
SET amount = 2000
WHERE sale_date = '2024-03-14 12:00:00' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';
```
  
**Важные моменты:**

- Без `WHERE` обновятся **все строки**, что может привести к потере данных.
- Если `UPDATE` касается большого количества строк, лучше делать **бэкап перед изменениями**.

### **3.4. Вставка или обновление (`UPSERT`)**

В некоторых случаях нужно **обновить данные, если они уже существуют**, или **вставить новые**, если их нет. В PostgreSQL для этого есть `ON CONFLICT`.

```sql
Тех.долг))
```  
---
## **4. Обновление объектов**

### **4.1. Изменение таблиц (`ALTER TABLE`)**

Добавление столбца:

```sql
ALTER TABLE dwh_shared.nefatov_sales ADD COLUMN owner_table text
```

Изменение типа данных:

```sql
ALTER TABLE dwh_shared.nefatov_sales ALTER COLUMN owner_table TYPE varchar(10);
```

Удаление столбца:

```sql
ALTER TABLE dwh_shared.nefatov_sales DROP COLUMN owner_table;
```

---
## **5. Удаление объектов**

### **5.1. Удаление данных (`DELETE`)**

Удаление заказов до 2023 года:

```sql
DELETE FROM dwh_shared.nefatov_sales
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440002';
```

### **5.2. Очистка таблицы (`TRUNCATE`)**

```sql
TRUNCATE TABLE dwh_shared.nefatov_sales
```

Удаляет все данные, но быстрее `DELETE`.  

### **5.3. Удаление таблиц и объектов (`DROP`)**

```sql
DROP TABLE dwh_shared.nefatov_sales;

DROP VIEW dwh_shared.v_nefatov_sales_summary;

DROP INDEX idx_sales_customer;
```

  