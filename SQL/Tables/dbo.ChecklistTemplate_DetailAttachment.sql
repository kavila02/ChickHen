CREATE TABLE [dbo].[ChecklistTemplate_DetailAttachment] (
    [ChecklistTemplate_DetailAttachmentID] INT            IDENTITY (1, 1) NOT NULL,
    [ChecklistTemplate_DetailID]           INT            NULL,
    [AttachmentID]                         INT            NULL,
    [AttachmentTypeID]                     INT            NULL,
    [UserName]                             NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([ChecklistTemplate_DetailAttachmentID] ASC),
    FOREIGN KEY ([AttachmentID]) REFERENCES [dbo].[Attachment] ([AttachmentID]),
    FOREIGN KEY ([AttachmentTypeID]) REFERENCES [dbo].[AttachmentType] ([AttachmentTypeID]),
    FOREIGN KEY ([ChecklistTemplate_DetailID]) REFERENCES [dbo].[ChecklistTemplate_Detail] ([ChecklistTemplate_DetailID])
);


GO
CREATE NONCLUSTERED INDEX [IX_ChecklistTemplate_DetailAttachment_ChecklistTemplate_DetailID]
    ON [dbo].[ChecklistTemplate_DetailAttachment]([ChecklistTemplate_DetailID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ChecklistTemplate_DetailAttachment_AttachmentID]
    ON [dbo].[ChecklistTemplate_DetailAttachment]([AttachmentID] ASC);

