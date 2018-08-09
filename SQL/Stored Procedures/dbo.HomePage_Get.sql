
CREATE proc [dbo].[HomePage_Get]
@UserName nvarchar(255) = ''
AS

select @UserName as UserName
, convert(bit,0) as ShowFuture
, convert(int,'') as LocationID
, convert(int,'') as LayerHouseID