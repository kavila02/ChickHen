
create procedure [csb].[Overview_Get]
	@OverviewID int
as

select o.GoLiveDate, o.Overview
	from csb.Overview o
	where o.OverviewID = @OverviewID