unit Frames.Configure;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
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
    btnTestConnection: TButton;
    layConfigButtons: TLayout;
    btnSaveConfig: TButton;
    btnLoadConfig: TButton;
    btnResetToDefaults: TButton;
    btnBack: TButton;
    procedure btnBrowsePhotoPathClick(Sender: TObject);
    procedure btnBrowseTemplatePathClick(Sender: TObject);
    procedure btnBrowseOutputPathClick(Sender: TObject);
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnLoadConfigClick(Sender: TObject);
    procedure btnResetToDefaultsClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
  private
    FOnNavigateToList: TNotifyEvent;
    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure SetDefaultPaths;
  public
    constructor Create(AOwner: TComponent); override;

    property OnNavigateToList: TNotifyEvent read FOnNavigateToList write FOnNavigateToList;
  end;

implementation

{$R *.fmx}

uses
  System.IOUtils;

constructor TFrameConfigure.Create(AOwner: TComponent);
begin
  inherited;
  SetDefaultPaths;
  LoadConfiguration;
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
  Value: string;
begin
  Value := dmPhotoKiosk.GetConfigValue('photo_path');
  if Value <> '' then
    edtPhotoPath.Text := Value;

  Value := dmPhotoKiosk.GetConfigValue('template_path');
  if Value <> '' then
    edtTemplatePath.Text := Value;

  Value := dmPhotoKiosk.GetConfigValue('output_path');
  if Value <> '' then
    edtOutputPath.Text := Value;
end;

procedure TFrameConfigure.SaveConfiguration;
begin
  dmPhotoKiosk.SetConfigValue('photo_path', edtPhotoPath.Text);
  dmPhotoKiosk.SetConfigValue('template_path', edtTemplatePath.Text);
  dmPhotoKiosk.SetConfigValue('output_path', edtOutputPath.Text);
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

procedure TFrameConfigure.btnTestConnectionClick(Sender: TObject);
begin
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
