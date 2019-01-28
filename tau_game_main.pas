UNIT TAU_GAME_MAIN;
{$MODE OBJFPC}
{$H+}
{$INCLUDE TAU_SIGNAL}
INTERFACE
USES
  SDL,
  SDL_IMAGE,
  TETRIS_BOARD;
CONST
  GAME_STATE_INGAME           = 1;
  GAME_STATE_PAUSE_STATETIMER = 2;
TYPE
  TTauGameMain = CLASS
  PRIVATE
    b_ok                 : boolean;
    b_pause              : boolean;
    b_gameover           : boolean;
    i_state              : integer;
    f_backgroundoffsetX  : real;
    f_backgroundoffsetY  : real;
    f_pausetimer         : real;
    i_pausestate         : integer;
    i_downpartDisapInd   : integer;
    i_menuoption         : integer;
    f_downpartDisapTimer : real;
    b_drawdetails        : boolean;
    srf_backgroundGrid   : PSDL_Surface;
    srf_backgroundBoard  : PSDL_Surface;
    srf_backgroundOverlay: PSDL_Surface;
    srf_backgroundPause0 : PSDL_Surface;
    srf_backgroundPause1 : PSDL_Surface;
    srf_square           : PSDL_Surface;
    srf_charsheet        : PSDL_Surface;
    srf_backgroundDetails: PSDL_Surface;
    srf_blockcounter     : PSDL_Surface;
    board                : TTetrisBoard;
    pauseStringMovText   : string;
    pauseStringMovInd    : integer;

    PROCEDURE Ren_Text(str: string; x, y: integer; pwin: PSDL_Surface);

    PROCEDURE ResetGame();

    FUNCTION  Tick_Ingame(pwin: PSDL_Surface): tausignal;
    PROCEDURE Draw_Background(pwin: PSDL_Surface);
    PROCEDURE Draw_Board(pwin: PSDL_Surface);
    PROCEDURE Draw_Overlay(pwin: PSDL_Surface);
    PROCEDURE Draw_Scoreboard(pwin: PSDL_Surface);
    PROCEDURE Draw_PauseScreen(pwin: PSDL_Surface);
    PROCEDURE Draw_Downpart(pwin: PSDL_Surface);
    PROCEDURE Draw_Rightpart(pwin:PSDL_Surface);

  PUBLIC
    CONSTRUCTOR Create();
    DESTRUCTOR Destroy(); OVERRIDE;

    FUNCTION Tick(pwin: PSDL_Surface): tausignal;
    FUNCTION IsOk(): boolean;
  END;

IMPLEMENTATION
CONSTRUCTOR TTauGameMain.Create();
VAR
  srf_temp: PSDL_Surface;
BEGIN
  b_pause               := FALSE;
  b_ok                  := TRUE;
  i_state               := GAME_STATE_INGAME;
  i_pausestate          := 0;
  i_downpartDisapInd    := 1;
  srf_backgroundGrid    := NIL;
  b_drawdetails         := FALSE;
  b_gameover            := FALSE;
  f_backgroundoffsetX   := 0.0;
  f_backgroundoffsetY   := 0.0;
  f_pausetimer          := 0.0;
  f_downpartDisapTimer  := 0.0;
  board                 := TTetrisBoard.Create();
  srf_temp              := NIL;
  srf_backgroundBoard   := NIL;
  srf_backgroundOverlay := NIL;
  srf_backgroundGrid    := NIL;
  srf_square            := NIL;
  srf_backgroundDetails := NIL;
  srf_blockcounter      := NIL;
  pauseStringMovInd     := 1;
  pauseStringMovText    := '$Z                                                         ';
  i_menuoption          := 0;

  srf_temp              := IMG_Load('data/tex/char/0.png');
  srf_charsheet         := SDL_DisplayFormat(srf_temp);
  SDL_FreeSurface(srf_temp);

  { Мрежа }
  srf_temp              := IMG_Load('data/tex/grid.bmp');
  srf_backgroundGrid    := SDL_DisplayFormat(srf_temp);
  SDL_FreeSurface(srf_temp);

  { Табла }
  srf_temp              := IMG_Load('data/tex/board.bmp');
  srf_backgroundBoard   := SDL_DisplayFormat(srf_temp);
  SDL_FreeSurface(srf_temp);
  SDL_SetAlpha(srf_backgroundBoard, SDL_SRCALPHA, $F0);

  srf_temp              := IMG_Load('data/tex/rect.bmp');
  srf_blockcounter      := SDL_DisplayFormat(srf_temp);
  SDL_FreeSurface(srf_temp);

  { Прекривач }
  srf_temp                  := IMG_Load('data/tex/overlay.png');
  srf_backgroundOverlay     := SDL_DisplayFormatAlpha(srf_temp);
  SDL_FreeSurface(srf_temp);
  srf_temp                  := IMG_Load('data/tex/overlay_details.png');
  srf_backgroundDetails     := SDL_DisplayFormatAlpha(srf_temp);
  SDL_FreeSurface(srf_temp);
  srf_temp                  := IMG_Load('data/tex/pause0.png');
  srf_backgroundPause0      := SDL_DisplayFormatAlpha(srf_temp);
  SDL_FreeSurface(srf_temp);
  srf_temp                  := IMG_Load('data/tex/pause1.png');
  srf_backgroundPause1      := SDL_DisplayFormatAlpha(srf_temp);
  SDL_FreeSurface(srf_temp);


  srf_temp   := IMG_Load('data/tex/square.bmp');
  srf_square := SDL_DisplayFormatAlpha(srf_temp);
  SDL_FreeSurface(srf_temp);

  IF ((srf_backgroundGrid = NIL) OR (srf_backgroundBoard = NIL) OR (srf_backgroundOverlay = NIL)) THEN
  BEGIN
    WriteLn('! data/tex/{?}');
    b_ok := FALSE;
  END;
END;

DESTRUCTOR TTauGameMain.Destroy();
BEGIN
  board.Free();
  SDL_FreeSurface(srf_backgroundDetails);
  SDL_FreeSurface(srf_charsheet);
  SDL_FreeSurface(srf_square);
  SDL_FreeSurface(srf_backgroundOverlay);
  SDL_FreeSurface(srf_backgroundBoard);
  SDL_FreeSurface(srf_backgroundGrid);
  SDL_FreeSurface(srf_blockcounter);
END;

PROCEDURE TTauGameMain.ResetGame();
BEGIN
  board.Reset();
END;

FUNCTION TTauGameMain.Tick(pwin: PSDL_Surface): tausignal;
VAR
  ts: tausignal;
BEGIN
  ts := TAU_SIG_VOID;

  CASE i_state OF
    GAME_STATE_INGAME:
    BEGIN
      ts := Tick_Ingame(pwin);
    END;
  END;

  Tick := ts;
END;

PROCEDURE TTauGameMain.Ren_Text(str: string; x, y: integer; pwin: PSDL_Surface);
VAR
  i, ind: integer;
  xx, yy: integer;
  d, dp : TSDL_Rect;
BEGIN
  xx := x;
  yy := y;
  i  := 1;
  WHILE (i <= Length(str)) DO
  BEGIN
    ind := Ord(str[i]);
    IF (str[i] = '$') THEN
    BEGIN
      IF (str[i+1] = 'c') THEN
      BEGIN
        ind := 1;
      end
      ELSE IF (str[i+1] = 'C') THEN
      BEGIN
        ind := 0;
      END
      ELSE IF (str[i+1] = 's') THEN
      BEGIN
        ind := 17;
      end
      ELSE IF (str[i+1] = 'S') THEN
      BEGIN
        ind := 16;
      END
      ELSE IF (str[i+1] = 'N') THEN
      BEGIN
        ind := 255;
      END
      ELSE IF (str[i+1] = 'Z') THEN
      BEGIN
        ind := 254;
      END
      ELSE IF (str[i+1] = 'D') THEN
      BEGIN
        ind := 253;
      END
      ELSE IF (str[i+1] = 'b') THEN
      BEGIN
        ind := Ord('v') + 16;
      END
      ELSE IF (str[i+1] = 'l') THEN
      BEGIN
        ind := Ord('l') + 16 * 2;
      END
      ELSE IF (str[i+1] = 'x') THEN
      BEGIN
        ind := (Ord('s') + 16);
      END
      ELSE IF (str[i+1] = '3') THEN
      BEGIN
        ind := 225-16+10;
      END
      ELSE IF (str[i+1] = '2') THEN
      BEGIN
        ind := 194-16;
      END
      ELSE IF (str[i+1] = '1') THEN
      BEGIN
        ind := 193-16;
      END
      ELSE IF (str[i+1] = '0') THEN
      BEGIN
        ind := 192-16;
      END;
      i := i + 1;
    END;

    d.x := xx;
    d.y := yy;
    d.w := 16;
    d.h := 16;
    dp.x := (ind MOD 16) * 16;
    dp.y := (ind DIV 16) * 16;
    dp.w := 16;
    dp.h := 16;

    SDL_BlitSurface(srf_charsheet, @dp, pwin, @d);

    xx := xx + 16;
    i  := i +1;
  END;
END;

FUNCTION TTauGameMain.IsOk(): boolean;
BEGIN
  IsOk := b_ok;
END;

FUNCTION TTauGameMain.Tick_Ingame(pwin: PSDL_Surface): tausignal;
VAR
  ts: tausignal;
  e: TSDL_Event;
  y: integer;
  srf: PSDL_Surface;
BEGIN
  ts                   := TAU_SIG_VOID;
  f_downpartDisapTimer := f_downpartDisapTimer + 0.1;
  board.SpeedUp((SDL_GetKeyState(NIL)[SDLK_DOWN] <> 0));

  IF (NOT b_pause) THEN
  BEGIN
    f_pausetimer := 0.0;
    f_backgroundoffsetX := sin((SDL_GetTicks() / 23.0)/256.0) * 40.0;
    f_backgroundoffsetY := cos((SDL_GetTicks() / 7.0)/256.0) * 40.0;
  END
  ELSE
  BEGIN
    f_pausetimer := f_pausetimer + 1.0;
    IF (f_pausetimer > GAME_STATE_PAUSE_STATETIMER) THEN
    BEGIN
      f_pausetimer := 0.0;
      i_pausestate := i_pausestate + 1;
      IF (i_pausestate > 1) THEN
      BEGIN
        i_pausestate := 0;
      END;
    END;
    SDL_Delay(32);
  END;

  WHILE (SDL_PollEvent(@e) <> 0) DO
  BEGIN
    IF (e.type_ = SDL_QUITEV) THEN
    BEGIN
      ts := TAU_SIG_QUIT;
    END;
    IF (e.type_ = SDL_KEYDOWN) THEN
    BEGIN
      CASE (e.key.keysym.sym) OF
        SDLK_PAUSE:
        BEGIN
          b_pause := NOT b_pause;
        END;
        SDLK_F1:
        BEGIN
          b_drawdetails := NOT b_drawdetails;
        END;
        SDLK_SPACE:
        BEGIN
          IF (NOT b_pause) THEN
            board.CurPiece_DropDown();
        END;
        SDLK_LEFT:
        BEGIN
          IF (NOT b_pause) THEN
          BEGIN
            board.CurPiece_MoveX(-1);
          END
          ELSE
          BEGIN
            IF (i_menuoption = 0) THEN i_menuoption := 2
            ELSE IF (i_menuoption = 1) THEN i_menuoption := 0
            ELSE IF (i_menuoption = 2) THEN i_menuoption := 1;
          END;
        END;
        SDLK_RIGHT:
        BEGIN
          IF (NOT b_pause) THEN
            board.CurPiece_MoveX(+1)
          ELSE
          BEGIN
            IF (i_menuoption = 0) THEN i_menuoption := 1
            ELSE IF (i_menuoption = 1) THEN i_menuoption := 2
            ELSE IF (i_menuoption = 2) THEN i_menuoption := 0;
          END;
        END;
        SDLK_z:
        BEGIN
          IF (NOT b_pause) THEN
            board.Piece_Rot(0, -1);
        END;
        SDLK_x:
        BEGIN
          IF (NOT b_pause) THEN
            board.Piece_Rot(0, +1);
        END;
        SDLK_a:
        BEGIN
          IF (NOT b_pause) THEN
            board.Piece_Rot(1, -1);
        END;
        SDLK_s:
        BEGIN
          IF (NOT b_pause) THEN
            board.Piece_Rot(1, +1);
        END;
        SDLK_RETURN:
        BEGIN
          IF (b_pause) THEN
            IF (i_menuoption = 0) THEN b_pause := FALSE
            ELSE IF (i_menuoption = 1) THEN ResetGame()
            ELSE IF (i_menuoption = 2) THEN ts := TAU_SIG_QUIT;
        END;
      END;
    END;
  END;

  IF (board.GetGameOver()) THEN
  BEGIN
    b_pause    := TRUE;
    b_gameover := TRUE;
  END;

  Draw_Background(pwin);
  Draw_Overlay(pwin);
  Draw_Scoreboard(pwin);
  Draw_Board(pwin);
  Draw_Rightpart(pwin);

  IF( b_pause) THEN
  BEGIN
    srf := srf_backgroundPause0;
    IF (i_pausestate = 1) THEN
    BEGIN
      srf := srf_backgroundPause1;
    END;
    SDL_BlitSurface(srf, NIL, pwin, NIL);
  END;

  IF (b_drawdetails) THEN
  BEGIN
    SDL_BlitSurface(srf_backgroundDetails, NIL, pwin, NIL);
  END;

  IF (NOT b_pause) THEN
  BEGIN
      board.Tick();
  END
  ELSE
  BEGIN
    Draw_PauseScreen(pwin);
    pauseStringMovInd := pauseStringMovInd + 1;
    IF (pauseStringMovInd < (Length(pauseStringMovText) + 1)) THEN
    BEGIN
      pauseStringMovText[pauseStringMovInd - 1] := ' ';
      pauseStringMovText[pauseStringMovInd + 0] := '$';
      pauseStringMovText[pauseStringMovInd + 1] := 'Z';
    END
    ELSE
    BEGIN
      pauseStringMovText[pauseStringMovInd + 0] := ' ';
      pauseStringMovText[pauseStringMovInd + 1] := ' ';
      pauseStringMovText[1] := '$';
      pauseStringMovText[2] := 'Z';
      pauseStringMovInd := 1;
    END;
  END;

  Draw_Downpart(pwin);
  Ren_Text('    TETRIS?      ', 560 + 6, 0, pwin);
  Ren_Text('                 ', 560 + 6, 16, pwin);
  IF (b_drawdetails) THEN
  BEGIN
    y := 0;
    Ren_Text('$3$3$3$3$3$3$2$2$2$2$2$2$1$1$1$1$1                    ', 0, y, pwin); y := y + 16;
    Ren_Text('+------------------------------------------------+', 0, y, pwin); y := y + 16;
    Ren_Text('| Igra napisana u Paskalu.                       |', 0, y, pwin); y := y + 16;
    Ren_Text('| Autor: Aleksandar Uro$sevi$c                     |', 0, y, pwin); y := y + 16;
    Ren_Text('|                                                |', 0, y, pwin); y := y + 16;
    Ren_Text('| Zapo$xeto u maju, zavrseno ko zna kada.         |', 0, y, pwin); y := y + 16;
    Ren_Text('|                                                |', 0, y, pwin); y := y + 16;
    Ren_Text('| Name$beno bilo kome.                            |', 0, y, pwin); y := y + 16;
    Ren_Text('| Softver moxete davati kome god xelite, i       |', 0, y, pwin); y := y + 16;
    Ren_Text('| prijate$lima i neprijate$lima. Radite $sta god    |', 0, y, pwin); y := y + 16;
    Ren_Text('| xelite sa ovim softverom.                      |', 0, y, pwin); y := y + 16;
    Ren_Text('|                                                |', 0, y, pwin); y := y + 16;
    Ren_Text('|                             Jedi pite sa sirom |', 0, y, pwin); y := y + 16;
    Ren_Text('|                                Xivot je proces$D|', 0, y, pwin); y := y + 16;
    Ren_Text('+------------------------------------------------+', 0, y, pwin); y := y + 16;
  END;

  Tick_Ingame := ts;
END;

PROCEDURE TTauGameMain.Draw_Rightpart(pwin:PSDL_Surface);
VAR
  s: string;
  a: arrCount;
  d: TSDL_Rect;
BEGIN
  a := board.GetBlockCounter();
  d.x := 0;
  d.y := 0;
  d.w := 1;
  d.h := 1;

  SDL_BlitSurface(srf_blockcounter, NIL, pwin, @d);
  Ren_Text ('Tetramino: ', 8, 8 + 16 * (0), pwin);
  Str(a[1], s); s := s + '          '; Ren_Text (s, 8, 8 + 16 * 1, pwin);
  Str(a[2], s); s := s + '          '; Ren_Text (s, 8, 8 + 16 * 2, pwin);
  Str(a[3], s); s := s + '          '; Ren_Text (s, 8, 8 + 16 * 3, pwin);
  Str(a[4], s); s := s + '          '; Ren_Text (s, 8, 8 + 16 * 4, pwin);
  Str(a[5], s); s := s + '          '; Ren_Text (s, 8, 8 + 16 * 5, pwin);
  Str(a[6], s); s := s + '          '; Ren_Text (s, 8, 8 + 16 * 6, pwin);
  Str(a[7], s); s := s + '          '; Ren_Text (s, 8, 8 + 16 * 7, pwin);
END;

PROCEDURE TTauGameMain.Draw_Downpart(pwin: PSDL_Surface);
VAR
  str: string;
BEGIN
  str    := '                              Aleksandar Uro$sevi$c$N      ';

  IF (f_downpartDisapTimer > 0.4) THEN
  BEGIN
    IF (str[i_downpartDisapInd] = '$') THEN
    BEGIN
      i_downpartDisapInd   := i_downpartDisapInd + 1;
    END;
    i_downpartDisapInd   := i_downpartDisapInd + 1;
    f_downpartDisapTimer := -0.4 - Random(2);
  END;
  IF (i_downpartDisapInd > Length(str)) THEN
  BEGIN
    i_downpartDisapInd := 1;
  END;

  IF (str[i_downpartDisapInd] = '$') THEN
  BEGIN
    Delete(str, i_downpartDisapInd, 1);
  END;
  str[i_downpartDisapInd] := ' ';
  Ren_Text(str, 0, 600-16, pwin);
END;

PROCEDURE TTauGameMain.Draw_Scoreboard(pwin: PSDL_Surface);
VAR
  d: TSDL_Rect;
  s: string;
  psts: playerstats;
BEGIN
  d.x := (800 div 2) + ((TETRIS_BOARD_WIDTH  * 32) div 2);
  d.y := 16*2;
  d.w := 1;
  d.h := 1;
  SDL_BlitSurface(srf_square, NIL, pwin, @d);

  psts := board.GetPlayerstats();
  Str(psts.i_lines, s);
  Ren_Text('LINIJE: ' + s, d.x+16, d.y + 16, pwin);
  Str(psts.i_score, s);
  Ren_Text('BODOVI: ' + s, d.x+16, d.y + 32, pwin);
  Ren_Text('SLEDE$CA: ', d.x+16, d.y + 128, pwin);
  board.DrawReserve(pwin);
END;

PROCEDURE TTauGameMain.Draw_Board(pwin: PSDL_Surface);
VAR
  d: TSDL_Rect;
BEGIN
  d.x := TETRIS_BOARD_RENDER_OFFSETX;
  d.y := -6;
  d.w := 1;
  d.h := 1;
  SDL_BlitSurface(srf_backgroundBoard, NIL, pwin, @d);
  board.Draw(pwin);
END;

PROCEDURE TTauGameMain.Draw_Overlay(pwin: PSDL_Surface);
VAR
  d: TSDL_Rect;
BEGIN
  d.x := 0;
  d.y := 0;
  d.w := 1;
  d.h := 1;
  SDL_BlitSurface(srf_backgroundOverlay, NIL, pwin, @d);
END;

PROCEDURE TTauGameMain.Draw_PauseScreen(pwin: PSDL_Surface);
VAR
  str: string;
  str2: string;
BEGIN
  str := '                                $0$0$0$1$2$3$3::[PAUZA]::$3$3$2$1$0$0$0                    ';
  Ren_Text(str, TETRIS_BOARD_RENDER_OFFSETX + TETRIS_BOARD_WIDTH * 16 - (Length(str) DIV 2) * 16 + (((Length(str) MOD 2)* 16) DIV 2), 600-16*4, pwin);
  str2 := '           [nastavi]; restart; isk$lu$xi                            ';
  IF (i_menuoption = 1) THEN str2 := '           nastavi; [restart]; isk$lu$xi                            '
  ELSE IF (i_menuoption = 2) THEN str2 := '           nastavi; restart; [isk$lu$xi]                            ';
  Ren_Text(str2, 0, 600-16*3, pwin);
  Ren_Text(pauseStringMovText, 0, 600-16*2, pwin);
END;

PROCEDURE TTauGameMain.Draw_Background(pwin: PSDL_Surface);
VAR
  d: TSDL_Rect;
  x, y: integer;
  sx, sy: integer;
BEGIN
  sx  := Trunc(-f_backgroundoffsetX)-128;
  sy  := Trunc(-f_backgroundoffsetY)-128;
  x   := sx;
  y   := sy;
  d.x := 0;
  d.y := 0;
  d.w := 0;
  d.h := 0;
  WHILE (y < 600) DO
  BEGIN
    d.y := y;
    x   := sx;
    WHILE (x < 800) DO
    BEGIN
      d.x := x;
      IF (SDL_BlitSurface(srf_backgroundGrid, NIL, pwin, @d) <> 0) THEN
      BEGIN
        WriteLn('! REN ' + SDL_GetError());
      END;
      x := x + srf_backgroundGrid^.w;
    END;
    y := y + srf_backgroundGrid^.h;
  END;
END;

END.

