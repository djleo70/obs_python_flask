@echo off
chcp 65001 >nul
title MISE A JOUR
mode con lines=42
echo.

set "APP_DIR=%localappdata%\OBS_module_chat"
set "REPO_DIR=C:\temp\OBS_module_chat"
echo [33;1mDetection des droits administrateur...[0m
:: Vérifier si le script a été relancé avec des droits d'administrateur
if exist "C:\Users\Public\admin_check.tmp" (
del /Q "C:\Users\Public\admin_check.tmp"
goto hasAdminRights
)

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [33mVérifiez la barre des tâches si une application clignote orange, il faut accorder les droits d'admin ![0m
    PowerShell -Command "Start-Process '%~f0' -Verb RunAs; Add-Content -Path 'C:\Users\Public\admin_check.tmp' -Value 'Admin'"
    exit
)

:hasAdminRights
:: Continuez le reste du script ici



pause









:checkPython0
setlocal
:checkPython
python --version >nul 2>&1
if "%ERRORLEVEL%"=="0" (
    echo Python est installé.
) else (
    echo Python n'est pas installé.
    if not exist "C:\Python312" (
        mkdir "C:\Python312"
        echo Dossier C:\temp créé.
    )
    "bitsadmin.exe" /transfer "PythonInstaller" "https://www.python.org/ftp/python/3.12.4/python-3.12.4-amd64.exe" "C:\temp\OBS_module_chat\python-installer.exe"
    echo Lancement de l'installation de Python, patientez...
    "C:\temp\OBS_module_chat\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1 DefaultCustomInstall=1 DefaultPath=%installDir%
    :waitForInstaller
    timeout 5 >nul
    tasklist /FI "IMAGENAME eq python-installer.exe" 2>NUL | find /I "python-installer.exe" >NUL
    if "%ERRORLEVEL%"=="0" (
        goto waitForInstaller
    )
    del /Q "C:\temp\OBS_module_chat\python-installer.exe" /f /q
    timeout 5 >nul
    )
)
endlocal
call "C:\temp\OBS_module_chat\refrenv.bat"
pause





:checkPip0
setlocal
:checkPip
pip --version >nul 2>&1
if "%ERRORLEVEL%"=="0" (
    echo pip est déjà installé.
) else (
    echo pip n'est pas installé.
    :DLpip
    echo Téléchargement de get-pip.py...
    powershell -Command "Invoke-WebRequest -Uri https://bootstrap.pypa.io/get-pip.py -OutFile 'C:\temp\OBS_module_chat\get-pip.py'"
    :: Vérification du téléchargement de get-pip.py
    if not exist "C:\temp\OBS_module_chat\get-pip.py" (
        echo Échec du téléchargement de get-pip.py
        echo Appuyez sur une touche pour réessayer
        pause
        goto DLpip
    )
    :: Exécution de get-pip.py pour installer pip
    echo Installation de pip...
    python "C:\temp\OBS_module_chat\get-pip.py"
    timeout 5 >nul
    )
)
endlocal
call "C:\temp\OBS_module_chat\refrenv.bat"
timeout 2 >nul
setlocal
:: Vérifier et installer/mettre à jour les paquets PIP
echo [33;1mVérification des paquets PIP...[0m
"pip" install --upgrade pip
"pip" install --upgrade selenium obs-websocket-py flask flask-cors flask-socketio pillow
echo.
endlocal







setlocal enabledelayedexpansion
:: Chemin des fichiers source et de destination
set "DEST_DIR=%localappdata%\OBS_module_chat"
set "SCRIPT_NAME=%~nx0"

:: Vérifier et copier les fichiers nécessaires
echo [33;1mVérification des fichiers nécessaires...[0m
echo.
:: Boucle pour chaque fichier .py et .bat dans %~dp0
for %%f in ("C:\temp\OBS_module_chat\*.py" "C:\temp\OBS_module_chat\*.bat" "C:\temp\OBS_module_chat\*.html" "C:\temp\OBS_module_chat\*.ini") do (
    echo Appel de :copy_if_newer "%%f" "%DEST_DIR%\%%~nxf"
    call :copy_if_newer "%%f" "%DEST_DIR%\%%~nxf"
    echo.
)




set "webdriverVersion=126.0.6478.61"
if not exist "C:\WebDrivers" (
    echo [33;1mCréation du répertoire C:\WebDrivers...[0m
    mkdir "C:\WebDrivers"
    echo [32;1mRépertoire C:\WebDrivers créé.[0m
)
REM Naviguer vers le dossier source
cd /d "C:\temp\OBS_module_chat"
REM Télécharger le fichier zip
curl -o chromedriver-win64.zip -L https://storage.googleapis.com/chrome-for-testing-public/%webdriverVersion%/win64/chromedriver-win64.zip --retry 3 --retry-delay 5
REM Vérifier si le téléchargement a réussi
if %errorlevel% neq 0 (
    echo Échec du téléchargement.
    exit /b 1
)
REM Extraire le fichier zip et écraser les fichiers existants
tar -xf chromedriver-win64.zip -C "C:\temp\OBS_module_chat"
REM Déplacer les fichiers extraits vers le répertoire principal
xcopy "C:\temp\OBS_module_chat\chromedriver-win64\*" "C:\WebDrivers" /s /e /y
REM Supprimer le dossier temporaire
rmdir /s /q "C:\temp\OBS_module_chat\chromedriver-win64"

REM Vérifier si l'extraction a réussi
if %errorlevel% neq 0 (
    echo Échec de l'extraction.
    exit /b 1
)
echo Extraction terminée
echo.
echo Appel de :copy_if_newer "C:\temp\OBS_module_chat\LICENSE.chromedriver" "C:\WebDrivers\LICENSE.chromedriver"
call :copy_if_newer "C:\temp\OBS_module_chat\LICENSE.chromedriver" "C:\WebDrivers\LICENSE.chromedriver"
echo.
echo Appel de :copy_if_newer "C:\temp\OBS_module_chat\chromedriver.exe" "C:\WebDrivers\chromedriver.exe"
call :copy_if_newer "C:\temp\OBS_module_chat\chromedriver.exe" "C:\WebDrivers\chromedriver.exe"
echo.
REM Supprimer le fichier zip
del /Q /f /q chromedriver-win64.zip
REM Supprimer les fichiers extraits (ajustez les fichiers et les dossiers à supprimer si nécessaire)
del /Q/ f /q chromedriver.exe
del /Q /f /q LICENSE.chromedriver



echo. & echo. & echo  FIN DE LA MISE A JOUR & timeout 5 >nul
pause
set "SRC_DIR=C:\temp\OBS_module_chat"
for %%i in ("C:\temp\OBS_module_chat") do set "PARENT_DIR=%%~dpi"
echo le dossier cible est traité : C:\temp\OBS_module_chat
pause
start "" cmd /k "C:\temp\OBS_module_chat\OUVRIR CECI.bat"
exit





:copy_if_newer
setlocal enabledelayedexpansion
echo [33;1mVérification de la copie des fichiers...[0m
echo SRC_FILE: %1
echo DEST_FILE: %2
set SRC_FILE=%~1
set DEST_FILE=%~2

if not exist "%DEST_FILE%" (
    echo [31;1mFichier %DEST_FILE% n'existe pas. Copie du fichier...[0m
    copy "%SRC_FILE%" "%DEST_FILE%"
    echo [32;1mFichier copié.[0m
) else (
    echo [33;1mFichier %DEST_FILE% existe. Vérification des dates...[0m
    for %%i in ("%SRC_FILE%") do set "SRC_DATE=%%~ti"
    echo SRC_DATE: !SRC_DATE!
    for %%i in ("%DEST_FILE%") do set "DEST_DATE=%%~ti"
    echo DEST_DATE: !DEST_DATE!
    
    echo [33;1mComparaison des fichiers : source !SRC_DATE!, destination !DEST_DATE![0m
    if !SRC_DATE! GTR !DEST_DATE! (
        echo [31;1mMise à jour du fichier %DEST_FILE%...[0m
        copy /Y "%SRC_FILE%" "%DEST_FILE%"
        echo [32;1mFichier mis à jour.[0m
    ) else (
        echo [32;1mLe fichier %DEST_FILE% est à jour.[0m
    )
)
endlocal & exit /b
