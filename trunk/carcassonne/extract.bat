REM Kill the current build directory
del /Q C:\carcassonne-vassal\carcassonne\build\images\*.*
del /Q C:\carcassonne-vassal\carcassonne\build\images
del /Q C:\carcassonne-vassal\carcassonne\build\*.*
REM Extract the data from the binary module
c:\progra~1\winrar\winrar.exe x carcassonne.mod build
