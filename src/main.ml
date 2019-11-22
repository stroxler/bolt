open Core
open Lex_and_parse
open Type_checker

let get_file_extension filename =
  String.split_on_chars filename ~on:['.'] |> List.last |> Option.value ~default:""

let bolt_file =
  let error_not_file filename =
    eprintf "'%s' is not a bolt file. Hint: use the .bolt extension\n%!" filename ;
    exit 1 in
  Command.Spec.Arg_type.create (fun filename ->
      match Sys.is_file filename with
      | `Yes ->
          if get_file_extension filename = "bolt" then filename
          else error_not_file filename
      | `No | `Unknown -> error_not_file filename)

let maybe_pprint_ast should_pprint_ast pprintfun ast =
  if should_pprint_ast then pprintfun Fmt.stdout ast ;
  ast

let run_program filename should_pprint_past should_pprint_tast () =
  let open Result in
  parse_program filename
  >>| maybe_pprint_ast should_pprint_past pprint_parsed_ast
  >>= type_check_program
  >>| maybe_pprint_ast should_pprint_tast pprint_typed_ast
  |> function Ok _ -> () | Error e -> Fmt.epr "%s" (Error.to_string_hum e)

let command =
  Command.basic ~summary:"Run bolt programs"
    ~readme:(fun () -> "A list of execution options")
    Command.Let_syntax.(
      let%map_open should_pprint_past =
        flag "-print-parsed-ast" no_arg
          ~doc:" Pretty print the parsed AST of the program"
      and should_pprint_tast =
        flag "-print-typed-ast" no_arg ~doc:" Pretty print the typed AST of the program"
      and filename = anon (maybe_with_default "-" ("filename" %: bolt_file)) in
      run_program filename should_pprint_past should_pprint_tast)

let () = Command.run ~version:"1.0" ~build_info:"RWO" command
