CREATE TABLE [dbo].[VaccineAttachment] (
    [VaccineAttachmentID] INT            IDENTITY (1, 1) NOT NULL,
    [VaccineID]           INT            NULL,
    [AttachmentID]        INT            NULL,
    [AttachmentTypeID]    INT            NULL,
    [UserName]            NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([VaccineAttachmentID] ASC),
    FOREIGN KEY ([AttachmentID]) REFERENCES [dbo].[Attachment] ([AttachmentID]),
    FOREIGN KEY ([AttachmentTypeID]) REFERENCES [dbo].[AttachmentType] ([AttachmentTypeID]),
    FOREIGN KEY ([VaccineID]) REFERENCES [dbo].[Vaccine] ([VaccineID])
);


GO
CREATE NONCLUSTERED INDEX [IX_VaccineAttachment_AttachmentID]
    ON [dbo].[VaccineAttachment]([AttachmentID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_VaccineAttachment_VaccineID]
    ON [dbo].[VaccineAttachment]([VaccineID] ASC);

