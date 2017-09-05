REM Change to SET CONFIGUPDATE=true to update Agent configuration after installation
SET CONFIGUPDATE=false

REM Install the AppDynamics agent on Windows Azure
SETLOCAL EnableExtensions

IF {%INTERNAL_APPDYNAMICS_AGENT_INSTALL_REBOOT%}=={true} (
	SETX INTERNAL_APPDYNAMICS_AGENT_INSTALL_REBOOT ""
	GOTO :END
)

REM Bypass the installation if this is emulated environment
IF {%EMULATED%}=={true} GOTO :END

REM Do nothing if other profiler is installed
IF NOT "%COR_PROFILER%"=="" (IF NOT "%COR_PROFILER%"=="AppDynamics.AgentProfiler" GOTO :END)

REM Uninstall if pre 3.8.0 .NET Agent already installed
SET PRODUCTCODE={0C633F51-09FE-4AE4-A25F-F6CD167CC46E}
SET REGKEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%PRODUCTCODE%
REG QUERY %REGKEY%
IF %ERRORLEVEL%==0 (
	start /wait msiexec /x %PRODUCTCODE% /quiet /log d:\aduninstall.log
	IF NOT %ERRORLEVEL%==0 SHUTDOWN /r /f /c "Reboot after uninstalling the AppDynamics .NET Agent"
)

IF NOT EXIST %~dp0dotNetAgentSetup64.msi GOTO :END

REM See if current agent version is installed
SET REGKEY="HKEY_LOCAL_MACHINE\Software\AppDynamics\dotNet Agent"
SET REGVALNAME=Version
SET REGVALUEVER=""
FOR /F "tokens=2*" %%A IN ('REG QUERY %REGKEY% /v %REGVALNAME%') DO SET REGVALUEVER=%%B

SET INSTALLVER=4.3.0
IF %REGVALUEVER%==%INSTALLVER% GOTO :CHECK_UPDATE_CONFIG

REM Install the agent
start /wait msiexec /i %~dp0dotNetAgentSetup64.msi AD_AGENT_ENVIRONMENT=Azure AD_AZUREROLENAME=%RoleName% AD_AZUREROLEINSTANCEID=%RoleInstanceID% /qn /l*v d:\adInstall.log 
IF %ERRORLEVEL%==0 (
	SETX INTERNAL_APPDYNAMICS_AGENT_INSTALL_REBOOT "true"
	REM Reboot the machine after installation in order to restart role CLR and attach AppDynamics Agent to it
	SHUTDOWN /r /f /c "Reboot after installing the AppDynamics .NET Agent"
)
GOTO :END

:CHECK_UPDATE_CONFIG
REM Checking for force update config flag

IF NOT %CONFIGUPDATE%==true GOTO END

SET REGVALNAME=DotNetAgentFolder
SET DotNetAgentFolder=""
FOR /F "tokens=2*" %%A IN ('REG QUERY %REGKEY% /v %REGVALNAME%') DO SET DotNetAgentFolder=%%B

IF NOT DEFINED DotNetAgentFolder (SET DotNetAgentFolder=%PROGRAMDATA%\AppDynamics\DotNetAgent)
SETX DotNetAgentFolder %DotNetAgentFolder%
COPY /Y "%~dp0\..\App_Data\AppDynamics\Config\config.xml" "%DotNetAgentFolder%\Config\config.xml"

REM Run script to set the azure-role-name and azure-role-instance-id in the config.xml
%SystemRoot%\System32\WindowsPowerShell\v1.0\PowerShell.exe "%~dp0config_update.ps1" "%DotNetAgentFolder%\Config\config.xml" %RoleName% %RoleInstanceID%

IF NOT %ERRORLEVEL%==0 GOTO :END
NET STOP "AppDynamics.Agent.Coordinator"
NET START "AppDynamics.Agent.Coordinator"
GOTO END

:SETERROR
REM SET ERRORLEVEL 1
MD; 2>NUL

:END
EXIT /B %ERRORLEVEL%
