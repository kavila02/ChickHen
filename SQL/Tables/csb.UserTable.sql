CREATE TABLE [csb].[UserTable] (
    [UserTableID]  INT           IDENTITY (1, 1) NOT NULL,
    [UserID]       VARCHAR (255) NOT NULL,
    [EmailAddress] VARCHAR (255) NULL,
    [UserGroupID]  INT           NULL,
    [ContactName]  VARCHAR (255) NULL,
    [Inactive]     BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([UserTableID] ASC),
    FOREIGN KEY ([UserGroupID]) REFERENCES [csb].[UserGroup] ([UserGroupID]),
    UNIQUE NONCLUSTERED ([UserID] ASC)
);

