CREATE TABLE [csb].[PerformanceLog] (
    [PerformanceLogID]          INT           IDENTITY (1, 1) NOT NULL,
    [LogDateTime]               DATETIME2 (7) NOT NULL,
    [UserID]                    INT           NULL,
    [PagePartID]                INT           NULL,
    [PerformanceLogEntryTypeID] INT           NOT NULL,
    [Milliseconds]              INT           NULL,
    [Source]                    VARCHAR (255) NULL,
    [SourceDetail]              VARCHAR (510) NULL,
    PRIMARY KEY CLUSTERED ([PerformanceLogID] ASC),
    FOREIGN KEY ([PerformanceLogEntryTypeID]) REFERENCES [csb].[PerformanceLogEntryType] ([PerformanceLogEntryTypeID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_PerformanceLog_LogDateTime]
    ON [csb].[PerformanceLog]([LogDateTime] ASC);

