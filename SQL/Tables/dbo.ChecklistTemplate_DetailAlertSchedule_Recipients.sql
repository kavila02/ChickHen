CREATE TABLE [dbo].[ChecklistTemplate_DetailAlertSchedule_Recipients] (
    [ChecklistTemplate_DetailAlertSchedule_RecipientsID] INT      IDENTITY (1, 1) NOT NULL,
    [ChecklistTemplate_DetailAlertScheduleID]            INT      NULL,
    [RecipientType]                                      SMALLINT NULL,
    [ContactRoleID]                                      INT      NULL,
    [ContactID]                                          INT      NULL,
    PRIMARY KEY CLUSTERED ([ChecklistTemplate_DetailAlertSchedule_RecipientsID] ASC),
    FOREIGN KEY ([ChecklistTemplate_DetailAlertScheduleID]) REFERENCES [dbo].[ChecklistTemplate_DetailAlertSchedule] ([ChecklistTemplate_DetailAlertScheduleID]),
    FOREIGN KEY ([ContactID]) REFERENCES [dbo].[Contact] ([ContactID]),
    FOREIGN KEY ([ContactRoleID]) REFERENCES [dbo].[ContactRole] ([ContactRoleID])
);

