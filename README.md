threema2html
============

Convert a Threema chat export to nicely formatted HTML

https://github.com/hkramski/threema2html

1. For long-running exports, make sure that your smartphone does not go into standby mode during the 
   export process otherwise you may end up with a corrupted .zip file.
2. Export a chat in Threema (including media files), see https://threema.ch/en/faq/chatexport.
3. Unpack the .zip file (without any subfolders) into the folder where this .awk script lives.
4. `gawk -f threema2html.awk messages-chatname.txt > index.html`
   (See `gawk -f threema2html.awk -- -h` for more options.)
5. Copy relevant media files:
    ```
    grep "href=\"./media/" index.html | cut -d= -f2 | cut -d\" -f2 | cut -d/ -f3 > medialist.txt
    xargs --arg-file=medialist.txt cp --target-directory=./media/
    ```
6. Adjust `./lib/default.css`.

This script expects German date formats and the user name "Ich" for the exporter.
For languages other than German, you will probably need to adjust some code.

It has been tested on Android based exports only.

Screenshot
----------

![Demo Screenshot](https://github.com/hkramski/threema2html/blob/master/demo.png "Demo Screenshot")
