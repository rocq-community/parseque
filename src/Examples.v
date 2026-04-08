From parseque Require Import Running Parseque Result Position Monad.
From Stdlib Require Import Ascii String NArith.

Section ArithmeticLanguage.

Context
  {Toks : nat -> Type} `{Sized Toks ascii}
  {M : Type -> Type} `{RawMonad M} `{RawAlternative M}.

Inductive Expr : Type :=
  | EEmb : Term -> Expr
  | EAdd : Expr -> Term -> Expr
  | ESub : Expr -> Term -> Expr
with Term : Type :=
  | TEmb : Factor -> Term
  | TMul : Term -> Factor -> Term
  | TDiv : Term -> Factor -> Term
with Factor : Type :=
  | FEmb : Expr -> Factor
  | FLit : nat -> Factor
.

Record Language (n : nat) : Type := MkLanguage
  { _expr   : Parser Toks ascii M Expr n
  ; _term   : Parser Toks ascii M Term n
  ; _factor : Parser Toks ascii M Factor n
  }.

Arguments MkLanguage {_}.

Definition language : [ Language ] := Fix Language (fun _ rec =>
  let addop  := EAdd <$ char "+" <|> ESub <$ char "-" in
  let mulop  := TMul <$ char "*" <|> TDiv <$ char "/" in
  let factor := FEmb <$> parens (Induction.map _expr _ rec) <|> FLit <$> decimal_nat in
  let term   := hchainl (TEmb <$> factor) mulop factor in
  let expr   := hchainl (EEmb <$> term) addop term in
  MkLanguage expr term factor).

Definition expr   : [ Parser Toks ascii M Expr   ] := fun n => _expr n (language n).
Definition term   : [ Parser Toks ascii M Term   ] := fun n => _term n (language n).
Definition factor : [ Parser Toks ascii M Factor ] := fun n => _factor n (language n).

End ArithmeticLanguage.

Local Open Scope string_scope.

Definition test1 : check "1+1" expr := MkSingleton
  (EAdd (EEmb (TEmb (FLit 1)))
              (TEmb (FLit 1))).

Definition test2 : check "1+(2*31-4)" expr := MkSingleton
 (EAdd (EEmb (TEmb (FLit 1)))
             (TEmb (FEmb (ESub (EEmb (TMul (TEmb (FLit 2)) (FLit 31)))
                                           (TEmb (FLit 4)))))).

(* Error reporting examples using ParsequeT *)

Section ErrorReporting.

Local Instance altInst : RawAlternative (ParsequeT Position) :=
  parsequeTRawAlternative id.

Context
  {Toks : nat -> Type} `{Sized Toks ascii}
  {n : nat}.

Definition binary_digit : Parser Toks ascii (ParsequeT Position) nat n :=
  0 <$ exact "0"%char <|> 1 <$ exact "1"%char.

Definition hex_digit : Parser Toks ascii (ParsequeT Position) nat n :=
  alts ( (0  <$ exact "0"%char) :: (1  <$ exact "1"%char)
      :: (2  <$ exact "2"%char) :: (3  <$ exact "3"%char)
      :: (4  <$ exact "4"%char) :: (5  <$ exact "5"%char)
      :: (6  <$ exact "6"%char) :: (7  <$ exact "7"%char)
      :: (8  <$ exact "8"%char) :: (9  <$ exact "9"%char)
      :: (10 <$ exact "a"%char) :: (11 <$ exact "b"%char)
      :: (12 <$ exact "c"%char) :: (13 <$ exact "d"%char)
      :: (14 <$ exact "e"%char) :: (15 <$ exact "f"%char)
      :: nil).

Definition digits (base : nat) (digit : Parser Toks ascii (ParsequeT Position) nat n) :
  Parser Toks ascii (ParsequeT Position) nat n :=
  let convert ds := NEList.foldl (fun ih d => base * ih + d) ds 0
  in Combinators.map convert (nelist digit).

(* Binary: "0b" prefix, then committed to binary digits *)
Definition binary : Parser Toks ascii (ParsequeT Position) nat n :=
  exact "0"%char &> exact "b"%char &>
    commitP (digits 2 binary_digit).

(* Hexadecimal: "0x" prefix, then committed to hex digits *)
Definition hexadecimal : Parser Toks ascii (ParsequeT Position) nat n :=
  exact "0"%char &> exact "x"%char &>
    commitP (digits 16 hex_digit).

(* Try binary, then hex *)
Definition number : Parser Toks ascii (ParsequeT Position) nat n :=
  binary <|> hexadecimal.

End ErrorReporting.

(* "0b101" parses as binary 5 *)
Definition test3 : checkResult id "0b101" (fun n => number) =
  inr 5 := eq_refl.

(* "0xff" parses as hex 255 *)
Definition test4 : checkResult id "0xff" (fun n => number) =
  inr 255 := eq_refl.

(* "0b0000002": error at "2" (col 8), not at "b" (col 1) *)
Definition test5 : checkResult id "0b0000002" (fun n => number) =
  inl (MkPosition 0%N 8%N) := eq_refl.
