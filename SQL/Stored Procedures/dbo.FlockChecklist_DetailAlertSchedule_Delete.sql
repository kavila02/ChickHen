
create proc [dbo].[FlockChecklist_DetailAlertSchedule_Delete]
	@I_vFlockChecklist_DetailAlertScheduleID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

delete from FlockChecklist_DetailAlertSchedule_Recipients where FlockChecklist_DetailAlertScheduleID = @I_vFlockChecklist_DetailAlertScheduleID
delete from FlockChecklist_DetailAlertSchedule where FlockChecklist_DetailAlertScheduleID = @I_vFlockChecklist_DetailAlertScheduleID