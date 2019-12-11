open Core
open Print_execution

let%expect_test "Seq of exprs" =
  print_execution
    " 
    begin 
    (fun x : int -> x end) 4;
    (fun x : int -> x end) 5;
    (fun x : int -> x end) 6
    end
  " ;
  [%expect
    {|
    ----- Step 0 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 4); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [  ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 1 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ PUSH(Int: 4); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Closure: ( Body: [ BIND(x); STACK_LOOKUP(x); SWAP; POP
      ] Env: [  ]) ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 2 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 4, Value: Closure: ( Body: [ BIND(x); STACK_LOOKUP(x); SWAP; POP
      ] Env: [  ]) ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 3 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ BIND(x); STACK_LOOKUP(x); SWAP; POP; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 4, Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 4 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ STACK_LOOKUP(x); SWAP; POP; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Env: [ x -> Int: 4 ], Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 5 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SWAP; POP; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 4, Env: [ x -> Int: 4 ], Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 6 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Env: [ x -> Int: 4 ], Value: Int: 4, Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 7 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 4, Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 8 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Env: [  ], Value: Int: 4 ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 9 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 4 ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 10 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [  ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 11 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ PUSH(Int: 5); APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Closure: ( Body: [ BIND(x); STACK_LOOKUP(x); SWAP; POP
      ] Env: [  ]) ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 12 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ APPLY; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 5, Value: Closure: ( Body: [ BIND(x); STACK_LOOKUP(x); SWAP; POP
      ] Env: [  ]) ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 13 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ BIND(x); STACK_LOOKUP(x); SWAP; POP; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 5, Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 14 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ STACK_LOOKUP(x); SWAP; POP; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Env: [ x -> Int: 5 ], Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 15 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SWAP; POP; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 5, Env: [ x -> Int: 5 ], Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 16 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Env: [ x -> Int: 5 ], Value: Int: 5, Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 17 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SWAP; POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 5, Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 18 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Env: [  ], Value: Int: 5 ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 19 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 5 ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 20 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ MK_CLOSURE(BIND(x); STACK_LOOKUP(x); SWAP; POP); PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [  ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 21 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ PUSH(Int: 6); APPLY; SWAP; POP ]
       └──Stack: [ Value: Closure: ( Body: [ BIND(x); STACK_LOOKUP(x); SWAP; POP
      ] Env: [  ]) ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 22 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ APPLY; SWAP; POP ]
       └──Stack: [ Value: Int: 6, Value: Closure: ( Body: [ BIND(x); STACK_LOOKUP(x); SWAP; POP
      ] Env: [  ]) ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 23 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ BIND(x); STACK_LOOKUP(x); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Int: 6, Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 24 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ STACK_LOOKUP(x); SWAP; POP; SWAP; POP ]
       └──Stack: [ Env: [ x -> Int: 6 ], Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 25 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Int: 6, Env: [ x -> Int: 6 ], Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 26 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; SWAP; POP ]
       └──Stack: [ Env: [ x -> Int: 6 ], Value: Int: 6, Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 27 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SWAP; POP ]
       └──Stack: [ Value: Int: 6, Env: [  ] ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 28 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP ]
       └──Stack: [ Env: [  ], Value: Int: 6 ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 29 - OUTPUT STATE --------
    Threads:
    └──Thread: 1
       └──Instructions: [  ]
       └──Stack: [ Value: Int: 6 ]
    Heap: [  ]
    ------------------------------------------
    Output: Int: 6 |}]
