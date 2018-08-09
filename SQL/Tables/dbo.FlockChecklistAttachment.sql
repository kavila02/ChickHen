CREATE TABLE [dbo].[FlockChecklistAttachment] (
    [FlockChecklistAttachmentID] INT IDENTITY (1, 1) NOT NULL,
    [FlockChecklistID]           INT NULL,
    [AttachmentID]               INT NULL,
    PRIMARY KEY CLUSTERED ([FlockChecklistAttachmentID] ASC),
    FOREIGN KEY ([AttachmentID]) REFERENCES [dbo].[Attachment] ([AttachmentID]),
    FOREIGN KEY ([FlockChecklistID]) REFERENCES [dbo].[FlockChecklist] ([FlockChecklistID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FlockChecklistAttachment_FlockChecklistID]
    ON [dbo].[FlockChecklistAttachment]([FlockChecklistID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FlockChecklistAttachment_AttachmentID]
    ON [dbo].[FlockChecklistAttachment]([AttachmentID] ASC);

