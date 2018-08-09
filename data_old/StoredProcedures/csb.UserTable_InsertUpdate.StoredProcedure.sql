if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'UserTable_InsertUpdate' and s.name = 'csb')
begin
	drop proc csb.UserTable_InsertUpdate
end
GO
create PROC [csb].[UserTable_InsertUpdate] (
	@I_vUserTableID int
	, @I_vUserID varchar(255)
	, @I_vEmailAddress varchar(255) = ''
	, @I_vUserGroupID int
	, @I_vContactName varchar(255) = ''
	, @I_vInactive bit = 0
	, @O_iErrorState int=0 output 
	, @oErrString varchar(255)='' output
	, @iRowID int=0 output
) 
AS
IF (SELECT COUNT(*) FROM csb.UserTable WHERE UserTableID=@I_vUserTableID) > 0
BEGIN
	UPDATE csb.UserTable
	Set
		UserID = @I_vUserID
		, eMailAddress = @I_veMailAddress
		, UserGroupID = @I_vUserGroupID
		, ContactName = @I_vContactName
		, Inactive = @I_vInactive
	WHERE 
		UserTableID = @I_vUserTableID
END
ELSE
BEGIN
	INSERT INTO csb.UserTable (
		UserID
		, eMailAddress
		, UserGroupID
		, ContactName
		, Inactive
	) VALUES (
		@I_vUserID
		, @I_veMailAddress
		, @I_vUserGroupID
		, @I_vContactName
		, (CASE WHEN @I_vInactive = 'True' THEN 1 ELSE 0 END)
	)

	
END
