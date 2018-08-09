/****** Object:  Table [dbo].[PulletGrower]    Script Date: 8/7/2018 1:52:40 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PulletGrower]') AND type in (N'U'))
DROP TABLE [dbo].[PulletGrower]
GO
/****** Object:  Table [dbo].[PulletGrower]    Script Date: 8/7/2018 1:52:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PulletGrower]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PulletGrower](
	[PulletGrowerID] [int] IDENTITY(1,1) NOT NULL,
	[PulletGrower] [nvarchar](255) NULL,
	[SortOrder] [int] NULL,
	[IsActive] [bit] NULL,
	[Capacity] [int] NULL,
	[Address] [varchar](100) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](25) NULL,
	[Zip] [varchar](10) NULL,
	[Longitude] [numeric](19, 5) NULL,
	[Latitude] [numeric](19, 5) NULL,
	[Phone] [varchar](20) NULL,
	[PremiseID] [varchar](18) NULL,
	[NPIPNo] [varchar](155) NULL,
PRIMARY KEY CLUSTERED 
(
	[PulletGrowerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
