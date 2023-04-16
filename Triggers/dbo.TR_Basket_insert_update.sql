---
CREATE TRIGGER dbo.TR_Basket_insert_update ON dbo.Basket
AFTER INSERT AS
BEGIN
    WITH grouped AS
    (
        SELECT DiscountValue, Value
        FROM dbo.Basket dB
        INNER JOIN(
            SELECT ID_SKU
            FROM INSERTED
            GROUP BY ID_SKU HAVING COUNT(*) > 1) as dI
        ON dB.ID_SKU = dI.ID_SKU
    )
    UPDATE grouped
        SET DiscountValue = Value * 0.05
    WHERE DiscountValue = 0
END;