
create procedure [csb].[ExceptionLog_InsertFromDatabase]
	@StoredProcedureName varchar(max),
	@ExceptionSummary varchar(max),
	@ExceptionDetails varchar(max) = null,
	@FormVariables varchar(max) = null
as

declare @LIMIT_ON_VARCHAR_MAX int = 16000
declare @MAX_LOG_ROWS int = 16000
declare @PROC_NAME varchar(255) = 'ExceptionLog_InsertFromDatabase'

declare @LogRowCount int = (
	select COUNT(*)
		from csb.ExceptionLog
	)

if @LogRowCount <= @MAX_LOG_ROWS begin

	if LEN(@ExceptionDetails) > @LIMIT_ON_VARCHAR_MAX begin
		set @ExceptionDetails = LEFT(@ExceptionDetails, @LIMIT_ON_VARCHAR_MAX) 
				+ '... (TRUNCATED IN ' + @PROC_NAME + ')'
	end
	if LEN(@FormVariables) > @LIMIT_ON_VARCHAR_MAX begin
		set @FormVariables = LEFT(@FormVariables, @LIMIT_ON_VARCHAR_MAX) 
				+ '... (TRUNCATED IN ' + @PROC_NAME + ')'
	end

	insert into csb.ExceptionLog (LogDateTime, UserID, PagePartID, Url, Method, 
			ExceptionSummary, ExceptionDetails, FormVariables, ServerVariables) values
		(SYSDATETIME(), null, null, LEFT(@StoredProcedureName, 510), 'DATABASE',
				LEFT(@ExceptionSummary, 510), @ExceptionDetails, @FormVariables, null)

end else begin

	declare @TooManyRowsMessage varchar(max) = 'Maximum exception log row limit reached: ' 
			+ convert(varchar(255), @MAX_LOG_ROWS)
	exec csb.WarningLog_Insert @UserName=null, @XmlScreenID=null, @Source=@PROC_NAME, 
			@Warning=@TooManyRowsMessage

end