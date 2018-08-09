CREATE TABLE [dbo].[ChecklistTemplate_Detail] (
    [ChecklistTemplate_DetailID]                   INT             IDENTITY (1, 1) NOT NULL,
    [ChecklistTemplateID]                          INT             NULL,
    [StepName]                                     NVARCHAR (255)  NULL,
    [StepOrder]                                    INT             NULL,
    [ActionDescription]                            NVARCHAR (500)  NULL,
    [StepOrFieldCalculation]                       SMALLINT        NULL,
    [DateOfAction_TimeFromStep]                    INT             NULL,
    [TimeFromStep_DatePartID]                      VARCHAR (4)     NULL,
    [DateOfAction_FlockChecklist_DetailID]         INT             NULL,
    [DateOfAction_TimeFromField]                   INT             NULL,
    [TimeFromField_DatePartID]                     VARCHAR (4)     NULL,
    [DateOfAction_FieldReferenceID]                INT             NULL,
    [OriginatorID]                                 INT             NULL,
    [DetailedNotes]                                NVARCHAR (4000) NULL,
    [DefaultDetail_StatusID]                       INT             NULL,
    [Checklist_DetailTypeID]                       INT             NULL,
    [StepOrFieldCalculation_EndDate]               SMALLINT        NULL,
    [DateOfAction_TimeFromStep_EndDate]            INT             NULL,
    [TimeFromStep_DatePartID_EndDate]              VARCHAR (4)     NULL,
    [DateOfAction_FlockChecklist_DetailID_EndDate] INT             NULL,
    [DateOfAction_TimeFromField_EndDate]           INT             NULL,
    [TimeFromField_DatePartID_EndDate]             VARCHAR (4)     NULL,
    [DateOfAction_FieldReferenceID_EndDate]        INT             NULL,
    PRIMARY KEY CLUSTERED ([ChecklistTemplate_DetailID] ASC),
    FOREIGN KEY ([Checklist_DetailTypeID]) REFERENCES [dbo].[Checklist_DetailType] ([Checklist_DetailTypeID]),
    FOREIGN KEY ([ChecklistTemplateID]) REFERENCES [dbo].[ChecklistTemplate] ([ChecklistTemplateID]),
    FOREIGN KEY ([DefaultDetail_StatusID]) REFERENCES [dbo].[Detail_Status] ([Detail_StatusID]),
    FOREIGN KEY ([OriginatorID]) REFERENCES [dbo].[ContactRole] ([ContactRoleID])
);


GO
CREATE NONCLUSTERED INDEX [IX_ChecklistTemplate_Detail_StepOrder]
    ON [dbo].[ChecklistTemplate_Detail]([StepOrder] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ChecklistTemplate_Detail_ChecklistTemplateID]
    ON [dbo].[ChecklistTemplate_Detail]([ChecklistTemplateID] ASC);

