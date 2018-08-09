CREATE TABLE [dbo].[ChecklistTemplateAttachment] (
    [ChecklistTemplateAttachmentID] INT IDENTITY (1, 1) NOT NULL,
    [ChecklistTemplateID]           INT NULL,
    [AttachmentID]                  INT NULL,
    PRIMARY KEY CLUSTERED ([ChecklistTemplateAttachmentID] ASC),
    FOREIGN KEY ([AttachmentID]) REFERENCES [dbo].[Attachment] ([AttachmentID]),
    FOREIGN KEY ([ChecklistTemplateID]) REFERENCES [dbo].[ChecklistTemplate] ([ChecklistTemplateID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FlockAttachment_AttachmentID]
    ON [dbo].[ChecklistTemplateAttachment]([AttachmentID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ChecklistTemplateAttachment_ChecklistTemplateID]
    ON [dbo].[ChecklistTemplateAttachment]([ChecklistTemplateID] ASC);

