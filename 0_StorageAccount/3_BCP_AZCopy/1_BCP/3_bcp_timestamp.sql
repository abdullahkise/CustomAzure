CREATE DATABASE SourceDB
GO

USE SourceDB
GO

CREATE TABLE Sales
(
	Product nvarchar(50),
	Store nvarchar(50),
	SalesDate date,
	Quantity int,
	Amount money ,

	timestamp
)

GO

--TRUNCATE TABLE Sales
INSERT INTO dbo.Sales(Product,Store,SalesDate,Quantity,Amount)
--SELECT * FROM (
	VALUES('Laptop','S1','2021-01-02',20,283456.15),
		  ('Laptop','S2','2021-01-20',15,150254.56),
		  ('Phone','S1','2021-01-25',100,350126.68),
		  ('TV','S2','2021-01-25',150,70126.84)
--)T(Product,Store,SalesDate,Quantity,Amount)

-------------------------------------------------
--timestamp alanı int (bigint) cast edilebilir.
SELECT *,CAST(timestamp as bigint) FROM dbo.Sales
--select cast(2005 as timestamp) --0x00000000000007D5
--
--timestamp alanı otomatik değişiyor.
UPDATE dbo.Sales
SET Product='Cell Phone'
WHERE Product='Phone'

-----------------------------
--tüm exportları ve timestampleri tuttuğumuz tablo
CREATE TABLE Exports
(
	ExportTable nvarchar(50),
	ExportDate datetime2 DEFAULT(GETDATE()),
	ExportTimestamp binary(8)
)
SELECT * FROM Exports
--TRUNCATE TABLE Exports
GO
----------------------------------------------
--bcp komutu üreten proc
CREATE OR ALTER PROC usp_ExportTableData
(@exportTable nvarchar(50))
AS
BEGIN
	DECLARE @lastTimestamp binary(8),
			@lastTimestampSaved binary(8),
			@cmd nvarchar(500)

	--kaydedilmiş son timstamp alalım
	SELECT TOP 1 @lastTimestampSaved=ExportTimestamp FROM Exports WHERE ExportTable=@exportTable ORDER BY ExportTimestamp DESC

	--tablodaki timestamp
	DECLARE @sql nvarchar(150)='SELECT TOP 1 @lastTimestamp=timestamp FROM '+ @exportTable + N' ORDER BY timestamp DESC'
	exec sp_executesql @sql,
					   N'@lastTimestamp binary(8) output',
					   @lastTimestamp output

	--timestamp alanlarını kontrol edelim.
	IF @lastTimestampSaved IS NULL
		BEGIN
			SET @cmd= 'bcp SourceDB.'+@exportTable+' OUT C:\Data\Sales_'+FORMAT(GETDATE(),'yyyyMMdd-HHmm')+'.csv -c -t, -T -S '+@@SERVERNAME
		END
	ELSE IF(@lastTimestampSaved<@lastTimestamp)
		BEGIN
			SET @cmd= 'bcp "SELECT * FROM SourceDB.dbo.Sales WHERE timestamp>'+CONVERT(nvarchar(100),@lastTimestampSaved,1) +'" queryout C:\Data\SalesSC_'+FORMAT(GETDATE(),'yyyyMMdd-HHmm')+'.csv -c -t, -S localhost -T'
		END
	ELSE
		PRINT 'Aktaracak herhangi bir satır mevcut değil.'
	
	--son aktarım denemesini kaydet.
	INSERT INTO dbo.Exports(ExportTable,ExportTimestamp) VALUES(@exportTable,@lastTimestamp)
	PRINT @cmd

	--bcp komutu terminalde çalışsın
	exec master..xp_cmdshell @cmd
END
------------------------
--TRUNCATE TABLE Exports
--UPDATE Sales SET Amount=Amount*1.18 WHERE Store='S1'
--INSERT INTO dbo.Sales(Product,Store,SalesDate,Quantity,Amount) VALUES('Mirror','S4','2021-01-22',150,500.12)

usp_ExportTableData 'dbo.Sales'
