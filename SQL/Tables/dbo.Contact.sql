CREATE TABLE [dbo].[Contact] (
    [ContactID]             INT            IDENTITY (1, 1) NOT NULL,
    [ContactName]           NVARCHAR (255) NULL,
    [PrimaryEmailAddress]   NVARCHAR (255) NULL,
    [SecondaryEmailAddress] NVARCHAR (255) NULL,
    [PhoneNumber]           NVARCHAR (20)  NULL,
    [Active]                BIT            NULL,
    PRIMARY KEY CLUSTERED ([ContactID] ASC)
);

