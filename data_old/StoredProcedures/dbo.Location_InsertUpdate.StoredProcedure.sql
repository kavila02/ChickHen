if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Location_InsertUpdate' and s.name = 'dbo')
begin
	drop proc Location_InsertUpdate
end
GO





create proc [dbo].[Location_InsertUpdate]
	@I_vLocationID int
	,@I_vLocation nvarchar(255) = ''
	,@I_vAddressName nvarchar(255) = ''
	,@I_vAddress1 varchar(255) = ''
	,@I_vAddress2 varchar(255) = ''
	,@I_vAddress3 varchar(255) = ''
	,@I_vCity varchar(50) = ''
	,@I_vZip varchar(50) = ''
	,@I_vState varchar(50) = ''
	,@I_vPhoneNumber1 varchar(20) = ''
	,@I_vLocationAbbreviation nvarchar(10) = ''
	,@I_vUSDAPlantNumber1 varchar(50) = ''
	,@I_vUSDAPlantNumber2 varchar(50) = ''
	,@I_vPDANumber varchar(50) = ''
	,@I_vPDAPremiseID varchar(50) = ''
	,@I_vFolderName varchar(50) = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vLocationID = 0
begin
	insert into Location (
		
		Location
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
	)
	select
		
		@I_vLocation
		,@I_vAddressName
		,@I_vAddress1
		,@I_vAddress2
		,@I_vAddress3
		,@I_vCity
		,@I_vZip
		,@I_vState
		,@I_vPhoneNumber1
		,@I_vLocationAbbreviation
		,@I_vUSDAPlantNumber1
		,@I_vUSDAPlantNumber2
		,@I_vPDANumber
		,@I_vPDAPremiseID
		,@I_vFolderName
end
else
begin
	update Location
	set
		
		Location = @I_vLocation
		,AddressName = @I_vAddressName
		,Address1 = @I_vAddress1
		,Address2 = @I_vAddress2
		,Address3 = @I_vAddress3
		,City = @I_vCity
		,Zip = @I_vZip
		,State = @I_vState
		,PhoneNumber1 = @I_vPhoneNumber1
		,LocationAbbreviation = @I_vLocationAbbreviation
		,USDAPlantNumber1 = @I_vUSDAPlantNumber1
		,USDAPlantNumber2 = @I_vUSDAPlantNumber2
		,PDANumber = @I_vPDANumber
		,PDAPremiseID = @I_vPDAPremiseID
		,FolderName = @I_vFolderName
	where @I_vLocationID = LocationID
end
