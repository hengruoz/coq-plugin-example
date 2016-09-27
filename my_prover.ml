(* kernel/term.ml: define Coq terms (term of Calculus of Inductive Constructions
, CiC) and related operations. *)
open Term
(* library/nameops.ml: some operations about names. We only use pr_id. *)
open Nameops

(* Check a term whether is a arrow type. If it's an arrow type, like "P1 -> P2",
   we apply it. Prod means "dependent product", which you can consider as
   "forall ...". In CiC, arrow type is just a particular case of dependent product. *)
let is_prod constr =
  match kind_of_term constr with
  | Prod _ -> true
  | _ -> false

(* Continue applying hypotheses.
Tactics (tactics/tactics.ml) contains many primitive tactics, like "apply",
"intros" and so on.
Tacticals (tactics/tacticals.ml) can combinate the tactics to a new tactic
(like MonadTransformer in Haskell). New is a module in Tacticals, I'll
introduce it later. tclTHEN is a tactical, whose type is "tactic -> tactic -> tactic".
When Coq evaluates "tclTHEN A B", Coq will apply tactic A and B in sequence.
h is a list of hypotheses. In Coq, each hypothesis is a triple, for example,
"H: P1 -> P2" is stored in Coq like this:
  ("H", _, "P1 -> P2").
Be careful, Coq stores hypotheses in a reverse order. If your hypotheses like this:
  H: ...
  H0: ...
  H1: ...
Coq will store them like this:
  [H1; H0; H]. *)
let rec apply_chain h =
  let (id, _, _) = List.hd h in
  let tac = Tactics.apply (Term.mkVar id) in
  let h = List.tl h in
  let rec apply_prod h =
    match h with
    | (id, _, constr)::hs ->
      if is_prod constr
      then Tacticals.New.tclTHEN (Tactics.apply (Term.mkVar id)) (apply_prod hs)
      else tac
    | [] -> tac
  in
  apply_prod h

(* Proofview (proofs/proofview.ml) shows the state of proofs. Goal.nf_enter tell
Coq we will enter a new proof. So we need Tacticals.New.xxx. Goal.hyps is a
function to extract hypotheses from the environment. *)
let prove () =
  Proofview.Goal.nf_enter ( fun gl ->
    Tacticals.New.tclTHEN Tactics.intros
      (Proofview.Goal.nf_enter
        begin
          fun gl ->
          let hyps = Proofview.Goal.hyps gl in
          apply_chain hyps
        end
    )
  )
