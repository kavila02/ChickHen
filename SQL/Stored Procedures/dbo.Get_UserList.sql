
CREATE PROC [dbo].[Get_UserList]
	@IncludeNew bit=0
AS
	SET NOCOUNT ON
	select [UserTableID]
		  ,[UserID]
		  ,[eMailAddress]
		  ,[UserGroupID]
		  ,[ContactName]
		  ,[Inactive]
	from csb.UserTable
	UNION
	select 0, '{new record}', NULL,0
		   ,NULL
		   ,NULL
	where @IncludeNew=1
	order by 1