UNIT TAU_MAIN;
{$MODE OBJFPC}
{$H+}
{$INCLUDE TAU_SIGNAL}
INTERFACE
USES
  SDL,
  TAU_WINDOW,
  TAU_GAME_MAIN;
TYPE
  TTauMain = CLASS
  PRIVATE
    b_running  : boolean;
    ctw_window : TTauWindow;
    ctg_game   : TTauGameMain;

    PROCEDURE Init();
  PUBLIC
    CONSTRUCTOR Create();
    DESTRUCTOR Destroy(); OVERRIDE;

    PROCEDURE MainLoop();
  END;

IMPLEMENTATION
CONSTRUCTOR TTauMain.Create();
BEGIN
  Init();
END;

DESTRUCTOR TTauMain.Destroy();
BEGIN
  ctw_window.Free();
  ctg_Game.Free();
  SDL_Quit();
END;

PROCEDURE TTauMain.Init();
BEGIN
  b_running := TRUE;
  ctw_window := NIL;
  ctg_game   := NIL;

  { Init SDL }
  IF (SDL_Init(SDL_INIT_EVERYTHING) <> 0) THEN
  BEGIN
    b_running := FALSE;
  END
  ELSE
  BEGIN
    { Init Win }
    ctw_window := TTauWindow.Create(800, 600);
    IF ((ctw_window = NIL) OR (ctw_window.IsOk() <> TRUE)) THEN
    BEGIN
      b_running := FALSE;
      WriteLn('! CTW_WINDOW');
    END
    ELSE
    BEGIN
      { Init Game }
      ctg_game := TTauGameMain.Create();
      IF ((ctg_game = NIL) OR (ctg_game.IsOk() <> TRUE)) THEN
      BEGIN
        b_running := FALSE;
        WriteLn('! CTG_GAME');
      END
    END;
  END;
END;

PROCEDURE TTauMain.MainLoop();
VAR
  signal: tausignal;
BEGIN
  signal := TAU_SIG_VOID;

  WHILE (b_running) DO
  BEGIN
    SDL_PumpEvents();
    SDL_FillRect(ctw_window.GetPWin(), NIL, SDL_MapRGB(ctw_window.GetPWin()^.format, 11, 12, 12));
    signal := ctg_game.Tick(ctw_window.GetPWin());
    ctw_window.Tick();

    CASE signal OF
      TAU_SIG_QUIT:
      BEGIN
        b_running := FALSE;
      END;
      TAU_SIG_VOID:
      BEGIN

      END;
    END;
    SDL_Delay(8);
  END;

  WriteLn('i MAIN LOOP BROKEN!');
END;

END.

