unit Frames.FamilyList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.DialogService, FMX.StdCtrls,
  FMX.Layouts, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Controls.Presentation,
  FMX.Edit, udmPhotoKiosk, Data.DB;

type
  TOnNavigateToFamilyEdit = procedure(FamilyID: Integer) of object;

  TFrameFamilyList = class(TFrame)
    layMain: TLayout;
    layToolbar: TLayout;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    btnRefresh: TButton;
    btnConfigure: TButton;
    btnGenerate: TButton;
    btnImport: TButton;
    laySearch: TLayout;
    lblSearch: TLabel;
    edtSearch: TEdit;
    lvFamilies: TListView;
    procedure btnRefreshClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure lvFamiliesDblClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure btnConfigureClick(Sender: TObject);
  private
    FOnNavigateToFamilyEdit: TOnNavigateToFamilyEdit;
    FOnNavigateToGenerate: TNotifyEvent;
    FOnNavigateToConfigure: TNotifyEvent;
    procedure FilterFamilies(const SearchText: string);
    function GetSelectedFamilyID: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadFamilies;

    property OnNavigateToFamilyEdit: TOnNavigateToFamilyEdit read FOnNavigateToFamilyEdit write FOnNavigateToFamilyEdit;
    property OnNavigateToGenerate: TNotifyEvent read FOnNavigateToGenerate write FOnNavigateToGenerate;
    property OnNavigateToConfigure: TNotifyEvent read FOnNavigateToConfigure write FOnNavigateToConfigure;
  end;

implementation

{$R *.fmx}

uses
  FireDAC.Comp.Client, FireDAC.Stan.Param;

constructor TFrameFamilyList.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TFrameFamilyList.LoadFamilies;
var
  qry: TFDQuery;
  Item: TListViewItem;
begin
  lvFamilies.Items.Clear;
  lvFamilies.BeginUpdate;
  try
    qry := TFDQuery.Create(nil);
    try
      qry.Connection := dmPhotoKiosk.FDConnection;
      qry.SQL.Text := 'SELECT * FROM v_families_by_last_name ORDER BY last_name';
      qry.Open;

      while not qry.Eof do
      begin
        Item := lvFamilies.Items.Add;
        Item.Text := qry.FieldByName('last_name').AsString;
        Item.Detail := qry.FieldByName('parent_names').AsString;
        if not qry.FieldByName('children_names').IsNull then
          Item.Detail := Item.Detail + ' (Children: ' + qry.FieldByName('children_names').AsString + ')';
        Item.Tag := qry.FieldByName('id').AsInteger;
        qry.Next;
      end;
    finally
      qry.Free;
    end;
  finally
    lvFamilies.EndUpdate;
  end;
end;

procedure TFrameFamilyList.FilterFamilies(const SearchText: string);
var
  qry: TFDQuery;
  Item: TListViewItem;
begin
  lvFamilies.Items.Clear;
  lvFamilies.BeginUpdate;
  try
    qry := TFDQuery.Create(nil);
    try
      qry.Connection := dmPhotoKiosk.FDConnection;
      if SearchText <> '' then
      begin
        qry.SQL.Text := 'SELECT * FROM v_families_by_last_name ' +
                        'WHERE last_name LIKE :search ' +
                        'ORDER BY last_name';
        qry.ParamByName('search').AsString := '%' + SearchText + '%';
      end
      else
      begin
        qry.SQL.Text := 'SELECT * FROM v_families_by_last_name ORDER BY last_name';
      end;
      qry.Open;

      while not qry.Eof do
      begin
        Item := lvFamilies.Items.Add;
        Item.Text := qry.FieldByName('last_name').AsString;
        Item.Detail := qry.FieldByName('parent_names').AsString;
        if not qry.FieldByName('children_names').IsNull then
          Item.Detail := Item.Detail + ' (Children: ' + qry.FieldByName('children_names').AsString + ')';
        Item.Tag := qry.FieldByName('id').AsInteger;
        qry.Next;
      end;
    finally
      qry.Free;
    end;
  finally
    lvFamilies.EndUpdate;
  end;
end;

function TFrameFamilyList.GetSelectedFamilyID: Integer;
begin
  Result := -1;
  if Assigned(lvFamilies.Selected) then
    Result := lvFamilies.Selected.Tag;
end;

procedure TFrameFamilyList.btnRefreshClick(Sender: TObject);
begin
  edtSearch.Text := '';
  LoadFamilies;
end;

procedure TFrameFamilyList.btnAddClick(Sender: TObject);
begin
  if Assigned(FOnNavigateToFamilyEdit) then
    FOnNavigateToFamilyEdit(-1);  // -1 means new family
end;

procedure TFrameFamilyList.btnEditClick(Sender: TObject);
var
  FamilyID: Integer;
begin
  FamilyID := GetSelectedFamilyID;
  if FamilyID > 0 then
  begin
    if Assigned(FOnNavigateToFamilyEdit) then
      FOnNavigateToFamilyEdit(FamilyID);
  end
  else
    ShowMessage('Please select a family to edit');
end;

procedure TFrameFamilyList.btnDeleteClick(Sender: TObject);
var
  FamilyID: Integer;
  qry: TFDQuery;
begin
  FamilyID := GetSelectedFamilyID;
  if FamilyID > 0 then
  begin
    TDialogService.MessageDialog('Delete this family and all associated people?',
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
        begin
          qry := TFDQuery.Create(nil);
          try
            qry.Connection := dmPhotoKiosk.FDConnection;
            // Soft delete - set is_active to 0
            qry.SQL.Text := 'UPDATE families SET is_active = 0 WHERE id = :id';
            qry.ParamByName('id').AsInteger := FamilyID;
            qry.ExecSQL;

            // Also soft delete all people in the family
            qry.SQL.Text := 'UPDATE people SET is_active = 0 WHERE family_id = :family_id';
            qry.ParamByName('family_id').AsInteger := FamilyID;
            qry.ExecSQL;

            LoadFamilies;
          finally
            qry.Free;
          end;
        end;
      end);
  end
  else
    ShowMessage('Please select a family to delete');
end;

procedure TFrameFamilyList.edtSearchChange(Sender: TObject);
begin
  FilterFamilies(edtSearch.Text);
end;

procedure TFrameFamilyList.lvFamiliesDblClick(Sender: TObject);
begin
  btnEditClick(Sender);
end;

procedure TFrameFamilyList.btnImportClick(Sender: TObject);
begin
  ShowMessage('Import - Not yet implemented');
end;

procedure TFrameFamilyList.btnGenerateClick(Sender: TObject);
begin
  if Assigned(FOnNavigateToGenerate) then
    FOnNavigateToGenerate(Self);
end;

procedure TFrameFamilyList.btnConfigureClick(Sender: TObject);
begin
  if Assigned(FOnNavigateToConfigure) then
    FOnNavigateToConfigure(Self);
end;

end.
