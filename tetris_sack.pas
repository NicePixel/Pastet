UNIT TETRIS_SACK;
INTERFACE
USES
  TETRIS_PIECE;
TYPE
  tetrissack = ARRAY [1 .. 7] OF TTauTetrisPiece;
  TTauTetrisSack = CLASS
  PRIVATE
    sack: tetrissack;
    index: integer;
  PUBLIC
    CONSTRUCTOR Create();
    DESTRUCTOR Destroy(); OVERRIDE;

    PROCEDURE Clear();
    PROCEDURE Reset();
    FUNCTION GetNext(): TTauTetrisPiece;
  END;
IMPLEMENTATION
CONSTRUCTOR TTauTetrisSack.Create();
VAR
  i: integer;
BEGIN
  index := 0;
  FOR i := 1 TO 7 DO
  BEGIN
    sack[i] := NIL;
  END;
  Reset();
END;

DESTRUCTOR TTauTetrisSack.Destroy();
BEGIN
  Clear();
END;

PROCEDURE TTauTetrisSack.Reset();
VAR
  ri, i: integer;
  used: ARRAY[1 .. 7] OF boolean;
BEGIN
  index := 0;
  ri    := -1;

  Clear();

  FOR i := 1 TO 7 DO
  BEGIN
    used[i] := FALSE;
  END;

  FOR i := 1 TO 7 DO
  BEGIN
    WHILE ((ri = -1) OR (used[ri + 1])) DO
    BEGIN
      ri := Random(7);
    END;
    used[ri + 1] := TRUE;

    IF (ri = 1) THEN
    BEGIN
      sack[i] := TTauTetrisPiece.Create(TETRIS_PIECE_RL);
    END
    ELSE IF (ri = 2) THEN
    BEGIN
      sack[i] := TTauTetrisPiece.Create(TETRIS_PIECE_L);
    END
    ELSE IF (ri = 3) THEN
    BEGIN
      sack[i] := TTauTetrisPiece.Create(TETRIS_PIECE_S);
    END
    ELSE IF (ri = 4) THEN
    BEGIN
      sack[i] := TTauTetrisPiece.Create(TETRIS_PIECE_Z);
    END
    ELSE IF (ri = 5) THEN
    BEGIN
      sack[i] := TTauTetrisPiece.Create(TETRIS_PIECE_I);
    END
    ELSE IF (ri = 6) THEN
    BEGIN
      sack[i] := TTauTetrisPiece.Create(TETRIS_PIECE_T);
    END
    ELSE
    BEGIN
      sack[i] := TTauTetrisPiece.Create(TETRIS_PIECE_Q);
    END;
  END;
END;

PROCEDURE TTauTetrisSack.Clear();
VAR
  i: integer;
BEGIN
  FOR i := 1 TO 7 DO
  BEGIN
    IF (sack[i] <> NIL) THEN
    BEGIN
      // sack[i].Free();
      sack[i] := NIL;
    END;
  END;
END;

FUNCTION TTauTetrisSack.GetNext(): TTauTetrisPiece;
VAR
  piece: TTauTetrisPiece;
BEGIN
  piece := NIL;
  index := index + 1;
  IF (index > 7) THEN
  BEGIN
    WriteLn('Sack index > 7, ', index);
    Reset();
    index := 1;
  END;
  IF (sack[index] = NIL) THEN
    RaiSE ExceptionClass.Create();
  GetNext := sack[index];
END;

END.

