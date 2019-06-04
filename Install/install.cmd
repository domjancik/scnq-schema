:: install.bat
:: Installs Schema dependencies
:: http://schema.domj.net

@echo off

echo [4mSchema Dependency Installer[0m
echo 2019 domj.net
echo.

:: VL nuget install
echo [33mInstalling VL dependencies[0m
echo [36mChoose your VVVV installation folder[0m
type installDependencies.ps1 | powershell -noprofile -
if errorlevel 1 (
  pause
  exit
)

:: Font install
echo.
echo [33mInstalling Fonts[0m
echo [36mPlease press OK/Yes for all[0m
type installFonts.ps1 | powershell -noprofile -

:: Confirmation
echo.
echo [32mAll should be done[0m
echo Start vvvv.exe and open any of the Schema_X.v4p base patches
pause

