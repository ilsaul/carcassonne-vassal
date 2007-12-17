REM Rebuild the binary module
DEL carcassonne-hg.mod
c:\progra~1\winrar\winrar.exe a -afzip -ep1 -r -xbuild\.svn -xbuild\images\.svn carcassonne-hg.mod build\*
