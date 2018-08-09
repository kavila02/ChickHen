CREATE TABLE [csb].[PerformanceLogEntryType] (
    [PerformanceLogEntryTypeID] INT           NOT NULL,
    [Name]                      VARCHAR (255) NOT NULL,
    [DisplaySequence]           INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([PerformanceLogEntryTypeID] ASC),
    UNIQUE NONCLUSTERED ([Name] ASC)
);

