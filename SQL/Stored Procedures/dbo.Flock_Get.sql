/****** Object:  StoredProcedure [dbo].[Flock_Get]    Script Date: 7/27/2018 3:17:03 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flock_Get]
GO
/****** Object:  StoredProcedure [dbo].[Flock_Get]    Script Date: 7/27/2018 3:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Flock_Get] AS' 
END
GO
ALTER proc [dbo].[Flock_Get]
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
	,LastPulletWeight
	,t.*
from Flock f
cross join ##tooltips t
where @FlockID = FlockID

GO
