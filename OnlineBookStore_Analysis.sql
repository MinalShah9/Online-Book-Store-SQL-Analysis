-- ============================================================
-- ONLINE BOOK STORE SALES ANALYSIS
-- Database: MySQL
-- Author: Minal Jeevan Shah
-- ============================================================


-- ============================================================
-- 1. DATABASE CREATION
-- ============================================================

CREATE DATABASE IF NOT EXISTS OnlineBookStore;

USE OnlineBookStore;


-- ============================================================
-- 2. DROP TABLES IF THEY ALREADY EXIST
-- ============================================================

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Books;


-- ============================================================
-- 3. CREATE BOOKS TABLE
-- ============================================================

CREATE TABLE Books (
    Book_ID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price DECIMAL(10,2),
    Stock INT
);


-- ============================================================
-- 4. CREATE CUSTOMERS TABLE
-- ============================================================

CREATE TABLE Customers (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(100),
    Country VARCHAR(150)
);


-- ============================================================
-- 5. CREATE ORDERS TABLE
-- ============================================================

CREATE TABLE Orders (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT,
    Book_ID INT,
    Order_Date DATE,
    Quantity INT,
    Total_Amount DECIMAL(10,2),

    FOREIGN KEY (Customer_ID)
        REFERENCES Customers(Customer_ID),

    FOREIGN KEY (Book_ID)
        REFERENCES Books(Book_ID)
);


-- ============================================================
-- 6. IMPORT DATA FROM CSV FILES
-- ============================================================

-- NOTE:
-- Update the file paths according to your computer.
-- These commands are commented out so the SQL file can be
-- viewed on GitHub without exposing your personal file path.

-- Books.csv
-- LOAD DATA LOCAL INFILE 'C:/path/to/Books.csv'
-- INTO TABLE Books
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (Book_ID, Title, Author, Genre, Published_Year, Price, Stock);


-- Customers.csv
-- LOAD DATA LOCAL INFILE 'C:/path/to/Customers.csv'
-- INTO TABLE Customers
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (Customer_ID, Name, Email, Phone, City, Country);


-- Orders.csv
-- LOAD DATA LOCAL INFILE 'C:/path/to/Orders.csv'
-- INTO TABLE Orders
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount);


-- ============================================================
-- 7. VIEW TABLE DATA
-- ============================================================

SELECT * FROM Books;

SELECT * FROM Customers;

SELECT * FROM Orders;


-- ============================================================
--                    BASIC ANALYSIS
-- ============================================================


-- ------------------------------------------------------------
-- Q1. Retrieve all books in the Fiction genre
-- ------------------------------------------------------------

SELECT *
FROM Books
WHERE Genre = 'Fiction';


-- ------------------------------------------------------------
-- Q2. Find books published after the year 1950
-- ------------------------------------------------------------

SELECT *
FROM Books
WHERE Published_Year > 1950;


-- ------------------------------------------------------------
-- Q3. List all customers from Canada
-- ------------------------------------------------------------

SELECT *
FROM Customers
WHERE Country LIKE '%Canada%';


-- ------------------------------------------------------------
-- Q4. Show orders placed in November 2023
-- ------------------------------------------------------------

SELECT *
FROM Orders
WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';


-- ------------------------------------------------------------
-- Q5. Retrieve the total stock of books available
-- ------------------------------------------------------------

SELECT
    SUM(Stock) AS Total_Stock
FROM Books;


-- ------------------------------------------------------------
-- Q6. Find the most expensive book
-- ------------------------------------------------------------

SELECT *
FROM Books
ORDER BY Price DESC
LIMIT 1;


-- ------------------------------------------------------------
-- Q7. Show customers who ordered more than 1 quantity of a book
-- ------------------------------------------------------------

SELECT
    c.Customer_ID,
    c.Name,
    o.Book_ID,
    o.Quantity
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
WHERE o.Quantity > 1;


-- ------------------------------------------------------------
-- Q8. Retrieve all orders where total amount exceeds $20
-- ------------------------------------------------------------

SELECT *
FROM Orders
WHERE Total_Amount > 20;


-- ------------------------------------------------------------
-- Q9. List all available genres
-- ------------------------------------------------------------

SELECT DISTINCT Genre
FROM Books;


-- ------------------------------------------------------------
-- Q10. Find the book(s) with the lowest stock
-- ------------------------------------------------------------

SELECT *
FROM Books
WHERE Stock = (
    SELECT MIN(Stock)
    FROM Books
);


-- ------------------------------------------------------------
-- Q11. Calculate total revenue generated from all orders
-- ------------------------------------------------------------

SELECT
    SUM(Total_Amount) AS Total_Revenue
FROM Orders;



-- ============================================================
--                   ADVANCED ANALYSIS
-- ============================================================


-- ------------------------------------------------------------
-- Q1. Retrieve total number of books sold for each genre
-- ------------------------------------------------------------

SELECT
    b.Genre,
    SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b
    ON o.Book_ID = b.Book_ID
GROUP BY b.Genre
ORDER BY Total_Books_Sold DESC;


-- ------------------------------------------------------------
-- Q2. Find the average price of books in the Fantasy genre
-- ------------------------------------------------------------

SELECT
    AVG(Price) AS Average_Price
FROM Books
WHERE Genre = 'Fantasy';


-- ------------------------------------------------------------
-- Q3. List customers who have placed at least 2 orders
-- ------------------------------------------------------------

SELECT
    c.Customer_ID,
    c.Name,
    COUNT(o.Order_ID) AS Order_Count
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name
HAVING COUNT(o.Order_ID) >= 2
ORDER BY Order_Count DESC;


-- ------------------------------------------------------------
-- Q4. Find the most frequently ordered book
-- ------------------------------------------------------------

SELECT
    o.Book_ID,
    b.Title,
    COUNT(o.Order_ID) AS Order_Count
FROM Orders o
JOIN Books b
    ON o.Book_ID = b.Book_ID
GROUP BY o.Book_ID, b.Title
ORDER BY Order_Count DESC
LIMIT 1;


-- ------------------------------------------------------------
-- Q5. Show the top 3 most expensive Fantasy books
-- ------------------------------------------------------------

SELECT *
FROM Books
WHERE Genre = 'Fantasy'
ORDER BY Price DESC
LIMIT 3;


-- ------------------------------------------------------------
-- Q6. Retrieve total quantity of books sold by each author
-- ------------------------------------------------------------

SELECT
    b.Author,
    SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b
    ON o.Book_ID = b.Book_ID
GROUP BY b.Author
ORDER BY Total_Books_Sold DESC;


-- ------------------------------------------------------------
-- Q7. List cities where customers spent over $30 in total
-- ------------------------------------------------------------

SELECT
    c.City,
    SUM(o.Total_Amount) AS Total_Spent
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.City
HAVING SUM(o.Total_Amount) > 30
ORDER BY Total_Spent DESC;


-- ------------------------------------------------------------
-- Q8. Find the customer who spent the most
-- ------------------------------------------------------------

SELECT
    c.Customer_ID,
    c.Name,
    SUM(o.Total_Amount) AS Total_Spent
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Total_Spent DESC
LIMIT 1;


-- ------------------------------------------------------------
-- Q9. Calculate remaining stock after fulfilling all orders
-- ------------------------------------------------------------

SELECT
    b.Book_ID,
    b.Title,
    b.Stock AS Original_Stock,
    COALESCE(SUM(o.Quantity), 0) AS Ordered_Quantity,
    b.Stock - COALESCE(SUM(o.Quantity), 0) AS Remaining_Stock
FROM Books b
LEFT JOIN Orders o
    ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Stock
ORDER BY b.Book_ID;


-- ============================================================
--                    END OF PROJECT
-- ============================================================