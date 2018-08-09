IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Origi__4DEA58AD]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] DROP CONSTRAINT [FK__FlockChec__Origi__4DEA58AD]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Flock__2704CA5F]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] DROP CONSTRAINT [FK__FlockChec__Flock__2704CA5F]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Detai__4C02103B]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] DROP CONSTRAINT [FK__FlockChec__Detai__4C02103B]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Compl__4B0DEC02]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] DROP CONSTRAINT [FK__FlockChec__Compl__4B0DEC02]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Check__4A19C7C9]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] DROP CONSTRAINT [FK__FlockChec__Check__4A19C7C9]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Check__4925A390]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] DROP CONSTRAINT [FK__FlockChec__Check__4925A390]
GO
/****** Object:  Table [dbo].[FlockChecklist_Detail]    Script Date: 7/27/2018 3:17:03 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]') AND type in (N'U'))
DROP TABLE [dbo].[FlockChecklist_Detail]
GO
/****** Object:  Table [dbo].[FlockChecklist_Detail]    Script Date: 7/27/2018 3:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[FlockChecklist_Detail](
	[FlockChecklist_DetailID] [int] IDENTITY(1,1) NOT NULL,
	[FlockChecklistID] [int] NULL,
	[StepName] [nvarchar](255) NULL,
	[StepOrder] [int] NULL,
	[ActionDescription] [nvarchar](500) NULL,
	[DateOfAction] [date] NULL,
	[StepOrFieldCalculation] [smallint] NULL,
	[DateOfAction_TimeFromStep] [int] NULL,
	[TimeFromStep_DatePartID] [varchar](4) NULL,
	[DateOfAction_FlockChecklist_DetailID] [int] NULL,
	[DateOfAction_TimeFromField] [int] NULL,
	[TimeFromField_DatePartID] [varchar](4) NULL,
	[DateOfAction_FieldReferenceID] [int] NULL,
	[OriginatorID] [int] NULL,
	[DetailedNotes] [nvarchar](4000) NULL,
	[CompletedByID] [int] NULL,
	[CompletedDate] [datetime] NULL,
	[Detail_StatusID] [int] NULL,
	[ChecklistTemplate_DetailID] [int] NULL,
	[Checklist_DetailTypeID] [int] NULL,
	[DateOfAction_EndDate] [date] NULL,
 CONSTRAINT [PK__FlockChe__70D75B06D0F81E81] PRIMARY KEY CLUSTERED 
(
	[FlockChecklist_DetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Check__4925A390]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail]  WITH CHECK ADD  CONSTRAINT [FK__FlockChec__Check__4925A390] FOREIGN KEY([Checklist_DetailTypeID])
REFERENCES [dbo].[Checklist_DetailType] ([Checklist_DetailTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Check__4925A390]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] CHECK CONSTRAINT [FK__FlockChec__Check__4925A390]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Check__4A19C7C9]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail]  WITH CHECK ADD  CONSTRAINT [FK__FlockChec__Check__4A19C7C9] FOREIGN KEY([ChecklistTemplate_DetailID])
REFERENCES [dbo].[ChecklistTemplate_Detail] ([ChecklistTemplate_DetailID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Check__4A19C7C9]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] CHECK CONSTRAINT [FK__FlockChec__Check__4A19C7C9]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Compl__4B0DEC02]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail]  WITH CHECK ADD  CONSTRAINT [FK__FlockChec__Compl__4B0DEC02] FOREIGN KEY([CompletedByID])
REFERENCES [dbo].[Contact] ([ContactID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Compl__4B0DEC02]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] CHECK CONSTRAINT [FK__FlockChec__Compl__4B0DEC02]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Detai__4C02103B]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail]  WITH CHECK ADD  CONSTRAINT [FK__FlockChec__Detai__4C02103B] FOREIGN KEY([Detail_StatusID])
REFERENCES [dbo].[Detail_Status] ([Detail_StatusID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Detai__4C02103B]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] CHECK CONSTRAINT [FK__FlockChec__Detai__4C02103B]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Flock__2704CA5F]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail]  WITH CHECK ADD  CONSTRAINT [FK__FlockChec__Flock__2704CA5F] FOREIGN KEY([FlockChecklistID])
REFERENCES [dbo].[FlockChecklist] ([FlockChecklistID])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Flock__2704CA5F]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] CHECK CONSTRAINT [FK__FlockChec__Flock__2704CA5F]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Origi__4DEA58AD]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail]  WITH CHECK ADD  CONSTRAINT [FK__FlockChec__Origi__4DEA58AD] FOREIGN KEY([OriginatorID])
REFERENCES [dbo].[ContactRole] ([ContactRoleID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__FlockChec__Origi__4DEA58AD]') AND parent_object_id = OBJECT_ID(N'[dbo].[FlockChecklist_Detail]'))
ALTER TABLE [dbo].[FlockChecklist_Detail] CHECK CONSTRAINT [FK__FlockChec__Origi__4DEA58AD]
GO
