#! /usr/bin/perl -w
use strict;

#****************************************************************
# To Do: display a thumbnail link to every image on every page  *
#****************************************************************

####
my $start;
print "<html><head><title>Images In This Directory</title></head>\n";
####
print <<BEGINSCRIPT;
<script type="text/javascript">
var counter = -1;
var showstuff = new Array();
BEGINSCRIPT
####
print "showstuff=[";
####
while (<*\.jp*>) {    #regex scans working directory and captures any filename with extension beginning "JP"
    print "\"$_\",";  #print each file name into the array
    $start = $_;
}
while (<*\.png>) {    #regex scans working directory and captures any filename with extension beginning "JP"
    print "\"$_\",";  #print each file name into the array
    $start = $_;
}
####
print "];\n";
####
print <<STARTHTML;
function next () {
    if (showstuff[counter] != "" && counter < showstuff.length-1) {
          document.graphic.src=showstuff[++counter];
      }
    else {
          counter = -1;
      next();
      }
}
function back () {
    if (showstuff[counter] != "" && counter > 0) {
          document.graphic.src=showstuff[--counter];
      }
    else {
          counter = showstuff.length;
      back();
      }
}
</script><body>
<p style="text-align:center">
<img src="" alt="Click one of the links below to see a different image." name="graphic" width="900"  />
<p  style="text-align:center">
<a href="javascript:back();" style="font-size:10pt;font-weight:bold;"><-- BACK</a>
...
<a href="javascript:next();" style="font-size:10pt;font-weight:bold;">NEXT --></a>
</body></html>


<script>next();</script>

STARTHTML
