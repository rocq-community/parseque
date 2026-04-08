From parseque Require Import Category Result Position.
From Stdlib Require Import Ascii.

Definition ParsequeT (E A : Type) : Type :=
  Position -> Result E (A * Position).

Section ParsequeTInstances.

Context {E : Type}.

#[global]
Instance parsequeTRawFunctor : RawFunctor (ParsequeT E) :=
  MkRawFunctor (fun _ _ f ma pos =>
    fmap (fun '(a, pos') => (f a, pos')) (ma pos)).

#[global]
Instance parsequeTRawApplicative : RawApplicative (ParsequeT E) :=
  MkRawApplicative
    (fun _ a pos => Value (a, pos))
    (fun _ _ mf ma pos =>
      bind (mf pos) (fun '(f, pos') =>
      fmap (fun '(a, pos'') => (f a, pos'')) (ma pos'))).

#[global]
Instance parsequeTRawMonad : RawMonad (ParsequeT E) :=
  MkRawMonad (fun _ _ ma f pos =>
    bind (ma pos) (fun '(a, pos') => f a pos')).

Definition getPosition : ParsequeT E Position :=
  fun pos => Value (pos, pos).

Definition commitT {A : Type} (ma : ParsequeT E A) : ParsequeT E A :=
  fun pos => commitResult (ma pos).

#[global]
Instance parsequeTRawCommit : RawCommit (ParsequeT E) :=
  MkRawCommit (fun _ => commitT).

#[global]
Instance parsequeTRecordToken : RecordToken (ParsequeT E) ascii :=
  MkRecordToken (fun c pos => Value (tt, update c pos)).

End ParsequeTInstances.

Section ParsequeTAlternative.

Context {E : Type} (toError : Position -> E).

#[global]
Instance parsequeTRawAlternative : RawAlternative (ParsequeT E) :=
  MkRawAlternative
    (fun _ pos => SoftFail (toError pos))
    (fun _ ma mb pos =>
      choice (ma pos) (fun _ => mb tt pos)).

End ParsequeTAlternative.

Arguments parsequeTRawAlternative {_} _.

Definition runParsequeT {E A : Type} (ma : ParsequeT E A) : Result E (A * Position) :=
  ma start.
