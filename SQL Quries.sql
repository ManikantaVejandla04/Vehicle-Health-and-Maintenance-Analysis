use vhms;

-- Q1 - Fleet Count by Fuel Type
SELECT fuel_type,
       COUNT(*) AS total_vehicles,
       ROUND(AVG(odometer_km),0) AS avg_odometer
FROM vehicles
GROUP BY fuel_type
ORDER BY total_vehicles DESC

-- Q2 — Total maintenance cost by service type
SELECT service_type,
       COUNT(*) AS service_count,
       ROUND(SUM(cost_inr),2) AS total_cost,
       ROUND(AVG(cost_inr),2) AS avg_cost
FROM maintenance
GROUP BY service_type
ORDER BY total_cost DESC

-- Q3 — Top 10 most expensive vehicles
SELECT top 10
       m.vehicle_id,
       v.make,
       v.fuel_type,
       COUNT(*) AS services,
       ROUND(SUM(m.cost_inr),2) AS total_cost
FROM maintenance m
JOIN vehicles v ON m.vehicle_id = v.vehicle_id
GROUP BY m.vehicle_id,v.make,v.fuel_type
ORDER BY total_cost DESC

--Q4 — Monthly maintenance cost trend
SELECT TOP 24
       service_year AS yr,
       service_month AS mo,
       month_name,
       COUNT(*) AS services,
       ROUND(SUM(cost_inr),2) AS total_cost
FROM maintenance
GROUP BY service_year,service_month,month_name
ORDER BY yr, mo

--Q5 — Overdue services count per vehicle make
SELECT v.make,
       COUNT(*) AS total_services,
       SUM(CAST(m.overdue_flag AS INT)) AS overdue_count,
       ROUND(100.0*SUM(CAST(m.overdue_flag AS INT))/COUNT(*),1) AS overdue_pct
FROM maintenance m
JOIN vehicles v ON m.vehicle_id = v.vehicle_id
GROUP BY v.make
ORDER BY overdue_pct DESC

--Q6 — Average fuel efficiency by make
SELECT v.make,
       ROUND(AVG(f.km_per_litre),2) AS avg_kmpl,
       COUNT(*) AS fill_ups,
       ROUND(SUM(f.cost_inr),2) AS total_fuel_cost
FROM fuel_logs f
JOIN vehicles  v ON f.vehicle_id = v.vehicle_id
GROUP BY v.make
ORDER BY avg_kmpl DESC

-- Q7 — Alert count by severity
SELECT severity,
       COUNT(*) AS total_alerts,
       SUM(CASE WHEN resolved=0 THEN 1 ELSE 0 END) AS open_alerts,
       SUM(CAST(resolved AS INT)) AS resolved_alerts
FROM alerts
GROUP BY severity
ORDER BY CASE severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 ELSE 3 END

-- Q8 — Driver with most overdue services
SELECT TOP 10
       m.driver_id,
       d.driver_name,
       COUNT(*) AS total_services,
       SUM(CAST(m.overdue_flag AS INT)) AS overdue_count
FROM maintenance m
JOIN drivers d ON m.driver_id = d.driver_id
GROUP BY m.driver_id,d.driver_name
ORDER BY overdue_count DESC

-- Q9 — Vehicles with unresolved HIGH alerts
SELECT a.vehicle_id,
       v.make,
       v.city,
       COUNT(*) AS open_high_alerts
FROM alerts a
JOIN vehicles v ON a.vehicle_id = v.vehicle_id
WHERE a.severity ='HIGH'
AND a.resolved = 0
GROUP BY a.vehicle_id,v.make,v.city
ORDER BY open_high_alerts DESC

-- Q10 — Yearly Maintenance cost comparison
SELECT service_year,
       COUNT(*) AS total_services,
       ROUND(SUM(cost_inr),2) AS total_cost,
       ROUND(AVG(cost_inr),2) AS avg_cost
FROM maintenance
GROUP BY service_year
ORDER BY service_year

--  Q11 — Maintenance Cost by city
SELECT v.city,
       COUNT(*) AS services,
       ROUND(SUM(m.cost_inr),2) AS total_cost,
       ROUND(AVG(m.cost_inr),2) AS avg_cost
FROM maintenance m
JOIN vehicles v ON m.vehicle_id = v.vehicle_id
GROUP BY v.city
ORDER BY total_cost DESC

--Q12 — Fuel cost trend by year
SELECT fill_year,
       COUNT(*) AS fill_ups,
       ROUND(SUM(cost_inr),2) AS total_fuel_cost,
       ROUND(AVG(km_per_litre),2) AS avg_kmpl
FROM fuel_logs
GROUP BY fill_year
ORDER BY fill_year

-- Q13 · Cumulative Cost per Vehicle (Top 15 rows)
SELECT TOP 15
       vehicle_id,
       service_date,
       cost_inr,
       ROUND(SUM(cost_inr) OVER (
           PARTITION BY vehicle_id
           ORDER BY service_date
       ),2) AS cumulative_cost
FROM maintenance
ORDER BY vehicle_id, service_date

-- Q14 · Vehicle Cost Rank
SELECT TOP 10
       vehicle_id,
       ROUND(SUM(cost_inr),2)            AS total_cost,
       RANK() OVER (ORDER BY SUM(cost_inr) DESC) AS cost_rank
FROM maintenance
GROUP BY vehicle_id
ORDER BY cost_rank

-- Q15 · Month-over-Month Cost Change
WITH monthly AS (
    SELECT service_year AS yr,
           service_month AS mo,
           ROUND(SUM(cost_inr),2) AS total_cost
    FROM maintenance
    GROUP BY service_year, service_month
)
SELECT TOP 10
       yr, mo, total_cost,
       LAG(total_cost) OVER (ORDER BY yr, mo) AS prev_month,
       ROUND(total_cost -
             LAG(total_cost) OVER (ORDER BY yr, mo), 2) AS mom_change
FROM monthly
ORDER BY yr, mo

-- Q16 — Vehicles never serviced
SELECT TOP 10
        v.vehicle_id,
        v.make, 
        v.fuel_type,
        v.city
FROM vehicles v
LEFT JOIN maintenance m ON v.vehicle_id = m.vehicle_id
WHERE m.vehicle_id IS NULL

-- Q17 Most common fault codes
SELECT fault_code,
       COUNT(*) AS occurrences,
       SUM(CASE WHEN resolved=0 THEN 1 ELSE 0 END) AS still_open
FROM alerts
WHERE fault_code != 'UNKNOWN'
GROUP BY fault_code
ORDER BY occurrences DESC

-- Q18 · Fuel Efficiency by Fuel Type & Year
SELECT fuel_type,
       fill_year,
       ROUND(AVG(km_per_litre),2) AS avg_kmpl,
       COUNT(*) AS fill_ups
FROM fuel_logs
GROUP BY fuel_type, fill_year
ORDER BY fuel_type, fill_year

-- Q19 · Fleet Health Summary
WITH maint_summary AS (
    SELECT vehicle_id,
           COUNT(*) AS services,
           SUM(CAST(overdue_flag AS INT)) AS overdues,
           SUM(cost_inr) AS total_cost
    FROM maintenance
    GROUP BY vehicle_id
),
alert_summary AS (
    SELECT vehicle_id,
           SUM(CASE WHEN severity='HIGH' AND resolved=0 THEN 1 ELSE 0 END) AS open_high
    FROM alerts
    GROUP BY vehicle_id
)
SELECT TOP 10
       v.vehicle_id, v.make, v.city,
       COALESCE(m.services,0) AS services,
       COALESCE(m.overdues,0) AS overdues,
       COALESCE(a.open_high,0) AS open_high_alerts,
       ROUND(COALESCE(m.total_cost,0),2) AS total_cost
FROM vehicles v
LEFT JOIN maint_summary m ON v.vehicle_id = m.vehicle_id
LEFT JOIN alert_summary a ON v.vehicle_id = a.vehicle_id
ORDER  BY total_cost DESC

-- Q20 · Quarterly Cost Share
SELECT quarter,
       COUNT(*) AS services,
       ROUND(SUM(cost_inr),2) AS total_cost,
       ROUND(100.0 * SUM(cost_inr) /
             (SELECT SUM(cost_inr) FROM maintenance), 1) AS pct_share
FROM maintenance
GROUP BY quarter
ORDER BY quarter

EXEC sp_help drivers;
EXEC sp_help vehicles;

ALTER TABLE vehicles ALTER COLUMN vehicle_id INT;
ALTER TABLE drivers ALTER COLUMN vehicle_id INT;
ALTER TABLE fuel_logs ALTER COLUMN vehicle_id INT;
ALTER TABLE alerts ALTER COLUMN vehicle_id INT;
ALTER TABLE maintenance ALTER COLUMN vehicle_id INT;

ALTER TABLE drivers ALTER COLUMN driver_id INT;
ALTER TABLE maintenance ALTER COLUMN driver_id INT;