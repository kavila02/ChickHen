IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Follo__16CF2DED]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent] DROP CONSTRAINT [FK__FlockEven__Follo__16CF2DED]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Follo__15DB09B4]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent] DROP CONSTRAINT [FK__FlockEven__Follo__15DB09B4]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Flock__2744C181]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent] DROP CONSTRAINT [FK__FlockEven__Flock__2744C181]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Creat__13F2C142]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent] DROP CONSTRAINT [FK__FlockEven__Creat__13F2C142]
GO
/****** Object:  Table [dbo].[FlockEvent]    Script Date: 7/30/2018 1:51:08 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FlockEvent]') AND type in (N'U'))
DROP TABLE [dbo].[FlockEvent]
GO
/****** Object:  Table [dbo].[FlockEvent]    Script Date: 7/30/2018 1:51:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FlockEvent]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[FlockEvent](
	[FlockEventID] [int] IDENTITY(1,1) NOT NULL,
	[EventDescription] [varchar](2000) NULL,
	[FollowUpDescription] [varchar](2000) NULL,
	[CreatedBy_UserTableID] [int] NULL,
	[FollowUpCreatedBy_UserTableID] [int] NULL,
	[FollowUpContact] [int] NULL,
	[FlockID] [int] NULL,
	[EventDate] [date] NULL,
 CONSTRAINT [PK__FlockEve__7267B41DFF96731E] PRIMARY KEY CLUSTERED 
(
	[FlockEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Creat__13F2C142]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent]  WITH CHECK ADD  CONSTRAINT [FK__FlockEven__Creat__13F2C142] FOREIGN KEY([CreatedBy_UserTableID])
REFERENCES [csb].[UserTable] ([UserTableID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Creat__13F2C142]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent] CHECK CONSTRAINT [FK__FlockEven__Creat__13F2C142]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Flock__2744C181]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent]  WITH CHECK ADD  CONSTRAINT [FK__FlockEven__Flock__2744C181] FOREIGN KEY([FlockID])
REFERENCES [dbo].[Flock] ([FlockID])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Flock__2744C181]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent] CHECK CONSTRAINT [FK__FlockEven__Flock__2744C181]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Follo__15DB09B4]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent]  WITH CHECK ADD  CONSTRAINT [FK__FlockEven__Follo__15DB09B4] FOREIGN KEY([FollowUpCreatedBy_UserTableID])
REFERENCES [csb].[UserTable] ([UserTableID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Follo__15DB09B4]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent] CHECK CONSTRAINT [FK__FlockEven__Follo__15DB09B4]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Follo__16CF2DED]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent]  WITH CHECK ADD  CONSTRAINT [FK__FlockEven__Follo__16CF2DED] FOREIGN KEY([FollowUpContact])
REFERENCES [dbo].[Contact] ([ContactID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockEven__Follo__16CF2DED]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockEvent]'))
ALTER TABLE [dbo].[FlockEvent] CHECK CONSTRAINT [FK__FlockEven__Follo__16CF2DED]
GO
