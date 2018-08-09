
create proc [dbo].[RecipientType_Lookup]
AS

select 'To:',1
union all select 'CC:',2
union all select 'BCC:',3