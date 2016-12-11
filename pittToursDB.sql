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

--adjustTicket 

create or replace trigger adjustTicket
after update 
on Price
for each row
declare 
cTime date;
new_price int;
begin
select *
into cTime
from timeInfo;
	update reservation
	set cost = :new.low_price
	where :new.departure_city = start_city and :new.arrival_city = end_city and ctime != reservation_date and ticketed = 0;
	update reservation
	set cost = :new.high_price
	where :new.departure_city = start_city and :new.arrival_city = end_city and ctime = reservation_date and ticketed = 0;
END; 
/

--Above this line works
--Below this line needs replaced 
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

--insert 10 airlines
INSERT INTO AIRLINE VALUES ('001', 'United Airlines', 'UAL', 1931);
INSERT INTO AIRLINE VALUES ('002', 'All Nippon Airways', 'ANA', 1952);
INSERT INTO AIRLINE VALUES ('003', 'Delta Air Lines', 'DAL', 1924);
INSERT INTO AIRLINE VALUES ('004', 'Belair Airlines', 'BHP', 1925);
INSERT INTO AIRLINE VALUES ('005', 'Western Airlines', 'WAL', 1925);
INSERT INTO AIRLINE VALUES ('006', 'Northwest Airlines', 'NWA', 1926);
INSERT INTO AIRLINE VALUES ('007', 'Lufthansa', 'DLH', 1953);
INSERT INTO AIRLINE VALUES ('008', 'American Airlines', 'AAL', 1926);
INSERT INTO AIRLINE VALUES ('009', 'British Airways', 'BAW', 1974);
INSERT INTO AIRLINE VALUES ('010', 'Qatar Airways', 'QAF', 1993);


--insert time
INSERT INTO timeInfo Values(to_date('10/1/2016', 'mm/dd/yyyy'));

--insert 30 planes
-- boeing 10
INSERT INTO PLANE VALUES ('B737', 'Boeing', 125, to_date('09/09/2009', 
'mm/dd/yyyy'), 1996, '001'); 
INSERT INTO PLANE VALUES ('B737', 'Boeing', 125, to_date('12/09/2009', 
'mm/dd/yyyy'), 1999, '003'); 
INSERT INTO PLANE VALUES ('B737', 'Boeing', 125, to_date('12/09/2010', 
'mm/dd/yyyy'), 1996, '002'); 
INSERT INTO PLANE VALUES ('B747', 'Boeing', 450, to_date('09/09/2010', 
'mm/dd/yyyy'), 1997, '007');
INSERT INTO PLANE VALUES ('B757', 'Boeing', 280, to_date('10/09/2009', 
'mm/dd/yyyy'), 2000, '008');
INSERT INTO PLANE VALUES ('B757', 'Boeing', 280, to_date('11/09/2009', 
'mm/dd/yyyy'), 2002, '001');
INSERT INTO PLANE VALUES ('B757', 'Boeing', 280, to_date('10/09/2007', 
'mm/dd/yyyy'), 2000, '005');
INSERT INTO PLANE VALUES ('B767', 'Boeing', 370, to_date('11/10/2011', 
'mm/dd/yyyy'), 1996, '002');
INSERT INTO PLANE VALUES ('B777', 'Boeing', 300, to_date('08/09/2009', 
'mm/dd/yyyy'), 1998, '001');
INSERT INTO PLANE VALUES ('B787', 'Boeing', 290, to_date('12/09/2012', 
'mm/dd/yyyy'), 2012, '003');

--airbus 10
INSERT INTO PLANE VALUES ('A319', 'Airbus', 160, to_date('06/15/2003', 
'mm/dd/yyyy'), 1995, '004');
INSERT INTO PLANE VALUES ('A319', 'Airbus', 160, to_date('07/15/2003', 
'mm/dd/yyyy'), 1998, '001'); 
INSERT INTO PLANE VALUES ('A320', 'Airbus', 155, to_date('10/01/2011', 
'mm/dd/yyyy'), 2001, '001'); 
INSERT INTO PLANE VALUES ('A320', 'Airbus', 155, to_date('10/01/2012', 
'mm/dd/yyyy'), 2002, '004'); 
INSERT INTO PLANE VALUES ('A300', 'Airbus', 266, to_date('10/01/2010', 
'mm/dd/yyyy'), 1990, '001'); 
INSERT INTO PLANE VALUES ('A310', 'Airbus', 155, to_date('10/01/2011', 
'mm/dd/yyyy'), 1990, '009'); 
INSERT INTO PLANE VALUES ('A330', 'Airbus', 335, to_date('08/01/2012', 
'mm/dd/yyyy'), 1999, '010');
INSERT INTO PLANE VALUES ('A340', 'Airbus', 375, to_date('04/01/2011', 
'mm/dd/yyyy'), 2001, '001');
INSERT INTO PLANE VALUES ('A350', 'Airbus', 280, to_date('06/07/2014', 
'mm/dd/yyyy'), 2000, '008');
INSERT INTO PLANE VALUES ('A380', 'Airbus', 525, to_date('10/01/2015', 
'mm/dd/yyyy'), 2007, '007'); 

-- embraer 9
INSERT INTO PLANE VALUES ('E145', 'Embraer', 50, to_date('06/15/2010', 
'mm/dd/yyyy'), 2008, '002');
INSERT INTO PLANE VALUES ('E145', 'Embraer', 50, to_date('07/22/2010', 
'mm/dd/yyyy'), 2008, '001');
INSERT INTO PLANE VALUES ('E145', 'Embraer', 50, to_date('06/15/2011', 
'mm/dd/yyyy'), 2007, '003');
INSERT INTO PLANE VALUES ('E190', 'Embraer', 114, to_date('07/15/2010', 
'mm/dd/yyyy'), 2005, '010');
INSERT INTO PLANE VALUES ('E190', 'Embraer', 114, to_date('08/15/2010', 
'mm/dd/yyyy'), 2004, '002');
INSERT INTO PLANE VALUES ('E190', 'Embraer', 114, to_date('06/15/2010', 
'mm/dd/yyyy'), 2007, '001');
INSERT INTO PLANE VALUES ('E195', 'Embraer', 122, to_date('07/15/2010', 
'mm/dd/yyyy'), 2006, '004');
INSERT INTO PLANE VALUES ('E170', 'Embraer', 78, to_date('08/15/2010', 
'mm/dd/yyyy'), 2005, '003');
INSERT INTO PLANE VALUES ('E175', 'Embraer', 88, to_date('04/05/2010', 
'mm/dd/yyyy'), 2007, '006'); 

-- tupolev 1
INSERT INTO PLANE VALUES ('T204', 'Tupolev', 200, to_date('06/15/2008', 
'mm/dd/yyyy'), 1995, '007');

--insert 100 flights
INSERT INTO FLIGHT VALUES ('001', '001', 'A320', 'PIT', 'DCA', '1000', '1120', 'SMTWTFS');
INSERT INTO FLIGHT VALUES ('002', '003', 'B737', 'JFK', 'DCA', '0015', '0100', 'S-TW-FS');
INSERT INTO FLIGHT VALUES ('003', '003', 'E145', 'PIT', 'DCA', '1100', '1150', 'SM-WT-S');
INSERT INTO FLIGHT VALUES ('004', '001', 'B737', 'LAX', 'DCA', '1200','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('005', '001', 'B757', 'LAX', 'DCA', '2100','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('006', '001', 'A319', 'LAX', 'DCA', '2000','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('007', '001', 'B777', 'LAX', 'DCA', '0200','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('008', '001', 'A320', 'LAX', 'DCA', '1800','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('009', '001', 'A340', 'LAX', 'DCA', '1700','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('010', '001', 'E190', 'LAX', 'DCA', '1500','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('011', '001', 'E145', 'LAX', 'DCA', '1400','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('012', '002', 'B737', 'LAX', 'DCA', '1300','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('013', '005', 'B757', 'LAX', 'DCA', '1900','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('014', '002', 'B767', 'LAX', 'DCA', '2200','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('015', '002', 'E190', 'LAX', 'DCA', '2300','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('016', '002', 'E145', 'LAX', 'DCA', '0400','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('017', '003', 'B737', 'LAX', 'DCA', '0500','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('018', '003', 'E145', 'LAX', 'DCA', '1000','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('019', '003', 'E170', 'LAX', 'DCA', '1100','1250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('020', '003', 'B787', 'LAX', 'DCA', '0900','1250', 'SM-T-S');

INSERT INTO FLIGHT VALUES ('021', '004', 'A319', 'SFA', 'PIT', '1600','1650', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('022', '004', 'E195', 'SFA', 'PIT', '1100','1350', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('023', '004', 'A320', 'SFA', 'PIT', '2000','2150', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('024', '005', 'B757', 'SFA', 'PIT', '2100','2250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('025', '002', 'E145', 'SFA', 'PIT', '2200','2350', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('026', '007', 'B747', 'SFA', 'PIT', '1900','2050', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('027', '007', 'T204', 'SFA', 'PIT', '1800','2050', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('028', '007', 'A380', 'SFA', 'PIT', '1700','1950', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('029', '008', 'B757', 'SFA', 'PIT', '1600','1850', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('030', '008', 'A350', 'SFA', 'PIT', '1400','1650', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('031', '009', 'A310', 'SFA', 'PIT', '1300','1750', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('032', '010', 'A330', 'SFA', 'PIT', '1200','1550', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('033', '010', 'E190', 'SFA', 'PIT', '1100','1450', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('034', '001', 'B737', 'SFA', 'PIT', '1000','1350', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('035', '001', 'B757', 'SFA', 'PIT', '0900','1150', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('036', '001', 'A319', 'SFA', 'PIT', '0800','1050', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('037', '001', 'B777', 'SFA', 'PIT', '0700','0950', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('038', '001', 'A320', 'SFA', 'PIT', '0400','0650', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('039', '001', 'A340', 'SFA', 'PIT', '0300','0650', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('040', '001', 'E190', 'SFA', 'PIT', '0200','0650', 'SM-T-S');


INSERT INTO FLIGHT VALUES ('041', '001', 'A320', 'SFA', 'DCA', '1600','1850', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('042', '003', 'B737', 'SFA', 'DCA', '1600','1850', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('043', '003', 'E145', 'SFA', 'DCA', '1600','1850', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('044', '001', 'B737', 'SFA', 'DCA', '1000','1450', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('045', '001', 'B757', 'SFA', 'DCA', '1000','1350', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('046', '001', 'A319', 'SFA', 'DCA', '2200','0150', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('047', '001', 'B777', 'SFA', 'DCA', '2200','0150', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('048', '001', 'A320', 'SFA', 'DCA', '2300','0250', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('049', '001', 'A340', 'SFA', 'DCA', '1800','2050', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('050', '001', 'E190', 'SFA', 'DCA', '1700','1950', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('051', '001', 'E145', 'SFA', 'DCA', '1600','1950', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('052', '002', 'B737', 'SFA', 'DCA', '1500','1850', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('053', '008', 'B757', 'SFA', 'DCA', '1400','1650', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('054', '002', 'B767', 'SFA', 'DCA', '1300','1650', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('055', '002', 'E190', 'SFA', 'DCA', '1200','1650', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('056', '002', 'E145', 'SFA', 'DCA', '0200','0750', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('057', '003', 'B737', 'SFA', 'DCA', '0100','0550', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('058', '003', 'E145', 'SFA', 'DCA', '0300','0650', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('059', '003', 'E170', 'SFA', 'DCA', '0400','0650', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('060', '003', 'B787', 'SFA', 'DCA', '0500','0850', 'SM-T-S');

INSERT INTO FLIGHT VALUES ('061', '001', 'A320', 'DCA', 'SFA', '2000','2200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('062', '003', 'B737', 'DCA', 'SFA', '2100','2200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('063', '003', 'E145', 'DCA', 'SFA', '2200','2300', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('064', '001', 'B737', 'DCA', 'SFA', '2300','0100', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('065', '001', 'B757', 'DCA', 'SFA', '2000','2200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('066', '001', 'A319', 'DCA', 'SFA', '1400','1800', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('067', '001', 'B777', 'DCA', 'SFA', '1600','1700', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('068', '001', 'A320', 'DCA', 'SFA', '2100','2200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('069', '001', 'A340', 'DCA', 'SFA', '2100','2200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('070', '001', 'E190', 'DCA', 'SFA', '2100','2200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('071', '001', 'E145', 'DCA', 'SFA', '1300','1600', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('072', '002', 'B737', 'DCA', 'SFA', '0900','1000', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('073', '008', 'B757', 'DCA', 'SFA', '0500','1000', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('074', '002', 'B767', 'DCA', 'SFA', '0600','0900', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('075', '002', 'E190', 'DCA', 'SFA', '0700','1000', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('076', '002', 'E145', 'DCA', 'SFA', '0800','1100', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('077', '003', 'B737', 'DCA', 'SFA', '1000','1400', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('078', '003', 'E145', 'DCA', 'SFA', '2100','2300', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('079', '003', 'E170', 'DCA', 'SFA', '2100','2300', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('080', '003', 'B787', 'DCA', 'SFA', '2100','2300', 'SM-T-S');

INSERT INTO FLIGHT VALUES ('081', '004', 'A319', 'ATL', 'LAX', '1000','1200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('082', '004', 'E195', 'ATL', 'LAX', '1100','1200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('083', '004', 'A320', 'ATL', 'LAX', '2200','2300', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('084', '005', 'B757', 'ATL', 'LAX', '2100','2300', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('085', '002', 'E145', 'ATL', 'LAX', '2100','2200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('086', '007', 'B747', 'ATL', 'LAX', '2100','2200', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('087', '007', 'T204', 'ATL', 'LAX', '1600','2000', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('088', '007', 'A380', 'ATL', 'LAX', '1500','1800', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('089', '008', 'B757', 'ATL', 'LAX', '1400','1600', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('090', '008', 'A350', 'ATL', 'LAX', '0900','1100', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('091', '009', 'A310', 'ATL', 'LAX', '0900','1100', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('092', '010', 'A330', 'ATL', 'LAX', '0800','1000', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('093', '010', 'E190', 'ATL', 'LAX', '0700','0900', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('094', '001', 'B737', 'ATL', 'LAX', '1800','2100', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('095', '001', 'B757', 'ATL', 'LAX', '1900','2100', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('096', '001', 'A319', 'ATL', 'LAX', '0600','0800', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('097', '001', 'B777', 'ATL', 'LAX', '0600','0800', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('098', '001', 'A320', 'ATL', 'LAX', '0500','0700', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('099', '001', 'A340', 'ATL', 'LAX', '0500','0700', 'SM-T-S');
INSERT INTO FLIGHT VALUES ('100', '001', 'E190', 'ATL', 'LAX', '2300','0100', 'SM-T-S');



--price

INSERT INTO PRICE VALUES ('PIT', 'DCA', '001', 200, 100);
INSERT INTO PRICE VALUES ('JFK', 'DCA', '003', 100, 50);
INSERT INTO PRICE VALUES ('LAX', 'DCA', '005', 350, 250);
INSERT INTO PRICE VALUES ('SFA', 'PIT', '004', 600, 550);
INSERT INTO PRICE VALUES ('SFA', 'DCA', '003', 500, 400);
INSERT INTO PRICE VALUES ('DCA', 'SFA', '001', 450, 400);
INSERT INTO PRICE VALUES ('ATL', 'LAX', '004', 350, 300);
INSERT INTO PRICE VALUES ('LAX', 'SFA', '003', 370, 325);
INSERT INTO PRICE VALUES ('SFA', 'LAX', '001', 300, 250);

-- customer values
insert into customer values('000000000', 'Mr', 'heywood', 'mccrone', '0000000000019952', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Orlando', 'ND', '0000000407', 'heywoodmccrone@gmail.com', '00002');
insert into customer values('000000001', 'Mr', 'ellwood', 'swann', '0000000000030735', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Dallas', 'SC', '0000000735', 'ellwoodswann@gmail.com', '00009');
insert into customer values('000000002', 'Mr', 'rodolph', 'mccormack', '0000000000057906', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Moscow', 'SC', '0000000604', 'rodolphmccormack@gmail.com', '00001');
insert into customer values('000000003', 'Mr', 'conan', 'hutchison', '0000000000049874', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Dallas', 'OH', '0000000686', 'conanhutchison@gmail.com', '00008');
insert into customer values('000000004', 'Mr', 'jessey', 'ruthning', '0000000000080159', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Baltimore', 'KA', '0000000137', 'jesseyruthning@gmail.com', '00001');
insert into customer values('000000005', 'Mr', 'carny', 'de ferrers', '0000000000082268', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Miami', 'CA', '0000000874', 'carnyde ferrers@gmail.com', '00004');
insert into customer values('000000006', 'Mr', 'ber', 'schmidt', '0000000000028873', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Philadelphia', 'NA', '0000000555', 'berschmidt@gmail.com', '00005');
insert into customer values('000000007', 'Mr', 'corey', 'bryant', '0000000000053161', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Dubai', 'GA', '0000000525', 'coreybryant@gmail.com', '00003');
insert into customer values('000000008', 'Mr', 'ive', 'de-mouton', '0000000000082093', to_date('10/10/2020', 'mm/dd/yyyy'), 'sennot', 'London', 'De', '0000000871', 'ivede-mouton@gmail.com', '00004');
insert into customer values('000000009', 'Mr', 'rock', 'denney', '0000000000034681', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Orlando', 'GA', '0000000505', 'rockdenney@gmail.com', '00006');
insert into customer values('000000010', 'Mr', 'maurice', 'barradell', '0000000000021660', to_date('10/10/2020', 'mm/dd/yyyy'), 'view', 'Pittsburgh', 'De', '0000000677', 'mauricebarradell@gmail.com', '00007');
insert into customer values('000000011', 'Mr', 'hurley', 'smith', '0000000000041158', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Baltimore', 'ND', '0000000384', 'hurleysmith@gmail.com', '00004');
insert into customer values('000000012', 'Mr', 'jeremias', 'mordy', '0000000000045783', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Miami', 'FA', '0000000119', 'jeremiasmordy@gmail.com', '00007');
insert into customer values('000000013', 'Mr', 'noble', 'rowlandson', '0000000000058733', to_date('10/10/2020', 'mm/dd/yyyy'), 'oak', 'Houston', 'OG', '0000000126', 'noblerowlandson@gmail.com', '00004');
insert into customer values('000000014', 'Mr', 'tadd', 'mcintosh', '0000000000058540', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'Moscow', 'ND', '0000000374', 'taddmcintosh@gmail.com', '00010');
insert into customer values('000000015', 'Mr', 'donnie', 'cullison', '0000000000094618', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Miami', 'De', '0000000953', 'donniecullison@gmail.com', '00006');
insert into customer values('000000016', 'Mr', 'fritz', 'rumsey', '0000000000017384', to_date('10/10/2020', 'mm/dd/yyyy'), 'second', 'Miami', 'OH', '0000000473', 'fritzrumsey@gmail.com', '00006');
insert into customer values('000000017', 'Mr', 'jacobo', 'digweed', '0000000000034029', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'New York', 'CA', '0000000873', 'jacobodigweed@gmail.com', '00001');
insert into customer values('000000018', 'Mr', 'maximilianus', 'miller', '0000000000094781', to_date('10/10/2020', 'mm/dd/yyyy'), 'oak', 'Denver', 'NY', '0000000419', 'maximilianusmiller@gmail.com', '00006');
insert into customer values('000000019', 'Mr', 'clyde', 'piper', '0000000000022912', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'Boston', 'GA', '0000000059', 'clydepiper@gmail.com', '00009');
insert into customer values('000000020', 'Mr', 'eli', 'aldeburgh#', '0000000000001951', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Miami', 'FA', '0000000994', 'elialdeburgh#@gmail.com', '00009');
insert into customer values('000000021', 'Mr', 'hercule', 'john', '0000000000087569', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Philadelphia', 'CA', '0000000110', 'herculejohn@gmail.com', '00001');
insert into customer values('000000022', 'Mr', 'felicio', 'whitby', '0000000000032713', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Pittsburgh', 'De', '0000000956', 'feliciowhitby@gmail.com', '00004');
insert into customer values('000000023', 'Mr', 'chucho', 'de culcheth', '0000000000039255', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'Pittsburgh', 'VM', '0000000701', 'chuchode culcheth@gmail.com', '00009');
insert into customer values('000000024', 'Mr', 'vernor', 'bruford', '0000000000011351', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Cleveland', 'VM', '0000000218', 'vernorbruford@gmail.com', '00003');
insert into customer values('000000025', 'Mr', 'nolan', 'horrage', '0000000000023533', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Boston', 'NC', '0000000787', 'nolanhorrage@gmail.com', '00002');
insert into customer values('000000026', 'Mr', 'burk', 'of lancaster', '0000000000071054', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Houston', 'NY', '0000000086', 'burkof lancaster@gmail.com', '00003');
insert into customer values('000000027', 'Mr', 'lev', 'greave', '0000000000057871', to_date('10/10/2020', 'mm/dd/yyyy'), 'sennot', 'Moscow', 'ID', '0000000904', 'levgreave@gmail.com', '00003');
insert into customer values('000000028', 'Mr', 'tobit', 'weintraub', '0000000000050167', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'Houston', 'GA', '0000000414', 'tobitweintraub@gmail.com', '00008');
insert into customer values('000000029', 'Mr', 'olvan', 'omara', '0000000000091823', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'Cleveland', 'ND', '0000000423', 'olvanomara@gmail.com', '00001');
insert into customer values('000000030', 'Mr', 'ambros', 'brownley', '0000000000014222', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Houston', 'FA', '0000000514', 'ambrosbrownley@gmail.com', '00008');
insert into customer values('000000031', 'Mr', 'garik', 'shimmin', '0000000000054871', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Baltimore', 'NA', '0000000743', 'garikshimmin@gmail.com', '00008');
insert into customer values('000000032', 'Mr', 'vivek', 'flower', '0000000000082184', to_date('10/10/2020', 'mm/dd/yyyy'), 'park', 'Cleveland', 'SC', '0000000850', 'vivekflower@gmail.com', '00004');
insert into customer values('000000033', 'Mr', 'shamus', 'thicknesse', '0000000000038683', to_date('10/10/2020', 'mm/dd/yyyy'), 'Forbes', 'Philadelphia', 'NY', '0000000989', 'shamusthicknesse@gmail.com', '00001');
insert into customer values('000000034', 'Mr', 'laurie', 'hatton', '0000000000014956', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Ontario', 'HA', '0000000830', 'lauriehatton@gmail.com', '00002');
insert into customer values('000000035', 'Mr', 'jessie', 'cory', '0000000000032014', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Orlando', 'NY', '0000000209', 'jessiecory@gmail.com', '00008');
insert into customer values('000000036', 'Mr', 'nicolai', 'jenson', '0000000000051022', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Baltimore', 'VM', '0000000547', 'nicolaijenson@gmail.com', '00009');
insert into customer values('000000037', 'Mr', 'payton', 'ymonds', '0000000000044332', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Orlando', 'TX', '0000000698', 'paytonymonds@gmail.com', '00008');
insert into customer values('000000038', 'Mr', 'iago', 'willcock', '0000000000077930', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Dover', 'CA', '0000000424', 'iagowillcock@gmail.com', '00008');
insert into customer values('000000039', 'Mr', 'gael', 'piggott', '0000000000070206', to_date('10/10/2020', 'mm/dd/yyyy'), 'atwood', 'Miami', 'VM', '0000000070', 'gaelpiggott@gmail.com', '00003');
insert into customer values('000000040', 'Mr', 'werner', 'northing', '0000000000069153', to_date('10/10/2020', 'mm/dd/yyyy'), 'park', 'Miami', 'VI', '0000000198', 'wernernorthing@gmail.com', '00009');
insert into customer values('000000041', 'Mr', 'xymenes', 'bowles', '0000000000076867', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Moscow', 'TX', '0000000172', 'xymenesbowles@gmail.com', '00003');
insert into customer values('000000042', 'Mr', 'archaimbaud', 'waterhouse', '0000000000045522', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Dallas', 'KA', '0000000249', 'awaterhouse@gmail.com', '00002');
insert into customer values('000000043', 'Mr', 'sigmund', 'tweedale', '0000000000047338', to_date('10/10/2020', 'mm/dd/yyyy'), 'fourth', 'Ontario', 'TX', '0000000985', 'sigmundtweedale@gmail.com', '00003');
insert into customer values('000000044', 'Mr', 'diego', 'tayl', '0000000000040334', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'New York', 'ND', '0000000572', 'diegotayl@gmail.com', '00002');
insert into customer values('000000045', 'Mr', 'griz', 'collins', '0000000000088429', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Philadelphia', 'OG', '0000000455', 'grizcollins@gmail.com', '00001');
insert into customer values('000000046', 'Mr', 'franklyn', 'mcara', '0000000000060123', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Dallas', 'De', '0000000156', 'franklynmcara@gmail.com', '00010');
insert into customer values('000000047', 'Mr', 'terencio', 'owens', '0000000000056776', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'New York', 'De', '0000000988', 'terencioowens@gmail.com', '00002');
insert into customer values('000000048', 'Mr', 'marcus', 'race', '0000000000026405', to_date('10/10/2020', 'mm/dd/yyyy'), 'main', 'Orlando', 'SC', '0000000872', 'marcusrace@gmail.com', '00008');
insert into customer values('000000049', 'Mr', 'mendel', 'sevil', '0000000000089451', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'Miami', 'TX', '0000000057', 'mendelsevil@gmail.com', '00003');
insert into customer values('000000050', 'Mr', 'fran', 'hyslop?', '0000000000016178', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Dallas', 'De', '0000000258', 'franhyslop?@gmail.com', '00007');
insert into customer values('000000051', 'Mr', 'vidovic', 'woodruff', '0000000000065856', to_date('10/10/2020', 'mm/dd/yyyy'), 'sennot', 'Houston', 'OH', '0000000667', 'vidovicwoodruff@gmail.com', '00007');
insert into customer values('000000052', 'Mr', 'saul', 'shenston', '0000000000048829', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Orlando', 'KA', '0000000068', 'saulshenston@gmail.com', '00002');
insert into customer values('000000053', 'Mr', 'ellswerth', 'watts', '0000000000001074', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'Houston', 'FA', '0000000194', 'ellswerthwatts@gmail.com', '00010');
insert into customer values('000000054', 'Mr', 'meredith', 'weidenmeyer', '0000000000043635', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Dubai', 'ND', '0000000586', 'meredithweidenmeyer@gmail.com', '00002');
insert into customer values('000000055', 'Mr', 'wilfrid', 'batson', '0000000000027541', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'Denver', 'VM', '0000000991', 'wilfridbatson@gmail.com', '00008');
insert into customer values('000000056', 'Mr', 'svend', 'bignell', '0000000000093399', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'Denver', 'CA', '0000000585', 'svendbignell@gmail.com', '00008');
insert into customer values('000000057', 'Mr', 'kimble', 'harrison', '0000000000015133', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Dubai', 'TX', '0000000773', 'kimbleharrison@gmail.com', '00006');
insert into customer values('000000058', 'Mr', 'nick', 'poppleton', '0000000000021721', to_date('10/10/2020', 'mm/dd/yyyy'), 'atwood', 'New York', 'NJ', '0000000019', 'nickpoppleton@gmail.com', '00010');
insert into customer values('000000059', 'Mr', 'travus', 'holberton', '0000000000090867', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Boston', 'ID', '0000000543', 'travusholberton@gmail.com', '00005');
insert into customer values('000000060', 'Mr', 'troy', 'godolpin', '0000000000062638', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Baltimore', 'ND', '0000000093', 'troygodolpin@gmail.com', '00004');
insert into customer values('000000061', 'Mr', 'nickey', 'haoos', '0000000000019143', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Denver', 'FA', '0000000008', 'nickeyhaoos@gmail.com', '00009');
insert into customer values('000000062', 'Mr', 'randy', 'macalister', '0000000000009734', to_date('10/10/2020', 'mm/dd/yyyy'), 'second', 'Orlando', 'SC', '0000000531', 'randymacalister@gmail.com', '00008');
insert into customer values('000000063', 'Mr', 'javier', 'clissold', '0000000000027472', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Miami', 'NY', '0000000591', 'javierclissold@gmail.com', '00005');
insert into customer values('000000064', 'Mr', 'cobby', 'pollitt', '0000000000083489', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Houston', 'CA', '0000000486', 'cobbypollitt@gmail.com', '00007');
insert into customer values('000000065', 'Mr', 'claus', 'holliday', '0000000000090017', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Baltimore', 'NJ', '0000000788', 'clausholliday@gmail.com', '00008');
insert into customer values('000000066', 'Mr', 'turner', 'may', '0000000000054260', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'London', 'TX', '0000000018', 'turnermay@gmail.com', '00008');
insert into customer values('000000067', 'Mr', 'desmund', 'underwood', '0000000000029571', to_date('10/10/2020', 'mm/dd/yyyy'), 'view', 'Moscow', 'ID', '0000000292', 'desmundunderwood@gmail.com', '00005');
insert into customer values('000000068', 'Mr', 'mylo', 'vanvolkenburg', '0000000000058112', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Ontario', 'PA', '0000000075', 'mylovanvolkenburg@gmail.com', '00007');
insert into customer values('000000069', 'Mr', 'elton', 'huggan', '0000000000033759', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Dubai', 'VM', '0000000311', 'eltonhuggan@gmail.com', '00010');
insert into customer values('000000070', 'Mr', 'currey', 'tibbets', '0000000000093571', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Baltimore', 'VM', '0000000179', 'curreytibbets@gmail.com', '00007');
insert into customer values('000000071', 'Mr', 'morgen', 'moorhouse', '0000000000014839', to_date('10/10/2020', 'mm/dd/yyyy'), 'second', 'Dubai', 'ND', '0000000524', 'morgenmoorhouse@gmail.com', '00007');
insert into customer values('000000072', 'Mr', 'frasier', 'burrowes', '0000000000043322', to_date('10/10/2020', 'mm/dd/yyyy'), 'lake', 'Cleveland', 'SC', '0000000153', 'frasierburrowes@gmail.com', '00003');
insert into customer values('000000073', 'Mr', 'aymer', 'woodhead', '0000000000005242', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Dallas', 'FA', '0000000755', 'aymerwoodhead@gmail.com', '00005');
insert into customer values('000000074', 'Mr', 'torrey', 'mcallister', '0000000000081864', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'New York', 'SC', '0000000500', 'torreymcallister@gmail.com', '00007');
insert into customer values('000000075', 'Mr', 'reider', 'barton', '0000000000052134', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Miami', 'VI', '0000000463', 'reiderbarton@gmail.com', '00009');
insert into customer values('000000076', 'Mr', 'ham', 'burch', '0000000000080401', to_date('10/10/2020', 'mm/dd/yyyy'), 'lake', 'Boston', 'NJ', '0000000067', 'hamburch@gmail.com', '00010');
insert into customer values('000000077', 'Mr', 'ruttger', 'reynardson', '0000000000022926', to_date('10/10/2020', 'mm/dd/yyyy'), 'oak', 'Dallas', 'FA', '0000000172', 'ruttgerreynardson@gmail.com', '00005');
insert into customer values('000000078', 'Mr', 'gery', 'clontz', '0000000000031224', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Pittsburgh', 'HA', '0000000214', 'geryclontz@gmail.com', '00007');
insert into customer values('000000079', 'Mr', 'ashbey', 'prout', '0000000000041456', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'Dover', 'GA', '0000000803', 'ashbeyprout@gmail.com', '00004');
insert into customer values('000000080', 'Mr', 'carter', 'stroud', '0000000000090192', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Dallas', 'NA', '0000000822', 'carterstroud@gmail.com', '00010');
insert into customer values('000000081', 'Mr', 'finley', 'wingate', '0000000000014352', to_date('10/10/2020', 'mm/dd/yyyy'), 'lake', 'Philadelphia', 'VI', '0000000761', 'finleywingate@gmail.com', '00009');
insert into customer values('000000082', 'Mr', 'terrence', 'covell', '0000000000025780', to_date('10/10/2020', 'mm/dd/yyyy'), 'lake', 'Denver', 'NA', '0000000933', 'terrencecovell@gmail.com', '00009');
insert into customer values('000000083', 'Mr', 'john', 'stelzriede', '0000000000090554', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Dover', 'NC', '0000000864', 'johnstelzriede@gmail.com', '00002');
insert into customer values('000000084', 'Mr', 'windham', 'schaefer', '0000000000034844', to_date('10/10/2020', 'mm/dd/yyyy'), 'lake', 'Orlando', 'NC', '0000000165', 'windhamschaefer@gmail.com', '00006');
insert into customer values('000000085', 'Mr', 'stefano', 'casson', '0000000000037270', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'Dover', 'VM', '0000000626', 'stefanocasson@gmail.com', '00004');
insert into customer values('000000086', 'Mr', 'finn', 'seymour', '0000000000013178', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Boston', 'KA', '0000000727', 'finnseymour@gmail.com', '00002');
insert into customer values('000000087', 'Mr', 'karim', 'spears', '0000000000066859', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Dover', 'NY', '0000000754', 'karimspears@gmail.com', '00008');
insert into customer values('000000088', 'Mr', 'dionysus', 'culverhouse', '0000000000077958', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Philadelphia', 'ND', '0000000710', 'dionysusculverhouse@gmail.com', '00001');
insert into customer values('000000089', 'Mr', 'horatio', 'crosby', '0000000000045263', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Baltimore', 'VM', '0000000702', 'horatiocrosby@gmail.com', '00008');
insert into customer values('000000090', 'Mr', 'darryl', 'maher', '0000000000057937', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'London', 'VI', '0000000986', 'darrylmaher@gmail.com', '00004');
insert into customer values('000000091', 'Mr', 'alessandro', 'newark', '0000000000096011', to_date('10/10/2020', 'mm/dd/yyyy'), 'view', 'New York', 'NJ', '0000000860', 'alessandronewark@gmail.com', '00003');
insert into customer values('000000092', 'Mr', 'weylin', 'manser', '0000000000048393', to_date('10/10/2020', 'mm/dd/yyyy'), 'lake', 'London', 'OG', '0000000371', 'weylinmanser@gmail.com', '00009');
insert into customer values('000000093', 'Mr', 'haskell', 'whitehead', '0000000000036199', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Pittsburgh', 'TX', '0000000194', 'haskellwhitehead@gmail.com', '00005');
insert into customer values('000000094', 'Mr', 'robbie', 'culligan', '0000000000095338', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Philadelphia', 'KA', '0000000517', 'robbieculligan@gmail.com', '00005');
insert into customer values('000000095', 'Mr', 'carver', 'rapier', '0000000000033516', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Cleveland', 'VM', '0000000893', 'carverrapier@gmail.com', '00008');
insert into customer values('000000096', 'Mr', 'garrett', 'oversby', '0000000000015766', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Houston', 'ID', '0000000251', 'garrettoversby@gmail.com', '00003');
insert into customer values('000000097', 'Mr', 'anatollo', 'newton', '0000000000059238', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'New York', 'VM', '0000000078', 'anatollonewton@gmail.com', '00006');
insert into customer values('000000098', 'Mr', 'scotty', 'foxcroft', '0000000000026286', to_date('10/10/2020', 'mm/dd/yyyy'), 'main', 'Dallas', 'TX', '0000000292', 'scottyfoxcroft@gmail.com', '00004');
insert into customer values('000000099', 'Mr', 'myrwyn', 'mckichan', '0000000000044795', to_date('10/10/2020', 'mm/dd/yyyy'), 'park', 'Moscow', 'NJ', '0000000262', 'myrwynmckichan@gmail.com', '00002');
insert into customer values('000000100', 'Mr', 'georgi', 'mcbride', '0000000000020625', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'Dubai', 'ID', '0000000659', 'georgimcbride@gmail.com', '00001');
insert into customer values('000000101', 'Mr', 'page', 'saville', '0000000000094811', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Dallas', 'HA', '0000000398', 'pagesaville@gmail.com', '00006');
insert into customer values('000000102', 'Mr', 'port', 'kinney', '0000000000094300', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'New York', 'ID', '0000000138', 'portkinney@gmail.com', '00009');
insert into customer values('000000103', 'Mr', 'simon', 'dautrich', '0000000000024800', to_date('10/10/2020', 'mm/dd/yyyy'), 'second', 'Baltimore', 'VM', '0000000988', 'simondautrich@gmail.com', '00002');
insert into customer values('000000104', 'Mr', 'karney', 'uzal', '0000000000058487', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Ontario', 'NC', '0000000409', 'karneyuzal@gmail.com', '00004');
insert into customer values('000000105', 'Mr', 'lawrence', 'parham', '0000000000080914', to_date('10/10/2020', 'mm/dd/yyyy'), 'park', 'London', 'SC', '0000000099', 'lawrenceparham@gmail.com', '00001');
insert into customer values('000000106', 'Mr', 'smitty', 'sunderland', '0000000000087585', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Orlando', 'VI', '0000000041', 'smittysunderland@gmail.com', '00009');
insert into customer values('000000107', 'Mr', 'stephen', 'blacket', '0000000000098002', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'Pittsburgh', 'VM', '0000000493', 'stephenblacket@gmail.com', '00004');
insert into customer values('000000108', 'Mr', 'sammie', 'odell', '0000000000031995', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'Moscow', 'CA', '0000000360', 'sammieodell@gmail.com', '00002');
insert into customer values('000000109', 'Mr', 'kimbell', 'sitwell', '0000000000029871', to_date('10/10/2020', 'mm/dd/yyyy'), 'second', 'Ontario', 'NY', '0000000617', 'kimbellsitwell@gmail.com', '00002');
insert into customer values('000000110', 'Mr', 'gardener', 'gosling', '0000000000031372', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'New York', 'NC', '0000000676', 'gardenergosling@gmail.com', '00002');
insert into customer values('000000111', 'Mr', 'burty', 'grave', '0000000000052363', to_date('10/10/2020', 'mm/dd/yyyy'), 'view', 'Dallas', 'SC', '0000000265', 'burtygrave@gmail.com', '00002');
insert into customer values('000000112', 'Mr', 'herman', 'meek', '0000000000099266', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Baltimore', 'De', '0000000551', 'hermanmeek@gmail.com', '00008');
insert into customer values('000000113', 'Mr', 'holmes', 'mcmurray', '0000000000041024', to_date('10/10/2020', 'mm/dd/yyyy'), 'main', 'Denver', 'NA', '0000000937', 'holmesmcmurray@gmail.com', '00001');
insert into customer values('000000114', 'Mr', 'onfroi', 'grainger', '0000000000016328', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Houston', 'SC', '0000000925', 'onfroigrainger@gmail.com', '00002');
insert into customer values('000000115', 'Mr', 'grantley', 'wills', '0000000000003932', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Philadelphia', 'HA', '0000000014', 'grantleywills@gmail.com', '00005');
insert into customer values('000000116', 'Mr', 'aldridge', 'shaw', '0000000000055172', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Dubai', 'GA', '0000000281', 'aldridgeshaw@gmail.com', '00001');
insert into customer values('000000117', 'Mr', 'brewer', 'dimma', '0000000000040573', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Pittsburgh', 'GA', '0000000011', 'brewerdimma@gmail.com', '00008');
insert into customer values('000000118', 'Mr', 'troy', 'casteltown', '0000000000067325', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Dover', 'CA', '0000000965', 'troycasteltown@gmail.com', '00003');
insert into customer values('000000119', 'Mr', 'hartwell', 'askew', '0000000000010694', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Ontario', 'CA', '0000000096', 'hartwellaskew@gmail.com', '00001');
insert into customer values('000000120', 'Mr', 'homerus', 'carelton', '0000000000087757', to_date('10/10/2020', 'mm/dd/yyyy'), 'Forbes', 'Dover', 'NY', '0000000227', 'homeruscarelton@gmail.com', '00002');
insert into customer values('000000121', 'Mr', 'antonino', 'swaffield', '0000000000060903', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'Denver', 'ND', '0000000298', 'antoninoswaffield@gmail.com', '00010');
insert into customer values('000000122', 'Mr', 'adolph', 'tessequeau', '0000000000043077', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Dubai', 'De', '0000000496', 'adolphtessequeau@gmail.com', '00010');
insert into customer values('000000123', 'Mr', 'clerkclaude', 'morris', '0000000000095800', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Philadelphia', 'HA', '0000000426', 'clerkclaudemorris@gmail.com', '00001');
insert into customer values('000000124', 'Mr', 'denis', 'broomhead', '0000000000044593', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Dubai', 'NC', '0000000550', 'denisbroomhead@gmail.com', '00004');
insert into customer values('000000125', 'Mr', 'tallie', 'berriman', '0000000000062097', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Philadelphia', 'FA', '0000000571', 'tallieberriman@gmail.com', '00005');
insert into customer values('000000126', 'Mr', 'sander', 'flower', '0000000000060080', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'London', 'CA', '0000000226', 'sanderflower@gmail.com', '00006');
insert into customer values('000000127', 'Mr', 'ilaire', 'mckerral', '0000000000045216', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Dubai', 'VM', '0000000817', 'ilairemckerral@gmail.com', '00007');
insert into customer values('000000128', 'Mr', 'raul', 'carnaghan', '0000000000027706', to_date('10/10/2020', 'mm/dd/yyyy'), 'second', 'Dover', 'ND', '0000000193', 'raulcarnaghan@gmail.com', '00001');
insert into customer values('000000129', 'Mr', 'constantine', 'Sarkari', '0000000000028822', to_date('10/10/2020', 'mm/dd/yyyy'), 'fourth', 'Denver', 'TX', '0000000602', 'constantineSarkari@gmail.com', '00009');
insert into customer values('000000130', 'Mr', 'cob', 'nellen', '0000000000051608', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Dover', 'NA', '0000000876', 'cobnellen@gmail.com', '00003');
insert into customer values('000000131', 'Mr', 'jefferey', 'grand', '0000000000036396', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Dubai', 'ID', '0000000096', 'jeffereygrand@gmail.com', '00009');
insert into customer values('000000132', 'Mr', 'art', 'jeffrey', '0000000000057501', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Pittsburgh', 'OH', '0000000563', 'artjeffrey@gmail.com', '00008');
insert into customer values('000000133', 'Mr', 'phillipe', 'harwood', '0000000000024722', to_date('10/10/2020', 'mm/dd/yyyy'), 'view', 'Denver', 'SC', '0000000653', 'phillipeharwood@gmail.com', '00002');
insert into customer values('000000134', 'Mr', 'barnie', 'griswold', '0000000000092618', to_date('10/10/2020', 'mm/dd/yyyy'), 'fourth', 'Miami', 'OH', '0000000901', 'barniegriswold@gmail.com', '00005');
insert into customer values('000000135', 'Mr', 'trumann', 'clarkson', '0000000000038518', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'Cleveland', 'FA', '0000000970', 'trumannclarkson@gmail.com', '00005');
insert into customer values('000000136', 'Mr', 'manny', 'easdown', '0000000000059849', to_date('10/10/2020', 'mm/dd/yyyy'), 'view', 'Ontario', 'CA', '0000000509', 'mannyeasdown@gmail.com', '00007');
insert into customer values('000000137', 'Mr', 'thorstein', 'housby', '0000000000049831', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Dubai', 'PA', '0000000429', 'thorsteinhousby@gmail.com', '00002');
insert into customer values('000000138', 'Mr', 'iorgos', 'spradlin', '0000000000074765', to_date('10/10/2020', 'mm/dd/yyyy'), 'fourth', 'Ontario', 'TX', '0000000778', 'iorgosspradlin@gmail.com', '00007');
insert into customer values('000000139', 'Mr', 'wolf', 'brailsford', '0000000000016588', to_date('10/10/2020', 'mm/dd/yyyy'), 'oak', 'Dover', 'OG', '0000000244', 'wolfbrailsford@gmail.com', '00001');
insert into customer values('000000140', 'Mr', 'arel', 'sinclair', '0000000000087873', to_date('10/10/2020', 'mm/dd/yyyy'), 'oak', 'Baltimore', 'ID', '0000000950', 'arelsinclair@gmail.com', '00010');
insert into customer values('000000141', 'Mr', 'arney', 'culligan', '0000000000004693', to_date('10/10/2020', 'mm/dd/yyyy'), 'fourth', 'Moscow', 'VM', '0000000965', 'arneyculligan@gmail.com', '00001');
insert into customer values('000000142', 'Mr', 'harlin', 'plawes', '0000000000031124', to_date('10/10/2020', 'mm/dd/yyyy'), 'fourth', 'Pittsburgh', 'FA', '0000000263', 'harlinplawes@gmail.com', '00007');
insert into customer values('000000143', 'Mr', 'jon', 'hinds', '0000000000030088', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Baltimore', 'GA', '0000000736', 'jonhinds@gmail.com', '00008');
insert into customer values('000000144', 'Mr', 'reginald', 'mccarty', '0000000000001174', to_date('10/10/2020', 'mm/dd/yyyy'), 'market', 'Pittsburgh', 'NA', '0000000787', 'reginaldmccarty@gmail.com', '00005');
insert into customer values('000000145', 'Mr', 'sherwood', 'paulett', '0000000000037006', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'New York', 'NA', '0000000456', 'sherwoodpaulett@gmail.com', '00009');
insert into customer values('000000146', 'Mr', 'kennith', 'denton', '0000000000031906', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'Dubai', 'ND', '0000000788', 'kennithdenton@gmail.com', '00010');
insert into customer values('000000147', 'Mr', 'thorpe', 'spiceland', '0000000000057503', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Denver', 'TX', '0000000443', 'thorpespiceland@gmail.com', '00009');
insert into customer values('000000148', 'Mr', 'renault', 'stapleton-cotton', '0000000000094909', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Philadelphia', 'NC', '0000000085', 'rstapleton-cotton@gmail.com', '00006');
insert into customer values('000000149', 'Mr', 'wyatan', 'duffett', '0000000000082044', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'New York', 'OG', '0000000163', 'wyatanduffett@gmail.com', '00005');
insert into customer values('000000150', 'Ms', 'Paula', 'woodall', '0000000000049787', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Cleveland', 'NY', '0000000080', 'Paulawoodall@gmail.com', '00002');
insert into customer values('000000151', 'Ms', 'Dawn', 'plowman', '0000000000082551', to_date('10/10/2020', 'mm/dd/yyyy'), 'main', 'New York', 'TX', '0000000812', 'Dawnplowman@gmail.com', '00008');
insert into customer values('000000152', 'Ms', 'Irene', 'cattanach', '0000000000023046', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Ontario', 'HA', '0000000726', 'Irenecattanach@gmail.com', '00001');
insert into customer values('000000153', 'Ms', 'Lydia', 'milliken', '0000000000018042', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'London', 'ND', '0000000488', 'Lydiamilliken@gmail.com', '00003');
insert into customer values('000000154', 'Ms', 'Agnes', 'sohrweide', '0000000000039696', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Philadelphia', 'CA', '0000000768', 'Agnessohrweide@gmail.com', '00009');
insert into customer values('000000155', 'Ms', 'Josephine', 'crowton', '0000000000019677', to_date('10/10/2020', 'mm/dd/yyyy'), 'atwood', 'Philadelphia', 'NC', '0000000711', 'Josephinecrowton@gmail.com', '00004');
insert into customer values('000000156', 'Ms', 'Alice', 'welding', '0000000000020644', to_date('10/10/2020', 'mm/dd/yyyy'), 'second', 'Miami', 'De', '0000000114', 'Alicewelding@gmail.com', '00010');
insert into customer values('000000157', 'Ms', 'Melanie', 'hogden', '0000000000053189', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Dubai', 'OG', '0000000944', 'Melaniehogden@gmail.com', '00004');
insert into customer values('000000158', 'Ms', 'Phyllis', 'goldstraw', '0000000000096640', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Pittsburgh', 'NA', '0000000936', 'Phyllisgoldstraw@gmail.com', '00010');
insert into customer values('000000159', 'Ms', 'Elizabeth', 'swettenham', '0000000000080604', to_date('10/10/2020', 'mm/dd/yyyy'), 'Forbes', 'Cleveland', 'VM', '0000000598', 'Elizabethswettenham@gmail.com', '00002');
insert into customer values('000000160', 'Ms', 'Melinda', 'bradish', '0000000000021903', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Denver', 'OG', '0000000766', 'Melindabradish@gmail.com', '00004');
insert into customer values('000000161', 'Ms', 'Linda', 'compton-hall', '0000000000048992', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Boston', 'ND', '0000000893', 'Lindacompton-hall@gmail.com', '00006');
insert into customer values('000000162', 'Ms', 'Irene', 'depaoli', '0000000000027226', to_date('10/10/2020', 'mm/dd/yyyy'), 'second', 'Dallas', 'HA', '0000000719', 'Irenedepaoli@gmail.com', '00006');
insert into customer values('000000163', 'Ms', 'Amy', 'marsden', '0000000000024666', to_date('10/10/2020', 'mm/dd/yyyy'), 'oak', 'Ontario', 'PA', '0000000719', 'Amymarsden@gmail.com', '00010');
insert into customer values('000000164', 'Ms', 'Cheryl', 'mccowan', '0000000000020613', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'London', 'FA', '0000000658', 'Cherylmccowan@gmail.com', '00009');
insert into customer values('000000165', 'Ms', 'Aileen', 'midgley', '0000000000020519', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'Ontario', 'ND', '0000000579', 'Aileenmidgley@gmail.com', '00010');
insert into customer values('000000166', 'Ms', 'Daphne', 'rawsthorne', '0000000000090872', to_date('10/10/2020', 'mm/dd/yyyy'), 'lake', 'Pittsburgh', 'OG', '0000000616', 'Daphnerawsthorne@gmail.com', '00007');
insert into customer values('000000167', 'Ms', 'Doreen', 'sutcliffe', '0000000000080346', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Dallas', 'VI', '0000000745', 'Doreensutcliffe@gmail.com', '00002');
insert into customer values('000000168', 'Ms', 'Adeline', 'bolin', '0000000000079298', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Miami', 'SC', '0000000203', 'Adelinebolin@gmail.com', '00009');
insert into customer values('000000169', 'Ms', 'Rowena', 'mccourty', '0000000000010419', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'London', 'SC', '0000000750', 'Rowenamccourty@gmail.com', '00008');
insert into customer values('000000170', 'Ms', 'Rachel', 'whittaker', '0000000000059579', to_date('10/10/2020', 'mm/dd/yyyy'), 'main', 'Dover', 'NA', '0000000479', 'Rachelwhittaker@gmail.com', '00007');
insert into customer values('000000171', 'Ms', 'Gladys', 'tremblay', '0000000000089644', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Dallas', 'De', '0000000841', 'Gladystremblay@gmail.com', '00006');
insert into customer values('000000172', 'Ms', 'Sue', 'shelbaur', '0000000000023119', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Pittsburgh', 'De', '0000000199', 'Sueshelbaur@gmail.com', '00004');
insert into customer values('000000173', 'Ms', 'Joan', 'overton', '0000000000004904', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Cleveland', 'NY', '0000000528', 'Joanoverton@gmail.com', '00004');
insert into customer values('000000174', 'Ms', 'Norma', 'garness', '0000000000098783', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'Dubai', 'OH', '0000000639', 'Normagarness@gmail.com', '00004');
insert into customer values('000000175', 'Ms', 'Emily', 'hardy', '0000000000025451', to_date('10/10/2020', 'mm/dd/yyyy'), 'atwood', 'Dubai', 'PA', '0000000400', 'Emilyhardy@gmail.com', '00009');
insert into customer values('000000176', 'Ms', 'Samantha', 'guy', '0000000000050250', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'Philadelphia', 'NJ', '0000000514', 'Samanthaguy@gmail.com', '00005');
insert into customer values('000000177', 'Ms', 'Mona', 'mc kinnon', '0000000000093036', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Dallas', 'NJ', '0000000101', 'Monamc kinnon@gmail.com', '00008');
insert into customer values('000000178', 'Ms', 'Grace', 'denholm', '0000000000055537', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Pittsburgh', 'VM', '0000000047', 'Gracedenholm@gmail.com', '00007');
insert into customer values('000000179', 'Ms', 'Linda', 'de luxembourg', '0000000000027090', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Denver', 'HA', '0000000408', 'Lindade luxembourg@gmail.com', '00002');
insert into customer values('000000180', 'Ms', 'Elaine', 'stevanson', '0000000000076301', to_date('10/10/2020', 'mm/dd/yyyy'), 'sennot', 'Miami', 'PA', '0000000440', 'Elainestevanson@gmail.com', '00007');
insert into customer values('000000181', 'Ms', 'Phoebe', 'dawtry', '0000000000099089', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Moscow', 'CA', '0000000979', 'Phoebedawtry@gmail.com', '00006');
insert into customer values('000000182', 'Ms', 'Anita', 'westbrook', '0000000000032373', to_date('10/10/2020', 'mm/dd/yyyy'), 'lake', 'Baltimore', 'VI', '0000000208', 'Anitawestbrook@gmail.com', '00008');
insert into customer values('000000183', 'Ms', 'Rosalind', 'algate', '0000000000070726', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Dover', 'SC', '0000000095', 'Rosalindalgate@gmail.com', '00002');
insert into customer values('000000184', 'Ms', 'Melody', 'strange', '0000000000085469', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'London', 'De', '0000000578', 'Melodystrange@gmail.com', '00006');
insert into customer values('000000185', 'Ms', 'Rita', 'scarr', '0000000000038313', to_date('10/10/2020', 'mm/dd/yyyy'), 'atwood', 'Cleveland', 'De', '0000000879', 'Ritascarr@gmail.com', '00002');
insert into customer values('000000186', 'Ms', 'Cora', 'cutler', '0000000000080256', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Baltimore', 'PA', '0000000074', 'Coracutler@gmail.com', '00005');
insert into customer values('000000187', 'Ms', 'Penny', 'short', '0000000000073509', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Orlando', 'KA', '0000000727', 'Pennyshort@gmail.com', '00004');
insert into customer values('000000188', 'Ms', 'Josephine', 'de cabaret', '0000000000011804', to_date('10/10/2020', 'mm/dd/yyyy'), 'atwood', 'Miami', 'NA', '0000000100', 'Josephinede cabaret@gmail.com', '00005');
insert into customer values('000000189', 'Ms', 'Rosa', 'mayman', '0000000000086535', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Miami', 'ID', '0000000787', 'Rosamayman@gmail.com', '00008');
insert into customer values('000000190', 'Ms', 'Monica', 'packard', '0000000000059411', to_date('10/10/2020', 'mm/dd/yyyy'), 'fourth', 'Baltimore', 'De', '0000000026', 'Monicapackard@gmail.com', '00004');
insert into customer values('000000191', 'Ms', 'Fiona', 'franklin', '0000000000017916', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Moscow', 'HA', '0000000734', 'Fionafranklin@gmail.com', '00003');
insert into customer values('000000192', 'Ms', 'Priscilla', 'roskelley', '0000000000019354', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Baltimore', 'OG', '0000000088', 'Priscillaroskelley@gmail.com', '00001');
insert into customer values('000000193', 'Ms', 'Marilyn', 'wafford', '0000000000053876', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Houston', 'ND', '0000000212', 'Marilynwafford@gmail.com', '00004');
insert into customer values('000000194', 'Ms', 'Bertha', 'truax', '0000000000009373', to_date('10/10/2020', 'mm/dd/yyyy'), 'market', 'Moscow', 'ND', '0000000725', 'Berthatruax@gmail.com', '00009');
insert into customer values('000000195', 'Ms', 'Gloria', 'goodricke', '0000000000000212', to_date('10/10/2020', 'mm/dd/yyyy'), 'oak', 'Moscow', 'OH', '0000000977', 'Gloriagoodricke@gmail.com', '00004');
insert into customer values('000000196', 'Ms', 'Rosemary', 'macneece', '0000000000005161', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Orlando', 'OH', '0000000366', 'Rosemarymacneece@gmail.com', '00010');
insert into customer values('000000197', 'Ms', 'Amanda', 'nellon', '0000000000075038', to_date('10/10/2020', 'mm/dd/yyyy'), 'fourth', 'Denver', 'GA', '0000000852', 'Amandanellon@gmail.com', '00009');
insert into customer values('000000198', 'Ms', 'Hazel', 'de chair', '0000000000093271', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'London', 'SC', '0000000825', 'Hazelde chair@gmail.com', '00005');
insert into customer values('000000199', 'Ms', 'Lydia', 'motley', '0000000000043770', to_date('10/10/2020', 'mm/dd/yyyy'), 'park', 'New York', 'KA', '0000000194', 'Lydiamotley@gmail.com', '00004');
insert into customer values('000000200', 'Ms', 'Greta', 'dilahoy', '0000000000026386', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Denver', 'SC', '0000000633', 'Gretadilahoy@gmail.com', '00009');
insert into customer values('000000201', 'Ms', 'Florence', 'cowin', '0000000000096263', to_date('10/10/2020', 'mm/dd/yyyy'), 'oak', 'Baltimore', 'OH', '0000000490', 'Florencecowin@gmail.com', '00001');
insert into customer values('000000202', 'Ms', 'Mildred', 'lowis', '0000000000035360', to_date('10/10/2020', 'mm/dd/yyyy'), 'market', 'Moscow', 'NC', '0000000003', 'Mildredlowis@gmail.com', '00010');
insert into customer values('000000203', 'Ms', 'Belinda', 'bessel', '0000000000053238', to_date('10/10/2020', 'mm/dd/yyyy'), 'atwood', 'Miami', 'NY', '0000000788', 'Belindabessel@gmail.com', '00005');
insert into customer values('000000204', 'Ms', 'Mariam', 'thornborough', '0000000000095074', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Pittsburgh', 'OG', '0000000401', 'Mariamthornborough@gmail.com', '00001');
insert into customer values('000000205', 'Ms', 'Isabel', 'dinwiddy', '0000000000072605', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'Miami', 'NJ', '0000000275', 'Isabeldinwiddy@gmail.com', '00004');
insert into customer values('000000206', 'Ms', 'Lisa', 'hamblin', '0000000000038954', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Pittsburgh', 'NJ', '0000000394', 'Lisahamblin@gmail.com', '00007');
insert into customer values('000000207', 'Ms', 'Catherine', 'brannon', '0000000000066474', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Dubai', 'NY', '0000000699', 'Catherinebrannon@gmail.com', '00009');
insert into customer values('000000208', 'Ms', 'Mabel', 'ditchfield', '0000000000063156', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Houston', 'KA', '0000000220', 'Mabelditchfield@gmail.com', '00001');
insert into customer values('000000209', 'Ms', 'Lora', 'gay', '0000000000006769', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Philadelphia', 'NY', '0000000077', 'Loragay@gmail.com', '00006');
insert into customer values('000000210', 'Ms', 'Alicia', 'edlington', '0000000000063347', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Ontario', 'NA', '0000000239', 'Aliciaedlington@gmail.com', '00009');
insert into customer values('000000211', 'Ms', 'Jane', 'terry-lewis', '0000000000016673', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Cleveland', 'ID', '0000000490', 'Janeterry-lewis@gmail.com', '00001');
insert into customer values('000000212', 'Ms', 'Sheila', 'hugget', '0000000000017377', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Miami', 'HA', '0000000042', 'Sheilahugget@gmail.com', '00003');
insert into customer values('000000213', 'Ms', 'Mariam', 'holegate', '0000000000055987', to_date('10/10/2020', 'mm/dd/yyyy'), 'main', 'New York', 'De', '0000000739', 'Mariamholegate@gmail.com', '00009');
insert into customer values('000000214', 'Ms', 'Laura', 'donaldson', '0000000000098044', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'London', 'SC', '0000000899', 'Lauradonaldson@gmail.com', '00006');
insert into customer values('000000215', 'Ms', 'Gertrude', 'edmunds', '0000000000080850', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Moscow', 'HA', '0000000379', 'Gertrudeedmunds@gmail.com', '00009');
insert into customer values('000000216', 'Ms', 'Sally', 'girdwood', '0000000000028052', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Miami', 'KA', '0000000559', 'Sallygirdwood@gmail.com', '00010');
insert into customer values('000000217', 'Ms', 'Greta', 'hardenbroeck', '0000000000090878', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Ontario', 'PA', '0000000063', 'Gretahardenbroeck@gmail.com', '00003');
insert into customer values('000000218', 'Ms', 'Catherine', 'baird nee', '0000000000033658', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Philadelphia', 'NJ', '0000000828', 'Catherinebaird nee@gmail.com', '00007');
insert into customer values('000000219', 'Ms', 'Carmen', 'porteous', '0000000000034676', to_date('10/10/2020', 'mm/dd/yyyy'), 'market', 'Baltimore', 'De', '0000000648', 'Carmenporteous@gmail.com', '00009');
insert into customer values('000000220', 'Ms', 'Rachel', 'hanmer', '0000000000030159', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Pittsburgh', 'OH', '0000000853', 'Rachelhanmer@gmail.com', '00001');
insert into customer values('000000221', 'Ms', 'Adeline', 'murphey', '0000000000079315', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Philadelphia', 'VI', '0000000933', 'Adelinemurphey@gmail.com', '00004');
insert into customer values('000000222', 'Ms', 'Alba', 'lamb', '0000000000033839', to_date('10/10/2020', 'mm/dd/yyyy'), 'Forbes', 'Dover', 'NA', '0000000104', 'Albalamb@gmail.com', '00003');
insert into customer values('000000223', 'Ms', 'Jocelyn', 'faithful', '0000000000029519', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'New York', 'NY', '0000000724', 'Jocelynfaithful@gmail.com', '00005');
insert into customer values('000000224', 'Ms', 'Lucy', 'jeter', '0000000000028818', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Ontario', 'GA', '0000000232', 'Lucyjeter@gmail.com', '00005');
insert into customer values('000000225', 'Ms', 'Madeline', 'unicomb', '0000000000096579', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Baltimore', 'PA', '0000000460', 'Madelineunicomb@gmail.com', '00002');
insert into customer values('000000226', 'Ms', 'Carol', 'elvridge', '0000000000033174', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Miami', 'NJ', '0000000848', 'Carolelvridge@gmail.com', '00009');
insert into customer values('000000227', 'Ms', 'Maria', 'pack', '0000000000081285', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Baltimore', 'NC', '0000000998', 'Mariapack@gmail.com', '00006');
insert into customer values('000000228', 'Ms', 'Cinderalla', 'eeles', '0000000000014482', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Miami', 'OG', '0000000074', 'Cinderallaeeles@gmail.com', '00009');
insert into customer values('000000229', 'Ms', 'Monica', 'rose', '0000000000030913', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Ontario', 'PA', '0000000522', 'Monicarose@gmail.com', '00003');
insert into customer values('000000230', 'Ms', 'Mona', 'bethome', '0000000000001655', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Boston', 'PA', '0000000354', 'Monabethome@gmail.com', '00004');
insert into customer values('000000231', 'Ms', 'Christine', 'whitledge', '0000000000022065', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Baltimore', 'SC', '0000000528', 'Christinewhitledge@gmail.com', '00010');
insert into customer values('000000232', 'Ms', 'Bridget', 'lockey', '0000000000027525', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Miami', 'VI', '0000000831', 'Bridgetlockey@gmail.com', '00003');
insert into customer values('000000233', 'Ms', 'Harriet', 'clancy', '0000000000004918', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Dubai', 'GA', '0000000184', 'Harrietclancy@gmail.com', '00006');
insert into customer values('000000234', 'Ms', 'Janice', 'mattison', '0000000000028365', to_date('10/10/2020', 'mm/dd/yyyy'), 'view', 'Ontario', 'OG', '0000000255', 'Janicemattison@gmail.com', '00004');
insert into customer values('000000235', 'Ms', 'Amy', 'manini', '0000000000099170', to_date('10/10/2020', 'mm/dd/yyyy'), 'main', 'Dubai', 'TX', '0000000362', 'Amymanini@gmail.com', '00005');
insert into customer values('000000236', 'Ms', 'Dorothy', 'hennesey', '0000000000079838', to_date('10/10/2020', 'mm/dd/yyyy'), 'Forbes', 'Ontario', 'NA', '0000000742', 'Dorothyhennesey@gmail.com', '00005');
insert into customer values('000000237', 'Ms', 'Josephine', 'willey', '0000000000008015', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Baltimore', 'FA', '0000000618', 'Josephinewilley@gmail.com', '00007');
insert into customer values('000000238', 'Ms', 'Alice', 'nugent', '0000000000014927', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'New York', 'VI', '0000000071', 'Alicenugent@gmail.com', '00002');
insert into customer values('000000239', 'Ms', 'Constance', 'gaunt', '0000000000043150', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Philadelphia', 'PA', '0000000352', 'Constancegaunt@gmail.com', '00006');
insert into customer values('000000240', 'Ms', 'Hazel', 'fleming', '0000000000001119', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Philadelphia', 'KA', '0000000471', 'Hazelfleming@gmail.com', '00005');
insert into customer values('000000241', 'Ms', 'Anne', 'waughj', '0000000000070041', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Ontario', 'GA', '0000000743', 'Annewaughj@gmail.com', '00005');
insert into customer values('000000242', 'Ms', 'Mabel', 'mackley', '0000000000065986', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'Miami', 'KA', '0000000488', 'Mabelmackley@gmail.com', '00008');
insert into customer values('000000243', 'Ms', 'Fiona', 'sachsen', '0000000000056100', to_date('10/10/2020', 'mm/dd/yyyy'), 'Forbes', 'Orlando', 'TX', '0000000925', 'Fionasachsen@gmail.com', '00003');
insert into customer values('000000244', 'Ms', 'Susan', 'gotha', '0000000000061791', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'Pittsburgh', 'SC', '0000000197', 'Susangotha@gmail.com', '00002');
insert into customer values('000000245', 'Ms', 'Maggie', 'altenburg', '0000000000058831', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Denver', 'VM', '0000000840', 'Maggiealtenburg@gmail.com', '00002');
insert into customer values('000000246', 'Ms', 'Gladys', 'hammerton', '0000000000033581', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Philadelphia', 'SC', '0000000105', 'Gladyshammerton@gmail.com', '00001');
insert into customer values('000000247', 'Ms', 'Claire', 'sieminski', '0000000000070823', to_date('10/10/2020', 'mm/dd/yyyy'), 'fourth', 'Baltimore', 'NJ', '0000000202', 'Clairesieminski@gmail.com', '00008');
insert into customer values('000000248', 'Ms', 'Andrea', 'betty', '0000000000033850', to_date('10/10/2020', 'mm/dd/yyyy'), 'atwood', 'London', 'CA', '0000000352', 'Andreabetty@gmail.com', '00009');
insert into customer values('000000249', 'Ms', 'Gloria', 'rawson', '0000000000064136', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'New York', 'NY', '0000000989', 'Gloriarawson@gmail.com', '00004');
insert into customer values('000000250', 'Ms', 'Nora', 'cunnington', '0000000000048781', to_date('10/10/2020', 'mm/dd/yyyy'), 'Forbes', 'Baltimore', 'PA', '0000000537', 'Noracunnington@gmail.com', '00005');
insert into customer values('000000251', 'Ms', 'Phoebe', 'bradbury', '0000000000073208', to_date('10/10/2020', 'mm/dd/yyyy'), 'allen', 'Ontario', 'GA', '0000000407', 'Phoebebradbury@gmail.com', '00004');
insert into customer values('000000252', 'Ms', 'Audrey', 'israel', '0000000000008393', to_date('10/10/2020', 'mm/dd/yyyy'), 'frick', 'New York', 'HA', '0000000581', 'Audreyisrael@gmail.com', '00004');
insert into customer values('000000253', 'Ms', 'Lilian', 'meaby', '0000000000042695', to_date('10/10/2020', 'mm/dd/yyyy'), 'market', 'Miami', 'NY', '0000000327', 'Lilianmeaby@gmail.com', '00006');
insert into customer values('000000254', 'Ms', 'Eileen', 'rayner', '0000000000052645', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Orlando', 'NJ', '0000000544', 'Eileenrayner@gmail.com', '00004');
insert into customer values('000000255', 'Ms', 'Olga', 'wishart', '0000000000099169', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'Boston', 'OH', '0000000673', 'Olgawishart@gmail.com', '00004');
insert into customer values('000000256', 'Ms', 'Doris', 'underwood', '0000000000021205', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Cleveland', 'KA', '0000000368', 'Dorisunderwood@gmail.com', '00005');
insert into customer values('000000257', 'Ms', 'Janet', 'dawson', '0000000000044143', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'New York', 'OG', '0000000865', 'Janetdawson@gmail.com', '00005');
insert into customer values('000000258', 'Ms', 'Mildred', 'towers', '0000000000039769', to_date('10/10/2020', 'mm/dd/yyyy'), 'lake', 'Orlando', 'NA', '0000000818', 'Mildredtowers@gmail.com', '00003');
insert into customer values('000000259', 'Ms', 'Lilita', 'crawley', '0000000000046227', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Philadelphia', 'GA', '0000000219', 'Lilitacrawley@gmail.com', '00007');
insert into customer values('000000260', 'Ms', 'Monica', 'urry', '0000000000000299', to_date('10/10/2020', 'mm/dd/yyyy'), 'fine', 'Baltimore', 'PA', '0000000869', 'Monicaurry@gmail.com', '00006');
insert into customer values('000000261', 'Ms', 'Juliana', 'colston', '0000000000024058', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'Baltimore', 'FA', '0000000640', 'Julianacolston@gmail.com', '00004');
insert into customer values('000000262', 'Ms', 'Ethel', 'wilson', '0000000000045276', to_date('10/10/2020', 'mm/dd/yyyy'), 'Forbes', 'Pittsburgh', 'NC', '0000000096', 'Ethelwilson@gmail.com', '00007');
insert into customer values('000000263', 'Ms', 'Diana', 'witte', '0000000000085588', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Cleveland', 'ND', '0000000526', 'Dianawitte@gmail.com', '00004');
insert into customer values('000000264', 'Ms', 'Daisy', 'cassells', '0000000000088254', to_date('10/10/2020', 'mm/dd/yyyy'), 'market', 'Dubai', 'FA', '0000000187', 'Daisycassells@gmail.com', '00004');
insert into customer values('000000265', 'Ms', 'Ada', 'le barbier', '0000000000088604', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Pittsburgh', 'NY', '0000000439', 'Adale barbier@gmail.com', '00007');
insert into customer values('000000266', 'Ms', 'Alba', 'cautherey', '0000000000066368', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'New York', 'OH', '0000000681', 'Albacautherey@gmail.com', '00010');
insert into customer values('000000267', 'Ms', 'Geraldine', 'prout', '0000000000000458', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Dover', 'CA', '0000000419', 'Geraldineprout@gmail.com', '00003');
insert into customer values('000000268', 'Ms', 'Anne', 'bowes', '0000000000055885', to_date('10/10/2020', 'mm/dd/yyyy'), 'pine', 'Denver', 'NA', '0000000601', 'Annebowes@gmail.com', '00009');
insert into customer values('000000269', 'Ms', 'Nancy', 'cowes', '0000000000035185', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Cleveland', 'GA', '0000000776', 'Nancycowes@gmail.com', '00003');
insert into customer values('000000270', 'Ms', 'Ida', 'marsden', '0000000000093144', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Philadelphia', 'PA', '0000000007', 'Idamarsden@gmail.com', '00007');
insert into customer values('000000271', 'Ms', 'Bernice', 'philipson', '0000000000078109', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Ontario', 'ND', '0000000863', 'Bernicephilipson@gmail.com', '00005');
insert into customer values('000000272', 'Ms', 'Mary', 'roche', '0000000000066663', to_date('10/10/2020', 'mm/dd/yyyy'), 'school', 'New York', 'KA', '0000000083', 'Maryroche@gmail.com', '00003');
insert into customer values('000000273', 'Ms', 'Alethea', 'divine', '0000000000070622', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Moscow', 'FA', '0000000360', 'Aletheadivine@gmail.com', '00006');
insert into customer values('000000274', 'Ms', 'Cheryl', 'balderston', '0000000000029250', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Miami', 'OG', '0000000098', 'Cherylbalderston@gmail.com', '00001');
insert into customer values('000000275', 'Ms', 'Gloria', 'pighills', '0000000000058098', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Dubai', 'VM', '0000000594', 'Gloriapighills@gmail.com', '00003');
insert into customer values('000000276', 'Ms', 'Carmen', 'shipley', '0000000000070580', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'Philadelphia', 'GA', '0000000522', 'Carmenshipley@gmail.com', '00010');
insert into customer values('000000277', 'Ms', 'Eileen', 'shore', '0000000000028449', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Dover', 'SC', '0000000725', 'Eileenshore@gmail.com', '00002');
insert into customer values('000000278', 'Ms', 'Maggie', 'brittain', '0000000000063243', to_date('10/10/2020', 'mm/dd/yyyy'), 'washington', 'Dubai', 'OG', '0000000417', 'Maggiebrittain@gmail.com', '00003');
insert into customer values('000000279', 'Ms', 'Melody', 'mogg', '0000000000065142', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Orlando', 'VI', '0000000599', 'Melodymogg@gmail.com', '00003');
insert into customer values('000000280', 'Ms', 'Julia', 'taylot', '0000000000022513', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Dubai', 'NA', '0000000345', 'Juliataylot@gmail.com', '00009');
insert into customer values('000000281', 'Ms', 'Florence', 'stoker', '0000000000002616', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Miami', 'KA', '0000000583', 'Florencestoker@gmail.com', '00009');
insert into customer values('000000282', 'Ms', 'Norma', 'stilwell', '0000000000030294', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Orlando', 'TX', '0000000130', 'Normastilwell@gmail.com', '00007');
insert into customer values('000000283', 'Ms', 'Evelyn', 'willson', '0000000000002600', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'Philadelphia', 'FA', '0000000146', 'Evelynwillson@gmail.com', '00005');
insert into customer values('000000284', 'Ms', 'Emily', 'franzke', '0000000000066843', to_date('10/10/2020', 'mm/dd/yyyy'), 'first', 'Moscow', 'OH', '0000000565', 'Emilyfranzke@gmail.com', '00002');
insert into customer values('000000285', 'Ms', 'Polly', 'johnson', '0000000000042576', to_date('10/10/2020', 'mm/dd/yyyy'), 'third', 'Ontario', 'SC', '0000000306', 'Pollyjohnson@gmail.com', '00007');
insert into customer values('000000286', 'Ms', 'Rosemary', 'precious', '0000000000037840', to_date('10/10/2020', 'mm/dd/yyyy'), 'sennot', 'Denver', 'HA', '0000000545', 'Rosemaryprecious@gmail.com', '00007');
insert into customer values('000000287', 'Ms', 'Isabel', 'finney', '0000000000076928', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Dover', 'NC', '0000000702', 'Isabelfinney@gmail.com', '00004');
insert into customer values('000000288', 'Ms', 'Mariam', 'halliwell', '0000000000036097', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Miami', 'OG', '0000000887', 'Mariamhalliwell@gmail.com', '00004');
insert into customer values('000000289', 'Ms', 'Mavis', 'weston', '0000000000067059', to_date('10/10/2020', 'mm/dd/yyyy'), 'maple', 'London', 'KA', '0000000087', 'Mavisweston@gmail.com', '00010');
insert into customer values('000000290', 'Ms', 'Rebecca', 'culligan', '0000000000047115', to_date('10/10/2020', 'mm/dd/yyyy'), 'main', 'Baltimore', 'NC', '0000000931', 'Rebeccaculligan@gmail.com', '00008');
insert into customer values('000000291', 'Ms', 'Adeline', 'mcgill', '0000000000015128', to_date('10/10/2020', 'mm/dd/yyyy'), 'view', 'Philadelphia', 'FA', '0000000153', 'Adelinemcgill@gmail.com', '00006');
insert into customer values('000000292', 'Ms', 'Adriana', 'tate', '0000000000086481', to_date('10/10/2020', 'mm/dd/yyyy'), 'market', 'London', 'OH', '0000000874', 'Adrianatate@gmail.com', '00006');
insert into customer values('000000293', 'Ms', 'Rita', 'harkins', '0000000000006902', to_date('10/10/2020', 'mm/dd/yyyy'), 'market', 'Orlando', 'PA', '0000000731', 'Ritaharkins@gmail.com', '00005');
insert into customer values('000000294', 'Ms', 'Gladys', 'mascy', '0000000000095194', to_date('10/10/2020', 'mm/dd/yyyy'), 'stine', 'Houston', 'NJ', '0000000830', 'Gladysmascy@gmail.com', '00007');
insert into customer values('000000295', 'Ms', 'Peggy', 'struthers', '0000000000038815', to_date('10/10/2020', 'mm/dd/yyyy'), 'shore', 'Houston', 'HA', '0000000804', 'Peggystruthers@gmail.com', '00008');
insert into customer values('000000296', 'Ms', 'Rowena', 'lulham', '0000000000006644', to_date('10/10/2020', 'mm/dd/yyyy'), 'hill', 'Philadelphia', 'TX', '0000000491', 'Rowenalulham@gmail.com', '00010');
insert into customer values('000000297', 'Ms', 'Bonnie', 'braunsheidel', '0000000000024797', to_date('10/10/2020', 'mm/dd/yyyy'), 'elm', 'Orlando', 'NY', '0000000579', 'Bonniebraunsheidel@gmail.com', '00010');
insert into customer values('000000298', 'Ms', 'Linda', 'argue', '0000000000019525', to_date('10/10/2020', 'mm/dd/yyyy'), 'sennot', 'London', 'GA', '0000000435', 'Lindaargue@gmail.com', '00001');
insert into customer values('000000299', 'Ms', 'Christine', 'elrick', '0000000000078190', to_date('10/10/2020', 'mm/dd/yyyy'), 'carson', 'New York', 'NY', '0000000447', 'Christineelrick@gmail.com', '00005');
insert into customer values('000000300', 'Ms', 'Patricia', 'cotes', '0000000000078025', to_date('10/10/2020', 'mm/dd/yyyy'), 'park', 'Cleveland', 'CA', '0000000930', 'Patriciacotes@gmail.com', '00010');
insert into customer values('000000301', 'Ms', 'Alison', 'mccully', '0000000000045136', to_date('10/10/2020', 'mm/dd/yyyy'), 'sennot', 'Dubai', 'NY', '0000000627', 'Alisonmccully@gmail.com', '00010');
insert into customer values('000000302', 'Ms', 'Sheila', 'yarker', '0000000000010356', to_date('10/10/2020', 'mm/dd/yyyy'), 'park', 'Baltimore', 'NY', '0000000229', 'Sheilayarker@gmail.com', '00009');
insert into customer values('000000303', 'Ms', 'Gertrude', 'whally', '0000000000068802', to_date('10/10/2020', 'mm/dd/yyyy'), 'cedar', 'Cleveland', 'CA', '0000000122', 'Gertrudewhally@gmail.com', '00002');
insert into customer values('000000304', 'Ms', 'Angelina', 'staniland', '0000000000080289', to_date('10/10/2020', 'mm/dd/yyyy'), 'craig', 'Cleveland', 'FA', '0000000202', 'Angelinastaniland@gmail.com', '00007');



--
-- reservation values//reservation_detail_values
insert into reservation values('1', '000000000', '670', '0000000000019952', to_date('4/9/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('1', '001', to_date('11/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('2', '000000001', '233', '0000000000030735', to_date('3/16/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('2', '002', to_date('11/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('3', '000000002', '688', '0000000000057906', to_date('7/15/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('3', '003', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('4', '000000003', '881', '0000000000049874', to_date('6/15/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('4', '003', to_date('11/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('5', '000000004', '501', '0000000000080159', to_date('2/10/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('5', '003', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('6', '000000005', '360', '0000000000082268', to_date('10/13/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('6', '001', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('7', '000000006', '286', '0000000000028873', to_date('9/9/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('7', '001', to_date('11/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('8', '000000007', '806', '0000000000053161', to_date('2/7/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('8', '001', to_date('11/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('9', '000000008', '560', '0000000000082093', to_date('6/2/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('9', '001', to_date('11/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('10', '000000009', '479', '0000000000034681', to_date('2/19/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('10', '001', to_date('11/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('11', '000000010', '171', '0000000000021660', to_date('5/1/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('11', '001', to_date('11/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('12', '000000011', '491', '0000000000041158', to_date('6/9/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('12', '001', to_date('11/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('13', '000000012', '315', '0000000000045783', to_date('1/16/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('13', '001', to_date('11/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('14', '000000013', '977', '0000000000058733', to_date('9/15/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('14', '001', to_date('11/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('15', '000000014', '258', '0000000000058540', to_date('5/10/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('15', '001', to_date('11/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('16', '000000015', '740', '0000000000094618', to_date('1/4/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('16', '001', to_date('11/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('17', '000000016', '192', '0000000000017384', to_date('6/2/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('17', '001', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('18', '000000017', '271', '0000000000034029', to_date('10/9/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('18', '001', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('19', '000000018', '552', '0000000000094781', to_date('9/1/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('19', '001', to_date('11/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('20', '000000019', '913', '0000000000022912', to_date('1/1/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('20', '001', to_date('11/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('21', '000000020', '553', '0000000000001951', to_date('6/19/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('21', '001', to_date('11/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('22', '000000021', '692', '0000000000087569', to_date('6/13/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('22', '001', to_date('11/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('23', '000000022', '802', '0000000000032713', to_date('6/11/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('23', '001', to_date('11/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('24', '000000023', '673', '0000000000039255', to_date('6/1/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('24', '001', to_date('11/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('25', '000000024', '696', '0000000000011351', to_date('3/8/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('25', '001', to_date('11/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('26', '000000025', '719', '0000000000023533', to_date('1/2/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('26', '001', to_date('11/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('27', '000000026', '127', '0000000000071054', to_date('6/5/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('27', '001', to_date('11/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('28', '000000027', '553', '0000000000057871', to_date('7/15/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('28', '001', to_date('11/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('29', '000000028', '730', '0000000000050167', to_date('2/1/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('29', '001', to_date('11/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('30', '000000029', '662', '0000000000091823', to_date('3/12/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('30', '001', to_date('11/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('31', '000000030', '746', '0000000000014222', to_date('9/17/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('31', '001', to_date('11/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('32', '000000031', '368', '0000000000054871', to_date('1/18/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('32', '001', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('33', '000000032', '121', '0000000000082184', to_date('9/11/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('33', '001', to_date('11/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('34', '000000033', '159', '0000000000038683', to_date('10/16/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('34', '001', to_date('11/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('35', '000000034', '188', '0000000000014956', to_date('10/10/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('35', '001', to_date('11/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('36', '000000035', '697', '0000000000032014', to_date('10/19/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('36', '001', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('37', '000000036', '530', '0000000000051022', to_date('5/20/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('37', '001', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('38', '000000037', '496', '0000000000044332', to_date('9/9/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('38', '001', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('39', '000000038', '699', '0000000000077930', to_date('10/8/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('39', '001', to_date('11/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('40', '000000039', '433', '0000000000070206', to_date('5/9/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('40', '001', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('41', '000000040', '491', '0000000000069153', to_date('9/7/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('41', '001', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('42', '000000041', '269', '0000000000076867', to_date('3/4/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('42', '001', to_date('11/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('43', '000000042', '495', '0000000000045522', to_date('7/12/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('43', '001', to_date('11/10/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('44', '000000043', '889', '0000000000047338', to_date('1/2/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('44', '001', to_date('11/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('45', '000000044', '183', '0000000000040334', to_date('7/17/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('45', '001', to_date('11/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('46', '000000045', '641', '0000000000088429', to_date('3/10/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('46', '001', to_date('11/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('47', '000000046', '572', '0000000000060123', to_date('4/8/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('47', '001', to_date('11/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('48', '000000047', '393', '0000000000056776', to_date('4/5/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('48', '001', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('49', '000000048', '706', '0000000000026405', to_date('8/6/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('49', '001', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('50', '000000049', '658', '0000000000089451', to_date('3/16/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('50', '001', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('51', '000000050', '198', '0000000000016178', to_date('8/12/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('51', '011', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('52', '000000051', '592', '0000000000065856', to_date('4/16/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('52', '071', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('53', '000000052', '564', '0000000000048829', to_date('6/10/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('53', '083', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('54', '000000053', '205', '0000000000001074', to_date('7/11/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('54', '025', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('55', '000000054', '595', '0000000000043635', to_date('8/3/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('55', '097', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('56', '000000055', '871', '0000000000027541', to_date('3/15/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('56', '077', to_date('11/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('57', '000000056', '546', '0000000000093399', to_date('7/11/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('57', '045', to_date('11/10/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('58', '000000057', '549', '0000000000015133', to_date('9/11/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('58', '078', to_date('11/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('59', '000000058', '574', '0000000000021721', to_date('7/17/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('59', '028', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('60', '000000059', '427', '0000000000090867', to_date('7/19/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('60', '085', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('61', '000000060', '672', '0000000000062638', to_date('9/15/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('61', '073', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('62', '000000061', '128', '0000000000019143', to_date('5/13/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('62', '049', to_date('11/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('63', '000000062', '683', '0000000000009734', to_date('4/12/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('63', '092', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('64', '000000063', '769', '0000000000027472', to_date('3/20/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('64', '078', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('65', '000000064', '696', '0000000000083489', to_date('3/19/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('65', '093', to_date('11/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('66', '000000065', '637', '0000000000090017', to_date('8/18/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('66', '051', to_date('11/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('67', '000000066', '519', '0000000000054260', to_date('5/8/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('67', '004', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('68', '000000067', '162', '0000000000029571', to_date('10/20/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('68', '068', to_date('11/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('69', '000000068', '564', '0000000000058112', to_date('7/9/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('69', '043', to_date('11/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('70', '000000069', '185', '0000000000033759', to_date('7/5/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('70', '093', to_date('11/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('71', '000000070', '899', '0000000000093571', to_date('7/15/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('71', '075', to_date('11/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('72', '000000071', '837', '0000000000014839', to_date('2/15/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('72', '017', to_date('11/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('73', '000000072', '836', '0000000000043322', to_date('2/5/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('73', '028', to_date('11/10/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('74', '000000073', '542', '0000000000005242', to_date('1/8/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('74', '054', to_date('11/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('75', '000000074', '580', '0000000000081864', to_date('1/6/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('75', '082', to_date('11/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('76', '000000075', '916', '0000000000052134', to_date('4/16/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('76', '061', to_date('11/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('77', '000000076', '583', '0000000000080401', to_date('2/13/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('77', '065', to_date('11/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('78', '000000077', '745', '0000000000022926', to_date('10/10/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('78', '074', to_date('11/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('79', '000000078', '810', '0000000000031224', to_date('4/20/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('79', '100', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('80', '000000079', '262', '0000000000041456', to_date('9/14/2016', 'mm/dd/yyyy'), '0', 'JFK', 'DCA');
insert into reservation_detail values('80', '002', to_date('11/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('81', '000000080', '982', '0000000000090192', to_date('3/8/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('81', '100', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('82', '000000081', '743', '0000000000014352', to_date('8/20/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('82', '013', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('83', '000000082', '883', '0000000000025780', to_date('6/3/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('83', '060', to_date('11/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('84', '000000083', '239', '0000000000090554', to_date('2/5/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('84', '007', to_date('11/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('85', '000000084', '366', '0000000000034844', to_date('1/4/2016', 'mm/dd/yyyy'), '0', 'JFK', 'DCA');
insert into reservation_detail values('85', '002', to_date('11/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('86', '000000085', '333', '0000000000037270', to_date('5/15/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('86', '009', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('87', '000000086', '669', '0000000000013178', to_date('9/13/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('87', '020', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('88', '000000087', '497', '0000000000066859', to_date('6/9/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('88', '045', to_date('11/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('89', '000000088', '430', '0000000000077958', to_date('4/17/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('89', '019', to_date('11/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('90', '000000089', '104', '0000000000045263', to_date('7/13/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('90', '009', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('91', '000000090', '817', '0000000000057937', to_date('2/8/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('91', '041', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('92', '000000091', '211', '0000000000096011', to_date('7/9/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('92', '085', to_date('11/10/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('93', '000000092', '485', '0000000000048393', to_date('3/8/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('93', '089', to_date('11/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('94', '000000093', '746', '0000000000036199', to_date('3/13/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('94', '015', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('95', '000000094', '615', '0000000000095338', to_date('10/15/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('95', '074', to_date('11/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('96', '000000095', '682', '0000000000033516', to_date('10/19/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('96', '056', to_date('11/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('97', '000000096', '502', '0000000000015766', to_date('4/4/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('97', '075', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('98', '000000097', '262', '0000000000059238', to_date('6/8/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('98', '096', to_date('11/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('99', '000000098', '258', '0000000000026286', to_date('5/18/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('99', '035', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('100', '000000099', '548', '0000000000044795', to_date('1/8/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('100', '082', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('101', '000000100', '501', '0000000000020625', to_date('6/20/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('101', '082', to_date('11/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('102', '000000101', '910', '0000000000094811', to_date('1/18/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('102', '026', to_date('11/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('103', '000000102', '150', '0000000000094300', to_date('2/2/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('103', '042', to_date('11/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('104', '000000103', '197', '0000000000024800', to_date('1/15/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('104', '067', to_date('11/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('105', '000000104', '260', '0000000000058487', to_date('3/2/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('105', '072', to_date('11/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('106', '000000105', '785', '0000000000080914', to_date('5/12/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('106', '058', to_date('11/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('107', '000000106', '216', '0000000000087585', to_date('3/13/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('107', '094', to_date('11/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('108', '000000107', '139', '0000000000098002', to_date('1/16/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('108', '013', to_date('11/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('109', '000000108', '718', '0000000000031995', to_date('6/8/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('109', '057', to_date('11/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('110', '000000109', '201', '0000000000029871', to_date('7/12/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('110', '092', to_date('11/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('111', '000000110', '721', '0000000000031372', to_date('5/12/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('111', '012', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('112', '000000111', '472', '0000000000052363', to_date('1/20/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('112', '069', to_date('11/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('113', '000000112', '601', '0000000000099266', to_date('2/20/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('113', '041', to_date('11/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('114', '000000113', '231', '0000000000041024', to_date('10/5/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('114', '052', to_date('11/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('115', '000000114', '721', '0000000000016328', to_date('4/6/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('115', '086', to_date('11/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('116', '000000115', '903', '0000000000003932', to_date('3/15/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('116', '050', to_date('11/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('117', '000000116', '740', '0000000000055172', to_date('9/19/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('117', '053', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('118', '000000117', '745', '0000000000040573', to_date('9/13/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('118', '096', to_date('11/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('119', '000000118', '805', '0000000000067325', to_date('4/12/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('119', '055', to_date('11/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('120', '000000119', '143', '0000000000010694', to_date('3/8/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('120', '036', to_date('11/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('121', '000000120', '343', '0000000000087757', to_date('7/11/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('121', '023', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('122', '000000121', '811', '0000000000060903', to_date('9/4/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('122', '022', to_date('11/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('123', '000000122', '926', '0000000000043077', to_date('2/12/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('123', '067', to_date('11/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('124', '000000123', '682', '0000000000095800', to_date('6/16/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('124', '058', to_date('11/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('125', '000000124', '785', '0000000000044593', to_date('1/17/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('125', '072', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('126', '000000125', '108', '0000000000062097', to_date('2/7/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('126', '081', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('127', '000000126', '275', '0000000000060080', to_date('2/9/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('127', '084', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('128', '000000127', '798', '0000000000045216', to_date('1/2/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('128', '045', to_date('11/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('129', '000000128', '704', '0000000000027706', to_date('5/20/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('129', '063', to_date('11/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('130', '000000129', '902', '0000000000028822', to_date('2/11/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('130', '076', to_date('11/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('131', '000000130', '884', '0000000000051608', to_date('4/18/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('131', '086', to_date('11/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('132', '000000131', '751', '0000000000036396', to_date('7/11/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('132', '059', to_date('11/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('133', '000000132', '205', '0000000000057501', to_date('1/13/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('133', '047', to_date('11/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('134', '000000133', '661', '0000000000024722', to_date('8/7/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('134', '061', to_date('11/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('135', '000000134', '951', '0000000000092618', to_date('5/2/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('135', '010', to_date('11/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('136', '000000135', '502', '0000000000038518', to_date('2/16/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('136', '024', to_date('11/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('137', '000000136', '593', '0000000000059849', to_date('1/3/2016', 'mm/dd/yyyy'), '0', 'PIT', 'DCA');
insert into reservation_detail values('137', '003', to_date('11/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('138', '000000137', '374', '0000000000049831', to_date('3/7/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('138', '018', to_date('11/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('139', '000000138', '390', '0000000000074765', to_date('1/8/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('139', '082', to_date('11/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('140', '000000139', '504', '0000000000016588', to_date('8/13/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('140', '031', to_date('11/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('141', '000000140', '972', '0000000000087873', to_date('5/16/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('141', '068', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('142', '000000141', '742', '0000000000004693', to_date('9/11/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('142', '035', to_date('11/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('143', '000000142', '753', '0000000000031124', to_date('1/15/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('143', '019', to_date('11/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('144', '000000143', '187', '0000000000030088', to_date('10/5/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('144', '041', to_date('11/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('145', '000000144', '259', '0000000000001174', to_date('7/17/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('145', '060', to_date('11/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('146', '000000145', '920', '0000000000037006', to_date('7/20/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('146', '081', to_date('11/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('147', '000000146', '226', '0000000000031906', to_date('3/13/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('147', '076', to_date('11/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('148', '000000147', '373', '0000000000057503', to_date('4/2/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('148', '056', to_date('11/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('149', '000000148', '863', '0000000000094909', to_date('9/9/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('149', '014', to_date('11/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('150', '000000149', '552', '0000000000082044', to_date('4/3/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('150', '065', to_date('11/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('151', '000000150', '856', '0000000000049787', to_date('10/4/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('151', '006', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('152', '000000151', '976', '0000000000082551', to_date('5/3/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('152', '027', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('153', '000000152', '384', '0000000000023046', to_date('1/11/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('153', '096', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('154', '000000153', '234', '0000000000018042', to_date('5/7/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('154', '076', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('155', '000000154', '201', '0000000000039696', to_date('6/7/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('155', '028', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('156', '000000155', '368', '0000000000019677', to_date('5/8/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('156', '026', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('157', '000000156', '391', '0000000000020644', to_date('5/1/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('157', '074', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('158', '000000157', '994', '0000000000053189', to_date('3/14/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('158', '094', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('159', '000000158', '847', '0000000000096640', to_date('2/16/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('159', '060', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('160', '000000159', '584', '0000000000080604', to_date('1/3/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('160', '027', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('161', '000000160', '346', '0000000000021903', to_date('5/3/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('161', '013', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('162', '000000161', '935', '0000000000048992', to_date('7/7/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('162', '058', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('163', '000000162', '754', '0000000000027226', to_date('6/18/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('163', '040', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('164', '000000163', '852', '0000000000024666', to_date('5/7/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('164', '040', to_date('12/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('165', '000000164', '646', '0000000000020613', to_date('9/4/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('165', '040', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('166', '000000165', '296', '0000000000020519', to_date('3/16/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('166', '011', to_date('12/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('167', '000000166', '635', '0000000000090872', to_date('7/2/2016', 'mm/dd/yyyy'), '0', 'JFK', 'DCA');
insert into reservation_detail values('167', '002', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('168', '000000167', '627', '0000000000080346', to_date('3/13/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('168', '093', to_date('12/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('169', '000000168', '113', '0000000000079298', to_date('5/3/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('169', '032', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('170', '000000169', '360', '0000000000010419', to_date('9/18/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('170', '080', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('171', '000000170', '736', '0000000000059579', to_date('6/13/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('171', '092', to_date('12/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('172', '000000171', '314', '0000000000089644', to_date('9/12/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('172', '064', to_date('12/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('173', '000000172', '183', '0000000000023119', to_date('4/13/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('173', '074', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('174', '000000173', '314', '0000000000004904', to_date('4/4/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('174', '071', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('175', '000000174', '222', '0000000000098783', to_date('4/1/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('175', '014', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('176', '000000175', '842', '0000000000025451', to_date('10/18/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('176', '071', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('177', '000000176', '583', '0000000000050250', to_date('1/1/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('177', '052', to_date('12/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('178', '000000177', '753', '0000000000093036', to_date('4/19/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('178', '055', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('179', '000000178', '608', '0000000000055537', to_date('3/17/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('179', '053', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('180', '000000179', '934', '0000000000027090', to_date('5/19/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('180', '029', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('181', '000000180', '945', '0000000000076301', to_date('10/5/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('181', '073', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('182', '000000181', '253', '0000000000099089', to_date('5/1/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('182', '021', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('183', '000000182', '603', '0000000000032373', to_date('2/20/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('183', '074', to_date('12/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('184', '000000183', '764', '0000000000070726', to_date('9/18/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('184', '067', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('185', '000000184', '599', '0000000000085469', to_date('6/11/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('185', '032', to_date('12/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('186', '000000185', '723', '0000000000038313', to_date('7/2/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('186', '099', to_date('12/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('187', '000000186', '622', '0000000000080256', to_date('7/14/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('187', '045', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('188', '000000187', '988', '0000000000073509', to_date('7/19/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('188', '087', to_date('12/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('189', '000000188', '894', '0000000000011804', to_date('4/4/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('189', '023', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('190', '000000189', '225', '0000000000086535', to_date('7/14/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('190', '086', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('191', '000000190', '116', '0000000000059411', to_date('3/15/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('191', '021', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('192', '000000191', '347', '0000000000017916', to_date('9/20/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('192', '046', to_date('12/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('193', '000000192', '526', '0000000000019354', to_date('4/8/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('193', '017', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('194', '000000193', '392', '0000000000053876', to_date('2/17/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('194', '023', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('195', '000000194', '129', '0000000000009373', to_date('5/15/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('195', '042', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('196', '000000195', '401', '0000000000000212', to_date('5/8/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('196', '083', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('197', '000000196', '756', '0000000000005161', to_date('3/4/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('197', '009', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('198', '000000197', '338', '0000000000075038', to_date('3/9/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('198', '096', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('199', '000000198', '436', '0000000000093271', to_date('7/7/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('199', '018', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('200', '000000199', '635', '0000000000043770', to_date('4/8/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('200', '026', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('201', '000000200', '289', '0000000000026386', to_date('2/1/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('201', '097', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('202', '000000201', '783', '0000000000096263', to_date('3/9/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('202', '075', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('203', '000000202', '782', '0000000000035360', to_date('1/15/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('203', '048', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('204', '000000203', '349', '0000000000053238', to_date('6/2/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('204', '023', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('205', '000000204', '143', '0000000000095074', to_date('3/6/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('205', '019', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('206', '000000205', '383', '0000000000072605', to_date('3/7/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('206', '081', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('207', '000000206', '577', '0000000000038954', to_date('1/16/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('207', '089', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('208', '000000207', '387', '0000000000066474', to_date('8/13/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('208', '039', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('209', '000000208', '530', '0000000000063156', to_date('2/6/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('209', '056', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('210', '000000209', '848', '0000000000006769', to_date('4/10/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('210', '010', to_date('12/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('211', '000000210', '506', '0000000000063347', to_date('6/10/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('211', '073', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('212', '000000211', '814', '0000000000016673', to_date('2/18/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('212', '057', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('213', '000000212', '946', '0000000000017377', to_date('10/20/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('213', '040', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('214', '000000213', '312', '0000000000055987', to_date('7/17/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('214', '037', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('215', '000000214', '550', '0000000000098044', to_date('7/14/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('215', '096', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('216', '000000215', '502', '0000000000080850', to_date('5/6/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('216', '058', to_date('12/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('217', '000000216', '553', '0000000000028052', to_date('10/8/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('217', '046', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('218', '000000217', '213', '0000000000090878', to_date('5/9/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('218', '083', to_date('12/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('219', '000000218', '352', '0000000000033658', to_date('9/1/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('219', '084', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('220', '000000219', '685', '0000000000034676', to_date('2/12/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('220', '089', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('221', '000000220', '337', '0000000000030159', to_date('9/9/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('221', '047', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('222', '000000221', '492', '0000000000079315', to_date('9/5/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('222', '076', to_date('12/10/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('223', '000000222', '479', '0000000000033839', to_date('5/9/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('223', '082', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('224', '000000223', '855', '0000000000029519', to_date('3/20/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('224', '076', to_date('12/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('225', '000000224', '215', '0000000000028818', to_date('7/13/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('225', '048', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('226', '000000225', '546', '0000000000096579', to_date('8/1/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('226', '090', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('227', '000000226', '630', '0000000000033174', to_date('3/14/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('227', '074', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('228', '000000227', '658', '0000000000081285', to_date('4/9/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('228', '015', to_date('12/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('229', '000000228', '885', '0000000000014482', to_date('3/18/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('229', '014', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('230', '000000229', '254', '0000000000030913', to_date('9/18/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('230', '097', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('231', '000000230', '205', '0000000000001655', to_date('8/9/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('231', '035', to_date('12/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('232', '000000231', '255', '0000000000022065', to_date('10/1/2016', 'mm/dd/yyyy'), '0', 'SFA', 'PIT');
insert into reservation_detail values('232', '032', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('233', '000000232', '935', '0000000000027525', to_date('3/14/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('233', '017', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('234', '000000233', '779', '0000000000004918', to_date('9/20/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('234', '014', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('235', '000000234', '339', '0000000000028365', to_date('9/19/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('235', '016', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('236', '000000235', '114', '0000000000099170', to_date('5/2/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('236', '012', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('237', '000000236', '239', '0000000000079838', to_date('4/1/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('237', '085', to_date('12/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('238', '000000237', '449', '0000000000008015', to_date('7/11/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('238', '059', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('239', '000000238', '311', '0000000000014927', to_date('2/14/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('239', '079', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('240', '000000239', '345', '0000000000043150', to_date('5/19/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('240', '052', to_date('12/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('241', '000000240', '489', '0000000000001119', to_date('5/20/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('241', '089', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('242', '000000241', '388', '0000000000070041', to_date('8/8/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('242', '045', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('243', '000000242', '798', '0000000000065986', to_date('1/14/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('243', '083', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('244', '000000243', '491', '0000000000056100', to_date('4/11/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('244', '089', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('245', '000000244', '677', '0000000000061791', to_date('9/14/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('245', '067', to_date('12/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('246', '000000245', '903', '0000000000058831', to_date('8/8/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('246', '094', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('247', '000000246', '187', '0000000000033581', to_date('5/13/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('247', '041', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('248', '000000247', '362', '0000000000070823', to_date('6/8/2016', 'mm/dd/yyyy'), '0', 'LAX', 'DCA');
insert into reservation_detail values('248', '010', to_date('12/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('249', '000000248', '138', '0000000000033850', to_date('8/1/2016', 'mm/dd/yyyy'), '0', 'DCA', 'SFA');
insert into reservation_detail values('249', '062', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('250', '000000249', '307', '0000000000064136', to_date('4/19/2016', 'mm/dd/yyyy'), '0', 'SFA', 'DCA');
insert into reservation_detail values('250', '059', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('251', '000000250', '423', '0000000000048781', to_date('4/7/2016', 'mm/dd/yyyy'), '0', 'ATL', 'LAX');
insert into reservation_detail values('251', '098', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('252', '000000251', '316', '0000000000073208', to_date('1/15/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('252', '084', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('253', '000000001', '579', '0000000000030735', to_date('5/7/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('253', '018', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('254', '000000002', '206', '0000000000057906', to_date('7/5/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('254', '018', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('255', '000000003', '712', '0000000000049874', to_date('8/10/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('255', '064', to_date('12/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('256', '000000004', '402', '0000000000080159', to_date('7/4/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('256', '008', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('257', '000000005', '872', '0000000000082268', to_date('1/5/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('257', '059', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('258', '000000006', '875', '0000000000028873', to_date('4/13/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('258', '016', to_date('12/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('259', '000000007', '352', '0000000000053161', to_date('5/14/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('259', '044', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('260', '000000008', '661', '0000000000082093', to_date('5/15/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('260', '028', to_date('12/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('261', '000000009', '692', '0000000000034681', to_date('6/12/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('261', '027', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('262', '000000010', '686', '0000000000021660', to_date('6/5/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('262', '080', to_date('12/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('263', '000000011', '965', '0000000000041158', to_date('10/7/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('263', '048', to_date('12/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('264', '000000012', '325', '0000000000045783', to_date('6/1/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('264', '092', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('265', '000000013', '969', '0000000000058733', to_date('7/3/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('265', '047', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('266', '000000014', '159', '0000000000058540', to_date('9/19/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('266', '090', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('267', '000000015', '654', '0000000000094618', to_date('4/19/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('267', '012', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('268', '000000016', '181', '0000000000017384', to_date('8/7/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('268', '012', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('269', '000000017', '909', '0000000000034029', to_date('9/13/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('269', '009', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('270', '000000018', '517', '0000000000094781', to_date('10/17/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('270', '100', to_date('12/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('271', '000000019', '874', '0000000000022912', to_date('2/3/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('271', '027', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('272', '000000020', '379', '0000000000001951', to_date('2/16/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('272', '068', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('273', '000000021', '347', '0000000000087569', to_date('4/14/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('273', '041', to_date('12/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('274', '000000022', '523', '0000000000032713', to_date('6/13/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('274', '054', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('275', '000000023', '237', '0000000000039255', to_date('6/6/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('275', '056', to_date('12/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('276', '000000024', '207', '0000000000011351', to_date('9/7/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('276', '064', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('277', '000000025', '238', '0000000000023533', to_date('8/10/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('277', '076', to_date('12/20/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('278', '000000026', '486', '0000000000071054', to_date('8/17/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('278', '048', to_date('12/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('279', '000000027', '119', '0000000000057871', to_date('3/8/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('279', '053', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('280', '000000028', '598', '0000000000050167', to_date('4/9/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('280', '026', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('281', '000000029', '378', '0000000000091823', to_date('9/12/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('281', '096', to_date('12/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('282', '000000030', '297', '0000000000014222', to_date('2/6/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('282', '064', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('283', '000000031', '261', '0000000000054871', to_date('3/12/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('283', '006', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('284', '000000032', '982', '0000000000082184', to_date('7/13/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('284', '097', to_date('12/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('285', '000000033', '844', '0000000000038683', to_date('10/16/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('285', '093', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('286', '000000034', '359', '0000000000014956', to_date('5/6/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('286', '008', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('287', '000000035', '997', '0000000000032014', to_date('5/10/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('287', '051', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('288', '000000036', '174', '0000000000051022', to_date('6/14/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('288', '025', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('289', '000000037', '245', '0000000000044332', to_date('9/1/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('289', '037', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('290', '000000038', '473', '0000000000077930', to_date('3/9/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('290', '018', to_date('12/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('291', '000000039', '556', '0000000000070206', to_date('5/8/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('291', '095', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('292', '000000040', '995', '0000000000069153', to_date('4/16/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('292', '066', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('293', '000000041', '165', '0000000000076867', to_date('1/11/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('293', '027', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('294', '000000042', '144', '0000000000045522', to_date('10/17/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('294', '034', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('295', '000000043', '451', '0000000000047338', to_date('6/5/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('295', '056', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('296', '000000044', '835', '0000000000040334', to_date('6/3/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('296', '034', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('297', '000000045', '406', '0000000000088429', to_date('10/11/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('297', '048', to_date('12/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('298', '000000046', '807', '0000000000060123', to_date('10/1/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('298', '021', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('299', '000000047', '668', '0000000000056776', to_date('10/7/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('299', '099', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('300', '000000048', '879', '0000000000026405', to_date('6/16/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('300', '012', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('301', '000000049', '552', '0000000000089451', to_date('3/15/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('301', '085', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('302', '000000050', '227', '0000000000016178', to_date('2/13/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('302', '037', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('303', '000000051', '428', '0000000000065856', to_date('6/9/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('303', '042', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('304', '000000052', '300', '0000000000048829', to_date('7/20/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('304', '039', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('305', '000000053', '520', '0000000000001074', to_date('7/13/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('305', '080', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('306', '000000054', '831', '0000000000043635', to_date('7/5/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('306', '054', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('307', '000000055', '264', '0000000000027541', to_date('1/3/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('307', '005', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('308', '000000056', '473', '0000000000093399', to_date('3/4/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('308', '009', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('309', '000000057', '611', '0000000000015133', to_date('1/16/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('309', '029', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('310', '000000058', '593', '0000000000021721', to_date('10/12/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('310', '036', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('311', '000000059', '954', '0000000000090867', to_date('8/14/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('311', '021', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('312', '000000060', '613', '0000000000062638', to_date('8/20/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('312', '058', to_date('12/9/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('313', '000000061', '619', '0000000000019143', to_date('8/17/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('313', '079', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('314', '000000062', '421', '0000000000009734', to_date('5/17/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('314', '031', to_date('12/6/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('315', '000000063', '667', '0000000000027472', to_date('7/9/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('315', '072', to_date('12/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('316', '000000064', '775', '0000000000083489', to_date('10/15/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('316', '100', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('317', '000000065', '878', '0000000000090017', to_date('9/15/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('317', '014', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('318', '000000066', '579', '0000000000054260', to_date('1/1/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('318', '087', to_date('12/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('319', '000000067', '526', '0000000000029571', to_date('10/8/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('319', '012', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('320', '000000068', '789', '0000000000058112', to_date('3/15/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('320', '037', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('321', '000000069', '202', '0000000000033759', to_date('5/15/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('321', '048', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('322', '000000070', '657', '0000000000093571', to_date('1/9/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('322', '020', to_date('12/11/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('323', '000000071', '108', '0000000000014839', to_date('10/17/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('323', '011', to_date('12/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('324', '000000072', '764', '0000000000043322', to_date('8/10/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('324', '084', to_date('12/17/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('325', '000000073', '752', '0000000000005242', to_date('5/17/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('325', '087', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('326', '000000074', '166', '0000000000081864', to_date('2/10/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('326', '068', to_date('12/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('327', '000000075', '151', '0000000000052134', to_date('6/8/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('327', '046', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('328', '000000076', '925', '0000000000080401', to_date('10/9/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('328', '049', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('329', '000000077', '338', '0000000000022926', to_date('6/7/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('329', '041', to_date('12/14/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('330', '000000078', '284', '0000000000031224', to_date('7/3/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('330', '026', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('331', '000000079', '939', '0000000000041456', to_date('8/6/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('331', '091', to_date('12/1/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('332', '000000080', '637', '0000000000090192', to_date('7/4/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('332', '027', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('333', '000000081', '839', '0000000000014352', to_date('7/5/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('333', '053', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('334', '000000082', '715', '0000000000025780', to_date('2/18/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('334', '022', to_date('12/16/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('335', '000000083', '178', '0000000000090554', to_date('2/14/2016', 'mm/dd/yyyy'), '1', 'DCA', 'SFA');
insert into reservation_detail values('335', '068', to_date('12/13/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('336', '000000084', '233', '0000000000034844', to_date('4/3/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('336', '041', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('337', '000000085', '380', '0000000000037270', to_date('2/5/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('337', '009', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('338', '000000086', '243', '0000000000013178', to_date('7/20/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('338', '008', to_date('12/18/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('339', '000000087', '229', '0000000000066859', to_date('10/11/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('339', '045', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('340', '000000088', '768', '0000000000077958', to_date('4/9/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('340', '055', to_date('12/19/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('341', '000000089', '781', '0000000000045263', to_date('6/5/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('341', '056', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('342', '000000090', '327', '0000000000057937', to_date('6/10/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('342', '013', to_date('12/3/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('343', '000000091', '124', '0000000000096011', to_date('9/3/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('343', '085', to_date('12/15/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('344', '000000092', '358', '0000000000048393', to_date('8/11/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('344', '034', to_date('12/12/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('345', '000000093', '927', '0000000000036199', to_date('3/2/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('345', '033', to_date('12/7/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('346', '000000094', '892', '0000000000095338', to_date('1/10/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('346', '081', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('347', '000000095', '331', '0000000000033516', to_date('10/17/2016', 'mm/dd/yyyy'), '1', 'ATL', 'LAX');
insert into reservation_detail values('347', '082', to_date('12/8/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('348', '000000096', '565', '0000000000015766', to_date('4/16/2016', 'mm/dd/yyyy'), '1', 'SFA', 'DCA');
insert into reservation_detail values('348', '059', to_date('12/5/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('349', '000000097', '723', '0000000000059238', to_date('4/14/2016', 'mm/dd/yyyy'), '1', 'SFA', 'PIT');
insert into reservation_detail values('349', '027', to_date('12/2/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('350', '000000098', '606', '0000000000026286', to_date('7/6/2016', 'mm/dd/yyyy'), '1', 'LAX', 'DCA');
insert into reservation_detail values('350', '004', to_date('12/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation values('351', '000000098', '606', '0000000000026286', to_date('11/4/2016', 'mm/dd/yyyy'), '1', 'LAX', 'SFA');
insert into reservation_detail values('351', '018', to_date('12/4/2016', 'mm/dd/yyyy'), 1);
insert into reservation_detail values('351', '069', to_date('12/4/2016', 'mm/dd/yyyy'), 2);
