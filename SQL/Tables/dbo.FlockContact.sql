CREATE TABLE [dbo].[FlockContact] (
    [FlockContactID] INT IDENTITY (1, 1) NOT NULL,
    [FlockID]        INT NULL,
    [ContactRoleID]  INT NULL,
    [ContactID]      INT NULL,
    PRIMARY KEY CLUSTERED ([FlockContactID] ASC),
    FOREIGN KEY ([ContactID]) REFERENCES [dbo].[Contact] ([ContactID]),
    FOREIGN KEY ([ContactRoleID]) REFERENCES [dbo].[ContactRole] ([ContactRoleID]),
    FOREIGN KEY ([FlockID]) REFERENCES [dbo].[Flock] ([FlockID])
);

