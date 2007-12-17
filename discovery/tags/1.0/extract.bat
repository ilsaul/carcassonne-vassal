REM Kill the current build directory
del /Q c:\vassalmods\disc\build\images\*.*
del /Q c:\vassalmods\disc\build\images
del /Q c:\vassalmods\disc\build\*.*
REM Extract the data from the binary module
c:\progra~1\winrar\winrar.exe x carcassonne-disc.mod build
