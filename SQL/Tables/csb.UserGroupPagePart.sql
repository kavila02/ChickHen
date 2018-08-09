CREATE TABLE [csb].[UserGroupPagePart] (
    [UserGroupPagePartID] INT IDENTITY (1, 1) NOT NULL,
    [UserGroupID]         INT NOT NULL,
    [PagePartID]          INT NOT NULL,
    [IsViewable]          BIT NOT NULL,
    [IsUpdatable]         BIT NOT NULL,
    PRIMARY KEY NONCLUSTERED ([UserGroupPagePartID] ASC),
    FOREIGN KEY ([PagePartID]) REFERENCES [csb].[PagePart] ([PagePartID]),
    CONSTRAINT [UQ_UserGroupPagePart_UserGroupIDPagePartID] UNIQUE CLUSTERED ([UserGroupID] ASC, [PagePartID] ASC)
);

