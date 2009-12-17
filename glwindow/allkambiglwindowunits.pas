unit AllKambiGLWindowUnits;

{ This is automatically generated unit, useful to compile all units
  in this directory (and OS-specific subdirectories like
  unix/, linux/, and windows/).
  Don't edit.
  Don't use this unit in your programs, it's just not for this.
  Generated by Kambi's Elisp function all-units-in-dir. }

interface

uses
  glmenu,
  glsoundmenu,
  glwindow,
  glwindowrecentmenu,
  glwindowvrmlbrowser,
  glwininputs,
  glwinmessages,
  glwinmodes,
  progressgl,
  timemessages,
  {$ifdef UNIX}
  kambiglx,
  kambixf86vmode,
  xlibutils
  {$endif UNIX}
  {$ifdef MSWINDOWS}
  glwindowwinapimenu
  {$endif MSWINDOWS}
  ;

implementation

end.
