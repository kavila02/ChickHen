if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Flock_Get' and s.name = 'dbo')
begin
	drop proc Flock_Get
end
GO
create proc [dbo].[Flock_Get]
@FlockID int
,@UserName nvarchar(255) = ''
As

declare @FMTONLY bit = 0
if 1=0
begin
	select @FMTONLY = 1
	SET FMTONLY OFF
END

if exists (select 1 from tempdb.sys.tables where name = '##tooltips')
begin
	drop table ##tooltips
end

declare @sql nvarchar(max), @columnList nvarchar(4000) = ''
select @columnList = @columnList + case when @columnList = '' then '' else ',' end
					+ '[' + FieldName + '_Tooltip]
'
from FieldReference
where TableName = 'Flock'

select @sql = 
'
select *
into ##tooltips
from
(select RTRIM(FieldName) + ''_Tooltip'' as ColumnName, ToolTip from FieldReference) as SourceTable
PIVOT
(
	MAX(ToolTip)
	for ColumnName in (

' + @columnList + '
)
) as PIVOTTABLE
'

exec (@sql)

IF @FMTONLY = 1
	SET FMTONLY ON

select
	FlockID
	, FlockName
	, LayerHouseID
	, ProductBreedID
	, dbo.FormatIntComma(Quantity) as Quantity
	, ServicesNotes
	, FlockNumber
	--, NPIP
	, OldOutDate
	, PulletsMovedID
	, dbo.FormatIntComma(NumberChicksOrdered) as NumberChicksOrdered
	, OldFowlHatchDate
	, ServiceTechID
	, dbo.FormatIntComma(TotalHoused) as TotalHoused
	, HousingOutDate
	, FowlRemoved
	, FowlOutID
	, HatchDate_First
	, HatchDate_Last
	, HatchDate_Average
	, HousingDate_First
	, HousingDate_Last
	, HousingDate_Average
	, OrderNumber
	, @UserName As UserName
	, DATEDIFF(wk,HatchDate_First,GETDATE()) As FowlAge
	, DATEDIFF(wk,HatchDate_First,HousingDate_Average) As AgeAtHousing_Weeks
	, DATEDIFF(d,HatchDate_First,HousingDate_Average) As AgeAtHousing_Days
	,HatcheryID
	,ChickPlacementDate
	,dbo.FormatIntComma(TotalChicksPlaced) as TotalChicksPlaced
	,PulletHousingTransConfirmNumber
	,FowlOutTransConfirmNumber
	,t.*
from Flock f
cross join ##tooltips t
where @FlockID = FlockID

