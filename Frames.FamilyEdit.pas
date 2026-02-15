unit Frames.FamilyEdit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.DialogService, FMX.StdCtrls,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Memo.Types,
  Data.DB, Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.DBScope, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  udmPhotoKiosk;

type
  TOnNavigateToPersonEdit = procedure(PersonID: Integer; FamilyID: Integer) of object;
  TOnNavigateToList = procedure of object;

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
    dsFamily: TDataSource;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField4: TLinkControlToField;
    LinkControlToField5: TLinkControlToField;
    layMembers: TLayout;
    lblMembers: TLabel;
    layMemberButtons: TLayout;
    btnAddPerson: TButton;
    btnEditPerson: TButton;
    lvMembers: TListView;
    btnBack: TButton;
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnAddPersonClick(Sender: TObject);
    procedure btnEditPersonClick(Sender: TObject);
    procedure lvMembersDblClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
  private
    FFamilyID: Integer;
    FIsNewFamily: Boolean;
    FOnNavigateToPersonEdit: TOnNavigateToPersonEdit;
    FOnNavigateToList: TOnNavigateToList;
    procedure LoadMembers;
    function GetSelectedPersonID: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure EditFamily(FamilyID: Integer);
    procedure NewFamily;
    function SaveFamily: Boolean;

    property FamilyID: Integer read FFamilyID;
    property OnNavigateToPersonEdit: TOnNavigateToPersonEdit read FOnNavigateToPersonEdit write FOnNavigateToPersonEdit;
    property OnNavigateToList: TOnNavigateToList read FOnNavigateToList write FOnNavigateToList;
  end;

implementation

{$R *.fmx}

constructor TFrameFamilyEdit.Create(AOwner: TComponent);
begin
  inherited;
  FFamilyID := -1;
  FIsNewFamily := True;
end;

procedure TFrameFamilyEdit.NewFamily;
begin
  FFamilyID := -1;
  FIsNewFamily := True;

  // Close any existing query and prepare for insert
  dmPhotoKiosk.qryFamilyEdit.Close;

  // Clear the edit fields
  edtLastName.Text := '';
  edtDisplayName.Text := '';
  edtPhone.Text := '';
  edtEmail.Text := '';
  memoNotes.Lines.Clear;

  // Clear members list and hide member buttons
  lvMembers.Items.Clear;
  btnAddPerson.Visible := False;
  btnEditPerson.Visible := False;

  edtLastName.SetFocus;
end;

procedure TFrameFamilyEdit.EditFamily(FamilyID: Integer);
begin
  FFamilyID := FamilyID;
  FIsNewFamily := False;

  // Load the family record using LiveBindings
  dmPhotoKiosk.qryFamilyEdit.Close;
  dmPhotoKiosk.qryFamilyEdit.ParamByName('id').AsInteger := FamilyID;
  dmPhotoKiosk.qryFamilyEdit.Open;

  if not dmPhotoKiosk.qryFamilyEdit.Eof then
    dmPhotoKiosk.qryFamilyEdit.Edit;

  // Load family members and show member buttons
  LoadMembers;
  btnAddPerson.Visible := True;
  btnEditPerson.Visible := True;
end;

procedure TFrameFamilyEdit.LoadMembers;
var
  Item: TListViewItem;
begin
  lvMembers.Items.Clear;

  if FFamilyID <= 0 then
    Exit;

  dmPhotoKiosk.qryFamilyMembers.Close;
  dmPhotoKiosk.qryFamilyMembers.ParamByName('family_id').AsInteger := FFamilyID;
  dmPhotoKiosk.qryFamilyMembers.Open;

  lvMembers.BeginUpdate;
  try
    while not dmPhotoKiosk.qryFamilyMembers.Eof do
    begin
      Item := lvMembers.Items.Add;
      Item.Text := dmPhotoKiosk.qryFamilyMembers.FieldByName('full_name').AsString;
      if dmPhotoKiosk.qryFamilyMembers.FieldByName('is_parent').AsBoolean then
        Item.Detail := 'Parent'
      else
        Item.Detail := 'Child';
      Item.Tag := dmPhotoKiosk.qryFamilyMembers.FieldByName('id').AsInteger;
      dmPhotoKiosk.qryFamilyMembers.Next;
    end;
  finally
    lvMembers.EndUpdate;
  end;
end;

function TFrameFamilyEdit.GetSelectedPersonID: Integer;
begin
  Result := -1;
  if Assigned(lvMembers.Selected) then
    Result := lvMembers.Selected.Tag;
end;

function TFrameFamilyEdit.SaveFamily: Boolean;
begin
  Result := False;

  // Validate
  if Trim(edtLastName.Text) = '' then
  begin
    ShowMessage('Last Name is required');
    edtLastName.SetFocus;
    Exit;
  end;

  try
    dmPhotoKiosk.EnsureConnected;

    if FIsNewFamily then
    begin
      // Insert new family
      dmPhotoKiosk.qryInsertFamily.ParamByName('last_name').AsString := Trim(edtLastName.Text);
      dmPhotoKiosk.qryInsertFamily.ParamByName('display_name').AsString := Trim(edtDisplayName.Text);
      dmPhotoKiosk.qryInsertFamily.ParamByName('phone').AsString := Trim(edtPhone.Text);
      dmPhotoKiosk.qryInsertFamily.ParamByName('email').AsString := Trim(edtEmail.Text);
      dmPhotoKiosk.qryInsertFamily.ParamByName('notes').AsString := memoNotes.Text;
      dmPhotoKiosk.qryInsertFamily.ExecSQL;

      // Get the new ID
      dmPhotoKiosk.qryLastInsertedId.Open;
      FFamilyID := dmPhotoKiosk.qryLastInsertedId.FieldByName('new_id').AsInteger;
      dmPhotoKiosk.qryLastInsertedId.Close;
      FIsNewFamily := False;
    end
    else
    begin
      // For existing family, post the changes through the dataset
      if dmPhotoKiosk.qryFamilyEdit.State in [dsEdit, dsInsert] then
        dmPhotoKiosk.qryFamilyEdit.Post;
    end;

    Result := True;
    ShowMessage('Family saved successfully');
  except
    on E: Exception do
      ShowMessage('Error saving family: ' + E.Message);
  end;
end;

procedure TFrameFamilyEdit.btnSaveClick(Sender: TObject);
begin
  if SaveFamily then
  begin
    // Optionally navigate back to list
    if Assigned(FOnNavigateToList) then
      FOnNavigateToList;
  end;
end;

procedure TFrameFamilyEdit.btnCancelClick(Sender: TObject);
begin
  if dmPhotoKiosk.qryFamilyEdit.State in [dsEdit, dsInsert] then
    dmPhotoKiosk.qryFamilyEdit.Cancel;

  if Assigned(FOnNavigateToList) then
    FOnNavigateToList
  else
    TDialogService.MessageDialog('Discard changes?', TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
        begin
          // Just cancel the edit state
          if dmPhotoKiosk.qryFamilyEdit.Active then
            dmPhotoKiosk.qryFamilyEdit.Close;
        end;
      end);
end;

procedure TFrameFamilyEdit.btnAddPersonClick(Sender: TObject);
begin
  // Must save family first if it's new
  if FIsNewFamily then
  begin
    if not SaveFamily then
      Exit;
  end;

  if Assigned(FOnNavigateToPersonEdit) then
    FOnNavigateToPersonEdit(-1, FFamilyID);  // -1 means new person
end;

procedure TFrameFamilyEdit.btnEditPersonClick(Sender: TObject);
var
  PersonID: Integer;
begin
  PersonID := GetSelectedPersonID;
  if PersonID > 0 then
  begin
    if Assigned(FOnNavigateToPersonEdit) then
      FOnNavigateToPersonEdit(PersonID, FFamilyID);
  end
  else
    ShowMessage('Please select a person to edit');
end;

procedure TFrameFamilyEdit.lvMembersDblClick(Sender: TObject);
begin
  btnEditPersonClick(Sender);
end;

procedure TFrameFamilyEdit.btnBackClick(Sender: TObject);
begin
  if Assigned(FOnNavigateToList) then
    FOnNavigateToList;
end;

end.
