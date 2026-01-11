unit Frames.PersonEdit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation, FMX.ListBox,
  udmPhotoKiosk, Data.DB;

type
  TFramePersonEdit = class(TFrame)
    layMain: TLayout;
    layFields: TLayout;
    lblFirstName: TLabel;
    edtFirstName: TEdit;
    lblMiddleName: TLabel;
    edtMiddleName: TEdit;
    lblLastName: TLabel;
    edtLastName: TEdit;
    lblFamily: TLabel;
    cboFamily: TComboBox;
    lblBirthYear: TLabel;
    edtBirthYear: TEdit;
    chkIsParent: TCheckBox;
    lblPhotoFilename: TLabel;
    edtPhotoFilename: TEdit;
    btnBrowsePhoto: TButton;
    layButtons: TLayout;
    btnSave: TButton;
    btnCancel: TButton;
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnBrowsePhotoClick(Sender: TObject);
  private
    FPersonID: Integer;
    FIsNewPerson: Boolean;
    procedure ClearFields;
    procedure LoadPerson(PersonID: Integer);
    procedure LoadFamilies;
    procedure SavePerson;
  public
    constructor Create(AOwner: TComponent); override;
    procedure EditPerson(PersonID: Integer);
    procedure NewPerson(FamilyID: Integer = -1);
  end;

implementation

{$R *.fmx}

uses
  FireDAC.Comp.Client, System.IOUtils;

constructor TFramePersonEdit.Create(AOwner: TComponent);
begin
  inherited;
  FPersonID := -1;
  FIsNewPerson := True;
  LoadFamilies;
  ClearFields;
end;

procedure TFramePersonEdit.ClearFields;
begin
  edtFirstName.Text := '';
  edtMiddleName.Text := '';
  edtLastName.Text := '';
  edtBirthYear.Text := '';
  edtPhotoFilename.Text := '';
  chkIsParent.IsChecked := False;
  if cboFamily.Items.Count > 0 then
    cboFamily.ItemIndex := 0;
end;

procedure TFramePersonEdit.LoadFamilies;
var
  qry: TFDQuery;
  Item: TListBoxItem;
begin
  cboFamily.Clear;

  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmPhotoKiosk.FDConnection;
    qry.SQL.Text := 'SELECT id, last_name FROM families WHERE is_active = 1 ORDER BY last_name';
    qry.Open;

    while not qry.Eof do
    begin
      Item := TListBoxItem.Create(cboFamily);
      Item.Text := qry.FieldByName('last_name').AsString;
      Item.Tag := qry.FieldByName('id').AsInteger;
      cboFamily.AddObject(Item);
      qry.Next;
    end;
  finally
    qry.Free;
  end;
end;

procedure TFramePersonEdit.NewPerson(FamilyID: Integer = -1);
var
  I: Integer;
begin
  FPersonID := -1;
  FIsNewPerson := True;
  ClearFields;

  // If a family ID is provided, select it
  if FamilyID > 0 then
  begin
    for I := 0 to cboFamily.Items.Count - 1 do
    begin
      if (cboFamily.ListItems[I] as TListBoxItem).Tag = FamilyID then
      begin
        cboFamily.ItemIndex := I;
        Break;
      end;
    end;
  end;

  edtFirstName.SetFocus;
end;

procedure TFramePersonEdit.EditPerson(PersonID: Integer);
begin
  FPersonID := PersonID;
  FIsNewPerson := False;
  LoadPerson(PersonID);
end;

procedure TFramePersonEdit.LoadPerson(PersonID: Integer);
var
  qry: TFDQuery;
  I: Integer;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmPhotoKiosk.FDConnection;
    qry.SQL.Text := 'SELECT * FROM people WHERE id = :id';
    qry.ParamByName('id').AsInteger := PersonID;
    qry.Open;

    if not qry.Eof then
    begin
      edtFirstName.Text := qry.FieldByName('first_name').AsString;
      edtMiddleName.Text := qry.FieldByName('middle_name').AsString;
      edtLastName.Text := qry.FieldByName('last_name').AsString;
      edtBirthYear.Text := qry.FieldByName('birth_year').AsString;
      edtPhotoFilename.Text := qry.FieldByName('photo_filename').AsString;
      chkIsParent.IsChecked := qry.FieldByName('is_parent').AsBoolean;

      // Select the family in combo
      for I := 0 to cboFamily.Items.Count - 1 do
      begin
        if (cboFamily.ListItems[I] as TListBoxItem).Tag = qry.FieldByName('family_id').AsInteger then
        begin
          cboFamily.ItemIndex := I;
          Break;
        end;
      end;
    end;
  finally
    qry.Free;
  end;
end;

procedure TFramePersonEdit.SavePerson;
var
  qry: TFDQuery;
  FamilyID: Integer;
begin
  if Trim(edtFirstName.Text) = '' then
  begin
    ShowMessage('First Name is required');
    edtFirstName.SetFocus;
    Exit;
  end;

  if Trim(edtLastName.Text) = '' then
  begin
    ShowMessage('Last Name is required');
    edtLastName.SetFocus;
    Exit;
  end;

  if cboFamily.ItemIndex < 0 then
  begin
    ShowMessage('Please select a family');
    Exit;
  end;

  FamilyID := (cboFamily.ListItems[cboFamily.ItemIndex] as TListBoxItem).Tag;

  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmPhotoKiosk.FDConnection;

    if FIsNewPerson then
    begin
      // Insert new person
      qry.SQL.Text := 'INSERT INTO people (family_id, first_name, middle_name, last_name, ' +
                      'is_parent, birth_year, photo_filename, is_active) ' +
                      'VALUES (:family_id, :first_name, :middle_name, :last_name, ' +
                      ':is_parent, :birth_year, :photo_filename, 1)';
    end
    else
    begin
      // Update existing person
      qry.SQL.Text := 'UPDATE people SET ' +
                      'family_id = :family_id, ' +
                      'first_name = :first_name, ' +
                      'middle_name = :middle_name, ' +
                      'last_name = :last_name, ' +
                      'is_parent = :is_parent, ' +
                      'birth_year = :birth_year, ' +
                      'photo_filename = :photo_filename ' +
                      'WHERE id = :id';
      qry.ParamByName('id').AsInteger := FPersonID;
    end;

    qry.ParamByName('family_id').AsInteger := FamilyID;
    qry.ParamByName('first_name').AsString := Trim(edtFirstName.Text);
    qry.ParamByName('middle_name').AsString := Trim(edtMiddleName.Text);
    qry.ParamByName('last_name').AsString := Trim(edtLastName.Text);
    qry.ParamByName('is_parent').AsBoolean := chkIsParent.IsChecked;

    if Trim(edtBirthYear.Text) <> '' then
      qry.ParamByName('birth_year').AsInteger := StrToIntDef(edtBirthYear.Text, 0)
    else
      qry.ParamByName('birth_year').Clear;

    qry.ParamByName('photo_filename').AsString := Trim(edtPhotoFilename.Text);

    qry.ExecSQL;

    ShowMessage('Person saved successfully');
  finally
    qry.Free;
  end;
end;

procedure TFramePersonEdit.btnSaveClick(Sender: TObject);
begin
  SavePerson;
  // TODO: Return to list view or stay in edit mode
end;

procedure TFramePersonEdit.btnCancelClick(Sender: TObject);
begin
  // TODO: Return to list view without saving
  if MessageDlg('Discard changes?', TMsgDlgType.mtConfirmation,
                [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    ClearFields;
  end;
end;

procedure TFramePersonEdit.btnBrowsePhotoClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.Title := 'Select Photo';
    Dialog.Filter := 'Image Files|*.jpg;*.jpeg;*.png;*.bmp|All Files|*.*';
    if Dialog.Execute then
      edtPhotoFilename.Text := ExtractFileName(Dialog.FileName);
  finally
    Dialog.Free;
  end;
end;

end.
