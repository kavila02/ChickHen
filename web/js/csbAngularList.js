
(function () {
    //note: remove the angularUtils.directives.dirPagination if not using pagination
    var app = angular.module('CargasSolutionBuilderAngular', ['angularUtils.directives.dirPagination', 'ngMaterial', 'ngMessages', 'ngStorage', 'csbAngularUI']);


    app.controller('DataController', ['$http', '$scope', '$filter', '$sessionStorage', '$q', '$mdToast', '$mdMedia', function ($http, $scope, $filter, $sessionStorage, $q, $mdToast, $mdMedia) {

        var loadingCount = 0;
        var mainController = this;
        mainController.isFirstLoad = true;

        mainController.loadingCount = loadingCount;     //isLoading;
        $scope.$mdMedia = $mdMedia;

        mainController.additionalActionsClick = function (thisAction) {
            if (typeof thisAction.confirmationMessage !== 'undefined') {
                if (thisAction.confirmationMessage.length > 0) {
                    var response = confirm(thisAction.confirmationMessage);
                    if (!response) return;
                }
            }

            //loop through the whole redirectUrl and replace {{thisRecord.fieldname}} with the value for fieldname
            if (thisAction.action == "link"
                || thisAction.action == "linkNoSave"
                || thisAction.action == "newWindow"
                || thisAction.action == "newWindowNoSave"
                || thisAction.action == "popup"
                || thisAction.action == "evalData"
            ) {
                var redirectUrl = thisAction.data;
                while (redirectUrl.indexOf("{{") > -1) {
                    var fieldReference = redirectUrl.substring(redirectUrl.indexOf("{{"), redirectUrl.indexOf("}}") + 2);
                    var fieldName = fieldReference.replace("{{thisRecord.", "").replace("}}", "");
                    if (typeof (mainController.filterSet) !== 'undefined' && typeof (mainController.filterSet[fieldName]) !== 'undefined') {
                        redirectUrl = redirectUrl.replace(fieldReference, mainController.filterSet[fieldName]);
                    } else {
                        redirectUrl = redirectUrl.replace(fieldReference, mainController.firstRow()[fieldName]);
                    }
                }
            }

            switch (thisAction.action) {
                case "link":
                    mainController.saveData(redirectUrl);
                    //window.location = thisAction.data;
                    break;
                case "linkNoSave":
                    window.location = redirectUrl;
                    break;
                case "newWindow":
                    mainController.saveData(redirectUrl, true);
                    break;
                case "newWindowNoSave":
                    window.open(redirectUrl);
                    break;
                case "popup":
                    //refine based on sending out the size params based on displayStyle
                    showInDialog(redirectUrl, thisAction.label, 600, 450);
                    break;
                case "evalData":
                    //eval is bad! This function should be the same as saveData and should handle javascript without issue
                    //eval(thisAction.data);
                    mainController.saveData(redirectUrl);
                    break;
                case "executeCommand":
                    executeCommand(thisAction.data, mainController.record);
                    break;
                case "refreshMenus":
                    mainController.refreshMenus();
                    break
                default:
                    alert(thisAction.action);

            };
            mainController.actionOpen = false;
        };

        var menuHTML = 'menuHTML' + document.location.pathname.split("/").slice(-2, -1).toString();
        var leftMenuHTML = 'leftMenuHTML' + document.location.pathname.substr(0, document.location.pathname.lastIndexOf('/')).replace('/', '_');


        //mainController.records = [{ "ProjectID": "683", "CustomerID": "CARGAS", "Name": "Administration", "Rate": "0.00", "TravelFactor": "0.0000", "TravelIsAmount": "0", "TimeLogProjectNum": "", "TotalBudget": "100.00", "TotalRemaining": "-332.75", "ProjectStatusID": "1", "PrevProjectID": "", "LocationID": "0", "SolutionID": "0", "ProjectManagerEmployeeID": "0", "Modified Date": "05/27/2015", "ProjectTypeID": "1", "ProjectStatus": "Active", "CustomerID": "CARGAS", "CustomerName": "Cargas Systems", "Hold For Billing": "0", "InActive": "0", "DateAdded": "06/04/2008", "CustomerClass": "L-OTHER", "TravelMethod": "Fraction", "TotalHours": "432.75", "NumberOfNegativeBudgetTasks": "1", "LastActivityDate": "05/27/2015" }];
        mainController.records = [];
        mainController.detailRecords = [];
        //should these be here, or at a "grid controller level?"
        mainController.searchString = "";
        mainController.searchArray = {};
        mainController.searchDropdowns = {};
        mainController.sortString = [];
        mainController.sortDirection = [];
        mainController.pageSize = 10;
        mainController.pageStart = 0;
        mainController.currentPage = 1;

        //mainController.filterSet = {"RowCount": "15", "EmployeeID": "38"};
        mainController.filterSet = {};
        //add a lookup to the server on page properties, including has find, page title, etc.
        mainController.screenPropertySet = {};
        //add a lookup function that identifies how many rows have changed (I guess this is has been touched)
        mainController.numberOfRowsTouched = numberOfRowsTouched;
        function numberOfRowsTouched() {
            return $filter('filter')(mainController.records, { thisRowHasChanged: true }).length;
        };
        mainController.firstRow = firstRow;
        function firstRow() {
            return mainController.records[0];
        }

        $scope.dropdownJSON = [];
        mainController.getDropdownJSON = function () {
            return $scope.dropdownJSON;
        }
        mainController.setColumnSorting = setColumnSorting;
        mainController.checkColumnSorting = checkColumnSorting;

        //set default properties
        searchObject = getURLParameters()

        var sScreenID = searchObject.screenID
        sParam = searchObject.plist;


        mainController.callLoadData = function () {
            loadData();
        };


        mainController.callReloadAll = function () {
            //PRC 12/7/17: I don't think we need to refresh the screen property set with the on screen refresh button. It shouldn't be changing.
            //loadScreenPropertySet(true);
            loadAllData();
        };

        mainController.saveData = saveData;
        mainController.executeCommand = executeCommand;


        loadScreenPropertySet(true);

        loadMenu();
        loadLeftMenu();

        mainController.sectionShowHide = function (index) {
            if (mainController.screenPropertySet.sectionInfo[index][0] == '0') {
                mainController.screenPropertySet.sectionInfo[index][0] = '1'
            } else {
                mainController.screenPropertySet.sectionInfo[index][0] = '0'
            }
        };


        mainController.treeNodeSelect = function (node, functionName) {
            $scope.currentNode && $scope.currentNode.selected &&
                ($scope.currentNode.selected = void 0);
            node.selected = "selected";
            $scope.currentNode = node;
            if (functionName == 'selectSecurityMenu') {
                window.location = 'Form.html?screenID=ScreenSecurity&p=' + node.linkValue;
            } else {
                var fn = window[functionName];
                var params = [mainController.record, node];
                if (typeof fn === "function") {
                    var valid = fn.apply(null, params);
                }
            }
        };

        mainController.setAdvancedSearchFields = function (json) {
            mainController.advancedSearchFields = json;
            //console.log(ctrl);
            return false;
        };

        mainController.getAdvancedSearchFieldsFiltered = function () {
            //thisRecord.firstRow().hasOwnProperty('CustomerChannel')" 
            var RowsToShow = [];

            for (var i = 0; i < mainController.advancedSearchFields.length; i++) {
                var y = mainController.advancedSearchFields[i]["field"];
                var x = mainController.records[0].hasOwnProperty(y);
                if (mainController.records[0].hasOwnProperty(mainController.advancedSearchFields[i]["field"])) {
                    var row = {};
                    row.field = mainController.advancedSearchFields[i]["field"];
                    row.label = mainController.advancedSearchFields[i]["label"];
                    RowsToShow.push(row);
                }
                // for (var key in mainController.records[0]) {
                // var x=RowsToShow.indexOf(mainController.records[0][i][fieldName])
                // if (x>-1)
                // RowsToShow.splice(x,1)
            }
            //return mainController.advancedSearchFields;
            return RowsToShow;
        };

        mainController.refreshMenus = function () {
            delete sessionStorage[menuHTML];
            delete sessionStorage[leftMenuHTML];
        };


        mainController.singleSelect = function (thisRecord, fieldName) {
            isSelected = thisRecord[fieldName];
            //uncheck all records
            if (isSelected == 1) {
                for (var i = 0; i < mainController.records.length; i++) {
                    //we put this condition here so that null checkboxes remain unaffected (so hideWhenNull still keeps it hidden)
                    if (mainController.records[i][fieldName] == '1') {
                        mainController.records[i][fieldName] = '0';
                    }
                }
            }
            //check the record that was clicked (cannot unselect a record)
            thisRecord[fieldName] = '1';
        };

        mainController.navigateGrid = function (e) {
            var key = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;
            var td = $(e.target).closest('td');
            var currentIndex = $(td).index();
            //$(td).closest('tr').next().find('td:eq(' + currentIndex + ')').hide();
            if (key == 38) { /*up*/
                e.preventDefault();
                var prevRowField = $(td).closest('tr').prev().find('td:eq(' + currentIndex + ')').find('input');
                $(prevRowField).focus();
                $(prevRowField).select();
                $(e.target).blur();
            }
            if (key == 40) { /*down*/
                e.preventDefault();
                var nextRowField = $(td).closest('tr').next().find('td:eq(' + currentIndex + ')').find('input');
                $(nextRowField).focus();
                $(nextRowField).select();
                $(e.target).blur();
            }
        }

        mainController.changeFunction = function (functionName, fieldName, isGrid, thisRecord, dataFieldName, listItem) {
            //Apparently using eval is like making a deal with the devil
            //So we do some crazy mumbo jumbo (also found in custom.js) to call our javascript function from screen.xml
            var functionCallNoParams = functionName.substring(0, functionName.indexOf('('));
            var functionParams = functionName.substring(functionName.indexOf('(') + 1, functionName.indexOf(')')).replace(/' /g, '').replace(/ '/g, '').replace(/'/g, '').split(',');
            for (var i = 0; i < functionParams.length; i++) {
                if (functionParams[i] == '{thisRecord}') {
                    if (!isGrid) {
                        functionParams[i] = mainController.record;
                    } else {
                        functionParams[i] = thisRecord;
                    }
                }
                if (functionParams[i] == '{listItem}') {
                    if (typeof listItem === 'undefined') {
                        for (var x = 0; x < $scope.dropdownJSON[dataFieldName].length; x++) {
                            if ($scope.dropdownJSON[dataFieldName][x].value == thisRecord[dataFieldName]) {
                                functionParams[i] = $scope.dropdownJSON[dataFieldName][x];
                            }
                        }
                    } else {
                        functionParams[i] = listItem;
                    }

                }
                if (functionParams[i] == '{detailRecords}') {
                    functionParams[i] = mainController.detailRecords;
                }
                if (functionParams[i] == '{scope}') {
                    functionParams[i] = $scope;
                }
                if (functionParams[i] == '{fieldName}') {
                    functionParams[i] = fieldName;
                }
                if (functionParams[i] == '{screenPropertySet}') {
                    functionParams[i] = mainController.screenPropertySet;
                }
                if (functionParams[i] == '{filterSet}') {
                    functionParams[i] = mainController.filterSet;
                }
            }
            var fn = window[functionCallNoParams];
            if (typeof fn === "function") {
                var valid = fn.apply(null, functionParams);
                $scope.csbForm[fieldName].$setValidity('custom', valid);
                //The ng-show doesn't work in a grid for some reason. Although the field is marked as invalid,
                //ng-show=csbForm.fieldname.$invalid isn't working. So the error message is a div with the same id+_invalid
                //pre-loaded with a class containing display:none; so we can just show it using jquery
                if (isGrid && !valid) {
                    $('[id="td' + fieldName + '_invalid"]').show();
                }
                if (isGrid && valid) {
                    $('[id="td' + fieldName + '_invalid"]').hide();
                }
            }
        };

        mainController.dataValidate = function (dataType, isGrid, value, errorDivId, fieldName) {
            var numericPattern = /^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/;
            var datePattern = /^(0?[1-9]|1[012])\/(0?[1-9]|[12][0-9]|3[01])\/((19\d{2})|([2-9]\d{3}))$/;

            var valid = true;
            if (dataType == 'date') {
                //it will only pass the date into the data object if it's valid. So if the data object is undefined, we can
                //assume it is not a date
                if (typeof value === 'undefined') {
                    valid = false;
                }
            }
            if (dataType == 'numeric') {
                valid = numericPattern.test(value);
            }
            if (dataType == 'required') {
                valid = (value > '');
            }
            if (isGrid && !valid) {
                $('[id="td' + errorDivId + '"]').show();
            }
            if (isGrid && valid) {
                $('[id="td' + errorDivId + '"]').hide();
            }
        };

        mainController.updateAll = function (thisRecord, fieldName, event) {

            var newValue = '';
            if ($(event.target).parent().prop('nodeName') == 'MD-CHECKBOX') {
                //this fires before the field is checked, so take the opposite
                if ($(event.target).parent().hasClass('md-checked')) {
                    newValue = '0';
                } else {
                    newValue = '1';
                }
            } else {
                newValue = $(event.target).val();
            }
            if (newValue > '') {
                for (var i = 0; i < thisRecord.length; i++) {
                    if (thisRecord[i][fieldName] !== newValue) {
                        //non-displaying pages don't have the watch fire off the is changed flag, so we do it manually
                        thisRecord[i].thisRowHasChanged = true;
                    }
                    thisRecord[i][fieldName] = newValue;
                }
            }
        };

        mainController.columnHeaderValues = function (columnName) {

            var columnHeaderResult = [];
            angular.forEach(mainController.records, function (val, key) {
                var thisValue = val[columnName]
                if (columnHeaderResult.indexOf(thisValue) == -1) {
                    columnHeaderResult.push(thisValue)
                }
            });

            return columnHeaderResult;

        };

        mainController.rowKeyValues = function (rowKey) {
            var rowKeyValueResult = [];
            angular.forEach(mainController.records, function (val, key) {
                var thisValue = val[rowKey]
                if (rowKeyValueResult.indexOf(thisValue) == -1) {
                    rowKeyValueResult.push(thisValue)
                }
            });
            //console.log(rowKeyValueResult);
            return rowKeyValueResult;
        };

        mainController.dataValues = function (rowKey, rowKeyValue) {
            var filterJSON = [];
            filterJSON[rowKey] = rowKeyValue.toString();

            var dataValueResult = $filter('filter')(mainController.records, filterJSON);
            return dataValueResult;
        };

        mainController.advancedFilter = function (value) {
            var dropdowns = $filter('filter')(mainController.advancedSearchFields, { type: 'dropdown' });
            //console.log(value);

            for (var i = 0; i < dropdowns.length; i++) {
                if (value[dropdowns[i].field] > '') {
                    var validOptions = $filter('filter')($scope.dropdownJSON[dropdowns[i].field], { display: mainController.searchDropdowns[dropdowns[i].field] });
                    for (var x = 0; x < validOptions.length; x++) {
                        if (validOptions[x].value == value[dropdowns[i].field]) {
                            return true;
                        }
                    }
                    return false;
                }
            }

            return true;
        };

        mainController.customUpdateAll = function (functionName, fieldName, isGrid, thisRecord, event) {
            //Apparently using eval is like making a deal with the devil
            //So we do some crazy mumbo jumbo (also found in custom.js) to call our javascript function from screen.xml
            var functionCallNoParams = functionName.substring(0, functionName.indexOf('('));
            var functionParams = functionName.substring(functionName.indexOf('(') + 1, functionName.indexOf(')')).replace(/' /g, '').replace(/ '/g, '').replace(/'/g, '').split(',');
            for (var i = 0; i < functionParams.length; i++) {
                if (functionParams[i].toLowerCase().trim() == '{thisrecord}') {
                    functionParams[i] = thisRecord;
                } else if (functionParams[i].toLowerCase().trim() == '{listitem}') {
                    for (var x = 0; x < $scope.dropdownJSON[fieldName].length; x++) {
                        if ($scope.dropdownJSON[fieldName][x].value == thisRecord[fieldName]) {
                            functionParams[i] = $scope.dropdownJSON[fieldName][x];
                        }
                    }
                } else if (functionParams[i].toLowerCase().trim() == '{event}') {
                    functionParams[i] = event;
                } else if (functionParams[i].toLowerCase().trim() == '{fieldname}') {
                    functionParams[i] = fieldName;
                }
            }
            var fn = window[functionCallNoParams];
            if (typeof fn === "function") {
                var valid = fn.apply(null, functionParams);
            }
        };


        function loadScreenPropertySet(callLoadAll) {
            //change the caching setting
            //var sURL = 'DataLoad/DataLoad.aspx?screenID=TimeLogLast10&p=&resultType=json';
            var sURL = 'DataLoad/DataLoad_ScreenLayout.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '');
            mainController.loadingCount++;

            //replace get with post...see what happens
            //alert('1');
            $http.post(sURL, mainController.filterSet).then(function (response) {
                // this callback will be called asynchronously
                // when the response is available
                //alert('2');
                mainController.screenPropertySet = response.data[0];
                mainController.loadingCount--;
                document.title = mainController.screenPropertySet['websiteTitle'];
                if (mainController.screenPropertySet['displayStyle'].indexOf("paging") > -1) {
                    if (mainController.screenPropertySet['displayStyle'].substring(7, 10) == "all") {
                        mainController.pageSize = 5000 //mainController.records.length();
                    } else {
                        mainController.pageSize = parseInt(mainController.screenPropertySet['displayStyle'].substring(7, 11));
                    }
                } else if (mainController.screenPropertySet['sectionDisplayStyle'].indexOf("paging") > -1) {
                    if (mainController.screenPropertySet['sectionDisplayStyle'].substring(7, 10) == "all") {
                        mainController.pageSize = 5000 //mainController.records.length();
                    } else {
                        mainController.pageSize = parseInt(mainController.screenPropertySet['sectionDisplayStyle'].substring(7, 11));
                    }
                }

                if (callLoadAll) {
                    loadAllData();
                }
            }, function (response) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
                //alert(response.data);
                mainController.loadingCount--;

            });
        };

        mainController.firstFindSql = true;

        function loadAllData() {
            //PRC- I think it's best if subsequent refreshes do not reset the find sql parameters, so call loadData() instead of loadAllData()
            if (mainController.firstFindSql === false) {
                loadData();
                return;
            }
            mainController.loadingCount++;
            //this is an array for the promises
            var loadCalls = [];

            var sURL = 'DataLoad/DataLoad.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + '&resultType=json&referenceType=findSQL';
            loadCalls.push($http.post(sURL));

            var sURL = 'DataLoad/DataLoad.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + '&resultType=json';

            var doNotLoadOnPageLoad = false;
            if (typeof (mainController.screenPropertySet['doNotLoadFindSQLResultsOnGet']) !== 'undefined') {
                doNotLoadOnPageLoad = mainController.screenPropertySet['doNotLoadFindSQLResultsOnGet'];
            }
            if (!doNotLoadOnPageLoad || !mainController.isFirstLoad || !mainController.screenPropertySet['hasFilter']) {
                loadCalls.push($http.post(sURL, mainController.filterSet));
            }

            sURL = 'DataLoad/DataLoad_LookupList.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + '&resultType=json';
            loadCalls.push($http.post(sURL, mainController.filterSet));
            mainController.isFirstLoad = false;

            sURL = 'DataLoad/DataLoad_DetailReference.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + '&resultType=json';
            loadCalls.push($http.post(sURL, mainController.filterSet));

            $q.all(loadCalls).then(
                function (response) {
                    //this response object
                    //is really an array of responses...
                    //...pretty cool...
                    angular.forEach(response, function (val, key) {

                        //filter data set
                        if (key == 0) {
                            mainController.filterSet = val.data[0];
                            mainController.firstFindSql = false;
                        };
                        //main data set
                        if (key == 1) {
                            mainController.records = val.data;
                            //defaultAutoComplete_List();
                            if (typeof listTemplateDataLoaded == "function") {
                                listTemplateDataLoaded(mainController, sScreenID);
                            }
                        };
                        //drop down
                        if (key == 2) {
                            $scope.dropdownJSON = val.data[0];
                        };
                        //detail
                        if (key == 3) {
                            mainController.detailRecords = val.data;
                            //init values for paging on multiple tabs
                            angular.forEach(mainController.detailRecords[0], function (val, setNumber) {
                                val.currentPage = 1;
                                val.pageSize = 10;
                                val.sortString = [];
                                val.sortReverse = true;
                                val.setColumnSorting = setColumnSorting;

                            }
                            );
                        };

                    });
                    //mainController.errorMessages = response.data;
                    //defaultAutoComplete();
                    defaultAutoComplete_Filter()
                    mainController.loadingCount--;
                    if (typeof formLoadReady == "function") {
                        var solutionBuilderPrimaryForm = $('[name="csbForm"]');
                        formLoadReady(sScreenID, solutionBuilderPrimaryForm);
                    }
                }
                , function (error) {
                    mainController.loadingCount--;
                }

            )
                //.catch(function (catchError) {
                //    alert(catchError);
                //})
                ;


        };

        mainController.autocompleteLoading = [];
        mainController.autocompleteDeferred = [];
        mainController.autocompleteSelectedItem = [];
        mainController.autocompleteSearchText = [];
        mainController.autocompletePreviousSearchText = [];

        function defaultAutoComplete() {
            //do not use- broke into two separate functions
        };

        function defaultAutoComplete_List() {
            //var currentRecord = mainController.records[0];
            //for (var fieldName in currentRecord) {
            //    if (currentRecord.hasOwnProperty(fieldName)) {
            //        if ($scope.dropdownJSON.hasOwnProperty(fieldName)) {
            //            //we're now down to the fields that are dropdowns
            //            //loop through all rows and set selected item
            //            for (var currentRowIndex = 0; currentRowIndex < mainController.records.length; currentRowIndex++) {
            //                mainController.autocompleteSelectedItem[fieldName + currentRowIndex] = $filter('filter')($scope.dropdownJSON[fieldName], { value: mainController.records[currentRowIndex][fieldName] }, true)[0];
            //                mainController.autocompletePreviousSearchText[fieldName + currentRowIndex] = '';
            //            }
            //            //mainController.autocompleteSelectedItem[fieldName] = $filter('filter')($scope.dropdownJSON[fieldName], { value: currentRecord[fieldName] }, true)[0];
            //        }
            //    }
            //}
        };

        function defaultAutoComplete_Filter() {
            var currentRecord = mainController.filterSet;
            for (var fieldName in currentRecord) {
                if (currentRecord.hasOwnProperty(fieldName)) {
                    if ($scope.dropdownJSON.hasOwnProperty(fieldName)) {
                        mainController.autocompleteSelectedItem[fieldName] = $filter('filter')($scope.dropdownJSON[fieldName], { value: currentRecord[fieldName].toString() }, true)[0];
                    } else {
                        if (typeof ($('md-autocomplete[name="' + fieldName + '"]').attr('name')) !== 'undefined') {
                            mainController.initializeDefaultAutocomplete(fieldName, fieldName, currentRecord, mainController.screenPropertySet.findScreenID, true);
                        }
                    }
                }
            }
        };


        mainController.getMatches = function getMatches(searchText, fieldName, fieldID) {
            //don't need all this code, if we change to using the |filter: blah syntax on the html directive...
            if (typeof (mainController.autocompletePreviousSearchText[fieldID]) !== 'undefined') {
                if (searchText && searchText === mainController.autocompletePreviousSearchText[fieldID]) {
                    return;
                }
            }
            mainController.autocompletePreviousSearchText[fieldID] = searchText;
            return $scope.dropdownJSON[fieldName].filter(createFilterForSearch(searchText));
        };

        //mainController.setValue = function setValue(thisRecord, fieldName, fieldID) {
        //    thisRecord[fieldName] = mainController.autocompleteSelectedItem[fieldID];
        //}

        function createFilterForSearch(searchText) {
            return function filterFn(item) {
                //starts with
                //return (item.display.toLowerCase().indexOf(searchText.toLowerCase()) === 0);
                //contains
                return (item.display.toLowerCase().indexOf(searchText.toLowerCase()) != -1);
            };
        }

        mainController.initializeDefaultAutocomplete = function initializeDefaultAutocomplete(fieldName, fieldID, thisRecord, screenID, isAsync) {
            if (typeof (thisRecord) !== 'undefined') {
                mainController.autocompleteSelectedItem[fieldID] = thisRecord[fieldName];
                mainController.autocompleteSearchText[fieldID] = '';
                if (thisRecord[fieldName] > '') {
                    if (isAsync) {
                        mainController.autocompleteSearchTextChanged('', fieldName, fieldID, thisRecord[fieldName], screenID);
                    } else {
                        mainController.autocompleteSelectedItem[fieldID] = $filter('filter')($scope.dropdownJSON[fieldName], { value: thisRecord[fieldName].toString() }, true)[0];
                    }
                }
                mainController.autocompletePreviousSearchText[fieldID] = '';
            }
        };


        mainController.autocompleteSearchTextChanged = function autocompleteSearchTextChanged(searchterm, fieldName, fieldID, value, screenID) {
            if (typeof (mainController.autocompletePreviousSearchText[fieldID]) !== 'undefined') {
                if (searchterm && searchterm === mainController.autocompletePreviousSearchText[fieldID]) {
                    return;
                }
            }
            return mainController.getAsyncAutocomplete(fieldName, fieldID, searchterm, value, screenID);
        };

        //for some reason when selecting an item this gets called twice. Not a big deal for setting the value, but could be an issue with validation
        mainController.autocompleteSelectedOnceAlready = false
        mainController.autocompleteSelectedItemChange = function autocompleteSelectedItemChange(item, thisRecord, fieldName, fieldID, customFunction) {

            if (typeof (item) !== 'undefined' && typeof (thisRecord) !== 'undefined') {
                if (typeof (item.display) !== 'undefined') {
                    thisRecord[fieldName] = item.value;
                    if (!mainController.autocompleteSelectedOnceAlready) {
                        //we pass in true for isGrid. Even if it's not a grid, it forces the function to use what we pass in for thisRecord instead of mainController.record
                        mainController.changeFunction(customFunction, fieldID, true, thisRecord, fieldName);
                    }
                    mainController.autocompleteSelectedOnceAlready = !mainController.autocompleteSelectedOnceAlready;
                }
            } else if (typeof (thisRecord) !== 'undefined') {
                //I think this is the clause where the record has been blanked out but our onload stuff will remain okay
                thisRecord[fieldName] = '';
            }
        };

        mainController.getAsyncAutocomplete = function (fieldName, fieldID, searchterm, fieldValue, screenID) {
            if (!mainController.autocompleteLoading[fieldID]) {
                mainController.autocompleteDeferred[fieldID] = $q.defer();
                mainController.getAsyncAutocompleteInitialize(fieldName, fieldID, searchterm, fieldValue, screenID);
                return mainController.autocompleteDeferred[fieldID].promise;
            } else {
                return;
            }
        };

        mainController.getAsyncAutocompleteInitialize = function (fieldName, fieldID, searchTerm, fieldValue, screenID) {
            mainController.autocompleteDeferred[fieldID] = $q.defer();

            mainController.autocompleteLoading[fieldID] = true;
            $http({
                method: 'get',
                url: 'DataSend/DataSend_AutoComplete.ashx?screenID=' + screenID + '&p=' + sParam.replace('#', '') + '&FieldName=' + fieldName + '&term=' + searchTerm + '&value=' + fieldValue,
            }).then(function (response) {
                if (response.data) {
                    mainController.autocompleteLoading[fieldID] = false;
                    $scope.dropdownJSON[fieldID] = response.data;
                    mainController.autocompleteDeferred[fieldID].resolve(response.data);

                    if (response.data[0]) {
                        if (response.data[0].hasOwnProperty('display')) {
                            if (mainController.autocompleteSearchText[fieldID] !== response.data[0].display) {
                                mainController.autocompleteSearchText[fieldID] = response.data[0].display;
                            }
                        }
                    }
                    mainController.autocompletePreviousSearchText[fieldID] = mainController.autocompleteSearchText[fieldID];
                    return mainController.autocompleteDeferred[fieldID].promise;
                } else {
                    mainController.autocompleteLoading[fieldID] = false;
                    mainController.autocompleteDeferred[fieldID].reject('An error occurred');
                    return;
                }

            }, function (response) {
                mainController.autocompleteLoading[fieldID] = false;
            });
        };

        mainController.gridPaste = function gridPaste(event, thisRecord, screenID) {
            var currentIndex = mainController.records.indexOf(thisRecord);
            //in chrome (and possibly other more recent browsers) get pasted data from event.originalEvent.clipboardData.getData('text/plain')
            var fieldName = $(event.target).attr('ng-model').replace('thisRecord.', '');
            var currentElement = $(event.target);
            var pastedData = '';
            if (navigator.userAgent.match(/msie|trident/i)) {
                $('<textarea />').attr('id', 'temp').attr('style', 'position:absolute; left:-3000px;').appendTo('body');
                $('#temp').change(function () {
                    pastedData = $(this).val();
                    pasteData(pastedData, currentElement, thisRecord, fieldName, currentIndex);
                    $('#temp').remove();
                });
                $('#temp').focus(function () {
                    $('#temp').blur();
                });
                $('#temp').focus();
            } else {
                pastedData = event.originalEvent.clipboardData.getData('text/plain');
                pasteData(pastedData, currentElement, thisRecord, fieldName, currentIndex);
            }
        }

        function pasteData(pastedData, currentElement, thisRecord, fieldName, currentIndex) {
            var multilinePasteReplaceContents = true;
            if (typeof pastedData !== 'undefined' && pastedData > '' && (pastedData.indexOf('\t') > -1 || pastedData.indexOf('\n') > -1)) {
                event.preventDefault();
                var arrGroup = pastedData.split('\n');
                for (var i = 0; i < arrGroup.length; i++) {
                    //decided to append to existing data, rather than overwrite, due to one-time pasting
                    //still possibly needs to accomidate for pasting mid-text on single line pasting
                    //**changed to config setting at top
                    if (arrGroup[i].indexOf('\t') >= 0) {
                        var currentRow = arrGroup[i].split('\t', -1);
                        for (var j = 0; j < currentRow.length; j++) {
                            var currentFieldName = $(currentElement).attr('ng-model').replace('thisRecord.', '');
                            var existingRowData = thisRecord[currentFieldName];
                            var newData = currentRow[j];
                            if (!multilinePasteReplaceContents) {
                                newData = existingRowData + newData;
                            }
                            thisRecord[currentFieldName] = newData;
                            var nextRowElement = $(currentElement).closest('td').next().find('input');

                            //sometimes the pasted text is greater than the number of rows, if it is stop pasting
                            if (nextRowElement.length > 0) {
                                currentElement = nextRowElement;
                            } else {
                                break;
                            }
                        }
                    } else {
                        var existingData = thisRecord[fieldName];
                        thisRecord[fieldName] = existingData + arrGroup[i];
                    }
                    currentIndex = currentIndex + 1;
                    var nextRow = mainController.records[currentIndex];
                    var nextElement = $(currentElement).closest('tr').next().find('[ng-model="thisRecord.' + fieldName + '"]input');

                    //sometimes the pasted text is greater than the number of rows, if it is stop pasting
                    if (nextElement.length > 0 && typeof nextRow !== 'undefined') {
                        thisRecord = nextRow;
                        currentElement = nextElement;
                    } else {
                        break;
                    }
                }
                //$scope.$digest();
            }
        }

        function getMatches(searchText, fieldName, thisRecord) {
            //don't need all this code, if we change to using the |filter: blah syntax on the html directive...
            return $scope.dropdownJSON[fieldName].filter(createFilterForSearch(searchText));
        }

        //probably can put this inline...rather than here?
        function setValue(fieldName, thisRecord, selectedItem) {
            //if (typeof selectedItem !== 'undefined' && selectedItem.value > '') {
            thisRecord[fieldName] = selectedItem.value;
            //}
        }

        function createFilterForSearch(searchText) {
            return function filterFn(item) {
                //starts with
                //return (item.display.toLowerCase().indexOf(searchText.toLowerCase()) === 0);
                //contains
                return (item.display.toLowerCase().indexOf(searchText.toLowerCase()) != -1);
            };
        }


        function loadData() {
            if (mainController.screenPropertySet.hasFilter) {
                //if filter set doesn't exist due to no dataStatement, create it
                if (typeof (mainController.filterSet) === 'undefined') {
                    mainController.filterSet = {};
                }
                //verify that filter set has all fields it needs, in case dataStatement is missing one
                $('[ng-model*="thisRecord."]').each(function () {
                    var fieldName = $(this).attr("id");
                    if (typeof ($(this).attr("id")) !== 'undefined' && !mainController.filterSet.hasOwnProperty(fieldName)) {
                        mainController.filterSet[fieldName] = "";
                    }
                });
            }
            //change the caching setting
            //var sURL = 'DataLoad/DataLoad.aspx?screenID=TimeLogLast10&p=&resultType=json';
            var sURL = 'DataLoad/DataLoad.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + '&resultType=json';
            mainController.loadingCount++;

            //replace get with post...see what happens
            //alert('1');
            $http.post(sURL, mainController.filterSet).then(function (response) {
                // this callback will be called asynchronously
                // when the response is available
                mainController.records = response.data;
                mainController.loadingCount--;
                //defaultAutoComplete_List();
                if (typeof listTemplateDataLoaded == "function") {
                    listTemplateDataLoaded(mainController, sScreenID);
                }

            }, function (response) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
                //alert(data);
                mainController.loadingCount--;

            });
        };


        function loadMenu() {
            //change the caching setting
            //var sURL = 'DataLoad/DataLoad_LookupList.aspx?screenID=TimeLogLast10&p=&resultType=json';
            var sURL = "ContentLoad/ContentLoad_Menu.ashx"    //?screenID=" + sScreenID


            //delete sessionStorage[menuHTML];
            if (sessionStorage[menuHTML]) {
                mainController.menuHTML = sessionStorage[menuHTML].replace('{{screenID}}', sScreenID);
                return;
            };
            //replace get with post...see what happens
            $http.get(sURL, { cache: true }).then(function (response) {
                sessionStorage[menuHTML] = response.data;
                mainController.menuHTML = response.data.replace('{{screenID}}', sScreenID);
                $("#cssmenu").html(response.data.replace('{{screenID}}', sScreenID));
                //initQuartzMenu(); //This causes duplicate hamburger in IE and Safari. Not sure it's necessary, since the directive definition calls it
            }, function (errorResponse) {

            });

        };

        function loadLeftMenu() {
            //change the caching setting
            //var sURL = 'DataLoad/DataLoad_LookupList.aspx?screenID=TimeLogLast10&p=&resultType=json';
            var sURL = "ContentLoad/ContentLoad_Menu.ashx?menuAppSettingKey=xmlLeftMenu&isLeftMenu=true"    //?screenID=" + sScreenID


            //delete sessionStorage[leftMenuHTML];
            if (sessionStorage[leftMenuHTML]) {
                mainController.leftMenuHTML = sessionStorage[leftMenuHTML];
                return;
            };
            //replace get with post...see what happens
            $http.get(sURL, { cache: true }).then(function (response) {

                sessionStorage[leftMenuHTML] = response.data;
                mainController.leftMenuHTML = response.data;
                $("#cssleftmenu").html(response.data);
                //initQuartzMenu();

            }, function (errorResponse) {

            });

        };

        function saveData(redirectUrl, inNewWindow) {
            if (typeof mainController.screenPropertySet.confirmationMessage !== 'undefined') {
                if (mainController.screenPropertySet.confirmationMessage.length > 0) {
                    var response = confirm(mainController.screenPropertySet.confirmationMessage);
                    if (!response) return;
                }
            }

            inNewWindow = inNewWindow || false;



            //get the set to post
            var changeSet = $filter('filter')(mainController.records, { thisRowHasChanged: true });

            //this is an array for the promises
            var saveCalls = [];


            mainController.loadingCount++;
            var sURL = 'DataSend/DataSend_SaveData.ashx?screenID=' + sScreenID;

            saveCalls.push($http.post(sURL, changeSet))

            //initialize the errorMessage object
            mainController.errorMessages = null;

            //now resolve all the calls
            $q.all(saveCalls).then(
                function (response) {
                    //this response object
                    //is really an array of responses...
                    //...pretty cool...
                    angular.forEach(response, function (val, key) {
                        if (val.data.length > 0) {
                            for (var i = 0; i < val.data.length; i++) {
                                if (val.data[i].hasOwnProperty('iRowID')) {
                                    if (val.data[i].hasOwnProperty('idFieldName')) {
                                        saveObjects[currentIndex][1][val.data[i]['idFieldName']] = val.data[i].iRowID;
                                    }
                                } else {
                                    if (mainController.errorMessages) {
                                        //mainController.errorMessages = null;
                                        mainController.errorMessages.push(val.data[i]);
                                    }
                                    else {
                                        mainController.errorMessages = new Array(val.data[i]);
                                    }
                                }
                            }

                            if (mainController.errorMessages) {
                                //this could be built out into a separate controller and template set to html page
                                $mdToast.show({
                                    template: '<md-toast class="md-toast simple" style="position:fixed;border-style:solid;border-color:red;">' + mainController.errorMessages[0].Message + '</md-toast>'
                                    , hideDelay: 5000
                                    , position: 'top left'
                                });
                            }
                        };
                    });
                    //mainController.errorMessages = response.data;
                    mainController.loadingCount--;
                    if (!mainController.errorMessages) {
                        $mdToast.show(
                            $mdToast.simple()
                                .content('Save Complete.')
                                .position('fit')
                                .hideDelay(2000)
                        );
                        var onSave = mainController.screenPropertySet['clientScriptOnSave'];
                        if (typeof redirectUrl !== 'undefined') {
                            if (redirectUrl.substring(0, 10) == 'javascript') {
                                onSave = redirectUrl.substring(11, redirectUrl.length);
                            } else {
                                if (inNewWindow) {
                                    window.open(redirectUrl);
                                } else {
                                    window.location = redirectUrl;
                                }
                            }

                        }
                        if (typeof onSave !== 'undefined' && onSave > '') {
                            //Apparently using eval is like making a deal with the devil
                            //So we do some crazy mumbo jumbo (also found in custom.js) to call our javascript function from screen.xml
                            var functionCallNoParams = onSave.substring(0, onSave.indexOf('('));
                            var functionParams = onSave.substring(onSave.indexOf('(') + 1, onSave.indexOf(')')).replace(/' /g, '').replace(/ '/g, '').replace(/'/g, '').split(',');

                            var fn = window[functionCallNoParams];
                            if (typeof fn === "function") {
                                //alert('found');
                                fn.apply(null, functionParams);
                            }
                        }

                    }


                    //refresh all data?
                    if (!redirectUrl) {
                        loadAllData();
                    }
                }
                , function (error) {
                    //alert(error);
                    mainController.loadingCount--;
                }

            );

        };

        function executeCommand(thisScreenID, thisRecord) {
            //this is an array for the promises
            var saveCalls = [];


            mainController.loadingCount++;
            var sURL = 'DataSend/DataSend_SaveData.ashx?screenID=' + thisScreenID;

            saveCalls.push($http.post(sURL, thisRecord))

            //initialize errorMessages object
            mainController.errorMessages = null;

            //now resolve all the calls
            $q.all(saveCalls).then(
                function (response) {
                    //this response object
                    //is really an array of responses...
                    //...pretty cool...
                    angular.forEach(response, function (val, key) {
                        if (val.data.length > 0) {
                            for (var i = 0; i < val.data.length; i++) {
                                if (val.data[i].hasOwnProperty('iRowID')) {
                                    if (val.data[i].hasOwnProperty('idFieldName')) {
                                        saveObjects[currentIndex][1][val.data[i]['idFieldName']] = val.data[i].iRowID;
                                    }
                                } else {
                                    if (mainController.errorMessages) {
                                        //mainController.errorMessages = null;
                                        mainController.errorMessages.push(val.data[i]);
                                    }
                                    else {
                                        mainController.errorMessages = new Array(val.data[i]);
                                    }
                                }
                            }

                            if (mainController.errorMessages) {
                                //this could be built out into a separate controller and template set to html page
                                $mdToast.show({
                                    template: '<md-toast class="md-toast simple" style="position:fixed;border-style:solid;border-color:red;">' + mainController.errorMessages[0].Message + '</md-toast>'
                                    , hideDelay: 5000
                                    , position: 'top left'
                                });
                            }
                        };
                    });
                    //mainController.errorMessages = response.data;
                    mainController.loadingCount--;
                    //refresh all data?
                    loadAllData();
                }
                , function (error) {
                    alert(error);
                    mainController.loadingCount--;
                }

            );

        };


    }]);

    app.filter('unsafe', function ($sce) {
        return $sce.trustAsHtml;
    });


    app.directive('csbMaterialDesignCss', function () {

        return {
            restrict: 'A'
            , templateUrl: 'css\\csbMaterialDesign.css'
            //, controller: initializeCargasCSS
        };

    });

    app.directive('tableContentMain', function () {
        searchObject = getURLParameters()

        var sScreenID = searchObject.screenID
        var sParam = searchObject.p;
        var templateURLValue = 'ContentLoad/ContentLoad_ListTable.ashx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + '&isListTemplate=true';

        return {
            restrict: 'EA'
            , templateUrl: templateURLValue

        };
    });
    app.directive('tableContentMainRow', function () {
        return {
            restrict: 'EA'
            , link: function (scope, element, attrs) {
                searchObject = getURLParameters()
                var sScreenID = searchObject.screenID
                if (scope.$last) {
                    scope.$evalAsync(function () {
                        if (typeof listLoadReady == "function") {
                            listLoadReady(sScreenID);
                        }
                    })
                }

                scope.$watchCollection('thisRecord', function (newValue, oldValue) {
                    if (!(newValue == oldValue)) {
                        newValue.thisRowHasChanged = true;
                    }

                });

            }
        };
    });

    app.filter('sqlDatePartOnly', function () {


        return function (input) {
            //var formatLowerCase = _format.toLowerCase();
            //var formatItems = formatLowerCase.split(_delimiter);
            var fullString = input.split(' ');
            return fullString[0];

            //the rest of this would be needed to turn into true javascript date
            //to pipe into the angular js date format function
            var dateItems = fullString[0].split('/');
            //var monthIndex = formatItems.indexOf("mm");
            //var dayIndex = formatItems.indexOf("dd");
            //var yearIndex = formatItems.indexOf("yyyy");
            var month = parseInt(dateItems[0]);
            month -= 1;
            var formatedDate = new Date(dateItems[2], month, dateItems[1]);
            return formatedDate;
        };

    });


    //TODO: refactor
    function getURLParameters() {
        var vars = [], hash;
        vars.push('plist');
        vars.plist = ''
        var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
        for (var i = 0; i < hashes.length; i++) {
            hash = hashes[i].split('=');
            vars.push(hash[0]);
            vars[hash[0]] = hash[1];
            if (hash[0] == 'p') {
                vars.plist = vars.plist + hash[1] + '&p='
            }
        }
        return vars;
    };


    function checkColumnSorting(thisDataContext, thisFieldName) {
        var result = 0;

        //check array for thisFieldName with the + character
        var idxAscending = $.inArray('+' + thisFieldName, thisDataContext.sortDirection);
        var idxDescending = $.inArray('-' + thisFieldName, thisDataContext.sortDirection);

        if (idxAscending > -1) {
            result = -1;
        }
        if (idxDescending > -1) {
            result = 1;
        }

        return result;

    }

    function setColumnSorting(thisDataContext, thisFieldName, dataType) {
        dataType = dataType || 'string';

        var idxAscending = $.inArray('+' + thisFieldName, thisDataContext.sortDirection);
        var idxDescending = $.inArray('-' + thisFieldName, thisDataContext.sortDirection);

        if (idxDescending > -1) {
            thisDataContext.sortDirection.splice(idxDescending, 1);
            thisDataContext.sortString.splice(idxDescending, 1);
            return;
        }
        if (idxAscending > -1) {
            thisDataContext.sortDirection[idxAscending] = '-' + thisFieldName;
            //for the functions, we have to return the values so that when sorted alphabetically they will return in reverse order
            //date and time: negative
            //string: use inverseSort
            switch (dataType) {
                case 'date':
                    thisDataContext.sortString[idxAscending] = function (thisRecord) {
                        return -(new Date(thisRecord[thisFieldName]));
                    };
                    break;
                case 'time':
                    thisDataContext.sortString[idxAscending] = function (thisRecord) {
                        return -(new Date('1/1/1900 ' + thisRecord[thisFieldName]));
                    };
                    break;
                case 'dropdown':
                    thisDataContext.sortString[idxAscending] = function (thisRecord) {
                        var dropdownJSON = thisDataContext.getDropdownJSON();
                        for (var x = 0; x < dropdownJSON[thisFieldName].length; x++) {
                            if (dropdownJSON[thisFieldName][x].value == thisRecord[thisFieldName]) {
                                return inverseString(dropdownJSON[thisFieldName][x].display);
                            }
                        }
                        return thisRecord[thisFieldName];
                    };
                    break;
                default:
                    thisDataContext.sortString[idxAscending] = '-' + thisFieldName;
            }
            return;
        }
        thisDataContext.sortDirection.push('+' + thisFieldName);
        switch (dataType) {
            case 'date':
                thisDataContext.sortString.push(function (thisRecord) {
                    return new Date(thisRecord[thisFieldName]);
                });
                break;
            case 'time':
                thisDataContext.sortString.push(function (thisRecord) {
                    return new Date('1/1/1900 ' + thisRecord[thisFieldName]);
                });
                break;
            case 'dropdown':
                thisDataContext.sortString.push(function (thisRecord) {
                    var dropdownJSON = thisDataContext.getDropdownJSON();
                    for (var x = 0; x < dropdownJSON[thisFieldName].length; x++) {
                        if (dropdownJSON[thisFieldName][x].value == thisRecord[thisFieldName]) {
                            return dropdownJSON[thisFieldName][x].display;
                        }
                    }
                    return thisRecord[fieldName];
                });
                break;
            default:
                thisDataContext.sortString.push('+' + thisFieldName);
        }
        return;
    };

    //because we sort by individual columns, not overall, we have to return values that will sort in reverse order. 
    //Convert the string to an array of negative character codes
    function inverseString(str) {
        str = str.toUpperCase();
        var result = [];
        for (var i = 0, length = str.length; i < length; i++) {
            var code = -1 * str.charCodeAt(i);
            // Since charCodeAt returns between 0~65536, simply save every character as 2-bytes
            result.push(code & 0xff00, code & 0xff);
        }
        return result;
    }



})();
