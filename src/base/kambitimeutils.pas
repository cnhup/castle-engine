{
  Copyright 2000-2010 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Time utilities. }
unit KambiTimeUtils;

{$I kambiconf.inc}

interface

uses
  {$ifdef MSWINDOWS}
    Windows,
  {$endif}
  {$ifdef UNIX}
    {$ifdef USE_LIBC} Libc, {$else} BaseUnix, Unix, Dl, {$endif}
  {$endif}
  SysUtils, Math;

type
  { Time in seconds. This is used throughout my engine to represent time
    as a floating-point value with good accuracy in seconds.
    In particular, for VRML / X3D time-dependent nodes.

    Implementation notes, about the choice of precision:

    @unorderedList(
      @item("Single" precision is sometimes @italic(not) enough for this.
        Proof: open rotate.kanim (from kambi_vrml_test_suite).
        Change "on display" time pass to 1000, wait a couple seconds
        (world time will reach a couple of thousands),
        change "on display" time pass back to 1.
        Result: with time as Single, animation becomes jagged.
        Reason: the precision loss of Single time, and the fact that
        Draw is not called all the time (because AutoRedisplay is false,
        and model is in Examine mode and is still (not rotating)),
        so incrementation steps of AnimationTime are very very small.

        Setting AutoRedisplay to true workarounds the problem too, but that's
        1. unacceptable to eat 100% CPU without a reason for utility like
        view3dscene 2. that's asking for trouble, after all even with
        AutoRedisplay = true the precision loss is there, it's just not
        noticeable... using better precision feels much safer.)

      @item(For X3D, SFTime has "Double" precision.
        Also "The Castle" and "The Rift" prooved it's enough in practice.

        I could have choosen Extended here,
        but for X3D sake (to avoid unnecessary floating-point convertions
        all around), let's stick to Double for now.)
    )
  }
  TKamTime = Double;

const
  OldestTime = -MaxDouble;

{ Hang the program for the specified number of miliseconds. }
procedure Delay(MiliSec: Word);

type
  TMilisecTime = LongWord;

{ Check is SecondTime larger by at least TimeDelay than FirstTime.

  Naive implementation of this would be @code(SecondTime - FirstTime >= TimeDelay).

  FirstTime and SecondTime are milisecond times from some initial point.
  For example, they may be taken from a function like GetTickCount.
  Such time may "wrap" (TMilisecTime, just a LongWord, is limited).
  This function checks these times intelligently, using the assumption that
  the SecondTime is always "later" than the FirstTime, and only having to check
  if it's later by at least TimeDelay.

  Always TimeTickSecond(X, X, 0) = @true. that is, when both times
  are actually equal, it's correctly "later by zero miliseconds". }
function TimeTickSecondLater(firstTime, secondTime, timeDelay: TMilisecTime): boolean;

{ Difference in times between SecondTime and FirstTime.

  Naive implementation would be just @code(SecondTime - FirstTime),
  this function does a little better: takes into account that times may "wrap"
  (see TimeTickSecondLater), and uses the assumption that
  the SecondTime for sure "later", to calculate hopefully correct difference. }
function TimeTickDiff(firstTime, secondTime: TMilisecTime): TMilisecTime;

{ Simply add and subtract two TMilisecTime values.

  These don't care if TMilisecTime is a point in time, or time interval.
  They simply add / subtract values. It's your problem if adding / subtracting
  them is sensible.

  Range checking is ignored. In particular, this means that if you subtract
  smaller value from larger value, the result will be like the time "wrapped"
  in between (since TMilisecTime range is limited).

  @groupBegin }
function MilisecTimesAdd(t1, t2: TMilisecTime): TMilisecTime;
function MilisecTimesSubtract(t1, t2: TMilisecTime): TMilisecTime;
{ @groupEnd }

{ Get current time, in miliseconds. Such time wraps after ~49 days.

  Under Windows, this is just a WinAPI GetTickCount call, it's a time
  since system start.

  Under Unix, similar result is obtained by gettimeofday call,
  and cutting off some digits. So under Unix it's not a time since system start,
  but since some arbitrary point. }
function GetTickCount: TMilisecTime;
 {$ifdef MSWINDOWS} stdcall; external KernelDLL name 'GetTickCount'; {$endif MSWINDOWS}

const
  MinDateTime: TDateTime = MinDouble;

{ Convert DateTime to string in the form "date at time". }
function DateTimeToAtStr(DateTime: TDateTime): string;

{ ------------------------------------------------------------------------------
  @section(Process (CPU) Time measuring ) }

type
  { }
  TProcessTimerResult =
    {$ifdef UNIX} clock_t {$endif}
    {$ifdef MSWINDOWS} DWord {$endif};

const
  { Resolution of process timer.
    @seealso ProcessTimerNow }
  ProcessTimersPerSec
    {$ifdef UNIX}
      {$ifdef USE_LIBC}
        : function: clock_t = Libc.CLK_TCK
      {$else}
        = { What is the frequency of FpTimes ?
            sysconf (_SC_CLK_TCK) ?
            Or does sysconf exist only in Libc ? }
          { Values below were choosen experimentally for Linux and FreeBSD
            (and I know that on most UNIXes it should be 128, that's
            a traditional value) }
          {$ifdef LINUX} 100 {$else}
            {$ifdef DARWIN}
              { In /usr/include/ppc/_limits.h and
                   /usr/include/i386/_limits.h
                __DARWIN_CLK_TCK is defined to 100. }
              100 {$else}
                128 {$endif} {$endif}
      {$endif}
    {$endif}
    {$ifdef MSWINDOWS} = 1000 { Using GetLastError } {$endif};

{ Current value of process (CPU) timer.
  This can be used to measure how much CPU time your process used.
  Although note that on Windows there's no way to measure CPU time,
  so this simply measures real time that passed. Only under Unix
  this uses clock() call designed to actually measure CPU time.

  You take two ProcessTimerNow values, subtract them with ProcessTimerDiff,
  this is the time passed --- in resolution ProcessTimersPerSec.

  For simple usage, see ProcessTimerBegin and ProcessTimerEnd. }
function ProcessTimerNow: TProcessTimerResult;

{ Subtract two process (CPU) timer results, obtained from ProcessTimerNow.

  Although it may just subtract two values, it may also do something more.
  For example, if timer resolution is only miliseconds, and it may wrap
  (just like TMilisecTime), then we may subtract values intelligently,
  taking into account that time could wrap (see TimeTickDiff). }
function ProcessTimerDiff(a, b: TProcessTimerResult): TProcessTimerResult;

{ Simple measure of process CPU time. Call ProcessTimerBegin at the beginning
  of your calculation, call ProcessTimerEnd at the end. ProcessTimerEnd
  returns a float number, with 1.0 being one second.

  Note that using this is unsafe in libraries, not to mention multi-threaded
  programs (it's not "reentrant") --- you risk that some other code
  called ProcessTimerBegin, and your ProcessTimerEnd doesn't measure
  what you think. So in general units, do not use this, use ProcessTimerNow
  and ProcessTimerDiff instead. In final programs (when you have full control)
  using these is comfortable and Ok.

  @groupBegin }
procedure ProcessTimerBegin;
function ProcessTimerEnd: Double;
{ @groupEnd }

{ -----------------------------------------------------------------------------
  @section(Timer) }
{ }

{$ifdef MSWINDOWS}
type
  TKamTimerResult = Int64;
  TKamTimerFrequency = Int64;

function KamTimerFrequency: TKamTimerFrequency;
{$endif MSWINDOWS}

{$ifdef UNIX}
type
  TKamTimerResult = Int64;
  TKamTimerFrequency = LongWord;

const
  KamTimerFrequency: TKamTimerFrequency = 1000000;
{$endif UNIX}

{ KamTimer is used to measure passed "real time". "Real" as opposed
  to e.g. process time (see ProcessTimerNow and friends above).
  Call KamTimer twice, calculate the difference, and you get time
  passed --- with frequency in KamTimerFrequency.

  KamTimerFrequency says how much KamTimer gets larger during 1 second
  (how many "ticks" are during one second).

  Implementation details: Under Unix this uses gettimeofday.
  Under Windows this uses QueryPerformanceCounter/Frequency,
  unless WinAPI "performance timer" is not available, then standard
  GetTickCount is used. }
function KamTimer: TKamTimerResult;

{ TFramesPerSecond ----------------------------------------------------------- }

type
  { Utility to measure frames per second, independent of actual
    rendering API. For example, it can be easily "plugged" into TGLWindow
    (see TGLWindow.FPS) or Lazarus GL control (see TKamOpenGLControl.FPS).

    Things named "_" here are supposed to be internal to the TGLWindow /
    TKamOpenGLControl and such implementations. Other properties can be
    controlled by the user of TGLWindow / TKamOpenGLControl. }
  TFramesPerSecond = class
  private
    { FramesRendered = 0 means "no frame was rendered yet" }
    FramesRendered: Int64;

    { if FramesRendered > 0 then FirstTimeTick is the time of first
      _RenderEnd call. }
    FirstTimeTick: LongWord;

    { set in _RenderBegin }
    RenderStartTime: TKamTimerResult;

    { how much time passed inside frame rendering }
    FrameTimePassed: TKamTimerResult;

    FActive: boolean;
    procedure SetActive(Value: boolean);

  private
    FDrawSpeed: Single;

    FSecondsToAutoReset: Cardinal;
    FHoldsAfterReset: TMilisecTime;

    FIdleSpeed: Single;
    DoIgnoreNextIdleSpeed: boolean;
    LastIdleStartTime: TKamTimerResult;
  public
    constructor Create;

    procedure _RenderBegin;
    procedure _RenderEnd;
    procedure _IdleBegin;

    { Turn on/off frames per second measuring.
      Before using FrameTime or RealTime you must set Active to @true. }
    property Active: boolean read FActive write SetActive;

    { Rendering speed in frames per second. This tells FPS,
      if we would only call Draw (EventDraw, OnDraw) all the time.
      That is, this doesn't take into account time spent on other activities,
      like OnIdle, and it doesn't take into account that frames are possibly
      not rendered continously (when AutoRedisplay = @false, we may render
      frames seldom, because there's no need to do it more often).

      @seealso RealTime }
    function FrameTime: Double;

    { How many frames per second were rendered. This is a real number
      of EventDraw (OnDraw) calls per second. This means that it's actual
      speed of your program. Anything can slow this down, not only long
      EventDraw (OnDraw), but also slow processing of other events (like OnIdle).
      Also, when AutoRedisplay = @false, this may be very low, since you
      just don't need to render frames continously.

      @seealso FrameTime }
    function RealTime: Double;

    { Reset the FPS measuring.
      Alternative to doing @code(Active := false; Active := true). }
    procedure Reset;

    { FPS measurements reset after this number of seconds.
      This way RealTime / FrameTime always show the average FPS numbers
      during the last SecondsToAutoReset seconds (well, actually it's
      more complicated, see HoldsAfterReset).

      This way RealTime / FrameTime don't change too rapidly
      (so they are good indicator of current FPS speed, as opposed to
      e.g. DrawSpeed which changes every frame so it very unstable).
      They also change rapidly enough --- you don't want to see measuments
      from too long time ago.

      Change SecondsToAutoReset when not Active = @false.  }
    property SecondsToAutoReset: Cardinal
        read FSecondsToAutoReset
       write FSecondsToAutoReset default 6;

    { How to keep previous FPS measurements, when they reset by
      SecondsToAutoReset?

      When measurements are reset by SecondsToAutoReset, you actually don't
      want to totally forget previous measurements (as this would make
      your RealTime / FrameTime unstable for a short time).
      Instead, you want to assume that current RealTime / FrameTime
      was measured during last HoldsAfterReset miliseconds.

      This way RealTime / FrameTime stay more stable.

      So actually the measurements are reset at each
      SecondsToAutoReset * 1000 - HoldsAfterReset miliseconds. }
    property HoldsAfterReset: TMilisecTime
        read FHoldsAfterReset
       write FHoldsAfterReset default 1000;

    { @abstract(How much time it took to render last frame?)

      This returns the time of last EventDraw (that by default just calls
      OnDraw callback).
      The time is in seconds, 1.0 = 1 second. In other words, if FrameTime
      would be measured only based on the last frame time and
      FrameTime = 1.0 then DrawSpeed is 1.0. (In reality,
      FrameTime is measured a little better, to average the time
      of a couple of last frames).

      So for two times faster computer DrawSpeed is = 0.5,
      for two times slower DrawSpeed = 2.0. This is useful for doing
      time-based rendering, when you want to scale some changes
      by computer speed, to get perceived animation speed the same on every
      computer, regardless of computer's speed. Although remember this measures
      only EventDraw (OnDraw) speed, so if you do anything else
      taking some time (e.g. you perform some calculations during OnIdle)
      you're probably much safer to use IdleSpeed.

      Note that this if you have "unstable" rendering times (for example,
      some OnDraw calls will do something costly like implicitly
      preparing VRML models on first Render) then DrawSpeed value will
      also raise suddenly on such frames. That's why you should do
      any potentially lengthy operations, like preparing VRML scene,
      in OnBeforeDraw, that is not taken into account when calculating
      DrawSpeed.

      This is independent from @link(Active) setting, it works always. }
    property DrawSpeed: Single read FDrawSpeed;

    { @abstract(How much time passed since last EventIdle (OnIdle) call?)

      The time is in seconds, 1.0 = 1 second.
      For two times faster computer IdleSpeed = 0.5,
      for two times slower IdleSpeed = 2.0. This is useful for doing
      time-based rendering, when you want to scale some changes
      by computer speed, to get perceived animation speed the same on every
      computer, regardless of computer's speed.

      This is like DrawSpeed, but calculated as a time between
      start of previous Idle event and start of current Idle event.
      So this really measures your whole loop time (unlike DrawSpeed
      that measures only EventDraw (OnDraw) speed).

      You can sanely use this only within EventIdle (OnIdle).

      This is independent from @link(Active) setting, it works always. }
    property IdleSpeed: Single read FIdleSpeed;

    { Forces IdleSpeed within the next EventIdle (onIdle) call to be
      equal to 0.0.

      This is useful if you just came back from some lenghty
      state, like a GUI dialog box (like TGLWindow.FileDialog or modal boxes
      in GLWinMessages --- but actually all our stuff already calls this
      as needed, TGLMode takes care of this). IdleSpeed would be ridicoulously
      long in such case (if our loop is totally stopped) or not relevant
      (if we do our loop, but with totally different callbacks, like
      GLWinMessages). Instead, it's most sensible in such case to fake
      that IdleSpeed is 0.0, so things such as TVRMLScene.Time
      should not advance wildly just because we did GUI box.

      This forces the IdleSpeed to zero only once, that is only on the
      next EventIdle (OnIdle). Following EventIdle (OnIdle) will have
      IdleSpeed as usual (unless you call IgnoreNextIdleSpeed again, of course). }
    procedure IgnoreNextIdleSpeed;
  end;

implementation

procedure Delay (MiliSec: Word);
begin
 SysUtils.Sleep(MiliSec);
end;

function TimeTickSecondLater(firstTime, secondTime, timeDelay: TMilisecTime): boolean;
{ trzeba uwazac na typy w tej procedurze.
  Dword to 32 bit unsigned int,
  Int64 to 64 bit signed int.
  I tak musi byc.
  Uwaga ! W Delphi 3, o ile dobrze pamietam, bylo Dword = longint ! tak nie moze byc ! }
var bigint: Int64;
begin
 bigint := secondTime-timeDelay;
 if bigint < 0 then
 begin
  bigint := bigint+High(TMilisecTime);
  result:=(firstTime > secondTime) and (firstTime <= bigint);
 end else result := firstTime <= bigint;
end;

function TimeTickDiff(firstTime, secondTime: TMilisecTime): TMilisecTime;
begin
 result := MilisecTimesSubtract(secondTime, firstTime);
{old implementation :

 if firstTime <= secondTime then
  result := secondTime-firstTime else
  result := High(TMilisecTime) -firstTime +secondTime;
}
end;

{$I norqcheckbegin.inc}
function MilisecTimesAdd(t1, t2: TMilisecTime): TMilisecTime;
begin result := t1+t2 end;

function MilisecTimesSubtract(t1, t2: TMilisecTime): TMilisecTime;
begin result := t1-t2 end;
{$I norqcheckend.inc}

{$ifndef MSWINDOWS}

{$I norqcheckbegin.inc}
function GetTickCount: TMilisecTime;
var timeval: TTimeVal;
begin
 {$ifdef USE_LIBC} gettimeofday(timeval, nil)
 {$else}           FpGettimeofday(@timeval, nil)
 {$endif};

 { Odrzucamy najbardziej znaczace cyfry z x -- i dobrze, bo w
   timeval.tv_sec najbardziej znaczace cyfry sa najmniej wazne bo najrzadziej
   sie zmieniaja.
   x*1000 jednoczesnie ma puste miejsca na trzech najmniej znaczaych cyfrach
   dziesietnych (mowiac po ludzku, po prostu x*1000 ma trzy zera na koncu).
   Wykorzystujemy te trzy miejsca na tv_usec div 1000 ktore na pewno zawiera
   sie w 0..999 bo tv_usec zawiera sie w 0..milion-1.

   W ten sposob zamenilismy timeval na jedna 32-bitowa liczbe w taki sposob
   ze odrzucilismy tylko najbardziej znaczace cyfry - a wiec lepiej
   sie nie da. W rezultacie otrzymana cyfra mierzy czas w milisekundach a wiec
   przewinie sie, podobnie jak Windowsowe GetTickCount, co jakies 49 dni
   (49 dni = 49* 24* 60* 60 *1000 milisekund = 4 233 600 000 a wiec okolice
   High(LongWord)). Tyle ze ponizsze GetTickCount nie liczy czasu poczawszy
   od startu windowsa wiec moze sie przewinac w kazdej chwili.

   Note: I used to have here some old code that instead of
     LongWord(timeval.tv_sec) * 1000
   was doing
     ( LongWord(timeval.tv_sec) mod (Int64(High(LongWord)) div 1000 + 1) ) * 1000
   but I longer think it's necessary. After all, I'm inside
   norqcheck begin/end so I don't have to care about such things,
   and everything should work OK.
 }

 Result := LongWord(timeval.tv_sec) * 1000 + Longword(timeval.tv_usec) div 1000;
end;
{$I norqcheckend.inc}

{$endif not MSWINDOWS}

function DateTimeToAtStr(DateTime: TDateTime): string;
begin
 result := FormatDateTime('yyyy"-"mm"-"dd" at "tt', DateTime);
end;

{ cross-platform process timery ---------------------------------------------- }

{$ifdef UNIX}
function ProcessTimerNow: TProcessTimerResult;
var Dummy: tms;
begin
 { See /c/mojepasy/console.testy/test_times/RESULTS,
   it occurs that (at least on my Linux ? Debian, Linux 2.4.20, libc-2.3.2)
   the only reliable way is to use return value from times
   (from Libc or FpTimes).

   tms.tms_utime, tms.tms_stime, clock() values are nonsense !

   This is not FPC bug as I tested this with C program too. }

 Result := {$ifdef USE_LIBC} times {$else} FpTimes {$endif} (Dummy);
end;

function ProcessTimerDiff(a, b: TProcessTimerResult): TProcessTimerResult;
begin
 Result := a - b;
end;
{$endif UNIX}

{$ifdef MSWINDOWS}
function ProcessTimerNow: TProcessTimerResult;
begin
  Result := GetTickCount;
end;

function ProcessTimerDiff(a, b: TProcessTimerResult): TProcessTimerResult;
begin
  Result := TimeTickDiff(b, a);
end;
{$endif MSWINDOWS}

var
  LastProcessTimerBegin: TProcessTimerResult;

procedure ProcessTimerBegin;
begin
  LastProcessTimerBegin := ProcessTimerNow
end;

function ProcessTimerEnd: Double;
begin
  Result := ProcessTimerDiff(ProcessTimerNow, LastProcessTimerBegin)
    / ProcessTimersPerSec;
end;

{ timer ---------------------------------------------------------- }

{$ifdef MSWINDOWS}
type
  TTimerState = (tsNotInitialized, tsQueryPerformance, tsGetTickCount);

var
  FTimerState: TTimerState = tsNotInitialized;
  FKamTimerFrequency: TKamTimerFrequency;

{ Set FTimerState to something <> tsNotInitialized.
  Also set FKamTimerFrequency. }
procedure InitKamTimer;
begin
  if QueryPerformanceFrequency(FKamTimerFrequency) then
    FTimerState := tsQueryPerformance else
  begin
    FTimerState := tsGetTickCount;
    FKamTimerFrequency := 1000;
  end;
end;

function KamTimerFrequency: TKamTimerFrequency;
begin
  if FTimerState = tsNotInitialized then InitKamTimer;

  Result := FKamTimerFrequency;
end;

function KamTimer: TKamTimerResult;
begin
  if FTimerState = tsNotInitialized then InitKamTimer;

  if FTimerState = tsQueryPerformance then
    QueryPerformanceCounter(Result) else
    Result := GetTickCount;
end;
{$endif MSWINDOWS}

{$ifdef UNIX}
function KamTimer: TKamTimerResult;
var
  tv: TTimeval;
begin
  {$ifdef USE_LIBC} gettimeofday(tv, nil)
  {$else}           FpGettimeofday(@tv, nil)
  {$endif};

  { w Int64 zmiesci sie cale TTimeval bez obcinania.
    Robie tylko odpowiednie casty na zapas zeby na pewno liczyl wszystko
    od poczatku jako Int64}
  Result := Int64(tv.tv_sec)*1000000 + Int64(tv.tv_usec);
end;
{$endif UNIX}

{ TFramesPerSecond ----------------------------------------------------------- }

constructor TFramesPerSecond.Create;
begin
  inherited;

  FSecondsToAutoReset := 6;
  HoldsAfterReset := 1000;

  { Just init DrawSpeed, IdleSpeed to some sensible default.
    Rendering time 30 frames per second seems sensible default for 3D game
    right?

    For IdleSpeed this is actually not essential, since we call
    IgnoreNextCompSpeed anyway. But in case programmer will (incorrectly!)
    try to use IdleSpeed before EventIdle (OnIdle) call, it's useful to have
    here some predictable value. }
  FDrawSpeed := 1 / 30;
  FIdleSpeed := 1 / 30;

  IgnoreNextIdleSpeed;
end;

procedure TFramesPerSecond.Reset;
var
  NowTick: TMilisecTime;
  OldFrameTime, OldRealTime: Double;
begin
  { We could just set FramesRendered = 0 and FrameTimePassed = 0.
    This would basically reset the FPS measurements.

    But it would be very crude solution. Right after Reset, our FrameTime/
    RealTime measurements would be completely wrong.
    So we use HoldsAfterReset to counteract this. }

  if HoldsAfterReset = 0 then
  begin
    { reset brutally }
    FramesRendered := 0;
    FrameTimePassed := 0;
  end else
  begin
    if FramesRendered <> 0 then
    begin
      { save measures }
      OldFrameTime := FrameTime;
      OldRealTime := RealTime;
    end else
    begin
      { Init some default measures. Otherwise FPS would be wild at the start
        of the program, when FramesRendered = 0. }
      OldFrameTime := 80;
      OldRealTime := 80;
    end;

    { fake that already HoldsAfterReset time passed }
    NowTick := GetTickCount;
    if NowTick > HoldsAfterReset then
      FirstTimeTick := NowTick - HoldsAfterReset else
      { Once in 49 days FirstTimeTick has to be wrong... }
      FirstTimeTick := 0;

    { Adjust FramesRendered to make new RealTime = OldRealTime.
      RealTime = FramesRendered * 1000 / HoldsAfterReset sos }
    FramesRendered := Round(OldRealTime * HoldsAfterReset / 1000.0);

    { Adjust FrameTimePassed to make new FrameTime = OldFrameTime.

      Remember that FrameTimePassed is in KamTimerFrequency units.
      So we want to
      FramesRendered  / (FrameTimePassed / KamTimerFrequency) = FrameTime so
      FramesRendered * KamTimerFrequency  / FrameTimePassed = FrameTime so
      FramesRendered * KamTimerFrequency / FrameTime = FrameTimePassed. }
    if OldFrameTime = 0 then
      FrameTimePassed := 0 else
      FrameTimePassed := Round(FramesRendered * KamTimerFrequency / OldFrameTime);
  end;
end;

procedure TFramesPerSecond.SetActive(Value: boolean);
begin
  if Value = Active then Exit;

  FActive := Value;
  if Value then
    Reset;
end;

procedure TFramesPerSecond._RenderBegin;
begin
  { Do this even when not Active: RenderStartTime is needed to calc DrawSpeed }

  RenderStartTime := KamTimer;
end;

procedure TFramesPerSecond._RenderEnd;
var
  NowTick: TMilisecTime;
begin
  { ((KamTimer-RenderStartTime) / KamTimerFrequency) = time of last frame
    rendering time. }
  FDrawSpeed := (KamTimer - RenderStartTime) / KamTimerFrequency;

  if not Active then Exit;

  NowTick := GetTickCount;
  if ((NowTick - FirstTimeTick) div 1000) >= SecondsToAutoReset then
    Reset;

  if FramesRendered = 0 then FirstTimeTick := NowTick;
  Inc(FramesRendered);
  FrameTimePassed := FrameTimePassed + KamTimer - RenderStartTime;
end;

function TFramesPerSecond.RealTime: Double;
var
  TimePass: TMilisecTime;
begin
  Assert(Active, 'RealTime called but FPS counting not Activated');
  TimePass := GetTickCount - FirstTimeTick;
  if TimePass > 0 then
    Result := FramesRendered * 1000 / TimePass else
    Result := 0;
end;

function TFramesPerSecond.FrameTime: Double;
begin
  Assert(Active, 'FrameTime called but FPS counting not Activated');
  if FrameTimePassed > 0 then
    Result := FramesRendered * KamTimerFrequency / FrameTimePassed else
    Result := 0;
end;

procedure TFramesPerSecond._IdleBegin;
var
  NewLastIdleStartTime: TKamTimerResult;
begin
  { update FIdleSpeed, DoIgnoreNextIdleSpeed, LastIdleStartTime }
  NewLastIdleStartTime := KamTimer;

  if DoIgnoreNextIdleSpeed then
  begin
    FIdleSpeed := 0.0;
    DoIgnoreNextIdleSpeed := false;
  end else
    FIdleSpeed := ((NewLastIdleStartTime - LastIdleStartTime) / KamTimerFrequency);

  LastIdleStartTime := NewLastIdleStartTime;
end;

procedure TFramesPerSecond.IgnoreNextIdleSpeed;
begin
  DoIgnoreNextIdleSpeed := true;
end;

end.
