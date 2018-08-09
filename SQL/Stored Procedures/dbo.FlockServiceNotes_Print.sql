create proc FlockServiceNotes_Print
@FlockID int
AS

select
f.FlockName
,l.Location
,lh.LayerHouseName
,convert(varchar,GETDATE(),101) as printDate
,f.ServicesNotes
,c.ContactName as ServiceTech
from Flock f
left outer join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
left outer join Location l on lh.LocationID = l.LocationID
left outer join Contact c on f.ServiceTechID = c.ContactID
where f.FlockID = @FlockID