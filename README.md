# Supply Chain & Order Fulfillment SQL Exploration

A data pipeline shouldn't just store orders—it should tell you where the supply chain is bleeding. 

This repository covers an end-to-end SQL data exploration project focused on warehouse logistics, tracking fulfillment bottlenecks, shipment delays, and rolling inventory replenishment.

---

### 🔍 Core SQL Skills Demonstrated
* **Data Cleaning & Type Casting:** Using `CAST` and `CONVERT` to handle messy text fields and numeric aggregations.
* **Relational Joins:** Connecting multi-table shipments and inbound restocks without breaking dataset integrity.
* **Window Functions:** Utilizing `SUM() OVER (PARTITION BY ...)` for running totals and rolling inventory counts.
* **Modular Logic:** Structuring queries with Common Table Expressions (CTEs), Temp Tables (`#`), and permanent `VIEWS` for reporting.

---

### 📊 Dataset Structure
* **`Shipment_Delays`**: Contains order volumes, regional breakdowns, delivery dates, and SLA failure counts.
* **`Warehouse_Restocks`**: Contains inbound stock movements, warehouse locations, and replenishment timelines.

---

### 🛠️ How to Run
1. Download `SupplyChain_Data_Exploration.sql`.
2. Import the source sheets into your SQL Server Management Studio (SSMS) database (`PortfolioProject`).
3. Execute the script sequentially from raw exploratory queries to view creation.

> **Takeaway:** Clean queries don't just return rows—they eliminate operational blind spots.
