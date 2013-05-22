unit testcasesimple;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  { TSimpleTestCase }

  TSimpleTestCase = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure InsertNewLoadExisting;
    procedure InsertNewSaveLoadEditSaveLoad;
    procedure LoadNotExisting;
    procedure Reset;
  end;

implementation

uses
  ghSQL, ghSQLdbLib, ghorm, models;

const
  DBFileName = 'test.db';
  ScriptName = 'test.sql';

procedure TSimpleTestCase.InsertNewLoadExisting;
var
  u: TUser;
  id: Integer;
begin
  id := AddUser('Mario',25,'25-03-88'); // take the auto increment id value

  u := TUser.Create(id);

  AssertEquals(u.Name,'Mario');
  AssertEquals(u.Age,24);
  AssertEquals(u.Birthdate,'25-03-88');

  u.Free;
end;

procedure TSimpleTestCase.InsertNewSaveLoadEditSaveLoad;
var
  id: objpas.Integer;
  u: TUser;
begin
  id := AddUser('Mario',25,'25-03-88'); // take the auto increment id value

  // load
  u := TUser.Create(id);
  // edit
  u.Name := 'Marijan';
  u.Age := 72;
  u.Birthdate := '1-1-99';
  u.Save;
  // reset
  u.Load(id);

  AssertEquals(u.Name,'Marijan');
  AssertEquals(u.Age,72);
  AssertEquals(u.Birthdate,'1-1-99');

  u.Free;
end;

procedure TSimpleTestCase.LoadNotExisting;
var
  u: TUser;
begin
  try
    u := TUser.Create(255);
  except
    on e: EghSQLError do
      Exit;
    on e: Exception do
      Fail('Unexpected ' + e.ClassName + ': ' + e.Message);
  end;
  Fail('Exception expected');
end;

procedure TSimpleTestCase.Reset;
var
  u: TUser;
  id: Integer;
begin
  id := AddUser('Mario',25,'25-03-88'); // take the auto increment id value

  // load
  u := TUser.Create(id);
  // edit
  u.Name := 'Marijan';
  u.Age := 72;
  u.Birthdate := '1-1-99';
  // reset
  u.Load(id);

  AssertEquals(u.Name,'Mario');
  AssertEquals(u.Age,24);
  AssertEquals(u.Birthdate,'25-03-88');

  u.Free;
end;

procedure TSimpleTestCase.SetUp;
begin
  SetConnection(TghSQLite3Lib,DBFileName);
  with TghSQLClient.Create(GetConnection) do
    try
      Clear;
      IsBatch := true;
      Script.LoadFromFile(ScriptName);
      Execute;
    finally
      Free;
    end;
end;

procedure TSimpleTestCase.TearDown;
var
  t: TghSQLTable;
begin
  t := GetConnection.Tables['user'].Open;
  while not t.EOF do begin
    t.Delete;
    t.Next;
  end;
  t.Commit;
  DeleteFile(DBFileName);
end;

initialization
  RegisterTest(TSimpleTestCase);

end.

