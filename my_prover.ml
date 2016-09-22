open Term
open Nameops

let is_prod constr =
  match kind_of_term constr with
  | Prod _ -> true
  | _ -> false

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
