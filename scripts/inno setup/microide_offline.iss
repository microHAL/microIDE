#define AppName "microIDE"

#include AddBackslash(SourcePath) + "microide_components.iss"


[Setup]
AppName=microIDE
AppVersion={#AppVersion}
AppCopyright="Copyright (C) 2018 Pawel Okas"
AppPublisher=microhal
AppPublisherURL=www.microhal.org
;AppSupportURL=www.microhal.org
;AppUpdatesURL=www.microhal.org
ArchitecturesAllowed=x64

DefaultDirName={sd}\microIDE
DefaultGroupName=microIDE
DisableStartupPrompt=yes
VersionInfoCompany=microhal
VersionInfoProductName=microIDE
OutputBaseFilename=microIDE_setup_{#AppVersion}_windows_offline
OutputDir=userdocs:Inno Setup microide


[Types]
Name: "user"; Description: "User installation"
Name: "devel"; Description: "Developer installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom


[Components]
Name: "eclipse"; Description: "Eclipse"; Types: user devel custom; Flags: fixed;
Name: "toolchains"; Description: "Toolchains"; Types: user devel custom;
Name: "toolchains\arm"; Description: "gcc-arm-none-eabi {#ARM_GCC_TOOLCHAIN_VERSION}"; Types: user devel custom; Flags: fixed;
Name: "toolchains\clang"; Description: "clang/llvm {#CLANG_TOOLCHAIN_VERSION}"; Types: user devel custom
Name: "toolchains\mingw"; Description: "minGW-w64"; Types: user devel custom
Name: "tools"; Description: "Programming tools"; Types: user devel custom;
Name: "tools\openocd"; Description: "openOCD {#OPENOCD_VERSION}"; Types: user devel custom; Flags: fixed;
Name: "tools\msys"; Description: "msys"; Types: user devel custom; Flags: fixed;
Name: "tools\doxygen"; Description: "Doxygen {#DOXYGEN_VERSION}"; Types: devel custom
Name: "tools\graphviz"; Description: "Graphviz 2.38"; Types: devel custom;
Name: "tools\cppcheck"; Description: "Cppcheck"; Types: devel custom;


[Files]
Source: "downloads\{#CLANG_TOOLCHAIN_FILENAME}"; DestDir: "{tmp}"; Components: toolchains\clang;
Source: "downloads\{#CPPCHECK_FILENAME}"; DestDir: "{tmp}"; Components: tools\cppcheck;
Source: "components\doxygen\*"; DestDir: "{#DOXYGEN_LOCATION}"; Flags: recursesubdirs; Components: tools\doxygen;
Source: "components\eclipse-installer\*"; DestDir: "{app}\eclipse-installer"; Flags: recursesubdirs; BeforeInstall: CreateNoticeFile;
Source: "components\gcc_arm_none_eabi\*"; DestDir: "{#ARM_GCC_TOOLCHAIN_LOCATION}"; Flags: recursesubdirs; Components: toolchains\arm;
Source: "components\graphviz\release\*"; DestDir: "{#GRAPHVIZ_LOCATION}"; Flags: recursesubdirs; Components: tools\graphviz;
Source: "components\mingw\mingw64\*"; DestDir: "{#MINGW_LOCATION}"; Flags: recursesubdirs; Components: toolchains\mingw;
Source: "components\msys\msys\*"; DestDir: "{app}\tools\msys"; Flags: recursesubdirs; Components: tools\msys;
Source: "components\openocd\*"; DestDir: "{#OPENOCD_LOCATION}"; Flags: recursesubdirs; Components: tools\openocd;


[Run]
;---- install clang\llvm
Filename: "{tmp}\{#CLANG_TOOLCHAIN_FILENAME}"; Parameters: "/S /D={#CLANG_TOOLCHAIN_LOCATION}"; Components: toolchains\clang; BeforeInstall: DisplayInstallProgress(True, 'Installing Clang Toolchain.')
;---- install cppcheck
Filename: "msiexec.exe"; Parameters: "/i {tmp}\{#CPPCHECK_FILENAME} /qb /L*V {app}\cppcheck.log INSTALLDIR={#CPPCHECK_LOCATION} ADDLOCAL=""CppcheckCore,Complete,CLI,Translations,GUI,ConfigFiles,PlatformFiles,CRT"""; Components: tools\cppcheck; BeforeInstall: UpdateInstallProgress('Installing Cppcheck.', 50)
;---- eclipse installer
Filename: "notepad.exe"; Parameters: "{tmp}\eclipse-notice.txt"; Components: eclipse; BeforeInstall: UpdateInstallProgress('Preparing eclipse installation.',80); AfterInstall: DisplayInstallProgress(False, '');
Filename: "{app}\eclipse-installer\eclipse-inst.exe"; Components: eclipse; BeforeInstall: PrepareMicroideOomphSetupFiles


[UninstallRun]
Filename: "{#CLANG_TOOLCHAIN_LOCATION}\Uninstall.exe"; Parameters: "/S"


;[UninstallDelete]
;Type: filesandordirs; Name: "{app}\eclipse";
;Type: dirifempty; Name: "{app}\toolchains\LLVM";
;Type: dirifempty; Name: "{app}\toolchains";
;Type: dirifempty; Name: "{app}\tools";


[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{#MINGW_LOCATION}\bin"; Check: NeedsAddPath('{#MINGW_LOCATION}\bin')

;-----------------------------------------------------------------------------------------------------------------------------
[Code]
var
InstallWithProgressPage : TOutputProgressWizardPage;

//Create custom progress bar for install progress
procedure Progress_InitializeWizard;
var
  UpdatedPageString:  AnsiString;
  OriginalPageString: String;
begin
  //The string msgWizardPreparing has the macro '[name]' inside that we have to replace.
  OriginalPageString := SetupMessage(msgPreparingDesc);
  StringChange(OriginalPageString, '[name]', '{#AppName}');
  UpdatedPageString := OriginalPageString;
  InstallWithProgressPage := CreateOutputProgressPage(SetupMessage(msgWizardPreparing), UpdatedPageString);
end;

//Enable or Disable the install progress page (also set initial progress/text)
procedure DisplayInstallProgress(showPage:Boolean; progressText:String);
begin
   if(showPage = True) then
      begin
         InstallWithProgressPage.Show;
         InstallWithProgressPage.SetText(progressText, '');
         InstallWithProgressPage.SetProgress(0,100);
      end
   else
      begin
         InstallWithProgressPage.Hide;
      end
end;

//Update the install progress page
procedure UpdateInstallProgress(progressText:String; progressPercent:Integer);
begin
   InstallWithProgressPage.SetProgress(progressPercent,100);
   InstallWithProgressPage.SetText(progressText, '');
end;

function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', OrigPath) then
  begin
    Result := True;
    exit;
  end;
  // look for the path with leading and trailing semicolon
  // Pos() returns 0 if not found
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;


//-----------------------------
[Code]
// ##################################################################### licence management code
// -------- Global variables ---------
var
  RequireLicenceAccepted: Array[0..6] of Boolean;
  Button: Array[0..6] of TNewButton;
  CheckBox: Array[0..6] of TNewCheckBox;
  URLLabel: Array[0..6] of TNewStaticText;
 //------------------------------------------------------------
 //------------------------------------------------------------ procedures
procedure URLLabelOnClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  case TNewStaticText(Sender).Caption of
    'GCC ARM Embedded': ShellExecAsOriginalUser('open', 'https://launchpad.net/gcc-arm-embedded/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'minGW-w64': ShellExecAsOriginalUser('open', 'http://mingw-w64.org', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'openOCD': ShellExecAsOriginalUser('open', 'http://openocd.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'Doxygen': ShellExecAsOriginalUser('open', 'http://www.doxygen.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'Graphviz': ShellExecAsOriginalUser('open', 'http://www.graphviz.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'Clang': ShellExecAsOriginalUser('open', 'http://clang.llvm.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'Cppcheck': ShellExecAsOriginalUser('open', 'http://cppcheck.sourceforge.net/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
  end;
end;
//----------------------------------------------------

procedure CheckIfAllLicenseAccepted();
var
  i: Integer;
begin
  for i := 0 to 6 do
  begin
    if CheckBox[i].Checked <> RequireLicenceAccepted[i] then
    begin
      WizardForm.NextButton.Enabled := False;
      exit;
    end;
  end;

  WizardForm.NextButton.Enabled := True;
end;
//----------------------------------------------------

procedure onLicenseActeptanceChange(Sender: TObject);
begin
   CheckIfAllLicenseAccepted;
end;
//----------------------------------------------------

procedure showLicsense(Sender: TObject);
var
   ErrorCode: Integer;
begin
   case Sender of
    Button[0]: ShellExecAsOriginalUser('open', '{#ARM_GCC_TOOLCHAIN_LICENSE_URL}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    Button[1]: ShellExecAsOriginalUser('open', 'http://sourceforge.net/projects/mingw-w64/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    Button[2]: ShellExecAsOriginalUser('open', 'http://openocd.org/doc/html/License.html', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    Button[3]: ShellExecAsOriginalUser('open', '{#DOXYGEN_LICENSE_URL}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    Button[4]: ShellExecAsOriginalUser('open', 'http://www.graphviz.org/License.php', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    Button[5]: ShellExecAsOriginalUser('open', 'http://llvm.org/releases/{#CLANG_TOOLCHAIN_VERSION}/LICENSE.TXT', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    Button[6]: ShellExecAsOriginalUser('open', '{#CPPCHECK_LICENSE_URL}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
  end;
end;
//----------------------------------------------------

procedure LicensePageActivate(Sender: TWizardPage);
var
  i: Integer;
  ComponentName: Array[0..6] of String;
begin
  ComponentName[0] := 'toolchains\arm';
  ComponentName[1] := 'toolchains\mingw';
  ComponentName[2] := 'tools\openocd';
  ComponentName[3] := 'tools\doxygen';
  ComponentName[4] := 'tools\graphviz';
  ComponentName[5] := 'toolchains\clang';
  ComponentName[6] := 'tools\cppcheck';

  for i:=0 to 6 do
  begin
    if IsComponentSelected(ComponentName[i]) then
    begin
      RequireLicenceAccepted[i] := True;
      URLLabel[i].Enabled := True;
      Button[i].Enabled := True;
      CheckBox[i].Enabled := True;
    end else
    begin
      RequireLicenceAccepted[i] := False;
      URLLabel[i].Enabled := False;
      Button[i].Enabled := False;
      CheckBox[i].Enabled := False;
    end;
  end;

  CheckIfAllLicenseAccepted;
end;
//----------------------------------------------------
// Shows a new license page
procedure License_InitializeWizard();
var
  Page: TWizardPage;

  WebAddress: Array[0..6] of String;
  i: Integer;
  longestComponnentName: Integer;
begin
  WebAddress[0] := 'GCC ARM Embedded';
  WebAddress[1] := 'minGW-w64';
  WebAddress[2] := 'openOCD';
  WebAddress[3] := 'Doxygen';
  WebAddress[4] := 'Graphviz';
  WebAddress[5] := 'Clang';
  WebAddress[6] := 'Cppcheck';

  longestComponnentName := 0;

  // Create the page
  Page := CreateCustomPage(wpSelectComponents, 'microIDE Components.', 'These components was developed by other teams, please read its license carefully and go to the projects website.');

  // Set the states and event handlers
  Page.OnActivate := @LicensePageActivate;

  for i:=0 to 6 do
  begin
    URLLabel[i] := TNewStaticText.Create(Page);
    URLLabel[i].Caption := WebAddress[i];
    URLLabel[i].Cursor := crHand;
    URLLabel[i].OnClick := @URLLabelOnClick;
    URLLabel[i].Parent := Page.Surface;
    { Alter Font *after* setting Parent so the correct defaults are inherited first }
    URLLabel[i].Font.Style := URLLabel[i].Font.Style + [fsUnderline];
    if GetWindowsVersion >= $040A0000 then   { Windows 98 or later? }
      URLLabel[i].Font.Color := clHotLight
    else
      URLLabel[i].Font.Color := clBlue;
    URLLabel[i].Top := ScaleY(30*i + 5);

    if URLLabel[i].Width > longestComponnentName then longestComponnentName := URLLabel[i].Width;
  end;

  for i:=0 to 6 do
  begin
    Button[i] := TNewButton.Create(Page);
    Button[i].Top := ScaleY(30*i);
    Button[i].Left := longestComponnentName + ScaleY(10);
    Button[i].Width := ScaleX(140);
    Button[i].Height := ScaleY(23);
    Button[i].Caption := 'Show license agreement';
    Button[i].OnClick := @showLicsense; //ShowLicenseEventsFunctions[i];
    Button[i].Parent := Page.Surface;

    CheckBox[i] := TNewCheckBox.Create(Page);
    CheckBox[i].Top := Button[i].Top ;
    CheckBox[i].Left := Button[i].Left + Button[i].Width + ScaleY(10);
    CheckBox[i].Width := Page.SurfaceWidth div 2;
    CheckBox[i].Height := ScaleY(23);
    CheckBox[i].Caption := 'I accept the agreement';
    CheckBox[i].Checked := False;
    CheckBox[i].OnClick := @onLicenseActeptanceChange;
    CheckBox[i].Parent := Page.Surface;
  end;
end;
// #####################################################################


procedure InitializeWizard();
begin
    License_InitializeWizard();
    Progress_InitializeWizard();
end;
//----------------------------------------------------

procedure CreateNoticeFile();
begin
  SaveStringToFile(ExpandConstant('{tmp}\eclipse-notice.txt'), 'IMPORTANT NOTICE' + #13#10 + #13#10 +
                                                               'When you close this window, "eclipse installer" will run.' + #13#10 +
                                                               'You have to set installation directory to: ' + ExpandConstant('{app}') + #13#10, False);
end;
//----------------------------------------------------

procedure CreateMicroideProductsSetupFile();
var
    microideProductSetupPatch: String;
begin
  microideProductSetupPatch := ExpandConstant('{app}/eclipse-installer/microideLocalSetups/microide.product.setup');
  StringChangeEx(microideProductSetupPatch, '\', '/', False);
  SaveStringToFile(ExpandConstant('{app}\eclipse-installer\microideLocalSetups\microide.products.setup'),
                                                               '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
                                                               '<setup:ProductCatalog' + #13#10 +
                                                               '    xmi:version="2.0"' + #13#10 +
                                                               '    xmlns:xmi="http://www.omg.org/XMI"' + #13#10 +
                                                               '    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + #13#10 +
                                                               '    xmlns:setup="http://www.eclipse.org/oomph/setup/1.0"' + #13#10 +
                                                               '    xmlns:setup.p2="http://www.eclipse.org/oomph/setup/p2/1.0"' + #13#10 +
                                                               '    name="microide"' + #13#10 +
                                                               '    label="microide Products">' + #13#10 +
                                                               '  <product' + #13#10 +
                                                               '    href="file:/' +  microideProductSetupPatch + '#/"/>' + #13#10 +
                                                               '  <description>Default IDE for microhal project</description>' + #13#10 +
                                                               '</setup:ProductCatalog>',
                                                               False);
end;
//----------------------------------------------------

procedure ReplaceMicroideProductLocationInSetupFile();
var
    data: AnsiString;
    unicodeData: String;
    microideInstalationPatch: String;
begin
  if LoadStringFromFile(ExpandConstant('{app}\eclipse-installer\microideLocalSetups\microide.product.setup'), data) then
  begin
    microideInstalationPatch := ExpandConstant('value="file:/{app}"');
    StringChangeEx(microideInstalationPatch, '\', '/', False);
    unicodeData := String(data)
    StringChangeEx(unicodeData, 'value="${installation.location|uri}"', microideInstalationPatch, False);
    SaveStringToFile(ExpandConstant('{app}\eclipse-installer\microideLocalSetups\microide.product.setup'), AnsiString(unicodeData), False);
  end;
end;
//----------------------------------------------------

procedure PrepareEclipseIniFile();
var
    fileContent: AnsiString;
    productsCatalogLocation: String;
begin
  if LoadStringFromFile(ExpandConstant('{app}\eclipse-installer\eclipse-inst.ini'), fileContent) then
  begin
    productsCatalogLocation := ExpandConstant('-Doomph.redirection.myProductsCatalog=index:/redirectable.products.setup->file:/{app}/eclipse-installer/microideLocalSetups/microide.products.setup');
    StringChangeEx(productsCatalogLocation, '\', '/', False);
    fileContent := fileContent + #13#10 + productsCatalogLocation
    SaveStringToFile(ExpandConstant('{app}\eclipse-installer\eclipse-inst.ini'), fileContent, False);
  end;
end;
//----------------------------------------------------

procedure PrepareMicroideOomphSetupFiles();
begin
    CreateMicroideProductsSetupFile();
    ReplaceMicroideProductLocationInSetupFile();
    PrepareEclipseIniFile();
end;
