unit ufrmPhotoKioskMgrMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IniFiles,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Edit, FMX.Layouts, FMX.Objects, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, udmPhotoKiosk, FMX.Memo.Types;

type
  TfrmPhotoKioskMgrMain = class(TForm)
    TabControl1: TTabControl;
    tabGenerate: TTabItem;
    tabConfigure: TTabItem;
    // Generate Tab Controls
    layGenerateMain: TLayout;
    lblTitle: TLabel;
    layButtons: TLayout;
    btnGenerateFirstName: TButton;
    btnGenerateLastName: TButton;
    btnGenerateBoth: TButton;
    layProgress: TLayout;
    lblProgress: TLabel;
    rectProgress: TRectangle;
    rectProgressBar: TRectangle;
    layPreview: TLayout;
    btnPreviewFirstName: TButton;
    btnPreviewLastName: TButton;
    layOutput: TLayout;
    memoOutput: TMemo;
    lblOutput: TLabel;
    // Configure Tab Controls
    layConfigureMain: TLayout;
    layPaths: TLayout;
    lblPhotoPath: TLabel;
    edtPhotoPath: TEdit;
    btnBrowsePhotoPath: TButton;
    lblTemplatePath: TLabel;
    edtTemplatePath: TEdit;
    btnBrowseTemplatePath: TButton;
    lblOutputPath: TLabel;
    edtOutputPath: TEdit;
    btnBrowseOutputPath: TButton;
    layDatabase: TLayout;
    lblDatabasePath: TLabel;
    edtDatabasePath: TEdit;
    btnBrowseDatabasePath: TButton;
    btnTestConnection: TButton;
    layConfigButtons: TLayout;
    btnSaveConfig: TButton;
    btnLoadConfig: TButton;
    btnResetToDefaults: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnGenerateFirstNameClick(Sender: TObject);
    procedure btnGenerateLastNameClick(Sender: TObject);
    procedure btnGenerateBothClick(Sender: TObject);
    procedure btnPreviewFirstNameClick(Sender: TObject);
    procedure btnPreviewLastNameClick(Sender: TObject);
    procedure btnBrowsePhotoPathClick(Sender: TObject);
    procedure btnBrowseTemplatePathClick(Sender: TObject);
    procedure btnBrowseOutputPathClick(Sender: TObject);
    procedure btnBrowseDatabasePathClick(Sender: TObject);
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnLoadConfigClick(Sender: TObject);
    procedure btnResetToDefaultsClick(Sender: TObject);

  private
    FConfigPath: string;
    FGenerating: Boolean;

    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure SetDefaultPaths;
    procedure UpdateProgress(const Step: string; Percent: Integer);
    procedure LogOutput(const Message: string);
    procedure SetGeneratingState(Generating: Boolean);
    function ValidatePaths: Boolean;
    function GetConfigPath: string;

    // Generation methods
    procedure GenerateFirstNamePages;
    procedure GenerateLastNamePages;
    procedure PreviewPages(ViewType: string);

  public
    { Public declarations }
  end;

var
  frmPhotoKioskMgrMain: TfrmPhotoKioskMgrMain;

implementation

{$R *.fmx}

uses
  System.IOUtils;

procedure TfrmPhotoKioskMgrMain.FormCreate(Sender: TObject);
begin
  FConfigPath := GetConfigPath;
  FGenerating := False;

  // Set default tab
  TabControl1.ActiveTab := tabGenerate;

  // Initialize paths
  SetDefaultPaths;
  LoadConfiguration;

  // Setup initial UI state
  SetGeneratingState(False);
  UpdateProgress('Ready', 0);

  LogOutput('PhotoKiosk Generator started');
  LogOutput('Database: ' + dmPhotoKiosk.DatabasePath);
end;

procedure TfrmPhotoKioskMgrMain.FormDestroy(Sender: TObject);
begin
  SaveConfiguration;
end;

function TfrmPhotoKioskMgrMain.GetConfigPath: string;
begin
  Result := TPath.Combine(TPath.GetDocumentsPath, 'PhotoKiosk');
  if not TDirectory.Exists(Result) then
    try
      TDirectory.CreateDirectory(Result);
    except
      ShowMessage('''
The system prevented the application path from being created.
You might need to adjust your security systems or allow an
exception for this path:

''' + Result);
      Abort;
    end;
  Result := TPath.Combine(Result, 'PhotoKiosk.ini');
end;

procedure TfrmPhotoKioskMgrMain.SetDefaultPaths;
var
  BaseDir: string;
begin
  BaseDir := TPath.Combine(TPath.GetDocumentsPath, 'PhotoKiosk');

  edtDatabasePath.Text := dmPhotoKiosk.DatabasePath;
  edtPhotoPath.Text := TPath.Combine(BaseDir, 'Photos');
  edtTemplatePath.Text := TPath.Combine(BaseDir, 'Templates');
  edtOutputPath.Text := TPath.Combine(BaseDir, 'Output');

  // Create directories if they don't exist
  if not TDirectory.Exists(edtPhotoPath.Text) then
    TDirectory.CreateDirectory(edtPhotoPath.Text);
  if not TDirectory.Exists(edtTemplatePath.Text) then
    TDirectory.CreateDirectory(edtTemplatePath.Text);
  if not TDirectory.Exists(edtOutputPath.Text) then
    TDirectory.CreateDirectory(edtOutputPath.Text);
end;

procedure TfrmPhotoKioskMgrMain.LoadConfiguration;
var
  Ini: TIniFile;
begin
  if not TFile.Exists(FConfigPath) then
    Exit;

  Ini := TIniFile.Create(FConfigPath);
  try
    edtDatabasePath.Text := Ini.ReadString('Paths', 'Database', edtDatabasePath.Text);
    edtPhotoPath.Text := Ini.ReadString('Paths', 'Photos', edtPhotoPath.Text);
    edtTemplatePath.Text := Ini.ReadString('Paths', 'Templates', edtTemplatePath.Text);
    edtOutputPath.Text := Ini.ReadString('Paths', 'Output', edtOutputPath.Text);
  finally
    Ini.Free;
  end;
end;

procedure TfrmPhotoKioskMgrMain.SaveConfiguration;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FConfigPath);
  try
    Ini.WriteString('Paths', 'Database', edtDatabasePath.Text);
    Ini.WriteString('Paths', 'Photos', edtPhotoPath.Text);
    Ini.WriteString('Paths', 'Templates', edtTemplatePath.Text);
    Ini.WriteString('Paths', 'Output', edtOutputPath.Text);
  finally
    Ini.Free;
  end;
end;

procedure TfrmPhotoKioskMgrMain.UpdateProgress(const Step: string; Percent: Integer);
begin
  lblProgress.Text := Step;
  rectProgressBar.Width := (rectProgress.Width * Percent) / 100;
  Application.ProcessMessages;
end;

procedure TfrmPhotoKioskMgrMain.LogOutput(const Message: string);
begin
  memoOutput.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + Message);
  memoOutput.GoToTextEnd;
  Application.ProcessMessages;
end;

procedure TfrmPhotoKioskMgrMain.SetGeneratingState(Generating: Boolean);
begin
  FGenerating := Generating;

  // Enable/disable buttons
  btnGenerateFirstName.Enabled := not Generating;
  btnGenerateLastName.Enabled := not Generating;
  btnGenerateBoth.Enabled := not Generating;
  btnPreviewFirstName.Enabled := not Generating;
  btnPreviewLastName.Enabled := not Generating;

  if not Generating then
    UpdateProgress('Ready', 0);
end;

function TfrmPhotoKioskMgrMain.ValidatePaths: Boolean;
begin
  Result := True;

  if not TFile.Exists(edtDatabasePath.Text) then
  begin
    ShowMessage('Database file not found: ' + edtDatabasePath.Text);
    TabControl1.ActiveTab := tabConfigure;
    Result := False;
    Exit;
  end;

  if not TDirectory.Exists(edtPhotoPath.Text) then
  begin
    ShowMessage('Photo directory not found: ' + edtPhotoPath.Text);
    TabControl1.ActiveTab := tabConfigure;
    Result := False;
    Exit;
  end;

  if not TDirectory.Exists(edtTemplatePath.Text) then
  begin
    ShowMessage('Template directory not found: ' + edtTemplatePath.Text);
    TabControl1.ActiveTab := tabConfigure;
    Result := False;
    Exit;
  end;

  if not TDirectory.Exists(edtOutputPath.Text) then
  begin
    if MessageDlg('Output directory does not exist. Create it?',
                  TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
      TDirectory.CreateDirectory(edtOutputPath.Text)
    else
    begin
      TabControl1.ActiveTab := tabConfigure;
      Result := False;
    end;
  end;
end;

// Browse button events
procedure TfrmPhotoKioskMgrMain.btnBrowsePhotoPathClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.Title := 'Select Photo Directory';
    Dialog.Options := [TOpenOption.ofPathMustExist];
    if Dialog.Execute then
      edtPhotoPath.Text := ExtractFilePath(Dialog.FileName);
  finally
    Dialog.Free;
  end;
end;

procedure TfrmPhotoKioskMgrMain.btnBrowseTemplatePathClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.Title := 'Select Template Directory';
    Dialog.Options := [TOpenOption.ofPathMustExist];
    if Dialog.Execute then
      edtTemplatePath.Text := ExtractFilePath(Dialog.FileName);
  finally
    Dialog.Free;
  end;
end;

procedure TfrmPhotoKioskMgrMain.btnBrowseOutputPathClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.Title := 'Select Output Directory';
    Dialog.Options := [TOpenOption.ofPathMustExist];
    if Dialog.Execute then
      edtOutputPath.Text := ExtractFilePath(Dialog.FileName);
  finally
    Dialog.Free;
  end;
end;

procedure TfrmPhotoKioskMgrMain.btnBrowseDatabasePathClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.Title := 'Select Database File';
    Dialog.Filter := 'SQLite Database|*.db|All Files|*.*';
    Dialog.DefaultExt := 'db';
    if Dialog.Execute then
      edtDatabasePath.Text := Dialog.FileName;
  finally
    Dialog.Free;
  end;
end;

// Configuration button events
procedure TfrmPhotoKioskMgrMain.btnTestConnectionClick(Sender: TObject);
begin
  dmPhotoKiosk.DatabasePath := edtDatabasePath.Text;
  if dmPhotoKiosk.TestConnection then
  begin
    LogOutput('Database connection successful');
    ShowMessage('Database connection successful!');
  end
  else
  begin
    LogOutput('Database connection failed');
    ShowMessage('Database connection failed!');
  end;
end;

procedure TfrmPhotoKioskMgrMain.btnSaveConfigClick(Sender: TObject);
begin
  SaveConfiguration;
  LogOutput('Configuration saved');
  ShowMessage('Configuration saved successfully!');
end;

procedure TfrmPhotoKioskMgrMain.btnLoadConfigClick(Sender: TObject);
begin
  LoadConfiguration;
  LogOutput('Configuration loaded');
  ShowMessage('Configuration loaded successfully!');
end;

procedure TfrmPhotoKioskMgrMain.btnResetToDefaultsClick(Sender: TObject);
begin
  if MessageDlg('Reset all paths to defaults?', TMsgDlgType.mtConfirmation,
                [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    SetDefaultPaths;
    LogOutput('Paths reset to defaults');
  end;
end;

// Generation button events
procedure TfrmPhotoKioskMgrMain.btnGenerateFirstNameClick(Sender: TObject);
begin
  if ValidatePaths then
    GenerateFirstNamePages;
end;

procedure TfrmPhotoKioskMgrMain.btnGenerateLastNameClick(Sender: TObject);
begin
  if ValidatePaths then
    GenerateLastNamePages;
end;

procedure TfrmPhotoKioskMgrMain.btnGenerateBothClick(Sender: TObject);
begin
  if ValidatePaths then
  begin
    GenerateFirstNamePages;
    GenerateLastNamePages;
  end;
end;

procedure TfrmPhotoKioskMgrMain.btnPreviewFirstNameClick(Sender: TObject);
begin
  if ValidatePaths then
    PreviewPages('firstname');
end;

procedure TfrmPhotoKioskMgrMain.btnPreviewLastNameClick(Sender: TObject);
begin
  if ValidatePaths then
    PreviewPages('lastname');
end;

// Generation methods (to be implemented)
procedure TfrmPhotoKioskMgrMain.GenerateFirstNamePages;
begin
  SetGeneratingState(True);
  try
    LogOutput('Starting FirstName page generation...');
    UpdateProgress('Loading data...', 10);

    // TODO: Implement template processing
    // dmPhotoKiosk.OpenFirstNameView;
    // Process templates with database data

    UpdateProgress('Generating pages...', 50);

    // TODO: Generate HTML files

    UpdateProgress('Complete', 100);
    LogOutput('FirstName pages generated successfully');

  except
    on E: Exception do
    begin
      LogOutput('Error generating FirstName pages: ' + E.Message);
      ShowMessage('Error: ' + E.Message);
    end;
  end;
  SetGeneratingState(False);
end;

procedure TfrmPhotoKioskMgrMain.GenerateLastNamePages;
begin
  SetGeneratingState(True);
  try
    LogOutput('Starting LastName page generation...');
    UpdateProgress('Loading data...', 10);

    // TODO: Implement template processing
    // dmPhotoKiosk.OpenLastNameView;
    // Process templates with database data

    UpdateProgress('Generating pages...', 50);

    // TODO: Generate HTML files

    UpdateProgress('Complete', 100);
    LogOutput('LastName pages generated successfully');

  except
    on E: Exception do
    begin
      LogOutput('Error generating LastName pages: ' + E.Message);
      ShowMessage('Error: ' + E.Message);
    end;
  end;
  SetGeneratingState(False);
end;

procedure TfrmPhotoKioskMgrMain.PreviewPages(ViewType: string);
begin
  LogOutput('Previewing ' + ViewType + ' pages...');
  // TODO: Implement preview functionality
  // Could open generated files in default browser
  ShowMessage('Preview functionality not yet implemented');
end;

end.
