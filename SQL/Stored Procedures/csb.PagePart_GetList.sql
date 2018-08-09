
create procedure [csb].[PagePart_GetList]
	@IncludeAll bit = 0
as
	select p.XmlScreenID, p.PagePartID, 2 as Sequence
		from csb.PagePart p
		join csb.PagePartType pt on p.PagePartTypeID = pt.PagePartTypeID
		where pt.IsPrimaryPage = 1
	union
	select 'All', -1, 1
		where @IncludeAll = 1
	order by Sequence, XmlScreenID