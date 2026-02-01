unit ufrmPhotoKioskMgrMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Layouts, FrameStand, SubjectStand,
  Frames.FamilyList, Frames.FamilyEdit, Frames.PersonEdit,
  Frames.Generate, Frames.Configure, udmPhotoKiosk;

type
  TfrmPhotoKioskMgrMain = class(TForm)
    MainTabs: TTabControl;
    tabList: TTabItem;
    tabEditFamily: TTabItem;
    tabEditPerson: TTabItem;
    tabGenerate: TTabItem;
    tabConfigure: TTabItem;
    FrameStand1: TFrameStand;
    layListContainer: TLayout;
    layEditFamilyContainer: TLayout;
    layEditPersonContainer: TLayout;
    layGenerateContainer: TLayout;
    layConfigureContainer: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MainTabsChange(Sender: TObject);
  private
    FCreating: Boolean;
    FFamilyListInfo: TFrameInfo<TFrameFamilyList>;
    FFamilyEditInfo: TFrameInfo<TFrameFamilyEdit>;
    FPersonEditInfo: TFrameInfo<TFramePersonEdit>;
    FGenerateInfo: TFrameInfo<TFrameGenerate>;
    FConfigureInfo: TFrameInfo<TFrameConfigure>;

    procedure LoadFrames;
    procedure SetupNavigationCallbacks;

    // Navigation callback handlers
    procedure HandleNavigateToFamilyEdit(FamilyID: Integer);
    procedure HandleNavigateToPersonEdit(PersonID: Integer; FamilyID: Integer);
    procedure HandleNavigateToFamilyList;
    procedure HandleNavigateBackFromPersonEdit(FamilyID: Integer);
    procedure HandleNavigateToGenerate(Sender: TObject);
    procedure HandleNavigateToConfigure(Sender: TObject);
    procedure HandleNavigateToListFromFrame(Sender: TObject);

    procedure ShowFamilyList;
    procedure ShowFamilyEdit;
    procedure ShowPersonEdit;
    procedure ShowGenerate;
    procedure ShowConfigure;
  public
    { Public declarations }
  end;

var
  frmPhotoKioskMgrMain: TfrmPhotoKioskMgrMain;

implementation

{$R *.fmx}

procedure TfrmPhotoKioskMgrMain.FormCreate(Sender: TObject);
begin
  FCreating := True;

  // Set default tab
  MainTabs.ActiveTab := tabList;

  // Load all frames
  LoadFrames;

  // Setup navigation callbacks between frames
  SetupNavigationCallbacks;

  FCreating := False;

  // Show the initial frame and load data
  FFamilyListInfo.Show();
  FFamilyListInfo.Frame.LoadFamilies;
end;

procedure TfrmPhotoKioskMgrMain.FormDestroy(Sender: TObject);
begin
  // Frames will be automatically freed by TFrameStand
end;

procedure TfrmPhotoKioskMgrMain.LoadFrames;
begin
  // Create frame instances (but don't show them yet)
  FFamilyListInfo := FrameStand1.New<TFrameFamilyList>(layListContainer);
  FFamilyEditInfo := FrameStand1.New<TFrameFamilyEdit>(layEditFamilyContainer);
  FPersonEditInfo := FrameStand1.New<TFramePersonEdit>(layEditPersonContainer);
  FGenerateInfo := FrameStand1.New<TFrameGenerate>(layGenerateContainer);
  FConfigureInfo := FrameStand1.New<TFrameConfigure>(layConfigureContainer);
end;

procedure TfrmPhotoKioskMgrMain.SetupNavigationCallbacks;
begin
  // FamilyList -> FamilyEdit navigation
  FFamilyListInfo.Frame.OnNavigateToFamilyEdit := HandleNavigateToFamilyEdit;

  // FamilyEdit -> FamilyList and -> PersonEdit navigation
  FFamilyEditInfo.Frame.OnNavigateToList := HandleNavigateToFamilyList;
  FFamilyEditInfo.Frame.OnNavigateToPersonEdit := HandleNavigateToPersonEdit;

  // PersonEdit -> FamilyEdit navigation
  FPersonEditInfo.Frame.OnNavigateBack := HandleNavigateBackFromPersonEdit;

  // FamilyList -> Generate and Configure navigation
  FFamilyListInfo.Frame.OnNavigateToGenerate := HandleNavigateToGenerate;
  FFamilyListInfo.Frame.OnNavigateToConfigure := HandleNavigateToConfigure;

  // Back to list navigation from PersonEdit, Generate, Configure
  FPersonEditInfo.Frame.OnNavigateToList := HandleNavigateToListFromFrame;
  FGenerateInfo.Frame.OnNavigateToList := HandleNavigateToListFromFrame;
  FConfigureInfo.Frame.OnNavigateToList := HandleNavigateToListFromFrame;
end;

procedure TfrmPhotoKioskMgrMain.HandleNavigateToFamilyEdit(FamilyID: Integer);
begin
  if FamilyID > 0 then
    FFamilyEditInfo.Frame.EditFamily(FamilyID)
  else
    FFamilyEditInfo.Frame.NewFamily;

  MainTabs.ActiveTab := tabEditFamily;
end;

procedure TfrmPhotoKioskMgrMain.HandleNavigateToPersonEdit(PersonID: Integer; FamilyID: Integer);
begin
  // Refresh the families list in the person edit frame
  FPersonEditInfo.Frame.RefreshFamilies;

  if PersonID > 0 then
    FPersonEditInfo.Frame.EditPerson(PersonID)
  else
    FPersonEditInfo.Frame.NewPerson(FamilyID);

  MainTabs.ActiveTab := tabEditPerson;
end;

procedure TfrmPhotoKioskMgrMain.HandleNavigateToFamilyList;
begin
  // Refresh the family list when returning
  FFamilyListInfo.Frame.LoadFamilies;
  MainTabs.ActiveTab := tabList;
end;

procedure TfrmPhotoKioskMgrMain.HandleNavigateBackFromPersonEdit(FamilyID: Integer);
begin
  // Return to family edit and refresh the members list
  if FamilyID > 0 then
  begin
    FFamilyEditInfo.Frame.EditFamily(FamilyID);
    MainTabs.ActiveTab := tabEditFamily;
  end
  else
  begin
    // If no family, go back to list
    HandleNavigateToFamilyList;
  end;
end;

procedure TfrmPhotoKioskMgrMain.HandleNavigateToGenerate(Sender: TObject);
begin
  MainTabs.ActiveTab := tabGenerate;
end;

procedure TfrmPhotoKioskMgrMain.HandleNavigateToConfigure(Sender: TObject);
begin
  MainTabs.ActiveTab := tabConfigure;
end;

procedure TfrmPhotoKioskMgrMain.HandleNavigateToListFromFrame(Sender: TObject);
begin
  FFamilyListInfo.Frame.LoadFamilies;
  MainTabs.ActiveTab := tabList;
end;

procedure TfrmPhotoKioskMgrMain.MainTabsChange(Sender: TObject);
begin
  // Show the appropriate frame based on selected tab
  case MainTabs.TabIndex of
    0: ShowFamilyList;
    1: ShowFamilyEdit;
    2: ShowPersonEdit;
    3: ShowGenerate;
    4: ShowConfigure;
  end;
end;

procedure TfrmPhotoKioskMgrMain.ShowFamilyList;
begin
  if not FCreating then
    FFamilyListInfo.Show();
end;

procedure TfrmPhotoKioskMgrMain.ShowFamilyEdit;
begin
  if not FCreating then
    FFamilyEditInfo.Show();
end;

procedure TfrmPhotoKioskMgrMain.ShowPersonEdit;
begin
  if not FCreating then
    FPersonEditInfo.Show();
end;

procedure TfrmPhotoKioskMgrMain.ShowGenerate;
begin
  if not FCreating then
    FGenerateInfo.Show();
end;

procedure TfrmPhotoKioskMgrMain.ShowConfigure;
begin
  if not FCreating then
    FConfigureInfo.Show();
end;

end.
