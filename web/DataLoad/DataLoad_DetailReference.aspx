<%@ Import Namespace="csi.Framework.ScreenData" %>
<%@ Import Namespace="csi.Framework.Utility" %>
<%@ Import Namespace="System.Xml" %>
<script language="VB" runat="server">

    'Private _xmlGlobalFileName As String = ConfigurationManager.AppSettings("xmlGlobal")
    'Private _xmlFormLayoutFileName As String = ""
    'Private _xmlGlobal As XmlDocument
    'Private _xmlFormLayout As XmlDocument
    Dim paramArrayValues() As String
    Dim paramArrayValuesCombined(0) As String
    Dim thisFramework As csi.Framework.Utility.Data = New csi.Framework.Utility.Data

    Public Shared ReadOnly DATE_DATA_TYPES As String() = {"datetime", "date", "system.datetime", "d"}


    Sub Page_Load(Sender As Object, E As EventArgs)

        Dim sScreenID = Request.Params("screenID")
        Dim csiSR As ScreenReader = New ScreenReader()
        Dim csiSI As ScreenItem

        Dim sectionNodes As XmlNodeList
        Dim sectionNode As XmlNode
        Dim fieldNode As XmlNode
        Dim thisFP As UIFieldProperty
        Dim alNodes As System.Collections.Generic.IList(Of XmlNode) = New System.Collections.Generic.List(Of XmlNode)
        Dim sFieldName As String
        Dim ScreenItemList As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)


        'gather parameters
        'need to parse the request.inputstream
        ''Dim streamRead As IO.StreamReader = New IO.StreamReader(Request.InputStream)
        Dim JSON_DictionaryLength As Integer = 0

        ''Request.InputStream.Position = 0
        ''Dim sJSON As String = streamRead.ReadToEnd()

        ''streamRead.Close()
        ''streamRead.Dispose()

        ''Dim JSON_StringDictionary As StringDictionary = JSON_ParseSimpleToDictionary(sJSON)


        'TODO:  this all has to be cleaned up
        'adjust the order based on findSQL control type for the screen (for now hard code to prove out)
        ''If Not JSON_StringDictionary Is Nothing Then
        ''    JSON_DictionaryLength = JSON_StringDictionary.Count

        ''    Array.Resize(paramArrayValuesCombined, JSON_StringDictionary.Count)
        ''    paramArrayValuesCombined(0) = JSON_StringDictionary.Item("RowCount").ToString()
        ''    paramArrayValuesCombined(1) = JSON_StringDictionary.Item("EmployeeID").ToString()

        ''End If        

        DefaultApplicationVariableHashTable()


        If Request.Params("p") IsNot Nothing Then
            Dim currentParameters As Parameters = New Parameters(Request)
            paramArrayValues = currentParameters.Array
            'paramArrayValues = CType(Request.Params("p"), String).Split(New Char() {CChar(",")})

            Array.Resize(paramArrayValuesCombined, paramArrayValuesCombined.Length + paramArrayValues.Length)
            paramArrayValues.CopyTo(paramArrayValuesCombined, JSON_DictionaryLength)

        End If



        'get screen references of type detail

        'csiSI = csiSR.Item(sScreenID, Common.UserName(Context))
        ScreenItemList = New List(Of ScreenItem)
        Try
            ScreenItemList.AddRange(csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "detail", Common.UserName(Context)))
        Catch ex As Exception

        End Try
        Try
            ScreenItemList.AddRange(csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "LeftNav", Common.UserName(Context)))
        Catch ex As Exception

        End Try

        If ScreenItemList Is Nothing OrElse ScreenItemList.Count = 0 Then
            Response.End()
            Exit Sub
        End If

        'open the json object
        Response.Write("[{")

        Dim firstField As Boolean = True
        For Each csiSI In ScreenItemList
            'loop through the fields in each section
            csiSI.CheckAccess(Server.MapPath(""))
            If csiSI.AllowAccess Then
                If Not firstField Then
                    Response.Write(",")
                End If
                firstField = False
                ProcessDetailData(csiSI, Response)
            End If


        Next

        'close the json object
        Response.Write("}]")

    End Sub

    Private Sub ProcessDetailData(thisScreenItem As ScreenItem, Response As HttpResponse)
        Dim dataStatement As String = ""
        Dim sql As String
        'Dim thisDT As System.Data.DataTable

        dataStatement = thisScreenItem.DataStatement

        If dataStatement.Trim() = "" Then
            Exit Sub
        End If

        dataStatement = Common.ReplaceVariables(dataStatement, CType(Context.Session("applicationVariable"), Hashtable))

        'TODO: REFACTOR using replaceVariables from CSB2013 (see screen data factory and/or data...)
        If paramArrayValuesCombined.Length > 0 Then
            sql = String.Format(dataStatement, paramArrayValuesCombined)
        Else
            sql = dataStatement
        End If



        'thisDT = thisFramework.SQL_to_DataSet(sql).Tables(0)

        'write out the field wrapper for the json
        Response.Write("""" + Common.JSON_Encode(thisScreenItem.ID.ToString()) + """: ")
        'write out the data set into the json
        If thisScreenItem.PageName.ToLower().Contains("treeview") Then
            Response.Write(thisFramework.SQL_To_TreeviewJSON(sql, True))
        Else
            Response.Write(thisFramework.SQL_To_JSON(sql, True))
        End If


        'ProcessDataTableToJSON(thisDT, Response)
        'close the field wrapper for the json


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

    </script>