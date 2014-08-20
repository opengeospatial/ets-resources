:: Sets up a TEAM-engine instance with test suites listed in a CSV file.
:: Reads a CSV file (first argument) where each record contains two fields:
:: Git repository URL, tag name
:: Example:
:: https://github.com/opengeospatial/ets-kml22.git,2.2-r10
::
:: Note: Maven and Git must be installed and available on the system path

@echo off
set home=%~dp0
if exist "%home%setenv.bat" call "%home%setenv.bat"
if "%JAVA_HOME%"=="" echo JAVA_HOME must be set. & goto :eof
if "%ETS_SRC%"=="" echo ETS_SRC must be set. & goto :eof
if [%1]==[] echo Location of CSV file not specified. & goto :eof
set csvfile=%~f1

cd /d %ETS_SRC%
for /F "usebackq tokens=1,2 delims=," %%a in ("%csvfile%") do (
  if exist %%~na (
    cd /d %%~na
    git fetch --tags
  )
  if not exist %%~na (
    git clone %%a
    cd /d %%~na
  )
  call :buildtag "%%b"
  cd /d ..
)

cd /d %TE_BASE%\scripts\
for %%f in (*.zip) do ("%JAVA_HOME%"\bin\jar xf %%f & del %%f)

cd /d %home%
robocopy ..\..\lib %TE_BASE%\resources\lib *.jar /mir
if exist "%TE_BASE%\config.xml" rename "%TE_BASE%\config.xml" "config-PREV.xml"
copy ..\..\config.xml %TE_BASE%\

goto :eof

:buildtag
call git checkout %1
call mvn -DskipTests clean install
copy /y target\*-ctl.zip %TE_BASE%\scripts\
exit /b