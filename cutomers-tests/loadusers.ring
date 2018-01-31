#!c:\ring\bin\ring.exe -cgi
Load "weblib.ring"
Load "datalib.ring"
load "users.ring"
Import System.Web
website = "loadusers.ring"
New UsersController { Routing() }

