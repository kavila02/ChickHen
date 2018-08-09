IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LayerHouseDaily_LayerHouse_Cascade]') AND parent_object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily]'))
ALTER TABLE [dbo].[LayerHouseDaily] DROP CONSTRAINT [FK_LayerHouseDaily_LayerHouse_Cascade]
GO
/****** Object:  Table [dbo].[LayerHouseDaily]    Script Date: 6/21/2018 8:03:32 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily]') AND type in (N'U'))
DROP TABLE [dbo].[LayerHouseDaily]
GO
/****** Object:  Table [dbo].[LayerHouseDaily]    Script Date: 6/21/2018 8:03:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[LayerHouseDaily](
	[LayerHouseDailyID] [int] IDENTITY(1,1) NOT NULL,
	[LayerHouseID] [int] NULL,
	[LayerHouseWeeklyID] [int] NULL,
	[DateOfRecord] [date] NULL,
	[Mortality] [int] NULL,
	[FeedDelivery] [int] NULL,
	[DailyEggs] [int] NULL,
	[Water] [int] NULL,
	[MinTemp] [decimal](16, 2) NULL,
	[MaxTemp] [decimal](16, 2) NULL,
	[Chlorine] [decimal](16, 2) NULL,
	[RationCode] [decimal](16, 2) NULL,
 CONSTRAINT [PK__LayerHou__09362C505B2F6E3D] PRIMARY KEY CLUSTERED 
(
	[LayerHouseDailyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LayerHouseDaily_LayerHouse_Cascade]') AND parent_object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily]'))
ALTER TABLE [dbo].[LayerHouseDaily]  WITH CHECK ADD  CONSTRAINT [FK_LayerHouseDaily_LayerHouse_Cascade] FOREIGN KEY([LayerHouseID])
REFERENCES [dbo].[LayerHouse] ([LayerHouseID])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LayerHouseDaily_LayerHouse_Cascade]') AND parent_object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily]'))
ALTER TABLE [dbo].[LayerHouseDaily] CHECK CONSTRAINT [FK_LayerHouseDaily_LayerHouse_Cascade]
GO
