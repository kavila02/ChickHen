CREATE TABLE [csb].[PagePartType] (
    [PagePartTypeID] INT           NOT NULL,
    [Name]           VARCHAR (255) NOT NULL,
    [IsPrimaryPage]  BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([PagePartTypeID] ASC),
    UNIQUE NONCLUSTERED ([Name] ASC)
);

