CREATE TABLE [csb].[ActivityLog] (
    [ActivityLogID] INT           IDENTITY (1, 1) NOT NULL,
    [LogDateTime]   DATETIME2 (7) NOT NULL,
    [UserID]        INT           NULL,
    [PagePartID]    INT           NULL,
    [IsPost]        BIT           NULL,
    [IpAddress]     VARCHAR (39)  NULL,
    [Url]           VARCHAR (255) NULL,
    [UserAgent]     VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([ActivityLogID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ActivityLog_LogDateTime]
    ON [csb].[ActivityLog]([LogDateTime] ASC);

