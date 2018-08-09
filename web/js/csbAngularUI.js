/// <reference path="appBar.tpl.html" />
/// <reference path="appBar.tpl.html" />
(function () {
    var moduleName = 'csbAngularUI';

    //websiteColor and secondaryColor can be set in custom.js. if they are not, default to blue

    var primaryColor = 'blue';
    var secondaryColor = 'blue';
    if (typeof websiteColor !== 'undefined') {
        primaryColor = websiteColor;
    }
    if (typeof websiteSecondaryColor !== 'undefined') {
        secondaryColor = websiteSecondaryColor;
    }

    var app;
    try {
        app = angular.module(moduleName);
    } catch (err) {
        // named module does not exist, so create one
        app = angular.module(moduleName, []);
    }

    app.config(function ($mdThemingProvider) {
        $mdThemingProvider.theme('default')
        .primaryPalette(primaryColor)
        .accentPalette(secondaryColor)

    });


    //put the theming provider into the provider value space
    //so it is accessible in other "scopes"
    app.config(function ($provide, $mdThemingProvider) {
        $provide.value('themeProvider', $mdThemingProvider);
    });

    //, '$mdThemingProvider'
    app.controller('initializeCargasCSS', ['$scope', 'themeProvider', function ($scope, themeProvider) {

        var materialDesignStyleController = this;
        var colorMap

        colorMap = themeProvider._PALETTES[themeProvider.theme('default').colors['primary'].name];

        //make available to scope, if needed
        $scope.colorMap = colorMap;

        materialDesignStyleController.resolveColor = resolveColor;
        materialDesignStyleController.resolvePaletteColor = resolvePaletteColor;
        materialDesignStyleController.resolveThemePaletteColor = resolveThemePaletteColor;

        function resolveColor(colorCode, contrast) {
            var returnValue = '';

            if (contrast) {
                returnValue = themeProvider._rgba(colorMap[colorCode].contrast);
            }
            else {
                returnValue = themeProvider._rgba(colorMap[colorCode].value);
            }

            return returnValue;
        }

        function resolvePaletteColor(colorPaletteName, colorCode) {
            var returnValue = '';

            returnValue = themeProvider._rgba(themeProvider._PALETTES[themeProvider.theme('default').colors[colorPaletteName].name][colorCode].value);

            return returnValue;

        }

        function resolveThemePaletteColor(themeName, colorPaletteName, colorCode) {
            var returnValue = '';

            returnValue = themeProvider._rgba(themeProvider._PALETTES[themeProvider.theme(themeName).colors[colorPaletteName].name][colorCode].value);

            return returnValue;

        }

    }]);

    app.controller('mainDialog', ['$scope', '$mdDialog', mainDialog]);

    function mainDialog($scope, $mdDialog) {
        var mainDialog = this;

        mainDialog.singleRecordTemplate = singleRecordTemplate;
        mainDialog.Label = "Click Here";

        function singleRecordTemplate(thisTemplateURL, thisItem, thisEvent) {

            $mdDialog.show({
                //templateUrl: 'solution/CustomLayout/ProjectFormLeftNavDialog.html'
                templateUrl: thisTemplateURL
                ,targetEvent: thisEvent
                , controller: DialogController
                , controllerAs: 'local'
                , clickOutsideToClose: true
                , locals: { item: thisItem }
            }).then(function (answer) {
                $scope.alert = 'You said the information was "' + answer + '".';
            }, function () {
                $scope.alert = 'You cancelled the dialog.';
            });


        };


    };
    function DialogController($scope, $mdDialog, item) {
        
        var dialogCtrl = this;
        dialogCtrl.item = item;

        $scope.hide = function () {
            $mdDialog.hide();
        };
        $scope.cancel = function () {
            $mdDialog.cancel();
        };
        $scope.answer = function (answer) {
            $mdDialog.hide(answer);
        };
    }


    app.controller('exportToExcel', ['$filter', exportToExcel]);
    function exportToExcel($filter) {
        var exportCtrl = this;
        exportCtrl.Export_JSON_To_Excel = JSONToCSVConvertor;


        function JSONToCSVConvertor(JSONData, ReportTitle, ShowLabel, columnsToShow, searchString, sortString, dropdownJSON) {
            //If JSONData is not an object then JSON.parse will parse the JSON string in an Object
            //var arrData = typeof JSONData != 'object' ? JSON.parse(JSONData) : JSONData;
            
            var CSV = '';
            //Set Report title in first row or line
            CSV += ReportTitle + '\r\n\n';

            //filter and sort the JSON object
            JSONData = $filter('filter')(JSONData, searchString)
            JSONData = $filter('orderBy')(JSONData, sortString)

            //This condition will generate the Label/Header
            if (ShowLabel) {
                var row = "";
                if (columnsToShow.length > 0) {
                    angular.forEach(columnsToShow, function (val, key) {
                        row += val.label + ',';
                    });
                }
                else {
                    //This loop will extract the label from 1st index of on array
                    //use this if no column set for the export is sent in
                    for (var index in JSONData[0]) {

                        //Now convert each value to string and comma-seprated
                        row += index + ',';
                    }

                }


                row = row.slice(0, -1);

                //append Label row with line break
                CSV += row + '\r\n';
            }

            //1st loop is to extract each row
            for (var i = 0; i < JSONData.length; i++) {
                var row = "";

                //2nd loop will extract each column and convert it in string comma-seprated
                if (columnsToShow.length > 0) {
                    angular.forEach(columnsToShow, function (val, key) {
                        var isDropDown = false;
                        var fieldName = val.field;
                        var fieldValue = JSONData[i][fieldName];
                        if (val.hasOwnProperty('isDropDown')) {
                            isDropDown = val.isDropDown;
                        }
                        if (isDropDown) {
                            var displayValue = '';
                            for (var j = 0; j < dropdownJSON[fieldName].length; j++) {
                                if (dropdownJSON[fieldName][j].value == fieldValue) {
                                    displayValue = dropdownJSON[fieldName][j].display;
                                    break;
                                }
                            }
                            row += '"' +  displayValue + '",';
                        }
                        else {
                            row += '"' + fieldValue + '",';
                        }
                    });
                }
                else {
                    for (var index in JSONData[i]) {
                        row += '"' + JSONData[i][index] + '",';
                    }
                };

                row.slice(0, row.length - 1);

                //add a line break after each row
                CSV += row + '\r\n';
            }

            if (CSV == '') {
                alert("Invalid data");
                return;
            }

            //Generate a file name
            var fileName = "MyReport_";
            //this will remove the blank-spaces from the title and replace it with an underscore
            fileName += ReportTitle.replace(/ /g, "_");

            //Initialize file format you want csv or xls
            //this has size limits....so switched to BLOB, which is a newer feature.
            //var uri = 'data:text/csv;charset=utf-8,' + escape(CSV);

            var thisBlob = new Blob([CSV]);


            // Now the little tricky part.
            // you can use either>> window.open(uri);
            // but this will not work in some browsers
            // or you will not get the correct file extension    

            //this trick will generate a temp <a /> tag
            var link = document.createElement("a");
            //link.href = uri;
            link.href = URL.createObjectURL(thisBlob);

            //set the visibility hidden so it will not effect on your web-layout
            link.style = "visibility:hidden";
            link.download = fileName + ".csv";

            //this part will append the anchor tag and remove it after automatic click
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            thisBlob = null;
        };


    };


    app.directive('appBar', function () {

        return {
            restrict: 'E'
            , templateUrl: "TemplateHtml/appBar.tpl.html"

        };
    });
    app.directive('contextBar', function () {

        return {
            restrict: 'E'
            , templateUrl: "TemplateHtml/contextBar.tpl.html"

        };
    });

    

    app.directive('csbMenu', function () {

        return {
            restrict: 'A'
            , link: function (scope, element, attrs) {
                
                $(element).html(scope.$parent.data.menuHTML);
                
                //this is in the quartz menu.js....
                //maybe it should move?
                initQuartzMenu();
                var watch = scope.$watch(function () {
                    return element.children().length;
                }, function () {
                    scope.$evalAsync(function () {
                        //var children = element.children();
                        //console.log(children);

                        //So internet explorer seems to calculate width including padding, so our 130px fix for right aligned menus breaks IE
                        //Manually override the width here, essentially undoing styles.css line ~171
                        var msie = window.navigator.userAgent.indexOf("MSIE ");
                        if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))  // If Internet Explorer
                        {
							//sometimes the object doesn't exist, so rather than editing the style of an object that may not exist, we will inject the css into the head
							$("<style type='text/css'> #cssmenu.align-right ul ul li a {width:170px !important}</style>").appendTo("head");
                            $('#cssmenu.align-right ul ul li a').attr('style', 'width:170px;');
                        }
                        if (typeof menuReady == "function") {
                            menuReady();
                        }
                    })
                });
            }
        };

    });

    app.directive('csbLeftMenu', function () {

        return {
            restrict: 'A'
            , link: function (scope, element, attrs) {

                $(element).html(scope.$parent.data.leftMenuHTML);
                
                scope.$evalAsync(function () {
                    if (typeof leftMenuReady == "function") {
                        leftMenuReady();
                    }
                })
                
            }

        };

    });


    app.directive('csbSiteHeader', function () {
        var templateURLValue = "ContentLoad/ContentLoad_SiteHeader.ashx"

        return {
            restrict: 'A'
            , templateUrl: templateURLValue
        };

    });

    app.directive('findControl', function () {
        searchObject = getURLParameters()

        var sScreenID = searchObject.screenID
        //var sParam = searchObject.p;
        var sParam = searchObject.plist;

        //var templateURLValue = 'ContentLoad/ContentLoad_Form.ashx?ScreenID=TimeLogLast10Find&p=';
        var templateURLValue = 'ContentLoad/ContentLoad_Form.ashx?screenID=' + sScreenID + '&p=' + sParam + '&referenceType=findSQL';

        return {
            restrict: 'E'
            //,template: ''
            //, templateUrl: 'CSB_AngularFindControlTest.html'
            , templateUrl: templateURLValue
            , scope: {
                thisRecord: '='
                , dropdownJSON: '='
                , parentData: '='
            }
        };

    });


    app.directive('formContent', function () {
        

        searchObject = getURLParameters()

        var sScreenID = searchObject.screenID
        var templateURLValue = 'ContentLoad/ContentLoad_Form.ashx?ScreenID=' + sScreenID + '&p=' + searchObject.plist;

        return {
            require: '^form'
            , restrict: 'E'
            //, templateUrl: 'CSB_AngularFormTest.html'
            , templateUrl: templateURLValue
            , scope: {
                thisRecord: '='
                , parentData: '=parentData'
                , dropdownJSON: '='
            }
            //do this to link the form object into my scope
            //which is needed to do the form messages
            , link: function (scope, element, attrs, ctrl) {
                scope.csbForm = ctrl;
            }
            
        };

    });

    app.directive('formTabs', function () {

        //changed to implement md-tabs...
        searchObject = getURLParameters()

        var sScreenID = searchObject.screenID
        var templateURLValue = 'ContentLoad/ContentLoad_Tabs.ashx?ScreenID=' + sScreenID;

        return {
            restrict: 'E'
            //template: templateValue,
            //templateUrl: 'TimeEntryTabs.html'
            , templateUrl: templateURLValue   /*'TimeEntryTabs.html',*/
        };



    });

    app.directive('navContent', function () {

        //changed to implement md-tabs...
        searchObject = getURLParameters()

        var sScreenID = searchObject.screenID
        var templateURLValue = 'ContentLoad/ContentLoad_Form.ashx?ScreenID=' + sScreenID + '&referenceType=LeftNav';

        return {
            restrict: 'E',
            templateUrl: templateURLValue   /*'TimeEntryTabs.html',*/
        };

    });


    app.directive('formTabContent', function () {

        //function dynamicTemplate() {
        //    return '<div>loading...' + screenId + '</div>'
        //};
        //maybe dynamically replace the template {{screenID}} with the current value
        return {
            restrict: 'E'
            //,template: '<div>loading...{{screenId}}</div>'
            , templateUrl: "TemplateHtml/FormTabGridContent.html"
            , scope: {
                screenId: '@'
				, pageSize: '@'
                , theseRecords: '=thisRecord'
                , thisRecord: '=thisRecord'
                , data: "=data"
            }
            
            
        };
    });

    app.directive("treeModel", function ($compile) {
        return {
            restrict: "A"
            //scope,element,attributes
            , link: function (scope, element, attributes) {
                var treeId = attributes.treeId
                    , treeModel = attributes.treeModel
                    , label = attributes.nodeLabel || "label"
                    , children = attributes.nodeChildren || "children"
                    , nodeSelectFunction = attributes.nodeSelectFunction
                    , foldersOnly = attributes.foldersOnly
                    , className = attributes.classField
                    , mainModel = attributes.mainModel || "parentData"
                    , label = '<ul>'
                            + '<li class="' + className + '" ng-show="(' + foldersOnly + '==1&&node.isFolder==\'True\')||' + foldersOnly + '==0" ng-class="{noKids:!node.' + children + '.length}" data-ng-repeat="node in ' + treeModel + '">'
                                + '<i class="material-icons collapsed" data-ng-show="node.' + children + '.length && !node.expanded" data-ng-click="' + treeId + '.selectNodeHead(node)">chevron_right</i>'
                                + '<i class="material-icons expanded" data-ng-show="node.' + children + '.length && node.expanded" data-ng-click="' + treeId + '.selectNodeHead(node)">expand_more</i>'
                                + '<i class="material-icons normal" data-ng-hide="node.' + children + '.length"></i>'
                                + '<span class="{{node.' + className + '}}" data-ng-class="node.selected" ng-click="' + mainModel + '.treeNodeSelect(node,\'' + nodeSelectFunction + '\')">{{node.' + label + '}}</span>'
                                + '<div data-ng-if="node.expanded" data-tree-id="' + treeId + '" data-tree-model="node.' + children + '" data-node-id=' + (attributes.nodeId || "id") + " data-node-label=" + label + " data-node-children=" + children + ' " node-select-function="' + nodeSelectFunction + '" data-folders-only="' + foldersOnly + '" data-class-field="' + attributes.classField + '" data-main-model="' + mainModel + '"></div>'
                            + '</li>'
                          + '</ul>';
                treeId && treeModel && (attributes.angularTreeview &&
                            (scope[treeId] = scope[treeId] || {}
                            , scope[treeId].selectNodeHead = scope[treeId].selectNodeHead
                                || function (a) { a.expanded = !a.expanded }
                            )
                            , element.html('').append($compile(label)(scope))
                          )
                } //end link function
        } //end return
    });

    app.directive('tableContent', function () {
        return {
            restrict: 'EA'
            , templateUrl: getTemplateURL
            , scope: {
                theseRecords: '=theseRecords'
                , pageSize: '=pageSize'
                , data: '=data'
            }
        };

        function getTemplateURL(tElement, tAttrs) {
            var tabContentElement = tElement[0].parentElement;
            var sScreenID = tabContentElement.getAttribute('screen-id');
            var value = 'ContentLoad/ContentLoad_ListTable.ashx?ScreenID=' + sScreenID + '&p=';

            //var trDataElement = tElement[0].parentElement.nextElementSibling.children[0]
            //trDataElement.setAttribute("screenID", sScreenID);


            return value;
        }
    });
    app.directive('tableContentRow', function () {
        return {
            restrict: 'EA'
            , link: function (scope, element, attrs) {

                //attach the dropdownJSON to this scope
                if (!scope.dropdownJSON) {
                    scope.dropdownJSON = scope.$parent.$parent.$parent.dropdownJSON;
                }
                else {
                    if (scope.dropdownJSON.length != scope.$parent.$parent.$parent.dropdownJSON.length) {
                        scope.dropdownJSON = scope.$parent.$parent.$parent.dropdownJSON;
                    };
                };

                if (scope.$last) {
                    scope.$evalAsync(function () {
                        if (typeof listLoadReady == "function") {
                            listLoadReady(attrs.tableScreenId);
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


    app.directive('csbWatchCollection', function () {
        return {
            restrict: 'EA'
            //,transclude: true   //this means that the scope of this directive is the parent scope, don't need to try to pass down the data object
            , scope: {
                thisRecord: '=row'
            }
            , link: function (scope, element, attrs) {

                //move to the controller?
                //make this smarter based on detail being editable?
                scope.$watchCollection('thisRecord', function (newValue, oldValue) {
                    if (!(newValue == oldValue)) {
                        newValue.thisRowHasChanged = true;
                        //console.log(oldValue);
                        //console.log(newValue);
                    }

                });
            }
        };

    });


    app.directive('jqDate', function () {
        return {
            restrict: 'EA'
        , link: function (scope, element, attrs) {
            //have to do this this way, since the element's id
            //has not yet been resolved
            attrs.$observe('id', function (value) {
                var dateInput = $('#' + value);
                datePickerInitialize(dateInput)

            });

        }

        }

    });

    app.directive('validDate', function () {
        //requires jquery UI datapicker be part of solution
        //which is no problem for us...
        return {
            require: 'ngModel'
            , link: function (scope, elm, attrs, ctrl) {
                ctrl.$validators.validDate = function (modelValue, viewValue) {
                    var result = false;
                    if (typeof (viewValue) === 'undefined') { //onload, viewValue is undefined, we need to not throw a false value or it prevents saving the whole time
                        return true;
                    }
                    try {
                        testdate = $.datepicker.parseDate('mm/dd/yy', viewValue);
                        result = true;
                        // Notice 'yy' indicates a 4-digit year value
                    } catch (e) {
                        result = false;
                    }
                    
                    return result;
                };
            }
        };

    });
    
    //utility functions
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
                vars.plist = vars.plist + hash[1].replace('#','') + '&p='
            }
        }
        return vars;
    }


    app.filter('csbCustomFormat', ['$filter', function ($filter) {
        return function (text, filterName, decimals) {
            switch (filterName) {
                case 'numeric':
                    if (decimals == '') decimals = undefined;
                    return (text === null || text === '' || (!text && text !== 0) ? '' : $filter('number')(text, decimals));
                case 'currency':
                    if (decimals === undefined) decimals = 2;
                    else if (decimals < 0) decimals = 0;
                    return (text === null || text === '' || (!text && text !== 0) ? '' : '$' + $filter('number')(text, decimals));
                case 'phone':
                    if (text) {
                        text = text.replace(/[^0-9]/g, '');
                        if (text.substring(10) == '0000' || text.substring(10) == '00000') {
                            text = text.substring(0, 10)
                        }
                        if (text.length > 10) {
                            return text.replace(/(\d{3})(\d{3})(\d{4})(\d{0,5})/, "$1-$2-$3 x$4");
                        } else {
                            return text.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
                        }
                    } else {
                        return '';
                    }
                case 'time':
                    if (text) {
                        var lastThree = text.substring(text.length - 3).toLowerCase();
                        var lastTwo = text.substring(text.length - 2).toLowerCase();
                        var lastOne = text.substring(text.length - 1).toLowerCase();
                        var timePart = text.replace(' am', '').replace(' pm', '').replace('am', '').replace('pm', '').replace('a', '').replace('p', '')
                        if (lastThree !== ' pm' && lastThree !== ' am') {
                            if (lastTwo == 'pm' || lastOne == 'p') {
                                text = timePart + ' PM';
                            }
                            if (lastTwo == 'am' || lastOne == 'a') {
                                text = timePart + ' AM';
                            }
                        }

                        return (text ? $filter("date")(text, "shortTime") : '');
                    } else {
                        return '';
                    }
            }
        };
    }]);


    app.directive('csbFormatTime', ['$filter', function ($filter) {
        return {
            restrict: 'A',
            require: 'ngModel',
            link: function (scope, element, attr, ngModel) {

                function toView(text) {
                    return $filter('csbCustomFormat')(text, 'time');
                }
                ngModel.$formatters.push(toView);

                function toModel(text) {
                    return text.replace(/^([01]\d|2[0-3]):?([0-5]\d)$/g, "");
                }
                ngModel.$parsers.push(toModel);

                element.bind('blur', function () {
                    ngModel.$viewValue = toView(ngModel.$modelValue);
                    ngModel.$render();
                });
            }
        };
    }]);
    
    app.directive('csbFormatNumeric', ['$filter', function ($filter) {
        return {
            restrict: 'A',
            require: 'ngModel',
            link: function (scope, element, attr, ngModel) {

                function toView(text) {
                    return $filter('csbCustomFormat')(text, attr.csbFormatNumeric, attr.csbFormatDecimals);
                }
                ngModel.$formatters.push(toView);

                function toModel(text) {
                    if (attr.csbFormatDecimals === undefined) return text.replace(/[^0-9\.\-]/g, "");
                    else return parseFloat(text.replace(/[^0-9\.\-]/g, "")).toFixed(attr.csbFormatDecimals || 2);
                }
                ngModel.$parsers.push(toModel);

                element.bind('blur', function () {
                    ngModel.$viewValue = toView(ngModel.$modelValue);
                    ngModel.$render();
                });
            }
        };
    }]);

    app.directive('csbFormatPhone', ['$filter', function ($filter) {
        return {
            restrict: 'A',
            require: 'ngModel',
            link: function (scope, element, attr, ngModel) {

                function toView(text) {
                    return $filter('csbCustomFormat')(text, attr.csbFormatPhone, 0);
                }
                ngModel.$formatters.push(toView);

                function toModel(text) {
                    return text.replace(/[^0-9]/g, "");
                }
                ngModel.$parsers.push(toModel);

                element.bind('blur', function () {
                    ngModel.$viewValue = toView(ngModel.$modelValue);
                    ngModel.$render();
                });
            }
        };
    }]);

    //file uploader stuff
    app.factory('fileUploader', ['$rootScope', '$q', function ($rootScope, $q) {
        var svc = {
            post: function (files, data, progressCb) {

                return {
                    to: function (uploadUrl) {
                        var deferred = $q.defer()
                        if (!files || !files.length) {
                            deferred.reject("No files to upload");
                            return;
                        }

                        //todo:  deal with response of 404...
                        //right now it appears to be working but actually does not

                        var xhr = new XMLHttpRequest();
                        xhr.upload.onprogress = function (e) {
                            $rootScope.$apply(function () {
                                var percentCompleted;
                                if (e.lengthComputable) {
                                    percentCompleted = Math.round(e.loaded / e.total * 100);
                                    if (progressCb) {
                                        progressCb(percentCompleted);
                                    } else if (deferred.notify) {
                                        var ret = {
                                            files: files,
                                            //data: angular.fromJson(xhr.responseText)
                                            percentCompleted: percentCompleted
                                        };
                                        deferred.notify(ret);
                                    }
                                }
                            });
                        };

                        xhr.onload = function (e) {
                            $rootScope.$apply(function () {
                                var ret = {
                                    files: files,
                                    //data: angular.fromJson(xhr.responseText)
                                    data: xhr.responseText
                                };
                                deferred.resolve(ret);
                            })
                        };

                        xhr.upload.onerror = function (e) {
                            var msg = xhr.responseText ? xhr.responseText : "An unknown error occurred posting to '" + uploadUrl + "'";
                            $rootScope.$apply(function () {
                                deferred.reject(msg);
                            });
                        }

                        var formData = new FormData();

                        if (data) {
                            Object.keys(data).forEach(function (key) {
                                formData.append(key, data[key]);
                            });
                        }

                        for (var idx = 0; idx < files.length; idx++) {
                            formData.append(files[idx].name, files[idx]);
                        }

                        xhr.open("POST", uploadUrl);
                        xhr.send(formData);
                        
                        return deferred.promise;
                    }
                };
            }
        };

        return svc;
    }]);

    //file uploader directive

    app.directive('csbFileUpload', ['fileUploader', function (fileUploader) {
        return {
            restrict: 'E',
            replace: true,
            scope: {
                chooseFileButtonText: '@',
                chooseFileButtonStyle: '@',
                acceptFileType: '@',
                uploadFileButtonText: '@',
                uploadFileButtonStyle: '@',
                uploadUrl: '@',
                maxFiles: '@',
                maxFileSizeMb: '@',
                autoUpload: '@',
                getAdditionalData: '&',
                onProgress: '&',
                onDone: '&',
                onError: '&',
                onFileAdded: '&',
                screenPropertySet: '&',
                customValidateFunction: '&',
                customErrorMessage: '@'
            },
            templateUrl: 'TemplateHtml/csbFileUpload.html',
            compile: function compile(tElement, tAttrs, transclude) {
                var fileInput = angular.element(tElement.children()[0]);
                var fileLabel = angular.element(tElement.children()[1]);

                if (!tAttrs.chooseFileButtonStyle) {
                    tAttrs.chooseFileButtonStyle = 'md-button md-raised md-primary';
                }

                if (!tAttrs.uploadFileButtonStyle) {
                    tAttrs.uploadFileButtonStyle = 'md-button md-raised md-primary';
                }

                if (tAttrs.acceptFileType) {
                    $(fileInput).attr('accept', tAttrs.acceptFileType);
                }

                if (!tAttrs.maxFiles) {
                    tAttrs.maxFiles = 1;
                    fileInput.removeAttr("multiple")
                } else {
                    fileInput.attr("multiple", "multiple");
                }

                if (!tAttrs.maxFileSizeMb) {
                    tAttrs.maxFileSizeMb = 50;
                }

                var fileId = (Math.random().toString(16) + "000000000").substr(2, 8);
                fileInput.attr("id", fileId);
                fileLabel.attr("for", fileId);

                return function postLink(scope, el, attrs, ctl) {
                    scope.files = [];
                    scope.showUploadButton = false;
                    //scope.fileList = [];

                    el.bind('change', function (e) {
                        if (!e.target.files.length) return;

                        if (tAttrs.customValidateFunction > '') {
                            var functionCallNoParams = tAttrs.customValidateFunction.substring(0, tAttrs.customValidateFunction.indexOf('('));
                            var functionParams = tAttrs.customValidateFunction.substring(tAttrs.customValidateFunction.indexOf('(') + 1, tAttrs.customValidateFunction.indexOf(')')).replace(/' /g, '').replace(/ '/g, '').replace(/'/g, '').split(',');
                            for (var i = 0; i < functionParams.length; i++) {
                                if (functionParams[i] == '{thisRecord}') {
                                    functionParams[i] = scope.getAdditionalData();
                                }
                                if (functionParams[i] == '{files}') {
                                    functionParams[i] = e.target.files;
                                }
                            }
                            
                            var fn = window[functionCallNoParams];
                            if (typeof fn === "function") {
                                var valid = fn.apply(null, functionParams);
                                if (!valid) {
                                    raiseError(e.target.files, 'CUSTOM', tAttrs.customErrorMessage);
                                    return;
                                }
                            }
                        }
                        //scope.files = [];
                        var tooBig = [];
                        var wrongType = [];
                        if (e.target.files.length > scope.maxFiles) {
                            raiseError(e.target.files, 'TOO_MANY_FILES', "Cannot upload " + e.target.files.length + " files, maxium allowed is " + scope.maxFiles);
                            return;
                        }

                        for (var i = 0; i < scope.maxFiles; i++) {
                            if (i >= e.target.files.length) break;

                            var file = e.target.files[i];
                            file.status = 'selected';

                            if (!scope.acceptFileType) {
                                scope.acceptFileType = '';
                            }

                            var listValidFiles = scope.acceptFileType.replace(' ','').replace('upload','').split(',');
                            var validFileType = false;
                            if (listValidFiles.length > 0 || scope.acceptFileType == '') {
                                for (var i = 0; i < listValidFiles.length; i++) {
                                    if (file.name.endsWith(listValidFiles[i])) {
                                        validFileType = true;
                                    }
                                }
                            } else {
                                validFileType = true;
                            }
                            
                            if (file.size > scope.maxFileSizeMb * 1048576) {
                                tooBig.push(file);
                            }else if (!validFileType){
                                wrongType.push(file);
                            }
                            else {
                                addNewFile(file);
                            }
                        }

                        if (tooBig.length > 0) {
                            raiseError(tooBig, 'MAX_SIZE_EXCEEDED', "Files are larger than the specified max (" + scope.maxFileSizeMb + "MB)");
                            return;
                        }
                        if (wrongType.length > 0) {
                            raiseError(wrongType, 'WRONG_FILE_TYPE', "Files are not the right type (" + scope.acceptFileType + ")");
                            return;
                        }

                        if (scope.autoUpload && scope.autoUpload.toLowerCase() == 'true') {
                            scope.upload();
                        }

                    });

                    scope.upload = function () {
                        var data = null;
                        if (scope.getAdditionalData) {
                            data = scope.getAdditionalData();
                        }
                        var redirectUrl = '';
                        var clientScriptOnSave = '';
                        if (scope.screenPropertySet) {
                            if (scope.screenPropertySet()['redirect']) {
                                redirectUrl = scope.screenPropertySet()['redirect'];
                            }
                            if (scope.screenPropertySet()['clientScriptOnSave']) {
                                clientScriptOnSave = scope.screenPropertySet()['clientScriptOnSave'];
                            }
                        }

                        //get the files to upload, and set the status to 'in process'
                        var theseFiles = getFilesToUpload();

                        if (angular.version.major <= 1 && angular.version.minor < 2) {
                            //older versions of angular's q-service don't have a notify callback
                            //pass the onProgress callback into the service
                            fileUploader
                                .post(theseFiles, data, function (complete) { scope.onProgress({ percentDone: complete }); })
                                .to(scope.uploadUrl)
                                .then(function (ret) {
                                    scope.onDone({ files: ret.files, data: ret.data });
                                }, function (error) {
                                    scope.onError({ files: scope.files, type: 'UPLOAD_ERROR', msg: error });
                                })
                        } else {
                            fileUploader
                                .post(theseFiles, data)
                                .to(scope.uploadUrl)
                                .then(function (ret) {
                                    //forward goes here
                                    if (redirectUrl > '') {
                                        window.location = redirectUrl;
                                    } else if (clientScriptOnSave > '') {
                                        //Remember, using eval is like making a deal with the devil
                                        //cue crazy code to protect us from the evils of eval
                                        var functionCallNoParams = clientScriptOnSave.substring(0, clientScriptOnSave.indexOf('('));
                                        var functionParams = clientScriptOnSave.substring(clientScriptOnSave.indexOf('(') + 1, clientScriptOnSave.indexOf(')')).replace(/' /g, '').replace(/ '/g, '').replace(/'/g, '').split(',');
                                        var fn = window[functionCallNoParams];
                                        if (typeof fn === "function") {
                                            var valid = fn.apply(null, functionParams);
                                        }
                                    }
                                    updateFileStatus(ret.files, 'complete');
                                    scope.onDone({ files: ret.files, data: ret.data });
                                }, function (error) {
                                    scope.onError({ files: scope.files, type: 'UPLOAD_ERROR', msg: error });
                                }, function (ret) {
                                    updateFileStatus(ret.files, ret.percentCompleted + '%');
                                    scope.onProgress({ percentDone: ret.percentCompleted });
                                });
                        }

                    };

                    function raiseError(files, type, msg) {
                        //PRC: I put this alert in because scope.onError does nothing and I'm just looking for a fast feedback
                        alert(msg);
                        scope.onError({ files: files, type: type, msg: msg });
                    };

                    function addNewFile(file) {
                        scope.files.push(file);
                        scope.onFileAdded({ file: file });
                        scope.$apply();
                    };

                    function getFilesToUpload() {

                        var theseFiles = [];

                        angular.forEach(scope.files, function (val, key) {
                            if (val.status == 'selected') {
                                val.status = 'uploading';
                                theseFiles.push(val);
                            }
                        });

                        return theseFiles;
                        scope.$apply();
                    };

                    function updateFileStatus(theseFiles, statusValue) {
                        angular.forEach(scope.files, function (val, key) {
                            if ($.inArray(val, theseFiles) >= 0) {
                                val.status = statusValue;
                            }
                        });
                        
                        scope.$apply();
                    };

                }
            }
        }
    }]);

})();
