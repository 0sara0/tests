#!ring  -cgi

Load "weblib.ring"
Import System.Web

  New Page
 {
	divstart([ :style = StyleSizeFull() + StyleGradient(32) ])
		divstart([ :style = StyleTextCenter() + StyleFontSize(50) +StyleGradient(42) ])
			text("Hello in Web Development by Ring Language") 
		divend()
	divend()
 }	
