# $Id: threema2html.awk,v 1.9 2019/04/21 10:24:55 kramski Exp kramski $
# Convert Threema export to nicely formatted HTML
# 1. Export a chat in Threema (including media files)
# 2. Unpack .zip into the folder where this .awk script lives
# 3. Move all media files into "./media" folder
# 4. "gawk -f $thisscript.awk messages-$chatname.txt > $htmlfile.html"
# 5. Adjust ./lib/default.css

@include "getopt.awk"

#------------------------------------------------------------------------------
function usage()
#------------------------------------------------------------------------------
{
    print "Usage: gawk -f threema2html.awk [-- options] inputfile [> outputfile]"
    print "options:"
    print "\t-f date   \t Start of date range to include (default: 19700101)" 
    print "\t-t date   \t End of date range to include (default: 20701231)" 
    print "\t-n name   \t Name of exporter to be substituted for user \"Ich\" (default: none)"
    print "\t-w width  \t Image width (default: 480)"
    print "\t-m folder \t Media folder (default: \"./media\")"
    print "\t-v        \t Verbose"
    print "\t-h        \t Help"
    print "\tinputfile \t Exported Threema messages (.txt)"
    print "\toutputfile\t Output file (.html)"
}

#------------------------------------------------------------------------------
BEGIN {
#------------------------------------------------------------------------------
    
    # Defaults
    DateFrom = 19700101
    DateTo   = 20701231
    ExporterName = ""
    MediaFolder = "./media/"
    ThumbWidth = 480
    
    # internal variables
    Verbose = 0
    OldDate = ""
    PendingMsg = 0
    ONR = 0
    
    # process options
    while ((C = getopt(ARGC, ARGV, "f:t:n:w:m:vh")) != -1) 
    {
        if (C == "h") 
        {
            usage()
            exit
        }
        if (C == "v") 
            Verbose = 1
        if (C == "f") 
            DateFrom = Optarg * 1
        if (C == "t") 
            DateTo = Optarg * 1
        if (C == "n") 
            ExporterName = Optarg        
        if (C == "m") 
            MediaFolder = Optarg
        if (C == "w") 
            ThumbWidth = Optarg * 1
    }
     
    # clear arguments, so that awk does not try to process the command-line options as file names 
    # (https://www.gnu.org/software/gawk/manual/html_node/Getopt-Function.html).
    for (I = 1; I <= Optind; I++)
    {
        if (substr(ARGV[I], 1, 1) == "-")
            ARGV[I] = ""
    }
    
    # check options
    if (DateFrom < 19700101 || DateFrom > 20701231)
    {
        print "Invalid -f date: " DateFrom
        usage()
        exit
    }
    
    if (DateTo < 19700101 || DateTo > 20701231)
    {
        print "Invalid -t date: " DateTo
        usage()
        exit
    }
    
    if (ThumbWidth < 16 || ThumbWidth > 3200)
    {
        print "Invalid -w width: " ThumbWidth
        usage()
        exit
    }

    if (Verbose)
    {
        print "This is $Id: threema2html.awk,v 1.9 2019/04/21 10:24:55 kramski Exp kramski $." > "/dev/stderr"
        print "Parameters in effect:"           > "/dev/stderr"
        print "\tDateFrom     = " DateFrom      > "/dev/stderr"
        print "\tDateTo       = " DateTo        > "/dev/stderr"
        print "\tExporterName = " ExporterName  > "/dev/stderr"
        print "\tMediaFolder  = " MediaFolder   > "/dev/stderr"
        print "\tThumbWidth   = " ThumbWidth    > "/dev/stderr"
        print "\tVerbose      = " Verbose       > "/dev/stderr"
    }
    
    # print file header
    print "<html>"
    print "<head>"
    print "\t<meta name=\"generator\" content=\"$Id: threema2html.awk,v 1.9 2019/04/21 10:24:55 kramski Exp kramski $\">"
    print "\t<title>Threema Export</title>"
    print "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"./lib/default.css\">"
    print "</head>"
    print "<body>"
    
}

#------------------------------------------------------------------------------
/^\[/ {   # 'normal' input line starting with "[$timestamp]"
#------------------------------------------------------------------------------

    # close previous message 
    if (PendingMsg)
    {
        print "\t\t\t</p>"
        print "\t\t\t<p class=\"timestamp\">"     
        print "\t\t\t\t" DateTime
        print "\t\t\t</p>"
        print "\t\t</div>"
    }
    
    # process current line
    split($0, A, /^\[[0-9\., :]+\] /)
    Msg = A[2]
    
    # process timestamp
    DateTime = substr($0, 2, length($0) - length(Msg) - 3)
    
    split(DateTime, A, /[, ]/)
    Date = A[1]
    Time = A[2]

    split(Date, A, ".")
    Date2 = sprintf("%04d%02d%02d", A[3], A[2], A[1]) * 1 # yyyymmdd 
    
    if (Date2 < 19700101 || Date2 > 20701231)
    {
        print "Invalid Timestamp: " DateTime ", Record " FNR " ignored." > "/dev/stderr"
        PendingMsg = 0
        next
    }
    
    if (Date2 < DateFrom || Date2 > DateTo)
    {
        if (Verbose)
            print "Timestamp out of range: " DateTime ", Record " FNR " ignored." > "/dev/stderr"
        PendingMsg = 0
        next
    }

    if (Date != OldDate)
    {
        # close previous date group
        if (PendingMsg)
        {
            print "\t</div>"
        }
        
        # start new date group
        print "\t<div class=\"date\">"
        print "\t\t<h2>" Date "</h2>"
        OldDate = Date
    }
    
    # process user
    N = split(Msg, A, ":")
    if (N > 1)
    {
        User = A[1]
        Msg = substr(Msg, length(User) + 3)
    }
    else # there are a few malformed(?) lines starting with "[$timestamp]" but missing a user name
    {
        User = "(Unknown)"
    }

    # start new message
    if (ExporterName && (User == "Ich"))
    {
        User2 = ExporterName
        print "\t\t<div class=\"" User " " User2"\">" # multiple classes are allowed, separated by blanks
    }
    else
    {
        User2 = User
        print "\t\t<div class=\"" User"\">"
    }
    
    print "\t\t\t<h3>" User2 "</h3>"

    # process hyperlinks
    Msg = gensub(/(https?:\/\/[^ ]+)/, "<a href=\"\\1\">\\1</a>", "g", Msg) 

    # process .jpg
    Msg = gensub(/<([0-9a-f\-]+\.jpg)>/, "\n\t\t\t\t<br/><a href=\"" MediaFolder "\\1\"><img src=\"" MediaFolder "\\1\" width=\"" ThumbWidth "\"/></a>", "g", Msg)    
    
    # process .mp4
    Msg = gensub(/<([0-9a-f\-]+\.mp4)>/, "\n\t\t\t\t<a href=\"" MediaFolder "\\1\">\\1</a>", "g", Msg)    
    
    # print Msg
    print "\t\t\t<p class=\"msg\">"
    print "\t\t\t\t" Msg

    ONR++
    PendingMsg = 1
    
}

#------------------------------------------------------------------------------
/^[^\[]/ && PendingMsg {   # continuation line
#------------------------------------------------------------------------------
    
    print "\t\t\t\t</br>" $0 

}

#------------------------------------------------------------------------------
END {
#------------------------------------------------------------------------------
    
    # close everything
    if (PendingMsg)
    {
        print "\t\t\t</p>"
        print "\t\t\t<p class=\"timestamp\">"     
        print "\t\t\t\t" DateTime
        print "\t\t\t</p>"
        print "\t\t</div>"
        print "\t</div>"
        print "</body>"
        print "</html>"
    }
    
    print NR " input records, " ONR " output messages." > "/dev/stderr"

}
