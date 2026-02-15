unit Frames.PersonEdit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.DialogService, FMX.StdCtrls,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation, FMX.ListBox,
  Data.DB, Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.DBScope, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  System.IOUtils, udmPhotoKiosk;

type
  TOnNavigateBack = procedure(FamilyID: Integer) of object;

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
    qryPerson: TFDQuery;
    dsPerson: TDataSource;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField4: TLinkControlToField;
    LinkControlToField5: TLinkControlToField;
    LinkControlToField6: TLinkControlToField;
    qryFamilies: TFDQuery;
    layPhotoFilename: TLayout;
    btnBack: TButton;
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnBrowsePhotoClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
  private
    FPersonID: Integer;
    FFamilyID: Integer;
    FIsNewPerson: Boolean;
    FOnNavigateBack: TOnNavigateBack;
    FOnNavigateToList: TNotifyEvent;
    procedure LoadFamilies;
    procedure SelectFamily(FamilyID: Integer);
    function GetSelectedFamilyID: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure EditPerson(PersonID: Integer);
    procedure NewPerson(FamilyID: Integer = -1);
    function SavePerson: Boolean;
    procedure RefreshFamilies;

    property PersonID: Integer read FPersonID;
    property FamilyID: Integer read FFamilyID;
    property OnNavigateBack: TOnNavigateBack read FOnNavigateBack write FOnNavigateBack;
    property OnNavigateToList: TNotifyEvent read FOnNavigateToList write FOnNavigateToList;
  end;

implementation

{$R *.fmx}

constructor TFramePersonEdit.Create(AOwner: TComponent);
begin
  inherited;
  FPersonID := -1;
  FFamilyID := -1;
  FIsNewPerson := True;
  LoadFamilies;
end;

procedure TFramePersonEdit.LoadFamilies;
var
  Item: TListBoxItem;
begin
  cboFamily.Clear;

  qryFamilies.Close;
  qryFamilies.Open;

  while not qryFamilies.Eof do
  begin
    Item := TListBoxItem.Create(cboFamily);
    Item.Text := qryFamilies.FieldByName('last_name').AsString;
    Item.Tag := qryFamilies.FieldByName('id').AsInteger;
    cboFamily.AddObject(Item);
    qryFamilies.Next;
  end;
end;

procedure TFramePersonEdit.RefreshFamilies;
begin
  LoadFamilies;
end;

procedure TFramePersonEdit.SelectFamily(FamilyID: Integer);
var
  I: Integer;
begin
  for I := 0 to cboFamily.Items.Count - 1 do
  begin
    if (cboFamily.ListItems[I] as TListBoxItem).Tag = FamilyID then
    begin
      cboFamily.ItemIndex := I;
      Exit;
    end;
  end;
end;

function TFramePersonEdit.GetSelectedFamilyID: Integer;
begin
  Result := -1;
  if cboFamily.ItemIndex >= 0 then
    Result := (cboFamily.ListItems[cboFamily.ItemIndex] as TListBoxItem).Tag;
end;

procedure TFramePersonEdit.NewPerson(FamilyID: Integer = -1);
begin
  FPersonID := -1;
  FFamilyID := FamilyID;
  FIsNewPerson := True;

  // Refresh families list
  LoadFamilies;

  // Prepare query for insert (empty record)
  qryPerson.Close;
  qryPerson.SQL.Text := 'SELECT id, family_id, first_name, middle_name, last_name, ' +
                        'is_parent, birth_year, photo_filename FROM people WHERE 1=0';
  qryPerson.Open;
  qryPerson.Append;

  // Select the family if provided
  if FamilyID > 0 then
    SelectFamily(FamilyID)
  else if cboFamily.Items.Count > 0 then
    cboFamily.ItemIndex := 0;

  edtFirstName.SetFocus;
end;

procedure TFramePersonEdit.EditPerson(PersonID: Integer);
var
  PersonFamilyID: Integer;
begin
  FPersonID := PersonID;
  FIsNewPerson := False;

  // Refresh families list
  LoadFamilies;

  // Load the person record
  qryPerson.Close;
  qryPerson.SQL.Text := 'SELECT id, family_id, first_name, middle_name, last_name, ' +
                        'is_parent, birth_year, photo_filename FROM people WHERE id = :id';
  qryPerson.ParamByName('id').AsInteger := PersonID;
  qryPerson.Open;

  if not qryPerson.Eof then
  begin
    PersonFamilyID := qryPerson.FieldByName('family_id').AsInteger;
    FFamilyID := PersonFamilyID;
    SelectFamily(PersonFamilyID);
    qryPerson.Edit;
  end;
end;

function TFramePersonEdit.SavePerson: Boolean;
var
  qryInsert: TFDQuery;
  SelectedFamilyID: Integer;
begin
  Result := False;

  // Validate
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

  SelectedFamilyID := GetSelectedFamilyID;
  if SelectedFamilyID <= 0 then
  begin
    ShowMessage('Please select a family');
    Exit;
  end;

  try
    if FIsNewPerson then
    begin
      // For new person, do an INSERT
      qryInsert := TFDQuery.Create(nil);
      try
        qryInsert.Connection := dmPhotoKiosk.FDConnection;
        qryInsert.SQL.Text := 'INSERT INTO people (family_id, first_name, middle_name, last_name, ' +
                              'is_parent, birth_year, photo_filename, is_active) ' +
                              'VALUES (:family_id, :first_name, :middle_name, :last_name, ' +
                              ':is_parent, :birth_year, :photo_filename, 1)';
        qryInsert.ParamByName('family_id').AsInteger := SelectedFamilyID;
        qryInsert.ParamByName('first_name').AsString := Trim(edtFirstName.Text);
        qryInsert.ParamByName('middle_name').AsString := Trim(edtMiddleName.Text);
        qryInsert.ParamByName('last_name').AsString := Trim(edtLastName.Text);
        qryInsert.ParamByName('is_parent').AsBoolean := chkIsParent.IsChecked;

        if Trim(edtBirthYear.Text) <> '' then
          qryInsert.ParamByName('birth_year').AsInteger := StrToIntDef(edtBirthYear.Text, 0)
        else
          qryInsert.ParamByName('birth_year').Clear;

        qryInsert.ParamByName('photo_filename').AsString := Trim(edtPhotoFilename.Text);
        qryInsert.ExecSQL;

        // Get the new ID
        qryInsert.SQL.Text := 'SELECT last_insert_rowid() as new_id';
        qryInsert.Open;
        FPersonID := qryInsert.FieldByName('new_id').AsInteger;
        FIsNewPerson := False;
        FFamilyID := SelectedFamilyID;
      finally
        qryInsert.Free;
      end;
    end
    else
    begin
      // For existing person, update the family_id field manually since it's not bound
      // Then post the changes through the dataset
      qryPerson.FieldByName('family_id').AsInteger := SelectedFamilyID;
      if qryPerson.State in [dsEdit, dsInsert] then
        qryPerson.Post;
      FFamilyID := SelectedFamilyID;
    end;

    Result := True;
    ShowMessage('Person saved successfully');
  except
    on E: Exception do
      ShowMessage('Error saving person: ' + E.Message);
  end;
end;

procedure TFramePersonEdit.btnSaveClick(Sender: TObject);
begin
  if SavePerson then
  begin
    if Assigned(FOnNavigateBack) then
      FOnNavigateBack(FFamilyID);
  end;
end;

procedure TFramePersonEdit.btnCancelClick(Sender: TObject);
begin
  if qryPerson.State in [dsEdit, dsInsert] then
    qryPerson.Cancel;

  if Assigned(FOnNavigateBack) then
    FOnNavigateBack(FFamilyID)
  else
    TDialogService.MessageDialog('Discard changes?', TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
        begin
          if qryPerson.Active then
            qryPerson.Close;
        end;
      end);
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

procedure TFramePersonEdit.btnBackClick(Sender: TObject);
begin
  if Assigned(FOnNavigateToList) then
    FOnNavigateToList(Self);
end;

end.
