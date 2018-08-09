IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Flock_LayerHouse_Cascade]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] DROP CONSTRAINT [FK_Flock_LayerHouse_Cascade]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__ServiceTe__3706F355]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] DROP CONSTRAINT [FK__Flock__ServiceTe__3706F355]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__PulletsMo__3612CF1C]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] DROP CONSTRAINT [FK__Flock__PulletsMo__3612CF1C]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__ProductBr__351EAAE3]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] DROP CONSTRAINT [FK__Flock__ProductBr__351EAAE3]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__HatcheryI__342A86AA]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] DROP CONSTRAINT [FK__Flock__HatcheryI__342A86AA]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__FowlOutID__33366271]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] DROP CONSTRAINT [FK__Flock__FowlOutID__33366271]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Flock__CreatedDa__7FB6BE6B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Flock] DROP CONSTRAINT [DF__Flock__CreatedDa__7FB6BE6B]
END
GO
/****** Object:  Table [dbo].[Flock]    Script Date: 7/27/2018 3:17:03 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock]') AND type in (N'U'))
DROP TABLE [dbo].[Flock]
GO
/****** Object:  Table [dbo].[Flock]    Script Date: 7/27/2018 3:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Flock](
	[FlockID] [int] IDENTITY(1,1) NOT NULL,
	[FlockName] [nvarchar](255) NULL,
	[LayerHouseID] [int] NULL,
	[ProductBreedID] [int] NULL,
	[Quantity] [int] NULL,
	[ServicesNotes] [nvarchar](1000) NULL,
	[FlockNumber] [varchar](15) NULL,
	[OldOutDate] [date] NULL,
	[PulletsMovedID] [int] NULL,
	[NumberChicksOrdered] [int] NULL,
	[OldFowlHatchDate] [date] NULL,
	[ServiceTechID] [int] NULL,
	[TotalHoused] [int] NULL,
	[HousingOutDate] [date] NULL,
	[FowlRemoved] [bit] NULL,
	[FowlOutID] [int] NULL,
	[HatchDate_First] [date] NULL,
	[HatchDate_Last] [date] NULL,
	[HousingDate_First] [date] NULL,
	[HousingDate_Last] [date] NULL,
	[OrderNumber] [varchar](50) NULL,
	[HatcheryID] [int] NULL,
	[ChickPlacementDate] [date] NULL,
	[TotalChicksPlaced] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[HatchDate_Average] [date] NULL,
	[HousingDate_Average] [date] NULL,
	[PulletHousingTransConfirmNumber] [nvarchar](50) NULL,
	[FowlOutTransConfirmNumber] [nvarchar](50) NULL,
	[LastPulletWeight] [decimal](16, 2) NULL,
 CONSTRAINT [PK__Flock__714C52E024A76609] PRIMARY KEY CLUSTERED 
(
	[FlockID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Flock__CreatedDa__7FB6BE6B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Flock] ADD  CONSTRAINT [DF__Flock__CreatedDa__7FB6BE6B]  DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__FowlOutID__33366271]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock]  WITH CHECK ADD  CONSTRAINT [FK__Flock__FowlOutID__33366271] FOREIGN KEY([FowlOutID])
REFERENCES [dbo].[FowlOutMover] ([FowlOutMoverID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__FowlOutID__33366271]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] CHECK CONSTRAINT [FK__Flock__FowlOutID__33366271]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__HatcheryI__342A86AA]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock]  WITH CHECK ADD  CONSTRAINT [FK__Flock__HatcheryI__342A86AA] FOREIGN KEY([HatcheryID])
REFERENCES [dbo].[Hatchery] ([HatcheryID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__HatcheryI__342A86AA]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] CHECK CONSTRAINT [FK__Flock__HatcheryI__342A86AA]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__ProductBr__351EAAE3]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock]  WITH CHECK ADD  CONSTRAINT [FK__Flock__ProductBr__351EAAE3] FOREIGN KEY([ProductBreedID])
REFERENCES [dbo].[ProductBreed] ([ProductBreedID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__ProductBr__351EAAE3]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] CHECK CONSTRAINT [FK__Flock__ProductBr__351EAAE3]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__PulletsMo__3612CF1C]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock]  WITH CHECK ADD  CONSTRAINT [FK__Flock__PulletsMo__3612CF1C] FOREIGN KEY([PulletsMovedID])
REFERENCES [dbo].[PulletMover] ([PulletMoverID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__PulletsMo__3612CF1C]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] CHECK CONSTRAINT [FK__Flock__PulletsMo__3612CF1C]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__ServiceTe__3706F355]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock]  WITH CHECK ADD  CONSTRAINT [FK__Flock__ServiceTe__3706F355] FOREIGN KEY([ServiceTechID])
REFERENCES [dbo].[Contact] ([ContactID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__Flock__ServiceTe__3706F355]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] CHECK CONSTRAINT [FK__Flock__ServiceTe__3706F355]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Flock_LayerHouse_Cascade]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock]  WITH CHECK ADD  CONSTRAINT [FK_Flock_LayerHouse_Cascade] FOREIGN KEY([LayerHouseID])
REFERENCES [dbo].[LayerHouse] ([LayerHouseID])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Flock_LayerHouse_Cascade]') AND parent_object_id = OBJECT_ID(N'[dbo].[Flock]'))
ALTER TABLE [dbo].[Flock] CHECK CONSTRAINT [FK_Flock_LayerHouse_Cascade]
GO
