use hotel_booking_db;
SELECT 
    rt.type_name AS room_category,
    COUNT(res.reservation_id) AS total_bookings,
    ROUND(AVG(DATEDIFF(res.check_out, res.check_in)), 1) AS avg_nights_stayed,
    COALESCE(SUM(res.total_amount), 0.00) AS total_revenue
FROM room_types rt
LEFT JOIN rooms r ON rt.type_id = r.type_id
LEFT JOIN reservations res 
    ON r.room_id = res.room_id 
    AND res.booking_status IN ('Confirmed', 'Checked-In', 'Checked-Out')
GROUP BY rt.type_id, rt.type_name
ORDER BY total_revenue DESC;

-- 2. Monthly Revenue Breakdown & Month-over-Month Comparison
SELECT 
    DATE_FORMAT(check_in, '%Y-%m') AS booking_month,
    COUNT(reservation_id) AS completed_bookings,
    SUM(total_amount) AS monthly_revenue,
    LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(check_in, '%Y-%m')) AS previous_month_revenue
FROM reservations
WHERE booking_status != 'Cancelled'
GROUP BY DATE_FORMAT(check_in, '%Y-%m')
ORDER BY booking_month;

-- 3. Top Spending Guests (VIP Customer Leaderboard)
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(res.reservation_id) AS total_stays,
    SUM(DATEDIFF(res.check_out, res.check_in)) AS total_nights,
    SUM(res.total_amount) AS lifetime_spend
FROM customers c
JOIN reservations res ON c.customer_id = res.customer_id
WHERE res.booking_status != 'Cancelled'
GROUP BY c.customer_id, c.full_name, c.email
ORDER BY lifetime_spend DESC
LIMIT 5;

-- 4. Room Utilization & Occupancy Ranking
SELECT 
    r.room_number,
    rt.type_name,
    COUNT(res.reservation_id) AS times_booked,
    COALESCE(SUM(DATEDIFF(res.check_out, res.check_in)), 0) AS total_nights_occupied,
    RANK() OVER (ORDER BY COALESCE(SUM(DATEDIFF(res.check_out, res.check_in)), 0) DESC) AS popularity_rank
FROM rooms r
JOIN room_types rt ON r.type_id = rt.type_id
LEFT JOIN reservations res 
    ON r.room_id = res.room_id 
    AND res.booking_status != 'Cancelled'
GROUP BY r.room_id, r.room_number, rt.type_name;

-- 5. Executive Summary View (Reusable Reporting Layer)
CREATE OR REPLACE VIEW vw_hotel_performance_summary AS
SELECT 
    rt.type_name,
    COUNT(DISTINCT r.room_id) AS total_physical_rooms,
    COUNT(res.reservation_id) AS active_or_past_bookings,
    COALESCE(SUM(res.total_amount), 0.00) AS gross_revenue
FROM room_types rt
LEFT JOIN rooms r ON rt.type_id = r.type_id
LEFT JOIN reservations res 
    ON r.room_id = res.room_id 
    AND res.booking_status != 'Cancelled'
GROUP BY rt.type_id, rt.type_name;

-- Test the View
SELECT * FROM vw_hotel_performance_summary;
