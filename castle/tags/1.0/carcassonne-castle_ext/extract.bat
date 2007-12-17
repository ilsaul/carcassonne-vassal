REM Kill the current build directories
del /Q c:\vassalmods\castle\carcassonne-castle_ext\build_carcassonne-castle-rules\images\*.*
del /Q c:\vassalmods\castle\carcassonne-castle_ext\build_carcassonne-castle-rules\images
del /Q c:\vassalmods\castle\carcassonne-castle_ext\build_carcassonne-castle-rules\*.*
REM Extract the data from the binary module extensions
c:\progra~1\winrar\winrar.exe x carcassonne-castle-rules.mdx build_carcassonne-castle-rules
