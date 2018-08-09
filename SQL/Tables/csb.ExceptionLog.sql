CREATE TABLE [csb].[ExceptionLog] (
    [ExceptionLogID]   INT           IDENTITY (1, 1) NOT NULL,
    [LogDateTime]      DATETIME2 (7) NOT NULL,
    [UserID]           INT           NULL,
    [PagePartID]       INT           NULL,
    [Method]           VARCHAR (20)  NULL,
    [Url]              VARCHAR (510) NULL,
    [ExceptionSummary] VARCHAR (510) NULL,
    [ExceptionDetails] VARCHAR (MAX) NULL,
    [FormVariables]    VARCHAR (MAX) NULL,
    [ServerVariables]  VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ExceptionLogID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ExceptionLog_LogDateTime]
    ON [csb].[ExceptionLog]([LogDateTime] ASC);

