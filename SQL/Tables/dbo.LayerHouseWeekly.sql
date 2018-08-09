IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LayerHouseWeekly_LayerHouse_Cascade]') AND parent_object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly]'))
ALTER TABLE [dbo].[LayerHouseWeekly] DROP CONSTRAINT [FK_LayerHouseWeekly_LayerHouse_Cascade]
GO
/****** Object:  Table [dbo].[LayerHouseWeekly]    Script Date: 7/31/2018 8:53:36 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly]') AND type in (N'U'))
DROP TABLE [dbo].[LayerHouseWeekly]
GO
/****** Object:  Table [dbo].[LayerHouseWeekly]    Script Date: 7/31/2018 8:53:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[LayerHouseWeekly](
	[LayerHouseWeeklyID] [int] IDENTITY(1,1) NOT NULL,
	[LayerHouseID] [int] NULL,
	[WeekEndingDate] [date] NULL,
	[NoOfHens] [int] NULL,
	[BirdAge] [int] NULL,
	[Mortality] [int] NULL,
	[HenWeight] [decimal](16, 2) NULL,
	[HiTemp] [decimal](16, 2) NULL,
	[LowTemp] [decimal](16, 2) NULL,
	[AmmoniaNh3] [int] NULL,
	[LightProgram] [decimal](16, 2) NULL,
	[Rodents] [int] NULL,
	[FlyCounts] [int] NULL,
	[EggsProduced] [int] NULL,
	[CaseWeight] [decimal](16, 2) NULL,
	[FeedInventory] [int] NULL,
	[Water] [int] NULL,
	[BeginningInventory] [int] NULL,
	[TotalFeedDeliveries] [int] NULL,
	[PoundsPerHundred] [decimal](16, 2) NULL,
	[PercentProduction] [decimal](16, 2) NULL,
	[Consumption] [int] NULL,
	[LightIntensity] [decimal](16, 2) NULL,
	[PercentWeightUniformity] [decimal](16, 2) NULL,
	[isActive] [bit] NULL,
 CONSTRAINT [PK__LayerHou__4A52AC0FF3BDE255] PRIMARY KEY CLUSTERED 
(
	[LayerHouseWeeklyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LayerHouseWeekly_LayerHouse_Cascade]') AND parent_object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly]'))
ALTER TABLE [dbo].[LayerHouseWeekly]  WITH CHECK ADD  CONSTRAINT [FK_LayerHouseWeekly_LayerHouse_Cascade] FOREIGN KEY([LayerHouseID])
REFERENCES [dbo].[LayerHouse] ([LayerHouseID])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LayerHouseWeekly_LayerHouse_Cascade]') AND parent_object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly]'))
ALTER TABLE [dbo].[LayerHouseWeekly] CHECK CONSTRAINT [FK_LayerHouseWeekly_LayerHouse_Cascade]
GO
