{
  Copyright 2006,2007 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ This unit provides utilities for making TGLMenu items to control
  TGameSoundEngine. }
unit GLSoundMenu;

interface

uses GLWindow, GLMenu, GameSoundEngine;

type
  { For now, this class is used only as an abstract class for
    GLSoundMenu items. In the future maybe such idea will be incorporated
    into GLMenu unit. }
  TGLMenuItem = class
  private
    FGlwin: TGLWindow;
  protected
    property Glwin: TGLWindow read FGlwin;
  public
    { Creates and adds this menu item to Menu. }
    constructor Create(AGlwin: TGLWindow; Menu: TGLMenu);
    function Title: string; virtual; abstract;
    function Accessory: TGLMenuItemAccessory; virtual;
    procedure Selected; virtual;
    procedure AccessoryValueChanged; virtual;
  end;

  TGLSoundMenuItem = class(TGLMenuItem)
  private
    FSoundEngine: TGameSoundEngine;
  protected
    property SoundEngine: TGameSoundEngine read FSoundEngine;
  public
    constructor Create(AGlwin: TGLWindow; Menu: TGLMenu;
      ASoundEngine: TGameSoundEngine);
  end;

  TGLSoundInfoMenuItem = class(TGLSoundMenuItem)
  public
    function Title: string; override;
    procedure Selected; override;
  end;

  { Small modification of TGLMenuFloatSlider especially suited for
    configuring sound volume: range is from 0 to 1 always, and
    when the slider is exactly on 0.0 position it shows "Off". }
  TGLMenuVolumeSlider = class(TGLMenuFloatSlider)
    constructor Create(const AValue: Single);
    function ValueToStr(const AValue: Single): string; override;
  end;

  TGLSoundVolumeMenuItem = class(TGLSoundMenuItem)
  private
    FSlider: TGLMenuVolumeSlider;
    property Slider: TGLMenuVolumeSlider read FSlider;
  public
    constructor Create(AGlwin: TGLWindow; Menu: TGLMenu;
      ASoundEngine: TGameSoundEngine);

    { Call this if volume changed by something outside of this class. }
    procedure RefreshAccessory;

    function Title: string; override;
    function Accessory: TGLMenuItemAccessory; override;
    procedure AccessoryValueChanged; override;
  end;

  TGLMusicVolumeMenuItem = class(TGLSoundMenuItem)
  private
    FSlider: TGLMenuVolumeSlider;
    property Slider: TGLMenuVolumeSlider read FSlider;
  public
    constructor Create(AGlwin: TGLWindow; Menu: TGLMenu;
      ASoundEngine: TGameSoundEngine);

    { Call this if volume changed by something outside of this class. }
    procedure RefreshAccessory;

    function Title: string; override;
    function Accessory: TGLMenuItemAccessory; override;
    procedure AccessoryValueChanged; override;
  end;

implementation

uses Classes, KambiClassUtils, KambiUtils, GLWinMessages;

{ TGLMenuItem ---------------------------------------------------------------- }

constructor TGLMenuItem.Create(AGlwin: TGLWindow; Menu: TGLMenu);
begin
  inherited Create;
  Menu.Items.AddObject(Title, Accessory);
  FGlwin := AGlwin;
end;

function TGLMenuItem.Accessory: TGLMenuItemAccessory;
begin
  Result := nil;
end;

procedure TGLMenuItem.Selected;
begin
end;

procedure TGLMenuItem.AccessoryValueChanged;
begin
end;

{ TGLSoundMenuItem ----------------------------------------------------------- }

constructor TGLSoundMenuItem.Create(AGlwin: TGLWindow;
  Menu: TGLMenu; ASoundEngine: TGameSoundEngine);
begin
  inherited Create(AGlwin, Menu);
  FSoundEngine := ASoundEngine;
end;

{ TGLSoundInfoMenuItem ------------------------------------------------------- }

function TGLSoundInfoMenuItem.Title: string;
begin
  Result := 'View sound information';
end;

procedure TGLSoundInfoMenuItem.Selected;
var
  S: TStringList;
begin
  S := TStringList.Create;
  try
    S.Append('Sound library (OpenAL) status:');
    S.Append('');
    Strings_AddSplittedString(S, SoundEngine.SoundInitializationReport, nl);
    SoundEngine.AppendALInformation(S);

    MessageOK(Glwin, S, taLeft);
  finally S.Free end;
end;

{ TGLMenuVolumeSlider ---------------------------------------------------- }

constructor TGLMenuVolumeSlider.Create(const AValue: Single);
begin
  inherited Create(0, 1, AValue);
end;

function TGLMenuVolumeSlider.ValueToStr(const AValue: Single): string;
begin
  if AValue = 0.0 then
    Result := 'Off' else
    Result := inherited ValueToStr(AValue);
end;

{ TGLSoundVolumeMenuItem ----------------------------------------------------- }

constructor TGLSoundVolumeMenuItem.Create(AGlwin: TGLWindow; Menu: TGLMenu;
  ASoundEngine: TGameSoundEngine);
begin
  FSlider := TGLMenuVolumeSlider.Create(ASoundEngine.SoundVolume);
  inherited;
end;

function TGLSoundVolumeMenuItem.Title: string;
begin
  Result := 'Volume';
end;

function TGLSoundVolumeMenuItem.Accessory: TGLMenuItemAccessory;
begin
  Result := FSlider;
end;

procedure TGLSoundVolumeMenuItem.AccessoryValueChanged;
begin
  SoundEngine.SoundVolume := Slider.Value;
end;

procedure TGLSoundVolumeMenuItem.RefreshAccessory;
begin
  Slider.Value := SoundEngine.SoundVolume;
end;

{ TGLMusicVolumeMenuItem ----------------------------------------------------- }

constructor TGLMusicVolumeMenuItem.Create(AGlwin: TGLWindow; Menu: TGLMenu;
  ASoundEngine: TGameSoundEngine);
begin
  FSlider := TGLMenuVolumeSlider.Create(ASoundEngine.MusicPlayer.MusicVolume);
  inherited;
end;

function TGLMusicVolumeMenuItem.Title: string;
begin
  Result := 'Music volume';
end;

function TGLMusicVolumeMenuItem.Accessory: TGLMenuItemAccessory;
begin
  Result := FSlider;
end;

procedure TGLMusicVolumeMenuItem.AccessoryValueChanged;
begin
  SoundEngine.MusicPlayer.MusicVolume := Slider.Value;
end;

procedure TGLMusicVolumeMenuItem.RefreshAccessory;
begin
  Slider.Value := SoundEngine.MusicPlayer.MusicVolume;
end;

end.
