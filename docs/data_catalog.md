# Data Catalog — Gold Data Mart

## 1. Overview

| Item | Description |
|---|---|
| Layer | Gold |
| Data Model | Star Schema |
| Fact Table | `gold.fact_sales` |
| Dimension Tables | `gold.dim_customers`, `gold.dim_products` |
| Business Process | Sales |
| Main Calculation | `Sales = Quantity × Price` |

---

# 2. Table: `gold.dim_customers`

## Description

Berisi informasi tentang customer.

## Grain

**1 row = 1 customer**

## Columns

| Column | Type | Key | Description |
|---|---|---|---|
| `customer_key` | BIGINT | PK | Surrogate key untuk customer. |
| `customer_id` | STRING | Business Key | ID customer dari source system. |
| `customer_number` | STRING | - | Nomor customer dari source system. |
| `first_name` | STRING | - | Nama depan customer. |
| `last_name` | STRING | - | Nama belakang customer. |
| `country` | STRING | - | Negara asal customer. |
| `marital_status` | STRING | - | Status pernikahan customer. |
| `gender` | STRING | - | Jenis kelamin customer. |
| `birthdate` | DATE | - | Tanggal lahir customer. |
| `create_date` | TIMESTAMP | - | Waktu record customer dibuat/masuk ke Gold layer. |

---

# 3. Table: `gold.dim_products`

## Description

Berisi informasi tentang product.

## Grain

**1 row = 1 product**

## Columns

| Column | Type | Key | Description |
|---|---|---|---|
| `product_key` | BIGINT | PK | Surrogate key untuk product. |
| `product_id` | STRING | Business Key | ID product dari source system. |
| `product_number` | STRING | - | Nomor product dari source system. |
| `product_name` | STRING | - | Nama product. |
| `category_id` | STRING | - | ID kategori product. |
| `category` | STRING | - | Kategori product. |
| `subcategory` | STRING | - | Subkategori product. |
| `maintenance` | STRING | - | Informasi maintenance product. |
| `cost` | DECIMAL | - | Biaya/cost product. |
| `product_line` | STRING | - | Kelompok atau lini product. |
| `start_date` | DATE | - | Tanggal mulai berlakunya product. |

---

# 4. Table: `gold.fact_sales`

## Description

Berisi data transaksi penjualan.

## Grain

**1 row = 1 sales transaction untuk suatu product dan customer.**

## Columns

| Column | Type | Key | Description |
|---|---|---|---|
| `order_number` | STRING | - | Nomor order/transaksi. |
| `customer_key` | BIGINT | FK | Referensi ke `gold.dim_customers.customer_key`. |
| `product_key` | BIGINT | FK | Referensi ke `gold.dim_products.product_key`. |
| `order_date` | DATE | - | Tanggal order dibuat. |
| `shipping_date` | DATE | - | Tanggal order dikirim. |
| `due_date` | DATE | - | Tanggal jatuh tempo order. |
| `sales_amount` | DECIMAL | Measure | Total nilai penjualan. |
| `quantity` | INT | Measure | Jumlah product yang terjual. |
| `price` | DECIMAL | Measure | Harga product per unit. |

---

# 5. Relationships

| Parent Table | Parent Key | Child Table | Child Key | Relationship |
|---|---|---|---|---|
| `gold.dim_customers` | `customer_key` | `gold.fact_sales` | `customer_key` | 1 : Many |
| `gold.dim_products` | `product_key` | `gold.fact_sales` | `product_key` | 1 : Many |

### Relationship Explanation

| Relationship | Description |
|---|---|
| Customer → Sales | 1 customer dapat memiliki banyak sales transaction. |
| Product → Sales | 1 product dapat muncul di banyak sales transaction. |

---

# 6. Keys

| Table | Key | Type | Description |
|---|---|---|---|
| `gold.dim_customers` | `customer_key` | PK | Unique identifier customer di Data Warehouse. |
| `gold.dim_products` | `product_key` | PK | Unique identifier product di Data Warehouse. |
| `gold.fact_sales` | `customer_key` | FK | Menghubungkan sales dengan customer. |
| `gold.fact_sales` | `product_key` | FK | Menghubungkan sales dengan product. |

---

# 7. Measures

| Measure | Formula | Description |
|---|---|---|
| `sales_amount` | `quantity × price` | Nilai total penjualan. |
| `quantity` | - | Jumlah product yang terjual. |
| `price` | - | Harga product per unit. |
| Total Sales | `SUM(sales_amount)` | Total seluruh penjualan. |
| Total Quantity | `SUM(quantity)` | Total product yang terjual. |
| Average Price | `AVG(price)` | Rata-rata harga product. |

---

# 8. Business Rules

| Rule | Description |
|---|---|
| Sales Calculation | `sales_amount = quantity × price` |
| Customer Reference | `fact_sales.customer_key` harus mengarah ke `dim_customers.customer_key`. |
| Product Reference | `fact_sales.product_key` harus mengarah ke `dim_products.product_key`. |
| Customer Grain | 1 row mewakili 1 customer. |
| Product Grain | 1 row mewakili 1 product. |
| Sales Grain | 1 row mewakili 1 sales transaction pada grain customer-product. |

---

# 9. Data Quality Rules

## `gold.dim_customers`

| Rule | Expected Condition |
|---|---|
| `customer_key` | Tidak boleh NULL. |
| `customer_key` | Harus unique. |
| `birthdate` | Tidak boleh lebih besar dari tanggal hari ini. |
| `country` | Value harus konsisten. |
| `gender` | Value harus konsisten. |

## `gold.dim_products`

| Rule | Expected Condition |
|---|---|
| `product_key` | Tidak boleh NULL. |
| `product_key` | Harus unique. |
| `product_id` | Harus mengikuti format source. |
| `cost` | Tidak boleh negatif, kecuali memang diperbolehkan. |
| `start_date` | Harus berupa tanggal yang valid. |

## `gold.fact_sales`

| Rule | Expected Condition |
|---|---|
| `customer_key` | Harus ditemukan di `dim_customers`. |
| `product_key` | Harus ditemukan di `dim_products`. |
| `quantity` | Biasanya harus > 0. |
| `price` | Harus mengikuti aturan bisnis. |
| `sales_amount` | Harus sesuai dengan `quantity × price`. |
| `shipping_date` | Biasanya tidak boleh lebih awal dari `order_date`. |
| `due_date` | Biasanya tidak boleh lebih awal dari `order_date`. |

---

# 10. Analytical Use Cases

| Analysis | Required Columns |
|---|---|
| Total Sales | `fact_sales.sales_amount` |
| Sales by Customer | `customer_key`, `sales_amount` |
| Sales by Country | `country`, `sales_amount` |
| Sales by Gender | `gender`, `sales_amount` |
| Sales by Product | `product_name`, `sales_amount` |
| Sales by Category | `category`, `sales_amount` |
| Sales by Subcategory | `subcategory`, `sales_amount` |
| Sales by Product Line | `product_line`, `sales_amount` |
| Sales by Order Date | `order_date`, `sales_amount` |
| Total Product Sold | `quantity` |

---

# 11. Star Schema Summary

| Table | Type | Grain | Primary Key |
|---|---|---|---|
| `gold.dim_customers` | Dimension | 1 row per customer | `customer_key` |
| `gold.dim_products` | Dimension | 1 row per product | `product_key` |
| `gold.fact_sales` | Fact | 1 row per sales transaction | - |

## Model

```text
              gold.dim_customers
                     |
                     | 1 : Many
                     |
                     v
              gold.fact_sales
                     ^
                     | Many : 1
                     |
                     |
              gold.dim_products
