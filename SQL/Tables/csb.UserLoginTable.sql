CREATE TABLE [csb].[UserLoginTable] (
    [UserTableID]      INT           NOT NULL,
    [UserPassword]     VARCHAR (512) NULL,
    [UserPasswordSalt] VARCHAR (32)  NULL,
    [PasswordChanged]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([UserTableID] ASC),
    FOREIGN KEY ([UserTableID]) REFERENCES [csb].[UserTable] ([UserTableID]) ON DELETE CASCADE
);

