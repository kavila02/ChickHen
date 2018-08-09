<%@ Import Namespace="csi.Framework.ScreenData" %>
<%@ Import Namespace="csi.Framework.Utility" %>
<%@ Import Namespace="System.Xml" %>
<script language="VB" runat="server">

    Private _xmlGlobalFileName As String = ConfigurationManager.AppSettings("xmlGlobal")
    Private _xmlFormLayoutFileName As String = ""
    Private _xmlGlobal As XmlDocument
    Private _xmlFormLayout As XmlDocument
    Dim paramArrayValues() As String
    Dim paramArrayValuesCombined(0) As String
    Dim thisFramework As csi.Framework.Utility.Data = New csi.Framework.Utility.Data

    Dim alNodes As System.Collections.Generic.IList(Of XmlNode) = New System.Collections.Generic.List(Of XmlNode)
    Dim firstField As Boolean = True


    Sub Page_Load(Sender As Object, E As EventArgs)

        Dim sScreenID = Request.Params("screenID")
        Dim csiSR As ScreenReader = New ScreenReader()
        Dim csiSI As ScreenItem

        Dim sectionNodes As XmlNodeList


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

        _xmlGlobal = Common.getXMLDoc(Context.Server.MapPath(_xmlGlobalFileName), HttpRuntime.Cache)

        'open the json object
        Response.Write("[{")

        'get format xml from screen

        csiSI = csiSR.Item(sScreenID, Common.UserName(Context))
        csiSI.CheckAccess(Server.MapPath(""))
        If csiSI.AllowAccess 'AndAlso csiSI.AllowUpdate Then 'Can technically load a readOnly dropdown, so allowaccess is irrelevant
            _xmlFormLayoutFileName = csiSI.FormatXML

            If _xmlFormLayoutFileName.Contains("|") Then
                'exit if
            Else
                'if the format file extention is html, then simply stream the file
                'how to get data for dropdown when a custom html layout?  where would we define this data statement?
                If System.IO.Path.GetExtension(_xmlFormLayoutFileName) = ".html" Then
                    'exit the if

                Else
                    _xmlFormLayout = Common.getXMLDoc(Context.Server.MapPath(_xmlFormLayoutFileName), HttpRuntime.Cache)
                    sectionNodes = _xmlFormLayout.SelectNodes("fieldList/section")


                    'only process the sectionNodes if the screen is updatable

                    ProcessFormatXML(sectionNodes)
                End If

            End If
        End If



        'get any findSQL references
        Dim csiSI_Find As ScreenItem
        Dim csiFindReferences As System.Collections.Generic.List(Of ScreenItem)

        csiFindReferences = csiSR.References(csiSI.ID, "findSQL", Common.UserName(Context))
        If Not csiFindReferences Is Nothing AndAlso csiFindReferences.Count > 0 Then
            csiSI_Find = csiFindReferences.Item(0)
            csiSI_Find.CheckAccess(Server.MapPath(""))
            If csiSI_Find.AllowAccess Then
                _xmlFormLayoutFileName = csiSI_Find.FormatXML
                _xmlFormLayout = Common.getXMLDoc(Context.Server.MapPath(_xmlFormLayoutFileName), HttpRuntime.Cache)
                sectionNodes = _xmlFormLayout.SelectNodes("fieldList/section")

                ProcessFormatXML(sectionNodes)

            End If

        End If

        'get any find references

        'get any detail references
        csiFindReferences = csiSR.References(csiSI.ID, "detail", Common.UserName(Context))
        If Not csiFindReferences Is Nothing AndAlso csiFindReferences.Count > 0 Then
            For Each csiSI_Detail As ScreenItem In csiFindReferences
                csiSI_Detail.CheckAccess(Server.MapPath(""))
                If csiSI_Detail.AllowAccess Then
                    _xmlFormLayoutFileName = csiSI_Detail.FormatXML
                    _xmlFormLayout = Common.getXMLDoc(Context.Server.MapPath(_xmlFormLayoutFileName), HttpRuntime.Cache)
                    sectionNodes = _xmlFormLayout.SelectNodes("fieldList/section")

                    ProcessFormatXML(sectionNodes)

                End If
            Next


        End If


        'close the json object
        Response.Write("}]")

    End Sub

    Private Sub ProcessFormatXML(sectionNodes As System.Xml.XmlNodeList)

        Dim sectionNode As XmlNode
        Dim fieldNode As XmlNode
        Dim thisFP As UIFieldProperty
        Dim sFieldName As String

        For Each sectionNode In sectionNodes
            'loop through the fields in each section
            For Each fieldNode In sectionNode.ChildNodes
                'create uiFP

                'only process if it is an element node type
                If fieldNode.NodeType = System.Xml.XmlNodeType.Element Then


                    alNodes.Clear()
                    alNodes.Add(fieldNode)
                    sFieldName = fieldNode.Attributes("fieldName").Value.ToString()

                    If _xmlGlobal.SelectNodes("fieldList/section/field[@fieldName='" & sFieldName & "']").Count > 0 Then
                        alNodes.Add(_xmlGlobal.SelectSingleNode("fieldList/section/field[@fieldName='" & sFieldName & "']"))
                    End If
                    'Instantiate a new field property for the current field.
                    'The constructor of UIFieldProperty gets all the values of the attributes in the Format XML
                    thisFP = New UIFieldProperty(alNodes)
                    'if it is a dropdown, process the data...
                    Dim IsAsyncAutocomplete As Boolean = thisFP.FieldType.ToLower.StartsWith("autocomplete") And Not thisFP.FieldType.ToLower.Contains("sync")


                    If thisFP.IsDropDown And Not IsAsyncAutocomplete Then
                        If Not firstField Then
                            Response.Write(",")
                        End If
                        firstField = False
                        ProcessDropDownData(thisFP, Response)
                    End If
                End If

            Next
        Next

    End Sub
    Private Sub ProcessDropDownData(thisFP As UIFieldProperty, Response As HttpResponse)
        Dim dataStatement As String = ""
        Dim sql As String
        'Dim thisDT As System.Data.DataTable

        Dim elementList As String = "["
        Dim firstElementInList As Boolean = True
        Dim isElementList As Boolean = False

        For Each lookUpNode As XmlNode In thisFP.LookupNodeList
            If lookUpNode.LocalName = "element" Then
                isElementList = True
                If Not firstElementInList Then
                    elementList = elementList & ","
                End If
                elementList = elementList & "{""display"":""" & lookUpNode.Attributes("text").Value & """"
                elementList = elementList & ",""value"":""" & lookUpNode.Attributes("value").Value & """"
                If Not lookUpNode.Attributes("filter") Is Nothing Then
                    elementList = elementList & ",""filter"":""" & lookUpNode.Attributes("filter").Value & """}"
                Else
                    elementList = elementList & "}"
                End If

                firstElementInList = False

            ElseIf lookUpNode.LocalName = "source" Then
                dataStatement = lookUpNode.Attributes("sql").Value
                dataStatement = Common.ReplaceVariables(dataStatement, CType(Context.Session("applicationVariable"), Hashtable))


            End If
        Next lookUpNode

        elementList = elementList & "]"

        'TODO: REFACTOR using replaceVariables from CSB2013 (see screen data factory and/or data...)
        If paramArrayValuesCombined.Length > 0 Then
            sql = String.Format(dataStatement, paramArrayValuesCombined)
        Else
            sql = dataStatement
        End If

        'thisDT = thisFramework.SQL_to_DataSet(sql).Tables(0)



        'write out the field wrapper for the json
        Response.Write("""" + Common.JSON_Encode(thisFP.FieldName) + """: ")

        'write out the data set into the json
        If isElementList Then
            Response.Write(elementList)
        Else
            Response.Write(thisFramework.SQL_To_JSON(sql, True, True))
        End If


        '        ProcessDataTableToJSON(thisDT, Response)
        'close the field wrapper for the json


    End Sub




    Private Function JSON_ParseSimpleToDictionary(sJSON As String) As StringDictionary
        Dim resultSD As StringDictionary = New StringDictionary()
        Dim sEntries As String()
        Dim sEntry As String
        Dim sEntryKeyValue As String()

        If sJSON.Length <= 2 Then
            Return Nothing
        End If

        'remove the {}
        sJSON = sJSON.Substring(1, sJSON.Length - 2)
        sEntries = sJSON.Split(New Char() {CChar(",")})
        For Each sEntry In sEntries
            sEntryKeyValue = sEntry.Split(New Char() {CChar(":")})
            'strip ""
            sEntryKeyValue(0) = sEntryKeyValue(0).Substring(1, sEntryKeyValue(0).Length - 2)
            sEntryKeyValue(1) = sEntryKeyValue(1).Substring(1, sEntryKeyValue(1).Length - 2)
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