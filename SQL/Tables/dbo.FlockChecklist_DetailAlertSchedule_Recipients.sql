CREATE TABLE [dbo].[FlockChecklist_DetailAlertSchedule_Recipients] (
    [FlockChecklist_DetailAlertSchedule_RecipientsID] INT      IDENTITY (1, 1) NOT NULL,
    [FlockChecklist_DetailAlertScheduleID]            INT      NULL,
    [RecipientType]                                   SMALLINT NULL,
    [ContactRoleID]                                   INT      NULL,
    [ContactID]                                       INT      NULL,
    PRIMARY KEY CLUSTERED ([FlockChecklist_DetailAlertSchedule_RecipientsID] ASC),
    FOREIGN KEY ([ContactID]) REFERENCES [dbo].[Contact] ([ContactID]),
    FOREIGN KEY ([ContactRoleID]) REFERENCES [dbo].[ContactRole] ([ContactRoleID]),
    FOREIGN KEY ([FlockChecklist_DetailAlertScheduleID]) REFERENCES [dbo].[FlockChecklist_DetailAlertSchedule] ([FlockChecklist_DetailAlertScheduleID])
);

