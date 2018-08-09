CREATE TABLE [dbo].[UserToLocation] (
    [UserToLocationID] INT IDENTITY (1, 1) NOT NULL,
    [UserTableID]      INT NULL,
    [LocationID]       INT NULL,
    PRIMARY KEY CLUSTERED ([UserToLocationID] ASC),
    FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Location] ([LocationID]),
    FOREIGN KEY ([UserTableID]) REFERENCES [csb].[UserTable] ([UserTableID])
);

