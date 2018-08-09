
create proc csb.ScreenSecurity_Update
@I_vPagePartID int
,@I_vDefaultPermission int = 1
,@O_iErrorState int=0 output
,@oErrString varchar(255)='' output
,@iRowID varchar(255)=NULL output
AS

update csb.PagePart
set IsReadOnly = 0
	,IsViewableDefault = case when @I_vDefaultPermission = 1 then 1 else 0 end
	,IsUpdatableDefault = case when @I_vDefaultPermission = 1 then 1 else 0 end
where PagePartID = @I_vPagePartID