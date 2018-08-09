if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'PulletGrower_InsertUpdate' and s.name = 'dbo')
begin
	drop proc PulletGrower_InsertUpdate
end
GO

create proc PulletGrower_InsertUpdate
	@I_vPulletGrowerID int
	,@I_vPulletGrower nvarchar(255)
	,@I_vAddress varchar(100) = ''
	,@I_vCity varchar(50) = ''
	,@I_vState varchar(25) = ''
	,@I_vZip varchar(10) = ''
	,@I_vSortOrder int = null
	,@I_vIsActive bit = 0
	,@I_vCapacity int = ''
	,@I_vLatitude numeric(19,5) = null
	,@I_vLongitude numeric(19,5) = null
	,@I_vPhone varchar(20) = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vPulletGrowerID = 0
begin
	declare @PulletGrowerID table (PulletGrowerID int)
	insert into PulletGrower (
		
		PulletGrower
		, Address
		, City
		, State
		, Zip
		, SortOrder
		, IsActive
		, Capacity
		, Latitude
		, Longitude
		, Phone
	)
	output inserted.PulletGrowerID into @PulletGrowerID(PulletGrowerID)
	select
		
		@I_vPulletGrower
		,@I_vAddress
		,@I_vCity
		,@I_vState
		,@I_vZip
		,@I_vSortOrder
		,@I_vIsActive
		,@I_vCapacity
		,@I_vLatitude
		,@I_vLongitude
		,@I_vPhone
	select top 1 @I_vPulletGrowerID = PulletGrowerID, @iRowID = PulletGrowerID from @PulletGrowerID
end
else
begin
	update PulletGrower
	set
		
		PulletGrower = @I_vPulletGrower
		,Address = @I_vAddress
		,City = @I_vCity
		,State = @I_vState
		,Zip = @I_vZip
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
		,Capacity = @I_vCapacity
		, Latitude = @I_vLatitude
		, Longitude = @I_vLongitude
		, Phone = @I_vPhone
	where @I_vPulletGrowerID = PulletGrowerID
	select @iRowID = @I_vPulletGrowerID
end