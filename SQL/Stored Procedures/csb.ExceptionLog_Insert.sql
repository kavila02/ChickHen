
create procedure [csb].[ExceptionLog_Insert]
	@UserName varchar(255),
	@XmlScreenID varchar(255),
	@Url varchar(max),
	@Method varchar(max),
	@ExceptionSummary varchar(max),
	@ExceptionDetails varchar(max),
	@FormVariables varchar(max),
	@ServerVariables varchar(max)
as

declare @LIMIT_ON_VARCHAR_MAX int = 16000
declare @MAX_LOG_ROWS int = 16000
declare @PROC_NAME varchar(255) = 'ExceptionLog_Insert'

declare @LogRowCount int = (
	select COUNT(*)
		from csb.ExceptionLog
	)

if @LogRowCount <= @MAX_LOG_ROWS begin

	declare @UserID int = (
		select u.UserID
			from csb.[User] u
			where u.UserName = @UserName
		)
	if @UserID is null begin
		declare @UserNotFoundMessage varchar(max) = 'User name not found: ' + @UserName
		exec csb.WarningLog_Insert @XmlScreenID=@XmlScreenID, @Source=@PROC_NAME, 
				@Warning=@UserNotFoundMessage
	end
	
	declare @PagePartID int = (
		select p.PagePartID
			from csb.PagePart p
			where p.XmlScreenID = @XmlScreenID
		)
	if @PagePartID is null begin
		declare @PagePartFoundMessage varchar(max) = 'XML screen ID not found: ' + @XmlScreenID
		exec csb.PagePart_Insert @PagePartID=@PagePartID output, @XmlScreenID=@XmlScreenID
		exec csb.WarningLog_Insert @UserID=@UserID, @Source=@PROC_NAME, 
				@Warning=@PagePartFoundMessage
	end

	if LEN(@ExceptionDetails) > @LIMIT_ON_VARCHAR_MAX begin
		set @ExceptionDetails = LEFT(@ExceptionDetails, @LIMIT_ON_VARCHAR_MAX) 
				+ '... (TRUNCATED IN ' + @PROC_NAME + ')'
	end
	if LEN(@FormVariables) > @LIMIT_ON_VARCHAR_MAX begin
		set @FormVariables = LEFT(@FormVariables, @LIMIT_ON_VARCHAR_MAX) 
				+ '... (TRUNCATED IN ' + @PROC_NAME + ')'
	end
	if LEN(@ServerVariables) > @LIMIT_ON_VARCHAR_MAX begin
		set @ServerVariables = LEFT(@ServerVariables, @LIMIT_ON_VARCHAR_MAX) 
				+ '... (TRUNCATED IN ' + @PROC_NAME + ')'
	end

	insert into csb.ExceptionLog (LogDateTime, UserID, PagePartID, Url, Method, 
			ExceptionSummary, ExceptionDetails, FormVariables, ServerVariables) values
		(SYSDATETIME(), @UserID, @PagePartID, LEFT(@Url, 510), LEFT(@Method, 20),
				left(@ExceptionSummary, 510), @ExceptionDetails, @FormVariables, 
				@ServerVariables)

end else begin

	declare @TooManyRowsMessage varchar(max) = 'Maximum exception log row limit reached: ' 
			+ convert(varchar(255), @MAX_LOG_ROWS)
	exec csb.WarningLog_Insert @UserName=@UserName, @XmlScreenID=@XmlScreenID, @Source=@PROC_NAME, 
			@Warning=@TooManyRowsMessage

end