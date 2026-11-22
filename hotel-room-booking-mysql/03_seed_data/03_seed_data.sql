use hotel_booking_db;
INSERT INTO room_types (type_name, base_price, max_occupancy) VALUES
('Standard Single', 100.00, 1),
('Deluxe Double', 180.00, 2),
('Executive Suite', 320.00, 4);

-- 2. Insert Physical Rooms
INSERT INTO rooms (room_number, type_id, floor) VALUES
('101', 1, 1), ('102', 1, 1),
('201', 2, 2), ('202', 2, 2),
('301', 3, 3);

-- 3. Insert Seasonal Pricing Multiplier
INSERT INTO seasonal_rates (season_name, start_date, end_date, price_multiplier) VALUES
('Winter Holiday Peak', '2026-12-20', '2027-01-05', 1.50);

-- 4. Insert Sample Customers
INSERT INTO customers (full_name, email, phone) VALUES
('Aarav Sharma', 'aarav@example.com', '9876543210'),
('Priya Nair', 'priya@example.com', '9123456780');

-- 5. Create a Reservation (Trigger calculates total_amount automatically)
INSERT INTO reservations (customer_id, room_id, check_in, check_out) VALUES
(1, 3, '2026-12-22', '2026-12-25');

-- 6. Verification Queries
CALL GetAvailableRooms(2, '2026-12-23', '2026-12-26');
SELECT * FROM reservations;