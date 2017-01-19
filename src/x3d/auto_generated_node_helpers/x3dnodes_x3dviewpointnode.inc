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
    function GetCenterOfRotation: TVector3Single;
    procedure SetCenterOfRotation(const Value: TVector3Single);
    function GetDescription: string;
    procedure SetDescription(const Value: string);
    function GetJump: boolean;
    procedure SetJump(const Value: boolean);
    function GetRetainUserOffsets: boolean;
    procedure SetRetainUserOffsets(const Value: boolean);
    function GetCameraMatrixSendAlsoOnOffscreenRendering: boolean;
    procedure SetCameraMatrixSendAlsoOnOffscreenRendering(const Value: boolean);
    function GetGravityUp: TVector3Single;
    procedure SetGravityUp(const Value: TVector3Single);
  public
    property CenterOfRotation: TVector3Single read GetCenterOfRotation write SetCenterOfRotation;
    property Description: string read GetDescription write SetDescription;
    property Jump: boolean read GetJump write SetJump;
    property RetainUserOffsets: boolean read GetRetainUserOffsets write SetRetainUserOffsets;
    property CameraMatrixSendAlsoOnOffscreenRendering: boolean read GetCameraMatrixSendAlsoOnOffscreenRendering write SetCameraMatrixSendAlsoOnOffscreenRendering;
    property GravityUp: TVector3Single read GetGravityUp write SetGravityUp;

{$endif read_interface}

{$ifdef read_implementation}

{ TAbstractX3DViewpointNode ----------------------------------------------- }

function TAbstractX3DViewpointNode.GetCenterOfRotation: TVector3Single;
begin
  Result := FdCenterOfRotation.Value;
end;

procedure TAbstractX3DViewpointNode.SetCenterOfRotation(const Value: TVector3Single);
begin
  FdCenterOfRotation.Send(Value);
end;

function TAbstractX3DViewpointNode.GetDescription: string;
begin
  Result := FdDescription.Value;
end;

procedure TAbstractX3DViewpointNode.SetDescription(const Value: string);
begin
  FdDescription.Send(Value);
end;

function TAbstractX3DViewpointNode.GetJump: boolean;
begin
  Result := FdJump.Value;
end;

procedure TAbstractX3DViewpointNode.SetJump(const Value: boolean);
begin
  FdJump.Send(Value);
end;

function TAbstractX3DViewpointNode.GetRetainUserOffsets: boolean;
begin
  Result := FdRetainUserOffsets.Value;
end;

procedure TAbstractX3DViewpointNode.SetRetainUserOffsets(const Value: boolean);
begin
  FdRetainUserOffsets.Send(Value);
end;

function TAbstractX3DViewpointNode.GetCameraMatrixSendAlsoOnOffscreenRendering: boolean;
begin
  Result := FdCameraMatrixSendAlsoOnOffscreenRendering.Value;
end;

procedure TAbstractX3DViewpointNode.SetCameraMatrixSendAlsoOnOffscreenRendering(const Value: boolean);
begin
  FdCameraMatrixSendAlsoOnOffscreenRendering.Send(Value);
end;

function TAbstractX3DViewpointNode.GetGravityUp: TVector3Single;
begin
  Result := FdGravityUp.Value;
end;

procedure TAbstractX3DViewpointNode.SetGravityUp(const Value: TVector3Single);
begin
  FdGravityUp.Send(Value);
end;

{$endif read_implementation}