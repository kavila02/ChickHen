create proc FlockChecklist_Detail_List_All
@UserName nvarchar(255)
,@FlockID int = null
,@ChecklistTemplateID int = null
,@Detail_StatusID int = null
As

If @FlockID = 0
	set @FlockID = null

If @ChecklistTemplateID = 0
	set @ChecklistTemplateID = null

If @Detail_StatusID = 0
	set @Detail_StatusID = null

select
	FlockChecklist_DetailID
    ,StepName
    ,StepOrder
    ,DateOfAction
    ,ActionDescription
    ,CompletedDate
	,fc.FlockChecklistName
	,f.FlockName
	,IsNull(ds.Detail_Status,'') as Detail_Status
	,convert(varchar,d.FlockChecklist_DetailID) + '&p=' + convert(varchar,d.FlockChecklistID) As LinkValue
from FlockChecklist_Detail d
inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
inner join Flock f on fc.FlockID = f.FlockID
inner join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
inner join UserToLocation utl on utl.LocationID = lh.LocationID
inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID
left outer join Detail_Status ds on d.Detail_StatusID = ds.Detail_StatusID
where IsNull(@FlockID,f.FlockID) = f.FlockID
and IsNull(@ChecklistTemplateID,fc.ChecklistTemplateID) = fc.ChecklistTemplateID
and IsNull(@Detail_StatusID,d.Detail_StatusID) = d.Detail_StatusID
and ut.UserID = @UserName