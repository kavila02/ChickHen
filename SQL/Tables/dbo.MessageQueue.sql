CREATE TABLE [dbo].[MessageQueue] (
    [MessageQueueID] INT             IDENTITY (1, 1) NOT NULL,
    [MessageContent] NVARCHAR (MAX)  NULL,
    [FromEmail]      NVARCHAR (2000) NULL,
    [ToEmail]        NVARCHAR (2000) NULL,
    [CcEmail]        NVARCHAR (2000) NULL,
    [BccEmail]       NVARCHAR (2000) NULL,
    [Processed]      BIT             NULL,
    [Subject]        NVARCHAR (255)  NULL,
    PRIMARY KEY CLUSTERED ([MessageQueueID] ASC)
);

