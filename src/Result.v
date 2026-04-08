From parseque Require Import Category.

Inductive Result (E A : Type) : Type :=
  | SoftFail : E -> Result E A
  | HardFail : E -> Result E A
  | Value    : A -> Result E A.

Arguments SoftFail {_} {_}.
Arguments HardFail {_} {_}.
Arguments Value    {_} {_}.

Definition result {E A B : Type} (soft hard : E -> B) (val : A -> B)
  (r : Result E A) : B :=
  match r with
  | SoftFail e => soft e
  | HardFail e => hard e
  | Value a    => val a
  end.

Section Instances.

Context {E : Type}.

#[global]
Instance resultRawFunctor : RawFunctor (Result E) :=
  MkRawFunctor (fun _ _ f r =>
    match r with
    | SoftFail e => SoftFail e
    | HardFail e => HardFail e
    | Value a    => Value (f a)
    end).

#[global]
Instance resultRawApplicative : RawApplicative (Result E) :=
  MkRawApplicative
    (fun _ a => Value a)
    (fun _ _ rf ra =>
      match rf with
      | SoftFail e => SoftFail e
      | HardFail e => HardFail e
      | Value f    => fmap f ra
      end).

#[global]
Instance resultRawMonad : RawMonad (Result E) :=
  MkRawMonad (fun _ _ ra f =>
    match ra with
    | SoftFail e => SoftFail e
    | HardFail e => HardFail e
    | Value a    => f a
    end).

Definition choice {A : Type} (ra : Result E A) (fb : unit -> Result E A) : Result E A :=
  match ra with
  | SoftFail _ => fb tt
  | HardFail e => HardFail e
  | Value a    => Value a
  end.

End Instances.

Definition commitResult {E A : Type} (r : Result E A) : Result E A :=
  match r with
  | SoftFail e => HardFail e
  | HardFail e => HardFail e
  | Value a    => Value a
  end.