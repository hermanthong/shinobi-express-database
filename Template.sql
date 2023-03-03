CREATE TABLE Employees (
  eid     INT,
  ename   INT,
  egender INT,
  dob     INT,
  title   INT,
  salary  INT
);

CREATE TABLE Facilities (
  fid         INT,
  addr        INT,
  postal_code INT
);

CREATE TABLE Customers (
  cid           INT,
  cname         INT,
  cgender       INT,
  mobile_number INT
);

CREATE TABLE Delivery_Requests (
  drid                  INT,
  pickup_addr           INT,
  pickup_postal_code    INT,
  recipient_name        INT,
  recipient_addr        INT,
  recipient_postal_code INT
);

CREATE TABLE Packages (
  pid         INT,
  dimensions  INT,
  weight      INT,
  description INT,
  value       INT
);

CREATE TABLE Legs (
  lid        INT,
  src        INT,
  dest       INT,
  eid        INT,
  start_time INT,
  end_time   INT
);

CREATE TABLE Delivery_Process (
  dpid INT
);

CREATE TABLE Pickups (
  puid INT
);

CREATE TABLE Accepted_Requests (
  cc_num    INT,
  timestamp INT,
  status    INT
);

CREATE TABLE Withdrawn_Requests (

);

CREATE TABLE Delivery_Personnels (

);

CREATE TABLE First_Legs (
  dimensions INT,
  weight     INT
);

CREATE TABLE Last_Legs (

);

CREATE TABLE Stores (

);

CREATE TABLE Submits (

);

CREATE TABLE Involves (

);

CREATE TABLE Evaluates (

);

CREATE TABLE Informs (

);

CREATE TABLE Proceeds (

);

CREATE TABLE Pays (

);

CREATE TABLE Monitors (

);

CREATE TABLE Consists (

);

CREATE TABLE Handles (

);

CREATE TABLE Updates_Measurements (

);

CREATE TABLE Updates_Status (

);

CREATE TABLE Drops_Off (

);

CREATE TABLE Processes (
  acceptable            INT,
  price                 INT,
  tentative_pickup_date INT,
  days_required         INT
);

