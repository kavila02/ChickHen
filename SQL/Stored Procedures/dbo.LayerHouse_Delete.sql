/****** Object:  StoredProcedure [dbo].[LayerHouse_Delete]    Script Date: 6/19/2018 1:26:45 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[LayerHouse_Delete]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouse_Delete]    Script Date: 6/19/2018 1:26:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouse_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouse_Delete] AS' 
END
GO
ALTER proc [dbo].[LayerHouse_Delete]
	@I_vLayerHouseID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from LayerHouse WHERE LayerHouseID = @I_vLayerHouseID
--delete from VaccineScheduleVaccine where VaccineScheduleID = @I_vVaccineScheduleID
--delete from VaccineSchedule where VaccineScheduleID = @I_vVaccineScheduleID

GO
