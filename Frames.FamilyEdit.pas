unit Frames.FamilyEdit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  udmPhotoKiosk, Data.DB;

type
  TFrameFamilyEdit = class(TFrame)
    layMain: TLayout;
    layFields: TLayout;
    lblLastName: TLabel;
    edtLastName: TEdit;
    lblDisplayName: TLabel;
    edtDisplayName: TEdit;
    lblPhone: TLabel;
    edtPhone: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    lblNotes: TLabel;
    memoNotes: TMemo;
    layButtons: TLayout;
    btnSave: TButton;
    btnCancel: TButton;
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FFamilyID: Integer;
    FIsNewFamily: Boolean;
    procedure ClearFields;
    procedure LoadFamily(FamilyID: Integer);
    procedure SaveFamily;
  public
    constructor Create(AOwner: TComponent); override;
    procedure EditFamily(FamilyID: Integer);
    procedure NewFamily;
  end;

implementation

{$R *.fmx}

uses
  FireDAC.Comp.Client;

constructor TFrameFamilyEdit.Create(AOwner: TComponent);
begin
  inherited;
  FFamilyID := -1;
  FIsNewFamily := True;
  ClearFields;
end;

procedure TFrameFamilyEdit.ClearFields;
begin
  edtLastName.Text := '';
  edtDisplayName.Text := '';
  edtPhone.Text := '';
  edtEmail.Text := '';
  memoNotes.Lines.Clear;
end;

procedure TFrameFamilyEdit.NewFamily;
begin
  FFamilyID := -1;
  FIsNewFamily := True;
  ClearFields;
  edtLastName.SetFocus;
end;

procedure TFrameFamilyEdit.EditFamily(FamilyID: Integer);
begin
  FFamilyID := FamilyID;
  FIsNewFamily := False;
  LoadFamily(FamilyID);
end;

procedure TFrameFamilyEdit.LoadFamily(FamilyID: Integer);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmPhotoKiosk.FDConnection;
    qry.SQL.Text := 'SELECT * FROM families WHERE id = :id';
    qry.ParamByName('id').AsInteger := FamilyID;
    qry.Open;

    if not qry.Eof then
    begin
      edtLastName.Text := qry.FieldByName('last_name').AsString;
      edtDisplayName.Text := qry.FieldByName('display_name').AsString;
      edtPhone.Text := qry.FieldByName('phone').AsString;
      edtEmail.Text := qry.FieldByName('email').AsString;
      memoNotes.Lines.Text := qry.FieldByName('notes').AsString;
    end;
  finally
    qry.Free;
  end;
end;

procedure TFrameFamilyEdit.SaveFamily;
var
  qry: TFDQuery;
begin
  if Trim(edtLastName.Text) = '' then
  begin
    ShowMessage('Last Name is required');
    edtLastName.SetFocus;
    Exit;
  end;

  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmPhotoKiosk.FDConnection;

    if FIsNewFamily then
    begin
      // Insert new family
      qry.SQL.Text := 'INSERT INTO families (last_name, display_name, phone, email, notes, is_active) ' +
                      'VALUES (:last_name, :display_name, :phone, :email, :notes, 1)';
    end
    else
    begin
      // Update existing family
      qry.SQL.Text := 'UPDATE families SET ' +
                      'last_name = :last_name, ' +
                      'display_name = :display_name, ' +
                      'phone = :phone, ' +
                      'email = :email, ' +
                      'notes = :notes ' +
                      'WHERE id = :id';
      qry.ParamByName('id').AsInteger := FFamilyID;
    end;

    qry.ParamByName('last_name').AsString := Trim(edtLastName.Text);
    qry.ParamByName('display_name').AsString := Trim(edtDisplayName.Text);
    qry.ParamByName('phone').AsString := Trim(edtPhone.Text);
    qry.ParamByName('email').AsString := Trim(edtEmail.Text);
    qry.ParamByName('notes').AsString := memoNotes.Lines.Text;

    qry.ExecSQL;

    ShowMessage('Family saved successfully');
  finally
    qry.Free;
  end;
end;

procedure TFrameFamilyEdit.btnSaveClick(Sender: TObject);
begin
  SaveFamily;
  // TODO: Return to list view or stay in edit mode
end;

procedure TFrameFamilyEdit.btnCancelClick(Sender: TObject);
begin
  // TODO: Return to list view without saving
  if MessageDlg('Discard changes?', TMsgDlgType.mtConfirmation,
                [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    ClearFields;
  end;
end;

end.
