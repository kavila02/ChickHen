CREATE TABLE [dbo].[ChecklistTemplateContact] (
    [ChecklistTemplateContactID] INT IDENTITY (1, 1) NOT NULL,
    [ChecklistTemplateID]        INT NULL,
    [ContactRoleID]              INT NULL,
    [ContactID]                  INT NULL,
    PRIMARY KEY CLUSTERED ([ChecklistTemplateContactID] ASC),
    FOREIGN KEY ([ChecklistTemplateID]) REFERENCES [dbo].[ChecklistTemplate] ([ChecklistTemplateID]),
    FOREIGN KEY ([ContactID]) REFERENCES [dbo].[Contact] ([ContactID]),
    FOREIGN KEY ([ContactRoleID]) REFERENCES [dbo].[ContactRole] ([ContactRoleID])
);

