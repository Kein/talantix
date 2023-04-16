-- We could replace division with a bit more complex multiplication
-- to avoid /0 issue but it still would return 0 anyway

IF OBJECT_ID('dbo.udf_GetSKUPrice') IS NOT NULL DROP FUNCTION dbo.udf_GetSKUPrice;
GO

CREATE FUNCTION dbo.udf_GetSKUPrice(@ID_SKU AS INT)
RETURNS DECIMAL(18,2) AS
BEGIN
	DECLARE @ret AS DECIMAL(18,2) = 0.00;

	SELECT @ret = SUM(Value)/SUM(Quantity)
	FROM dbo.Basket
	WHERE ID_SKU = @ID_SKU
	GROUP BY ID_SKU
	HAVING SUM(Value) > 0;

	RETURN @ret;
END;
GO