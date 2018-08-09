CREATE TABLE [csb].[SupportSubInterval] (
    [SupportSubIntervalID] INT           NOT NULL,
    [Name]                 VARCHAR (255) NOT NULL,
    [SignificantLength]    INT           NOT NULL,
    [InsignificantSuffix]  VARCHAR (3)   NOT NULL,
    PRIMARY KEY CLUSTERED ([SupportSubIntervalID] ASC),
    UNIQUE NONCLUSTERED ([Name] ASC),
    UNIQUE NONCLUSTERED ([SignificantLength] ASC)
);

