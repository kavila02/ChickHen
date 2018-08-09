
CREATE VIEW [csb].[SolutionObject]
AS
	with SysObject as (
		select s.name as SchemaName, o.name as ObjectName, ISNULL(t.Name, o.type_desc) as TypeName, 
				o.create_date as CreateDateTime, o.modify_date as ModifyDateTime, 
				Sum(i.rowcnt) as Rows,
				Sum(case when i.indid in (0, 1) then i.used end) as TotalPagesUsed,
				Sum(case when i.indid in (0, 1) then i.used end)
					- Sum(case when i.indid not in (0, 1) then i.used end) as DataPagesUsed,
				Sum(case when i.indid not in (0, 1) then i.used end) as IndexPagesUsed,
				ss.Description as SchemaDescription, ss.DisplaySequence as SchemaDisplaySequence,
				o.type as SolutionObjectTypeCode
			from csb.SolutionSchema ss
			join sys.schemas s on ss.SchemaName = s.name
			join sys.objects o on s.schema_id = o.schema_id
				and o.name like ss.NameFilter
			left join csb.SolutionObjectType t on o.type COLLATE DATABASE_DEFAULT = t.SolutionObjectTypeCode
			left join sysindexes i on o.object_id = i.id
			where (o.parent_object_id = 0 or o.type = 'TR')
				--and s.name in ('cer', 'csb')
			group by s.name, o.name, ISNULL(t.Name, o.type_desc), o.create_date, o.modify_date, 
				ss.Description, ss.DisplaySequence, o.type
	)
	select o.SchemaName, o.ObjectName, o.TypeName, o.CreateDateTime, o.ModifyDateTime, 
			o.Rows, o.TotalPagesUsed, o.DataPagesUsed, o.IndexPagesUsed, 
			o.SchemaDisplaySequence, o.SolutionObjectTypeCode, 2 as ObjectTypeDisplaySequence
		from SysObject o
	union
	select o.SchemaName, o.SchemaDescription, 'Schema', MIN(o.CreateDateTime), MAX(o.ModifyDateTime),
			SUM(o.Rows), SUM(o.TotalPagesUsed), SUM(o.DataPagesUsed), SUM(o.IndexPagesUsed),
			o.SchemaDisplaySequence, '$$', 1 as ObjectTypeDisplaySequence
		from SysObject o
		group by o.SchemaName, o.SchemaDescription, o.SchemaDisplaySequence