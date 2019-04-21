threema2html
============

Convert a Threema chat export to nicely formatted HTML

1. Export a chat in Threema (including media files, see https://threema.ch/es/faq/chatexport)
2. Unpack .zip into the folder where this .awk script lives
3. Move all media files into "./media" folder
4. "gawk -f threema2html.awk messages-chatname.txt > outputfile.html"
5. Adjust ./lib/default.css

This script expects German date formats and the exporter's user name be "Ich".

For languages other than German, you probably will have to adjust some code.

Screenshot
----------

![Demo Screenshot](https://github.com/hkramski/threema2html/blob/master/demo.png "Demo Screenshot")
