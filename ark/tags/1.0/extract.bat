REM Kill the current build directory
del /Q c:\vassalmods\ark\build\images\*.*
del /Q c:\vassalmods\ark\build\images
del /Q c:\vassalmods\ark\build\*.*
REM Extract the data from the binary module
c:\progra~1\winrar\winrar.exe x arkofthecovenant.mod build
