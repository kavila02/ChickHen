CREATE TABLE [dbo].[ChecklistTemplate_DetailAlertSchedule] (
    [ChecklistTemplate_DetailAlertScheduleID] INT            IDENTITY (1, 1) NOT NULL,
    [ChecklistTemplate_DetailID]              INT            NULL,
    [AlertDescription]                        NVARCHAR (255) NULL,
    [AlertTemplateID]                         INT            NULL,
    [TimeFromStep]                            INT            NULL,
    [TimeFromStep_DatePartID]                 VARCHAR (4)    NULL,
    [StartDateOrEndDate]                      SMALLINT       NULL,
    PRIMARY KEY CLUSTERED ([ChecklistTemplate_DetailAlertScheduleID] ASC),
    FOREIGN KEY ([AlertTemplateID]) REFERENCES [dbo].[AlertTemplate] ([AlertTemplateID]),
    FOREIGN KEY ([ChecklistTemplate_DetailID]) REFERENCES [dbo].[ChecklistTemplate_Detail] ([ChecklistTemplate_DetailID])
);

