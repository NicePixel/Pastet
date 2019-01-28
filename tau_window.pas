UNIT TAU_WINDOW;
{$MODE OBJFPC}
{$H+}
INTERFACE
USES
  SDL;

TYPE
  pTTauWindow = ^TTauWindow;
  TTauWindow  = CLASS
  PRIVATE
    b_ok    : boolean;
    surf_win: PSDL_Surface;

  PUBLIC
    CONSTRUCTOR Create(w, h: integer);
    DESTRUCTOR Destroy(); OVERRIDE;

    FUNCTION IsOk(): boolean;
    FUNCTION GetPWin(): PSDL_Surface;
    PROCEDURE Tick();
  END;

IMPLEMENTATION
CONSTRUCTOR TTauWindow.Create(w, h: integer);
BEGIN
  b_ok := TRUE;
  surf_win := SDL_SetVideoMode(
    w,
    h,
    0,
    SDL_HWSURFACE
  );
  IF (surf_win = NIL) THEN
  BEGIN
    b_ok := FALSE;
  END;
END;

DESTRUCTOR TTauWindow.Destroy();
BEGIN

END;

FUNCTION TTauWindow.IsOk(): boolean;
BEGIN
  IsOk := b_ok;
END;

FUNCTION TTauWindow.GetPWin(): PSDL_Surface;
BEGIN
  GetPWin := surf_win;
END;

PROCEDURE TTauWindow.Tick();
BEGIN
  IF (SDL_Flip(surf_win) <> 0) THEN
  BEGIN
    WriteLn('! WIN ' + SDL_GetError());
  END;
END;

END.
