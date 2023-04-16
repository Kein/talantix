-- The exercise does not specify if SurName is an unique value or not,
-- for all we know we can have multiple duplicate SurName values under unique IDs
-- in dbo.Family. Exercise's conditions do not specify any restrictions so we
-- process all possible Family_IDs that have the same SurName.
-- Alternative solution is appened below, it assumes that exercise assumes that we
-- assume that we need to check for existence of SurName first in dbo.Family

IF OBJECT_ID('dbo.usp_MakeFamilyPurchase', 'P') IS NOT NULL DROP PROC dbo.usp_MakeFamilyPurchase;
GO

CREATE PROC dbo.usp_MakeFamilyPurchase
	@FamilySurName AS VARCHAR(255)
AS
	WITH sumVT AS(
		SELECT ID_Family, SUM(Value) as SumValue
		FROM dbo.Basket
		GROUP BY ID_Family
	),
	finalVT AS(
		SELECT ID, SurName, BudgetValue, (BudgetValue - sumVT.SumValue) as NewBudget
		FROM dbo.Family as F
		INNER JOIN sumVT ON F.ID = sumVT.ID_Family AND F.SurName = @FamilySurName
	)
	UPDATE finalVT
		SET BudgetValue = NewBudget;
	IF @@ROWCOUNT = 0  
		RAISERROR(N'No entries were found for Family.SurName: %s', 1, 1, @FamilySurName);
GO

--- Alternative variant
/*
CREATE PROC dbo.usp_MakeFamilyPurchase
	@FamilySurName AS VARCHAR(255)
AS
	DECLARE @FID as INT;
	DECLARE @TotalSum as MONEY;
	-- We could handle ERROR 512 if needed but this should be done at DB schema level
	SET @FID = (SELECT ID FROM dbo.Family WHERE SurName = @FamilySurName);

	IF @FID IS NULL
		RAISERROR(N'No family ID found for SurName: %s', 1, 1, @FamilySurName);
	ELSE
	BEGIN
		SET @TotalSum = (SELECT SUM(Value) FROM dbo.Basket WHERE ID_Family = @FID GROUP BY ID_Family);
		IF @TotalSum IS NOT NULL AND @TotalSum > 0
			UPDATE dbo.Family SET BudgetValue = (BudgetValue - @TotalSum) WHERE ID = @FID;
	END;
GO
*/