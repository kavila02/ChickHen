CREATE TABLE [dbo].[FlockChecklist_DetailAttachment] (
    [FlockChecklist_DetailAttachmentID] INT            IDENTITY (1, 1) NOT NULL,
    [FlockChecklist_DetailID]           INT            NULL,
    [AttachmentID]                      INT            NULL,
    [AttachmentTypeID]                  INT            NULL,
    [UserName]                          NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([FlockChecklist_DetailAttachmentID] ASC),
    FOREIGN KEY ([AttachmentID]) REFERENCES [dbo].[Attachment] ([AttachmentID]),
    FOREIGN KEY ([AttachmentTypeID]) REFERENCES [dbo].[AttachmentType] ([AttachmentTypeID]),
    FOREIGN KEY ([FlockChecklist_DetailID]) REFERENCES [dbo].[FlockChecklist_Detail] ([FlockChecklist_DetailID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FlockChecklist_DetailAttachment_FlockChecklist_DetailID]
    ON [dbo].[FlockChecklist_DetailAttachment]([FlockChecklist_DetailID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FlockChecklist_DetailAttachment_AttachmentID]
    ON [dbo].[FlockChecklist_DetailAttachment]([AttachmentID] ASC);

