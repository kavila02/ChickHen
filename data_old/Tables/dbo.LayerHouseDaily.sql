CREATE TABLE [dbo].[LayerHouseDaily](
	[LayerHouseDailyID] [int] primary key IDENTITY(1,1) ,
	--[LayerHouseID] [int] NULL,
	[LayerHouseWeeklyID] [int] foreign key references LayerHouseWeekly(LayerHouseWeeklyID),
	[DateOfRecord] [date] NULL,
	[Mortality] [int] NULL,
	[FeedDelivery] [int] NULL,
	[DailyEggs] [int] NULL,
	[Water] [int] NULL,
	[MinTemp] [int] NULL,
	[MaxTemp] [int] NULL
	)
GO
create nonclustered index IX_LayerHouseDaily_LayerHouseWeeklyID
on LayerHouseDaily(LayerHouseWeeklyID)

