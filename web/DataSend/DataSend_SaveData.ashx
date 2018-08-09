<%@ WebHandler Language="VB" Class="csbAngular_SaveDataForScreen" %>

Imports System
Imports System.Web
Imports System.Collections
Imports csi.Framework.ScreenData
Imports csi.Framework.Web
Imports csi.Framework.Security
Imports csi.Framework.ScreenDefinition
Imports csi.Framework.Utility
Imports System.Data.SqlClient

Public Class csbAngular_SaveDataForScreen : Implements IHttpHandler
    Private _mainScreenItem As csi.Framework.ScreenData.ScreenItem
    Private _formToXML As csi.Framework.ScreenData.FormToXML = New csi.Framework.ScreenData.FormToXML()
    Private cConnect As csi.Framework.ScreenData.cConnect
    Private Common As csi.Framework.Utility.Common = New csi.Framework.Utility.Common()
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "text/html"
        'Dim sScreenID As String

        'get the screen id
        If context.Request.QueryString("ScreenID") > "" Then

            'load the update xml
            Dim _userName As String = Common.UserName(context)
            _mainScreenItem = TemplateUtility.CheckAccess(_userName)

            'if no updatexml or not allowed to update, exit
            If _mainScreenItem.UpdateXML.Length = 0 Then
                Exit Sub
            End If
            If Not _mainScreenItem.AllowUpdate Then
                Exit Sub
            End If
            'unpack the json that is streamed to handler
            Dim streamRead As IO.StreamReader = New IO.StreamReader(context.Request.InputStream)
            Dim JSON_DictionaryLength As Integer = 0

            context.Request.InputStream.Position = 0
            Dim sJSON As String = streamRead.ReadToEnd()

            streamRead.Close()
            streamRead.Dispose()
            Dim fileRead As IO.StreamReader = New IO.StreamReader(HttpRuntime.AppDomainAppPath & _mainScreenItem.UpdateXML.Replace("~", ""))
            Dim updateXMLString As String = fileRead.ReadToEnd()
            fileRead.Close()
            fileRead.Dispose()
            Dim updateXMLDoc As New System.Xml.XmlDocument()
            updateXMLDoc.LoadXml(updateXMLString)
            If String.IsNullOrWhiteSpace(sJSON) OrElse sJSON = "[]" Then
                Exit Sub
            End If

            Dim JSON_HashTable As Hashtable = Common.JSON_ParseSimpleToHashTable(sJSON)
            Dim ProcessAsSet As Boolean = False
            Try
                Dim p As String = updateXMLDoc.FirstChild.Attributes.GetNamedItem("processAsSet").Value
                ProcessAsSet = p.ToUpper() = "TRUE" Or p = "1"
            Catch ex As Exception
                ProcessAsSet = False
            End Try

            If ProcessAsSet Then
                'Process data as set

                'create data table with updateXML layout
                Dim dt As New System.Data.DataTable()
                For Each n As System.Xml.XmlNode In updateXMLDoc.FirstChild.FirstChild.ChildNodes
                    dt.Columns.Add(n.Name)

                Next
                For Each key As Int32 In JSON_HashTable.Keys
                    Dim r As System.Data.DataRow = dt.NewRow()
                    For Each col As System.Data.DataColumn In dt.Columns
                        If col.ColumnName = "UserName" Then
                            r(col.ColumnName) = _userName
                        Else
                            r(col.ColumnName) = JSON_HashTable(key)(col.ColumnName)
                        End If
                    Next
                    dt.Rows.Add(r)
                Next
                'send datatable to proc
                If dt.Rows.Count > 0 Then

                    cConnect = New csi.Framework.ScreenData.cConnect()
                    Dim bStatus As Boolean = cConnect.ExecuteSet(updateXMLDoc.FirstChild.FirstChild.Name, dt)
                    'return any error
                    Dim rowID As String = ""
                    Dim idFieldName As String = ""
                    If cConnect.RowID IsNot Nothing And cConnect.RowID > "" Then
                        rowID = cConnect.RowID
                        idFieldName = cConnect.idFieldName
                    End If
                    If Not bStatus Then
                        'there was an error...deal with the error collection....
                        'context.Response.Write("error...")

                        ProcessDataTableToJSON(cConnect.ErrorCollection.ToTable, context.Response, rowID, idFieldName)
                    End If
                End If

            Else
                'load xml with changes

                'map to xml
                Dim thisXMLDoc As System.Xml.XmlDocument

                _formToXML.XMLTemplateFileName = context.Server.MapPath(_mainScreenItem.UpdateXML)
                thisXMLDoc = _formToXML.MapToXML(JSON_HashTable)
                'submit the xml
                cConnect = New csi.Framework.ScreenData.cConnect()
                Dim bStatus As Boolean = cConnect.Execute(thisXMLDoc)
                'return any error
                Dim rowID As String = ""
                Dim idFieldName As String = ""
                If cConnect.RowID IsNot Nothing And cConnect.RowID > "" Then
                    rowID = cConnect.RowID
                    idFieldName = cConnect.idFieldName
                End If
                If Not bStatus Then
                    'there was an error...deal with the error collection....
                    'context.Response.Write("error...")

                    ProcessDataTableToJSON(cConnect.ErrorCollection.ToTable, context.Response, rowID, idFieldName)

                ElseIf rowID > "" Then
                    'send back the row id
                    context.Response.Write("[{""iRowID"":""" & rowID & """,""idFieldName"":""" & idFieldName & """}]")
                End If

            End If
            'TODO:  return the row ID?

        End If

    End Sub


    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

    Private Sub ProcessDataTableToJSON(thisDT As System.Data.DataTable, Response As HttpResponse, rowID As String, idFieldName As String)

        Dim firstRow = True, firstColumn = True
        Dim thisDR As System.Data.DataRow
        Dim myCol As System.Data.DataColumn

        Response.Write("[")
        If rowID > "" Then
            Response.Write("{""iRowID"":""" & rowID & """,""idFieldName"":""" & idFieldName & """},")
        End If
        For Each thisDR In thisDT.Rows
            If firstRow = False Then
                Response.Write(",")
            Else
                firstRow = False
            End If
            Response.Write("{")
            firstColumn = True
            For Each myCol In thisDR.Table.Columns
                If firstColumn = False Then
                    Response.Write(",")
                Else
                    firstColumn = False
                End If
                'hard coded for now.....consider generalizing
                If myCol.Ordinal = 0 Then
                    myCol.ColumnName = "display"
                End If
                If myCol.Ordinal = 1 Then
                    myCol.ColumnName = "value"
                End If
                Response.Write("""" + Common.JSON_Encode(myCol, True) + """:""" + Common.JSON_Encode(thisDR.Item(myCol), True) + """")
            Next
            Response.Write("}")
        Next
        Response.Write("]")

    End Sub


End Class