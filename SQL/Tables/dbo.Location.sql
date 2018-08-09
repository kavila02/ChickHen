/****** Object:  Table [dbo].[Location]    Script Date: 7/20/2018 10:35:12 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Location]') AND type in (N'U'))
DROP TABLE [dbo].[Location]
GO
/****** Object:  Table [dbo].[Location]    Script Date: 7/20/2018 10:35:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Location]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Location](
	[LocationID] [int] IDENTITY(1,1) NOT NULL,
	[Location] [nvarchar](255) NULL,
	[AddressName] [nvarchar](255) NULL,
	[Address1] [varchar](255) NULL,
	[Address2] [varchar](255) NULL,
	[Address3] [varchar](255) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Zip] [varchar](50) NULL,
	[PhoneNumber1] [varchar](20) NULL,
	[LocationAbbreviation] [nvarchar](10) NULL,
	[USDAPlantNumber1] [varchar](50) NULL,
	[USDAPlantNumber2] [varchar](50) NULL,
	[PDANumber] [varchar](50) NULL,
	[PDAPremiseID] [varchar](50) NULL,
	[FolderName] [varchar](50) NULL,
	[SortOrder] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
