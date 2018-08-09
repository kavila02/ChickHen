if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Contact_InsertUpdate' and s.name = 'dbo')
begin
	drop proc Contact_InsertUpdate
end
GO





create proc Contact_InsertUpdate
	@I_vContactID int
	,@I_vContactName nvarchar(255) = ''
	,@I_vPrimaryEmailAddress nvarchar(255) = ''
	,@I_vSecondaryEmailAddress nvarchar(255) = ''
	,@I_vPhoneNumber nvarchar(20) = ''
	,@I_vActive bit = 1
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vContactID = 0
begin
	insert into Contact (
		
		ContactName
		, PrimaryEmailAddress
		, SecondaryEmailAddress
		, PhoneNumber
		, Active
	)
	select
		
		@I_vContactName
		,@I_vPrimaryEmailAddress
		,@I_vSecondaryEmailAddress
		,@I_vPhoneNumber
		,@I_vActive
end
else
begin
	update Contact
	set
		
		ContactName = @I_vContactName
		,PrimaryEmailAddress = @I_vPrimaryEmailAddress
		,SecondaryEmailAddress = @I_vSecondaryEmailAddress
		,PhoneNumber = @I_vPhoneNumber
		,Active = @I_vActive
	where @I_vContactID = ContactID
end