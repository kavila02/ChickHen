<%@ Import Namespace="csi.Framework.ScreenData" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="csi.Framework.Utility" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
	<title>Processing...</title>
	<meta http-equiv="refresh" content="5" />
</head>
<body id="runProcessBody">
	<form id="Form1" method="post" runat="server">
		<div align="center">
			<img src="images\ProgressIndicatorAni.gif" /><br />
			<div id="refreshMessage" runat="server">Processing...</div>
		</div>
	</form>
</body>
</html>

<script language="VB" runat="server">

    Private Sub Page_Load(sender As Object, e As EventArgs) Handles MyBase.Load

        Dim userName As String = Common.UserName(Context)
        Dim currentScreenItem As ScreenItem = TemplateUtility.CheckAccess(userName)
        Dim currentQueryStringParameterValues As String() = getCurrentQueryStringParameterValues(Context)
        DefaultApplicationVariableHashTable()
        Dim redirectDataView As DataView = executePreProcessSql(currentScreenItem, _
        currentQueryStringParameterValues)
        Dim redirectReference As ScreenItem = getRedirectReference(userName, currentScreenItem, _
                redirectDataView)
        Dim redirectQueryString As String = getRedirectQueryString(Context, redirectDataView)
        Dim redirectUrl As String = getRedirectUrl(userName, redirectReference, redirectQueryString)



        ' This is most commonly true because redirectUrl is an empty string...
        If Request.RawUrl.EndsWith(redirectUrl.Replace(" ", "%20")) Then
            refreshMessage.InnerText = getStatusMessage(userName, currentScreenItem.ID, _
                    currentQueryStringParameterValues, redirectReference)
        Else
            Response.Redirect(redirectUrl)
        End If

    End Sub

    Private Sub DefaultApplicationVariableHashTable()
        Dim thisHashTable As Hashtable

        If Context.Session("applicationVariable") Is Nothing Then
            thisHashTable = New Hashtable

        Else

            thisHashTable = CType(Context.Session("applicationVariable"), Hashtable)

        End If

        If Not thisHashTable.ContainsKey("UserName") Then
            thisHashTable.Add("UserName", Context.User.Identity.Name)
        ElseIf thisHashTable.Item("UserName").ToString = "" Then
            thisHashTable.Item("UserName") = Context.User.Identity.Name
        End If

        'For now, slam in a UserDate for testing againsts Creamery
        If Not thisHashTable.ContainsKey("UserDate") Then
            thisHashTable.Add("UserDate", New Date().ToString("MM/dd/yyyy"))
        ElseIf thisHashTable.Item("UserDate").ToString = "" Then
            thisHashTable.Item("UserDate") = New Date().ToString("MM/dd/yyyy")
        End If


        Context.Session("applicationVariable") = thisHashTable
    End Sub

    Private Shared Function getCurrentQueryStringParameterValues(context As HttpContext) As String()

        Dim parametersAsString As String = If(context.Request.Params("p"), "")
        Return parametersAsString.Split(","c)

    End Function

    Private Shared Function executePreProcessSql(currentScreenItem As ScreenItem,
                queryStringParameterValues As String()) As DataView

        Return getDataView(currentScreenItem, queryStringParameterValues)

    End Function

    Private Shared Function getDataView(screenItem As ScreenItem,
                queryStringParameterValues As String()) As DataView

        Dim dataSet As DataSet = Data.GetDataSet(screenItem.DataStatement, queryStringParameterValues)
        Return If(dataSet.Tables.Count > 0 AndAlso dataSet.Tables(0).Rows.Count > 0, _
                  dataSet.Tables(0).DefaultView, _
                  Nothing)

    End Function

    Private Shared Function getRedirectReferenceType(dataView As DataView) As String

        If dataView IsNot Nothing AndAlso dataView.Table.Columns.Contains("ReferenceType") Then
            Return dataView.Item(0).Item("ReferenceType").ToString()
        Else
            Return "navigate to"
        End If

    End Function

    Private Shared Function getRedirectQueryString(context As HttpContext, dataView As DataView) As String

        Dim queryString As String = ""
        Dim isFirst As Boolean = True
        If dataView IsNot Nothing AndAlso dataView.Table.Columns.Contains("ReferenceType") Then
            For i As Integer = 0 To dataView.Table.Columns.Count - 1
                If dataView.Table.Columns(i).ColumnName <> "ReferenceType" Then
                    queryString &= If(Not isFirst, "&p=", "")
                    queryString &= dataView.Item(0).Item(i).ToString()
                    isFirst = False
                End If
            Next
        Else
            queryString = context.Request.Params("p").Replace(",", "&p=")
        End If

        For Each queryStringKey As String In context.Request.QueryString.Keys
            If queryStringKey <> "p" And queryStringKey.ToLower <> "screenid" Then
                queryString &= "&" & queryStringKey & "=" & context.Request.QueryString(queryStringKey)
            End If
        Next
        Return queryString

    End Function

    Private Shared Function getRedirectReference(userName As String, currentScreenItem As ScreenItem, _
            redirectDataView As DataView) As ScreenItem

        Dim redirectReferenceType As String = getRedirectReferenceType(redirectDataView)
        Dim redirectReferences As List(Of ScreenItem) = Common.ScreenReader.References(currentScreenItem.ID, _
                redirectReferenceType, userName)
        If redirectReferences Is Nothing Then
            redirectReferences = Common.ScreenReader.References(currentScreenItem.ID, "navigate to", userName)
        End If
        If Not redirectReferences Is Nothing Then
            For Each redirectReference As ScreenItem In redirectReferences
                ' It doesn't make sense to have multiple, but if there are more than one, then first one wins...
                Return redirectReference
            Next redirectReference
        End If
        Return Nothing

    End Function

    Private Shared Function getRedirectUrl(userName As String, redirectReference As ScreenItem, _
            redirectQueryString As String) As String

        If redirectReference IsNot Nothing Then
            Dim url As String = Common.ScreenReader.RenderHREF(redirectReference.ID, False, _
                    redirectQueryString, userName)
            If redirectReference.DisplayStyle > "" Then
                url &= "&detailScreenID=" & redirectReference.DisplayStyle
            End If
            Return url
        Else
            Return ""
        End If

    End Function

    Private Shared Function getStatusMessage(userName As String, screenID As String, _
            queryStringParameterValues As String(), redirectReference As ScreenItem) As String

        Dim statusMessageReferences As List(Of ScreenItem) = Common.ScreenReader.References(screenID, "statusMessage", userName)
        If Not statusMessageReferences Is Nothing Then
            For Each statusMessageReference As ScreenItem In statusMessageReferences
                Dim dataView As DataView = getDataView(statusMessageReference, queryStringParameterValues)
                If dataView IsNot Nothing Then
                    Return dataView.Table.Rows(0)(0).ToString()
                End If
            Next
        End If
        Return If(redirectReference.DisplayName > "", redirectReference.DisplayName, "Processing...")

    End Function

</script>