
create procedure [csb].[RethrowError] 
	@OverrideErrorNumber int = null,
	@OverrideErrorMessage varchar(max) = null
as

	declare @ErrorNumber int = ERROR_NUMBER()
    if @ErrorNumber = @OverrideErrorNumber begin
		raiserror(@OverrideErrorMessage, 11, 1)
	end else begin
		declare @ErrorSeverity int = ERROR_SEVERITY()
		declare @ErrorState int = ERROR_STATE()
		declare @ErrorLine int = ERROR_LINE()
		declare @ErrorProcedure  nvarchar(200) = ISNULL(ERROR_PROCEDURE(), '-')
		declare @ErrorMessage nvarchar(4000) = case 
				when @ErrorNumber = 50000
				then ERROR_MESSAGE()
				else N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' 
						+ ERROR_MESSAGE()
				end
		raiserror(@ErrorMessage, @ErrorSeverity, 1, @ErrorNumber,
				@ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine);
	end