REM Kill the current build directory
del /Q c:\vassalmods\hg\build\images\*.*
del /Q c:\vassalmods\hg\build\images
del /Q c:\vassalmods\hg\build\*.*
REM Extract the data from the binary module
c:\progra~1\winrar\winrar.exe x carcassonne-hg.mod build
