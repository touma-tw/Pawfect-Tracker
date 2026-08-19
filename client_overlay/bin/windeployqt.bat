@echo off
REM Deploy Qt next to the exe (flat layout). Do NOT reintroduce --dir/--plugindir:
REM installer.nsi packages the plugin/QML folders by name from bin\win64, and
REM qt.conf declares Prefix/Plugins/Qml2Imports = "." to match this layout.
cd win64

windeployqt.exe --release --qmldir res/qml OpenVR-InputEmulatorOverlay.exe

REM Sanity check - without this file the overlay dies at startup with
REM "no Qt platform plugin could be initialized".
if not exist platforms\qwindows.dll (
	echo.
	echo *** ERROR: platforms\qwindows.dll missing - deployment failed ***
	exit /b 1
)

@REM Debug:
@REM windeployqt.exe --debug --compiler-runtime --qmldir res/qml OpenVR-InputEmulatorOverlay.exe
