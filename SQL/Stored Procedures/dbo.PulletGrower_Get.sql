/****** Object:  StoredProcedure [dbo].[PulletGrower_Get]    Script Date: 8/7/2018 1:52:40 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PulletGrower_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PulletGrower_Get]
GO
/****** Object:  StoredProcedure [dbo].[PulletGrower_Get]    Script Date: 8/7/2018 1:52:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PulletGrower_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PulletGrower_Get] AS' 
END
GO

ALTER proc [dbo].[PulletGrower_Get]
@PulletGrowerID int = null
,@IncludeNew bit = 1
As

select
	PulletGrowerID
	, PulletGrower
	, Address
	, City
	, State
	, Zip
	, SortOrder
	, IsActive
	, Capacity
	, Latitude
	, Longitude
	, Phone
	, PremiseID
	, NPIPNo
from PulletGrower
where IsNull(@PulletGrowerID,PulletGrowerID) = PulletGrowerID
union all
select
	PulletGrowerID = convert(int,0)
	, PulletGrower = convert(nvarchar(255),null)
	, Address = convert(varchar(100),null)
	, City = convert(varchar,(50),null)
	, State = convert(varchar,(25),null)
	, Zip = convert(varchar,(10),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from PulletGrower),1))
	, IsActive = convert(bit,0)
	, Capacity = convert(int,null)
	, Latitude = convert(numeric(19,5),null)
	, Longitude = convert(numeric(19,5),null)
	, Phone = convert(varchar(20),null)
	, PremiseID = convert(varchar(18),null)
	, NPIPNo = convert(varchar(155),null)
where @IncludeNew = 1
Order by ISActive DESC, SortOrder

GO
