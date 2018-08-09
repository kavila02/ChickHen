if not exists (select 1 from sys.tables where name = 'Message_DefaultValues')
begin
create table Message_DefaultValues (
	Message_DefaultValuesID int primary key identity(1,1)
	,URLPrefix nvarchar(255)
	,SolutionPath nvarchar(255)
	,SubjectPrefix nvarchar(255)
)
end
GO
if not exists (select 1 from Message_DefaultValues)
begin
	insert into Message_DefaultValues (URLPrefix, SolutionPath, SubjectPrefix)
	select 'http://localhost/ChickHen/','C:\Projects\Customer Projects\GP\Kreider\ChickHen\trunk\web','TEST: '
end