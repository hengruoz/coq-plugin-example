
(** This line is an annotation of Camlp4 to support grammar extension. **)
(*i camlp4deps: "grammar/grammar.cma" i*)

(** Name of your plugin. You will use it in Coq file. **)
DECLARE PLUGIN "myplugin"

(** Well, TACTIC EXTEND ... END is a grammar extension defined in Coq! **)
TACTIC EXTEND tac_myplugin
| [ "killtrans"] ->
    [ My_prover.prove () ]
END;;
