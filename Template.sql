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
  src        INT,
  dest       INT,
  start_time INT,
  end_time   INT
);

CREATE TABLE Delivery_Processes (

);

CREATE TABLE Pickups (
  timestamp INT
);

CREATE TABLE Successful_Pickups (

);

CREATE TABLE Unsuccessful_Pickups (
  reason INT
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

CREATE TABLE Unsuccessful_Deliveries (
  timestamp INT,
  reason    INT,
  count     INT
);

CREATE TABLE Return_Delivery_Processes (

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

CREATE TABLE Pays (

);

CREATE TABLE Monitors (

);

CREATE TABLE Has (

);

CREATE TABLE Starts (

);

CREATE TABLE Does (

);

CREATE TABLE Initiates (

);

CREATE TABLE Keeps (

);

CREATE TABLE Handles (

);

CREATE TABLE Terminates (

);

CREATE TABLE Refunds (

);

CREATE TABLE Cancels (
  timestamp INT
);

