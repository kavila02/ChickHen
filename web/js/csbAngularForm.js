(function () {
    var app = angular.module('CargasSolutionBuilderAngular', ['angularUtils.directives.dirPagination', 'ngMaterial', 'ngMessages', 'ngStorage', 'textAngular', 'csbAngularUI', 'materialCalendar']);


    app.controller('DataController', ['$http', '$filter', '$scope', '$sessionStorage', '$q', '$mdToast', '$mdMedia', '$timeout', function ($http, $filter, $scope, $sessionStorage, $q, $mdToast, $mdMedia, $timeout, MaterialCalendarData) {





        var loadingCount = 0;
        var mainController = this;

        //properties
        mainController.loadingCount = loadingCount;     //isLoading;

        mainController.record = [];
        mainController.detailRecords = [];
        $scope.dropdownJSON = [];
        mainController.getDropdownJSON = function () {
            return $scope.dropdownJSON;
        }
        mainController.getToday = getTodayDate;
        mainController.screenPropertySet = {};
        $scope.$mdMedia = $mdMedia;
        mainController.selectOpen = function () {
        };


        mainController.selectedDate = new Date();
        mainController.weekStartsOn = 0;
        mainController.dayFormat = "d";
        mainController.tooltips = true;
        mainController.disableFutureDates = false;
        mainController.direction = 'horizontal';

        mainController.setDirection = function (direction) {
            mainController.direction = direction;
            mainController.dayFormat = direction === "vertical" ? "EEEE, MMMM d" : "d";
        };

        mainController.dayClick = function (date) {
            //mainController.msg = "You clicked " + $filter("date")(date, "MMM d, y h:mm:ss a Z");
        };

        mainController.prevMonth = function (data) {
            //mainController.msg = "You clicked (prev) month " + data.month + ", " + data.year;
        };

        mainController.nextMonth = function (data) {
            //mainController.msg = "You clicked (next) month " + data.month + ", " + data.year;
        };

        mainController.setContentViaService = function () {
            var today = new Date();
            MaterialCalendarData.setDayContent(today, '<span> :oD </span>')
        }

        var holidays = { "2015-01-01": [{ "name": "New Year's Day", "country": "US", "date": "2015-01-01" }] };

        // You would inject any HTML you wanted for
        // that particular date here.
        var numFmt = function (num) {
            num = num.toString();
            if (num.length < 2) {
                num = "0" + num;
            }
            return num;
        };

        var loadContentAsync = true;
        mainController.setDayContent = function (date) {
            var key = [date.getFullYear(), numFmt(date.getMonth() + 1), numFmt(date.getDate())].join("-");
            var data = (holidays[key] || [{ name: "" }])[0].name;

            if (loadContentAsync) {
                var deferred = $q.defer();
                $timeout(function () {
                    deferred.resolve(data);
                });
                return deferred.promise;
            }

            return data;

        };

        //mainController.numberOfRowsTouched = numberOfRowsTouched;
        //function numberOfRowsTouched() {
        //    var recCount = 0;

        //    angular.forEach(mainController.detailRecords[0], function(val, key){
        //        recCount += $filter('filter')(val, { thisRowHasChanged: true }).length;
        //    });


        //    return recCount;
        //};

        //events
        mainController.saveData = saveData;
        mainController.executeCommand = executeCommand;

        var menuHTML = 'menuHTML' + document.location.pathname.split("/").slice(-2, -1).toString();
        var leftMenuHTML = 'leftMenuHTML' + document.location.pathname.substr(0, document.location.pathname.lastIndexOf('/')).replace('/', '_');

        //set default properties
        searchObject = getURLParameters();

        var sScreenID = searchObject.screenID;

        //var sParam = searchObject.p;
        var sParam = searchObject.plist;


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
                    redirectUrl = redirectUrl.replace(fieldReference, mainController.record[fieldName]);
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
                    //eval is evil. saveData can handle this
                    //eval(thisAction.data);
                    mainController.saveData(redirectUrl);
                    break;
                case "executeCommand":
                    executeCommand(thisAction.data, mainController.record, thisAction.additionalProcessRedirectUrl);
                    break;
                case "refreshMenus":
                    mainController.refreshMenus();
                    break
                default:
                    alert('default');
                    alert(thisAction.action);

            };
            mainController.actionOpen = false;
        };





        loadScreenPropertySet();
        loadAllData();
        loadMenu();
        loadLeftMenu();


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



        mainController.sectionShowHide = function (index) {
            if (mainController.screenPropertySet.sectionInfo[index][index] == '0') {
                mainController.screenPropertySet.sectionInfo[index][index] = '1'
            } else {
                mainController.screenPropertySet.sectionInfo[index][index] = '0'
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


        mainController.gridPaste = function gridPaste(event, thisRecord, screenID) {
            var currentIndex = mainController.detailRecords[0][screenID].indexOf(thisRecord);
            //in chrome (and possibly other more recent browsers) get pasted data from event.originalEvent.clipboardData.getData('text/plain')
            var fieldName = $(event.target).attr('ng-model').replace('thisRecord.', '');
            var currentElement = $(event.target);
            var pastedData = '';
            if (navigator.userAgent.match(/msie|trident/i)) {
                $('<textarea />').attr('id', 'temp').attr('style', 'position:absolute; left:-3000px;').appendTo('body');
                $('#temp').change(function () {
                    pastedData = $(this).val();
                    pasteData(pastedData, currentElement, thisRecord, fieldName, currentIndex, mainController.detailRecords[0][screenID]);
                    $('#temp').remove();
                });
                $('#temp').focus(function () {
                    $('#temp').blur();
                });
                $('#temp').focus();
            } else {
                pastedData = event.originalEvent.clipboardData.getData('text/plain');
                pasteData(pastedData, currentElement, thisRecord, fieldName, currentIndex, mainController.detailRecords[0][screenID]);
            }
        }

        function pasteData(pastedData, currentElement, thisRecord, fieldName, currentIndex, currentTabRecords) {
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
                        if (arrGroup.length == 1) {
                            multilinePasteReplaceContents = false;
                        }
                        var existingData = thisRecord[fieldName];
                        var newData = arrGroup[i];
                        if (!multilinePasteReplaceContents) {
                            newData = existingData + newData;
                        }
                        thisRecord[fieldName] = newData;
                    }
                    currentIndex = currentIndex + 1;
                    var nextRow = currentTabRecords[currentIndex];
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

        mainController.showInDialog2 = function () {

        };

        mainController.refreshMenus = function () {
            delete sessionStorage[menuHTML];
            delete sessionStorage[leftMenuHTML];
        };

        mainController.menuNav = function (screenID, event) {
            alert(screenID);
        };

        mainController.callReloadAll = function () {
            mainController.errorMessages = null;
            //PRC 12/7/17: I don't think we need to refresh the screen property set with the on screen refresh button. It shouldn't be changing.
            //loadScreenPropertySet();
            loadAllData();
        };

        mainController.singleSelect = function (thisRecord, fieldName) {
            var tabName = $('md-tab-content.md-active').find('form-tab-content').attr('this-record').replace('data.detailRecords[0].', '');
            isSelected = thisRecord[fieldName];
            //uncheck all records
            if (isSelected == 1) {
                for (var i = 0; i < mainController.detailRecords[0][tabName].length; i++) {
                    //we put this condition here so that null checkboxes remain unaffected (so hideWhenNull still keeps it hidden)
                    if (mainController.detailRecords[0][tabName][i][fieldName] == '1') {
                        mainController.detailRecords[0][tabName][i][fieldName] = '0';
                    }
                }
            }
            //check the record that was clicked (cannot unselect a record)
            thisRecord[fieldName] = '1';
        };

        mainController.passwordValidate = function (password, passwordVerify) {
            $scope.csbForm.Password.$setValidity('passwordBlank', true);
            $scope.csbForm.PasswordVerify.$setValidity('passwordVerifyBlank', true);
            $scope.csbForm.PasswordVerify.$setValidity('passwordsDontMatch', true);
            $scope.csbForm.Password.$setValidity('passwordRequirements', true);
            var returnVal = true;
            var requirements = [0, 0, 0, 0, 4];
            if (typeof passwordValidationCustom == 'function') {
                requirements = passwordValidationCustom();
            }
            if (password.length == 0) {
                $scope.csbForm.Password.$setValidity('passwordBlank', false);
                returnVal = false;
            }
            if (passwordVerify.length == 0) {
                $scope.csbForm.PasswordVerify.$setValidity('passwordVerifyBlank', false);
                returnVal = false;
            }
            if (password != passwordVerify) {
                $scope.csbForm.PasswordVerify.$setValidity('passwordsDontMatch', false);
                returnVal = false;
            }
            if (!passwordIsValid(password, requirements)) {
                $scope.csbForm.Password.$setValidity('passwordRequirements', false);
                returnVal = false;
            }
            return returnVal;
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
                if (functionParams[i] == '{record}') {
                    functionParams[i] = mainController.record;
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
            }
            var fn = window[functionCallNoParams];
            if (typeof fn === "function") {
                var valid = fn.apply(null, functionParams);
                if (typeof $scope.csbForm[fieldName] !== 'undefined') {
                    $scope.csbForm[fieldName].$setValidity('custom', valid);
                }
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
                $scope.csbForm[fieldName].$setValidity('validDate', true)

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
                    thisRecord[i][fieldName] = newValue;
                }
            }
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


        function loadScreenPropertySet() {
            //change the caching setting
            //var sURL = 'DataLoad/DataLoad.aspx?screenID=TimeLogLast10&p=&resultType=json';
            var sURL = 'DataLoad/DataLoad_ScreenLayout.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + "&isForm=true";
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

                //alert(mainController.screenPropertySet['redirect']);
            }, function (errorResponse) {
                // called asynchronously if an error occurs
                // or server returns response with an error status.
                //alert(data);
                mainController.loadingCount--;

            });
        };


        function loadAllData() {
            mainController.loadingCount++;
            //this is an array for the promises
            var loadCalls = [];

            var sURL = 'DataLoad/DataLoad.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + '&resultType=json';
            loadCalls.push($http.get(sURL));

            sURL = 'DataLoad/DataLoad_LookupList.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + '&resultType=json';
            loadCalls.push($http.post(sURL, mainController.filterSet));

            sURL = 'DataLoad/DataLoad_DetailReference.aspx?screenID=' + sScreenID + '&p=' + sParam.replace('#', '') + '&resultType=json';
            loadCalls.push($http.post(sURL, mainController.filterSet));

            $q.all(loadCalls).then(
                function (response) {
                    //this response object
                    //is really an array of responses...
                    //...pretty cool...
                    angular.forEach(response, function (val, key) {

                        //main data set
                        if (key == 0) {
                            mainController.record = val.data[0];
                        };
                        //drop down
                        if (key == 1) {
                            $scope.dropdownJSON = val.data[0];
                        };
                        //detail
                        if (key == 2) {
                            mainController.detailRecords = val.data;
                            //init values for paging on multiple tabs
                            angular.forEach(mainController.detailRecords[0], function (val, setNumber) {
                                val.currentPage = 1;
                                //manually changing this from 10 to 20 because that's what Kreider needs
                                //this needs to be configurable
                                //val.pageSize = 20;
                                val.sortString = [];
                                val.sortDirection = [];

                                val.setColumnSorting = setColumnSorting;
                                val.checkColumnSorting = checkColumnSorting;
                                val.getDropdownJSON = mainController.getDropdownJSON;
                            });
                        };

                    });
                    //mainController.errorMessages = response.data;
                    defaultAutoComplete_Form();
                    mainController.loadingCount--;
                    if (typeof formLoadReady == "function") {
                        var solutionBuilderPrimaryForm = $('[name="csbForm"]');
                        formLoadReady(sScreenID, solutionBuilderPrimaryForm, mainController.record, $scope);
                    }
                }
                , function (error) {
                    mainController.loadingCount--;
                }



            );


        };



        mainController.autocompleteLoading = [];
        mainController.autocompleteDeferred = [];
        mainController.autocompleteSelectedItem = [];
        mainController.autocompleteSearchText = [];
        mainController.autocompletePreviousSearchText = [];



        function defaultAutoComplete_Form() {

            var currentRecord = mainController.record;
            for (var fieldName in currentRecord) {
                if (currentRecord.hasOwnProperty(fieldName)) {
                    if ($scope.dropdownJSON.hasOwnProperty(fieldName)) {
                        mainController.autocompleteSelectedItem[fieldName] = $filter('filter')($scope.dropdownJSON[fieldName], { value: currentRecord[fieldName].toString() }, true)[0];
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
                if (typeof (thisRecord[fieldName]) !== 'undefined') {
                    mainController.autocompleteSelectedItem[fieldID] = thisRecord[fieldName];
                    if (isAsync) {
                        mainController.autocompleteSearchTextChanged('', fieldName, fieldID, thisRecord[fieldName], screenID);
                    } else {
                        mainController.autocompleteSelectedItem[fieldID] = $filter('filter')($scope.dropdownJSON[fieldName], { value: thisRecord[fieldName].toString() }, true)[0];
                    }
                    mainController.autocompletePreviousSearchText[fieldID] = '';
                }
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
        //I don't think it's getting called twice all the time, maybe just with async version.
        mainController.autocompleteSelectedOnceAlready = false
        mainController.autocompleteSelectedItemChange = function autocompleteSelectedItemChange(item, thisRecord, fieldName, fieldID, customFunction, isAsync) {
            isAsync = isAsync || true;
            if (typeof (item) !== 'undefined') {
                if (typeof (item.display) !== 'undefined') {
                    thisRecord[fieldName] = item.value;
                    //this condition is causing issues, and only getting called once, so maybe whatever bug this condition was working around is fixed
                    if (!mainController.autocompleteSelectedOnceAlready || !isAsync) {
                        //we pass in true for isGrid. Even if it's not a grid, it forces the function to use what we pass in for thisRecord instead of mainController.record
                        mainController.changeFunction(customFunction, fieldID, true, thisRecord, fieldName, item);
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

                } else {
                    mainController.autocompleteLoading[fieldID] = false;
                }

            }, function (response) {
                mainController.autocompleteLoading[fieldID] = false;
            });
        };


        mainController.passwordHashed = false;

        function validateUserPassword() {
            if (sScreenID == 'UserTable_Form' && !mainController.passwordHashed && typeof (mainController.record.Password) !== 'undefined') {
                var password = mainController.record.Password;
                var passwordVerify = mainController.record.PasswordVerify;
                if (password.length > 0 || passwordVerify.length > 0) {

                    if (mainController.record.UserPasswordSalt.length == 0) {
                        $scope.csbForm['PasswordVerify'].$setValidity('passwordSalt', false);
                        alert('Invalid Salt');
                        return false;
                    } else {
                        var hashedValue = CryptoJS.SHA256(password + mainController.record.UserPasswordSalt).toString(CryptoJS.enc.Base64);
                        mainController.record.UserPassword = hashedValue;
                        mainController.record.Password = '*********' //'*'.repeat(password.length);
                        mainController.record.PasswordVerify = '*********' //'*'.repeat(password.length);
                    }
                }
            }
            return true;
        }



        function passwordIsValid(password, requirements) {
            if (password.replace(/[^a-z]/g, "").length < requirements[0]
                || password.replace(/[^A-Z]/g, "").length < requirements[1]
                || password.replace(/[^~!@#$%^&\*\(\)\_\+\-\=\;:'"<>\?\,\.]/g, "").length < requirements[2]
                || password.replace(/[^0-9]/g, "").length < requirements[3]
                || password.length < requirements[4]
            ) {
                return false;
            } else {
                return true;
            }
        }

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
            validateUserPassword();

            var saveObjects = [];

            mainController.loadingCount++;
            var sURL = 'DataSend/DataSend_SaveData.ashx?screenID=' + sScreenID;

            //add all details that are marked with a 1 for sort (any marked with displayStyle="saveDetailFirst")
            angular.forEach(mainController.detailRecords[0], function (val, key) {
                for (var i = 0; i < mainController.screenPropertySet.detailSaveOrder.length; i++) {
                    if (mainController.screenPropertySet.detailSaveOrder[i].detailScreenID == key && mainController.screenPropertySet.detailSaveOrder[i].saveOrder == 1) {
                        //filter the set
                        var changeSet = $filter('filter')(val, { thisRowHasChanged: true });
                        //if there is anything, then do the rest
                        if (changeSet.length > 0) {
                            //format url
                            //mainController.loadingCount++;
                            var sURL = 'DataSend/DataSend_SaveData.ashx?screenID=' + key;
                            //saveCalls.push($http.post(sURL, changeSet));
                            saveObjects.push([sURL, changeSet]);
                        };
                    }
                }
            });

            //saveCalls.push($http.post(sURL, mainController.record))
            saveObjects.push([sURL, mainController.record]);

            //add all remaining details
            angular.forEach(mainController.detailRecords[0], function (val, key) {
                for (var i = 0; i < mainController.screenPropertySet.detailSaveOrder.length; i++) {
                    if (mainController.screenPropertySet.detailSaveOrder[i].detailScreenID == key && mainController.screenPropertySet.detailSaveOrder[i].saveOrder == 3) {
                        //filter the set
                        var changeSet = $filter('filter')(val, { thisRowHasChanged: true });
                        //if there is anything, then do the rest
                        if (changeSet.length > 0) {
                            //format url
                            //mainController.loadingCount++;
                            var sURL = 'DataSend/DataSend_SaveData.ashx?screenID=' + key;
                            //saveCalls.push($http.post(sURL, changeSet));
                            saveObjects.push([sURL, changeSet]);
                        };
                    }
                }
            });

            //initialize teh errorMessages array
            mainController.errorMessages = null;

            if (mainController.screenPropertySet.asyncSave == "False") {
                //run save call in order
                mainController.syncSave(saveObjects, 0, redirectUrl, inNewWindow);

            } else {
                //create deferred object so that we can queue up all saves that need to happen,
                //and then process one then on all of the promises...

                //this is an array for the promises
                var saveCalls = [];
                for (var x = 0; x < saveObjects.length; x++) {
                    saveCalls.push($http.post(saveObjects[x][0], saveObjects[x][1]));
                }

                //now resolve all the calls asyncronously
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
                                        template: '<md-toast class="md-toast simple" style="top:0px; bottom:unset; position:fixed;border-style:solid;border-color:red;">' + mainController.errorMessages[0].Message + '</md-toast>'
                                        , hideDelay: 5000
                                        , position: 'top left'
                                    });
                                    mainController.loadingCount--;
                                }
                            };
                        });
                        //mainController.errorMessages = response.data;

                        if (!mainController.errorMessages) {
                            mainController.successfulSave(redirectUrl, inNewWindow);
                        }



                    }
                    , function (error) {
                        //throws an error if one of the tabs doesn't contain records
                        //alert('error 1');
                        //alert(error);
                        mainController.loadingCount--;
                    }

                );
            }

        };

        mainController.syncSave = function syncSave(saveObjects, currentIndex, redirectUrl, inNewWindow) {
            if (saveObjects.length > 0) {
                $http.post(saveObjects[currentIndex][0], saveObjects[currentIndex][1]).then(function (response) {
                    if (response.data.length > 0) {
                        for (var i = 0; i < response.data.length; i++) {
                            if (response.data[i].hasOwnProperty('iRowID')) {
                                if (response.data[i].hasOwnProperty('idFieldName')) {
                                    saveObjects[currentIndex][1][response.data[i]['idFieldName']] = response.data[i].iRowID;
                                }
                            } else {
                                if (mainController.errorMessages) {
                                    //mainController.errorMessages = null;
                                    mainController.errorMessages.push(response.data[i]);
                                }
                                else {
                                    mainController.errorMessages = new Array(response.data[i]);
                                }
                            }
                        }
                        if (mainController.errorMessages) {
                            //this could be built out into a separate controller and template set to html page
                            $mdToast.show({
                                template: '<md-toast class="md-toast simple" style="top:0px; bottom:unset; position:fixed;border-style:solid;border-color:red;">' + mainController.errorMessages[0].Message + '</md-toast>'
                                , hideDelay: 5000
                                , position: 'top left'
                            });
                            mainController.loadingCount--;
                        }
                    } else {
                        //no error, move to next record
                        if (saveObjects.length == currentIndex + 1) {
                            //this was the last save- move on with life
                            mainController.successfulSave(redirectUrl, inNewWindow);
                        } else {
                            //call again for next save
                            mainController.syncSave(saveObjects, currentIndex + 1, redirectUrl, inNewWindow);
                        }
                    }


                });
            } else {
                //No records to save, move on with life
                mainController.successfulSave(redirectUrl, inNewWindow);
            }

        };

        mainController.successfulSave = function successfulSave(redirectUrl, inNewWindow) {
            mainController.loadingCount--;

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
                if (onSave.substring(0, 10) == 'javascript') {
                    onSave = onSave.substring(11, onSave.length);
                }
                var functionCallNoParams = onSave.substring(0, onSave.indexOf('('));
                var functionParams = onSave.substring(onSave.indexOf('(') + 1, onSave.indexOf(')')).replace(/' /g, '').replace(/ '/g, '').replace(/'/g, '').split(',');

                var fn = window[functionCallNoParams];
                if (typeof fn === "function") {
                    //alert('found');
                    fn.apply(null, functionParams);
                }
            }

            //refresh all data?
            if (!redirectUrl) {
                loadAllData();
            }
        };

        mainController.runReport = function runReport() {
            
            var reportUrl = mainController.screenPropertySet.reportUrl;
            reportUrl = reportUrl.replace('{{data.screenPropertySet.reportFormat}}', mainController.screenPropertySet.reportFormat);

            var sURL = 'DataSend/DataSend_MapUpdateXml.ashx?ScreenID=' + sScreenID;
            
            $http.post(sURL, mainController.record).then(function (response) {
                console.log(response.data);
                reportUrl = reportUrl + response.data[0].parameters;
                mainController.loadingCount--;

                if (mainController.screenPropertySet.reportPopup == "True") {
                    window.open(reportUrl, "_blank");
                } else {
                    window.location = reportUrl;
                }
            }, function (errorResponse) {
                mainController.loadingCount--;

            });

        };

        function executeCommand(thisScreenID, thisRecord, redirectUrl) {

            //this is an array for the promises
            var saveCalls = [];


            mainController.loadingCount++;
            var sURL = 'DataSend/DataSend_SaveData.ashx?screenID=' + thisScreenID;

            saveCalls.push($http.post(sURL, thisRecord))

            //initialize errorMessages array
            mainController.errorMessages = null;

            //now resolve all the calls
            $q.all(saveCalls).then(
                function (response) {
                    //this response object
                    //is really an array of responses...
                    //...pretty cool...
                    angular.forEach(response, function (val, key) {
                        if (val.data.length > 0) {
                            if (mainController.errorMessages) {
                                //mainController.errorMessages = null;
                                mainController.errorMessages.push(val.data);
                            }
                            else {
                                mainController.errorMessages = val.data;
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
                                window.location = redirectUrl;
                            }

                        }
                        if (typeof onSave !== 'undefined' && onSave > '') {
                            //Apparently using eval is like making a deal with the devil
                            //So we do some crazy mumbo jumbo (also found in custom.js) to call our javascript function from screen.xml
                            if (onSave.substring(0, 10) == 'javascript') {
                                onSave = onSave.substring(11, onSave.length);
                            }
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
                    alert('error 2');
                    alert(error);
                    mainController.loadingCount--;
                }

            );

        };




    }]);


    app.config(function ($provide) {
        // this demonstrates how to register a new tool and add it to the default toolbar
        $provide.decorator('taOptions', ['taRegisterTool', '$delegate', function (taRegisterTool, taOptions) { // $delegate is the taOptions we are decorating
            taOptions.toolbar = [
                ['bold', 'italics', 'underline', 'strikeThrough', 'ul', 'ol', 'justifyLeft', 'justifyCenter', 'justifyRight', 'indent', 'outdent', 'insertImage', 'insertLink', 'undo', 'redo', 'clear', 'html']
            ];


            /*

            taOptions.toolbar = [
              ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'pre', 'quote'],
              ['bold', 'italics', 'underline', 'strikeThrough', 'ul', 'ol', 'redo', 'undo', 'clear'],
              ['justifyLeft', 'justifyCenter', 'justifyRight', 'indent', 'outdent'],
              ['html', 'insertImage', 'insertLink', 'insertVideo', 'wordcount', 'charcount']
            ];
            taRegisterTool('test', {
                buttontext: 'Test',
                action: function () {
                    alert('Test Pressed')
                }
            });
            taOptions.toolbar[1].push('test');
            taRegisterTool('colourRed', {
                iconclass: "fa fa-square red",
                action: function () {
                    this.$editor().wrapSelection('forecolor', 'red');
                }
            });
            // add the button to the default toolbar definition
            taOptions.toolbar[1].push('colourRed');
            
            taOptions.classes = {
                focussed: 'focussed',
                toolbar: 'btn-toolbar',
                toolbarGroup: 'btn-group',
                toolbarButton: 'btn btn-default',
                toolbarButtonActive: 'active',
                disabled: 'disabled',
                textEditor: 'form-control',
                htmlEditor: 'form-control'
            };
            */
            return taOptions;
        }]);
        /*
        // this demonstrates changing the classes of the icons for the tools for font-awesome v3.x
        $provide.decorator('taTools', ['$delegate', function (taTools) {
            taTools.bold.iconclass = 'icon-bold';
            taTools.italics.iconclass = 'icon-italic';
            taTools.underline.iconclass = 'icon-underline';
            taTools.ul.iconclass = 'icon-list-ul';
            taTools.ol.iconclass = 'icon-list-ol';
            taTools.undo.iconclass = 'icon-undo';
            taTools.redo.iconclass = 'icon-repeat';
            taTools.justifyLeft.iconclass = 'icon-align-left';
            taTools.justifyRight.iconclass = 'icon-align-right';
            taTools.justifyCenter.iconclass = 'icon-align-center';
            taTools.clear.iconclass = 'icon-ban-circle';
            taTools.insertLink.iconclass = 'icon-link';
            taTools.insertImage.iconclass = 'icon-picture';
            // there is no quote icon in old font-awesome so we change to text as follows
            delete taTools.quote.iconclass;
            taTools.quote.buttontext = 'quote';
            return taTools;
        }]);
        */
    });

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


    function getTodayDate() {
        //return '8/27/15'

        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();

        if (dd < 10) {
            dd = '0' + dd
        }

        if (mm < 10) {
            mm = '0' + mm
        }

        today = mm + '/' + dd + '/' + yyyy;
        return today;

    };


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
    }


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
                        return thisRecord[fieldName];
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
                    return thisRecord[thisFieldName];
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
