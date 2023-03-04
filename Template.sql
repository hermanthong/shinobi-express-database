CREATE TABLE Employees (
  eid     INT PRIMARY KEY,
  ename   VARCHAR(200),
  egender VARCHAR(20),
  dob     DATE,
  title   VARCHAR(200),
  salary  INT
);

CREATE TABLE Facilities (
  fid         INT PRIMARY KEY,
  addr        VARCHAR(200),
  postal_code INT
);

CREATE TABLE Customers (
  cid           INT PRIMARY KEY,
  cname         VARCHAR(200),
  cgender       VARCHAR(20),
  mobile_number INT
);

CREATE TABLE Delivery_Requests (
  drid                  INT PRIMARY KEY,
  pickup_addr           VARCHAR(200),
  pickup_postal_code    INT,
  recipient_name        VARCHAR(200),
  recipient_addr        VARCHAR(200),
  recipient_postal_code INT
);

CREATE TABLE Packages (
  pid         INT PRIMARY KEY,
  height      NUMERIC CHECK (height >=0), 
  width       NUMERIC CHECK (width >=0),
  depth       NUMERIC CHECK (depth >=0),
  weight      NUMERIC CHECK (weight >=0),
  description VARCHAR(200),
  value       NUMERIC CHECK (value >= 0)
);

CREATE TABLE Legs ( 
  src        INT,
  dest       INT,
  start_time DATETIME,
  end_time   DATETIME
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
  eid INT REFERENCES Employees
  

);

CREATE TABLE Terminates (

);

CREATE TABLE Refunds (

);

CREATE TABLE Cancels (
  timestamp INT
);

