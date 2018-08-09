CREATE TABLE [dbo].[AttachmentSettings] (
    [AttachmentSettingsID]    INT           IDENTITY (1, 1) NOT NULL,
    [BaseAttachmentDirectory] VARCHAR (500) NULL,
    PRIMARY KEY CLUSTERED ([AttachmentSettingsID] ASC)
);

