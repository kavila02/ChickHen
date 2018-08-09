CREATE TABLE [dbo].[Attachment] (
    [AttachmentID]    INT             IDENTITY (1, 1) NOT NULL,
    [FileDescription] NVARCHAR (255)  NULL,
    [Path]            NVARCHAR (2000) NULL,
    [DisplayName]     NVARCHAR (500)  NULL,
    [DriveName]       NVARCHAR (50)   NULL,
    [FileSize]        INT             NULL,
    PRIMARY KEY CLUSTERED ([AttachmentID] ASC)
);

