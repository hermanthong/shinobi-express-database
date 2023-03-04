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
  src        VARCHAR(200),
  dest       VARCHAR(200),
  start_time DATETIME,
  end_time   DATETIME,
  puid       INT
    REFERENCES Successful_Pickups (puid),
  PRIMARY KEY  (puid, start_time)
);

CREATE TABLE Pickups (
  puid      INT PRIMARY KEY,
  timestamp DATETIME
);

CREATE TABLE Successful_Pickups (
  puid      INT PRIMARY KEY
    REFERENCES Pickups (puid) ON DELETE CASCADE
);

CREATE TABLE Unsuccessful_Pickups (
  puid      INT PRIMARY KEY
    REFERENCES Pickups (puid) ON DELETE CASCADE,
  reason    VARCHAR(200)
);

CREATE TABLE Accepted_Requests (
  drid      INT PRIMARY KEY
    REFERENCES Delivery_Requests (drid) ON DELETE CASCADE,
  cc_num    INT,
  timestamp DATETIME,
  status    VARCHAR(20)
);

CREATE TABLE Withdrawn_Requests (
  drid      INT PRIMARY KEY
    REFERENCES Delivery_Requests (drid) ON DELETE CASCADE
);

CREATE TABLE Delivery_Personnels (
  eid     INT PRIMARY KEY
    REFERENCES Employees (eid) ON DELETE CASCADE
);

CREATE TABLE First_Legs (
  dimensions INT,
  weight     INT,
  puid       INT,
  start_time DATETIME,
  PRIMARY KEY (puid, start_time)
    REFERENCES Legs (puid, start_time) ON DELETE CASCADE
);

CREATE TABLE Last_Legs (
  puid       INT,
  start_time DATETIME,
  PRIMARY KEY (puid, start_time)
    REFERENCES Legs (puid, start_time) ON DELETE CASCADE
);

CREATE TABLE Unsuccessful_Deliveries (
  timestamp   DATETIME,
  reason      VARCHAR(200),
  count       INT,
  puid        INT,
  start_time  DATETIME,
  PRIMARY KEY (puid, start_time)
    REFERENCES Last_Legs (puid, start_time) ON DELETE CASCADE
);

CREATE TABLE Return_Delivery_Processes (
  drid      INT PRIMARY KEY,
  FOREIGN KEY (drid) REFERENCES Accepted_Requests (drid)
);

CREATE TABLE Stores (
  fid INT,
  pid INT,
  FOREIGN KEY (fid) REFERENCES Facilities (fid),
  FOREIGN KEY (pid) REFERENCES Packages (pid)
);

CREATE TABLE Submits (
  drid INT,
  cid  INT,
  FOREIGN KEY (drid) REFERENCES Delivery_Requests (drid),
  FOREIGN KEY (cid) REFERENCES Customers (cid),
  PRIMARY KEY (drid, cid)
);

CREATE TABLE Involves (
  drid INT,
  pid  INT,
  FOREIGN KEY (drid) REFERENCES Delivery_Requests (drid),
  FOREIGN KEY (pid) REFERENCES Packages (pid)
);

CREATE TABLE Evaluates (
  drid INT,
  eid  INT,
  cid  INT,
  FOREIGN KEY (drid) REFERENCES Delivery_Requests (drid),
  FOREIGN KEY (eid) REFERENCES Employees (eid),
  FOREIGN KEY (cid) REFERENCES Customers (cid)
);


CREATE TABLE Pays (
  cid INT,
  drid INT,
  FOREIGN KEY (cid) REFERENCES Customers (cid),
  FOREIGN KEY (drid) REFERENCES Accepted_Requests (drid)
);

CREATE TABLE Monitors (
  eid INT,
  drid INT,
  FOREIGN KEY (eid) REFERENCES Employees (eid),
  FOREIGN KEY (drid) REFERENCES Accepted_Requests (drid)
);

CREATE TABLE Starts (
  puid      INT,
  drid      INT,
  FOREIGN KEY (puid) REFERENCES Pickups (puid),
  FOREIGN KEY (drid) REFERENCES Accepted_Requests (drid)
);

CREATE TABLE Does (
  eid INT,
  puid INT,
  FOREIGN KEY (eid) REFERENCES Delivery_Personnels (eid),
  FOREIGN KEY (puid) REFERENCES Pickups (puid)
);

CREATE TABLE Keeps (
  puid        INT,
  start_time  DATETIME,
  fid         INT,
  FOREIGN KEY (puid, start_time) REFERENCES Last_Legs (puid, start_time),
  FOREIGN KEY (fid) REFERENCES Facilities (fid)
);

CREATE TABLE Handles (
  eid         INT,
  puid        INT,
  start_time  DATETIME,
  FOREIGN KEY (eid) REFERENCES Delivery_Personnels (eid),
  FOREIGN KEY (puid, start_time) REFERENCES Legs (puid, start_time)
);

CREATE TABLE Terminates (
  eid         INT,
  puid        INT,
  start_time  DATETIME,
  drid        INT,
  cid         INT,
  FOREIGN KEY (eid) REFERENCES Delivery_Personnels (eid),
  FOREIGN KEY (puid, start_time) REFERENCES First_Legs (puid, start_time),
  FOREIGN KEY (drid, cid) REFERENCES Submits (drid, cid)
);

CREATE TABLE Cancels (
  cid         INT,
  drid        INT,
  timestamp   DATETIME,
  FOREIGN KEY (cid) REFERENCES Customers (cid),
  FOREIGN KEY (drid) REFERENCES Return_Delivery_Processes (drid)
);

