Завдання 1-2
-- Створення таблиці типів палива
CREATE TABLE FuelTypes (
    FuelTypeID INT PRIMARY KEY IDENTITY(1,1),
    FuelName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200),
    CurrentPrice DECIMAL(10,2) NOT NULL
);

-- Створення таблиці паливних резервуарів
CREATE TABLE FuelTanks (
    TankID INT PRIMARY KEY IDENTITY(1,1),
    FuelTypeID INT FOREIGN KEY REFERENCES FuelTypes(FuelTypeID),
    Capacity DECIMAL(10,2) NOT NULL, -- в літрах
    CurrentVolume DECIMAL(10,2) NOT NULL,
    LastRefillDate DATETIME,
    MinimumLevel DECIMAL(10,2) -- мінімальний рівень для сповіщення
);

-- Створення таблиці паливних колонок
CREATE TABLE FuelDispensers (
    DispenserID INT PRIMARY KEY IDENTITY(1,1),
    Location NVARCHAR(50), -- розташування на АЗС
    Status NVARCHAR(20) CHECK (Status IN ('Active', 'Maintenance', 'OutOfOrder')),
    LastMaintenanceDate DATETIME
);

-- Зв'язок між колонками та типами палива
CREATE TABLE DispenserFuelTypes (
    DispenserID INT FOREIGN KEY REFERENCES FuelDispensers(DispenserID),
    FuelTypeID INT FOREIGN KEY REFERENCES FuelTypes(FuelTypeID),
    PRIMARY KEY (DispenserID, FuelTypeID)
);

-- Створення таблиці клієнтів
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Phone VARCHAR(20),
    Email VARCHAR(100) UNIQUE,
    LoyaltyCardNumber VARCHAR(20) UNIQUE,
    RegistrationDate DATETIME DEFAULT GETDATE()
);

-- Створення таблиці працівників
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Position NVARCHAR(50),
    HireDate DATE,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Status VARCHAR(20) CHECK (Status IN ('Active', 'OnLeave', 'Terminated'))
);

-- Створення таблиці змін
CREATE TABLE Shifts (
    ShiftID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    ShiftStart DATETIME NOT NULL,
    ShiftEnd DATETIME,
    CashBalance DECIMAL(10,2)
);

-- Створення таблиці транзакцій заправки
CREATE TABLE FuelingTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    DispenserID INT FOREIGN KEY REFERENCES FuelDispensers(DispenserID),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    FuelTypeID INT FOREIGN KEY REFERENCES FuelTypes(FuelTypeID),
    ShiftID INT FOREIGN KEY REFERENCES Shifts(ShiftID),
    Volume DECIMAL(10,2) NOT NULL,
    PricePerLiter DECIMAL(10,2) NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    TransactionDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(20) CHECK (PaymentMethod IN ('Cash', 'Card', 'LoyaltyPoints'))
);

-- Створення таблиці поставок палива
CREATE TABLE FuelDeliveries (
    DeliveryID INT PRIMARY KEY IDENTITY(1,1),
    TankID INT FOREIGN KEY REFERENCES FuelTanks(TankID),
    DeliveryDate DATETIME NOT NULL,
    Volume DECIMAL(10,2) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    SupplierName NVARCHAR(100),
    InvoiceNumber VARCHAR(50)
);

-- Створення таблиці магазину при АЗС
CREATE TABLE StoreItems (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    ItemName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50),
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL,
    MinimumQuantity INT -- мінімальна кількість для поповнення
);

-- Створення таблиці продажів магазину
CREATE TABLE StoreSales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    ShiftID INT FOREIGN KEY REFERENCES Shifts(ShiftID),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    TransactionDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(20)
);

-- Деталі продажів магазину
CREATE TABLE StoreSaleDetails (
    SaleID INT FOREIGN KEY REFERENCES StoreSales(SaleID),
    ItemID INT FOREIGN KEY REFERENCES StoreItems(ItemID),
    Quantity INT NOT NULL,
    PricePerUnit DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (SaleID, ItemID)
);

-- Створення таблиці технічного обслуговування
CREATE TABLE Maintenance (
    MaintenanceID INT PRIMARY KEY IDENTITY(1,1),
    DispenserID INT FOREIGN KEY REFERENCES FuelDispensers(DispenserID),
    MaintenanceDate DATETIME NOT NULL,
    Description NVARCHAR(MAX),
    Cost DECIMAL(10,2),
    PerformedBy NVARCHAR(100),
    NextMaintenanceDate DATETIME
);

-- Створення індексів для оптимізації
CREATE INDEX IX_FuelingTransactions_Date ON FuelingTransactions(TransactionDate);
CREATE INDEX IX_FuelingTransactions_Customer ON FuelingTransactions(CustomerID);
CREATE INDEX IX_StoreSales_Date ON StoreSales(TransactionDate);
CREATE INDEX IX_Customers_LoyaltyCard ON Customers(LoyaltyCardNumber);
Завдання 3 
-- Очищення існуючих даних (якщо потрібно)
DELETE FROM Maintenance;
DELETE FROM StoreSaleDetails;
DELETE FROM StoreSales;
DELETE FROM FuelingTransactions;
DELETE FROM DispenserFuelTypes;
DELETE FROM FuelDeliveries;
DELETE FROM Shifts;
DELETE FROM Employees;
DELETE FROM Customers;
DELETE FROM FuelDispensers;
DELETE FROM FuelTanks;
DELETE FROM FuelTypes;
DELETE FROM StoreItems;

-- Додавання типів палива
INSERT INTO FuelTypes (FuelName, Description, CurrentPrice) VALUES
('95 Euro', 'Бензин А-95 European', 54.99),
('92', 'Бензин А-92 Стандарт', 52.99),
('ДП', 'Дизельне паливо', 56.99),
('95', 'Бензин А-95 Стандарт', 53.99),
('ГАЗ', 'Газ автомобільний', 32.99);

-- Додавання паливних резервуарів
INSERT INTO FuelTanks (FuelTypeID, Capacity, CurrentVolume, LastRefillDate, MinimumLevel) VALUES
(1, 20000, 15000, DATEADD(day, -1, GETDATE()), 3000),
(2, 15000, 10000, DATEADD(day, -2, GETDATE()), 2000),
(3, 25000, 20000, DATEADD(day, -1, GETDATE()), 4000),
(4, 20000, 16000, DATEADD(day, -3, GETDATE()), 3000),
(5, 10000, 7000, DATEADD(day, -2, GETDATE()), 1500);

-- Додавання паливних колонок
INSERT INTO FuelDispensers (Location, Status, LastMaintenanceDate) VALUES
('Колонка 1', 'Active', DATEADD(month, -1, GETDATE())),
('Колонка 2', 'Active', DATEADD(month, -1, GETDATE())),
('Колонка 3', 'Active', DATEADD(month, -2, GETDATE())),
('Колонка 4', 'Maintenance', GETDATE());

-- Зв'язування колонок з типами палива
INSERT INTO DispenserFuelTypes VALUES
(1, 1), (1, 2), (1, 3), -- Перша колонка: 95 Euro, 92, ДП
(2, 2), (2, 3), (2, 4), -- Друга колонка: 92, ДП, 95
(3, 1), (3, 4), (3, 5), -- Третя колонка: 95 Euro, 95, ГАЗ
(4, 3), (4, 5);         -- Четверта колонка: ДП, ГАЗ

-- Додавання працівників
INSERT INTO Employees (FirstName, LastName, Position, HireDate, Phone, Email, Status) VALUES
('Марія', 'Коваленко', 'Старший оператор', '2022-01-15', '+380671234567', 'maria@station.com', 'Active'),
('Петро', 'Іваненко', 'Оператор АЗС', '2022-03-20', '+380672234567', 'petro@station.com', 'Active'),
('Олена', 'Сидоренко', 'Оператор АЗС', '2022-06-10', '+380673234567', 'olena@station.com', 'Active'),
('Андрій', 'Мельник', 'Механік', '2022-02-01', '+380674234567', 'andriy@station.com', 'Active');

-- Додавання клієнтів
INSERT INTO Customers (FirstName, LastName, Phone, Email, LoyaltyCardNumber, RegistrationDate) VALUES
('Іван', 'Петренко', '+380501234567', 'ivan@email.com', 'LC001', DATEADD(month, -6, GETDATE())),
('Олександра', 'Василенко', '+380502234567', 'oleks@email.com', 'LC002', DATEADD(month, -5, GETDATE())),
('Михайло', 'Григоренко', '+380503234567', 'mikh@email.com', 'LC003', DATEADD(month, -4, GETDATE())),
('Тетяна', 'Шевченко', '+380504234567', 'tanya@email.com', 'LC004', DATEADD(month, -3, GETDATE())),
('Василь', 'Борисенко', '+380505234567', 'vasyl@email.com', 'LC005', DATEADD(month, -2, GETDATE()));

-- Додавання товарів магазину
INSERT INTO StoreItems (ItemName, Category, Price, StockQuantity, MinimumQuantity) VALUES
('Кава американо', 'Напої', 25.00, 100, 20),
('Хот-дог класичний', 'Фаст-фуд', 55.00, 50, 10),
('Моторне масло 5W-40 1л', 'Автотовари', 350.00, 30, 5),
('Вода мінеральна 0.5л', 'Напої', 15.00, 150, 30),
('Батончик енергетичний', 'Снеки', 22.00, 80, 15),
('Серветки автомобільні', 'Автотовари', 45.00, 60, 10),
('Рідина омивача 5л', 'Автотовари', 220.00, 40, 8);

-- Додавання змін
INSERT INTO Shifts (EmployeeID, ShiftStart, ShiftEnd, CashBalance) VALUES
(1, DATEADD(day, -1, GETDATE()), DATEADD(hour, 12, DATEADD(day, -1, GETDATE())), 15000),
(2, DATEADD(hour, 12, DATEADD(day, -1, GETDATE())), GETDATE(), 12000),
(3, GETDATE(), NULL, 0);

-- Додавання транзакцій заправки
INSERT INTO FuelingTransactions 
(DispenserID, CustomerID, FuelTypeID, ShiftID, Volume, PricePerLiter, TotalAmount, PaymentMethod) VALUES
(1, 1, 1, 1, 40.5, 54.99, 2227.095, 'Card'),
(2, 2, 3, 1, 35.0, 56.99, 1994.65, 'Cash'),
(3, 3, 5, 2, 25.0, 32.99, 824.75, 'Card'),
(1, 4, 2, 2, 30.0, 52.99, 1589.70, 'LoyaltyPoints');

-- Додавання продажів магазину
INSERT INTO StoreSales (ShiftID, CustomerID, TransactionDate, TotalAmount, PaymentMethod) VALUES
(1, 1, DATEADD(hour, -3, GETDATE()), 80.00, 'Cash'),
(1, 2, DATEADD(hour, -2, GETDATE()), 395.00, 'Card'),
(2, 3, DATEADD(hour, -1, GETDATE()), 270.00, 'Card');

-- Додавання деталей продажів
INSERT INTO StoreSaleDetails (SaleID, ItemID, Quantity, PricePerUnit) VALUES
(1, 1, 2, 25.00),  -- 2 кави
(1, 4, 2, 15.00),  -- 2 води
(2, 3, 1, 350.00), -- моторне масло
(2, 6, 1, 45.00),  -- серветки
(3, 2, 2, 55.00),  -- 2 хот-доги
(3, 5, 2, 22.00),  -- 2 батончики
(3, 4, 2, 15.00);  -- 2 води

-- Додавання записів про техобслуговування
INSERT INTO Maintenance (DispenserID, MaintenanceDate, Description, Cost, PerformedBy, NextMaintenanceDate) VALUES
(1, DATEADD(month, -1, GETDATE()), 'Планове ТО', 1500.00, 'СервісМайстер', DATEADD(month, 2, GETDATE())),
(2, DATEADD(month, -1, GETDATE()), 'Планове ТО', 1500.00, 'СервісМайстер', DATEADD(month, 2, GETDATE())),
(4, GETDATE(), 'Ремонт насосу', 3500.00, 'СервісМайстер', DATEADD(month, 3, GETDATE()));

-- Додавання поставок палива
INSERT INTO FuelDeliveries (TankID, DeliveryDate, Volume, UnitPrice, SupplierName, InvoiceNumber) VALUES
(1, DATEADD(day, -1, GETDATE()), 5000, 45.00, 'НафтаПостач', 'INV-001'),
(2, DATEADD(day, -2, GETDATE()), 4000, 43.00, 'НафтаПостач', 'INV-002'),
(3, DATEADD(day, -1, GETDATE()), 6000, 47.00, 'НафтаПостач', 'INV-003'),
(4, DATEADD(day, -3, GETDATE()), 5000, 44.00, 'НафтаПостач', 'INV-004'),
(5, DATEADD(day, -2, GETDATE()), 3000, 25.00, 'ГазПостач', 'INV-005');
Завдання 4 
-- 1. Аналіз продажів палива по кожній колонці за останній місяць
SELECT 
    fd.Location as DispenserLocation,
    ft.FuelName,
    COUNT(*) as TransactionsCount,
    SUM(ft2.Volume) as TotalVolume,
    SUM(ft2.TotalAmount) as TotalRevenue,
    AVG(ft2.Volume) as AverageVolume
FROM FuelDispensers fd
JOIN DispenserFuelTypes dft ON fd.DispenserID = dft.DispenserID
JOIN FuelTypes ft ON dft.FuelTypeID = ft.FuelTypeID
LEFT JOIN FuelingTransactions ft2 ON fd.DispenserID = ft2.DispenserID 
    AND ft2.FuelTypeID = ft.FuelTypeID
    AND ft2.TransactionDate >= DATEADD(month, -1, GETDATE())
GROUP BY fd.Location, ft.FuelName
ORDER BY fd.Location, TotalRevenue DESC;

-- 2. Аналіз роботи працівників: продажі палива та магазину по змінах
SELECT 
    e.FirstName + ' ' + e.LastName as EmployeeName,
    s.ShiftStart,
    s.ShiftEnd,
    COUNT(DISTINCT ft.TransactionID) as FuelTransactions,
    SUM(ft.TotalAmount) as FuelRevenue,
    COUNT(DISTINCT ss.SaleID) as StoreTransactions,
    SUM(ss.TotalAmount) as StoreRevenue,
    (SUM(ft.TotalAmount) + ISNULL(SUM(ss.TotalAmount), 0)) as TotalRevenue
FROM Shifts s
JOIN Employees e ON s.EmployeeID = e.EmployeeID
LEFT JOIN FuelingTransactions ft ON s.ShiftID = ft.ShiftID
LEFT JOIN StoreSales ss ON s.ShiftID = ss.ShiftID
GROUP BY e.FirstName, e.LastName, s.ShiftStart, s.ShiftEnd
ORDER BY s.ShiftStart DESC;

-- 3. Аналіз залишків палива та необхідності поповнення
SELECT 
    ft.FuelName,
    tank.Capacity,
    tank.CurrentVolume,
    tank.MinimumLevel,
    CASE 
        WHEN tank.CurrentVolume <= tank.MinimumLevel THEN 'Терміново'
        WHEN tank.CurrentVolume <= tank.MinimumLevel * 1.5 THEN 'Скоро потрібно'
        ELSE 'Достатньо'
    END as RefillStatus,
    (SELECT TOP 1 fd.DeliveryDate 
     FROM FuelDeliveries fd 
     WHERE fd.TankID = tank.TankID 
     ORDER BY fd.DeliveryDate DESC) as LastDeliveryDate,
    (SELECT SUM(Volume) 
     FROM FuelingTransactions ft2 
     WHERE ft2.FuelTypeID = tank.FuelTypeID 
     AND ft2.TransactionDate >= DATEADD(day, -7, GETDATE())) as WeeklyConsumption
FROM FuelTanks tank
JOIN FuelTypes ft ON tank.FuelTypeID = ft.FuelTypeID
ORDER BY RefillStatus, ft.FuelName;

-- 4. Аналіз активності клієнтів та їх покупок
SELECT 
    c.FirstName + ' ' + c.LastName as CustomerName,
    c.LoyaltyCardNumber,
    COUNT(DISTINCT ft.TransactionID) as FuelTransactions,
    SUM(ft.Volume) as TotalFuelVolume,
    SUM(ft.TotalAmount) as TotalFuelAmount,
    COUNT(DISTINCT ss.SaleID) as StoreTransactions,
    SUM(ss.TotalAmount) as TotalStoreAmount,
    SUM(ft.TotalAmount) + ISNULL(SUM(ss.TotalAmount), 0) as TotalSpent,
    MAX(CASE 
        WHEN ft.TransactionDate > ISNULL(ss.TransactionDate, '1900-01-01') 
        THEN ft.TransactionDate 
        ELSE ss.TransactionDate 
    END) as LastVisit
FROM Customers c
LEFT JOIN FuelingTransactions ft ON c.CustomerID = ft.CustomerID
LEFT JOIN StoreSales ss ON c.CustomerID = ss.CustomerID
GROUP BY c.FirstName, c.LastName, c.LoyaltyCardNumber
ORDER BY TotalSpent DESC;

-- 5. Аналіз популярності товарів магазину та їх зв'язок з продажами палива
WITH CustomerPurchases AS (
    SELECT 
        ss.CustomerID,
        ssd.ItemID,
        ft.TransactionID as FuelTransactionID
    FROM StoreSales ss
    JOIN StoreSaleDetails ssd ON ss.SaleID = ssd.SaleID
    LEFT JOIN FuelingTransactions ft ON ss.CustomerID = ft.CustomerID 
        AND ss.TransactionDate BETWEEN DATEADD(minute, -30, ft.TransactionDate) 
        AND DATEADD(minute, 30, ft.TransactionDate)
)
SELECT 
    si.ItemName,
    si.Category,
    COUNT(DISTINCT cp.CustomerID) as UniqueCustomers,
    SUM(ssd.Quantity) as TotalQuantitySold,
    SUM(ssd.Quantity * ssd.PricePerUnit) as TotalRevenue,
    COUNT(cp.FuelTransactionID) as PurchasesWithFuel,
    CAST(COUNT(cp.FuelTransactionID) * 100.0 / COUNT(*) as DECIMAL(10,2)) as PercentWithFuel,
    si.StockQuantity as CurrentStock,
    CASE 
        WHEN si.StockQuantity <= si.MinimumQuantity THEN 'Потрібне поповнення'
        ELSE 'Достатньо'
    END as StockStatus
FROM StoreItems si
LEFT JOIN StoreSaleDetails ssd ON si.ItemID = ssd.ItemID
LEFT JOIN CustomerPurchases cp ON si.ItemID = cp.ItemID
GROUP BY si.ItemName, si.Category, si.StockQuantity, si.MinimumQuantity
ORDER BY TotalRevenue DESC;

-- 6. Аналіз технічного стану колонок та їх ефективності
SELECT 
    fd.Location,
    fd.Status,
    fd.LastMaintenanceDate,
    m.Description as LastMaintenanceDescription,
    m.Cost as LastMaintenanceCost,
    m.NextMaintenanceDate,
    COUNT(ft.TransactionID) as TransactionsSinceLastMaintenance,
    SUM(ft.Volume) as VolumeDispensed,
    SUM(ft.TotalAmount) as RevenueGenerated,
    STRING_AGG(DISTINCT ftype.FuelName, ', ') as AvailableFuels
FROM FuelDispensers fd
LEFT JOIN Maintenance m ON fd.DispenserID = m.DispenserID
LEFT JOIN FuelingTransactions ft ON fd.DispenserID = ft.DispenserID 
    AND ft.TransactionDate > fd.LastMaintenanceDate
JOIN DispenserFuelTypes dft ON fd.DispenserID = dft.DispenserID
JOIN FuelTypes ftype ON dft.FuelTypeID = ftype.FuelTypeID
GROUP BY 
    fd.Location, 
    fd.Status, 
    fd.LastMaintenanceDate,
    m.Description,
    m.Cost,
    m.NextMaintenanceDate
ORDER BY fd.Location;
Завдання 5 
-- 1. Представлення для аналізу продажів палива
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_FuelSalesAnalysis')
    DROP VIEW vw_FuelSalesAnalysis;
GO

CREATE VIEW vw_FuelSalesAnalysis AS
SELECT 
    ft.TransactionDate,
    fd.Location AS DispenserLocation,
    ftype.FuelName,
    ft.Volume,
    ft.PricePerLiter,
    ft.TotalAmount,
    ft.PaymentMethod,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.LoyaltyCardNumber,
    e.FirstName + ' ' + e.LastName AS EmployeeName
FROM FuelingTransactions ft
JOIN FuelDispensers fd ON ft.DispenserID = fd.DispenserID
JOIN FuelTypes ftype ON ft.FuelTypeID = ftype.FuelTypeID
LEFT JOIN Customers c ON ft.CustomerID = c.CustomerID
JOIN Shifts s ON ft.ShiftID = s.ShiftID
JOIN Employees e ON s.EmployeeID = e.EmployeeID;
GO

-- 2. Представлення для моніторингу стану паливних резервуарів
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_FuelTankStatus')
    DROP VIEW vw_FuelTankStatus;
GO

CREATE VIEW vw_FuelTankStatus AS
SELECT 
    ft.TankID,
    ftype.FuelName,
    ft.Capacity,
    ft.CurrentVolume,
    ft.MinimumLevel,
    CAST((ft.CurrentVolume * 100.0 / ft.Capacity) AS DECIMAL(5,2)) AS FillPercentage,
    CASE 
        WHEN ft.CurrentVolume <= ft.MinimumLevel THEN 'Критичний'
        WHEN ft.CurrentVolume <= ft.MinimumLevel * 1.5 THEN 'Низький'
        ELSE 'Нормальний'
    END AS StockStatus,
    ft.LastRefillDate,
    ftype.CurrentPrice
FROM FuelTanks ft
JOIN FuelTypes ftype ON ft.FuelTypeID = ftype.FuelTypeID;
GO

-- 3. Представлення для аналізу продажів магазину
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_StoreSalesAnalysis')
    DROP VIEW vw_StoreSalesAnalysis;
GO

CREATE VIEW vw_StoreSalesAnalysis AS
SELECT 
    ss.TransactionDate,
    si.ItemName,
    si.Category,
    ssd.Quantity,
    ssd.PricePerUnit,
    (ssd.Quantity * ssd.PricePerUnit) AS TotalAmount,
    ss.PaymentMethod,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    e.FirstName + ' ' + e.LastName AS EmployeeName
FROM StoreSales ss
JOIN StoreSaleDetails ssd ON ss.SaleID = ssd.SaleID
JOIN StoreItems si ON ssd.ItemID = si.ItemID
LEFT JOIN Customers c ON ss.CustomerID = c.CustomerID
JOIN Shifts s ON ss.ShiftID = s.ShiftID
JOIN Employees e ON s.EmployeeID = e.EmployeeID;
GO

-- 4. Представлення для аналізу роботи працівників
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_EmployeePerformance')
    DROP VIEW vw_EmployeePerformance;
GO

CREATE VIEW vw_EmployeePerformance AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    s.ShiftStart,
    s.ShiftEnd,
    s.CashBalance,
    COUNT(DISTINCT ft.TransactionID) AS FuelTransactions,
    SUM(ft.TotalAmount) AS FuelSalesAmount,
    COUNT(DISTINCT ss.SaleID) AS StoreTransactions,
    SUM(ss.TotalAmount) AS StoreSalesAmount,
    (SUM(ft.TotalAmount) + ISNULL(SUM(ss.TotalAmount), 0)) AS TotalSalesAmount
FROM Employees e
JOIN Shifts s ON e.EmployeeID = s.EmployeeID
LEFT JOIN FuelingTransactions ft ON s.ShiftID = ft.ShiftID
LEFT JOIN StoreSales ss ON s.ShiftID = ss.ShiftID
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName, 
    s.ShiftStart, s.ShiftEnd, s.CashBalance;
GO

-- 5. Представлення для аналізу технічного стану обладнання
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_DispenserMaintenance')
    DROP VIEW vw_DispenserMaintenance;
GO

CREATE VIEW vw_DispenserMaintenance AS
SELECT 
    fd.DispenserID,
    fd.Location,
    fd.Status,
    m.MaintenanceDate,
    m.Description AS MaintenanceDescription,
    m.Cost AS MaintenanceCost,
    m.NextMaintenanceDate,
    m.PerformedBy,
    STRING_AGG(ft.FuelName, ', ') AS AvailableFuels
FROM FuelDispensers fd
LEFT JOIN Maintenance m ON fd.DispenserID = m.DispenserID
JOIN DispenserFuelTypes dft ON fd.DispenserID = dft.DispenserID
JOIN FuelTypes ft ON dft.FuelTypeID = ft.FuelTypeID
GROUP BY 
    fd.DispenserID, fd.Location, fd.Status, 
    m.MaintenanceDate, m.Description, m.Cost, 
    m.NextMaintenanceDate, m.PerformedBy;
GO

-- 6. Представлення для аналізу активності клієнтів
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CustomerActivity')
    DROP VIEW vw_CustomerActivity;
GO

CREATE VIEW vw_CustomerActivity AS
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.LoyaltyCardNumber,
    COUNT(DISTINCT ft.TransactionID) AS FuelTransactions,
    SUM(ft.Volume) AS TotalFuelVolume,
    SUM(ft.TotalAmount) AS TotalFuelAmount,
    COUNT(DISTINCT ss.SaleID) AS StoreTransactions,
    SUM(ss.TotalAmount) AS TotalStoreAmount,
    MAX(
        CASE 
            WHEN ft.TransactionDate > ISNULL(ss.TransactionDate, '1900-01-01') 
            THEN ft.TransactionDate 
            ELSE ss.TransactionDate 
        END
    ) AS LastVisit
FROM Customers c
LEFT JOIN FuelingTransactions ft ON c.CustomerID = ft.CustomerID
LEFT JOIN StoreSales ss ON c.CustomerID = ss.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.LoyaltyCardNumber;
GO
Завдання 6 
-- 1. Перетворення таблиці FuelTypes на історичну
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('FuelTypes') AND name = 'ValidFrom')
BEGIN
    ALTER TABLE FuelTypes ADD
        ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
            CONSTRAINT DF_FuelTypes_ValidFrom DEFAULT SYSUTCDATETIME(),
        ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
            CONSTRAINT DF_FuelTypes_ValidTo DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
        PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FuelTypes_History')
BEGIN
    ALTER TABLE FuelTypes
        SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.FuelTypes_History));
END;
GO

-- 2. Перетворення таблиці StoreItems на історичну
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('StoreItems') AND name = 'ValidFrom')
BEGIN
    ALTER TABLE StoreItems ADD
        ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
            CONSTRAINT DF_StoreItems_ValidFrom DEFAULT SYSUTCDATETIME(),
        ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
            CONSTRAINT DF_StoreItems_ValidTo DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
        PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'StoreItems_History')
BEGIN
    ALTER TABLE StoreItems
        SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.StoreItems_History));
END;
GO

-- 3. Перетворення таблиці Employees на історичну
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'ValidFrom')
BEGIN
    ALTER TABLE Employees ADD
        ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
            CONSTRAINT DF_Employees_ValidFrom DEFAULT SYSUTCDATETIME(),
        ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
            CONSTRAINT DF_Employees_ValidTo DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
        PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employees_History')
BEGIN
    ALTER TABLE Employees
        SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Employees_History));
END;
GO
Завдання 7 
-- Stored procedure for FuelTypes
CREATE OR ALTER PROCEDURE sp_GetFuelTypes
    @FuelTypeID INT = NULL,
    @FuelName NVARCHAR(50) = NULL,
    @PageSize INT = 10,
    @PageNumber INT = 1,
    @SortColumn VARCHAR(50) = 'FuelTypeID', -- 'FuelName', 'CurrentPrice'
    @SortDirection BIT = 0  -- 0-ASC, 1-DESC
AS
BEGIN
    IF @FuelTypeID IS NOT NULL AND NOT EXISTS (
        SELECT * FROM FuelTypes WHERE FuelTypeID = @FuelTypeID
    )
    BEGIN
        RAISERROR('Invalid FuelTypeID provided', 16, 1)
        RETURN
    END

    SELECT *
    FROM FuelTypes
    WHERE (@FuelTypeID IS NULL OR FuelTypeID = @FuelTypeID)
        AND (@FuelName IS NULL OR FuelName LIKE @FuelName + '%')
    ORDER BY
        CASE WHEN @SortDirection = 0 THEN
            CASE @SortColumn 
                WHEN 'FuelTypeID' THEN CAST(FuelTypeID AS VARCHAR(50))
                WHEN 'FuelName' THEN FuelName
                WHEN 'CurrentPrice' THEN CAST(CurrentPrice AS VARCHAR(50))
            END
        END ASC,
        CASE WHEN @SortDirection = 1 THEN
            CASE @SortColumn 
                WHEN 'FuelTypeID' THEN CAST(FuelTypeID AS VARCHAR(50))
                WHEN 'FuelName' THEN FuelName
                WHEN 'CurrentPrice' THEN CAST(CurrentPrice AS VARCHAR(50))
            END
        END DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- Stored procedure for Employees
CREATE OR ALTER PROCEDURE sp_GetEmployees
    @EmployeeID INT = NULL,
    @Name NVARCHAR(50) = NULL,
    @Position NVARCHAR(50) = NULL,
    @Status VARCHAR(20) = NULL,
    @PageSize INT = 10,
    @PageNumber INT = 1,
    @SortColumn VARCHAR(50) = 'EmployeeID', -- 'LastName', 'Position', 'Status'
    @SortDirection BIT = 0  -- 0-ASC, 1-DESC
AS
BEGIN
    IF @EmployeeID IS NOT NULL AND NOT EXISTS (
        SELECT * FROM Employees WHERE EmployeeID = @EmployeeID
    )
    BEGIN
        RAISERROR('Invalid EmployeeID provided', 16, 1)
        RETURN
    END

    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Position,
        HireDate,
        Phone,
        Email,
        Status
    FROM Employees
    WHERE (@EmployeeID IS NULL OR EmployeeID = @EmployeeID)
        AND (@Name IS NULL OR (FirstName LIKE @Name + '%' OR LastName LIKE @Name + '%'))
        AND (@Position IS NULL OR Position = @Position)
        AND (@Status IS NULL OR Status = @Status)
    ORDER BY
        CASE WHEN @SortDirection = 0 THEN
            CASE @SortColumn 
                WHEN 'EmployeeID' THEN CAST(EmployeeID AS VARCHAR(50))
                WHEN 'LastName' THEN LastName
                WHEN 'Position' THEN Position
                WHEN 'Status' THEN Status
            END
        END ASC,
        CASE WHEN @SortDirection = 1 THEN
            CASE @SortColumn 
                WHEN 'EmployeeID' THEN CAST(EmployeeID AS VARCHAR(50))
                WHEN 'LastName' THEN LastName
                WHEN 'Position' THEN Position
                WHEN 'Status' THEN Status
            END
        END DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- Stored procedure for StoreItems
CREATE OR ALTER PROCEDURE sp_GetStoreItems
    @ItemID INT = NULL,
    @ItemName NVARCHAR(100) = NULL,
    @Category NVARCHAR(50) = NULL,
    @MinPrice DECIMAL(10,2) = NULL,
    @MaxPrice DECIMAL(10,2) = NULL,
    @PageSize INT = 10,
    @PageNumber INT = 1,
    @SortColumn VARCHAR(50) = 'ItemID', -- 'ItemName', 'Category', 'Price', 'StockQuantity'
    @SortDirection BIT = 0  -- 0-ASC, 1-DESC
AS
BEGIN
    IF @ItemID IS NOT NULL AND NOT EXISTS (
        SELECT * FROM StoreItems WHERE ItemID = @ItemID
    )
    BEGIN
        RAISERROR('Invalid ItemID provided', 16, 1)
        RETURN
    END

    SELECT *
    FROM StoreItems
    WHERE (@ItemID IS NULL OR ItemID = @ItemID)
        AND (@ItemName IS NULL OR ItemName LIKE @ItemName + '%')
        AND (@Category IS NULL OR Category = @Category)
        AND (@MinPrice IS NULL OR Price >= @MinPrice)
        AND (@MaxPrice IS NULL OR Price <= @MaxPrice)
    ORDER BY
        CASE WHEN @SortDirection = 0 THEN
            CASE @SortColumn 
                WHEN 'ItemID' THEN CAST(ItemID AS VARCHAR(50))
                WHEN 'ItemName' THEN ItemName
                WHEN 'Category' THEN Category
                WHEN 'Price' THEN CAST(Price AS VARCHAR(50))
                WHEN 'StockQuantity' THEN CAST(StockQuantity AS VARCHAR(50))
            END
        END ASC,
        CASE WHEN @SortDirection = 1 THEN
            CASE @SortColumn 
                WHEN 'ItemID' THEN CAST(ItemID AS VARCHAR(50))
                WHEN 'ItemName' THEN ItemName
                WHEN 'Category' THEN Category
                WHEN 'Price' THEN CAST(Price AS VARCHAR(50))
                WHEN 'StockQuantity' THEN CAST(StockQuantity AS VARCHAR(50))
            END
        END DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
Завдання 8 
-- Stored procedure for FuelTypes
CREATE OR ALTER PROCEDURE sp_SetFuelType
    @FuelTypeID INT = NULL OUTPUT,
    @FuelName NVARCHAR(50),
    @Description NVARCHAR(200) = NULL,
    @CurrentPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @FuelName IS NULL OR @CurrentPrice IS NULL
    BEGIN
        RAISERROR('FuelName and CurrentPrice are required parameters', 16, 1)
        RETURN
    END

    IF @CurrentPrice <= 0
    BEGIN
        RAISERROR('CurrentPrice must be greater than 0', 16, 1)
        RETURN
    END

    BEGIN TRY
        IF @FuelTypeID IS NULL
        BEGIN
            INSERT INTO FuelTypes (FuelName, Description, CurrentPrice)
            VALUES (@FuelName, @Description, @CurrentPrice)
            
            SET @FuelTypeID = SCOPE_IDENTITY()
        END
        ELSE
        BEGIN
            UPDATE FuelTypes
            SET FuelName = @FuelName,
                Description = ISNULL(@Description, Description),
                CurrentPrice = @CurrentPrice
            WHERE FuelTypeID = @FuelTypeID

            IF @@ROWCOUNT = 0
                RAISERROR('FuelType with specified ID not found', 16, 1)
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END;
GO

-- Stored procedure for Employees
CREATE OR ALTER PROCEDURE sp_SetEmployee
    @EmployeeID INT = NULL OUTPUT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Position NVARCHAR(50) = NULL,
    @HireDate DATE = NULL,
    @Phone VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL,
    @Status VARCHAR(20) = 'Active'
AS
BEGIN
    SET NOCOUNT ON;

    IF @FirstName IS NULL OR @LastName IS NULL
    BEGIN
        RAISERROR('FirstName and LastName are required parameters', 16, 1)
        RETURN
    END

    IF @Status NOT IN ('Active', 'OnLeave', 'Terminated')
    BEGIN
        RAISERROR('Invalid Status value. Must be Active, OnLeave, or Terminated', 16, 1)
        RETURN
    END

    BEGIN TRY
        IF @EmployeeID IS NULL
        BEGIN
            INSERT INTO Employees (FirstName, LastName, Position, HireDate, Phone, Email, Status)
            VALUES (@FirstName, @LastName, @Position, ISNULL(@HireDate, GETDATE()), 
                    @Phone, @Email, @Status)
            
            SET @EmployeeID = SCOPE_IDENTITY()
        END
        ELSE
        BEGIN
            UPDATE Employees
            SET FirstName = @FirstName,
                LastName = @LastName,
                Position = ISNULL(@Position, Position),
                HireDate = ISNULL(@HireDate, HireDate),
                Phone = ISNULL(@Phone, Phone),
                Email = ISNULL(@Email, Email),
                Status = @Status
            WHERE EmployeeID = @EmployeeID

            IF @@ROWCOUNT = 0
                RAISERROR('Employee with specified ID not found', 16, 1)
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END;
GO

-- Stored procedure for StoreItems
CREATE OR ALTER PROCEDURE sp_SetStoreItem
    @ItemID INT = NULL OUTPUT,
    @ItemName NVARCHAR(100),
    @Category NVARCHAR(50) = NULL,
    @Price DECIMAL(10,2),
    @StockQuantity INT,
    @MinimumQuantity INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ItemName IS NULL OR @Price IS NULL OR @StockQuantity IS NULL
    BEGIN
        RAISERROR('ItemName, Price, and StockQuantity are required parameters', 16, 1)
        RETURN
    END

    IF @Price <= 0 OR @StockQuantity < 0
    BEGIN
        RAISERROR('Price must be greater than 0 and StockQuantity must be non-negative', 16, 1)
        RETURN
    END

    BEGIN TRY
        IF @ItemID IS NULL
        BEGIN
            INSERT INTO StoreItems (ItemName, Category, Price, StockQuantity, MinimumQuantity)
            VALUES (@ItemName, @Category, @Price, @StockQuantity, @MinimumQuantity)
            
            SET @ItemID = SCOPE_IDENTITY()
        END
        ELSE
        BEGIN
            UPDATE StoreItems
            SET ItemName = @ItemName,
                Category = ISNULL(@Category, Category),
                Price = @Price,
                StockQuantity = @StockQuantity,
                MinimumQuantity = ISNULL(@MinimumQuantity, MinimumQuantity)
            WHERE ItemID = @ItemID

            IF @@ROWCOUNT = 0
                RAISERROR('StoreItem with specified ID not found', 16, 1)
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END;
GO

-- Example usage for FuelTypes
DECLARE @NewFuelTypeID INT
-- Add new fuel type
EXEC sp_SetFuelType 
    @FuelTypeID = @NewFuelTypeID OUTPUT,
    @FuelName = 'Premium 98',
    @Description = 'Premium gasoline 98 octane',
    @CurrentPrice = 58.99

-- Modify existing fuel type
EXEC sp_SetFuelType 
    @FuelTypeID = 1,
    @FuelName = '95 Euro Plus',
    @Description = 'Enhanced Euro gasoline 95 octane',
    @CurrentPrice = 55.99

-- Example usage for Employees
DECLARE @NewEmployeeID INT
-- Add new employee
EXEC sp_SetEmployee
    @EmployeeID = @NewEmployeeID OUTPUT,
    @FirstName = 'Олег',
    @LastName = 'Петренко',
    @Position = 'Оператор АЗС',
    @Phone = '+380671234567',
    @Email = 'oleg.p@station.com',
    @Status = 'Active'

-- Modify existing employee
EXEC sp_SetEmployee
    @EmployeeID = 1,
    @FirstName = 'Марія',
    @LastName = 'Коваленко',
    @Position = 'Старший оператор',
    @Status = 'Active'

-- Example usage for StoreItems
DECLARE @NewItemID INT
-- Add new store item
EXEC sp_SetStoreItem
    @ItemID = @NewItemID OUTPUT,
    @ItemName = 'Енергетичний напій XL',
    @Category = 'Напої',
    @Price = 45.00,
    @StockQuantity = 50,
    @MinimumQuantity = 10

-- Modify existing store item
EXEC sp_SetStoreItem
    @ItemID = 1,
    @ItemName = 'Кава американо XL',
    @Category = 'Напої',
    @Price = 30.00,
    @StockQuantity = 120,
    @MinimumQuantity = 25
Завдання 9 
CREATE OR ALTER PROCEDURE sp_CreateFuelDelivery
    @TankID INT,
    @Volume DECIMAL(10,2),
    @UnitPrice DECIMAL(10,2),
    @SupplierName NVARCHAR(100),
    @InvoiceNumber VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Перевірка місткості резервуару
        DECLARE @CurrentVolume DECIMAL(10,2), @Capacity DECIMAL(10,2);
        SELECT @CurrentVolume = CurrentVolume, @Capacity = Capacity
        FROM FuelTanks 
        WHERE TankID = @TankID;

        IF (@CurrentVolume + @Volume) > @Capacity
            THROW 50002, 'Перевищення місткості резервуару', 1;

        -- Створення запису про поставку
        INSERT INTO FuelDeliveries (
            TankID, DeliveryDate, Volume, UnitPrice, 
            SupplierName, InvoiceNumber
        )
        VALUES (
            @TankID, GETDATE(), @Volume, @UnitPrice, 
            @SupplierName, @InvoiceNumber
        );

        -- Оновлення об'єму в резервуарі
        UPDATE FuelTanks
        SET CurrentVolume = CurrentVolume + @Volume,
            LastRefillDate = GETDATE()
        WHERE TankID = @TankID;

        -- Оновлення ціни палива
        DECLARE @FuelTypeID INT, @CurrentPrice DECIMAL(10,2);
        SELECT @FuelTypeID = FuelTypeID FROM FuelTanks WHERE TankID = @TankID;
        
        SET @CurrentPrice = @UnitPrice * 1.2; -- 20% націнка

        EXEC sp_SetFuelType
            @FuelTypeID = @FuelTypeID,
            @CurrentPrice = @CurrentPrice;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
CREATE OR ALTER PROCEDURE sp_CreateFuelingTransaction
    @DispenserID INT,
    @CustomerID INT = NULL,
    @FuelTypeID INT,
    @ShiftID INT,
    @Volume DECIMAL(10,2),
    @PaymentMethod NVARCHAR(20),
    @TransactionID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Перевірка наявності палива
        DECLARE @CurrentVolume DECIMAL(10,2), @TankID INT;
        SELECT @CurrentVolume = ft.CurrentVolume, @TankID = ft.TankID
        FROM FuelTanks ft
        WHERE ft.FuelTypeID = @FuelTypeID;

        IF @Volume > @CurrentVolume
            THROW 50001, 'Недостатньо палива в резервуарі', 1;

        -- Перевірка існування DispenserID
        IF NOT EXISTS (
            SELECT 1
            FROM FuelDispensers
            WHERE DispenserID = @DispenserID
        )
        BEGIN
            THROW 50003, 'Помилка: Вказаний DispenserID не існує.', 1;
        END;

        -- Отримання поточної ціни
        DECLARE @PricePerLiter DECIMAL(10,2);
        SELECT @PricePerLiter = CurrentPrice 
        FROM FuelTypes 
        WHERE FuelTypeID = @FuelTypeID;

        -- Створення транзакції
        INSERT INTO FuelingTransactions (
            DispenserID, CustomerID, FuelTypeID, ShiftID,
            Volume, PricePerLiter, TotalAmount, PaymentMethod
        )
        VALUES (
            @DispenserID, @CustomerID, @FuelTypeID, @ShiftID,
            @Volume, @PricePerLiter, @Volume * @PricePerLiter, @PaymentMethod
        );

        SET @TransactionID = SCOPE_IDENTITY();

        -- Оновлення об'єму в резервуарі
        UPDATE FuelTanks
        SET CurrentVolume = CurrentVolume - @Volume
        WHERE TankID = @TankID;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO


