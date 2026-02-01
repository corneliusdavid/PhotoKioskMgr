unit Frames.Configure;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IniFiles,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation, udmPhotoKiosk;

type
  TFrameConfigure = class(TFrame)
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
    btnBack: TButton;
    procedure btnBrowsePhotoPathClick(Sender: TObject);
    procedure btnBrowseTemplatePathClick(Sender: TObject);
    procedure btnBrowseOutputPathClick(Sender: TObject);
    procedure btnBrowseDatabasePathClick(Sender: TObject);
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnLoadConfigClick(Sender: TObject);
    procedure btnResetToDefaultsClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
  private
    FOnNavigateToList: TNotifyEvent;
    FConfigPath: string;
    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure SetDefaultPaths;
    function GetConfigPath: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property OnNavigateToList: TNotifyEvent read FOnNavigateToList write FOnNavigateToList;
  end;

implementation

{$R *.fmx}

uses
  System.IOUtils;

constructor TFrameConfigure.Create(AOwner: TComponent);
begin
  inherited;
  FConfigPath := GetConfigPath;
  SetDefaultPaths;
  LoadConfiguration;
end;

destructor TFrameConfigure.Destroy;
begin
  inherited;
end;

function TFrameConfigure.GetConfigPath: string;
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

procedure TFrameConfigure.SetDefaultPaths;
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

procedure TFrameConfigure.LoadConfiguration;
var
  Ini: TMemIniFile;
begin
  if not TFile.Exists(FConfigPath) then
    Exit;

  Ini := TMemIniFile.Create(FConfigPath);
  try
    edtDatabasePath.Text := Ini.ReadString('Paths', 'Database', edtDatabasePath.Text);
    edtPhotoPath.Text := Ini.ReadString('Paths', 'Photos', edtPhotoPath.Text);
    edtTemplatePath.Text := Ini.ReadString('Paths', 'Templates', edtTemplatePath.Text);
    edtOutputPath.Text := Ini.ReadString('Paths', 'Output', edtOutputPath.Text);
  finally
    Ini.Free;
  end;
end;

procedure TFrameConfigure.SaveConfiguration;
var
  Ini: TMemIniFile;
begin
  ForceDirectories(ExtractFilePath(FConfigPath));
  Ini := TMemIniFile.Create(FConfigPath);
  try
    Ini.WriteString('Paths', 'Database', edtDatabasePath.Text);
    Ini.WriteString('Paths', 'Photos', edtPhotoPath.Text);
    Ini.WriteString('Paths', 'Templates', edtTemplatePath.Text);
    Ini.WriteString('Paths', 'Output', edtOutputPath.Text);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TFrameConfigure.btnBrowsePhotoPathClick(Sender: TObject);
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

procedure TFrameConfigure.btnBrowseTemplatePathClick(Sender: TObject);
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

procedure TFrameConfigure.btnBrowseOutputPathClick(Sender: TObject);
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

procedure TFrameConfigure.btnBrowseDatabasePathClick(Sender: TObject);
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

procedure TFrameConfigure.btnTestConnectionClick(Sender: TObject);
begin
  dmPhotoKiosk.DatabasePath := edtDatabasePath.Text;
  if dmPhotoKiosk.TestConnection then
    ShowMessage('Database connection successful!')
  else
    ShowMessage('Database connection failed!');
end;

procedure TFrameConfigure.btnSaveConfigClick(Sender: TObject);
begin
  SaveConfiguration;
  ShowMessage('Configuration saved successfully!');
end;

procedure TFrameConfigure.btnLoadConfigClick(Sender: TObject);
begin
  LoadConfiguration;
  ShowMessage('Configuration loaded successfully!');
end;

procedure TFrameConfigure.btnResetToDefaultsClick(Sender: TObject);
begin
  if MessageDlg('Reset all paths to defaults?', TMsgDlgType.mtConfirmation,
                [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    SetDefaultPaths;
  end;
end;

procedure TFrameConfigure.btnBackClick(Sender: TObject);
begin
  if Assigned(FOnNavigateToList) then
    FOnNavigateToList(Self);
end;

end.
