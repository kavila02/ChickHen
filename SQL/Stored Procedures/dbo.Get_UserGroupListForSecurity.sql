
CREATE PROC [dbo].[Get_UserGroupListForSecurity]
AS
	select ID=UserID
		   ,Name=case when isnull(ContactName, '')='' then UserID else ContactName end
		   ,[Type]=CONVERT(varchar(255), 'user')
       
	from csb.UserTable
	UNION
	select UserGroup,UserGroup,'group'
	from csb.UserGroup
	order by [Type], Name