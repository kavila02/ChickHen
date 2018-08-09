if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Location_Get' and s.name = 'dbo')
begin
	drop proc Location_Get
end
GO




create proc [dbo].[Location_Get]
@LocationID int = null
,@IncludeNew bit = 1
As

select
	LocationID
	, Location
	, AddressName
	, Address1
	, Address2
	, Address3
	, City
	, Zip
	, State
	, PhoneNumber1
	, LocationAbbreviation
	, USDAPlantNumber1 
	, USDAPlantNumber2 
	, PDANumber 
	, PDAPremiseID 
	, FolderName
from Location
where IsNull(@LocationID,LocationID) = LocationID
union all
select
	LocationID = convert(int,0)
	, Location = convert(nvarchar(255),null)
	, AddressName = convert(nvarchar(255),null)
	, Address1 = convert(varchar(255),null)
	, Address2 = convert(varchar(255),null)
	, Address3 = convert(varchar(255),null)
	, City = convert(varchar(50),null)
	, Zip = convert(varchar(50),null)
	, State = convert(varchar(50),null)
	, PhoneNumber1 = convert(varchar(20),null)
	, LocationAbbreviation = convert(nvarchar(10),null)
	, USDAPlantNumber1 = convert(varchar(50),null)
	, USDAPlantNumber2 = convert(varchar(50),null)
	, PDANumber = convert(varchar(50),null)
	, PDAPremiseID = convert(varchar(50),null)
	, FolderName = convert(varchar(50),null)
where @IncludeNew = 1
