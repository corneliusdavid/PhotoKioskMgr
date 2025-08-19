unit udmPhotoKiosk;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Phys.SQLiteWrapper.Stat;

type
  TdmPhotoKiosk = class(TDataModule)
    FDConnection: TFDConnection;
    qryFamilyMembers: TFDQuery;
    qryFirstNameView: TFDQuery;
    qryLastNameView: TFDQuery;
    qryNavFirstNameLetters: TFDQuery;
    qryPersonPhotos: TFDQuery;
    qryNavLastNameLetters: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FDatabasePath: string;
    function GetDatabasePath: string;
    procedure SetupConnection;
    procedure CreateDatabaseIfNeeded;
    procedure ExecuteCreationScripts;
  public
    property DatabasePath: string read FDatabasePath write FDatabasePath;

    // Data access methods
    procedure OpenFirstNameView;
    procedure OpenLastNameView;
    procedure OpenFamilyMembers(FamilyID: Integer);
    procedure OpenPersonPhotos(PersonID: Integer);

    // Database maintenance
    procedure BackupDatabase(const BackupPath: string);
    procedure CompactDatabase;
    function TestConnection: Boolean;
  end;

var
  dmPhotoKiosk: TdmPhotoKiosk;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TdmPhotoKiosk.DataModuleCreate(Sender: TObject);
begin
  FDatabasePath := GetDatabasePath;
  SetupConnection;
  CreateDatabaseIfNeeded;
end;

procedure TdmPhotoKiosk.DataModuleDestroy(Sender: TObject);
begin
  FDConnection.Close;
end;

function TdmPhotoKiosk.GetDatabasePath: string;
begin
  // Cross-platform database location
  Result := TPath.Combine(TPath.GetDocumentsPath, 'PhotoKiosk');

  // Ensure directory exists
  if not TDirectory.Exists(Result) then
    TDirectory.CreateDirectory(Result);

  Result := TPath.Combine(Result, 'PhotoKiosk.db');
end;

procedure TdmPhotoKiosk.SetupConnection;
begin
  FDConnection.Params.Clear;
  FDConnection.Params.Add('Database=' + FDatabasePath);
  FDConnection.Params.Add('DriverID=SQLite');
  FDConnection.Params.Add('LockingMode=Normal');
  FDConnection.Params.Add('Synchronous=Normal');
  FDConnection.Params.Add('JournalMode=WAL');
  FDConnection.Params.Add('ForeignKeys=True');
end;

procedure TdmPhotoKiosk.OpenFirstNameView;
begin
  if qryLastNameView.Active then
    qryLastNameView.Close;

  qryFirstNameView.Open;
end;

procedure TdmPhotoKiosk.OpenLastNameView;
begin
  if qryFirstNameView.Active then
    qryFirstNameView.Close;

  qryLastNameView.Open;
end;

procedure TdmPhotoKiosk.OpenFamilyMembers(FamilyID: Integer);
begin
  qryFamilyMembers.Close;
  qryFamilyMembers.ParamByName('family_id').AsInteger := FamilyID;
  qryFamilyMembers.Open;
end;

procedure TdmPhotoKiosk.OpenPersonPhotos(PersonID: Integer);
begin
  qryPersonPhotos.Close;
  qryPersonPhotos.ParamByName('person_id').AsInteger := PersonID;
  qryPersonPhotos.Open;
end;

procedure TdmPhotoKiosk.CreateDatabaseIfNeeded;
begin
  if not TFile.Exists(FDatabasePath) then
  begin
    // Database doesn't exist, opening it will create the SQLite .db file
    try
      FDConnection.Open;

      ExecuteCreationScripts;
    except
      on e:Exception do
        raise Exception.Create('Failed to create database: ' + e.Message);
    end;

    FDConnection.Connected := False;
  end;
end;

procedure TdmPhotoKiosk.BackupDatabase(const BackupPath: string);
begin
  if FDConnection.Connected then
    FDConnection.Open;

  try
    TFile.Copy(FDatabasePath, BackupPath, True);
  finally
    FDConnection.Connected := True;
  end;
end;

procedure TdmPhotoKiosk.CompactDatabase;
begin
  if not FDConnection.Connected then
    FDConnection.Open;

  FDConnection.ExecSQL('VACUUM');
end;

function TdmPhotoKiosk.TestConnection: Boolean;
begin
  try
    if not FDConnection.Connected then
      FDConnection.Open;
    Result := FDConnection.Connected;
  except
    Result := False;
  end;
end;

procedure TdmPhotoKiosk.ExecuteCreationScripts;
{-- fill these from photokiosk_schema.sql --}
begin
  // Main families table - one record per household/family unit
  FDConnection.ExecSQL('''
  CREATE TABLE families (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    last_name TEXT NOT NULL,
    display_name TEXT,  -- Optional: "Smith Family", "The Johnsons", etc.
    photo_filename TEXT, -- Family photo if available
    phone TEXT,
    email TEXT,
    notes TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_date DATETIME DEFAULT (DATETIME('now')),
    modified_date DATETIME DEFAULT (DATETIME('now'))
  );
''');

  // Individual people - multiple records per family
  FDConnection.ExecSQL('''
  CREATE TABLE people (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    last_name TEXT, -- Usually same as family.last_name but allows for step-families, etc.
    full_name TEXT GENERATED ALWAYS AS (
        CASE
            WHEN middle_name IS NOT NULL AND middle_name != ''
            THEN first_name || ' ' || middle_name || ' ' || last_name
            ELSE first_name || ' ' || last_name
        END
    ) STORED,
    is_parent BOOLEAN DEFAULT 0,
    birth_year INTEGER, -- Year only for privacy
    photo_filename TEXT,
    sort_order INTEGER DEFAULT 0, -- For custom ordering within family
    is_active BOOLEAN DEFAULT 1,
    created_date DATETIME DEFAULT (DATETIME('now')),
    modified_date DATETIME DEFAULT (DATETIME('now')),

    FOREIGN KEY (family_id) REFERENCES families(id)
  );
''');

  	// Photo metadata table - tracks all photos and their usage
    FDConnection.ExecSQL('''
  CREATE TABLE photos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT UNIQUE NOT NULL,
    original_filename TEXT, -- In case file gets renamed
    file_size INTEGER,
    width INTEGER,
    height INTEGER,
    thumbnail_filename TEXT, -- Generated thumbnail
    photo_date DATE,
    description TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_date DATETIME DEFAULT (DATETIME('now'))
  );
''');

  // Link table for people who appear in multiple photos
  FDConnection.ExecSQL('''
  CREATE TABLE person_photos (
    person_id INTEGER,
    photo_id INTEGER,
    is_primary BOOLEAN DEFAULT 0, -- Is this the person's main photo?
    created_date DATETIME DEFAULT (DATETIME('now')),

    FOREIGN KEY (person_id) REFERENCES people(id),
    FOREIGN KEY (photo_id) REFERENCES photos(id),
    PRIMARY KEY (person_id, photo_id)
  );
''');

  // Indexes for performance
  FDConnection.ExecSQL('CREATE INDEX idx_families_last_name ON families(last_name);');
  FDConnection.ExecSQL('CREATE INDEX idx_people_family_id ON people(family_id);');
  FDConnection.ExecSQL('CREATE INDEX idx_people_first_name ON people(first_name);');
  FDConnection.ExecSQL('CREATE INDEX idx_people_last_name ON people(last_name);');
  FDConnection.ExecSQL('CREATE INDEX idx_people_full_name ON people(full_name);');
  FDConnection.ExecSQL('CREATE INDEX idx_people_is_parent ON people(is_parent);');
  FDConnection.ExecSQL('CREATE INDEX idx_photos_filename ON photos(filename);');

  // View for FirstName sorting (each person individually)
  FDConnection.ExecSQL('''
  CREATE VIEW v_people_by_first_name AS
  SELECT
    p.id,
    p.first_name,
    p.last_name,
    p.full_name,
    p.photo_filename,
    f.last_name as family_name,
    f.photo_filename as family_photo,
    p.is_parent,
    UPPER(SUBSTR(p.first_name, 1, 1)) as first_letter
  FROM people p
  JOIN families f ON p.family_id = f.id
  WHERE p.is_active = 1 AND f.is_active = 1
  ORDER BY p.first_name, p.last_name;
''');

  // View for LastName sorting (family units)
  FDConnection.ExecSQL('''
  CREATE VIEW v_families_by_last_name AS
  SELECT
    f.id,
    f.last_name,
    f.display_name,
    f.photo_filename,
    -- Concatenate all family member names
    GROUP_CONCAT(
        CASE WHEN p.is_parent = 1 THEN p.first_name END,
        ' & '
    ) as parent_names,
    GROUP_CONCAT(
        CASE WHEN p.is_parent = 0 THEN p.first_name END,
        ', '
    ) as children_names,
    COUNT(p.id) as member_count,
    UPPER(SUBSTR(f.last_name, 1, 1)) as first_letter
  FROM families f
  LEFT JOIN people p ON f.id = p.family_id AND p.is_active = 1
  WHERE f.is_active = 1
  GROUP BY f.id, f.last_name, f.display_name, f.photo_filename
  ORDER BY f.last_name;
''');

  // Triggers to update modified_date
  FDConnection.ExecSQL('''
  CREATE TRIGGER tr_families_modified
    AFTER UPDATE ON families
    FOR EACH ROW
    WHEN OLD.modified_date = NEW.modified_date
  BEGIN
    UPDATE families SET modified_date = DATETIME('now') WHERE id = NEW.id;
  END;
''');

  FDConnection.ExecSQL('''
  CREATE TRIGGER tr_people_modified
    AFTER UPDATE ON people
    FOR EACH ROW
    WHEN OLD.modified_date = NEW.modified_date
  BEGIN
    UPDATE people SET modified_date = DATETIME('now') WHERE id = NEW.id;
  END;
''');
end;

end.