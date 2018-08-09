create proc FieldReference_GetList_ForAlerts
as

select * from FieldReference
where AlertField = 1