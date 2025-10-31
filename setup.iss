[Setup]
AppName=nginx server
AppVersion=1.0.0
DefaultDirName={autopf}\nginx server
DefaultGroupName=nginx server
OutputBaseFilename=nginx_server
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
WizardStyle=modern
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\nginx\nginx.exe

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Files]
Source: "nginx\*"; DestDir: "{app}\nginx"; Flags: recursesubdirs createallsubdirs
Source: "web\*"; DestDir: "{app}\nginx\html"; Flags: recursesubdirs createallsubdirs
Source: "cmd\*"; DestDir: "{app}\cmd"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\Uninstall nginx server"; Filename: "{uninstallexe}"

[Code]
function ReplaceString(const Source, Find, Replace: String): String;
var
  PosStart: Integer;
  ResultStr: String;
begin
  ResultStr := Source;
  PosStart := Pos(Find, ResultStr);
  while PosStart > 0 do
  begin
    Delete(ResultStr, PosStart, Length(Find));
    Insert(Replace, ResultStr, PosStart);
    PosStart := Pos(Find, ResultStr);
  end;
  Result := ResultStr;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  XMLTemplate: AnsiString;
  AppPath: String;
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    AppPath := ExpandConstant('{app}');
    if LoadStringFromFile(AppPath + '\cmd\nginx-server-service.xml', XMLTemplate) then
    begin
      XMLTemplate := ReplaceString(XMLTemplate, '{app}', AppPath);
      SaveStringToFile(AppPath + '\cmd\nginx-server-service.xml', XMLTemplate, False);
    end
    else
      MsgBox('Error while loading the template nginx-server-service.xml', mbError, MB_OK);
    if not Exec(AppPath + '\cmd\nginx-server-service.exe', 'install', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      MsgBox('Error while installing the nginx server service.', mbError, MB_OK);
    if not Exec(AppPath + '\cmd\nginx-server-service.exe', 'start', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      MsgBox('Error while starting the nginx server service.', mbError, MB_OK);
  end;
end;

[UninstallRun]
Filename: "{app}\cmd\nginx-server-service.exe"; Parameters: "stop"; Flags: runhidden; RunOnceId: "StopService"
Filename: "{app}\cmd\nginx-server-service.exe"; Parameters: "uninstall"; Flags: runhidden; RunOnceId: "UninstallService"
