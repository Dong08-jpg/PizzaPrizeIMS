@echo off
REM Compile and run PIZZA PRIZE (requires JDK 17 or newer)
cd /d "%~dp0"
if exist out rmdir /s /q out
set S=src\com\pizzaprize
javac -encoding UTF-8 -d out %S%\*.java %S%\model\*.java %S%\exception\*.java %S%\repository\*.java %S%\service\*.java %S%\util\*.java %S%\web\*.java
if errorlevel 1 (pause & exit /b 1)
java -cp out com.pizzaprize.Main 8080
pause
