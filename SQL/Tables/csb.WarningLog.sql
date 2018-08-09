CREATE TABLE [csb].[WarningLog] (
    [WarningLogID] INT           IDENTITY (1, 1) NOT NULL,
    [LogDateTime]  DATETIME2 (7) NOT NULL,
    [UserID]       INT           NULL,
    [PagePartID]   INT           NULL,
    [Source]       VARCHAR (255) NULL,
    [Warning]      VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([WarningLogID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_WarningLog_LogDateTime]
    ON [csb].[WarningLog]([LogDateTime] ASC);

