
create procedure [csb].[SupportSubInterval_GetList]
	@IncludeDefault bit = 0
as
	select ssi.Name, ssi.SupportSubIntervalID, ssi.SignificantLength
		from csb.SupportSubInterval ssi
	union
	select 'Default', -1, 1000
		where @IncludeDefault = 1
	order by SignificantLength desc