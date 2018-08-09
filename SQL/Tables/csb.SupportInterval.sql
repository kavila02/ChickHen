CREATE TABLE [csb].[SupportInterval] (
    [SupportIntervalID]           INT           NOT NULL,
    [Name]                        VARCHAR (255) NOT NULL,
    [MinuteCount]                 INT           NOT NULL,
    [DefaultSupportSubIntervalID] INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([SupportIntervalID] ASC),
    FOREIGN KEY ([DefaultSupportSubIntervalID]) REFERENCES [csb].[SupportSubInterval] ([SupportSubIntervalID]),
    UNIQUE NONCLUSTERED ([Name] ASC)
);

