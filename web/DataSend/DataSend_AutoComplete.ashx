<%@ WebHandler Language="VB" Class="AutoCompleteLookup" %>

Imports System.Web

Imports csi.Framework.ScreenData
Imports csi.Framework.Web
Imports csi.Framework.Security
Imports csi.Framework.ScreenDefinition
Imports csi.Framework.Utility
Imports System.Xml


'JDC TODO:
'much of this should probably be refactored for the new screen and screen factory stuff...

Public Class AutoCompleteLookup
    Implements System.Web.IHttpHandler

    Private _parameters As Parameters



    Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        ' Write your handler implementation here.

        _parameters = New Parameters(context.Request)

        Dim fieldName As String = context.Request.QueryString("FieldName")
        Dim searchTerm As String = context.Request.QueryString("term")
        Dim screenID As String = context.Request.QueryString("ScreenID")
        Dim _userName As String = Common.UserName(context)
        Dim value As String = context.Request.QueryString("value")


        Dim screen As Screen = ScreenDefinitionFactory.GetScreen(screenID)

        'Could have easily put the following four lines into one but chose not to for readability and possible use
        Dim mainScreenItem As ScreenItem = TemplateUtility.CheckAccess(_userName)
        Dim xmlFormLayout As XmlDocument = Common.getXMLDoc(context.Server.MapPath(mainScreenItem.FormatXML), HttpRuntime.Cache)
        Dim fieldNode As XmlNode = xmlFormLayout.SelectSingleNode("fieldList/section/field[@fieldName='" & fieldName & "']")
        Dim fieldNodes As IList(Of XmlNode) = New List(Of XmlNode)
        fieldNodes.Clear()
        fieldNodes.Add(fieldNode)
        Dim field As UIFieldProperty = New UIFieldProperty(fieldNodes)
        Dim lookupNode As XmlNode = field.LookupNodeList.Item(0)


        Dim options As IList(Of LookupOption) = New List(Of LookupOption)
        Dim fieldDefinition As FieldDefinition = screen.PrimaryScreenPart.GetFieldDefinitionWithLookup(fieldName)
        If value > "" Then
            options = ScreenDataFactory.GetLookupOptionsForAutoCompleteValue(fieldDefinition, value, _parameters.Array)
        ElseIf searchTerm > "" Then
            options = ScreenDataFactory.GetLookupOptionsForAutoComplete(fieldDefinition, searchTerm, _parameters.Array)
        End If

        writeOptionsAsJson(context.Response, options)

    End Sub

    ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property


    Private Shared Sub writeOptionsAsJson(response As HttpResponse, lookupOptions As IList(Of LookupOption))

        response.ContentType = "application/json"
        response.Write("[")
        Dim isFirstRow As Boolean = True
        For Each lookupOption As LookupOption In lookupOptions
            If Not isFirstRow Then
                response.Write(",")
            Else
                isFirstRow = False
            End If
            response.Write("{")
            writeJsonNameValuePair(response, "display", lookupOption.Text)
            response.Write(",")
            writeJsonNameValuePair(response, "value", lookupOption.ValueString)
            For Each keyValuePair As KeyValuePair(Of String, String) In lookupOption.AdditionalData
                response.Write(",")
                writeJsonNameValuePair(response, keyValuePair.Key, keyValuePair.Value)
            Next
            response.Write("}")
        Next
        response.Write("]")

    End Sub

    Private Shared Sub writeJsonNameValuePair(response As HttpResponse, name As String, value As String)

        response.Write("""")
        response.Write(name.Replace("""", "\"""))
        response.Write(""": """)
        response.Write(value.Replace("""", "\"""))
        response.Write("""")

    End Sub

End Class