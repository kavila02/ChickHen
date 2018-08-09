CREATE TABLE [dbo].[FlockAttachment] (
    [FlockAttachmentID] INT            IDENTITY (1, 1) NOT NULL,
    [FlockID]           INT            NULL,
    [AttachmentID]      INT            NULL,
    [AttachmentTypeID]  INT            NULL,
    [UserName]          NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([FlockAttachmentID] ASC),
    FOREIGN KEY ([AttachmentID]) REFERENCES [dbo].[Attachment] ([AttachmentID]),
    FOREIGN KEY ([AttachmentTypeID]) REFERENCES [dbo].[AttachmentType] ([AttachmentTypeID]),
    FOREIGN KEY ([FlockID]) REFERENCES [dbo].[Flock] ([FlockID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FlockAttachment_FlockID]
    ON [dbo].[FlockAttachment]([FlockID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FlockAttachment_AttachmentID]
    ON [dbo].[FlockAttachment]([AttachmentID] ASC);

