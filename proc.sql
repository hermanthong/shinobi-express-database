-- you have to make a delivery_request before you add packages
-- so it wouldn't make sense to check delivery requests when they're inserted
-- since the check is done after a package is inserted, fresh delivery requests
-- that the package's request id references should survive
CREATE OR REPLACE FUNCTION trigger_one_function() RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM delivery_requests WHERE id = NEW.request_id) THEN
        DELETE FROM delivery_requests WHERE id = NEW.request_id;
    END IF;
    -- return value can be whatever
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_one_check
AFTER INSERT ON packages
FOR EACH ROW
EXECUTE FUNCTION trigger_one_function();



-- checks the highest previous package id with the same request id
-- then checks if the new addition has a consecutive package id
-- also includes edge case where table is empty
CREATE OR REPLACE FUNCTION trigger_two_function() RETURNS TRIGGER AS $$
DECLARE
    last_id INTEGER;
BEGIN
    SELECT MAX(package_id) INTO last_id FROM packages WHERE request_id = NEW.request_id;
    IF last_id IS NULL THEN
        -- table is empty
        IF NEW.package_id != 1 THEN
            RAISE EXCEPTION 'Package ID should start from 1';
        END IF;
    ELSIF NEW.package_id != last_id + 1 THEN
        RAISE EXCEPTION 'Package ID not consecutive';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_two_check
BEFORE INSERT ON packages
FOR EACH ROW
EXECUTE FUNCTION trigger_two_function();

-- trigger #3 is same as trigger #2
-- trigger #4 selects the appropriate timestamp and prevents insertion of earlier timestamps
CREATE OR REPLACE FUNCTION trigger_three_and_four_function()
RETURNS TRIGGER AS $$
DECLARE
    last_id INTEGER;
    other_timestamp TIMESTAMP;
BEGIN
    SELECT MAX(pickup_id) INTO last_id FROM unsuccessful_pickups WHERE request_id = NEW.request_id;
    -- question three
    IF last_id IS NULL THEN
        -- table is empty
        IF NEW.pickup_id != 1 THEN
            RAISE EXCEPTION 'Pickup ID should start from 1';
        END IF;
    ELSIF NEW.pickup_id != last_id + 1 THEN
        RAISE EXCEPTION 'Pickup ID not consecutive';
    END IF;
    -- question four
    IF NEW.pickup_id == 1 THEN
        SELECT submission_time INTO other_timestamp FROM delivery_requests WHERE id = NEW.request_id;
    ELSE
    -- no need to check for request timestamp since previous request would have to pass that check already
        SELECT pickup_time INTO other_timestamp FROM unsuccessful_pickups WHERE pickup_id = last_id;
    END IF;
    IF NEW.pickup_time <= other_timestamp THEN
        RAISE EXCEPTION 'New timestamp should not be earlier than request or last unsuccessful pickup';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_three_and_four_check
BEFORE INSERT ON unsuccessful_pickups
FOR EACH ROW
EXECUTE FUNCTION trigger_three_and_four_function();

-- same as trigger #2
CREATE OR REPLACE FUNCTION legs_one_two_and_three_function() RETURNS TRIGGER AS $$
DECLARE
    last_id INTEGER;
    other_timestamp TIMESTAMP;
    previous_leg_end_timestamp TIMESTAMP;
BEGIN
    -- legs one
    SELECT MAX(leg_id) INTO last_id FROM legs WHERE request_id = NEW.request_id;
    IF last_id IS NULL THEN
        -- table is empty
        IF NEW.leg_id != 1 THEN
            RAISE EXCEPTION 'Leg ID should start from 1';
        END IF;
    ELSIF NEW.leg_id != last_id + 1 THEN
        RAISE EXCEPTION 'Leg ID not consecutive';
    END IF;
    RETURN NEW;
    -- legs two
    IF NEW.leg_id == 1 THEN
        SELECT submission_time INTO other_timestamp FROM delivery_requests WHERE id = NEW.request_id;
    ELSE
    -- no need to check for request timestamp since previous request would have to pass that check already
        SELECT start_time INTO other_timestamp FROM legs WHERE leg_id = last_id;
    END IF;
    IF NEW.start_time <= other_timestamp THEN
        RAISE EXCEPTION 'New timestamp should not be earlier than request or last unsuccessful pickup';
    END IF;
    -- legs three
    IF NEW.leg_id > 1 THEN
        SELECT end_time INTO previous_leg_end_timestamp FROM legs WHERE leg_id = last_id;
        IF previous_leg_end_timestamp IS NULL THEN
            RAISE EXCEPTION 'Previous leg has not been completed';
        ELSIF NEW.start_time < previous_leg_end_timestamp THEN
            RAISE EXCEPTION 'New timestamp should not be earlier than previous legs end timestamp';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER legs_one_two_and_three_check
BEFORE INSERT ON legs
FOR EACH ROW
EXECUTE FUNCTION legs_one_two_and_three_function();

CREATE OR REPLACE FUNCTION unsuccess_delivery_one_function() RETURNS TRIGGER AS $$
DECLARE
    other_timestamp TIMESTAMP;
BEGIN
    SELECT start_time INTO other_timestamp FROM legs WHERE leg_id = NEW.leg_id AND request_id = NEW.request_id;
    IF NEW.attempt_time <= other_timestamp THEN
        RAISE EXCEPTION 'New timestamp should not be earlier than legs start time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER unsuccess_delivery_one_check
BEFORE INSERT ON unsuccessful_deliveries
FOR EACH ROW
EXECUTE FUNCTION unsuccess_delivery_one_function();

CREATE OR REPLACE FUNCTION unsuccess_delivery_two_function() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM unsuccessful_deliveries
    WHERE leg_id = NEW.leg_id AND request_id = NEW.request_id
    HAVING COUNT(*) >= 3
    ) THEN
    RAISE EXCEPTION 'There have already been 3 unsuccessful deliveries';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER unsuccess_delivery_two_check
BEFORE INSERT ON unsuccessful_deliveries
FOR EACH ROW
EXECUTE FUNCTION unsuccess_delivery_two_function();

CREATE OR REPLACE FUNCTION cancel_one_function() RETURNS TRIGGER AS $$
DECLARE
    other_timestamp TIMESTAMP;
BEGIN
    SELECT submission_time INTO other_timestamp FROM delivery_requests WHERE id = NEW.id;
    IF NEW.cancel_time <= other_timestamp THEN
        RAISE EXCEPTION 'Cancel timestamp should not be earlier than request submission time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER cancel_one_check
BEFORE INSERT ON cancelled_requests
FOR EACH ROW
EXECUTE FUNCTION cancel_one_function();

CREATE OR REPLACE FUNCTION return_leg_one_function() RETURNS TRIGGER AS $$
DECLARE
    last_id INTEGER;
BEGIN
    SELECT MAX(leg_id) INTO last_id FROM return_legs WHERE request_id = NEW.request_id;
    IF last_id IS NULL THEN
        -- table is empty
        IF NEW.leg_id != 1 THEN
            RAISE EXCEPTION 'Return leg ID should start from 1';
        END IF;
    ELSIF NEW.leg_id != last_id + 1 THEN
        RAISE EXCEPTION 'Return leg ID not consecutive';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER return_leg_one_check
BEFORE INSERT ON return_legs
FOR EACH ROW
EXECUTE FUNCTION return_leg_one_function();

CREATE OR REPLACE FUNCTION return_leg_two_function() RETURNS TRIGGER AS $$
DECLARE
    last_leg_id INTEGER;
    other_timestamp TIMESTAMP;
    cancel_timestamp TIMESTAMP;
BEGIN
    -- part i
    IF NOT EXISTS (
        SELECT 1
        FROM legs
        WHERE request_id = NEW.request_id
        ) THEN
        RAISE EXCEPTION 'Leg does not exist for delivery request';
    END IF;
    -- part ii
    SELECT MAX(leg_id) INTO last_leg_id FROM legs WHERE request_id = NEW.request_id;
    SELECT end_time INTO other_timestamp FROM legs WHERE leg_id = last_leg_id AND request_id = NEW.request_id;
    IF NEW.start_time < other_timestamp THEN
        RAISE EXCEPTION 'Return leg start time should not be earlier than end time of latest leg';
    END IF;
    -- part iii
    SELECT cancel_time INTO cancel_timestamp FROM cancelled_requests WHERE id = NEW.request_id;
    IF cancel_timestamp IS NOT NULL THEN
        IF NEW.start_time <= cancel_timestamp THEN
            RAISE EXCEPTION 'Return leg start time should not be earlier than cancel time of cancelled request';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER return_leg_two_check
BEFORE INSERT ON return_legs
FOR EACH ROW
EXECUTE FUNCTION return_leg_two_function();

CREATE OR REPLACE FUNCTION return_leg_three_function() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM return_legs
    WHERE leg_id = NEW.leg_id AND request_id = NEW.request_id
    HAVING COUNT(*) >= 3
    ) THEN
    RAISE EXCEPTION 'There have already been 3 unsuccessful return deliveries for this leg';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER return_leg_three_check
BEFORE INSERT ON unsuccessful_return_deliveries
FOR EACH ROW
EXECUTE FUNCTION return_leg_three_function();

CREATE OR REPLACE FUNCTION unsuccess_return_function() RETURNS TRIGGER AS $$
DECLARE
    other_timestamp TIMESTAMP;
BEGIN
    -- return leg is not a leg
    SELECT start_time INTO other_timestamp FROM return_legs WHERE leg_id = NEW.leg_id AND request_id = NEW.request_id;
    IF NEW.attempt_time <= other_timestamp THEN
        RAISE EXCEPTION 'Return attempt timestamp should not be earlier than start of return leg';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER unsuccess_return_one_check
BEFORE INSERT ON unsuccessful_return_deliveries
FOR EACH ROW
EXECUTE FUNCTION unsuccess_return_function();

-- 2.1.1
-- The procedure submit_request takes input parameters like customer_id, evaluator_id, pickup_addr, pickup_postal, etc. as mentioned in the problem statement.
-- A local variable request_id is declared to store the ID of the newly inserted delivery request.
-- The delivery_requests table is inserted with the input values and the status is set to submitted. The RETURNING clause is used to get the id of the newly inserted row into request_id.
-- A loop is used to insert each package's details into the packages table. The ith item of each input array is used to insert into the corresponding column in the table.

CREATE OR REPLACE PROCEDURE submit_request(
    IN customer_id INTEGER,
    IN evaluator_id INTEGER,
    IN pickup_addr TEXT,
    IN pickup_postal TEXT,
    IN recipient_name TEXT,
    IN recipient_addr TEXT,
    IN recipient_postal TEXT,
    IN submission_time TIMESTAMP,
    IN package_num INTEGER,
    IN reported_height NUMERIC[],
    IN reported_width NUMERIC[],
    IN reported_depth NUMERIC[],
    IN reported_weight NUMERIC[],
    IN content TEXT[],
    IN estimated_value NUMERIC[]
)
AS $$
DECLARE
    request_id INTEGER;
    i INTEGER;
BEGIN
    INSERT INTO delivery_requests (customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price)
    VALUES (customer_id, evaluator_id, 'submitted', pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, NULL, NULL, NULL)
    RETURNING id INTO request_id;

    i := 1;
    LOOP
        EXIT WHEN i > package_num;
        INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value)
        VALUES (request_id, i, reported_height[i], reported_width[i], reported_depth[i], reported_weight[i], content[i], estimated_value[i]);
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- to test
-- CALL submit_request(
--     1,
--     1,
--     '123 Main St',
--     'V6T 1Z4',
--     'John Smith',
--     '456 Oak St',
--     'V6M 3W4',
--     '2023-04-14 15:30:00',
--     2,
--     ARRAY[1.5, 2.0],
--     ARRAY[0.8, 1.2],
--     ARRAY[1.0, 1.5],
--     ARRAY[2.0, 3.0],
--     ARRAY['Clothing', 'Books'],
--     ARRAY[100.0, 50.0]
-- );

-- 2.1.2
-- The procedure first creates a new delivery request with the same attributes as the original one, except for the evaluator_id, status, and submission_time.
-- It then copies the packages from the original delivery request to the new one, with the reported measurements replaced by the ones provided as input and
-- the actual measurements set to NULL.
CREATE OR REPLACE PROCEDURE resubmit_request(
    IN old_request_id INTEGER,
    IN evaluator_id INTEGER,
    IN submission_time TIMESTAMP,
    IN reported_height INTEGER[],
    IN reported_width INTEGER[],
    IN reported_depth INTEGER[],
    IN reported_weight INTEGER[]
)
AS $$
DECLARE
    new_request_id INTEGER;
    package RECORD;
    i INTEGER;
BEGIN
    -- Generate a new request ID
    SELECT MAX(id) + 1 INTO new_request_id FROM delivery_requests;
    IF new_request_id IS NULL THEN
        new_request_id := 1;
    END IF;

    -- Insert new request
    INSERT INTO delivery_requests (
        id,
        customer_id,
        evaluater_id,
        status,
        pickup_addr,
        pickup_postal,
        recipient_name,
        recipient_addr,
        recipient_postal,
        submission_time,
        pickup_date,
        num_days_needed,
        price
    )
    SELECT
        new_request_id,
        customer_id,
        evaluator_id,
        'submitted',
        pickup_addr,
        pickup_postal,
        recipient_name,
        recipient_addr,
        recipient_postal,
        delivery_requests.submission_time,
        NULL,
        NULL,
        NULL
    FROM delivery_requests
    WHERE id = old_request_id;

    -- Insert new packages
    i := 1;
    FOR package IN SELECT * FROM packages WHERE old_request_id = packages.request_id
    LOOP
        INSERT INTO packages (
            request_id,
            package_id,
            reported_height,
            reported_width,
            reported_depth,
            reported_weight,
            content,
            estimated_value,
            actual_height,
            actual_width,
            actual_depth,
            actual_weight
        )
        VALUES (
            new_request_id,
            package.package_id,
            reported_height[i],
            reported_width[i],
            reported_depth[i],
            reported_weight[i],
            package.content,
            package.estimated_value,
            NULL,
            NULL,
            NULL,
            NULL
        );

        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- test
-- CALL resubmit_request(
-- 	1,
-- 	1,
--     '2023-04-14 22:00:00',
-- 	ARRAY[10, 12],
-- 	ARRAY[5, 6],
-- 	ARRAY[3, 4],
-- 	ARRAY[2, 3]
-- );

-- 2.1.3
CREATE OR REPLACE PROCEDURE insert_leg(
  IN req_id INTEGER,
  IN handler_id INTEGER,
  IN start_time TIMESTAMP,
  IN destination_facility INTEGER
)
AS $$
DECLARE
  new_leg_id INTEGER;
BEGIN
  SELECT COALESCE(MAX(leg_id), 0) + 1
  INTO new_leg_id
  FROM legs
  WHERE req_id = request_id;

  INSERT INTO legs (request_id, leg_id, handler_id, start_time, destination_facility, end_time)
  VALUES (req_id, new_leg_id, handler_id, start_time, destination_facility, NULL);
END;
$$ LANGUAGE plpgsql;

-- to test
-- CALL insert_leg(1, 2, '2023-04-14 22:00:00', 3);

-- 2.2.1
CREATE OR REPLACE FUNCTION view_trajectory(req_id INTEGER)
RETURNS TABLE(
    source_addr TEXT,
    destination_addr TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    WITH delivery AS (
        SELECT
            dr.submission_time AS start_time,
            l.start_time AS end_time,
            dr.pickup_addr AS source_addr,
            l.destination_facility AS dest_id
        FROM
            accepted_requests ar
            JOIN delivery_requests dr ON dr.id = ar.id
            JOIN legs l ON l.request_id = ar.id
        WHERE
            ar.id = req_id
        UNION
        SELECT
            rl.start_time,
            rl.end_time,
            f.address AS source_addr,
            rl.source_facility AS dest_id
        FROM
            cancelled_or_unsuccessful_requests cr
            JOIN return_legs rl ON rl.request_id = cr.id
            JOIN facilities f ON f.id = rl.source_facility
        WHERE
            cr.id = req_id
    )
    SELECT
        sf.address AS source_addr,
        df.address AS destination_addr,
        delivery.start_time,
        delivery.end_time
    FROM
        delivery
        JOIN facilities sf ON sf.id = delivery.dest_id
        JOIN facilities df ON df.postal = (SELECT pickup_postal FROM delivery_requests WHERE id = req_id)
    ORDER BY
        delivery.start_time ASC;
END;
$$ LANGUAGE plpgsql;


-- 2.2.2
CREATE OR REPLACE FUNCTION get_top_delivery_persons(k INTEGER)
RETURNS TABLE (employee_id INTEGER) AS $$
BEGIN
    RETURN QUERY

    SELECT d.id
    FROM legs l
    JOIN delivery_staff d ON d.id = l.handler_id
    JOIN accepted_requests a ON a.id = l.request_id
    GROUP BY d.id
    ORDER BY COUNT(d.id) DESC
    LIMIT k;
END;
$$ LANGUAGE plpgsql;

-- to test
-- SELECT get_top_delivery_persons(3);

-- 1. put all legs in order: ascending accepted request, then ascending timestamp
-- 2. gather all pairs of consecutive facility_id as source_facility id, destination_facility_id, and put in CTE
-- 3. count the number of occurrences of each facility_id
-- 4. order as specified and limit k
-- 2.2.3
CREATE OR REPLACE FUNCTION get_top_connections(k INTEGER)
RETURNS TABLE(source_facility INTEGER, destination_facility_id INTEGER) AS $$
BEGIN
    RETURN QUERY     
    SELECT source_facility, destination_facility, sum(count) as count
    FROM(
        SELECT * 
        FROM (
            SELECT source_facility, destination_facility, COALESCE(count(*), 0) AS count
            FROM (
                SELECT source_facility, destination_facility
                    FROM (
                        SELECT
                            lag(request_id) OVER (ORDER BY request_id, end_time) AS old_request_id, 
                            request_id,
                            lag(destination_facility) OVER (ORDER BY request_id, end_time) AS source_facility,
                            destination_facility
                        FROM legs
                    ) AS consecutive_facilities
                    WHERE old_request_id = request_id
            ) AS leg_trajectory
            GROUP BY source_facility, destination_facility
        ) AS legs_sorted

        UNION 
        
            SELECT source_facility, destination_facility, COALESCE(count(*), 0) AS count
            FROM (
                SELECT source_facility, destination_facility
                    FROM (
                        SELECT
                            lag(request_id) OVER (ORDER BY request_id, end_time) AS old_request_id, 
                            request_id,
                            source_facility,
                            lag(source_facility) OVER (ORDER BY request_id, end_time) AS destination_facility
                        FROM return_legs
                    ) AS consecutive_facilities
                    WHERE old_request_id = request_id
            ) AS return_leg_trajectory
            GROUP BY source_facility, destination_facility
        ) AS df
    GROUP BY source_facility, destination_facility
    ORDER BY count DESC, source_facility, destination_facility
    LIMIT k;
END;
$$ LANGUAGE plpgsql;

