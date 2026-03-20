From Stdlib Require Import Ascii String NArith Lia.
From Stdlib Require Import List.
Import ListNotations.
From Stdlib Require Import Program.Wf Program.Utils.
From parseque Require Import StringAsList.
Local Open Scope N_scope.

Record Position : Type :=
  MkPosition { line : N ; col : N }.

Definition start : Position := MkPosition 0 0.

Definition update (c : ascii) (p : Position) : Position :=
  if (c =? "010")%char then MkPosition (N.succ (line p)) 0
  else MkPosition (line p) (N.succ (col p)).

Definition updates (cs : list ascii) (p : Position) : Position :=
  List.fold_left (fun pos c => update c pos) cs p.

Definition digit_to_ascii (n : N) : ascii :=
  ascii_of_N (48 + n).

Lemma pos_lt_wf : well_founded Pos.lt.
Proof.
  intro p. induction p using Pos.peano_ind.
  - constructor. intros y Hy. lia.
  - constructor. intros y Hy.
    assert (H: (y < p \/ y = p)%positive) by lia.
    destruct H.
    + apply IHp. assumption.
    + subst. exact IHp.
Qed.

Program Fixpoint pos_to_string_aux (p : positive) (acc : String)
  {wf Pos.lt p} : String :=
  let qr := N.pos_div_eucl p 10 in
  let acc' := digit_to_ascii (snd qr) :: acc in
  match fst qr with
  | N0     => acc'
  | Npos q' => pos_to_string_aux q' acc'
  end.
Next Obligation.
  pose proof (N.pos_div_eucl_spec p 10) as H.
  destruct (N.pos_div_eucl p 10) as [q r].
  simpl in *. lia.
Qed.
Next Obligation.
  apply measure_wf. exact pos_lt_wf.
Defined.

Definition N_to_string (n : N) : String :=
  match n with
  | N0     => ["0"]%char
  | Npos p => pos_to_string_aux p nil
  end.

Definition show (p : Position) : String :=
  N_to_string (line p) ++ [":"]%char ++ N_to_string (col p).
