/*******************************************************************************
Solution-specific JavaScript goes in this file.
*******************************************************************************/

/*******************************************************************************
documentOnReadyCustom() - This function is called when the document is ready to
                          be processed by JavaScript.
*******************************************************************************/
var websiteColor = 'green';
var websiteSecondaryColor = 'green';
/*
https://www.google.com/design/spec/style/color.html#color-color-palette
Options:
    red
    pink
    purple
    deep-purple
    indigo
    blue
    light-blue
    cyan
    teal
    green
    light-green
    lime
    yellow
    amber
    orange
    deep-orange
    brown
    grey
    blue-grey
*/
function test() {
    alert('hey');
    return true;
}
function addFieldReference(fieldReference, record) {
    record.alertBody = record.alertBody + '{{' + fieldReference.FieldName + '}}';
    return true;
}

function updateReportType(screenPropertySet, listItem) {
    screenPropertySet.reportFormat = listItem.value;
    return true;
}

function RedirectToNewDate(thisRecord) {
    if (thisRecord.LayerHouseID !== 0 && thisRecord.LayerHouseID !== undefined && thisRecord.WeekEndingDate !== '') {
        window.location = "runProcess.aspx?screenID=LayerHouseWeek&p=" + thisRecord.LayerHouseID + "&p=" + thisRecord.WeekEndingDate;
    }
    return true;
}


function switchTrueFalse(thisRecord, fieldName, scope) {
    
    if (thisRecord[fieldName].toString() === '0') {
        thisRecord[fieldName] = '1';
    } else {
        thisRecord[fieldName] = '0';
    }
    
    return true;
}

function PulletGrowerLookup(thisRecord,listItem){
    thisRecord.Capacity = listItem.Capacity;
}

function Calculator_ProductBreed(thisRecord, listItem) {
    thisRecord.NumberOfWeeks = listItem.NumberOfWeeks;
    thisRecord.WeeksHatchToHouse = listItem.WeeksHatchToHouse;
    Calculator_Recalculate(thisRecord);
    return true;
}

function Calculator_Recalculate(thisRecord) {
    var dateArray = thisRecord.HatchDate_First.split('/');
    var hatchDate = new Date(dateArray[2], parseInt(dateArray[0]) - 1, dateArray[1]);
    var calcDate = new Date(hatchDate);
    var weeks = parseFloat(thisRecord.NumberOfWeeks) * 7;
    var hatchToHouse = parseFloat(thisRecord.WeeksHatchToHouse) * 7;

    //Calc Hatch Date = Current Hatch + weeks - hatch to house
    calcDate.setDate(hatchDate.getDate() + (weeks - hatchToHouse));
    thisRecord.CalculatedHatchDate = (calcDate.getMonth() + 1) + '/' + calcDate.getDate() + '/' + calcDate.getFullYear();

    //Calc House Date = Current Hatch + weeks
    calcDate = new Date(hatchDate);
    calcDate.setDate(hatchDate.getDate() + weeks);
    thisRecord.CalculatedHouseDate = (calcDate.getMonth() + 1) + '/' + calcDate.getDate() + '/' + calcDate.getFullYear();

    //Calc Out Date = Calc Hatch + weeks aka Current Hatch + 2Weeks - Hatch to House
    calcDate = new Date(hatchDate);
    calcDate.setDate(hatchDate.getDate() + (weeks + weeks - hatchToHouse));
    thisRecord.CalculatedOutDate = (calcDate.getMonth() + 1) + '/' + calcDate.getDate() + '/' + calcDate.getFullYear();
    return true;
}

function previousHousingInfo(thisRecord, detailRecords) {
    var previousHousingDate = '1/1/1990';
    var previousHatchDate = '1/1/1990';
    var previousOutDate = '1/1/1990';
    for (i = 0; i < detailRecords[0].HousingDates_Get.length; i++)
    {
        var currentRecord = detailRecords[0].HousingDates_Get[i];
        if (thisRecord.LayerHouseID === currentRecord.LayerHouseID) {
            if (dateGreaterThan(currentRecord.HousingDate_Average, previousHousingDate) && dateGreaterThan(thisRecord.HousingDate_Average, currentRecord.HousingDate_Average)) {
                previousHousingDate = currentRecord.HousingDate_Average;
                previousHatchDate = currentRecord.HatchDate_First;
                previousOutDate = currentRecord.HousingOutDate;
            }
        }
    }
    if (previousHatchDate !== '1/1/1900') {
        thisRecord.OldFowlHatchDate = previousHatchDate;
    }
    if (previousOutDate !== '1/1/1900') {
        thisRecord.OldOutDate = previousOutDate;
    }
    return true;
}

function dateGreaterThan(date1, date2) {
    var date1_array = date1.split("/");
    var date1_date = new Date(date1_array[2], parseInt(date1_array[0]) - 1, date1_array[1]);
    var date2_array = date2.split("/");
    var date2_date = new Date(date2_array[2], parseInt(date2_array[0]) - 1, date2_array[1]);
    return date1_date > date2_date;
}

function toggleLocation(parentData, LocationID) {
    //The following logic will check if any of the cards are collapsed. If so, it will expand all cards.
    //If all cards are expanded, it will collapse them all.
    var houseRecords = $.grep(parentData.detailRecords[0].HouseInformation_Detail, function (h) { return h.LocationID === LocationID });
    
    var containsFalse = 0
    for (i = 0; i < houseRecords.length; i++) {
        if (houseRecords[i].ShowRecord === 0) {
            containsFalse = 1;
        }
    }
    for (i = 0; i<houseRecords.length; i++){
            if (containsFalse) {
                houseRecords[i].ShowRecord = containsFalse;
            } else {
                houseRecords[i].ShowRecord = containsFalse;
            }
    }


    return true;
}

function attachmentTypeChange(listItem, thisRecord) {
    if (thisRecord.AttachmentID === 0) {
        thisRecord.AttachmentType = listItem.display;
        var AttachmentTypeFolder = thisRecord.AttachmentType;
        if (AttachmentTypeFolder !== '') {
            AttachmentTypeFolder = AttachmentTypeFolder + '\\';
        }
        thisRecord.Folder = thisRecord.DefaultFolder.trim() + AttachmentTypeFolder;
        thisRecord.Path = thisRecord.Folder.trim() + thisRecord.FileName.trim();
        thisRecord.Location = thisRecord.Path.replace(thisRecord.BaseAttachmentDirectory, '');
    }
    return true;
}

function validateFile(thisRecord, files) {
    thisRecord.FileName = files[0].name;
    thisRecord.Path = thisRecord.Folder.trim() + thisRecord.FileName.trim();
    thisRecord.DisplayName = thisRecord.FileName;
    thisRecord.Location = thisRecord.Path.replace(thisRecord.BaseAttachmentDirectory, '');
    return true;
}

function FileNameChange(thisRecord) {
    thisRecord.Path = thisRecord.Folder.trim() + thisRecord.FileName.trim();
    thisRecord.Location = thisRecord.Path.replace(thisRecord.BaseAttachmentDirectory, '');
    thisRecord.DisplayName = thisRecord.FileName;
    return true;
}

function selectFile(thisRecord, node) {
    if (node.isFolder === 'True' && thisRecord.fileType==='1') {
        thisRecord.Folder = node.saveValue.trim()
        thisRecord.Path = thisRecord.Folder.trim() + thisRecord.FileName.trim();
        thisRecord.Location = thisRecord.Path.replace(thisRecord.BaseAttachmentDirectory, '');
    } else if(node.isFolder === 'False' && thisRecord.fileType==='2') {
        thisRecord.Folder = node.saveValue.substring(0, node.saveValue.lastIndexOf('\\')+1);
        thisRecord.FileName = node.saveValue.substring(node.saveValue.lastIndexOf('\\')+1, node.saveValue.length);
        thisRecord.Path = node.saveValue.trim()
        thisRecord.Location = thisRecord.Path.replace(thisRecord.BaseAttachmentDirectory, '');
        thisRecord.DisplayName = thisRecord.FileName;
    } else {
        node.selected = void 0;
    }
}

function fileTypeChange(thisRecord, scope) {
    if (thisRecord.AttachmentID > 0) {
        return true;
    }
    var returnValue = false;
    if (thisRecord.fileType === '1') {
        thisRecord.foldersOnly = '1';
        thisRecord.TreeLabel = 'Override Default Location';
        returnValue = false;
    }
    if (thisRecord.fileType === '2') {
        thisRecord.foldersOnly = '0';
        thisRecord.TreeLabel = 'Select File';
        returnValue = true;
    }
    if (typeof scope.currentNode !== 'undefined') {
        scope.currentNode.selected = void 0;
    }
    var AttachmentTypeFolder = thisRecord.AttachmentType;
    if (AttachmentTypeFolder !== '') {
        AttachmentTypeFolder = AttachmentTypeFolder + '\\';
    }
    thisRecord.Folder = thisRecord.DefaultFolder.trim() + AttachmentTypeFolder;
    thisRecord.FileName = '';
    thisRecord.Path = thisRecord.DefaultFolder.trim() + AttachmentTypeFolder;
    thisRecord.Location = thisRecord.Path.replace(thisRecord.BaseAttachmentDirectory, '');
    thisRecord.DisplayName = '';
    return returnValue;
}

function formLoadReady(screenID, form) {
    if (screenID === 'Flock') {
        $('div[layout="row"]').css('border-style', 'solid');
        $('div[layout="row"]').css('border-width', '1px');
    }
}

function listLoadReady(screenID) {
    switch (screenID) {
        case "HomePage_FlockList":
            setFixedTop('table');
            break;
    }
}

function menuReady() {
    
}


function documentOnReadyCustom(screenID, form) {
    
    //initializeResizeListener();
    
    if ($("link[href='css/lsNoHeaderNoMenu.css']").length) {
        $('#mainContentContainer').removeClass('col-sm-10').removeClass('col-sm-offset-2');
    }
    
    //$('#menuBar').prepend('<ul id="favorite" class = "nav navbar-nav sm sm-simple favorite"><a href="javascript:void(0)" onclick="addToFavorites();"><img src="images/BookmarkAdd.png" style="width:15px;"/></a></ul>');

    switch (screenID) {
        case "ChecklistTemplate_List":
        case 'ChecklistTemplate_Detail_List':
        case 'ChecklistTemplate_Detail':
            $('body').addClass("blueBackground");
            break;
	}


}

var waitForFinalEvent = function () { var b = {}; return function (c, d, a) { a || (a = "I am a banana!"); b[a] && clearTimeout(b[a]); b[a] = setTimeout(c, d) } }();
function initializeResizeListener() {
    //$(window).resize(function () {
    //    //waitForFinalEvent(moveLeftNav, 100, new Date().getTime());
    //    respaceLeftNav();
    //});
}



function addToFavorites() {
    // Mozilla Firefox Bookmark
    if ('sidebar' in window && 'addPanel' in window.sidebar) {
        window.sidebar.addPanel(location.href, document.title, "");
    } else if (window.external && ('AddFavorite' in window.external)) { // IE Favorite
        window.external.AddFavorite(location.href, document.title);
    } else if ( /*@cc_on!@*/false) { // IE Favorite old
        window.external.AddFavorite(location.href, document.title);
    } else { // webkit - safari/chrome
        alert('Press ' + (navigator.userAgent.toLowerCase().indexOf('mac') !== -1 ? 'Command/Cmd' : 'CTRL') + ' + D to bookmark this page.');
    }
}


function openPDFscreen(screenID)
{
    switch (screenID) {
        case 'ContactSheet':
            window.open('solution/ContactSheet.pdf');
            break;
        case 'KreiderBrochure':
            window.open('solution/KreiderBrochure.pdf');
            break;
        case 'DairyProductList':
            window.open('solution/DairyProductList.pdf')
            break;
        case 'EggProductList':
            window.open('solution/EggProductList.pdf')
            break;
    };
}

function roundToDecimal(value, decimal) {
    return Math.round(value * Math.pow(10, decimal)) / Math.pow(10, decimal);
}

/*******************************************************************************
autoCompleteOnSelectCustom() - This function is called when an option is
                               selected in a JQuery auto-complete control.
*******************************************************************************/

function autoCompleteOnSelectCustom(screenID, fieldName, inputControl, event, ui) {
}

function passwordValidationCustom() {
    //return an array of four values containing password requirements
    //requirements = [# capital, # lowercase, #special, # numbers, #total min length]
    var requirements = [0, 0, 1, 1, 8];
    return requirements;
}

/*******************************************************************************
It is recommended that you put your custom JavaScript below here and organize
it by screen.
*******************************************************************************/

function setFixedTop(grid) {
    var $rt = $(grid + " thead");
    var $clone = $rt.clone();
    $clone.attr('id', 'clone');

    var TableTop = $rt.offset().top;
    var columnWidth = $(grid + " tbody").find('tr:first').find('td').toArray();

    $(window).scroll(function () {
        if ($(window).scrollTop() + 100 > TableTop && !$rt.hasClass('fixedTop')) {
            $rt.after($clone);
            $rt.addClass("fixedTop");
            $(grid + " thead th").each(function () {
                var columnIndex = $(this).index();
                $(this).width($(columnWidth[columnIndex]).width());
            });
        } else if ($(window).scrollTop() + 100 < TableTop) {
            $rt.removeClass("fixedTop");
            $('[id="clone"]').remove();
        }

    });
}

//Consider moving the following two functions to solution builder
function respaceLeftNav() {
    //// Fix bottom floating element height
    //$('#leftContentContainer').css('min-height', $('.mainContainer').height() - 10);

    //if ($('#leftContentContainer .bottom-link').length) {
    //    if (!$('#left-menu-spacer').length) {
    //        $('#leftContentContainer .bottom-link:first').before('<div id="left-menu-spacer">&nbsp;</div>');
    //    }

    //    var bHeight = 0;
    //    $('#leftContentContainer ul').children().not('#left-menu-spacer').each(function () {
    //        bHeight += $(this).outerHeight(true);
    //    });


    //    $('#left-menu-spacer').height($('#leftContentContainer').innerHeight() - bHeight);
    //    //alert($('#left-menu-spacer').height());
    //}


}

//function moveLeftNav() {
//    if ($('.leftMenu').css('display') == 'none') {
//        if (!$.contains('#cssmenu', '#cssleftmenu>ul')) {
//            //$('#cssleftmenu>ul').removeClass('sm-vertical').removeClass('sm-simple-vertical').addClass('sm-simple');
//            $('#cssleftmenu>ul').children().addClass('originallyLeftMenu');
//            $('#cssleftmenu>ul').children().insertAfter('#menu-button');
//            renderSmartMenu('#userMenu');
//        }
//    } else {
//        if (!$.contains('#leftMenu', '#cssleftmenu>ul')) {
//            //alert('put it back');
//            //$('#cssleftmenu>ul').addClass('sm-vertical').addClass('sm-simple-vertical').removeClass('sm-simple');
//            $('.originallyLeftMenu').appendTo('#cssleftmenu>ul');
//            $('.originallyLeftMenu').removeClass('originallyLeftMenu');
//            renderSmartMenu('#userMenu');
            
//        }
//        respaceLeftNav();
//    }
//}

function renderSmartMenu(menuElement) {
    //$(menuElement).smartmenus({
    //    subMenusSubOffsetX: 1,
    //    subMenusSubOffsetY: 0,
    //    subIndicators: false,
    //    subMenusMinWidth: '13em',
    //});
}
function getMenuToRender(screenID) {
    //// Set XMLHTTPRequest Type
    //RequestType = "menu";
    //// If empty, get the menu.
    ////document.body.style.cursor = 'wait';
    //$('#cssMenu').prepend('<p id="navbar-loading-text" class="navbar-text">Menu is loading...</p>');
    //// Save the selected menu option to the hidden field (for postback)
    ////document.forms[0].selectedMenu.value = screenID;
    //$("#selectedMenu").val(screenID);
    //gl_screenID = screenID;
    //// Create the URL to get the menu
    //var sURL = "RenderMenu.aspx?screenID=" + screenID
    //SendRequest(sURL);
}



//THIS MUST STAY AT THE END OF THIS SCRIPT
function fireCSBLink(thisControl) {
    //alert(thisControl.getAttribute("csb-link"));

    //eval(thisControl.getAttribute("csb-link"));
    var functionCall = thisControl.getAttribute("csb-link");
    var functionCallNoParams = functionCall.substring(0, functionCall.indexOf('('));
    var functionParams = functionCall.substring(functionCall.indexOf('(') + 1, functionCall.indexOf(')')).replace(/' /g,'').replace(/ '/g,'').replace(/'/g,'').split(',');
    
    var fn = window[functionCallNoParams];
    if (typeof fn === "function") {
        //alert('found');
        fn.apply(null,functionParams);
    }


}