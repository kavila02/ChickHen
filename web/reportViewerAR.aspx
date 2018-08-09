<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="CSIActiveReports.ActiveReports" %>
<%@ Import Namespace="GrapeCity.ActiveReports" %>
<%@ Import Namespace="GrapeCity.ActiveReports.Document.Section" %>
<%@ Import Namespace="GrapeCity.ActiveReports.Export.Pdf.Section" %>
<%@ Import Namespace="GrapeCity.ActiveReports.SectionReportModel" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="csi.Framework.Utility" %>
<%@ Import Namespace="csi.Framework.ScreenData" %>

<%@ Register TagPrefix="ActiveReportsWeb" Namespace="GrapeCity.ActiveReports.Web" 
        Assembly="GrapeCity.ActiveReports.Web.v7, Version=7.3.7973.0, Culture=neutral, PublicKeyToken=cc4967777c49a3ff" 
%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head id="Head1" runat="server">
	
	<link rel="stylesheet" type="text/css" href="style/general.css" />
	<link id="layoutStyle" rel="stylesheet" type="text/css" href="style/report.css" />

    <script language="VB" runat="server">
        Dim _fileName As String
        Dim _displayRecordField As String
        Dim _parameterValues As String()

        Dim _pageCounter As ActiveReportsPageCounter
        Dim WithEvents _partialReport As SectionReport
        Dim WithEvents _partialReportSection As Section

        Dim _reportsToDispose As IList(Of SectionReport) = New List(Of SectionReport)

        Private Sub Page_Load(sender As System.Object, e As EventArgs) Handles MyBase.Load

            _fileName = Request.Params("fileNameField")
            _displayRecordField = Request.Params("displayRecordField")
            Dim currentParameters As Parameters = New Parameters(Request)
            _parameterValues = currentParameters.Array
            '_parameterValues = If(Request.Params("p") Is Nothing, Nothing, Request.QueryString.GetValues("p"))

            Dim screenID As String = Request.Params("screenID")
            Dim reportFormat As String = getReportFormat(Request, _displayRecordField)
            Dim screenReader As ScreenReader = New ScreenReader()
            Dim primaryReportScreenItem As ScreenItem = screenReader.Item(screenID, User.Identity.Name)
            Dim fullReport As SectionReport = runFullReport(screenReader, primaryReportScreenItem)
            Dim pageRange As String = getPageRange(screenReader, screenID, fullReport)

            If reportFormat = "ActiveReports" Then
                Dim reportName As String = Page.Request.QueryString("Report")
                SetExportUrls(screenID, reportName, _parameterValues, uxExcelExport,
                               uxWordExport, uxPdfExport)
                uxWebViewer.Report = fullReport
            Else
                ExportMemoryStream(fullReport, reportFormat, pageRange)
            End If
            displosePartialReports()

        End Sub

        Private Shared Function getReportFormat(request As HttpRequest,
                                                displayRecordField As String) As String

            Dim reportFormat As String = request.Params("ReportFormat")
            'active reports format does not support suppressing or removing pages.
            'if we need to hide some pages, switch to PDF format
            If reportFormat = "ActiveReports" And displayRecordField > "" Then
                reportFormat = "PDF"
            End If
            Return reportFormat

        End Function

        Private Function runFullReport(screenReader As ScreenReader,
                                       primaryReportScreenItem As ScreenItem) As SectionReport

            Dim data As csi.Framework.Utility.Data = New csi.Framework.Utility.Data()
            Try
                Dim fullReport As SectionReport = New SectionReport
                runPartialReport(screenReader, data, fullReport, primaryReportScreenItem)
                Dim additionalReportReferences As List(Of ScreenItem) _
                        = screenReader.References(primaryReportScreenItem.ID, "additionalReport")
                If Not additionalReportReferences Is Nothing Then
                    For Each additionalReportReference As ScreenItem In additionalReportReferences
                        runPartialReport(screenReader, data, fullReport, additionalReportReference)
                    Next
                End If
                Return fullReport
            Finally
                data.Close()
            End Try

        End Function

        Private Sub runPartialReport(screenReader As ScreenReader, data As csi.Framework.Utility.Data,
                                     fullReport As SectionReport,
                                     reportScreenItem As ScreenItem)

            Dim dataTable As DataTable = Nothing
            Try
                Dim sql As String = csi.Framework.Utility.Data.BuildSql(reportScreenItem.DataStatement, _parameterValues)
                dataTable = data.SQL_to_DataSet(sql).Tables(0)
            Catch thisException As SqlException
                ActiveReportsUtility.AddExceptionToReport(fullReport, thisException)
            End Try

            If Not dataTable Is Nothing Then
                _partialReport = New SectionReport
                _partialReport.LoadLayout(ActiveReportsUtility.GetXmlReader(reportScreenItem.PageName))
                _partialReport.DataSource = dataTable
                _partialReport.Restart()
                setChartDataSources(screenReader, reportScreenItem, data, dataTable)
            End If

            Try
                _partialReport.Document.Printer.PrinterName = String.Empty
                _partialReport.Run(False)
                fullReport.Document.Pages.AddRange(_partialReport.Document.Pages)
            Catch exception As Exception
                ActiveReportsUtility.AddExceptionToReport(fullReport, exception)
            End Try
            'While _partialReport.Document.Pages.Count > 0
            '    _partialReport.Document.Pages.RemoveAt(0)
            'End While
            'For Each currentPage As Page In _partialReport.Document.Pages
            '    _partialReport.Document.Pages.Remove(currentPage)
            'Next
            'The above code has two different methods for the same process. Both processes are failing with an error concerning 'parameter not found: key'
            'I don't see the purpose to removing the pages from the report so I commented out the code in the meantime. This resolved the error and the report runs without issue
            _reportsToDispose.Add(_partialReport)

        End Sub

        Private Sub setChartDataSources(screenReader As ScreenReader, reportScreenItem As ScreenItem,
                              data As csi.Framework.Utility.Data, dataTable As DataTable)

            Dim chartControlReferences As List(Of ScreenItem) = screenReader.References(reportScreenItem.ID, "chartControl")
            If Not chartControlReferences Is Nothing Then
                For Each section As Section In _partialReport.Sections
                    For Each control As ARControl In section.Controls
                        Dim chart As ChartControl = TryCast(control, ChartControl)
                        If (chart IsNot Nothing) Then
                            For Each screenItem As ScreenItem In chartControlReferences
                                If chart.Name = screenItem.DisplayName Then
                                    Dim sql As String = csi.Framework.Utility.Data.BuildSql(screenItem.DataStatement, _parameterValues)
                                    chart.DataSource = data.SQL_to_DataSet(sql).Tables(0)
                                End If
                            Next
                            If chart.DataSource Is Nothing Then
                                chart.DataSource = dataTable
                            End If
                        End If
                    Next
                Next
            End If

        End Sub

        Private Function getPageRange(screenReader As ScreenReader, screenID As String,
                                      fullReport As SectionReport) As String

            Dim helperProcDataStatement As String = getPageRangeHelperProcDataStatement(screenReader, screenID)
            Dim thisPageRange As String = ""
            Dim data As New csi.Framework.Utility.Data()
            Try
                If Not _pageCounter Is Nothing Then
                    For Each pageRangeRecord As String() In _pageCounter.PageRanges
                        Dim pathName As String = Server.MapPath(pageRangeRecord(0))
                        pathName = pathName.Substring(0, pathName.LastIndexOf("\"))
                        If Not Directory.Exists(pathName) Then
                            Directory.CreateDirectory(pathName)
                        End If
                        'if doing this, the report cannot have Bookmarks added!
                        exportPageRangesToPdf(fullReport, pageRangeRecord(1), pageRangeRecord(0))
                        If helperProcDataStatement > "" Then
                            Dim sql As String = csi.Framework.Utility.Data.BuildSql(helperProcDataStatement)
                            sql = sql.Replace("{0}", pageRangeRecord(0))
                            data.SQL_to_DataSet(sql)
                        End If
                    Next
                    thisPageRange = _pageCounter.DisplayPageRange
                End If
                Return thisPageRange
            Finally
                data.Close()
            End Try

        End Function

        Private Function getPageRangeHelperProcDataStatement(screenReader As ScreenReader,
                                                             screenID As String) As String

            'TODO: Throw exception if more than one reference instead of quietly taking last?
            Dim helperProcDataStatement As String = ""
            Dim postExportSqlReferences As List(Of ScreenItem) = screenReader.References(screenID, "execSQLAfterExport")
            If Not postExportSqlReferences Is Nothing Then
                For Each primaryReportScreenItem As ScreenItem In postExportSqlReferences
                    helperProcDataStatement = Common.ReplaceVariables(primaryReportScreenItem.DataStatement,
                                                                                 CType(Context.Session("applicationVariable"), Hashtable))
                Next
            End If
            Return helperProcDataStatement

        End Function

        Private Sub exportPageRangesToPdf(fullReport As SectionReport, pageRange As String,
                                              fileName As String)
            Dim pdf As PdfExport = New PdfExport
            If pageRange > "" Then
                pdf.Export(fullReport.Document, Server.MapPath(fileName), pageRange)
            Else
                pdf.Export(fullReport.Document, Server.MapPath(fileName))
            End If

        End Sub

        Private Sub partialReport_ReportStart(sender As Object, e As EventArgs) Handles _partialReport.ReportStart

            Dim thisSection As Section = Nothing
            For Each thisSection In _partialReport.Sections
                If thisSection.Type = SectionType.Detail Then
                    _partialReportSection = thisSection
                    Exit For
                End If
            Next
            If _fileName Is Nothing Then
                _fileName = ""
            End If
            If _displayRecordField Is Nothing Then
                _displayRecordField = ""
            End If

            Dim thisLabel As SectionReportModel.Label
            If _fileName > "" Then
                thisLabel = New SectionReportModel.Label
                thisLabel.DataField = _fileName
                thisLabel.Name = "fileNameFieldForPDFExport"
                thisLabel.Visible = False
                thisSection.Controls.Add(thisLabel)
            End If
            If _displayRecordField > "" Then
                thisLabel = New SectionReportModel.Label
                thisLabel.DataField = _displayRecordField
                thisLabel.Name = "displayRecordFieldForPDFExport"
                thisLabel.Visible = False
                thisSection.Controls.Add(thisLabel)
            End If
            If _fileName > "" Or _displayRecordField > "" Then
                _pageCounter = New ActiveReportsPageCounter
            End If

        End Sub

        Private Sub partialReport_ReportEnd(sender As Object, e As EventArgs) Handles _partialReport.ReportEnd

            If _fileName > "" Or _displayRecordField > "" Then
                _pageCounter.EndCount()
            End If

        End Sub

        Private Sub partialReportSection_BeforePrint(sender As Object, e As EventArgs) _
                Handles _partialReportSection.BeforePrint

            Dim thisFileName As String = ""
            Dim thisDisplayRecord As Boolean = True
            Dim thisPage As Long
            If _fileName > "" Then
                'thisFileName = __partialReport.Fields(fileNameField).Value
                thisFileName = CType(_partialReportSection.Controls("fileNameFieldForPDFExport"), SectionReportModel.Label).Text
            End If
            If _displayRecordField > "" Then
                thisDisplayRecord = CType(CType(_partialReportSection.Controls("displayRecordFieldForPDFExport"), SectionReportModel.Label).Text, Boolean)
            End If
            If _fileName > "" Or _displayRecordField > "" Then
                thisPage = _partialReport.PageNumber
                _pageCounter.CheckPage(thisPage, thisFileName, thisDisplayRecord)
            End If

        End Sub

        Private Sub displosePartialReports()

            'dispose of all the helper report objects here
            For Each reportToDispose As SectionReport In _reportsToDispose
                reportToDispose.Document.Dispose()
                reportToDispose.Dispose()
            Next
            _reportsToDispose = Nothing

        End Sub
    </script>

</head>
<body>
<form id="frmReport" method="post" runat="server">
    <div class="reportExportLinks">
        <a id="uxExcelExport" runat="server"><img alt="Export to Excel" src='images/excelsmall.gif' /></a>
        <a id="uxWordExport" runat="server"><img alt="Export to Word" src='images/wordsmall.gif' /></a>
        <a id="uxPdfExport" runat="server"><img alt="Export to PDF" src='images/PDFiconsm.gif' /></a>
    </div>
    <ActiveReportsWeb:WebViewer ID="uxWebViewer" ViewerType="FlashViewer" Height="980px" Width="98%" runat="server" />
</form>
</body>
</html>
