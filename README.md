threema2html
============

Convert a Threema chat export to nicely formatted HTML

- Export a chat in Threema (including media files, see https://threema.ch/es/faq/chatexport)
- Unpack .zip into the folder where this .awk script lives
- Move all media files into "./media" folder
- "gawk -f threema2html.awk messages-chatname.txt > outputfile.html"
- Adjust ./lib/default.css

This script expects German date formats and the exporter's user name be "Ich".

For languages other than German, you probably will have to adjust some code.

Screenshot
----------

![Demo Screenshot](https://github.com/hkramski/threema2html/blob/master/demo.png "Demo Screenshot")
