CREATE TABLE [csb].[WebServerInfo] (
    [WebServerInfoID]    INT            IDENTITY (1, 1) NOT NULL,
    [WebServerName]      NVARCHAR (255) NULL,
    [WebServerIpAddress] NVARCHAR (20)  NULL,
    [WebServerVersion]   NVARCHAR (50)  NULL,
    [WebSiteRootFolder]  NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([WebServerInfoID] ASC)
);

