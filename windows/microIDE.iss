#define AppName "microIDE"
#define AppVersion "0.2.2"

#define DOWNLOAD_DIR "{userdocs}\microIDE_installer"
#define UNZIP_7Z_PATH "tools\7z1604-extra"

#define ARM_GCC_TOOLCHAIN_URL "https://launchpad.net/gcc-arm-embedded/5.0/5-2016-q1-update/+download/gcc-arm-none-eabi-5_3-2016q1-20160330-win32.exe"
#define ARM_GCC_TOOLCHAIN_FILENAME "gcc-arm-none-eabi-5_3-2016q1-20160330-win32.exe"
#define ARM_GCC_TOOLCHAIN_VERSION "5.3.0"
#define ARM_GCC_TOOLCHAIN_SIZE 442470400
#define ARM_GCC_TOOLCHAIN_LOCATION "{app}\toolchains\gcc-arm-none-eabi\microhal\gcc-arm-none-eabi-5_3-2016q1"

#define CLANG_TOOLCHAIN_URL "http://llvm.org/releases/3.8.0/LLVM-3.8.0-win64.exe"
#define CLANG_TOOLCHAIN_FILENAME "LLVM-3.8.0-win64.exe"
#define CLANG_TOOLCHAIN_VERSION "3.8.0"
#define CLANG_TOOLCHAIN_SIZE 631264097
#define CLANG_TOOLCHAIN_LOCATION "{app}\toolchains\LLVM\3.8.0"  

#define OPENOCD_URL "http://www.freddiechopin.info/en/download/category/10-openocd-dev?download=140%3Aopenocd-0.10.0-dev-00247-g73b676c"
#define OPENOCD_FILENAME "openocd-0.10.0-dev-00247-g73b676c.7z"
#define OPENOCD_VERSION "0.10.0"
#define OPENOCD_SIZE 2333886
#define OPENOCD_LOCATION "{app}\tools\openocd\0.10.0"


[Setup]
AppName=microIDE
AppVersion={#AppVersion}
AppCopyright="Copyright � 2016 Pawel Okas"
AppPublisher=microHAL
AppPublisherURL=www.microhal.org
;AppSupportURL=www.microhal.org
;AppUpdatesURL=www.microhal.org
ArchitecturesAllowed=x64

DefaultDirName={sd}\microIDE
DefaultGroupName=microIDE
DisableStartupPrompt=yes
VersionInfoCompany=microHAL
VersionInfoProductName=microIDE
OutputBaseFilename=microIDE_setup_{#AppVersion}
OutputDir=userdocs:Inno Setup Examples Output

#include <idp.iss>

[Types]
Name: "user"; Description: "User installation"
Name: "devel"; Description: "Developer installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "eclipse"; Description: "Eclipse"; Types: user devel custom; Flags: fixed; ExtraDiskSpaceRequired: 51720192
;Name: "python"; Description: "Python 2.7.3"; Types: devel custom; ExtraDiskSpaceRequired: 76718080
Name: "toolchains"; Description: "Toolchains"; Types: user devel custom; 
Name: "toolchains\arm"; Description: "gcc-arm-none-eabi {#ARM_GCC_TOOLCHAIN_VERSION}"; Types: user devel custom; ExtraDiskSpaceRequired: {#ARM_GCC_TOOLCHAIN_SIZE}  
Name: "toolchains\clang"; Description: "clang/llvm"; Types: user devel custom; ExtraDiskSpaceRequired: {#CLANG_TOOLCHAIN_SIZE} 
Name: "toolchains\mingw"; Description: "minGW-w64"; Types: user devel custom; ExtraDiskSpaceRequired: 478638080
Name: "tools"; Description: "Programming tools"; Types: user devel custom;
Name: "tools\openocd"; Description: "openOCD {#OPENOCD_VERSION}"; Types: user devel custom; ExtraDiskSpaceRequired: {#OPENOCD_SIZE}
Name: "tools\msys"; Description: "msys"; Types: user devel custom; ExtraDiskSpaceRequired: 416485376
;Name: "tools\cpplint"; Description: "CPPlint"; Types: devel custom;
Name: "tools\doxygen"; Description: "Doxygen 1.8.11"; Types: devel custom; ExtraDiskSpaceRequired: 49614848  
Name: "tools\graphiz"; Description: "Graphiz 2.38"; Types: devel custom; ExtraDiskSpaceRequired: 204574720 

[Files]
Source: "{#UNZIP_7Z_PATH}\*"; DestDir: "{tmp}\tools\7z"; Flags: recursesubdirs
;gcc-arm-none-eabi patch, unpack to tmp directory and after running installer copy files to toolchain directory
;Source: "toolchains\gcc-arm-none-eabi-5_3-patch\*"; DestDir: "{tmp}\toolchains\gcc-arm-none-eabi_patch"; Components: toolchains\arm; Flags: recursesubdirs
;Source: "tools\openocd\openocd-0.9.0.7z"; DestDir: "{tmp}\tools"; Components: tools\openocd;
;Source: "tools\cpplint\*"; DestDir: "{app}\tools\cpplint"; Components: tools\cpplint; Flags: recursesubdirs; AfterInstall: CreateCPPlintRunFile;  
Source: "eclipse-installer\*"; DestDir: "{app}\eclipse-installer"; Flags: recursesubdirs; BeforeInstall: CreateNoticeFile
Source: "launch\*"; DestDir: "{app}"; Flags: recursesubdirs;

;Source: licsenses\GCC-ARM.txt; DestDir: {app}; Flags: ignoreversion dontcopy
;Source: licsenses\openocd.txt; DestDir: {app}; Flags: ignoreversion dontcopy
;Source: licsenses\Graphiz.rtf; DestDir: {app}; Flags: ignoreversion dontcopy
;Source: licsenses\doxygen.txt; DestDir: {app}; Flags: ignoreversion dontcopy
;Source: licsenses\llvm.txt; DestDir: {app}; Flags: ignoreversion dontcopy

[Dirs] 
;Name: "{app}\eclipse"

[Icons]
Name: {commondesktop}\microIDE; Filename: {app}\launch.bat; WorkingDir: {app}; Tasks: desktopicon 
;IconFilename: {app}\MyApplication.ico; Comment: "MyApplication"; Components: MyApplication;

[Tasks]
Name: desktopicon; Description: Create Desktop Icon;

[Run]
;unpack git repozitory files   
Filename: "{tmp}\tools\7z\7za.exe"; Parameters: "x {#DOWNLOAD_DIR}\master.zip -o{tmp}\ -y"; BeforeInstall: DisplayInstallProgress(True, 'Unpacking toolchain patch and eclipse installer setup configuration.');
;toolchains installer
Filename: "{#DOWNLOAD_DIR}\{#ARM_GCC_TOOLCHAIN_FILENAME}"; Parameters: "/S /D={#ARM_GCC_TOOLCHAIN_LOCATION}"; Components: toolchains\arm; BeforeInstall: UpdateInstallProgress('Installing ARM Toolchain.',5)
; install patch for arm toolchain
Filename: "xcopy.exe"; Parameters: "/s /y {tmp}\microIDE-master\toolchains\gcc-arm-none-eabi-patch\{#ARM_GCC_TOOLCHAIN_VERSION} {#ARM_GCC_TOOLCHAIN_LOCATION}\"; Components: toolchains\arm; Flags: runhidden; BeforeInstall: UpdateInstallProgress('Patching ARM Toolchain.',20)                   
; install clang\llvm
Filename: "{#DOWNLOAD_DIR}\{#CLANG_TOOLCHAIN_FILENAME}"; Parameters: "/S /D={#CLANG_TOOLCHAIN_LOCATION}"; Components: toolchains\clang; BeforeInstall: UpdateInstallProgress('Installing Clang Toolchain.',25)
;mingw
Filename: "{tmp}\tools\7z\7za.exe"; Parameters: "x {#DOWNLOAD_DIR}\x86_64-5.3.0-release-posix-seh-rt_v4-rev0.7z -o{app}\toolchains\mingw-w64 -y"; Components: toolchains\mingw; BeforeInstall: UpdateInstallProgress('Installing mingw toolchain.',40) 
Filename: "cmd.exe"; Parameters: "/c rename {app}\toolchains\mingw-w64\mingw64 5.3.0"; Components: toolchains\mingw ; BeforeInstall: UpdateInstallProgress('Installing mingw toolchain.',55)
; tools installer
;Filename: "{#DOWNLOAD_DIR}\{#OPENOCD_FILENAME}"; Parameters: "/S /D={app}\tools\openocd\{#OPENOCD_VERSION}"; Components: tools\openocd; BeforeInstall: UpdateInstallProgress('Installing OpenOCD.',56)
Filename: "{tmp}\tools\7z\7za.exe"; Parameters: "x {#DOWNLOAD_DIR}\{#OPENOCD_FILENAME} -o{#OPENOCD_LOCATION} -y"; Components: tools\openocd; BeforeInstall: UpdateInstallProgress('Installing OpenOCD.',56)
;Filename: "xcopy.exe"; Parameters: "/s /y {tmp}\tools\openocd {#OPENOCD_LOCATION}\"; Components: tools\openocd; BeforeInstall: UpdateInstallProgress('Installing OpenOCD.',60)
; extract msys
Filename: "{tmp}\tools\7z\7za.exe"; Parameters: "x {#DOWNLOAD_DIR}\msys-rev13.7z -o{app}\tools\ -y"; Components: tools\msys; BeforeInstall: UpdateInstallProgress('Installing msys.',62)
; install doxygen  
Filename: "{#DOWNLOAD_DIR}\doxygen-1.8.11-setup.exe"; Parameters: "/SILENT /DIR={app}\tools\doxygen\1.8.11"; Components: tools\doxygen; BeforeInstall: UpdateInstallProgress('Installing doxygen.',75)
; unpack graphiz
Filename: "{tmp}\tools\7z\7za.exe"; Parameters: "x {#DOWNLOAD_DIR}\graphviz-2.38.zip -o{app}\tools\ -y"; Components: tools\graphiz; BeforeInstall: UpdateInstallProgress('Installing graphiz.',85)
Filename: "cmd.exe"; Parameters: "/c rename {app}\tools\release graphiz"; Components: tools\graphiz; BeforeInstall: UpdateInstallProgress('Installing graphiz.',95)
;python
;Filename: "msiexec"; Parameters: "/i {userdocs}\microIDE_installer\python-2.7.11.msi /qr"; Components: python and tools\openocd
;---- eclipse installer
; copy oomph setup files
Filename: "xcopy.exe"; Parameters: "/s /y {tmp}\microIDE-master\eclipse-installer\setups {app}\eclipse-installer\setups\"; Components: eclipse; Flags: runhidden; BeforeInstall: UpdateInstallProgress('Preparing eclipse instalation.',97)                   
Filename: "notepad.exe"; Parameters: "{tmp}\eclipse-notice.txt"; Components: eclipse; BeforeInstall: UpdateInstallProgress('Preparing eclipse instalation.',99); AfterInstall: DisplayInstallProgress(False, ''); 
Filename: "{app}\eclipse-installer\eclipse-inst.exe"; Components: eclipse 

[UninstallRun]
Filename: "{#CLANG_TOOLCHAIN_LOCATION}\Uninstall.exe"; Parameters: "/S"
Filename: "{#ARM_GCC_TOOLCHAIN_LOCATION}\uninstall.exe"; Parameters: "/S"
Filename: "{app}\tools\doxygen\1.8.11\system\unins000.exe"; Parameters: "/SILENT"                      

[UninstallDelete]
Type: filesandordirs; Name: "{app}\eclipse";
Type: filesandordirs; Name: "{app}\toolchains\mingw-w64"; Components: toolchains\mingw
;Type: filesandordirs; Name: "{app}\tools\cpplint"; Components: tools\cpplint
Type: filesandordirs; Name: "{app}\tools\graphiz"; Components: tools\graphiz
Type: filesandordirs; Name: "{app}\tools\msys"; Components: tools\msys
Type: filesandordirs; Name: "{app}\tools\openocd"; Components: tools\openocd

Type: dirifempty; Name: "{app}\toolchains\gcc-arm-none-eabi";
Type: dirifempty; Name: "{app}\toolchains";
Type: dirifempty; Name: "{app}\tools";



[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\toolchains\mingw-w64\5.3.0\bin"; Check: NeedsAddPath('{app}\toolchains\mingw-w64\5.3.0\bin')

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

//-----------------------------
[Code]       
var   
  LicenceAccepted: Array[0..5] of Boolean; 
  RequireLicenceAccepted: Array[0..5] of Boolean;
  Button: Array[0..5] of TNewButton;
  CheckBox: Array[0..5] of TNewCheckBox;
  URLLabel: Array[0..5] of TNewStaticText;

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

// functions responsible for license acceptance
// this function show license text
procedure ShowLicenseWizard(LicsenseText: AnsiString);
var
  LicensePage: TSetupForm;          
  OKButton: TNewButton;
  RichEditViewer: TRichEditViewer; 
begin  
  LicensePage := CreateCustomForm();
  try
    LicensePage.ClientWidth := WizardForm.Width;
    LicensePage.ClientHeight := WizardForm.Height;
    LicensePage.Caption := 'License';
    LicensePage.CenterInsideControl(WizardForm, False); 
  
    RichEditViewer := TRichEditViewer.Create(LicensePage);
    RichEditViewer.Top := 5;
    RichEditViewer.Left := 5;
    RichEditViewer.Width := LicensePage.ClientWidth - 10;
    RichEditViewer.Height := LicensePage.ClientHeight - 50;
    RichEditViewer.Parent := LicensePage;
    RichEditViewer.ScrollBars := ssVertical;
    RichEditViewer.UseRichEdit := True;
    RichEditViewer.RTFText := LicsenseText;
    RichEditViewer.ReadOnly := True;

    OKButton := TNewButton.Create(LicensePage);
    OKButton.Parent := LicensePage;
    OKButton.Width := ScaleX(75);
    OKButton.Height := ScaleY(23);
    OKButton.Left := LicensePage.ClientWidth - ScaleX(75 + 5);
    OKButton.Top := LicensePage.ClientHeight - ScaleY(23 + 10);
    OKButton.Caption := 'OK';
    OKButton.ModalResult := mrOk;
    OKButton.Default := True;
                                
    LicensePage.ShowModal();      
  finally
    LicensePage.Free();
  end;
end;  

//procedure Show_python_license(Sender: TObject);
//var 
//  ErrorCode: Integer;
//begin
//  ShellExecAsOriginalUser('open', 'http://docs.python.org/3/license.html', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
//end;

procedure Show_GCCARM_license(Sender: TObject);
var
  LicsenseText: AnsiString;
begin
  // Load the licsense text into the new page
  ExtractTemporaryFile('GCC-ARM.txt');
  LoadStringFromFile(ExpandConstant('{tmp}/GCC-ARM.txt'), LicsenseText);

  ShowLicenseWizard(LicsenseText);
end;

procedure Show_mingw_license(Sender: TObject);
var 
  ErrorCode: Integer;
begin 
  ShellExecAsOriginalUser('open', 'http://sourceforge.net/projects/mingw-w64/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure Show_openocd_license(Sender: TObject);
var
  LicsenseText: AnsiString;
begin
  // Load the licsense text into the new page
  ExtractTemporaryFile('openocd.txt');
  LoadStringFromFile(ExpandConstant('{tmp}/openocd.txt'), LicsenseText);

  ShowLicenseWizard(LicsenseText);
end;

procedure Show_doxygen_license(Sender: TObject);
var
  LicsenseText: AnsiString;
begin
  // Load the licsense text into the new page
  ExtractTemporaryFile('doxygen.txt');
  LoadStringFromFile(ExpandConstant('{tmp}/doxygen.txt'), LicsenseText);

  ShowLicenseWizard(LicsenseText);
end;

procedure Show_graphiz_license(Sender: TObject);
var
  LicsenseText: AnsiString;
begin
  // Load the licsense text into the new page
  ExtractTemporaryFile('Graphiz.rtf');
  LoadStringFromFile(ExpandConstant('{tmp}/Graphiz.rtf'), LicsenseText);

  ShowLicenseWizard(LicsenseText);
end;

procedure Show_clang_license(Sender: TObject);
var
  LicsenseText: AnsiString;
begin
  // Load the licsense text into the new page
  ExtractTemporaryFile('llvm.txt');
  LoadStringFromFile(ExpandConstant('{tmp}/llvm.txt'), LicsenseText);

  ShowLicenseWizard(LicsenseText);
end;
//------------------------------------------------------------
procedure URLLabelOnClick(Sender: TObject);
var
  ErrorCode: Integer;
begin      
  case TNewStaticText(Sender).Caption of
    'GCC ARM Embedded': ShellExecAsOriginalUser('open', 'https://launchpad.net/gcc-arm-embedded/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'minGW-w64': ShellExecAsOriginalUser('open', 'http://mingw-w64.org', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'openOCD': ShellExecAsOriginalUser('open', 'http://openocd.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'Doxygen': ShellExecAsOriginalUser('open', 'http://www.doxygen.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'Graphiz': ShellExecAsOriginalUser('open', 'http://www.graphviz.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
//    'Python': ShellExecAsOriginalUser('open', 'http://www.python.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    'clang': ShellExecAsOriginalUser('open', 'http://clang.llvm.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
  end;
end;      

procedure CheckIfAllLicenseAccepted();
var
  i: Integer;  
begin                     
  for i := 0 to 5 do
  begin
    if LicenceAccepted[i] <> RequireLicenceAccepted[i] then 
    begin
      WizardForm.NextButton.Enabled := False;
      exit;
    end;
  end;
  
  WizardForm.NextButton.Enabled := True; 
end;

// on license acceptance changed procedures
procedure PythonLicenseChecked(Sender: TObject);
begin
  LicenceAccepted[5] := TNewCheckBox(Sender).Checked;
  CheckIfAllLicenseAccepted;
end;

procedure AcceptARMLicenseChecked(Sender: TObject);
begin
   LicenceAccepted[0] := TNewCheckBox(Sender).Checked;
   CheckIfAllLicenseAccepted;
end;

procedure MinGWLicenseChecked(Sender: TObject);
begin
   LicenceAccepted[1] := TNewCheckBox(Sender).Checked;
   CheckIfAllLicenseAccepted;
end;

procedure openOCDLicenseChecked(Sender: TObject);
begin
   LicenceAccepted[2] := TNewCheckBox(Sender).Checked;
   CheckIfAllLicenseAccepted;
end;

procedure DoxygenLicenseChecked(Sender: TObject);
begin
   LicenceAccepted[3] := TNewCheckBox(Sender).Checked;
   CheckIfAllLicenseAccepted;
end;  

procedure GraphizLicenseChecked(Sender: TObject);
begin
   LicenceAccepted[4] := TNewCheckBox(Sender).Checked;
   CheckIfAllLicenseAccepted;
end;

procedure ClangLicenseChecked(Sender: TObject);
begin
   LicenceAccepted[5] := TNewCheckBox(Sender).Checked;
   CheckIfAllLicenseAccepted;
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
  ComponentName[4] := 'tools\graphiz';
 // ComponentName[5] := 'python';
  ComponentName[5] := 'toolchains\clang';
  
  for i:=0 to 5 do
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

// Shows a new license page
procedure License_InitializeWizard();
var 
  Page: TWizardPage; 
  
  WebAddress: Array[0..5] of String;
  i: Integer;   
  longestComponnentName: Integer;
  CheckboxEventsFunctions: Array[0..5] of TNotifyEvent;
  ShowLicenseEventsFunctions: Array[0..5] of TNotifyEvent;
begin
  WebAddress[0] := 'GCC ARM Embedded';
  WebAddress[1] := 'minGW-w64';
  WebAddress[2] := 'openOCD';
  WebAddress[3] := 'Doxygen';
  WebAddress[4] := 'Graphiz';
//  WebAddress[5] := 'Python'; 
  WebAddress[5] := 'Clang'; 

  CheckboxEventsFunctions[0] := @AcceptARMLicenseChecked;
  CheckboxEventsFunctions[1] := @MinGWLicenseChecked;
  CheckboxEventsFunctions[2] := @openOCDLicenseChecked;
  CheckboxEventsFunctions[3] := @DoxygenLicenseChecked;
  CheckboxEventsFunctions[4] := @GraphizLicenseChecked;
//  CheckboxEventsFunctions[5] := @PythonLicenseChecked;
  CheckboxEventsFunctions[5] := @ClangLicenseChecked;

  ShowLicenseEventsFunctions[0] := @Show_GCCARM_license;
  ShowLicenseEventsFunctions[1] := @Show_mingw_license;
  ShowLicenseEventsFunctions[2] := @Show_openocd_license;
  ShowLicenseEventsFunctions[3] := @Show_doxygen_license;
  ShowLicenseEventsFunctions[4] := @Show_graphiz_license;
//  ShowLicenseEventsFunctions[5] := @Show_python_license;
  ShowLicenseEventsFunctions[5] := @Show_clang_license

  longestComponnentName := 0;   
    
  // Create the page
  Page := CreateCustomPage(wpSelectComponents, 'microIDE Components.', 'These components was developed by other teams, please read its license carefully and go to the projects website.');

  // Set the states and event handlers
  Page.OnActivate := @LicensePageActivate;

  for i:=0 to 5 do
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
  
  for i:=0 to 5 do
  begin  
    Button[i] := TNewButton.Create(Page);
    Button[i].Top := ScaleY(30*i);
    Button[i].Left := longestComponnentName + ScaleY(10);
    Button[i].Width := ScaleX(140);
    Button[i].Height := ScaleY(23);    
    Button[i].Caption := 'Show license agreement';
    Button[i].OnClick := ShowLicenseEventsFunctions[i];
    Button[i].Parent := Page.Surface;    
  
    CheckBox[i] := TNewCheckBox.Create(Page);
    CheckBox[i].Top := Button[i].Top ;
    CheckBox[i].Left := Button[i].Left + Button[i].Width + ScaleY(10);
    CheckBox[i].Width := Page.SurfaceWidth div 2;
    CheckBox[i].Height := ScaleY(23);
    CheckBox[i].Caption := 'I accept the agreement';
    CheckBox[i].Checked := False;
    CheckBox[i].OnClick := CheckboxEventsFunctions[i];
    CheckBox[i].Parent := Page.Surface;                  
  end;
end;  

procedure InitializeWizard();
begin
  // create directory where downloaded files will be stored
  if not DirExists(ExpandConstant('{#DOWNLOAD_DIR}')) then
    CreateDir(ExpandConstant('{#DOWNLOAD_DIR}'));

  if not FileExists(ExpandConstant('{#DOWNLOAD_DIR}\master.zip')) then
    idpAddFile('https://github.com/microHAL/microIDE/archive/master.zip',  ExpandConstant('{#DOWNLOAD_DIR}\master.zip'));

  if not FileExists(ExpandConstant('{#DOWNLOAD_DIR}\{#ARM_GCC_TOOLCHAIN_FILENAME}')) then
    idpAddFileComp('{#ARM_GCC_TOOLCHAIN_URL}',  ExpandConstant('{#DOWNLOAD_DIR}\{#ARM_GCC_TOOLCHAIN_FILENAME}'),  'toolchains\arm');
 
  if not FileExists(ExpandConstant('{#DOWNLOAD_DIR}\{#CLANG_TOOLCHAIN_FILENAME}')) then                                    
    idpAddFileComp('{#CLANG_TOOLCHAIN_URL}', ExpandConstant('{#DOWNLOAD_DIR}\{#CLANG_TOOLCHAIN_FILENAME}'), 'toolchains\clang');        
  
  if not FileExists(ExpandConstant('{#DOWNLOAD_DIR}\x86_64-5.3.0-release-posix-seh-rt_v4-rev0.7z')) then                                    
    idpAddFileComp('http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/5.3.0/threads-posix/seh/x86_64-5.3.0-release-posix-seh-rt_v4-rev0.7z', ExpandConstant('{#DOWNLOAD_DIR}\x86_64-5.3.0-release-posix-seh-rt_v4-rev0.7z'), 'toolchains\mingw');      
  
  if not FileExists(ExpandConstant('{#DOWNLOAD_DIR}\msys-rev13.7z')) then
    idpAddFileComp('http://downloads.sourceforge.net/project/mingwbuilds/external-binary-packages/msys%2B7za%2Bwget%2Bsvn%2Bgit%2Bmercurial%2Bcvs-rev13.7z',  ExpandConstant('{#DOWNLOAD_DIR}\msys-rev13.7z'),  'tools\msys');
  
  if not FileExists(ExpandConstant('{#DOWNLOAD_DIR}\doxygen-1.8.11-setup.exe')) then
    idpAddFileComp('http://sourceforge.net/projects/doxygen/files/rel-1.8.11/doxygen-1.8.11-setup.exe/download',  ExpandConstant('{#DOWNLOAD_DIR}\doxygen-1.8.11-setup.exe'), 'tools\doxygen');    
  
  if not FileExists(ExpandConstant('{#DOWNLOAD_DIR}\graphviz-2.38.zip')) then
    idpAddFileComp('http://www.graphviz.org/pub/graphviz/stable/windows/graphviz-2.38.zip',  ExpandConstant('{#DOWNLOAD_DIR}\graphviz-2.38.zip'),  'tools\graphiz');  
  
  if not FileExists(ExpandConstant('{#DOWNLOAD_DIR}\{#OPENOCD_FILENAME}')) then
    idpAddFileComp('{#OPENOCD_URL}',  ExpandConstant('{#DOWNLOAD_DIR}\{#OPENOCD_FILENAME}'),  'tools\openocd');    
 

 // if not FileExists(ExpandConstant('{userdocs}\microIDE_installer\python-2.7.11.msi')) then
  //  idpAddFileComp('https://www.python.org/ftp/python/2.7.11/python-2.7.11.msi',  ExpandConstant('{userdocs}\microIDE_installer\python-2.7.11.msi'),  'python');    
 
  idpDownloadAfter(wpReady);
  License_InitializeWizard();  
  Progress_InitializeWizard();                                                                
end; 

procedure CreateNoticeFile();
begin
  SaveStringToFile(ExpandConstant('{tmp}\eclipse-notice.txt'), 'IMPORTANT NOTICE' + #13#10 + #13#10 +
                                                               'When you close this window, "eclipse installer" will run.' + #13#10 +
                                                               'You have to set installation directory to: ' + ExpandConstant('{app}') + #13#10 +
                                                               'You also have to uncheck "create start menu entry" and "create desktop shortcut".', False);
end;

//procedure CreateCPPlintRunFile();
//begin
  //SaveStringToFile(ExpandConstant('{app}\tools\cpplint\runCPPlint.bat'), 'C:\Python27\python ' + ExpandConstant('{app}') + '\tools\cpplint\cpplint.py %1', False);
//end;   

//---------------------------------------