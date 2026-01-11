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
    FFamilyListInfo: TFrameInfo<TFrameFamilyList>;
    FFamilyEditInfo: TFrameInfo<TFrameFamilyEdit>;
    FPersonEditInfo: TFrameInfo<TFramePersonEdit>;
    FGenerateInfo: TFrameInfo<TFrameGenerate>;
    FConfigureInfo: TFrameInfo<TFrameConfigure>;

    procedure LoadFrames;
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
  // Set default tab
  MainTabs.ActiveTab := tabList;

  // Load all frames
  LoadFrames;

  // Show the initial frame
  ShowFamilyList;
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
  FFamilyListInfo.Show();
end;

procedure TfrmPhotoKioskMgrMain.ShowFamilyEdit;
begin
  FFamilyEditInfo.Show();
end;

procedure TfrmPhotoKioskMgrMain.ShowPersonEdit;
begin
  FPersonEditInfo.Show();
end;

procedure TfrmPhotoKioskMgrMain.ShowGenerate;
begin
  FGenerateInfo.Show();
end;

procedure TfrmPhotoKioskMgrMain.ShowConfigure;
begin
  FConfigureInfo.Show();
end;

end.
