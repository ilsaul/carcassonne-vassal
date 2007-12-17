REM Rebuild the binary module
DEL carcassonne-disc.mod
c:\progra~1\winrar\winrar.exe a -afzip -ep1 -r -xbuild\.svn -xbuild\images\.svn carcassonne-disc.mod build\*
