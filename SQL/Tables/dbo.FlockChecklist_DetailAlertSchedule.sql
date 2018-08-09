CREATE TABLE [dbo].[FlockChecklist_DetailAlertSchedule] (
    [FlockChecklist_DetailAlertScheduleID]    INT            IDENTITY (1, 1) NOT NULL,
    [FlockChecklist_DetailID]                 INT            NULL,
    [AlertDescription]                        NVARCHAR (255) NULL,
    [AlertTemplateID]                         INT            NULL,
    [TimeFromStep]                            INT            NULL,
    [TimeFromStep_DatePartID]                 VARCHAR (4)    NULL,
    [AlertSent]                               BIT            NULL,
    [ChecklistTemplate_DetailAlertScheduleID] INT            NULL,
    [StartDateOrEndDate]                      SMALLINT       NULL,
    PRIMARY KEY CLUSTERED ([FlockChecklist_DetailAlertScheduleID] ASC),
    FOREIGN KEY ([AlertTemplateID]) REFERENCES [dbo].[AlertTemplate] ([AlertTemplateID]),
    FOREIGN KEY ([ChecklistTemplate_DetailAlertScheduleID]) REFERENCES [dbo].[ChecklistTemplate_DetailAlertSchedule] ([ChecklistTemplate_DetailAlertScheduleID]),
    FOREIGN KEY ([FlockChecklist_DetailID]) REFERENCES [dbo].[FlockChecklist_Detail] ([FlockChecklist_DetailID])
);

