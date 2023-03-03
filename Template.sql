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
  dimensions  INT, -- figure out the composite attributes (height FLOAT, width FLOAT, depth FLOAT)
  weight      FLOAT,
  description VARCHAR(200),
  value       FLOAT
);

CREATE TABLE Legs ( -- need to specify who it belongs to? eg legs of a delivery / delivery
  src        INT, -- what if not fid, but an address tho. maybe worth creating a intermediate_legs table?
  dest       INT,
  eid        INT,
  start_time DATETIME,
  end_time   DATETIME
);

CREATE TABLE Delivery_Processes (
  -- lmao
);

CREATE TABLE Pickups (
  timestamp INT,
  eid       INT
  PRIMARY KEY (timestamp, eid)
);

CREATE TABLE Successful_Pickups (
);

CREATE TABLE Unsuccessful_Pickups (
  reason VARCHAR(200)
);

CREATE TABLE Accepted_Requests (
  cc_num    INT,
  timestamp DATETIME,
  status    VARACHAR(20)
);

CREATE TABLE Withdrawn_Requests (

);

CREATE TABLE Delivery_Personnels (

);

CREATE TABLE First_Legs (
  dimensions INT, -- figure out composite attributes
  weight     FLOAT
);

CREATE TABLE Last_Legs (

);

CREATE TABLE Unsuccessful_Deliveries (
  timestamp DATETIME,
  reason    VARCHAR(200),
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

CREATE TABLE Proceeds (

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

