CREATE TABLE [csb].[TeamMember] (
    [TeamMemberID]         INT           IDENTITY (1, 1) NOT NULL,
    [Organization]         VARCHAR (255) NOT NULL,
    [Name]                 VARCHAR (255) NOT NULL,
    [FirstInvolvementDate] DATE          NOT NULL,
    [Role]                 VARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([TeamMemberID] ASC),
    UNIQUE NONCLUSTERED ([Name] ASC)
);

