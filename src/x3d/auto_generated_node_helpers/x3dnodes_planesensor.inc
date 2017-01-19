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
    function GetAxisRotation: TVector4Single;
    procedure SetAxisRotation(const Value: TVector4Single);
    function GetMaxPosition: TVector2Single;
    procedure SetMaxPosition(const Value: TVector2Single);
    function GetMinPosition: TVector2Single;
    procedure SetMinPosition(const Value: TVector2Single);
    function GetOffset: TVector3Single;
    procedure SetOffset(const Value: TVector3Single);
  public
    property AxisRotation: TVector4Single read GetAxisRotation write SetAxisRotation;
    property MaxPosition: TVector2Single read GetMaxPosition write SetMaxPosition;
    property MinPosition: TVector2Single read GetMinPosition write SetMinPosition;
    property Offset: TVector3Single read GetOffset write SetOffset;

{$endif read_interface}

{$ifdef read_implementation}

{ TPlaneSensorNode ----------------------------------------------- }

function TPlaneSensorNode.GetAxisRotation: TVector4Single;
begin
  Result := FdAxisRotation.Value;
end;

procedure TPlaneSensorNode.SetAxisRotation(const Value: TVector4Single);
begin
  FdAxisRotation.Send(Value);
end;

function TPlaneSensorNode.GetMaxPosition: TVector2Single;
begin
  Result := FdMaxPosition.Value;
end;

procedure TPlaneSensorNode.SetMaxPosition(const Value: TVector2Single);
begin
  FdMaxPosition.Send(Value);
end;

function TPlaneSensorNode.GetMinPosition: TVector2Single;
begin
  Result := FdMinPosition.Value;
end;

procedure TPlaneSensorNode.SetMinPosition(const Value: TVector2Single);
begin
  FdMinPosition.Send(Value);
end;

function TPlaneSensorNode.GetOffset: TVector3Single;
begin
  Result := FdOffset.Value;
end;

procedure TPlaneSensorNode.SetOffset(const Value: TVector3Single);
begin
  FdOffset.Send(Value);
end;

{$endif read_implementation}