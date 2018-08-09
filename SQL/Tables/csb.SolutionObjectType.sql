CREATE TABLE [csb].[SolutionObjectType] (
    [SolutionObjectTypeCode] VARCHAR (2)  NOT NULL,
    [Name]                   VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([SolutionObjectTypeCode] ASC),
    UNIQUE NONCLUSTERED ([Name] ASC)
);

