CREATE TABLE [csb].[SolutionSchema] (
    [SchemaName]      VARCHAR (5)   NOT NULL,
    [Description]     VARCHAR (255) NOT NULL,
    [DisplaySequence] INT           NOT NULL,
    [NameFilter]      VARCHAR (50)  DEFAULT ('%') NOT NULL,
    PRIMARY KEY CLUSTERED ([SchemaName] ASC)
);

