open Ast.Ast_types
open Core
open Result
open Type_expr

let check_no_duplicate_class_names class_defns =
  if
    List.contains_dup
      ~compare:
        (fun (Parsing.Parsed_ast.TClass (name_1, _, _, _))
             (Parsing.Parsed_ast.TClass (name_2, _, _, _)) ->
        if name_1 = name_2 then 0 else 1)
      class_defns
  then
    Error
      (Error.of_string
         (Fmt.str "Duplicate class declarations. Classes must have distinct names.@."))
  else Ok ()

let check_no_duplicate_fields error_prefix field_defns =
  if
    List.contains_dup
      ~compare:(fun (TField (_, name_1, _)) (TField (_, name_2, _)) ->
        if name_1 = name_2 then 0 else 1)
      field_defns
  then Error (Error.of_string (Fmt.str "%s Duplicate field declarations.@." error_prefix))
  else Ok ()

let check_req_field_present error_prefix
    (TRequire (TField (mode, trait_field_name, type_field))) class_fields =
  if
    List.exists
      ~f:(fun class_field -> class_field = TField (mode, trait_field_name, type_field))
      class_fields
  then Ok ()
  else
    Error
      (Error.of_string
         (Fmt.str "%s missing required field: %s@." error_prefix
            (Field_name.to_string trait_field_name)))

(* Class must include all fields required by the trait it is implementing *)
let check_trait_req_fields_present error_prefix (TTrait (_name, _cap, req_field_defns))
    class_fields =
  List.fold ~init:(Ok ())
    ~f:(fun result_acc req_field_defn ->
      result_acc
      >>= fun () -> check_req_field_present error_prefix req_field_defn class_fields)
    req_field_defns

(* Check class's cap-trait is valid by seeing if there is a matching trait definition
   (same name and capability) - we return this trait defn *)
let check_valid_cap_trait error_prefix (TCapTrait (capability, trait_name)) trait_defns =
  let matching_trait_defns =
    List.filter
      ~f:(fun (TTrait (name, cap, _req_fd_defns)) ->
        name = trait_name && cap = capability)
      trait_defns in
  match matching_trait_defns with
  | []           -> Error
                      (Error.of_string
                         (Fmt.str "%s No matching declarations.@." error_prefix))
  | [trait_defn] -> Ok trait_defn
  | _            ->
      Error (Error.of_string (Fmt.str "%s Duplicate trait declarations.@." error_prefix))

(* Type check method bodies *)

let init_env_from_method_params params class_name =
  let param_env =
    List.map ~f:(fun (TParam (type_expr, param_name)) -> (param_name, type_expr)) params
  in
  (Var_name.of_string "this", TEClass class_name) :: param_env

let type_method_defn class_defns trait_defns function_defns class_name
    (Parsing.Parsed_ast.TFunction (method_name, return_type, params, body_expr)) =
  infer_type_expr class_defns trait_defns function_defns body_expr
    (init_env_from_method_params params class_name)
  >>= fun (typed_body_expr, body_return_type) ->
  if body_return_type = return_type then
    Ok (Typed_ast.TFunction (method_name, return_type, params, typed_body_expr))
  else
    Error
      (Error.of_string
         (Fmt.str
            "Type Error for method %s: expected return type of %s but got %s instead"
            (Function_name.to_string method_name)
            (string_of_type return_type)
            (string_of_type body_return_type)))

(* Check a given class definition is well formed *)
let type_class_defn
    (Parsing.Parsed_ast.TClass
      (class_name, TCapTrait (capability, trait_name), class_fields, method_defns))
    class_defns trait_defns function_defns =
  (* All type error strings for a particular class have same prefix *)
  let error_prefix = Fmt.str "%s has a type error: " (Class_name.to_string class_name) in
  check_no_duplicate_fields error_prefix class_fields
  >>= fun () ->
  (* Check class's cap-trait is valid *)
  check_valid_cap_trait error_prefix (TCapTrait (capability, trait_name)) trait_defns
  (* Check class's required fields are valid *)
  >>= fun matching_trait_defn ->
  check_trait_req_fields_present error_prefix matching_trait_defn class_fields
  >>= fun () ->
  Result.all
    (List.map
       ~f:(type_method_defn class_defns trait_defns function_defns class_name)
       method_defns)
  >>| fun typed_method_defns ->
  Typed_ast.TClass
    (class_name, TCapTrait (capability, trait_name), class_fields, typed_method_defns)

(* Check all class definitions are well formed *)
let type_class_defns class_defns trait_defns function_defns =
  check_no_duplicate_class_names class_defns
  >>= fun () ->
  Result.all
    (List.map
       ~f:(fun class_defn ->
         type_class_defn class_defn class_defns trait_defns function_defns)
       class_defns)
