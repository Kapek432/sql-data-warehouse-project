# 🏗️ Data Warehouse and Analytics Project

Welcome to my **Data Warehouse and Analytics Project** repository! 🚀
This project showcases my ability to independently design and build a modern data warehousing solution using SQL Server. While I drew inspiration from a [YouTube tutorial by Data With Baraa](https://www.youtube.com/watch?v=9GVqKuTVANE), I have implemented all components myself, including writing SQL scripts, designing the ETL processes, and creating the data models.

---

## 📐 Project Architecture

This project follows the **Medallion Architecture** approach (Bronze, Silver, and Gold layers), a widely used best practice in modern data engineering:

* **Bronze Layer:** Ingests raw data from CSV files into the SQL Server database.
* **Silver Layer:** Performs data cleansing, normalization, and standardization.
* **Gold Layer:** Prepares business-ready data using a **star schema** optimized for analytics.

---

## 📊 Project Scope

### 🔧 Data Engineering

* **Source Data:** ERP and CRM data imported from CSV files
* **ETL Pipelines:** Extract, transform, and load data across the three Medallion layers
* **Data Modeling:** Star schema with fact and dimension tables for reporting
* **Tools Used:**

  * SQL Server Express
  * SQL Server Management Studio (SSMS)
  * Git & GitHub (version control and documentation)

### 📈 Data Analytics

Using SQL queries and transformations, the project delivers insights on:

* Customer behavior
* Product performance
* Sales trends

These insights are designed to support data-driven decisions for business stakeholders.

---

## 🧠 Skills Demonstrated

This project allowed me to gain hands-on experience in:

* Data Warehousing and SQL Development
* ETL Pipeline Creation
* Dimensional Data Modeling
* Data Cleaning and Normalization
* Analytical Query Design

---

## 📁 Project Structure

```
data-warehouse-project/
│
├── datasets/                     # Raw ERP and CRM CSV files
│
├── scripts/                      # SQL scripts by layer
│   ├── bronze/                   # Load raw data
│   ├── silver/                   # Clean and transform
│   ├── gold/                     # Star schema creation
│
├── README.md                     # This file
```

---

## 📝 Final Notes

This project is part of my data engineering portfolio. It demonstrates my ability to apply theoretical knowledge to real-world scenarios using industry-relevant tools and practices.
