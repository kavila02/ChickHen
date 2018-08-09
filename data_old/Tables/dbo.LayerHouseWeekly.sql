CREATE TABLE [dbo].[LayerHouseWeekly](
	[LayerHouseWeeklyID] [int] primary key IDENTITY(1,1) ,
	[LayerHouseID] [int] foreign key references LayerHouse(LayerHouseID),
	[WeekEndingDate] [date] NULL,
	[NoOfHens] [int] NULL,
	--[BirdAge] [int] NULL,
	[Mortality] [int] NULL,
	[HenWeight] [int] NULL,
	[HiTemp] [int] NULL,
	[LowTemp] [int] NULL,
	[AmmoniaNh3] [int] NULL,
	[LightProgram] [decimal](4, 2) NULL,
	[Rodents] [int] NULL,
	[FlyCounts] [int] NULL,
	[EggsProduced] [int] NULL,
	[CaseWeight] [int] NULL,
	[FeedInventory] [int] NULL,
	[Water] [int] NULL,
	[BeginningInventory] [int] NULL,
	[TotalFeedDeliveries] [int] NULL,
	[PoundsPerHundred] [int] NULL,
	[PercentProduction] [int] NULL
	)
GO
create nonclustered index IX_LayerHouseWeekly_LayerHouseID
on LayerHouseWeekly(LayerHouseID)
create nonclustered index IX_LayerHouseWeekly_WeekEndingDate
on LayerHouseWeekly(WeekEndingDate)
