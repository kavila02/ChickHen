
create procedure [csb].[TeamMember_GetList]
as

select t.Organization, t.Name, t.FirstInvolvementDate, t.Role
	from csb.TeamMember t
	order by t.FirstInvolvementDate, Name