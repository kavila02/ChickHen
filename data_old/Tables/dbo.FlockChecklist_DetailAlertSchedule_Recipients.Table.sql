if not exists (select 1 from sys.tables where name = 'FlockChecklist_DetailAlertSchedule_Recipients')
begin
create table FlockChecklist_DetailAlertSchedule_Recipients
(
	FlockChecklist_DetailAlertSchedule_RecipientsID int primary key identity(1,1)
	,FlockChecklist_DetailAlertScheduleID int foreign key references FlockChecklist_DetailAlertSchedule(FlockChecklist_DetailAlertScheduleID)
	,RecipientType smallint --1 To; 2 CC; 3 BCC exec RecipientType_Lookup
	,ContactRoleID int foreign key references ContactRole(ContactRoleID)
	,ContactID int foreign key references Contact(ContactID)
)
end