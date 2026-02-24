#define MyAppName "LocalX"
#define MyAppPublisher "MCODERs"
#define MyAppURL "https://github.com/mcodersir/LocalX"

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

#ifndef SourceDir
  #define SourceDir "."
#endif

#ifndef OutputDir
  #define OutputDir "."
#endif

[Setup]
AppId={{B9A4F15D-5B45-47A8-8B29-5CCFD9EB72A2}
AppName={#MyAppName}
AppVersion={#AppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=LICENSE
OutputDir={#OutputDir}
OutputBaseFilename=LocalX-windows-x64-installer
SetupIconFile=assets\icons\localx.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\localx.exe
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\LocalX"; Filename: "{app}\localx.exe"
Name: "{autodesktop}\LocalX"; Filename: "{app}\localx.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\localx.exe"; Description: "Launch LocalX"; Flags: nowait postinstall skipifsilent
