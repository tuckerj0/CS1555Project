-- PittTours by Vivek Sen and Jason Tucker

-- Schema
drop table airline cascade constraints;
drop table flight cascade constraints;
drop table plane cascade constraints;
drop table price cascade constraints;
drop table customer cascade constraints;
drop table reservation cascade constraints;
drop table reservation_detail cascade constraints;
drop table timeInfo cascade constraints;

create table airline(
	aid varchar2(5),
	name varchar2(50),
	abbreviation varchar2(10),
	year_founded int,
	constraint Airline_pk primary key(aid)
);

create table plane(
	plane_type varchar2(4),
	manufacture varchar2(10),
	plane_capacity int,
	last_service_date date,
	year int,
	owner_id varchar(5),
	constraint plane_pk primary key(plane_type, owner_id),
	constraint plane_fk foreign key(owner_id) references airline(aid) 
);

create table flight(
	flight_number varchar2(3),
	airline_id varchar2(5),
	plane_type varchar2(4),
	departure_city varchar2(3),
	arrival_city varchar2(3),
	departure_time varchar2(4),
	arrival_time varchar2(4),
	weekely_schedule varchar2(7),
	constraint flight_pk primary key(flight_number),
	constraint flight_fk1 foreign key(plane_type, airline_id) references plane(plane_type, owner_id)
);


create table price(
	departure_city varchar2(3),
	arrival_city varchar2(3),
	airline_id varchar2(5),
	high_price int,
	low_price int,
	constraint price_pk primary key (departure_city, arrival_city),
	constraint price_fk foreign key (airline_id) references airline(aid)	
);

create table customer(
	cid varchar2(9),
	salutation varchar2(3),
	first_name varchar2(30),
	last_name varchar2(30),
	credit_card_num varchar2(16),
	credit_card_expire date,
	street varchar(30),
	city varchar2(30),
	state varchar2(30),
	phone varchar2(10),
	email varchar2(30),
	frequent_miles varchar(5),
	constraint customer_pk primary key (cid)
);

create table reservation(
	reservation_number varchar2(5),
	cid varchar2(9),
	cost int,
	credit_card_num varchar(16),
	reservation_date date,
	ticketed varchar(1),
	start_city varchar(3),
	end_city varchar(3),
	constraint reservation_pk primary key(reservation_number),
	constraint reservation_fk1 foreign key (cid) references customer (cid)
);

create table reservation_detail(
	reservation_number varchar(5),
	flight_number varchar(3),
	flight_date date,
	leg int,
	constraint reservation_detail_pk primary key(reservation_number, leg),
	constraint reservation_detail_fk1 foreign key (reservation_number) references reservation(reservation_number),
	constraint reservation_detail_fk2 foreign key (flight_number) references flight(flight_number)
);

create table timeInfo(
	c_date date,
	constraint timeInfo_pk primary key (c_date)
);

--set cost trigger
--sets cost of reservation upon insertion
create or replace trigger setCost
before insert
on reservation
for each row
declare 
cTime date;
new_price int;
begin
select *
into cTime
from timeInfo;
	if (:new.reservation_date = cTime)
	then
		select high_price into new_price
		from price
		where :new.start_city = departure_city and :new.end_city = arrival_city;
	end if;
	if (:new.reservation_date != cTime)
	then
		select low_price into new_price
		from price
		where :new.start_city = departure_city and :new.end_city = arrival_city;
	end if;
:new.cost := new_price;
END;
/

--procedure
create or replace function biggerPlane (plane_capacity in int) return char (4)
as
begin try
if (Plane.plane_capacity > plane_capacity and Plane.airline_id = Flight.airline_id)
	return Plane.plane_type;
end try
begin catch 
	RAISERROR ('SORRY NO LARGER PLANE') WITH NOWAIT;
end;
/

create or replace function smallerPlane (plane_capacity in int) return char (4)
as
begin try
if (Plane.plane_capacity < plane_capacity and Plane.airline_id = Flight.airline_id)
	return Plane.plane_type;
end try
begin catch
	RAISERROR ('SORRY NO SMALLER PLANE') WITH NOWAIT;
end;
/

-- function

create or replace trigger adjustTicket
after update Price
for each row
begin
update Reservation
if (Reservation.reservation_date = Date.c_date) {
reservation.cost := Reservation.cost + (Price.high_price - new.high_price);
}
else {
reservation.cost := Reservation.cost + (Price.low_price - new.low_price);
}
END; / 

--planeUpdate trigger
 
create or replace trigger planeUpgrade
before update Reservation_detail
for each row
when (COUNT(Reservation_detail.reservation_number) > Plane.plane_capacity)
begin
Flight.plane_type = largerPlane(:new.plane_capacity);
where  Reservation_detail.flight_number = Flight.flight_number
end; /

-- cancel reservation triger
create or replace cancelReservation
before update Reservation
for each row
declare @dt
declare @timeDiff
	@dt = CURRENT_TIME
	@timeDiff = @dt - departure_time
	if (timeDiff < 12 and Reservation.ticketed = 'N') 
			Flight.plane_type = smallerPlane(:new.plane_capacity)
where Flight.flight_number = Reservation_detail.flight_number
end;/

start pittToursData.sql
