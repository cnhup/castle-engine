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
    function GetHeadlight: boolean;
    procedure SetHeadlight(const Value: boolean);
    function GetSpeed: Single;
    procedure SetSpeed(const Value: Single);
    function GetTransitionTime: TFloatTime;
    procedure SetTransitionTime(const Value: TFloatTime);
    function GetVisibilityLimit: Single;
    procedure SetVisibilityLimit(const Value: Single);
  public
    property Headlight: boolean read GetHeadlight write SetHeadlight;
    property Speed: Single read GetSpeed write SetSpeed;
    property TransitionTime: TFloatTime read GetTransitionTime write SetTransitionTime;
    property VisibilityLimit: Single read GetVisibilityLimit write SetVisibilityLimit;

{$endif read_interface}

{$ifdef read_implementation}

{ TNavigationInfoNode ----------------------------------------------- }

function TNavigationInfoNode.GetHeadlight: boolean;
begin
  Result := FdHeadlight.Value;
end;

procedure TNavigationInfoNode.SetHeadlight(const Value: boolean);
begin
  FdHeadlight.Send(Value);
end;

function TNavigationInfoNode.GetSpeed: Single;
begin
  Result := FdSpeed.Value;
end;

procedure TNavigationInfoNode.SetSpeed(const Value: Single);
begin
  FdSpeed.Send(Value);
end;

function TNavigationInfoNode.GetTransitionTime: TFloatTime;
begin
  Result := FdTransitionTime.Value;
end;

procedure TNavigationInfoNode.SetTransitionTime(const Value: TFloatTime);
begin
  FdTransitionTime.Send(Value);
end;

function TNavigationInfoNode.GetVisibilityLimit: Single;
begin
  Result := FdVisibilityLimit.Value;
end;

procedure TNavigationInfoNode.SetVisibilityLimit(const Value: Single);
begin
  FdVisibilityLimit.Send(Value);
end;

{$endif read_implementation}