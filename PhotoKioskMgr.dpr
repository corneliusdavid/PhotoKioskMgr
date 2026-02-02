program PhotoKioskMgr;

uses
  System.StartUpCopy,
  FMX.Forms, System.SysUtils,
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
  try
    Application.CreateForm(TdmPhotoKiosk, dmPhotoKiosk);
    Application.CreateForm(TfrmPhotoKioskMgrMain, frmPhotoKioskMgrMain);
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      Halt(1);
    end;
  end;
  Application.Run;
end.
