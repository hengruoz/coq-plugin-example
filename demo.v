Declare ML Module "myplugin".

Theorem trans_imply_3: forall P1 P2 P3:Prop,
(P1 -> P2) -> (P2 -> P3) -> (P1 -> P3).
Proof.
killtrans.
Qed.

Theorem trans_imply_4: forall P1 P2 P3 P4,
(P1 -> P2) -> (P2 -> P3) -> (P3 -> P4) -> (P1 -> P4).
Proof.
killtrans.
Qed.

