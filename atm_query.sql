-- 1 --
select da.atm_number, da.atm_manufacturer, dl.location, 
count(da.atm_id) as total_transaction_count, count(tf.atm_status) as inactive_count,
round(inactive_count * 100.0 / count(*), 1) as inactive_count_percent
from atm_new_trans.transaction_fact tf 
join atm_new_trans.dim_atm da on tf.atm_id = da.atm_id
join atm_new_trans.dim_location dl on da.location_id = dl.location_id
where tf.atm_status = 'Inactive' 
group by da.atm_number, da.atm_manufacturer, dl.location 
order by inactive_count desc limit 10;


-- 2 --
select dt1.weather_main, dt1.total_counts,
case
	when dt2.inactive_counts is null then 0 else dt2.inactive_counts
end as inactive_counts,
case
	when round(dt2.inactive_counts * 100.0 / dt1.total_counts, 4) is null then 0 else round(dt2.inactive_counts * 100.0 / dt1.total_counts, 4)
end as inactive_count_percent
from (select weather_main, count(*) as total_counts from atm_new_trans.transaction_fact where weather_main <> '' group by weather_main) dt1
left join (select weather_main, count(*) as inactive_counts
from atm_new_trans.transaction_fact where atm_status = 'Inactive' and weather_main <> ''
group by weather_main) dt2 on dt1.weather_main = dt2.weather_main order by inactive_count_percent desc;


-- 3 --
select da.atm_id, da.atm_manufacturer, dl.location, count(*) as transaction_count from atm_new_trans.transaction_fact tf
join atm_new_trans.dim_atm da on tf.atm_id = da.atm_id
join atm_trans_schema.dim_location dl on dl.location_id = da.location_id
group by da.atm_id, da.atm_manufacturer, dl.location order by transaction_count desc limit 10;


-- 4 --
select dd.year, dd.month, count(*) as total_transaction_count,
count(case
	when tf.atm_status = 'Inactive' then 1
end) as inactive_count,
round(inactive_count * 100.0 / total_transaction_count, 4) as inactive_count_percent
from atm_new_trans.transaction_fact tf
join atm_new_trans.dim_atm da on da.atm_id = tf.atm_id
join atm_new_trans.dim_date dd on tf.date_id = dd.date_id
group by dd.year, dd.month
order by dd.month;

-- 5 --
select da.atm_id, da.atm_manufacturer, dl.location, sum(tf.transaction_amount) as total_trans_amount from atm_new_trans.transaction_fact tf
join atm_new_trans.dim_atm da on tf.atm_id = da.atm_id
join atm_new_trans.dim_location dl on da.location_id = dl.location_id
group by da.atm_id, da.atm_manufacturer, dl.location order by total_trans_amount desc limit 10;


-- 6 --
select ct.card_type, count(*) as total_transaction_count,
count(case
	when tf.atm_status = 'Inactive' then 1
end) as inactive_count,
round(inactive_count * 100.0 / total_transaction_count, 4) as inactive_count_percent
from atm_new_trans.transaction_fact tf
join atm_new_trans.dim_card_type ct on tf.card_type_id = ct.card_type_id
group by ct.card_type order by inactive_count_percent desc;


-- 7 --
select da.atm_number, da.atm_manufacturer, dl.location, 
case 
	when dd.weekday in ('Saturday', 'Sunday') then 1 else 0 
end as weekend_flag, 
count(*) as total_transaction_count
from atm_new_trans.transaction_fact tf
join atm_new_trans.dim_atm da on tf.atm_id = da.atm_id
join atm_new_trans.dim_date dd on tf.date_id = dd.date_id
join atm_new_trans.dim_location dl on da.location_id = dl.location_id
group by da.atm_id, da.atm_number, da.atm_manufacturer, dl.location, weekend_flag
order by da.atm_number, weekend_flag, total_transaction_count;


-- 8 --
drop view if exists atm_new_trans.weekday_trans;
create view atm_new_trans.weekday_trans as
select dd.weekday, count(*)
from atm_new_trans.transaction_fact tf
join atm_new_trans.dim_date dd on dd.date_id = tf.date_id
join atm_new_trans.dim_atm da on tf.atm_id = da.atm_id
join atm_new_trans.dim_location dl on dl.location_id = da.location_id
where dl.location = 'Vejgaard' group by dd.weekday;


select da.atm_id, da.atm_manufacturer, dd.weekday,
dl.location, count(*) as total_transaction_count
from atm_new_trans.transaction_fact tf
join atm_new_trans.dim_date dd on dd.date_id = tf.date_id
join atm_new_trans.dim_atm da on da.atm_id = tf.atm_id
join atm_new_trans.dim_location dl on dl.location_id = da.location_id
where dl.location = 'Vejgaard' and dd.weekday = (select weekday
from atm_new_trans.weekday_trans 
where count = (select max(count) from atm_trans_schema.weekday_trans))
group by da.atm_id, da.atm_manufacturer, dd.weekday, dl.location
order by total_transaction_count;