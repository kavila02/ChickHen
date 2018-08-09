if not exists (select 1 from sys.tables where name = 'FlockEvent')
begin
create table FlockEvent
(
	FlockEventID int primary key identity(1,1)
	,FlockID int foreign key references Flock(FlockID)
	,EventDescription varchar(255)
	,FollowUpDescription varchar(255)
	,CreatedBy_UserTableID int foreign key references csb.UserTable(UserTableID)
	,FollowUpCreatedBy_UserTableID int foreign key references csb.UserTable(UserTableID)
	,FollowUpContact int foreign key references Contact(ContactID)
	,EventDate date
)


create nonclustered index IX_FlockEvent_CreatedBy_UserTableID
on FlockEvent(CreatedBy_UserTableID)
create nonclustered index IX_FlockEvent_FollowUpCreatedBy_UserTableID
on FlockEvent(FollowUpCreatedBy_UserTableID)
create nonclustered index IX_FlockEvent_FollowUpContact
on FlockEvent(FollowUpContact)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where c.name = 'FlockID' and t.name = 'FlockEvent')
begin
	alter table FlockEvent add FlockID int foreign key references Flock(FlockID)
end
if not exists (select 1 from sys.indexes where name = 'IX_FlockEvent_FlockID')
begin
	create nonclustered index IX_FlockEvent_FlockID on FlockEvent(FlockID)
end


if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where c.name = 'EventDate' and t.name = 'FlockEvent')
begin
	alter table FlockEvent add EventDate date
end