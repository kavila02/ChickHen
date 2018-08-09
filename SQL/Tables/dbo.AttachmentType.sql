CREATE TABLE [dbo].[AttachmentType] (
    [AttachmentTypeID] INT            IDENTITY (1, 1) NOT NULL,
    [AttachmentType]   NVARCHAR (255) NULL,
    [SortOrder]        INT            NULL,
    [IsActive]         BIT            NULL,
    [ShowOnScreenID]   SMALLINT       NULL,
    PRIMARY KEY CLUSTERED ([AttachmentTypeID] ASC)
);

