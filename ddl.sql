
INSERT INTO customers (name, gender, mobile) VALUES ('John Smith', 'male', '123-456-7890');
INSERT INTO customers (name, gender, mobile) VALUES ('Jane Doe', 'female', '555-555-5555');
INSERT INTO employees (name, gender, dob, title, salary) VALUES ('Bob Johnson', 'male', '1990-01-01', 'Delivery Driver', 40000);
INSERT INTO employees (name, gender, dob, title, salary) VALUES ('Samantha Lee', 'female', '1985-03-15', 'Manager', 80000);
INSERT INTO employees (name, gender, dob, title, salary) VALUES ('Jonathan Lee', 'male', '1985-03-25', 'Delivery Driver', 40000);

INSERT INTO delivery_staff (id) VALUES (1);
INSERT INTO delivery_staff (id) VALUES (2);
INSERT INTO delivery_staff (id) VALUES (3);

INSERT INTO delivery_requests (customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES (1, 2, 'submitted', '123 Main St', 'M5V 1K4', 'Sarah Smith', '456 Queen St', 'M5V 1K4', '2023-04-14 12:00:00', '2023-04-16', 2, 50.00);
INSERT INTO delivery_requests (customer_id, evaluater_id, status, pickup_addr, pickup_postal, recipient_name, recipient_addr, recipient_postal, submission_time, pickup_date, num_days_needed, price) VALUES (2, 1, 'submitted', '789 King St', 'M5V 1K4', 'John Doe', '321 Yonge St', 'M5V 1K4', '2023-04-14 14:00:00', '2023-04-18', 4, 100.00);
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES (1, 1, 10.0, 20.0, 30.0, 5.0, 'Books', 50.00, NULL, NULL, NULL, NULL);
INSERT INTO packages (request_id, package_id, reported_height, reported_width, reported_depth, reported_weight, content, estimated_value, actual_height, actual_width, actual_depth, actual_weight) VALUES (1, 2, 15.0, 25.0, 35.0, 10.0, 'Clothes', 100.00, NULL, NULL, NULL, NULL);
INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (1, '1234-5678-9012-3456', '2023-04-14 15:00:00', 2);
INSERT INTO accepted_requests (id, card_number, payment_time, monitor_id) VALUES (2, '1234-5678-9012-3437', '2023-04-14 17:00:00', 1);

INSERT INTO cancelled_or_unsuccessful_requests (id) VALUES (1);
INSERT INTO cancelled_or_unsuccessful_requests (id) VALUES (2);

INSERT INTO cancelled_requests (id, cancel_time) VALUES (1, '2023-04-15 10:00:00');
INSERT INTO unsuccessful_pickups (request_id, pickup_id, handler_id, pickup_time, reason) VALUES (1, 1, 1, '2023-04-16 13:00:00', 'Customer not home');
INSERT INTO facilities(id, address, postal) VALUES (1, 'test1 dr.', '554425');
INSERT INTO facilities(id, address, postal) VALUES (2, 'test2 dr.', '554455');
INSERT INTO facilities(id, address, postal) VALUES (3, 'test3 dr.', '554355');

-- Sample data for legs table
INSERT INTO legs (request_id, leg_id, handler_id, start_time, end_time, destination_facility)
VALUES
	(1, 1, 1, '2023-04-10 10:00:00', '2023-04-10 12:00:00', 1),
	(1, 2, 2, '2023-04-10 13:00:00', '2023-04-10 14:00:00', 2),
	(2, 1, 3, '2023-04-11 11:00:00', '2023-04-11 12:00:00', 3);
