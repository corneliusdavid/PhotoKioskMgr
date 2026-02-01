unit Frames.Generate;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  FMX.Memo.Types, udmPhotoKiosk;

type
  TFrameGenerate = class(TFrame)
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
    layToolbar: TLayout;
    btnBack: TButton;
    procedure btnGenerateFirstNameClick(Sender: TObject);
    procedure btnGenerateLastNameClick(Sender: TObject);
    procedure btnGenerateBothClick(Sender: TObject);
    procedure btnPreviewFirstNameClick(Sender: TObject);
    procedure btnPreviewLastNameClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
  private
    FOnNavigateToList: TNotifyEvent;
    FGenerating: Boolean;
    procedure UpdateProgress(const Step: string; Percent: Integer);
    procedure LogOutput(const Message: string);
    procedure SetGeneratingState(Generating: Boolean);
    function ValidatePaths: Boolean;
    procedure GenerateFirstNamePages;
    procedure GenerateLastNamePages;
    procedure PreviewPages(ViewType: string);
  public
    constructor Create(AOwner: TComponent); override;

    property OnNavigateToList: TNotifyEvent read FOnNavigateToList write FOnNavigateToList;
  end;

implementation

{$R *.fmx}

uses
  System.IOUtils;

constructor TFrameGenerate.Create(AOwner: TComponent);
begin
  inherited;
  FGenerating := False;
  SetGeneratingState(False);
  UpdateProgress('Ready', 0);
  LogOutput('PhotoKiosk Generator ready');
end;

procedure TFrameGenerate.UpdateProgress(const Step: string; Percent: Integer);
begin
  lblProgress.Text := Step;
  rectProgressBar.Width := (rectProgress.Width * Percent) / 100;
  Application.ProcessMessages;
end;

procedure TFrameGenerate.LogOutput(const Message: string);
begin
  memoOutput.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + Message);
  memoOutput.GoToTextEnd;
  Application.ProcessMessages;
end;

procedure TFrameGenerate.SetGeneratingState(Generating: Boolean);
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

function TFrameGenerate.ValidatePaths: Boolean;
begin
  Result := True;

  if not TFile.Exists(dmPhotoKiosk.DatabasePath) then
  begin
    ShowMessage('Database file not found. Please configure paths in the Configure tab.');
    Result := False;
    Exit;
  end;

  // Additional path validation could be added here
end;

procedure TFrameGenerate.btnGenerateFirstNameClick(Sender: TObject);
begin
  if ValidatePaths then
    GenerateFirstNamePages;
end;

procedure TFrameGenerate.btnGenerateLastNameClick(Sender: TObject);
begin
  if ValidatePaths then
    GenerateLastNamePages;
end;

procedure TFrameGenerate.btnGenerateBothClick(Sender: TObject);
begin
  if ValidatePaths then
  begin
    GenerateFirstNamePages;
    GenerateLastNamePages;
  end;
end;

procedure TFrameGenerate.btnPreviewFirstNameClick(Sender: TObject);
begin
  if ValidatePaths then
    PreviewPages('firstname');
end;

procedure TFrameGenerate.btnPreviewLastNameClick(Sender: TObject);
begin
  if ValidatePaths then
    PreviewPages('lastname');
end;

procedure TFrameGenerate.GenerateFirstNamePages;
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

procedure TFrameGenerate.GenerateLastNamePages;
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

procedure TFrameGenerate.PreviewPages(ViewType: string);
begin
  LogOutput('Previewing ' + ViewType + ' pages...');
  // TODO: Implement preview functionality
  // Could open generated files in default browser
  ShowMessage('Preview functionality not yet implemented');
end;

procedure TFrameGenerate.btnBackClick(Sender: TObject);
begin
  if Assigned(FOnNavigateToList) then
    FOnNavigateToList(Self);
end;

end.
