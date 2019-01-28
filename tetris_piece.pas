UNIT TETRIS_PIECE;
INTERFACE
CONST                   
  TETRIS_PIECE_VOID = 0;
  TETRIS_PIECE_L    = 1;
  TETRIS_PIECE_Z    = 2;
  TETRIS_PIECE_S    = 3;
  TETRIS_PIECE_Q    = 4;
  TETRIS_PIECE_RL   = 5;
  TETRIS_PIECE_T    = 6;
  TETRIS_PIECE_I    = 7;
  
TYPE
  arrpiece = ARRAY[1 .. 4] OF ARRAY[1 .. 4] OF integer;
  TTauTetrisPiece = CLASS
  PRIVATE  
    _rep: arrpiece;
    _tip: integer;
    _x  : integer;
    _y  : integer;
    _rot: integer;

    PROCEDURE ResetPiece();
  PUBLIC
    CONSTRUCTOR Create(t: integer);
    DESTRUCTOR Destroy(); OVERRIDE;

    PROCEDURE Rot(d: integer);
    PROCEDURE MoveOffX(a: integer);
    PROCEDURE MoveOffY(a: integer);
    PROCEDURE SetOffX(a: integer);
    PROCEDURE SetOffY(a: integer);
    PROCEDURE SetRot(a: integer);
    FUNCTION GetTip(): integer;
    FUNCTION GetRep(): arrpiece;
    FUNCTION GetOffX(): integer;
    FUNCTION GetOffY(): integer;
    FUNCTION GetRot(): integer;
  END;

IMPLEMENTATION
CONSTRUCTOR TTauTetrisPiece.Create(t: integer);
BEGIN
  _rot := 0;
  _x   := 0;
  _y   := 0;
  _tip := t;
  CASE t OF
  TETRIS_PIECE_L:
  BEGIN
      _rep[1][1] := 1; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 0; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 1; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
  END;
  TETRIS_PIECE_RL:
  BEGIN
      _rep[1][1] := 0; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 0; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 1; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
  END;
  TETRIS_PIECE_S:
  BEGIN
      _rep[1][1] := 0; _rep[1][2] := 1; _rep[1][3] := 1; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
  END;
  TETRIS_PIECE_Z:
  BEGIN
      _rep[1][1] := 1; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 0; _rep[2][2] := 1; _rep[2][3] := 1; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
  END;
  TETRIS_PIECE_I:
  BEGIN
      _rep[1][1] := 1; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 0; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 1; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
  END;
  TETRIS_PIECE_Q:
  BEGIN
      _rep[1][1] := 1; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
  END;
  TETRIS_PIECE_T:
  BEGIN
      _rep[1][1] := 1; _rep[1][2] := 1; _rep[1][3] := 1; _rep[1][4] := 0;
      _rep[2][1] := 0; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
  END;
  END;
END;

DESTRUCTOR TTauTetrisPiece.Destroy();
BEGIN

END;

PROCEDURE TTauTetrisPiece.Rot(d: integer);
BEGIN
  _rot := _rot + d;
  IF (_rot < 0) THEN
  BEGIN
    _rot := 3;
  END;

  IF (_rot > 3) THEN
  BEGIN
    _rot := 0;
  END;

  ResetPiece();
END;

PROCEDURE TTauTetrisPiece.ResetPiece();
BEGIN
  IF (_tip = TETRIS_PIECE_L) THEN
  BEGIN
    IF (_rot = 0) THEN
    BEGIN
      _rep[1][1] := 1; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 0; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 1; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF (_rot = 1) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 1; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF (_rot = 2) THEN
    BEGIN
      _rep[1][1] := 1; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 0; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 1; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF (_rot = 3) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 0; _rep[2][2] := 0; _rep[2][3] := 1; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 1; _rep[3][3] := 1; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END;
  END
  ELSE IF (_tip = TETRIS_PIECE_RL) THEN
  BEGIN
    IF (_rot = 0) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 0; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 1; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF (_rot = 1) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 0; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 1; _rep[3][3] := 1; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF (_rot = 2) THEN
    BEGIN
      _rep[1][1] := 1; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 0; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF (_rot = 3) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 1; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 0; _rep[3][3] := 1; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END;
  END
  ELSE IF (_tip = TETRIS_PIECE_T) THEN
  BEGIN
    IF (_rot = 0) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 1; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 1; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF (_rot = 1) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 1; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF (_rot = 2) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 1; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF (_rot = 3) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 0; _rep[2][2] := 1; _rep[2][3] := 1; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 1; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END;
  END
  ELSE IF (_tip = TETRIS_PIECE_S) THEN
  BEGIN
    IF ((_rot = 0) OR (_rot = 2)) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 1; _rep[1][3] := 1; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF ((_rot = 1) OR (_rot = 3)) THEN
    BEGIN
      _rep[1][1] := 1; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 1; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END;
  END
  ELSE IF (_tip = TETRIS_PIECE_Z) THEN
  BEGIN
    IF ((_rot = 0) OR (_rot = 2)) THEN
    BEGIN
      _rep[1][1] := 1; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 0; _rep[2][2] := 1; _rep[2][3] := 1; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF ((_rot = 1) OR (_rot = 3)) THEN
    BEGIN
      _rep[1][1] := 0; _rep[1][2] := 1; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 1; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END;
  END
  ELSE IF (_tip = TETRIS_PIECE_I) THEN
  BEGIN
    IF ((_rot = 0) OR (_rot = 2)) THEN
    BEGIN
      _rep[1][1] := 1; _rep[1][2] := 0; _rep[1][3] := 0; _rep[1][4] := 0;
      _rep[2][1] := 1; _rep[2][2] := 0; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 1; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 1; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END
    ELSE IF ((_rot = 1) OR (_rot = 3)) THEN
    BEGIN
      _rep[1][1] := 1; _rep[1][2] := 1; _rep[1][3] := 1; _rep[1][4] := 1;
      _rep[2][1] := 0; _rep[2][2] := 0; _rep[2][3] := 0; _rep[2][4] := 0;
      _rep[3][1] := 0; _rep[3][2] := 0; _rep[3][3] := 0; _rep[3][4] := 0;
      _rep[4][1] := 0; _rep[4][2] := 0; _rep[4][3] := 0; _rep[4][4] := 0;
    END;
  END
  ELSE IF (_tip = TETRIS_PIECE_Q) THEN
  BEGIN
  END;
END;

PROCEDURE TTauTetrisPiece.MoveOffX(a: integer);
BEGIN
  _x := _x + a;
END;

PROCEDURE TTauTetrisPiece.MoveOffY(a: integer);
BEGIN
  _y := _y + a;
END;

PROCEDURE TTauTetrisPiece.SetOffX(a: integer);
BEGIN
  _x := a;
END;

PROCEDURE TTauTetrisPiece.SetOffY(a: integer);
BEGIN
  _y := a;
END;

PROCEDURE TTauTetrisPiece.SetRot(a: integer);
BEGIN
  _rot := a;
  ResetPiece();
END;

FUNCTION TTauTetrisPiece.GetTip(): integer;
BEGIN
  GetTip := _tip;
END;

FUNCTION TTauTetrisPiece.GetRep(): arrpiece;
BEGIN
  GetRep := _rep;
END;

FUNCTION TTauTetrisPiece.GetOffX(): integer;
BEGIN
  GetOffX := _x;
END;

FUNCTION TTauTetrisPiece.GetOffY(): integer;
BEGIN
  GetOffY := _y;
END;

FUNCTION TTauTetrisPiece.GetRot(): integer;
BEGIN
  GetRot := _rot;
END;

END.

