@echo off
mkdir build-cache
cd %~dp0\build-cache

set GIT_REPO="https://github.com/covscript/"

call:git_fetch covscript
call:git_fetch covscript-regex
call:git_fetch covscript-codec
call:git_fetch covscript-process

cd covscript
if "%1%" EQU "release" (
    echo Building for release...
    set CSPKG_CONFIG=".\misc\cspkg_config.json"
    git checkout 3.4.1
) else (
    echo Building for nightly...
    set CSPKG_CONFIG=".\misc\cspkg_nightly_config.json"
    git checkout master
)
cd ..

call:call_bat covscript
set CS_DEV_PATH=%cd%\covscript\csdev
call:call_bat covscript-regex
call:call_bat covscript-codec
call:call_bat covscript-process

cd ..
rd /S /Q .\build
mkdir build
cd build-cache

xcopy /E /Y covscript\build ..\build\
xcopy /E /Y covscript\csdev ..\build\
xcopy /E /Y covscript-regex\build ..\build\
xcopy /E /Y covscript-codec\build ..\build\
xcopy /E /Y covscript-process\build ..\build\

cd ..
.\build\bin\cs -i .\build\imports .\misc\win32_build.csc .\misc\win32_config.json
.\build\bin\cs -i .\build\imports .\misc\cspkg_build.csc %CSPKG_CONFIG%

move /Y .\build\imports\imgui_legacy.cse .\build\imports\imgui.cse
cd build-cache
xcopy /E /Y ecs\build\ ..\build\
cd ..

goto:eof
:call_bat
cd %1%
call csbuild\make.bat
cd ..
goto:eof
:git_fetch
if exist %1% (
    cd %1%
    git fetch
    git pull
    git clean -dfx
    cd ..
) else (
    git clone %GIT_REPO%/%1% --depth=1
)
goto:eof