<%@ WebHandler Language="VB" Class="csbAngular_SaveDataForScreen" %>

Imports System
Imports System.Web
Imports System.Collections
Imports csi.Framework.ScreenData
Imports csi.Framework.Web
Imports csi.Framework.Security
Imports csi.Framework.ScreenDefinition
Imports csi.Framework.Utility


Public Class csbAngular_SaveDataForScreen : Implements IHttpHandler
    Private _mainScreenItem As csi.Framework.ScreenData.ScreenItem
    Private _formToXML As csi.Framework.ScreenData.FormToXML = New csi.Framework.ScreenData.FormToXML()
    Private cConnect As csi.Framework.ScreenData.cConnect
    Private Common As csi.Framework.Utility.Common = New csi.Framework.Utility.Common()
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "text/html"
        Dim sScreenID As String = context.Request.QueryString("ScreenID")

        'get the screen id
        If sScreenID > "" Then

            'load the update xml
            Dim _userName As String = Common.UserName(context)
            Dim reportRef As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
            reportRef = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "report", Common.UserName(context))

            _mainScreenItem = reportRef.Item(0)

            'if no updatexml or not allowed to update, exit
            If _mainScreenItem.UpdateXML.Length = 0 Then
                Exit Sub
            End If
            'unpack the json that is streamed to handler
            Dim streamRead As IO.StreamReader = New IO.StreamReader(context.Request.InputStream)
            Dim JSON_DictionaryLength As Integer = 0

            context.Request.InputStream.Position = 0
            Dim sJSON As String = streamRead.ReadToEnd()

            streamRead.Close()
            streamRead.Dispose()

            If String.IsNullOrWhiteSpace(sJSON) OrElse sJSON = "[]" Then
                Exit Sub
            End If

            Dim JSON_HashTable As Hashtable = Common.JSON_ParseSimpleToHashTable(sJSON)

            'map to xml
            Dim thisXMLDoc As System.Xml.XmlDocument

            _formToXML.XMLTemplateFileName = context.Server.MapPath(_mainScreenItem.UpdateXML)
            thisXMLDoc = _formToXML.MapToXML(JSON_HashTable)

            Dim paramString As StringBuilder = New StringBuilder("")

            For Each thisNode As System.Xml.XmlNode In thisXMLDoc.ChildNodes(0).ChildNodes
                paramString.Append("&p=")
                paramString.Append(thisNode.InnerXml.Replace("#", "%23"))
            Next thisNode

            paramString.Append("&p=")
            context.Response.Write("[{""parameters"":""")
            context.Response.Write(paramString.ToString())
            context.Response.Write("""}]")

        End If

    End Sub


    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property




End Class