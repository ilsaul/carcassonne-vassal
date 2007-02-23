REM Kill the current build directory
del /Q C:\cv\carcassonne\build\images\*.*
del /Q C:\cv\carcassonne\build\images
del /Q C:\cv\carcassonne\build\*.*
REM Extract the data from the binary module
c:\progra~1\winrar\winrar.exe x carcassonne.mod build
