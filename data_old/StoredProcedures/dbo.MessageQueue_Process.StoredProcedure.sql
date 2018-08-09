if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'MessageQueue_Process' and s.name = 'dbo')
begin
	drop proc MessageQueue_Process
end
GO



create proc [dbo].[MessageQueue_Process]
AS

declare @profile_name nvarchar(128)
,@recipients varchar(max)
,@copy_recipients varchar(max)
,@blind_copy_recipients varchar(max)
,@subject nvarchar(255)
,@body nvarchar(max)
,@body_format varchar(20)
--,@importance varchar(6)
--,@sensitivity varchar(12)
--,@file_attachments nvarchar(max)
--,@query nvarchar(max)
--,@execute_query_database nvarchar(128)
--,@attach_query_result_as_file bit
--,@query_attachment_filename nvarchar(260)
--,@query_result_header bit
--,@query_result_width int
--,@query_result_separator char(1)
--,@exclude_query_output bit
--,@append_query_error bit
--,@query_no_truncate bit
--,@query_result_no_padding bit
--,@mailitem_id int
--,@from_address varchar(max)
--,@reply_to varchar(max)


declare @CurrentID int

while exists (select 1 from MessageQueue where IsNull(Processed,0) = 0) 
Begin 
	Select top 1 @CurrentID = MessageQueueID from MessageQueue where IsNull(Processed,0) = 0
	Select 
		@profile_name = 'sqlmail'
		,@recipients = mq.ToEmail
		,@copy_recipients = IsNull(mq.CcEmail,'')
		,@blind_copy_recipients =IsNull(mq.BccEmail,'')
		,@subject = mq.Subject
		,@body = mq.MessageContent
		,@body_format = 'HTML'
		--,@importance = mq.importance
		--,@sensitivity = mq.sensitivity
		--,@file_attachments = mq.file_attachments
		--,@query = mq.query
		--,@execute_query_database = mq.execute_query_database
		--,@attach_query_result_as_file = mq.attach_query_result_as_file
		--,@query_attachment_filename = mq.query_attachment_filename
		--,@query_result_header = mq.query_result_header
		--,@query_result_width = mq.query_result_width
		--,@query_result_separator = mq.query_result_separator
		--,@exclude_query_output = mq.exclude_query_output
		--,@append_query_error = mq.append_query_error
		--,@query_no_truncate = mq.query_no_truncate
		--,@query_result_no_padding = mq.query_result_no_padding
		--,@mailitem_id = mq.mailitem_id
		--,@from_address = mq.from_address
		--,@reply_to = mq.reply_to
	From MessageQueue mq 
	Where mq.MessageQueueID = @CurrentID

	exec msdb.dbo.sp_send_dbmail
		@profile_name = @profile_name
		,@recipients = @recipients
		,@copy_recipients = @copy_recipients
		,@blind_copy_recipients = @blind_copy_recipients
		,@subject = @subject
		,@body = @body
		,@body_format = @body_format
		--,@importance = @importance
		--,@sensitivity = @sensitivity
		--,@file_attachments = @file_attachments
		--,@query = @query
		--,@execute_query_database = @execute_query_database
		--,@attach_query_result_as_file = @attach_query_result_as_file
		--,@query_attachment_filename = @query_attachment_filename
		--,@query_result_header = @query_result_header
		--,@query_result_width = @query_result_width
		--,@query_result_separator = @query_result_separator
		--,@exclude_query_output = @exclude_query_output
		--,@append_query_error = @append_query_error
		--,@query_no_truncate = @query_no_truncate
		--,@query_result_no_padding = @query_result_no_padding
		--,@mailitem_id = @mailitem_id output
		--,@from_address = @from_address
		--,@reply_to = @reply_to
	

	Update MessageQueue
	Set Processed = 1
	Where MessageQueueID = @CurrentID
End
	

GO


