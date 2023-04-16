IF OBJECT_ID('dbo.vw_SKUPrices') IS NOT NULL DROP VIEW dbo.vw_SKUPrices;
GO

CREATE VIEW dbo.vw_SKUPrices
AS
	SELECT ID, Code, Name, dbo.udf_GetSKUPrice(ID) as SKUPrice
	FROM dbo.SKU;
GO