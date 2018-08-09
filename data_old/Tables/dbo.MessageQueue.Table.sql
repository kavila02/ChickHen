if not exists (select 1 from sys.tables where name = 'MessageQueue')
begin

CREATE TABLE MessageQueue(
	[MessageQueueID] [int] IDENTITY(1,1) NOT NULL,
	[MessageContent] [nvarchar](max) NULL,
	[FromEmail] [nvarchar](2000) NULL,
	[ToEmail] [nvarchar](2000) NULL,
	[CcEmail] [nvarchar](2000) NULL,
	[BccEmail] [nvarchar](2000) NULL,
	[Processed] [bit] NULL,
	[Subject] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[MessageQueueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]



END