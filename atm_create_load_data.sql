create schema atm_new_trans;

drop table if exists atm_new_trans.dim_date;
create table atm_new_trans.dim_date
(
	date_id integer not null,
	year integer,
	month varchar(20),
	day integer,
	weekday varchar(20),
	hour integer,
	full_date timestamp,
	constraint PK_dim_date primary key (date_id)
);

drop table if exists atm_new_trans.dim_location;
create table atm_new_trans.dim_location
(
	location_id integer not null,
	location varchar(50),
	streetname varchar(255),
	street_number integer,
	zipcode integer,
	lat decimal(10, 3),
	lon decimal(10, 3),
	constraint PK_dim_location primary key (location_id)
);

drop table if exists atm_new_trans.dim_atm;
create table atm_new_trans.dim_atm
(
	atm_id integer not null,
	atm_number varchar(20),
	atm_manufacturer varchar(255),
	location_id integer,
	constraint PK_dim_atm primary key (atm_id),
	constraint FK_dim_atm foreign key (location_id) references atm_new_trans.dim_location(location_id)
);


drop table if exists atm_new_trans.dim_card_type;
create table atm_new_trans.dim_card_type
(
	card_type_id integer not null,
	card_type varchar(50),
	constraint PK_dim_card_type primary key (card_type_id)
);


drop table if exists atm_new_trans.transaction_fact cascade;
create table atm_new_trans.transaction_fact
(
	trans_id bigint not null,
	date_id integer,
	atm_status varchar(20),
	atm_id integer,
	currency varchar(10),
	card_type_id integer,
	transaction_amount integer,
	service varchar(50),
	message_code varchar(255),
	message_text varchar(255),
	weather_loc_id integer,
	rain_3h decimal(10, 3),
	clouds_all integer,
	weather_id integer,
	weather_main varchar(255),
	weather_description varchar(255),
	constraint PK_transaction_fact primary key (trans_id),
	constraint FK_atm foreign key (atm_id) references atm_new_trans.dim_atm(atm_id),
	constraint FK_card_type foreign key (card_type_id) references atm_new_trans.dim_card_type(card_type_id),
	constraint FK_location foreign key (weather_loc_id) references atm_new_trans.dim_location(location_id),
	constraint FK_date foreign key (date_id) references atm_new_trans.dim_date(date_id)
);

copy atm_new_trans.dim_atm
from 's3://atmtransdata/atmtrans_v2/dim_atm.csv'
iam_role 'arn:aws:iam::823888918855:role/redshift_s3_fullaccess'
delimiter ',' region 'us-east-1'
CSV;

copy atm_new_trans.dim_location
from 's3://atmtransdata/atmtrans_v2/dim_location.csv'
iam_role 'arn:aws:iam::823888918855:role/redshift_s3_fullaccess'
delimiter ',' region 'us-east-1'
CSV;

copy atm_new_trans.dim_card_type
from 's3://atmtransdata/atmtrans_v2/dim_card_type.csv'
iam_role 'arn:aws:iam::823888918855:role/redshift_s3_fullaccess'
delimiter ',' region 'us-east-1'
CSV;

copy atm_new_trans.dim_date
from 's3://atmtransdata/atmtrans_v2/dim_date.csv'
iam_role 'arn:aws:iam::823888918855:role/redshift_s3_fullaccess'
delimiter ',' region 'us-east-1'
timeformat 'YYYY-MM-DDTHH:MI:SS'
CSV;

copy atm_new_trans.transaction_fact
from 's3://atmtransdata/atmtrans_v2/transaction_fact.csv'
iam_role 'arn:aws:iam::823888918855:role/redshift_s3_fullaccess'
delimiter ',' region 'us-east-1'
CSV;