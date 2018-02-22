Load "mysqllib.ring"
Import System.Web
Class Database
################################################
	cServer = "localhost"
	cUserName = "root"
	cPassword = "root"
	cDatabase = "allquran"
################################################

	Func Connect

		con = mysql_init() 
		if not mysql_connect(con, cServer, cUserName, cPassWord,cDatabase)
			raise("Error (DataLib-1) : Can't connect to the database server!")
		ok

	Func Disconnect

		mysql_close(con)

	Func Query cQuery

		mysql_query(con,cQuery)

	Func QueryResult

		return mysql_result(con)

	Func QueryResultWithColumns
		# return columns names + query result
		return mysql_result2(con)

	Func QueryValue
		aResult = mysql_result(con)
		if islist(aResult) and len(aResult) >= 1
			aResult = aResult[1]
			if len(aResult) >= 1
				return aResult[1]
			ok
		ok
		return 0

	Func EscapeString x
		if isstring(x)
			return MySQL_Escape_String(con,x)
		else
			return MySQL_Escape_String(con,string(x))
		ok

	Private
		con = NULL

Class ModelBase from Database
################################################
	cTableName = ""
	cSearchColumn = "name"
	aColumns = []				# columns name	
	aQueryResult = []
	ID = 0
################################################

	# set table name from class name
	classname = lower(classname(self))
	if right(classname,5) = :model
		cTablename = left(classname,len(classname)-5)
	ok

	Func Insert 

		cValues = ""
		for x in aColumns										# values in columns  like sara,ahmed in coulumn{names}
			cValues += "'" + EscapeString(aPageVars[x]) + "',"					# we add to  data entery fron users and add comma for every value  like 'Mahmoud',15000,  
		Next
		cValues = left(cValues,len(cValues)-1)								# remove last comma in the last column value ex in table names 'Mahmoud',15000  so we remove comma		
		cColumns = ""
		for x in aColumns										# separate columns name  in columns by comma ,
			cColumns += x + ","								
		next
		cColumns = left(cColumns,len(cColumns)-1)  							# to remove last comma	in columns names
		query("insert into " + cTableName + "("+cColumns+") values (" + 				# ex insert into  customers (id,name,salary) values (1,'Mahmoud',15000)
				 cValues + ")" )

	Func Update nID

		cStr = ""
		for x in aColumns
			cStr += x + " = '" + EscapeString(aPageVars[x]) + "' , " 				# the space after comma is necessary , to be separated when we enter this value in sql statements
		Next
		cStr = left(cStr,len(cStr)-2)  									# remove comma and space 	
		query("update " + cTableName + " set " + cStr + " where id = " + nID )

	Func UpdateColumn cColumn,cValue
		query("update " + cTableName + " set " + cColumn + " = 
			'" + EscapeString(cValue) + "' where id = " + self.ID )




	Func Count cValue

		query("SELECT count(*) FROM " + cTableName +
				 " where "+cSearchColumn+" like '" + EscapeString(cValue) + "%' ")
		return queryValue()

	Func Read nStart,nRecordsPerPage

		query("SELECT * FROM "+ cTableName+" limit " + EscapeString(nStart) + "," +
		EscapeString(nRecordsPerPage) )
		aQueryResult = queryResult()

	Func Search cValue,nStart,nRecordsPerPage

	     query("SELECT * FROM "+ cTableName+" where "+cSearchColumn+" like '" + EscapeString(cValue) + "%'" +
			" limit " + EscapeString(nStart) + "," + EscapeString(nRecordsPerPage) )
	     aQueryResult = queryResult()									# all values will be values after query search

	Func Find nID

		query("select * from " + cTableName + " where id = " + EscapeString(nID) )
		aResult = queryResult()[1]
		# move the result from the array to the object attributes
		ID = nID
		cCode = ""
		for x = 2 to len(aResult)										
			cCode += aColumns[x-1] + " = hex2str('" + str2hex(aResult[x]) + "')" + nl
		next
		eval(cCode)

	Func FindWith cColumn,cValue

		query("select * from " + cTableName + " where "+cColumn+" = '" + EscapeString(cValue) + "'" )
		aResult = queryResult()
		if len(aResult) > 0
			aResult = aResult[1]	 # values in list
		else
			return 0
		ok
		# move the result from the array to the object attributes
		ID = aResult[1]
		cCode = ""
		for x = 2 to len(aResult)
			cCode += aColumns[x-1] + " = hex2str('" + str2hex(aResult[x]) + "')" + nl	  # to add distances to values then add result to columns names
		next
		eval(cCode)
		return 1

	Func Delete ID

		query("delete from " + cTableName + " where id = " + EscapeString(ID) )

	Func Clear

		cCode = ""
		for x in aColumns
			cCode += x + ' = ""' + nl    							 # eval code strings ---->  x+ ' = "" '	-->x=""
		next
		eval(cCode)

	Func LoadModel

		# create the columns array
		query("SELECT * FROM "+ cTableName + " limit 0,6")
		aQueryResult = QueryResultWithColumns()[1]
		for x = 2 to len(aQueryResult)
			aColumns + lower(trim(aQueryResult[x]))
		next

		# create attribute for each column
		for x in aColumns
			addattribute(self,x)
		next

	Func Connect

		Super.Connect()
		if nLoadModel = 0
			nLoadModel = 1
			query("SET NAMES utf8")
			query('SET CHARACTER SET utf8')
			LoadModel()
		ok

	private

		nLoadModel = 0


Class ControllerBase
################################################	
	nRecordsPerPage = 7
	nRecordsCount = 0
	nPagesCount = 0
	nActivePage = 0
################################################
	# Dynamic creation of oView = new tablenameView and oModel = new tablename.Model
	classname = lower(classname(self))
	if right(classname,10)  = :controller
		tablename = left(classname,len(classname)-10)
		cCode = "oView = new " + tablename+"View" + nl
		cCode += "oModel = new " + tablename+"Model" + nl
		eval(cCode)
		oModel.connect()
	ok
################################################
	cSearchName = "searchname"
	cPart = "part"  # page no
	cPageError = "The page number is not correct"
	cLast = "last"
	cOperation = "operation"
	cRecID = "recid"
	aColumnsNames = ["id"]
################################################
	for t in oModel.aColumns
		aColumnsNames + t
	next

	cMainURL = website + "?"

	func Routing

		switch  	aPageVars[cOperation]
		on NULL 	showtable()
		on :add    	addrecord()
		on :save    	saverecord()
		on :delete	deleterecord()
		on :edit	editrecord()
		on :update	updaterecord()
		on :msg		SearchMessage()
		on :go		searchRecord()

		off

	func ShowTable

		nRecordsCount = oModel.Count( aPageVars[cSearchName] )

		nPagesCount = ceil(nRecordsCount / nRecordsPerPage)

		if aPageVars[cPart] = cLast
			aPageVars[cPart] = string(nPagesCount)
		ok

		nActivePage = number(aPageVars[cPart])
		if nActivePage = 0 nActivePage = 1 ok		

		if ( nActivePage > nPagesCount ) and nRecordsCount > 0 
			ErrorMsg(cPageError)
			return
		ok

		nStart = (nActivePage-1)*nRecordsPerPage

		if aPageVars[cSearchName] = NULL
			oModel.Read( nStart,nRecordsPerPage )
		else
			oModel.Search( aPageVars[cSearchName],nStart,nRecordsPerPage )
		ok

		oView.GridView(self)

	func AddRecord

		oModel.clear()
		oView.FormViewAdd(Self,:save,false) # false mean don't include record id

	func SaveRecord

		oModel.Insert()
		oView.SaveView(self)

	func EditRecord

		oModel.Find( aPageVars[cRecID] )
		oView.FormViewEdit(Self,:update,true) # true mean include record id

	func UpdateRecord
		oModel.update( aPageVars[cRecID] )
		oView.UpdateView(self)

	func DeleteRecord

		oModel.Delete( aPageVars[cRecID] )
		oView.DeleteView()

	func searchRecord
		oModel.clear()
		oView.searchView(Self,:msg)

	func SearchMessage

		oModel.Search( aPageVars[cSearchName],0,200 )
		oView.searchResult(self)


	func braceend

		oModel.Disconnect()

Class ViewBase

	Func HiddenVars	obj
		# No hidden variables

	Func FormViewAdd oController,cOperation,lrecid

		FormView(oController,oLanguage.csearch,cOperation,lrecid)

	Func FormViewEdit oController,cOperation,lrecid

		FormView(oController,oLanguage.cEditRecord,cOperation,lrecid)


# move it to another obj before deleting

	Func DeleteView

		oTranslation = oLanguage
		New Page
		{
			text(oTranslation.cRecordDeleted)
		}

	Func SaveView oController 

		New Page
		{
			script(scriptredirection( oController.cMainURL+
			oController.cPart+"="+oController.cLast ))
		}

	Func UpdateView oController

		New Page 
		{  
			script(scriptredirection( oController.cMainURL+
			oController.cPart+"=" + aPageVars["ActivePage"] )) 
 
		}

	func searchView oController , cOperation

		oTranslation = oLanguage
		oThisView = self

		New Page
		{

			formstart(website)

				oThisView.HiddenVars(self)
				hidden(oController.cPart,1)
				oThisView.HiddenVars(self)	

				hidden(oController.cOperation,cOperation)	
				tablestart([ :style = styletablenoborder() ])
					rowstart([])
						cellstart([ :style = styletablenoborder() + stylewidth("10%") ])
							text(oTranslation.aColumnsTitles[2]+" : ")
						cellend()
						cellstart([ :style = styletablenoborder() + stylewidth("70%") ])
							textbox([ :name = oController.cSearchName , 
							          :value = aPageVars[oController.cSearchName] ,
								  :style = stylewidth("100%") ])
						cellend()
						cellstart([ :style = styletablenoborder() + stylewidth("20%") ])
							submit([ :value = oTranslation.cSearch , 
								:style = stylewidth("100%") ] )
						cellend()
					rowend()
				tableend()
			formend()				
		}

	func searchResult oController

		oTranslation = oLanguage
		oThisView = self

		New Page
		{

				divstart([ :style = StyleTextRight() + StyleFontSize(30) ])
					for x in oController.oModel.aQueryResult						
						nSizeIndex = 0
						for x2=1 to len(x)
							if x2=4    
								nSizeIndex++
								tablestart([:style= StyleTable()+ StyleFixed()])	
									rowstart([ :style =stylewidth("80%")+ Stylebackcolor("#d6e5d4")]) 
										p([ :text = x[x2] ]) 
									rowend()
								tableend() 
							ok
						next
					next
				divend()
	
		}

	func GridView oController

		oTranslation = oLanguage
		oThisView = self

		New Page
		{
			StartHTML()
			Cookie("ActivePage",oController.nActivePage)

			divstart( [ :style = stylesize("100%","4%") + styletextcenter() + stylegradient(55)])
				text( oTranslation.cTitle )
			divend()


			divstart( [ :style = stylesize("100%","100%") + stylegradient(4) ] )
			divstart( [ :style = stylefloatleft() + stylesizefull() + stylemargintop("2%") ] )
				divstart( [ :style = stylesize("50%","50%")  + styleHorizontalCenter() ])		
					style(styletable() + styletablerows("t01"))	
				
					if oController.nRecordsCount > 0	
#####################################################  grid of search result  #####################################################		
					tablestart([:id = :t01 , :style="width:100%"])		
						rowstart([ :style = stylegradient(57) ]) 
							for x in oTranslation.aColumnsTitles headerstart([]) text(x) headerend() next 
						rowend() 

						aSize = [50,50,50,200]
						nID =1

						for x in oController.oModel.aQueryResult
							rowstart([ :id = "gridrow" + nID ])
								nSizeIndex = 0
								for x2=1 to len(x)
									if x2 > 1 and x2 <= len(oController.oModel.aColumns) +1
									    if find(oController.aColumnsNames,oController.oModel.aColumns[x2-1])=0
											loop
									    ok
									ok
									nSizeIndex++

									cellstart([ :style = stylewidth(""+aSize[nSizeIndex]+"px") ]) 
										text(x[x2])  
									cellend() 
								next
							rowend()
						next
					tableend()					
#####################################################  First   Prev   Next   Last#####################################################
					divstart([ :style = stylegradient(5)  ])
						tablestart([ :style = styletablenoborder() + stylewidth("100%") ])
						rowstart([])
						cellstart([ :style = styletablenoborder() + stylewidth("50%") ])
						if oController.nActivePage > 1	# move between pages when there are more than one page
							#first
							link([ :url = oController.cMainURL+oController.cPart+"=1"+
							"&searchname="+aPageVars["searchname"], :title = oTranslation.aMovePages[1] ])
							#prev
							link([ :url = oController.cMainURL+oController.cPart+"="+(oController.nActivePage-1)+
							"&searchname="+aPageVars["searchname"], :title = oTranslation.aMovePages[2] ])
						else
							text(" " + oTranslation.aMovePages[1] + " ")
							text(" " + oTranslation.aMovePages[2] + " ")
						ok
						if oController.nActivePage < oController.nPagesCount
							#next
							link([ :url = oController.cMainURL+oController.cPart+"="+(oController.nActivePage+1)+
								"&searchname="+aPageVars["searchname"], :title = oTranslation.aMovePages[3] ])
							#last
							link([ :url = oController.cMainURL+oController.cPart+"="+oController.cLast+""+
								"&searchname="+aPageVars["searchname"], :title = oTranslation.aMovePages[4] ])

						else 
							text(" " + oTranslation.aMovePages[3] + " ")
							text(" " + oTranslation.aMovePages[4] + " ")
						ok
						cellend()
						cellstart([  :style = styletablenoborder() + oTranslation.cTextAlign ])					
						text(" "+oTranslation.cRecordsCount+" ( " + oController.nRecordsCount + " ) : " +
						     oTranslation.cPage + " " + oController.nActivePage + " "+ oTranslation.cOf +" " + oController.nPagesCount )	
						cellend()
						rowend()
						tableend()
					divend()
##################################################### 		end of  First   Prev   Next   Last 	 #####################################################

					ok
					divstart([ :id = "result" , :style = stylewidth("100%") + styleheight("10%") ])   # msg when clear any record
					divend()
#####################################################	
				
					divstart([ :style = stylewidth("100%") + styleheight("10%") ])				
						button([ :value = oTranslation.csearch, :onclick = "search()" , :style = stylegradient(20)])  
					divend()

					divstart([ :id = "mysubpage" , :style = stylewidth("100%")+stylemargintop("2%")+styleheight("70%")]) 
					divend()					
				divend()
			divend()
			divend()


			Script( oThisView.AddFuncScript(self,oController)) 


		}


