program PhotoKiosMgr;

uses
  System.StartUpCopy,
  FMX.Forms,
  ufrmPhotoKioskMgrMain in 'ufrmPhotoKioskMgrMain.pas' {frmPhotoKioskMgrMain},
  udmPhotoKiosk in 'udmPhotoKiosk.pas' {dmPhotoKiosk: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmPhotoKiosk, dmPhotoKiosk);
  Application.CreateForm(TfrmPhotoKioskMgrMain, frmPhotoKioskMgrMain);
  Application.Run;
end.
