# kmlupdater
This repo contains a Perl script to make kml index file from a set of kml/kmz files located in a hierarchical  disk file structure. The generated kml file will have the same hierarchial folders with separte kml network links to the individual files. 

The createKML.pl perl script takes one argument which is the path to the folder with the kml/kmz files. The standard output is the generated kml file which can be piped to an output file

It can be useful to create a updateKML.bat file in windows with content

SET KMLUPDATER_DIR="C:\APPL\KMLUPDATER"
perl "%KMLUPDATER_DIR%\createKML.pl" %1 > %1.kml
pause

where you need to set the folder/directory where the createKML.pl script is located. 
Drag-dropping a folder to the updateKML.bat file will then run the script and create a file
parallell to the folder with same name as folder but extension kml. 
