@echo off
cd /d %USERPROFILE%\Sage
set "CLAUDE_PATH=claude"
if exist "%USERPROFILE%\.local\bin\claude.exe" set "CLAUDE_PATH=%USERPROFILE%\.local\bin\claude.exe"
if exist "%LOCALAPPDATA%\Programs\claude-code\claude.exe" set "CLAUDE_PATH=%LOCALAPPDATA%\Programs\claude-code\claude.exe"
"%CLAUDE_PATH%" %*
