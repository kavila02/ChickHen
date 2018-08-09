CREATE TABLE [dbo].[FlockChecklistContact] (
    [FlockChecklistContactID] INT IDENTITY (1, 1) NOT NULL,
    [FlockChecklistID]        INT NULL,
    [ContactRoleID]           INT NULL,
    [ContactID]               INT NULL,
    PRIMARY KEY CLUSTERED ([FlockChecklistContactID] ASC),
    FOREIGN KEY ([ContactID]) REFERENCES [dbo].[Contact] ([ContactID]),
    FOREIGN KEY ([ContactRoleID]) REFERENCES [dbo].[ContactRole] ([ContactRoleID]),
    FOREIGN KEY ([FlockChecklistID]) REFERENCES [dbo].[FlockChecklist] ([FlockChecklistID])
);

