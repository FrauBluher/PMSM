call "%VS100COMNTOOLS%..\..\VC\vcvarsall.bat" AMD64

cd .
nmake -f PMSM_Sinusoidal_Drive.mk  GENERATE_REPORT=0 GENERATE_ASAP2=0
@if errorlevel 1 goto error_exit
exit /B 0

:error_exit
echo The make command returned an error of %errorlevel%
An_error_occurred_during_the_call_to_make
