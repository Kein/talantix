-- We dont know if [dbo] is the default DB schema fo given login,
-- so we check  and create one in case it is not.
DECLARE @targetSchema sysname = 'dbo';
DECLARE @sql nvarchar(255);

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = @targetSchema)
BEGIN
	SET @sql = CONCAT(N'CREATE SCHEMA', ' ', @targetSchema);
	EXEC sp_executesql @sql;
END;
GO

-- Create requested tables, DROP if exist
IF OBJECT_ID('dbo.Basket', 'U') IS NOT NULL DROP TABLE dbo.Basket;
IF OBJECT_ID('dbo.SKU', 'U') IS NOT NULL DROP TABLE dbo.SKU;
IF OBJECT_ID('dbo.Family', 'U') IS NOT NULL DROP TABLE dbo.Family;

------------
-- dbo.SKU
------------
CREATE TABLE dbo.SKU(
    ID    INT                  IDENTITY NOT NULL,
    Code  AS CONCAT('s', ID)   PERSISTED,
    Name  VARCHAR(255)         NULL,
	CONSTRAINT PK_ID PRIMARY KEY(ID),
	CONSTRAINT UNQ_Code UNIQUE(Code),
);
GO

----------------
-- dbo.Family
----------------
CREATE TABLE dbo.Family
(
	ID           INT             NOT NULL IDENTITY,
	SurName      VARCHAR(255)    NULL,
	BudgetValue  MONEY           NOT NULL,
	CONSTRAINT PK_FamilyID PRIMARY KEY(ID),
);
GO

----------------
-- dbo.Basket
----------------
CREATE TABLE dbo.Basket
(
	ID            INT            NOT NULL IDENTITY,
	ID_SKU        INT            NOT NULL,
	ID_Family     INT            NOT NULL,
	Quantity      INT            NOT NULL,
	Value         MONEY          NOT NULL,
	PurchaseDate  DATETIME       NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	DiscountValue NUMERIC(18, 2) NOT NULL DEFAULT(0),
	CONSTRAINT PK_BasketID PRIMARY KEY(ID),
	CONSTRAINT FK_Basket_to_SKU FOREIGN KEY(ID_SKU)
		REFERENCES dbo.SKU(ID),
	CONSTRAINT FK_Basket_to_Family FOREIGN KEY(ID_Family)
		REFERENCES dbo.Family(ID),
	CONSTRAINT CHK_Value    CHECK(Value >= 0),
	CONSTRAINT CHK_Quantity CHECK(Quantity >= 0),
);
GO