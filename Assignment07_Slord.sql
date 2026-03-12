--*************************************************************************--
-- Title: Assignment07
-- Author: Slord
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01, Stephen Lord, Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_Slord')
	 Begin 
	  Alter Database [Assignment07DB_Slord] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_Slord;
	 End
	Create Database Assignment07DB_Slord;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_Slord;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
/*
1)
Select * From vProducts;

	-- Note: Identify available columns in the Products table in the Products view (vProduct): ProductID, ProductName, CategoryID, and UnitPrice --

2)
Select ProductName, UnitPrice From vProducts;

	-- Note: Query yeild ProductName and UnitPrice columns from vProducts --

3)
Select ProductName,
Format (vProducts.UnitPrice, 'C', 'en-us') as UnitPrice
From vProducts;

	-- Note: Used the FORMAT function to define the UnitPrice column as Currecy ('C') and US Dollar ('en-us') --

4)
Select ProductName,
Format (vProducts.UnitPrice, 'C', 'en-us') as UnitPrice
From vProducts
Order By 1;

	-- Note: Using ORDER BY, having the query order the results by ProductName --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Enhance the code for readability

5)	
Select p.ProductName,
Format (p.UnitPrice, 'C', 'en-us') as UnitPrice
From vProducts As p
Order By p.ProductName;
Go

	-- Note: Defined/used aliases --
	*/

Select p.ProductName,
Format (p.UnitPrice, 'C', 'en-us') as UnitPrice
From vProducts As p
Order By p.ProductName;
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
 /*
1)
Select * From vCategories;

 	-- Note: Query yeild CategoryID and CategoryName columns from vCategories --

2)
Select * From vProducts;

	-- Note: Identify available columns in the Products table in the Products view (vProduct): ProductID, ProductName, CategoryID, and UnitPrice --
	-- Note: CategoryID (vCategories) and CategoryID (vProducts) are PK/FK --

3)
Select vCategories.CategoryName, vProducts.ProductName, vProducts.UnitPrice
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID;

	-- Note: Using the JOIN statement, combine vCategories and vProducts, specificaly ON the CategoryID --
	-- Comment: Need to format the price as US dollars

4)
Select vCategories.CategoryName, vProducts.ProductName,
Format (vProducts.UnitPrice, 'C', 'en-us') as UnitPrice
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID;

	-- Note: Used the FORMAT function to define the UnitPrice column as Currecy ('C') and US Dollar ('en-us') -- 
	-- Comment: Need to order the results by Category and Product

5)
Select vCategories.CategoryName, vProducts.ProductName,
Format (vProducts.UnitPrice, 'C', 'en-us') as UnitPrice
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID
Order By 1, 2, 3;

	-- Note: Using ORDER BY, having the query order the results by CateogryName first, ProductName second, and UnitPrice third --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Enhance the code for readability

6)
Select c.CategoryName, p.ProductName,
Format (p.UnitPrice, 'C', 'en-us') as UnitPrice
From vCategories As c
	Inner Join vProducts As p
		On c.CategoryID = p.CategoryID
Order By c.CategoryName, p.ProductName,UnitPrice;
Go

	-- Note: Defined/used aliases --
	 */

Select c.CategoryName, p.ProductName,
Format (p.UnitPrice, 'C', 'en-us') as UnitPrice
From vCategories As c
	Inner Join vProducts As p
		On c.CategoryID = p.CategoryID
Order By c.CategoryName, p.ProductName,UnitPrice;
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
1)
Select * From vProducts;

	-- Note: Identify available columns in the Products table in the Products view (vProduct): ProductID, ProductName, CategoryID, and UnitPrice --

2)
Select * From vInventories;

	-- Note: Identify available columns in the Products table in the Inventories view (vInventories): InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, and Count --
	-- Note: ProductID (vProducts) and ProductID (vInventories) are PK/FK --

3)
Select vProducts.ProductName, vInventories.InventoryDate, vInventories.[Count]
From vProducts
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID;

	-- Note: Using the JOIN statement, combine vProducts and vInventories, specificaly ON the ProductID --
	-- Comment: Need to format the date (Year,Month)

4)
Select vProducts.ProductName, 
[InventoryDate] = DateName (Month, vInventories.InventoryDate) + ', ' + DateName (Year, vInventories.InventoryDate),
vInventories.[Count]
From vProducts
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID;

	-- Note: Formating the InventoryDate using DATENAME of Month/Year (Display month number as name/Display year number as year) --
	-- Note: Combining DATENAME for Month/Year to make a singular "Month, Year" column --
	-- Comment: Need to order the results by Product and Date

5)
Select vProducts.ProductName, 
[InventoryDate] = DateName (Month, vInventories.InventoryDate) + ', ' + DateName (Year, vInventories.InventoryDate),
vInventories.[Count]
From vProducts
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
Order By 1, 2;

	-- Note: Using ORDER BY, having the query order the results by ProductName first and InventoryDate second --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Enhance the code for readability

6)
Select p.ProductName, 
[InventoryDate] = DateName (Month, i.InventoryDate) + ', ' + DateName (Year, i.InventoryDate),
i.[Count]
From vProducts As p
	Inner Join vInventories As i
		On p.ProductID = i.ProductID
Order By p.ProductName, i.InventoryDate;
Go

	-- Note: Defined/used aliases --
*/

Select p.ProductName, 
[InventoryDate] = DateName (Month, i.InventoryDate) + ', ' + DateName (Year, i.InventoryDate),
i.[Count]
From vProducts As p
	Inner Join vInventories As i
		On p.ProductID = i.ProductID
Order By p.ProductName, i.InventoryDate;
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
1)
Select * From vProducts;

	-- Print Note: You must use the BASIC views for each table --
	-- Note: Identify available columns in the Products table in the Products view (vProduct): ProductID, ProductName, CategoryID, and UnitPrice --

2)
Select * From vInventories; 

	-- Print Note: You must use the BASIC views for each table --
	-- Note: Identify available columns in the Products table in the Inventories view (vInventories): InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, and Count --
	-- Note: ProductID (vProducts) and ProductID (vInventories) are PK/FK --

3)
Create View vProductInventories
As
Select vProducts.ProductName, vInventories.InventoryDate, vInventories.[Count]
From vProducts
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID;

	-- Note: Using the JOIN statement, combined vProducts and vInventories, specificaly ON the ProductID --
	-- Note: Created a view called ProductInventories (vProductInventories) --
	-- Comment: Need to format the date (Year,Month)

4)
Create View vProductInventories
As
Select vProducts.ProductName,
[InventoryDate] = DateName (Month, Inventories.InventoryDate) + ', ' + DateName (Year, Inventories.InventoryDate),
vInventories.[Count]
From vProducts
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID;

	-- Note: Formating the InventoryDate using DATENAME of Month/Year (Display month number as name/Display year number as year) --
	-- Note: Combining DATENAME for Month/Year to make a singular "Month, Year" column --
	-- Comment: Need to order the results by Product and Date

5)
Create View vProductInventories
As
Select Top 100000 vProducts.ProductName,
[InventoryDate] = DateName (Month, vInventories.InventoryDate) + ', ' + DateName (Year, vInventories.InventoryDate),
vInventories.[Count]
From vProducts
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
Order By 1, vInventories.InventoryDate;

	-- Note: Using ORDER BY, having the query order the results by ProductName first and InventoryDate second --
	-- Comment: When using "2" to signify the 2nd column (InventoryDate), it treats it as a string and will sort the InventoryDate alphabetically, not chronologically
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Enhance the code for readability

6)
Create View vProductInventories
As
Select Top 1000000 p.ProductName, 
[InventoryDate] = DateName (Month, i.InventoryDate) + ', ' + DateName (Year, i.InventoryDate),
i.[Count]
From vProducts As p
	Inner Join vInventories As i
		On p.ProductID = i.ProductID
Order By p.ProductName, i.InventoryDate;
Go

	-- Note: Defined/used aliases --
*/

Create View vProductInventories
As
Select Top 1000000 p.ProductName, 
[InventoryDate] = DateName (Month, i.InventoryDate) + ', ' + DateName (Year, i.InventoryDate),
i.[Count] As InventoryCount
From vProducts As p
	Inner Join vInventories As i
		On p.ProductID = i.ProductID
Order By p.ProductName, i.InventoryDate;
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Check that it works: Select * From vProductInventories;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
/*
7)
Select * From vProductInventories

	-- Comment: Returns a table with Column(s) ProductName, InventoryDate, and InventoryCount 
	-- Comment: ProductName is alphabetical and InventoryDate is chronological 
*/

Select * From vProductInventories
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
/*
1)
Select * From vCategories;

 	-- Note: Query yeild CategoryID and CategoryName columns from vCategories --

2)
Select * From vProducts;

	-- Note: Identify available columns in the Products table in the Products view (vProduct): ProductID, ProductName, CategoryID, and UnitPrice --
	-- Note: CategoryID (vCategories) and CategoryID (vProducts) are PK/FK --

3)
Select * From vInventories; 

	-- Note: Identify available columns in the Products table in the Inventories view (vInventories): InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, and Count --
	-- Note: ProductID (vProducts) and ProductID (vInventories) are PK/FK --

4)
Create View vCategoryInventories
As
Select vCategories.CategoryName, vInventories.InventoryDate, vInventories.[Count]
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID;

	-- Note: Using the JOIN statement, combined vCategories/vProducts/vInventories, specificaly ON the CategoryID/ProductID --
	-- Note: Created a view called CategoryInventories (vCategoryInventories) --
	-- Comment: Need to a TOTAL inventory count
	-- Comment: Need to format the date (Year,Month) 

5)
Create View vCategoryInventories
As
Select vCategories.CategoryName,
[InventoryDate] = DateName (Month, vInventories.InventoryDate) + ', ' + DateName (Year, vInventories.InventoryDate),
[InventoryCountByCategory] = Sum(vInventories.[Count])
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
	Group By vCategories.CategoryName, vInventories.InventoryDate;

	-- Note: Formating the InventoryDate using DATENAME of Month/Year (Display month number as name/Display year number as year) --
	-- Note: Combining DATENAME for Month/Year to make a singular "Month, Year" column --
	-- Note: Used the SUM function to sum the vInventories Count for a TOTAL inventory count --
	-- Note: GROUP BY is required because SUM was utilized --
	-- Comment: Need to order the results by Product and Date

6)
Create View vCategoryInventories
As
Select Top 1000000 vCategories.CategoryName,
[InventoryDate] = DateName (Month, vInventories.InventoryDate) + ', ' + DateName (Year, vInventories.InventoryDate),
[InventoryCountByCategory] = Sum(vInventories.[Count])
From vCategories
	Inner Join vProducts
		On vCategories.CategoryID = vProducts.CategoryID
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
	Group By vCategories.CategoryName, vInventories.InventoryDate
Order By vCategories.CategoryName, Month (InventoryDate), InventoryCountByCategory;

	-- Note: Using ORDER BY, having the query order the results by CategoryName first, InventoryDate second and InventoryCountByCategory third --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Enhance the code for readability

7)
Create View vCategoryInventories
As
Select Top 1000000 c.CategoryName,
[InventoryDate] = DateName (Month, i.InventoryDate) + ', ' + DateName (Year, i.InventoryDate),
[InventoryCountByCategory] = Sum(i.[Count])
From vCategories As c
	Inner Join vProducts As p
		On c.CategoryID = p.CategoryID
	Inner Join vInventories As i
		On p.ProductID = i.ProductID
	Group By c.CategoryName, i.InventoryDate
Order By c.CategoryName, Month (InventoryDate), InventoryCountByCategory;
Go

	-- Note: Defined/used aliases --

*/

Create View vCategoryInventories
As
Select Top 1000000 c.CategoryName,
[InventoryDate] = DateName (Month, i.InventoryDate) + ', ' + DateName (Year, i.InventoryDate),
[InventoryCountByCategory] = Sum(i.[Count])
From vCategories As c
	Inner Join vProducts As p
		On c.CategoryID = p.CategoryID
	Inner Join vInventories As i
		On p.ProductID = i.ProductID
	Group By c.CategoryName, i.InventoryDate
Order By c.CategoryName, Month (InventoryDate), InventoryCountByCategory;
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Check that it works: Select * From vCategoryInventories;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
8)
Select * From vCategoryInventories;

	-- Comment: Returns a table with Column(s) CategoryName, InventoryDate, and InventoryCountByCategory 
	-- Comment: CategoryName is alphabetical, InventoryDate is chronological, and InventoryCountByCategory is Totaled

*/

Select * From vCategoryInventories;
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
1)
Select * From vProductInventories;

	-- Comment: Created earlier, vProductInventories has a list of Product Names, Inventory Dates, and Counts
	-- Comment: Returns a table with Column(s) ProductName, InventoryDate, and InventoryCount 
	-- Comment: ProductName is alphabetical and InventoryDate is chronological 


2) 
Create View vProductInventoriesWithPreviousMonthCounts
As
Select
ProductName, InventoryDate, InventoryCount
From vProductInventories;

	-- Note: Created another view called vProductInventoriesWithPreviousMonthCounts --
	-- Comment: Need to add a new column that has the previous month count 

3)
Create View vProductInventoriesWithPreviouMonthCounts
As
Select
ProductName, InventoryDate, InventoryCount,
LAG([InventoryCount]) Over (Partition By ProductName Order By ProductName, Month(InventoryDate)) As 'PreviousMonthCount'
From vProductInventories;

	-- Note: After the Count column, added a new column (PreviousMonthCount) where the LAG function retrieved the previous month's inventory count (ORDER BY) for each product --
	-- Comment: Need to set any Januay NULL counts to zero

4)
Create View vProductInventoriesWithPreviousMonthCounts
As
Select
ProductName, InventoryDate, InventoryCount,
IsNull (LAG([InventoryCount]) Over (Partition By ProductName Order By ProductName, Month(InventoryDate)), 0) As 'PreviousMonthCount'
From vProductInventories;

	-- Note: Used ISNULL function to replace the first rows "NULL" with "0" --
	-- Comment: Need to order the results by the Product and Date

5) 
Create View vProductInventoriesWithPreviousMonthCounts
As
Select Top 100000
ProductName, InventoryDate, InventoryCount,
IsNull (LAG([InventoryCount]) Over (Partition By ProductName Order By ProductName, Month(InventoryDate)), 0) As 'PreviousMonthCount'
From vProductInventories
Order By ProductName, Month(InventoryDate);

	-- Note: Using ORDER BY, having the query order the results by ProductName first and InventoryDate second --
	-- Note: The specificity of the "order by" isn't specific to ascending (ASC) or descending (DESC) order, so leaving blank/default --
	-- Comment: Enhance the code for readability

*/

Create View vProductInventoriesWithPreviousMonthCounts
As
Select Top 100000
ProductName, InventoryDate, InventoryCount,
IsNull (Lag([InventoryCount]) Over (Partition By ProductName Order By ProductName, Month(InventoryDate)), 0) As 'PreviousMonthCount'
From vProductInventories
Order By ProductName, Month(InventoryDate);
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
6)
Select * From vProductInventoriesWithPreviousMonthCounts;

	-- Comment: Returns a table with Column(s) ProductName, InventoryDate, InventoryCount, and PreviousMonthCount 
*/

Select * From vProductInventoriesWithPreviousMonthCounts;
Go 

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
1)
Select * From vProductInventoriesWithPreviousMonthCounts;

	-- Comment: Created earlier,vProductInventoriesWithPreviousMonthCounts has a list of Product Names, Inventory Dates, Inventory Count, and Previous Month Count
	-- Comment: Returns a table with Column(s) ProductName, InventoryDate, InventoryCount, and PreviousMonthCount

2)
Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount
From vvProductInventoriesWithPreviousMonthCounts;

	-- Note: Created a view called vProductInventoriesWithPreviousMonthCounts --
	-- Comment: The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1


3)
Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount,
CountVsPreviousCountKPI = Case
	When InventoryCount > PreviousMonthCount Then 1
	When InventoryCount = PreviousMonthCount Then 0
	When InventoryCount < PreviousMonthCount Then -1
End
From vProductInventoriesWithPreviousMonthCounts;

	-- Note: Used CASE to create a new column (CountVsPreviousCountKPI) based on conditions (WHEN/THEN) applied from columns (InventoryCount/PreviousMonthCount) --
	-- Note: Scenario 1 - WHEN the InventoryCount is greater than (increased) the PreviousMonthCount THEN yeild "1" --
	-- Note: Scenario 2 - WHEN the InventoryCount is equal (the same) to the PreviousMonthCount THEN yeild "0" --
	-- Note: Scenario 3 - WHEN the InventoryCount is less than (decreased) the PreviousMonthCount THEN yeild "-1" --
	-- Comment: Need to verify the results are ordered by the Product and Date

4)
Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
Select Top 100000 ProductName, InventoryDate, InventoryCount, PreviousMonthCount,
CountVsPreviousCountKPI = Case
	When InventoryCount > PreviousMonthCount Then 1
	When InventoryCount = PreviousMonthCount Then 0
	When InventoryCount < PreviousMonthCount Then -1
End
From vProductInventoriesWithPreviousMonthCounts
Order By ProductName, Cast(InventoryDate As Date);
Go

	-- Note: Using ORDER BY, having the query order the results by ProductName first and InventoryDate second --
*/

Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
Select Top 100000 ProductName, InventoryDate, InventoryCount, PreviousMonthCount,
CountVsPreviousCountKPI = Case
	When InventoryCount > PreviousMonthCount Then 1
	When InventoryCount = PreviousMonthCount Then 0
	When InventoryCount < PreviousMonthCount Then -1
End
From vProductInventoriesWithPreviousMonthCounts
Order By ProductName, Cast(InventoryDate As Date);
Go


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
5)
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
	
	-- Comment: Returns a table with Column(s) ProductName, InventoryDate, InventoryCount, PreviousMonthCount, and CountVsPreviousCountKPI 
	*/

Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Go
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
1) 
Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVSPreviousCountKPI
From vProductInventoriesWithPreviousMonthCountsWithKPIs;

	-- Note: From the vProductInventoriesWithPreviousMonthCountsWithKPI, return ProductName, InventoryDate, InventoryCount, PreviousMonthCount, and CountVSPreviousCountKPI --

2)
Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs ()
Returns Table
As
	Return
	Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVSPreviousCountKPI
	From vProductInventoriesWithPreviousMonthCountsWithKPIs;

	-- Note: Using CREATE FUNCTION created fProductInventoriesWithPreviousMonthCountsWithKPIs --
	-- Comment: Need to define the KPI...CountVSPreviousCountKPI

3) 
Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPIs Int)
Returns Table
As
	Return
	Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVSPreviousCountKPI
	From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVSPreviousCountKPI = @KPIs;

	-- Note: Defined the KPI as an integer from (WHERE) the CountVSPreviousCountKPI column --
	-- Comment: Need to order the results by the Product and Date

4)
Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPIs Int)
Returns Table
As
	Return
	Select Top 100000 ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVSPreviousCountKPI
	From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVSPreviousCountKPI = @KPIs
Order By ProductName, Month(InventoryDate);
Go

	-- Note: Using ORDER BY, having the results order by ProductName first and InventoryDate second --
*/

Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPIs Int)
Returns Table
As
	Return
	Select Top 100000 ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVSPreviousCountKPI
	From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVSPreviousCountKPI = @KPIs
Order By ProductName, Month(InventoryDate);
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/*
5)
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
Go

	-- Note: Ran each query and yielded the correct tables each time, specific to KPI's of 1, 0, and -1 --
*/
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
Go

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

/***************************************************************************************/