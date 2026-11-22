use hotel_booking_db;

DELIMITER //

CREATE PROCEDURE GetAvailableRooms(
    IN p_type_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE
)
BEGIN
    SELECT 
        r.room_id,
        r.room_number,
        rt.type_name,
        rt.base_price
    FROM rooms r
    JOIN room_types rt ON r.type_id = rt.type_id
    WHERE r.type_id = p_type_id
      AND r.status != 'Maintenance'
      AND NOT EXISTS (
          SELECT 1
          FROM reservations res
          WHERE res.room_id = r.room_id
            AND res.booking_status IN ('Confirmed', 'Checked-In')
            AND p_check_in < res.check_out 
            AND p_check_out > res.check_in
      );
END //

DELIMITER ;


    
DELIMITER //

DROP TRIGGER IF EXISTS trg_calculate_booking_total //

CREATE TRIGGER trg_calculate_booking_total
BEFORE INSERT ON reservations
FOR EACH ROW
BEGIN
    DECLARE v_base_price DECIMAL(10, 2);
    DECLARE v_multiplier DECIMAL(3, 2) DEFAULT 1.00;
    DECLARE v_nights INT;

    -- 1. Validate stay duration
    SET v_nights = DATEDIFF(NEW.check_out, NEW.check_in);
    IF v_nights <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Check-out date must be at least one day after check-in date.';
    END IF;

    -- 2. Fetch room base price
    SELECT rt.base_price INTO v_base_price
    FROM rooms r
    JOIN room_types rt ON r.type_id = rt.type_id
    WHERE r.room_id = NEW.room_id;

    -- 3. Fetch seasonal multiplier (defaults to 1.00 if none matches)
    SELECT COALESCE(MAX(price_multiplier), 1.00) INTO v_multiplier
    FROM seasonal_rates
    WHERE NEW.check_in BETWEEN start_date AND end_date;

    -- 4. Calculate total
    SET NEW.total_amount = v_base_price * v_multiplier * v_nights;
END //

DELIMITER ;


