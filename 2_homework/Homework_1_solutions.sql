-- 1.	Вывести все данные из таблицы flights.
SELECT *
FROM bookings.flights;

-- 2.	Вывести список всех пассажиров (их имена и фамилии).

SELECT distinct passenger_name
FROM bookings.tickets;

-- 3.	Вывести список номеров рейсов и аэропортов отправления из таблицы flights.
SELECT flight_no, departure_airport
FROM bookings.flights;

-- 4.	Вывести первые 10 записей из таблицы flights.
SELECT *
FROM bookings.flights f
limit 10

-- 5.	Вывести все рейсы, отправляющиеся из аэропорта "SVO".
select flight_no
FROM bookings.flights f
where departure_airport = 'SVO'

-- 6.	Вывести все рейсы, запланированные после "2017-09-14"
SELECT flight_no
FROM bookings.flights
WHERE scheduled_departure > '2017-09-14';

-- 7.	Вывести все рейсы, у которых не указано фактическое время вылета (actual_departure IS NULL).
select flight_no
FROM bookings.flights f
where actual_departure is null

-- 8.	Вывести все рейсы, у которых есть фактическое время вылета (actual_departure IS NOT NULL).
select flight_no
FROM bookings.flights f
where actual_departure is not null


-- 9.	Вывести список рейсов, отсортированный по времени вылета (scheduled_departure), сначала самые поздние.
select flight_no
FROM bookings.flights f
order by scheduled_departure desc

-- 10.	Вывести все рейсы, которые отправляются из "SVO" или "DME", и при этом ещё не вылетели (actual_departure IS NULL).
select flight_no
FROM bookings.flights f
where actual_departure is null and (departure_airport = 'SVO' or departure_airport = 'DME')

-- 11.	Вывести топ-5 самых последних прибывших (Arrived) рейсов, которые прилетели из аэропортов Москвы (SVO, DME, VKO).
select *
FROM bookings.flights f
where status = 'Arrived' and (departure_airport = 'SVO' or departure_airport = 'DME' or departure_airport = 'VKO')
order by actual_arrival desc
limit 5
