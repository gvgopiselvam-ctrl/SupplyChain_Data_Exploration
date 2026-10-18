/*
Supply Chain & Order Fulfillment Data Exploration
Skills used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- 1. Verify Imported Tables
SELECT *
FROM PortfolioProject..Shipment_Delays
WHERE region IS NOT NULL 
ORDER BY 3, 4;


-- 2. Select Baseline Operational Data
SELECT warehouse_location, order_date, total_orders, new_orders, delayed_shipments, monthly_demand_capacity
FROM PortfolioProject..Shipment_Delays
WHERE region IS NOT NULL 
ORDER BY 1, 2;


-- 3. Total Orders vs Delayed Shipments (SLA Failure Rate %)
-- Shows likelihood of a shipment missing its SLA window at a specific hub
SELECT warehouse_location, order_date, total_orders, delayed_shipments, 
       (delayed_shipments / total_orders) * 100 AS DelayPercentage
FROM PortfolioProject..Shipment_Delays
WHERE warehouse_location LIKE '%Chennai%'
  AND region IS NOT NULL 
ORDER BY 1, 2;


-- 4. Total Orders vs Monthly Demand Capacity (Hub Utilization %)
-- Shows what percentage of total warehouse capacity has been consumed
SELECT warehouse_location, order_date, monthly_demand_capacity, total_orders,  
       (total_orders / monthly_demand_capacity) * 100 AS CapacityUtilizationPercent
FROM PortfolioProject..Shipment_Delays
ORDER BY 1, 2;


-- 5. Hubs with Highest Utilization Rate Compared to Capacity
SELECT warehouse_location, monthly_demand_capacity, 
       MAX(total_orders) AS PeakOrderVolume,  
       MAX((total_orders / monthly_demand_capacity)) * 100 AS MaxCapacityUtilization
FROM PortfolioProject..Shipment_Delays
GROUP BY warehouse_location, monthly_demand_capacity
ORDER BY MaxCapacityUtilization DESC;


-- 6. Hubs with Highest Total Delayed Shipments (Using CAST for Data Type Handling)
SELECT warehouse_location, MAX(CAST(delayed_shipments AS int)) AS TotalDelayedShipments
FROM PortfolioProject..Shipment_Delays
WHERE region IS NOT NULL 
GROUP BY warehouse_location
ORDER BY TotalDelayedShipments DESC;


-- 7. Breaking Metrics Down by Region
-- Showing regions with the highest bottleneck volume
SELECT region, MAX(CAST(delayed_shipments AS int)) AS TotalDelayedShipments
FROM PortfolioProject..Shipment_Delays
WHERE region IS NOT NULL 
GROUP BY region
ORDER BY TotalDelayedShipments DESC;


-- 8. Global Supply Network Numbers (Daily & Overall Rollup)
SELECT SUM(new_orders) AS total_orders, 
       SUM(CAST(new_delays AS int)) AS total_delays, 
       SUM(CAST(new_delays AS int)) / SUM(new_orders) * 100 AS GlobalDelayPercentage
FROM PortfolioProject..Shipment_Delays
WHERE region IS NOT NULL;


-- 9. Total Demand Capacity vs Inbound Restocks (JOIN + Window Function)
-- Shows rolling inventory replenishment across warehouse hubs
SELECT del.region, del.warehouse_location, del.order_date, del.monthly_demand_capacity, res.new_restocks,
       SUM(CONVERT(int, res.new_restocks)) OVER (PARTITION BY del.warehouse_location ORDER BY del.warehouse_location, del.order_date) AS RollingUnitsRestocked
FROM PortfolioProject..Shipment_Delays del
JOIN PortfolioProject..Warehouse_Restocks res
    ON del.warehouse_location = res.warehouse_location
    AND del.order_date = res.order_date
WHERE del.region IS NOT NULL 
ORDER BY 2, 3;


-- 10. Using CTE to Perform Calculation on Partition By in Previous Query
WITH DemandvsRestock (Region, Warehouse_Location, Order_Date, Monthly_Demand_Capacity, New_Restocks, RollingUnitsRestocked)
AS
(
SELECT del.region, del.warehouse_location, del.order_date, del.monthly_demand_capacity, res.new_restocks,
       SUM(CONVERT(int, res.new_restocks)) OVER (PARTITION BY del.warehouse_location ORDER BY del.warehouse_location, del.order_date) AS RollingUnitsRestocked
FROM PortfolioProject..Shipment_Delays del
JOIN PortfolioProject..Warehouse_Restocks res
    ON del.warehouse_location = res.warehouse_location
    AND del.order_date = res.order_date
WHERE del.region IS NOT NULL
)
SELECT *, (RollingUnitsRestocked / Monthly_Demand_Capacity) * 100 AS ReplenishmentCoveragePercent
FROM DemandvsRestock;


-- 11. Using Temp Table to Perform Calculation on Partition By in Previous Query
DROP TABLE IF EXISTS #PercentInventoryReplenished
CREATE TABLE #PercentInventoryReplenished
(
Region nvarchar(255),
Warehouse_Location nvarchar(255),
Order_Date datetime,
Monthly_Demand_Capacity numeric,
New_Restocks numeric,
RollingUnitsRestocked numeric
)

INSERT INTO #PercentInventoryReplenished
SELECT del.region, del.warehouse_location, del.order_date, del.monthly_demand_capacity, res.new_restocks,
       SUM(CONVERT(int, res.new_restocks)) OVER (PARTITION BY del.warehouse_location ORDER BY del.warehouse_location, del.order_date) AS RollingUnitsRestocked
FROM PortfolioProject..Shipment_Delays del
JOIN PortfolioProject..Warehouse_Restocks res
    ON del.warehouse_location = res.warehouse_location
    AND del.order_date = res.order_date;

SELECT *, (RollingUnitsRestocked / Monthly_Demand_Capacity) * 100 AS ReplenishmentCoveragePercent
FROM #PercentInventoryReplenished;


-- 12. Creating View to Store Data for Later Power BI / Tableau Visualizations
CREATE VIEW PercentInventoryReplenished AS
SELECT del.region, del.warehouse_location, del.order_date, del.monthly_demand_capacity, res.new_restocks,
       SUM(CONVERT(int, res.new_restocks)) OVER (PARTITION BY del.warehouse_location ORDER BY del.warehouse_location, del.order_date) AS RollingUnitsRestocked
FROM PortfolioProject..Shipment_Delays del
JOIN PortfolioProject..Warehouse_Restocks res
    ON del.warehouse_location = res.warehouse_location
    AND del.order_date = res.order_date
WHERE del.region IS NOT NULL;
