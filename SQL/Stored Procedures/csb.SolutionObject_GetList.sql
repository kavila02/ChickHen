
create procedure [csb].[SolutionObject_GetList]
	@SolutionObjectTypeCode varchar(2),
	@SchemaName varchar(50),
	@ObjectNameFilter varchar(4000)
as

select o.SchemaName, o.ObjectName, o.TypeName, o.CreateDateTime, o.ModifyDateTime,
		o.Rows, o.TotalPagesUsed, o.DataPagesUsed, o.IndexPagesUsed
	from csb.SolutionObject o
	where o.SolutionObjectTypeCode like @SolutionObjectTypeCode
		and o.SchemaName like @SchemaName
		and o.ObjectName like '%' + @ObjectNameFilter + '%'
	order by SchemaDisplaySequence, ObjectTypeDisplaySequence