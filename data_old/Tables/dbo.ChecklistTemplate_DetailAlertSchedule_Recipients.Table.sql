if not exists (select 1 from sys.tables where name = 'ChecklistTemplate_DetailAlertSchedule_Recipients')
begin
create table ChecklistTemplate_DetailAlertSchedule_Recipients
(
	ChecklistTemplate_DetailAlertSchedule_RecipientsID int primary key identity(1,1)
	,ChecklistTemplate_DetailAlertScheduleID int foreign key references ChecklistTemplate_DetailAlertSchedule(ChecklistTemplate_DetailAlertScheduleID)
	,RecipientType smallint --1 To; 2 CC; 3 BCC exec RecipientType_Lookup
	,ContactRoleID int foreign key references ContactRole(ContactRoleID)
	,ContactID int foreign key references Contact(ContactID)
)
end