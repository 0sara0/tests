#!ring  -cgi

Load "weblib.ring"
Import System.Web

  New Page
 {
	divstart([:style = Stylecolor("#0000FF")])
		text("Hello in Web Development by Ring Language") 
		h1("Hello in Web Development by Ring Language" )
		h5("Hello in Web Development by Ring Language" )
		p([ :text = "Hello in Web Development by Ring Language" ])
	divend()
 }	


					


