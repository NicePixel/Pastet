PROGRAM TETRIS;
USES
  TAU_MAIN,
  TAU_WINDOW,
  TAU_GAME_MAIN,
  TETRIS_BOARD,
  TETRIS_PIECE,
  TETRIS_SACK;
VAR
  g: TTauMain;
BEGIN
  Randomize();
  WriteLn('OBJEKTIVNI TETRIS KAPPA');
  g := TTauMain.Create();
  g.MainLoop();
  g.Free();
END.

