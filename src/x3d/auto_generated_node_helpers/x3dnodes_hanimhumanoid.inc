{ -*- buffer-read-only: t -*-

  Copyright 2015-2017 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Automatically generated X3D node class helpers.
  Do not edit manually, instead regenerate using
  castle_game_engine/src/x3d/doc/generate_x3d_nodes_to_pascal.lpr . }

{$ifdef read_interface}

  private
    function GetCenter: TVector3Single;
    procedure SetCenter(const Value: TVector3Single);
    function GetNameField: string;
    procedure SetNameField(const Value: string);
    function GetRotation: TVector4Single;
    procedure SetRotation(const Value: TVector4Single);
    function GetScale: TVector3Single;
    procedure SetScale(const Value: TVector3Single);
    function GetScaleOrientation: TVector4Single;
    procedure SetScaleOrientation(const Value: TVector4Single);
    function GetTranslation: TVector3Single;
    procedure SetTranslation(const Value: TVector3Single);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetBboxCenter: TVector3Single;
    procedure SetBboxCenter(const Value: TVector3Single);
    function GetBboxSize: TVector3Single;
    procedure SetBboxSize(const Value: TVector3Single);
  public
    property Center: TVector3Single read GetCenter write SetCenter;
    property NameField: string read GetNameField write SetNameField;
    property Rotation: TVector4Single read GetRotation write SetRotation;
    property Scale: TVector3Single read GetScale write SetScale;
    property ScaleOrientation: TVector4Single read GetScaleOrientation write SetScaleOrientation;
    property Translation: TVector3Single read GetTranslation write SetTranslation;
    property Version: string read GetVersion write SetVersion;
    property BboxCenter: TVector3Single read GetBboxCenter write SetBboxCenter;
    property BboxSize: TVector3Single read GetBboxSize write SetBboxSize;

{$endif read_interface}

{$ifdef read_implementation}

{ THAnimHumanoidNode ----------------------------------------------- }

function THAnimHumanoidNode.GetCenter: TVector3Single;
begin
  Result := FdCenter.Value;
end;

procedure THAnimHumanoidNode.SetCenter(const Value: TVector3Single);
begin
  FdCenter.Send(Value);
end;

function THAnimHumanoidNode.GetNameField: string;
begin
  Result := FdName.Value;
end;

procedure THAnimHumanoidNode.SetNameField(const Value: string);
begin
  FdName.Send(Value);
end;

function THAnimHumanoidNode.GetRotation: TVector4Single;
begin
  Result := FdRotation.Value;
end;

procedure THAnimHumanoidNode.SetRotation(const Value: TVector4Single);
begin
  FdRotation.Send(Value);
end;

function THAnimHumanoidNode.GetScale: TVector3Single;
begin
  Result := FdScale.Value;
end;

procedure THAnimHumanoidNode.SetScale(const Value: TVector3Single);
begin
  FdScale.Send(Value);
end;

function THAnimHumanoidNode.GetScaleOrientation: TVector4Single;
begin
  Result := FdScaleOrientation.Value;
end;

procedure THAnimHumanoidNode.SetScaleOrientation(const Value: TVector4Single);
begin
  FdScaleOrientation.Send(Value);
end;

function THAnimHumanoidNode.GetTranslation: TVector3Single;
begin
  Result := FdTranslation.Value;
end;

procedure THAnimHumanoidNode.SetTranslation(const Value: TVector3Single);
begin
  FdTranslation.Send(Value);
end;

function THAnimHumanoidNode.GetVersion: string;
begin
  Result := FdVersion.Value;
end;

procedure THAnimHumanoidNode.SetVersion(const Value: string);
begin
  FdVersion.Send(Value);
end;

function THAnimHumanoidNode.GetBboxCenter: TVector3Single;
begin
  Result := FdBboxCenter.Value;
end;

procedure THAnimHumanoidNode.SetBboxCenter(const Value: TVector3Single);
begin
  FdBboxCenter.Send(Value);
end;

function THAnimHumanoidNode.GetBboxSize: TVector3Single;
begin
  Result := FdBboxSize.Value;
end;

procedure THAnimHumanoidNode.SetBboxSize(const Value: TVector3Single);
begin
  FdBboxSize.Send(Value);
end;

{$endif read_implementation}