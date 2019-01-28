UNIT TETRIS_BOARD;
INTERFACE
USES
  TETRIS_PIECE,
  TETRIS_SACK,
  SDL,
  SDL_IMAGE;
CONST
  TETRIS_BOARD_WIDTH                = 10;
  TETRIS_BOARD_HEIGHT               = 21;
  TETRIS_BOARD_TICKTIMER            = 96;
  TETRIS_BOARD_GHOSTTIMER           = 4;
  TETRIS_BOARD_RENDER_OFFSETX       = (800 div 2) - ((TETRIS_BOARD_WIDTH  * 32) div 2) - 6; { 12 - dodatna granica 6 + 6 }
  TETRIS_BOARD_PIECE_MARKER_CURRENT = 999;
  TETRIS_BOARD_PIECE_MARKER_GHOST   = 969;
TYPE
  playerstats = RECORD
    i_lines: integer;
    i_score: integer;
  END;

  arrSurfBlock = ARRAY [1 .. 7] OF PSDL_Surface;
  arrCount     = ARRAY [1 .. 7] OF integer;
  arrboardwidth = ARRAY [1 .. TETRIS_BOARD_WIDTH] OF integer;
  arrboard = ARRAY[1 .. TETRIS_BOARD_HEIGHT] OF arrboardwidth;
  TTetrisBoard = CLASS
  PRIVATE
    _board            : arrboard;
    ftimerstep        : real;
    spdup             : boolean;
    piece_lv0         : TTauTetrisPiece;
    piece_lv1         : TTauTetrisPiece;
    tetrissack        : TTauTetrisSack;
    arrSrfBlock       : arrSurfBlock;
    arrSrfBlockGhost0 : arrSurfBlock;
    arrSrfBlockGhost1 : arrSurfBlock;
    srf_block_ghost   : PSDL_Surface;
    srf_block_ghostReserve: PSDL_Surface;
    ghostblockState   : integer;
    ghostblockTimer   : real;
    blockcounter      : arrCount;
    playersts         : playerstats;
    f_speed           : real;
    b_gameover        : boolean;

    PROCEDURE CheckBoard();

    PROCEDURE Piece_DropDown(piece: TTauTetrisPiece; doscore: BOOLEAN);
    FUNCTION Piece_CanMove(CONST piece: TTauTetrisPiece; offX, offY: integer): boolean;
    FUNCTION CurPiece_CanMoveDown(): boolean;
    FUNCTION CurPiece_CanMoveX(a: integer): boolean;
    PROCEDURE CurPiece_DoNew();
    PROCEDURE CurPiece_DownOne();
  PUBLIC
    CONSTRUCTOR Create();
    DESTRUCTOR Destroy(); OVERRIDE;

    PROCEDURE Reset();

    PROCEDURE Nullify();
    PROCEDURE Draw(pwin: PSDL_Surface);
    PROCEDURE DrawReserve(pwin: PSDL_Surface);
    PROCEDURE Add(piece: TTauTetrisPiece; VAR bboard: arrboard; m: integer);
    PROCEDURE Tick();
    PROCEDURE SpeedUp(b: boolean);

    PROCEDURE CurPiece_DropDown();
    PROCEDURE CurPiece_MoveX(a: integer);
    PROCEDURE CurPiece_Rot(d: integer);
    PROCEDURE Piece_Rot(lv, d: integer);

    FUNCTION GetPiece(lv: integer): TTauTetrisPiece;
    FUNCTION GetGameOver(): boolean;
    FUNCTION GetPlayerstats(): playerstats;
    FUNCTION GetBlockCounter(): arrCount;
  END;

IMPLEMENTATION
CONSTRUCTOR TTetrisBoard.Create();
VAR
  srf_tmp: PSDL_Surface;
BEGIN
  ghostblockState   := 0;
  playersts.i_lines := 0;
  playersts.i_score := 0;
  piece_lv0         := NIL;
  tetrissack        := TTauTetrisSack.Create();
  b_gameover        := FALSE;

  srf_tmp         := IMG_Load('data/tex/block/0/t0.png');
  arrSrfBlock[1] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp         := IMG_Load('data/tex/block/0/t1.png');
  arrSrfBlock[2] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp         := IMG_Load('data/tex/block/0/t2.png');
  arrSrfBlock[3] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp         := IMG_Load('data/tex/block/0/t3.png');
  arrSrfBlock[4] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp         := IMG_Load('data/tex/block/0/t4.png');
  arrSrfBlock[5] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp         := IMG_Load('data/tex/block/0/t5.png');
  arrSrfBlock[6] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp         := IMG_Load('data/tex/block/0/t6.png');
  arrSrfBlock[7] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);

  srf_tmp             := IMG_Load('data/tex/block/0/g_t0.png');
  arrSrfBlockGhost0[1] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t1.png');
  arrSrfBlockGhost0[2] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t2.png');
  arrSrfBlockGhost0[3] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t3.png');
  arrSrfBlockGhost0[4] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t4.png');
  arrSrfBlockGhost0[5] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t5.png');
  arrSrfBlockGhost0[6] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t6.png');
  arrSrfBlockGhost0[7] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);

  srf_tmp             := IMG_Load('data/tex/block/0/g_t10.png');
  arrSrfBlockGhost1[1] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t11.png');
  arrSrfBlockGhost1[2] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t12.png');
  arrSrfBlockGhost1[3] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t13.png');
  arrSrfBlockGhost1[4] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t14.png');
  arrSrfBlockGhost1[5] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t15.png');
  arrSrfBlockGhost1[6] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);
  srf_tmp             := IMG_Load('data/tex/block/0/g_t16.png');
  arrSrfBlockGhost1[7] := SDL_DisplayFormatAlpha(srf_tmp);
  SDL_FreeSurface(srf_tmp);

  srf_block_ghost        := arrSrfBlockGhost0[1];
  srf_block_ghostReserve := arrSrfBlockGhost0[1];

  Nullify();
  CurPiece_DoNew();
END;

DESTRUCTOR TTetrisBoard.Destroy();
BEGIN
  SDL_FreeSurface(arrSrfBlockGhost0[1]);
  SDL_FreeSurface(arrSrfBlockGhost0[2]);
  SDL_FreeSurface(arrSrfBlockGhost0[3]);
  SDL_FreeSurface(arrSrfBlockGhost0[4]);
  SDL_FreeSurface(arrSrfBlockGhost0[5]);
  SDL_FreeSurface(arrSrfBlockGhost0[6]);
  SDL_FreeSurface(arrSrfBlockGhost0[7]);
  SDL_FreeSurface(arrSrfBlockGhost1[1]);
  SDL_FreeSurface(arrSrfBlockGhost1[2]);
  SDL_FreeSurface(arrSrfBlockGhost1[3]);
  SDL_FreeSurface(arrSrfBlockGhost1[4]);
  SDL_FreeSurface(arrSrfBlockGhost1[5]);
  SDL_FreeSurface(arrSrfBlockGhost1[6]);
  SDL_FreeSurface(arrSrfBlockGhost1[7]);
  SDL_FreeSurface(arrSrfBlock[1]);
  SDL_FreeSurface(arrSrfBlock[2]);
  SDL_FreeSurface(arrSrfBlock[3]);
  SDL_FreeSurface(arrSrfBlock[4]);
  SDL_FreeSurface(arrSrfBlock[5]);
  SDL_FreeSurface(arrSrfBlock[6]);
  SDL_FreeSurface(arrSrfBlock[7]);
  tetrissack.Free();
  piece_lv0.Free();
  piece_lv1.Free();
END;

PROCEDURE TTetrisBoard.CheckBoard();
VAR
  i, j, k: integer;
  clear: boolean;
  linesclear: integer;
BEGIN
  clear      := FALSE;
  linesclear := 0;
  i          := TETRIS_BOARD_HEIGHT;
  WHILE (i > 0) DO
  BEGIN
    clear := TRUE;
    FOR j := 1 TO TETRIS_BOARD_WIDTH DO
    BEGIN
      IF (_board[i][j] = TETRIS_PIECE_VOID) THEN
      BEGIN
        clear := FALSE;
      END;
    END;

    IF (clear) THEN
    BEGIN
      linesclear := linesclear + 1;
      FOR j := i DOWNTO 2 DO
      BEGIN
        FOR k := 1 TO TETRIS_BOARD_WIDTH DO
        BEGIN
          _board[j][k] := _board[j - 1][k];
        END;
      END;
      i := i + 1;
    END;

    i := i - 1;
  END;

  IF (linesclear > 0) THEN
  BEGIN
    f_speed := f_speed + 0.6;
  END;

  playersts.i_lines := playersts.i_lines + linesclear;
  playersts.i_score := playersts.i_score + (linesclear * linesclear * 1000);
END;

PROCEDURE TTetrisBoard.Piece_DropDown(piece: TTauTetrisPiece; doscore: BOOLEAN);
BEGIN
  WHILE (Piece_CanMove(piece, 0, 1)) DO
  BEGIN
    IF (doscore) THEN
    BEGIN
      playersts.i_score := playersts.i_score + 5;
    END;
    piece.MoveOffY(+1);
  END;
END;

PROCEDURE TTetrisBoard.CurPiece_DropDown();
BEGIN
  Piece_DropDown(piece_lv0, TRUE);
  ftimerstep := TETRIS_BOARD_TICKTIMER; { захтевај следећи корак }
END;

PROCEDURE TTetrisBoard.Piece_Rot(lv, d: integer);
VAR
  temp: TTauTetrisPiece;
  sav: TTauTetrisPiece;
BEGIN
  IF (lv = 1) THEN
  BEGIN
    piece_lv1.Rot(d);
  END
  ELSE
  BEGIN
    sav  := piece_lv0;
    temp := TTauTetrisPiece.Create(piece_lv0.GetTip());
    temp.SetOffX(sav.GetOffX());
    temp.SetOffY(sav.GetOffY());
    temp.SetRot(sav.GetRot());
    temp.Rot(d);
    piece_lv0 := temp;
    IF (NOT Piece_CanMove(piece_lv0, 0, 0)) THEN
    BEGIN
      piece_lv0 := sav;
      temp.Free();
    END
    ELSE
    BEGIN
      sav.Free();
    END;
  END
END;

PROCEDURE TTetrisBoard.CurPiece_Rot(d: integer);
VAR
  temp: TTauTetrisPiece;
  sav: TTauTetrisPiece;
BEGIN
  sav  := piece_lv0;
  temp := TTauTetrisPiece.Create(piece_lv0.GetTip());
  temp.SetOffX(sav.GetOffX());
  temp.SetOffY(sav.GetOffY());
  temp.SetRot(sav.GetRot());
  temp.Rot(d);
  piece_lv0 := temp;
  IF (NOT Piece_CanMove(piece_lv0, 0, 0)) THEN
  BEGIN
    piece_lv0 := sav;
    temp.Free();
  end
  ELSE
  BEGIN
    sav.Free();
  END;
END;

PROCEDURE TTetrisBoard.CurPiece_DownOne();
BEGIN
  playersts.i_score := playersts.i_score + 5;
  piece_lv0.MoveOffY(+1);
END;

PROCEDURE TTetrisBoard.SpeedUp(b: boolean);
BEGIN
  spdup:= b;
END;

FUNCTION TTetrisBoard.Piece_CanMove(CONST piece: TTauTetrisPiece; offX, offY: integer): boolean;
VAR
  b: boolean;
  i, j: integer;
BEGIN
  { Све ради како треба, плиз не дирај. }
  b := TRUE;
  FOR j := 1 TO 4 DO
  BEGIN
    FOR i := 1 TO 4 DO
    BEGIN
      IF (piece.GetRep()[j][i] <> 0) THEN
      BEGIN
        IF ((piece.GetOffY() + j + offY) > (TETRIS_BOARD_HEIGHT-3)) THEN
        BEGIN
          b := FALSE;
        END
        ELSE IF ((piece.GetOffX() + i + offX) > TETRIS_BOARD_WIDTH) THEN
        BEGIN
          b := FALSE;
        END
        ELSE IF ((piece.GetOffX() + i + offX) < 1) THEN
        BEGIN
          b := FALSE;
        END
        ELSE IF (_board[piece.GetOffY() + j + offY][piece.GetOffX() + i + offX] <> TETRIS_PIECE_VOID) THEN
        BEGIN
          b := FALSE;
        END;
      END;
    END;
  END;
  Piece_CanMove := b;
END;


PROCEDURE TTetrisBoard.CurPiece_DoNew();
BEGIN
  IF (piece_lv1 = NIL) THEN
  BEGIN
    piece_lv1 := tetrissack.GetNext();
  END;

  IF (piece_lv0 <> NIL) THEN
  BEGIN
    piece_lv0.Free();
  END;

  piece_lv0 := piece_lv1;
  piece_lv1 := tetrissack.GetNext();
  IF (piece_lv0 = NIL) THEN
  BEGIN
    WriteLn('piece_lv0 := tetrissack.GetNext(); -> NIL');
    RAISE ExceptionClass.Create();
  END;
  blockcounter[piece_lv1.GetTip()] := blockcounter[piece_lv1.GetTip()] + 1;

  piece_lv0.MoveOffX((TETRIS_BOARD_WIDTH DIV 2) - 1);

  if (Piece_CanMove(piece_lv0, 0, 0) <> TRUE) THEN
  BEGIN
    b_gameover := true;
  END;
END;

PROCEDURE TTetrisBoard.CurPiece_MoveX(a: integer);
BEGIN
  IF (CurPiece_CanMoveX(a)) THEN
  BEGIN
    piece_lv0.MoveOffX(a);
  END;
END;

FUNCTION TTetrisBoard.CurPiece_CanMoveDown(): boolean;
BEGIN
  CurPiece_CanMoveDown := Piece_CanMove(piece_lv0, 0, 1);
END;

FUNCTION TTetrisBoard.CurPiece_CanMoveX(a: integer): boolean;
BEGIN
  CurPiece_CanMoveX := Piece_CanMove(piece_lv0, a, 0);
END;

PROCEDURE TTetrisBoard.Tick();
VAR
  ftimer: real;
BEGIN
  ftimerstep      := ftimerstep + 1.0;
  ghostblockTimer := ghostblockTimer + 1.0;
  ftimer          := ftimerstep;
  IF (spdup) THEN
  BEGIN
    ftimer := ftimer * 8;
  END;

  IF (ghostblockTimer > TETRIS_BOARD_GHOSTTIMER) THEN
  BEGIN
    ghostblockTimer := 0.0;
    ghostblockState := ghostblockState + 1;
    IF (ghostblockState > 1) THEN
    BEGIN
      ghostblockState := 0;
    END;

    IF (ghostblockState = 0) THEN
    BEGIN
     srf_block_ghost        := arrSrfBlockGhost0[piece_lv0.GetTip()];
     srf_block_ghostReserve := arrSrfBlockGhost0[piece_lv1.GetTip()];
    END
    ELSE
    BEGIN
     srf_block_ghost        := arrSrfBlockGhost1[piece_lv0.GetTip()];
     srf_block_ghostReserve := arrSrfBlockGhost1[piece_lv1.GetTip()];
    END;
  END;

  IF ((ftimer + f_speed) > TETRIS_BOARD_TICKTIMER) THEN
  BEGIN
    ftimerstep := 0.0;
    IF (CurPiece_CanMoveDown()) THEN
    BEGIN
        CurPiece_DownOne();
    END
    ELSE
    BEGIN
      Add(piece_lv0, _board, piece_lv0.GetTip()); { сачувај тетромин }
      CheckBoard();
      CurPiece_DoNew();
    END;
  END;
END;

PROCEDURE TTetrisBoard.Add(piece: TTauTetrisPiece; VAR bboard: arrboard; m: integer);
VAR
  x: integer;
  y: integer;
BEGIN
  FOR x := 1 TO 4 DO
  BEGIN
    FOR y := 1 TO 4 DO
    BEGIN
      IF (piece.GetRep()[y][x] <> 0) THEN
      BEGIN
        IF ((y + piece.GetOffY() <= 0)) THEN
        BEGIN
          CONTINUE;
        END;
        bboard[y + piece.GetOffY()][x + piece.GetOffX()] := m;
      END;
    END;
  END;
END;

PROCEDURE TTetrisBoard.Draw(pwin: PSDL_Surface);
VAR
  d: TSDL_Rect;
  i, j: integer;
  tempBoard: arrboard;
  piecetemp: TTauTetrisPiece;
BEGIN
  piecetemp := NIL;
  tempBoard := _board;
  d.x := 0;
  d.y := 0;
  d.w := 1;
  d.h := 1;
  piecetemp := TTauTetrisPiece.Create(piece_lv0.GetTip());
  piecetemp.SetOffX(piece_lv0.GetOffX());
  piecetemp.SetOffY(piece_lv0.GetOffY());
  piecetemp.SetRot(piece_lv0.GetRot());
  Piece_DropDown(piecetemp, FALSE);
  Add(piecetemp, tempBoard, TETRIS_BOARD_PIECE_MARKER_GHOST);
  Add(piece_lv0, tempBoard, piece_lv0.GetTip());
  piecetemp.Free();
  FOR j := 1 TO TETRIS_BOARD_WIDTH DO
  BEGIN
    FOR i := 1 TO TETRIS_BOARD_HEIGHT DO
    BEGIN
      IF (tempBoard[i][j] <> TETRIS_PIECE_VOID) THEN
      BEGIN
        d.x := (j - 1) * 32 + TETRIS_BOARD_RENDER_OFFSETX + 6;
        d.y := (i - 1) * 32;
        IF (tempBoard[i][j] = TETRIS_BOARD_PIECE_MARKER_GHOST) THEN
        BEGIN
          SDL_BlitSurface(srf_block_ghost, NIL, pwin, @d);
        END
        ELSE
        BEGIN
          SDL_BlitSurface(arrSrfBlock[tempBoard[i][j]], NIL, pwin, @d);
        END;
      END;  
    END
  END;
END;

PROCEDURE TTetrisBoard.Reset();
BEGIN
  ghostblockState   := 0;
  playersts.i_lines := 0;
  playersts.i_score := 0;
  piece_lv0         := NIL;
  tetrissack.Free();
  tetrissack        := TTauTetrisSack.Create();
  b_gameover        := FALSE;
  f_speed := 0;
  Nullify();
  CurPiece_DoNew();
END;

PROCEDURE TTetrisBoard.DrawReserve(pwin: PSDL_Surface);
VAR
  d: TSDL_Rect;
  x, y: integer;
BEGIN
  d.w := 1;
  d.h := 1;
  FOR x := 1 TO 4 DO
  BEGIN
    FOR y := 1 TO 4 DO
    BEGIN
      d.x := x*32 + (TETRIS_BOARD_RENDER_OFFSETX*7) DIV 3 + 32 + 16 - 8;
      d.y := y*32 + 256 - 96;
      IF (piece_lv1.GetRep()[y][x] <> 0) THEN
      BEGIN
        SDL_BlitSurface(arrSrfBlock[piece_lv1.GetTip()], NIL, pwin, @d);
      END
      ELSE
      BEGIN
        SDL_BlitSurface(srf_block_ghostReserve, NIL, pwin, @d);
      END;
    END;
  END;
END;

PROCEDURE TTetrisBoard.Nullify();
VAR
  i, j: integer;
BEGIN
  FOR i := 1 TO 7 DO
  BEGIN
    blockcounter[i] := 0;
  END;

  FOR i := 1 TO TETRIS_BOARD_HEIGHT DO
  BEGIN
    FOR j := 1 TO TETRIS_BOARD_WIDTH DO
    BEGIN
      _board[i][j] := TETRIS_PIECE_VOID;
    END;
  END;
END;

FUNCTION TTetrisBoard.GetGameOver(): boolean;
BEGIN
  GetGameOver := b_gameover;
END;

FUNCTION TTetrisBoard.GetPlayerstats(): playerstats;
BEGIN
  GetPlayerstats := playersts;
END;

FUNCTION TTetrisBoard.GetPiece(lv: integer): TTauTetrisPiece;
VAR
  t: TTauTetrisPiece;
BEGIN
  t := piece_lv0;
  IF (lv = 1) THEN
  BEGIN
    t := piece_lv1;
  END;
  GetPiece := t;
END;

FUNCTION TTetrisBoard.GetBlockCounter(): arrCount;
BEGIN
  GetBlockCounter := blockcounter;
END;

END.

