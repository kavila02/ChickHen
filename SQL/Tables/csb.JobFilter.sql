CREATE TABLE [csb].[JobFilter] (
    [JobFilterID] INT          IDENTITY (1, 1) NOT NULL,
    [NameFilter]  VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([JobFilterID] ASC),
    UNIQUE NONCLUSTERED ([NameFilter] ASC)
);

