program PhotoKioskMgr;

uses
  System.StartUpCopy,
  FMX.Forms,
  ufrmPhotoKioskMgrMain in 'ufrmPhotoKioskMgrMain.pas' {frmPhotoKioskMgrMain},
  udmPhotoKiosk in 'udmPhotoKiosk.pas' {dmPhotoKiosk: TDataModule},
  Frames.Configure in 'Frames.Configure.pas' {FrameConfigure: TFrame},
  Frames.FamilyEdit in 'Frames.FamilyEdit.pas' {FrameFamilyEdit: TFrame},
  Frames.FamilyList in 'Frames.FamilyList.pas' {FrameFamilyList: TFrame},
  Frames.Generate in 'Frames.Generate.pas' {FrameGenerate: TFrame},
  Frames.PersonEdit in 'Frames.PersonEdit.pas' {FramePersonEdit: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmPhotoKiosk, dmPhotoKiosk);
  Application.CreateForm(TfrmPhotoKioskMgrMain, frmPhotoKioskMgrMain);
  Application.Run;
end.
