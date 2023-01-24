/*
cmd
where bcp.exe
bcp -v
bcp -h

select cr = ascii('')select lf = ascii(right('',1))
--cr = 13 = 0x0D, lf = 10 = 0x0A.

--- -c ile okunabilir, -n ile native çıktı alınabilir.
bcp SourceDB.dbo.Sales out C:\Data\Sales.csv -c -t, -S localhost -T
bcp SourceDB.dbo.Sales format nul -f C:\Data\Sales.fmt -c -t, -S localhost -T

bcp "select Product,Store,SalesDate,Quantity,Amount FROM SourceDB.dbo.Sales" queryout C:\Data\SalesSC.txt -c -t, -S localhost -T
*/
--tek satır tek kolon halinde
SELECT *
	FROM OPENROWSET (
		BULK 'C:\Data\Sales.csv',
		SINGLE_CLOB 
       ) AS t1;

---Kolonlara ayrılmış şekilde
SELECT *
	FROM OPENROWSET (
		BULK 'C:\Data\Sales.csv',
		FORMATFILE='C:\Data\Sales.fmt'
       ) AS t1;