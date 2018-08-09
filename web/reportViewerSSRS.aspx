<%@ Import Namespace="csi.Framework" %>
<%@ Import Namespace="Microsoft.Reporting.WebForms" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Drawing.Imaging" %>
<%@ Import Namespace="System.Drawing.Printing" %>
<%@ Import Namespace="csi" %>
<%@ Import Namespace="csi.Framework.Utility" %>
<%@ Import Namespace="csi.Framework.ScreenData" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=12.0.0.0, Culture=neutral" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
	<HEAD>
        <script language="VB" runat="server">



            'Inherits System.Web.UI.Page

            Dim csiSI As ScreenItem
            Dim csiSIRefs As List(Of ScreenItem)
            Dim paramArrayValues() As String
            Dim thisReport As LocalReport
            Dim sReportFormat As String = "PDF"
            Dim subReportHT As New Hashtable
            Dim _width As String = ""
            Dim _height As String = ""
            Dim _marginTop As String = ""
            Dim _marginLeft As String = ""
            Dim _marginBottom As String = ""
            Dim _marginRight As String = ""
            Dim _pageWidth As String = ""
            Dim _pageHeight As String = ""
            Dim _bDebug As Boolean = False

            Dim WithEvents printDoc As PrintDocument
            Dim sReturnReport As String
            Dim sReportName As String
            '	Dim eRpt As csi.Framework.errorReport2
            Private m_currentPageIndex As Integer
            Private m_streams As IList(Of Stream)
            Private m_fileName As String
            Private _printerName As String


            Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
                Dim reportArray As Byte() = Nothing
                Dim _oDebug As Object
                Dim sPrintReport As String

                'Dim _common As Common = New Common
                _oDebug = Request.Params("debug")
                If Not _oDebug Is Nothing Then
                    _bDebug = CBool(_oDebug)
                End If
                If Not Me.Page.IsPostBack Then
                    sReportFormat = Request.QueryString("ReportFormat")
                    csiSI = Common.ScreenReader.Item(Request.Params("screenID"), Common.UserName(Context))
                    If _bDebug Then
                        Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Loading report screen ID:" & csiSI.ID)
                    End If
                    sReportName = csiSI.PageName
                    If _bDebug Then
                        Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Loading report:" & sReportName)
                    End If

                    sPrintReport = Request.QueryString("PrintReport")
                    _printerName = Request.QueryString("PrinterName")

                    If sPrintReport Is Nothing Then
                        sPrintReport = ""
                    End If

                    If Not sReportName Is Nothing Then
                        If (Not sReportName.Trim() = String.Empty) Then
                            If Not CType(Request.Params("p"), String) = String.Empty Then
                                Dim currentParameters As Parameters = New Parameters(Request)
                                paramArrayValues = currentParameters.Array
                                'paramArrayValues = CType(Request.Params("p"), String).Split(New Char() {","c})
                            End If

                            If _bDebug Then
                                Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Loading report:" & sReportName & " calling RunScreenToReport")
                            End If
                            RunScreenToRpt(csiSI)
                            If _bDebug Then
                                Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Loading report:" & sReportName & " Done calling RunScreenToReport")
                            End If

                            ' Clear anything that might have been written by the aspx page
                            Me.Page.Response.ClearContent()
                            Me.Page.Response.ClearHeaders()
                            If sPrintReport.ToLower() = "true" Then
                                ExportReportToEMF(thisReport)
                                m_currentPageIndex = 0
                                Print()
                                Response.Write("<html><body onLoad='self.close();' /></html>")
                            ElseIf sReportFormat = "PDF" Then
                                reportArray = ExportReportToPDF(thisReport)
                                Response.AddHeader("Content-Length", CStr(reportArray.Length))
                                Response.AddHeader("Content-Disposition", "inline; filename=MyPDF.PDF")
                                Response.ContentType = "application/pdf"
                            ElseIf sReportFormat = "Excel" Then
                                reportArray = ExportReportToExcel(thisReport)
                                Response.AddHeader("Content-Length", CStr(reportArray.Length))
                                'Response.AddHeader("Content-Disposition", "inline; filename=MyXLS.xls")
                                Response.AddHeader("Content-Disposition", "inline")
                                Response.ContentType = "application/vnd.ms-excel"
                                Response.Charset = ""

                            End If

                            If reportArray IsNot Nothing Then
                                Response.BinaryWrite(reportArray)
                            End If
                            'Response.BinaryWrite(myStream.ToArray())
                            ' Send all buffered content to the client
                            Response.End()
                        End If
                    End If
                End If
            End Sub

            Private Function ExportReportToPDF(_report As LocalReport) As Byte()
                Dim PDF As Byte()
                Dim deviceInfo As String
                Dim warnings As Warning() = Nothing
                Dim streamids As String() = Nothing
                Dim mimeType As String = Nothing
                Dim encoding As String = Nothing
                Dim extension As String = Nothing
                Dim thisWarning As Warning

                deviceInfo = "<DeviceInfo><StartPage>0</StartPage>"
                If _width > "" Then
                    deviceInfo = deviceInfo + "<PageWidth>" + _pageWidth + "</PageWidth>"
                End If
                If _height > "" Then
                    deviceInfo = deviceInfo + "<PageHeight>" + _pageHeight + "</PageHeight>"
                End If
                If _marginTop > "" Then
                    deviceInfo = deviceInfo + "<MarginTop>" + _marginTop + "</MarginTop>"
                End If
                If _marginLeft > "" Then
                    deviceInfo = deviceInfo + "<MarginLeft>" + _marginLeft + "</MarginLeft>"
                End If
                If _marginBottom > "" Then
                    deviceInfo = deviceInfo + "<MarginBottom>" + _marginBottom + "</MarginBottom>"
                End If
                If _marginRight > "" Then
                    deviceInfo = deviceInfo + "<MarginRight>" + _marginRight + "</MarginRight>"
                End If
                deviceInfo = deviceInfo + "</DeviceInfo>"
                'Dim _common As Common = New Common
                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Device Info:" & deviceInfo)
                End If
                PDF = thisReport.Render("PDF", deviceInfo, mimeType, encoding, extension, streamids, warnings)

                If Not warnings Is Nothing And _bDebug Then
                    For Each thisWarning In warnings
                        Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Error processing report " & Request.Params("screenID") & ".  " & thisWarning.Message)
                    Next
                End If
                '_common = Nothing
                Return PDF
            End Function

            Private Function ExportReportToExcel(_report As LocalReport) As Byte()
                Dim XLS As Byte()
                Dim deviceInfo As String = "<DeviceInfo></DeviceInfo>"
                Dim warnings As Warning() = Nothing
                Dim streamids As String() = Nothing
                Dim mimeType As String = Nothing
                Dim encoding As String = Nothing
                Dim extension As String = Nothing
                Dim thisWarning As Warning

                XLS = thisReport.Render("Excel", deviceInfo, mimeType, encoding, extension, streamids, warnings)
                If Not warnings Is Nothing And _bDebug Then
                    'Dim _common As Common = New Common
                    For Each thisWarning In warnings
                        Common.WriteEntryToLogFile("Error processing report " & Request.Params("screenID") & ".  " & thisWarning.Message, "Error processing SSRS report.")
                    Next
                    '_common = Nothing
                End If

                Return XLS
            End Function

            Private Function CreateStream(name As String,
               fileNameExtension As String,
               encoding As Encoding, mimeType As String,
               willSeek As Boolean) As Stream

                'Create file in temp subdirectory of main application directory
                m_fileName = Server.MapPath("") & "\temp\" + name + Guid.NewGuid().ToString() + "." + fileNameExtension



                Dim stream As Stream = New FileStream(m_fileName, FileMode.Create)
                m_streams.Add(stream)

                'Dim _common As New Common
                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Created Stream: " & m_fileName)

                End If
                '_common = Nothing

                Return stream
            End Function

            Private Sub ExportReportToEMF(report As LocalReport)
                Dim deviceInfo As String '= _
                '"<DeviceInfo>" + _
                '"  <OutputFormat>EMF</OutputFormat>" + _
                '"  <PageWidth>8.5in</PageWidth>" + _
                '"  <PageHeight>11in</PageHeight>" + _
                '"  <MarginTop>0.25in</MarginTop>" + _
                '"  <MarginLeft>0.25in</MarginLeft>" + _
                '"  <MarginRight>0.25in</MarginRight>" + _
                '"  <MarginBottom>0.25in</MarginBottom>" + _
                '"</DeviceInfo>"
                Dim thisWarning As Warning

                deviceInfo = "<DeviceInfo><StartPage>0</StartPage><OutputFormat>EMF</OutputFormat>"
                If _width > "" Then
                    deviceInfo = deviceInfo + "<PageWidth>" + _pageWidth + "</PageWidth>"
                End If
                If _height > "" Then
                    deviceInfo = deviceInfo + "<PageHeight>" + _pageHeight + "</PageHeight>"
                End If
                If _marginTop > "" Then
                    deviceInfo = deviceInfo + "<MarginTop>" + _marginTop + "</MarginTop>"
                End If
                If _marginLeft > "" Then
                    deviceInfo = deviceInfo + "<MarginLeft>" + _marginLeft + "</MarginLeft>"
                End If
                If _marginBottom > "" Then
                    deviceInfo = deviceInfo + "<MarginBottom>" + _marginBottom + "</MarginBottom>"
                End If
                If _marginRight > "" Then
                    deviceInfo = deviceInfo + "<MarginRight>" + _marginRight + "</MarginRight>"
                End If
                deviceInfo = deviceInfo + "</DeviceInfo>"

                Dim warnings() As Warning = Nothing
                m_streams = New List(Of Stream)()
                report.Render("Image", deviceInfo, AddressOf CreateStream,
                   warnings)

                'Dim _common As New Common
                If Not warnings Is Nothing And _bDebug Then
                    For Each thisWarning In warnings
                        Common.WriteEntryToLogFile("Error processing report " & Request.Params("screenID") & ".  " & thisWarning.Message, "Error processing SSRS report.")
                    Next
                End If
                '_common = Nothing

                Dim stream As Stream
                For Each stream In m_streams
                    stream.Position = 0
                Next
            End Sub

            Private Sub PrintPage(sender As Object,
            ev As PrintPageEventArgs)
                Dim pageImage As New Metafile(m_streams(m_currentPageIndex))
                'Dim _common As Common = New Common
                ev.Graphics.DrawImage(pageImage, ev.PageBounds)

                m_currentPageIndex += 1

                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - page: " & m_currentPageIndex.ToString)
                End If
                ev.HasMorePages = (m_currentPageIndex < m_streams.Count)
            End Sub

            Private Sub Print()
                'Dim _domain As String
                'Dim _user As String
                'Dim _password As String

                If _bDebug And Not m_streams Is Nothing Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - stream count" & m_streams.Count)
                End If

                If m_streams Is Nothing Or m_streams.Count = 0 Then
                    Return
                End If

                printDoc = New PrintDocument()
                Dim printTo As String = ""

                For Each thisPrinterName As String In PrinterSettings.InstalledPrinters
                    If _bDebug Then
                        Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Checking if " & thisPrinterName & " is the selected printer.")
                    End If
                    If thisPrinterName = _printerName Then
                        printTo = _printerName
                        Exit For
                    End If
                Next
                If printTo = "" Then
                    For Each thisPrinterName As String In PrinterSettings.InstalledPrinters
                        If _bDebug Then
                            Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Checking if " & thisPrinterName & " is default.")
                        End If
                        printDoc.PrinterSettings.PrinterName = thisPrinterName
                        If _bDebug Then
                            Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), thisPrinterName & " IsDefault:" & printDoc.PrinterSettings.IsDefaultPrinter.ToString)
                        End If
                        If printDoc.PrinterSettings.IsDefaultPrinter Then
                            printTo = thisPrinterName
                            Exit For
                        End If
                    Next
                End If
                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - printer name: " & printTo)
                End If

                Try
                    printDoc.PrinterSettings.PrinterName = printTo
                Catch ex As System.Exception
                    If _bDebug Then
                        Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - error setting printer name: " & ex.Message)
                        If ex.InnerException IsNot Nothing Then
                            Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - error setting printer name inner exception: " & ex.InnerException.Message)
                        End If
                    End If
                End Try
                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - done setting printer name.")
                End If

                'If Not printDoc.PrinterSettings.IsValid Then
                '    Dim msg As String = String.Format( _
                '        "Can't find printer ""{0}"".", _printerName)
                '    Response.Write(msg)

                '    If _bDebug Then
                '        Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - " & msg)
                '    End If
                'End If

                'If _bDebug Then
                '    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - done validating printer name")
                'End If
                AddHandler printDoc.PrintPage, AddressOf PrintPage

                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - done adding handler")
                End If

                If Not _bDebug = True Then
                    printDoc.Print()
                End If

                'close all file streams that make up the current report
                For i As Integer = 0 To m_streams.Count - 1
                    If _bDebug Then
                        Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Closing Stream: " & i.ToString)
                    End If
                    m_streams(i).Close()
                Next

                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - done printDoc.print")
                End If

                'delete the file when it is done printing
                If m_fileName > "" Then
                    File.Delete(m_fileName)
                End If

                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Printing report - Deleted report image: " & m_fileName)
                End If


            End Sub

            Private Sub RunScreenToRpt(thisSI As ScreenItem)
                Dim screenItem As ScreenItem
                Dim sbData = New StringBuilder
                Dim thisDT As DataTable
                Dim thisFramework = New Data
                Dim thisXML As New XmlDocument
                Dim dsName As String = "defaultDataSource"
                Dim sql As String
                Dim _paramList As XmlNodeList
                Dim _paramNode As XmlNode
                Dim _param As ReportParameter
                Dim i As Integer
                Dim additionalDataSetHT As New Hashtable
                Dim num As Decimal
                Dim _params As System.Collections.Generic.List(Of Microsoft.Reporting.WebForms.ReportParameter)

                thisReport = New LocalReport

                Dim ms As MemoryStream
                Dim sw As StreamWriter
                Dim _paramNodeChild As XmlNode
                Dim needToRewriteDefinition As Boolean
                subReportHT.Clear()
                'handle subreport screen refs here
                csiSIRefs = Common.ScreenReader.References(Request.Params("screenID"), "subreport", Common.UserName(Context))
                If Not csiSIRefs Is Nothing Then
                    For Each screenItem In csiSIRefs
                        thisXML.Load(Server.MapPath(screenItem.PageName))
                        needToRewriteDefinition = False
                        _paramList = thisXML.GetElementsByTagName("ReportParameter")
                        For Each _paramNode In _paramList
                            For Each _paramNodeChild In _paramNode.ChildNodes
                                If _paramNodeChild.Name = "ValidValues" Then
                                    _paramNode.RemoveChild(_paramNodeChild)
                                    needToRewriteDefinition = True
                                End If
                            Next
                        Next
                        If needToRewriteDefinition Then
                            thisXML.Save(Server.MapPath(screenItem.PageName))
                        End If
                        subReportHT.Add(screenItem.DisplayName, screenItem.ID)
                        ms = New MemoryStream()
                        sw = New StreamWriter(ms)
                        sw.Write(thisXML.OuterXml)
                        sw.Flush()
                    Next
                End If

                thisReport.ReportPath = sReportName

                thisXML.Load(Server.MapPath(sReportName))

                _paramList = thisXML.GetElementsByTagName("Report")

                For Each _paramNode In _paramList(0).ChildNodes
                    If _paramNode.Name = "Width" Then
                        _width = _paramNode.InnerText
                    End If
                    If _paramNode.Name = "Height" Then
                        _height = _paramNode.InnerText
                    End If
                    If _paramNode.Name = "PageWidth" Then
                        _pageWidth = _paramNode.InnerText
                    End If
                    If _paramNode.Name = "PageHeight" Then
                        _pageHeight = _paramNode.InnerText
                    End If
                    If _paramNode.Name = "TopMargin" Then
                        _marginTop = _paramNode.InnerText
                    End If
                    If _paramNode.Name = "LeftMargin" Then
                        _marginLeft = _paramNode.InnerText
                    End If
                    If _paramNode.Name = "BottomMargin" Then
                        _marginBottom = _paramNode.InnerText
                    End If
                    If _paramNode.Name = "RightMargin" Then
                        _marginRight = _paramNode.InnerText
                    End If
                Next
                If _pageWidth = "" And _width > "" Then
                    num = CType(_width.Replace("in", ""), Decimal)
                    If _marginLeft > "" Then
                        num = num + CType(_marginLeft.Replace("in", ""), Decimal)
                    End If
                    If _marginRight > "" Then
                        num = num + CType(_marginRight.Replace("in", ""), Decimal)
                    End If
                    _pageWidth = CType(num, String) + "in"
                End If
                If _pageHeight = "" And _height > "" Then
                    num = CType(_height.Replace("in", ""), Decimal)
                    If _marginTop > "" Then
                        num = num + CType(_marginTop.Replace("in", ""), Decimal)
                    End If
                    If _marginBottom > "" Then
                        num = num + CType(_marginBottom.Replace("in", ""), Decimal)
                    End If
                    _pageHeight = CType(num, String) + "in"
                End If
                'If CType(_pageWidth.Replace("in", ""), Decimal) > 8.5 And CType(_pageWidth.Replace("in", ""), Decimal) < 12 Then
                '    _pageWidth = "11in"
                '    If _pageHeight = "" Then
                '        _height = "8.5in"
                '    End If
                'End If
                _paramList = Nothing

                _paramList = thisXML.GetElementsByTagName("ReportParameter")

                additionalDataSetHT.Clear()

                thisReport.DataSources.Clear()

                'handle additionalDataSet screen refs here
                csiSIRefs = Common.ScreenReader.References(Request.Params("screenID"), "additionalDataSet", Common.UserName(Context))
                If Not csiSIRefs Is Nothing Then
                    For Each screenItem In csiSIRefs
                        additionalDataSetHT.Add(screenItem.DisplayName, screenItem.ID)
                    Next
                End If

                Dim oCmdTimeout As Object
                oCmdTimeout = System.Configuration.ConfigurationManager.AppSettings("ReportCmdTimeout")
                'default to 120 seconds, pull from ReportCmdTimeout web config key if it's there
                thisFramework.CmdTimeout = 120
                If Not oCmdTimeout Is Nothing Then
                    If IsNumeric(oCmdTimeout) Then
                        thisFramework.CmdTimeout = CType(oCmdTimeout, Integer)
                    End If
                End If

                'now load up the datasources
                For Each dsName In thisReport.GetDataSourceNames()
                    'if our list of additional datasets contains this dataset name, look up the reference screen and run it's datastatement
                    If additionalDataSetHT.Contains(dsName) Then
                        csiSI = Common.ScreenReader.Item(CStr(additionalDataSetHT(dsName)), Common.UserName(Context))

                        sql = Common.ReplaceVariables(csiSI.DataStatement, CType(Me.Context.Session("applicationVariable"), Hashtable))
                        If Not paramArrayValues Is Nothing Then
                            sql = String.Format(sql, paramArrayValues)
                        End If
                        thisDT = thisFramework.SQL_to_DataSet(sql).Tables(0)
                        If Not thisDT Is Nothing Then
                            thisReport.DataSources.Add(New ReportDataSource(dsName, thisDT))
                        End If
                        'otherwise use the main dataset of the subreport screen
                    Else
                        sql = Common.ReplaceVariables(thisSI.DataStatement, CType(Me.Context.Session("applicationVariable"), Hashtable))
                        If Not paramArrayValues Is Nothing Then
                            sql = String.Format(sql, paramArrayValues)
                        End If
                        thisDT = thisFramework.SQL_to_DataSet(sql).Tables(0)
                        If Not thisDT Is Nothing Then
                            thisReport.DataSources.Add(New ReportDataSource(dsName, thisDT))
                        End If
                    End If
                Next

                If Not _paramList Is Nothing Then

                    i = 0
                    'ReDim _params(_paramList.Count)
                    _params = New System.Collections.Generic.List(Of Microsoft.Reporting.WebForms.ReportParameter)()
                    For Each _paramNode In _paramList
                        If paramArrayValues.Length <= i Then
                            _param = New ReportParameter(_paramNode.Attributes("Name").Value, "", False)
                        Else
                            _param = New ReportParameter(_paramNode.Attributes("Name").Value, paramArrayValues(i), False)
                        End If
                        _params.Add(_param)
                        i = i + 1
                    Next
                    thisReport.SetParameters(_params)
                End If

                'Add a handler for drillthrough.
                AddHandler thisReport.SubreportProcessing, AddressOf SubreportProcessingEventHandler

                thisFramework.Close()
                thisFramework = Nothing
                'End If
            End Sub

            Private Sub SubreportProcessingEventHandler(sender As Object, e As SubreportProcessingEventArgs)
                Dim thisDT As DataTable
                Dim dsName As String
                Dim subReportScreenID As String
                Dim additionalDataSetHT As New Hashtable
                Dim csiSIRef As ScreenItem
                Dim sql As String = ""
                Dim thisFramework As Data = New Data
                Dim SubReportParamArray As String()
                Dim i As Integer
                Dim param As ReportParameterInfo

                subReportScreenID = CStr(subReportHT(e.ReportPath))
                csiSI = Common.ScreenReader.Item(subReportScreenID, Common.UserName(Context))

                If Not csiSI Is Nothing Then
                    csiSIRefs = Common.ScreenReader.References(subReportScreenID, "additionalDataSet", Common.UserName(Context))
                    additionalDataSetHT.Clear()
                    'get a list of all of the attached dataset names
                    If Not csiSIRefs Is Nothing Then
                        For Each csiSIRef In csiSIRefs
                            additionalDataSetHT.Add(csiSIRef.DisplayName, csiSIRef.ID)
                        Next
                    End If

                    i = 0
                    ReDim SubReportParamArray(e.Parameters.Count)
                    For Each param In e.Parameters
                        SubReportParamArray(i) = param.Values(0)
                        i = i + 1
                    Next

                    For Each dsName In e.DataSourceNames
                        'if our list of additional datasets contains this dataset name, look up the reference screen and run it's datastatement
                        If additionalDataSetHT.Contains(dsName) Then
                            Try
                                csiSIRef = Common.ScreenReader.Item(CStr(additionalDataSetHT(dsName)), Common.UserName(Context))

                                sql = Common.ReplaceVariables(csiSIRef.DataStatement, CType(Me.Context.Session("applicationVariable"), Hashtable))
                                If Not SubReportParamArray Is Nothing Then

                                    sql = String.Format(sql, SubReportParamArray)
                                    'sql = String.Format(sql, paramArrayValues)
                                End If
                                thisDT = thisFramework.SQL_to_DataSet(sql).Tables(0)
                                If Not thisDT Is Nothing Then
                                    e.DataSources.Add(New ReportDataSource(dsName, thisDT))
                                End If
                            Catch ex As Exception
                                Common.WriteEntryToLogFile("Error processing report " & Request.Params("screenID") & ".  " & ex.Message & "  " & sql, "Error processing SSRS report.")

                            End Try
                            'otherwise use the main dataset of the subreport screen
                        Else
                            Try
                                sql = Common.ReplaceVariables(csiSI.DataStatement, CType(Me.Context.Session("applicationVariable"), Hashtable))
                                'If Not paramArrayValues Is Nothing Then
                                '    sql = String.Format(sql, paramArrayValues)
                                'End If
                                If Not SubReportParamArray Is Nothing Then
                                    sql = String.Format(sql, SubReportParamArray)
                                End If
                                thisDT = thisFramework.SQL_to_DataSet(sql).Tables(0)
                                If Not thisDT Is Nothing Then
                                    e.DataSources.Add(New ReportDataSource(dsName, thisDT))
                                End If
                            Catch ex As Exception
                                Common.WriteEntryToLogFile("Error processing report " & Request.Params("screenID") & ".  " & ex.Message & "  " & sql, "Error processing SSRS report.")
                            End Try
                        End If
                    Next
                    thisReport.Refresh()
                End If

                thisFramework.Close()
                thisFramework = Nothing
                additionalDataSetHT.Clear()
                additionalDataSetHT = Nothing
            End Sub

            Private Sub printDoc_BeginPrint(sender As Object, e As System.Drawing.Printing.PrintEventArgs) Handles printDoc.BeginPrint
                'Dim _common As New Common
                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "Begin Print")
                End If
                '_common = Nothing

            End Sub

            Private Sub printDoc_EndPrint(sender As Object, e As System.Drawing.Printing.PrintEventArgs) Handles printDoc.EndPrint
                'Dim _common As New Common
                If _bDebug Then
                    Common.WriteEntryToLogFile(Server.MapPath("SSRS Log.txt"), "End Print")
                End If
                '_common = Nothing

            End Sub

        </script>

		<title></title>
	</HEAD>
	<body>
		<form id="frmReport" method="post" runat="server">
			<input id="redirectURL" type="hidden" name="redirectURL" runat="server">
		</form>
	</body>
</HTML>

