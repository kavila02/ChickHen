CREATE TABLE [dbo].[FlockChecklist] (
    [FlockChecklistID]    INT            IDENTITY (1, 1) NOT NULL,
    [FlockID]             INT            NULL,
    [ChecklistTemplateID] INT            NULL,
    [FlockChecklistName]  NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([FlockChecklistID] ASC),
    FOREIGN KEY ([ChecklistTemplateID]) REFERENCES [dbo].[ChecklistTemplate] ([ChecklistTemplateID]),
    FOREIGN KEY ([FlockID]) REFERENCES [dbo].[Flock] ([FlockID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FlockChecklist_FlockID]
    ON [dbo].[FlockChecklist]([FlockID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FlockChecklist_ChecklistTemplateID]
    ON [dbo].[FlockChecklist]([ChecklistTemplateID] ASC);

