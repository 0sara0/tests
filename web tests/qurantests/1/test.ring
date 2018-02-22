#!c:\ring\bin\ring.exe -cgi
Load "weblib.ring"
Load "datalib.ring"
Import System.Web

website = "test.ring"

New QuranController {Routing()}


Class QuranModel from ModelBase

		cSearchColumn = "sura" 

Class QuranController From ControllerBase

Class QuranView From ViewBase

  oLanguage = new QuranLanguageEnglish

  Func AddFuncScript oPage,oController
        return   oPage.scriptfuncajax("search",oController.cMainURL+
                 oController.cOperation+"=go","mysubpage")


Class QuranLanguageEnglish
	cTitle = "All Quran "
	cBack = "back"
	aColumnsTitles = [" ID ","Sura No","AYA No ","text"]
	cOptions = "Options"
	cSearch = "Search"
	cEditRecord = "Edit Record"
	cRecordDeleted = "Record Deleted!"
	aMovePages = ["First","Prev","Next","Last"]
	cPage = "Page"
	cOf = "of"
	cRecordsCount = "Records Count"
	cGo = "Go"
	cSave = "save"
	temp = new page
	cTextAlign = temp.StyleTextRight()
	cNoRecords = "No records!"







