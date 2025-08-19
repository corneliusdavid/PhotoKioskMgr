object dmPhotoKiosk: TdmPhotoKiosk
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 372
  Width = 582
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 72
    Top = 40
  end
  object qryFamilyMembers: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      
        'SELECT id, first_name, last_name, full_name, is_parent, birth_ye' +
        'ar, photo_filename'
      'FROM people WHERE family_id = :family_id AND is_active = 1'
      'ORDER BY is_parent DESC, sort_order, first_name')
    Left = 248
    Top = 152
    ParamData = <
      item
        Name = 'FAMILY_ID'
        ParamType = ptInput
      end>
  end
  object qryFirstNameView: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      
        'SELECT * FROM v_people_by_first_name ORDER BY first_name, last_n' +
        'ame')
    Left = 72
    Top = 120
  end
  object qryLastNameView: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM v_families_by_last_name ORDER BY last_name')
    Left = 72
    Top = 192
  end
  object qryNavFirstNameLetters: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT DISTINCT first_letter '
      'FROM v_people_by_first_name '
      'ORDER BY first_letter')
    Left = 432
    Top = 96
  end
  object qryPersonPhotos: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      
        'SELECT ph.filename, ph.thumbnail_filename, ph.description, pp.is' +
        '_primary'
      'FROM person_photos pp'
      'JOIN photos ph ON pp.photo_id = ph.id'
      'WHERE pp.person_id = :person_id'
      'ORDER BY pp.is_primary DESC, ph.filename')
    Left = 272
    Top = 224
    ParamData = <
      item
        Name = 'PERSON_ID'
        ParamType = ptInput
      end>
  end
  object qryNavLastNameLetters: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT DISTINCT first_letter '
      'FROM v_families_by_last_name '
      'ORDER BY first_letter')
    Left = 432
    Top = 160
  end
end
