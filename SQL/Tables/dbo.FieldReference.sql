CREATE TABLE [dbo].[FieldReference] (
    [FieldReferenceID]  INT            IDENTITY (1, 1) NOT NULL,
    [TableName]         NVARCHAR (255) NULL,
    [FieldName]         NVARCHAR (255) NULL,
    [FriendlyName]      NVARCHAR (255) NULL,
    [SortOrder]         INT            NULL,
    [IsActive]          INT            NULL,
    [DateField]         BIT            NULL,
    [ToolTip]           NVARCHAR (255) NULL,
    [IncludeInCalendar] BIT            NULL,
	AlertField bit null,
    PRIMARY KEY CLUSTERED ([FieldReferenceID] ASC)
);

