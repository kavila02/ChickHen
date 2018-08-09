<%@ Import Namespace="csi.Framework.ScreenData" %>
<%@ Import Namespace="csi.Framework.Utility" %>
<script language="VB" runat="server">
    Public Shared ReadOnly DATE_DATA_TYPES As String() = {"datetime", "date", "system.datetime", "d"}


    Sub Page_Init()
    End Sub


    Sub Page_Load(Sender As Object, E As EventArgs)

        Dim sql As String = ""
        Dim dataStatement As String
        Dim thisDT As System.Data.DataTable
        Dim thisDR As System.Data.DataRow
        Dim myCol As System.Data.DataColumn
        Dim sScreenID = Request.Params("screenID")
        Dim resultType = Request.Params("resultType")
        Dim sRefernceType As String = Request.Params("referenceType")
        Dim fieldName As String = Request.Params("field")
        Dim csiSR As ScreenReader = New ScreenReader()
        Dim csiSI As ScreenItem
        Dim thisFramework As Data = New Data
        Dim paramArrayValues() As String
        Dim paramArrayValuesCombined(0) As String
        Dim csiSI_Find As ScreenItem
        Dim csiFindReferences As System.Collections.Generic.List(Of ScreenItem)

        ' Added 1/9/2018 SR to disable data calls while the user is logged out
        If Not HttpContext.Current.Request.IsAuthenticated And Not sScreenID = "LoginValidate" And Not sScreenID = "LoginResetPassword" Then
            Throw New UnauthorizedAccessException()
            Return
        End If

        csiSI = csiSR.Item(sScreenID, Common.UserName(Context))
        csiSI.CheckAccess(Server.MapPath(""))

        If csiSI.AllowAccess Then

            'get the findSQL reference

            csiFindReferences = csiSR.References(csiSI.ID, "findSQL", Common.UserName(Context))
            If Not csiFindReferences Is Nothing AndAlso csiFindReferences.Count > 0 Then
                csiSI_Find = csiFindReferences.Item(0)
            End If
            'if this is a findSQL reference type then switch the screenID
            If Not csiSI_Find Is Nothing AndAlso sRefernceType = "findSQL" Then
                csiSI = csiSI_Find
            ElseIf sRefernceType = "findSQL" And csiSI_Find Is Nothing Then
                Return
            End If

            dataStatement = csiSI.DataStatement

            DefaultApplicationVariableHashTable()

            'replace datastatement application variable values first
            dataStatement = Common.ReplaceVariables(dataStatement, CType(Context.Session("applicationVariable"), Hashtable))


            'need to parse the request.inputstream
            Dim streamRead As IO.StreamReader = New IO.StreamReader(Request.InputStream)
            Dim JSON_DictionaryLength As Integer = 0

            Request.InputStream.Position = 0
            Dim sJSON As String = streamRead.ReadToEnd()

            streamRead.Close()
            streamRead.Dispose()

            'If sJSON.Length <= 2 Then
            '    sql = sqlParameters(dataStatement, JSON_DictionaryLength)
            '    If sql.Trim > "" Then
            '        'thisDT = thisFramework.SQL_to_DataSet(sql).Tables(0)
            '        Try
            '            sJSON = thisFramework.SQL_To_JSON(sql, True)
            '        Catch ex As Exception

            '        End Try
            '    End If
            'End If
            'Response.Write(sJSON)

            Dim JSON_StringDictionary As StringDictionary = JSON_ParseSimpleToDictionary(sJSON)



            'if there is not stream from the client
            'and there is a findSQL reference
            'and that has a data statement
            'run that data into the JSON_StringDictionary
            If JSON_StringDictionary Is Nothing AndAlso Not csiSI_Find Is Nothing AndAlso csiSI_Find.DataStatement > "" AndAlso sRefernceType <> "findSQL" Then

                Dim findDataStatement As String = csiSI_Find.DataStatement
                thisFramework = New Data
                findDataStatement = Common.ReplaceVariables(findDataStatement, CType(Context.Session("applicationVariable"), Hashtable))

                If Request.Params("p") IsNot Nothing Then
                    Dim currentParameters As Parameters = New Parameters(Request)
                    paramArrayValues = currentParameters.Array
                    'paramArrayValues = CType(Request.Params("p"), String).Split(New Char() {CChar(",")})

                    Array.Resize(paramArrayValuesCombined, paramArrayValuesCombined.Length + paramArrayValues.Length)
                    paramArrayValues.CopyTo(paramArrayValuesCombined, JSON_DictionaryLength)
                    Try
                        findDataStatement = String.Format(findDataStatement, paramArrayValuesCombined)
                    Catch ex As Exception

                    End Try
                Else

                End If


                sJSON = thisFramework.SQL_To_JSON(findDataStatement, False)
                'Response.Write(sJSON)
                'if the sql is returned, it has a [] around it...strip that off
                If sJSON.Length > 1 AndAlso sJSON.StartsWith("[") Then
                    sJSON = sJSON.Substring(1, sJSON.Length - 2)
                End If
                JSON_StringDictionary = JSON_ParseSimpleToDictionary(sJSON)

            End If


            'TODO:  this all has to be cleaned up
            'adjust the order based on findSQL control type for the screen (for now hard code to prove out)
            If Not JSON_StringDictionary Is Nothing Then
                JSON_DictionaryLength = JSON_StringDictionary.Count

                Array.Resize(paramArrayValuesCombined, JSON_StringDictionary.Count)

                'are there other scenarios where where we will post back a set?
                'get findSQL reference
                'Dim csiSI_Find As ScreenItem
                'Dim csiFindReferences As System.Collections.Generic.List(Of ScreenItem)

                csiFindReferences = csiSR.References(csiSI.ID, "findSQL", Common.UserName(Context))
                If Not csiSI_Find Is Nothing Then
                    Dim iLinkFieldCount As Integer = 0
                    For Each sLinkField As String In csiSI_Find.LinkFields
                        'add values to the parameter array in this order
                        'Response.Write(sLinkField)
                        paramArrayValuesCombined(iLinkFieldCount) = JSON_StringDictionary.Item(sLinkField).ToString()
                        iLinkFieldCount += 1
                    Next
                End If
                'paramArrayValuesCombined(0) = JSON_StringDictionary.Item("RowCount").ToString()
                'paramArrayValuesCombined(1) = JSONStringDictionary.Item("EmployeeID").ToString()

            End If



            If Request.Params("p") IsNot Nothing Then
                Dim currentParameters As Parameters = New Parameters(Request)
                paramArrayValues = currentParameters.Array
                'paramArrayValues = CType(Request.Params("p"), String).Split(New Char() {CChar(",")})

                Array.Resize(paramArrayValuesCombined, paramArrayValuesCombined.Length + paramArrayValues.Length)
                paramArrayValues.CopyTo(paramArrayValuesCombined, JSON_DictionaryLength)
                Try
                    sql = String.Format(dataStatement, paramArrayValuesCombined)
                Catch ex As Exception

                End Try
            Else
                sql = dataStatement
            End If

            If sql.Trim > "" Then
                thisFramework = New Data
                Try

                    Response.Write(thisFramework.SQL_To_JSON(sql, True))
                Catch ex As Exception

                End Try
            End If


            'TODO: end


        End If


    End Sub



    Private Function sqlParameters(dataStatement As String, ByRef JSON_DictionaryLength As Integer) As String
        Dim paramArrayValues() As String
        Dim sql As String = ""
        Dim paramArrayValuesCombined(0) As String

        If Request.Params("p") IsNot Nothing Then
            Dim currentParameters As Parameters = New Parameters(Request)
            paramArrayValues = currentParameters.Array
            'paramArrayValues = CType(Request.Params("p"), String).Split(New Char() {CChar(",")})

            Array.Resize(paramArrayValuesCombined, paramArrayValuesCombined.Length + paramArrayValues.Length)
            paramArrayValues.CopyTo(paramArrayValuesCombined, JSON_DictionaryLength)
            Try
                sql = String.Format(dataStatement, paramArrayValuesCombined)
            Catch ex As Exception

            End Try
        Else
            sql = dataStatement
        End If
        Return sql
    End Function

    Private Function JSON_ParseSimpleToDictionary(sJSON As String) As StringDictionary

        Dim resultSD As StringDictionary = New StringDictionary()
        Dim sEntries As String()
        Dim sEntry As String
        Dim sEntryKeyValue As String()
        If sJSON.Length <= 2 Then
            Return Nothing
        End If

        'remove the []
        sJSON = sJSON.Substring(1, sJSON.Length - 2)
        sEntries = sJSON.Split(New Char() {CChar(",")})
        For Each sEntry In sEntries
            'Response.Write(sEntry)
            sEntryKeyValue = sEntry.Split(New Char() {CChar(":")})
            ''strip "" and {}
            If sEntryKeyValue(0).StartsWith("""") Then
                sEntryKeyValue(0) = sEntryKeyValue(0).Substring(1, sEntryKeyValue(0).Length - 2)
            End If
            If sEntryKeyValue(1).StartsWith("""") Then
                sEntryKeyValue(1) = sEntryKeyValue(1).Substring(1, sEntryKeyValue(1).Length - 2)
            End If
            resultSD.Add(sEntryKeyValue(0), sEntryKeyValue(1))


        Next

        Return resultSD
    End Function

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