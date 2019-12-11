open Core
open Print_execution

let%expect_test "Access a thread variable in other thread" =
  print_execution
    " 
    class Foo = thread Bar {
      var f : int
    }
    thread trait Bar {
      require var f : int
    }
    let x = new Foo(f:5) in 
      let y = x in 
      finish{

        async{
          x.f 
        }
        async{
          y.f (* cannot read thread alias in different thread*)
        }
      } ;
      x.f
      end
    end
  " ;
  [%expect
    {|
    ----- Step 0 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ PUSH(Int: 5); CONSTRUCTOR(Foo); HEAP_FIELD_SET(f); BIND(x); STACK_LOOKUP(x); BIND(y); SPAWN [ STACK_LOOKUP(y); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [  ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 1 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ CONSTRUCTOR(Foo); HEAP_FIELD_SET(f); BIND(x); STACK_LOOKUP(x); BIND(y); SPAWN [ STACK_LOOKUP(y); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Int: 5 ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 2 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ HEAP_FIELD_SET(f); BIND(x); STACK_LOOKUP(x); BIND(y); SPAWN [ STACK_LOOKUP(y); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Address: 1, Value: Int: 5 ]
    Heap: [ 1 -> { Class_name: Foo, Fields: {  } } ]
    ------------------------------------------
    ----- Step 3 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ BIND(x); STACK_LOOKUP(x); BIND(y); SPAWN [ STACK_LOOKUP(y); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Address: 1 ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 4 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ STACK_LOOKUP(x); BIND(y); SPAWN [ STACK_LOOKUP(y); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 5 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ BIND(y); SPAWN [ STACK_LOOKUP(y); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Address: 1, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 6 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SPAWN [ STACK_LOOKUP(y); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 7 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Thread ID: 2, Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    └──Thread: 2
       └──Instructions: [ STACK_LOOKUP(y); HEAP_FIELD_LOOKUP(f) ]
       └──Stack: [ Env: [ x -> Address: 1, y -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 8 - scheduled thread : 2-----
    Threads:
    └──Thread: 2
       └──Instructions: [ STACK_LOOKUP(y); HEAP_FIELD_LOOKUP(f) ]
       └──Stack: [ Env: [ x -> Address: 1, y -> Address: 1 ] ]
    └──Thread: 1
       └──Instructions: [ HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Address: 1, Value: Thread ID: 2, Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 9 - scheduled thread : 2-----
    Threads:
    └──Thread: 2
       └──Instructions: [ HEAP_FIELD_LOOKUP(f) ]
       └──Stack: [ Value: Address: 1, Env: [ x -> Address: 1, y -> Address: 1 ] ]
    └──Thread: 1
       └──Instructions: [ HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Address: 1, Value: Thread ID: 2, Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 10 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Address: 1, Value: Thread ID: 2, Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    └──Thread: 2
       └──Instructions: [  ]
       └──Stack: [ Value: Int: 5, Env: [ x -> Address: 1, y -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 11 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Int: 5, Value: Thread ID: 2, Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    └──Thread: 2
       └──Instructions: [  ]
       └──Stack: [ Value: Int: 5, Env: [ x -> Address: 1, y -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 12 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Thread ID: 2, Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    └──Thread: 2
       └──Instructions: [  ]
       └──Stack: [ Value: Int: 5, Env: [ x -> Address: 1, y -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 13 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 14 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ HEAP_FIELD_LOOKUP(f); SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Address: 1, Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 15 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SWAP; POP; SWAP; POP ]
       └──Stack: [ Value: Int: 5, Env: [ y -> Address: 1 ], Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 16 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; SWAP; POP ]
       └──Stack: [ Env: [ y -> Address: 1 ], Value: Int: 5, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 17 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SWAP; POP ]
       └──Stack: [ Value: Int: 5, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 18 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP ]
       └──Stack: [ Env: [ x -> Address: 1 ], Value: Int: 5 ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 19 - OUTPUT STATE --------
    Threads:
    └──Thread: 1
       └──Instructions: [  ]
       └──Stack: [ Value: Int: 5 ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    Output: Int: 5 |}]

let%expect_test "Access an alias of a mutable object in multiple threads" =
  print_execution
    " 
    class Foo = linear Bar {
      var f : int
    }
    linear trait Bar {
      require var f : int
    }
    let x = new Foo(f:5) in 
      finish{
        (* cannot read same alias in different threads *)
        async{
          x.f 
        }
        async{
          x.f
        }
      } ;
      x.f
    end
  " ;
  [%expect
    {|
    ----- Step 0 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ PUSH(Int: 5); CONSTRUCTOR(Foo); HEAP_FIELD_SET(f); BIND(x); SPAWN [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [  ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 1 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ CONSTRUCTOR(Foo); HEAP_FIELD_SET(f); BIND(x); SPAWN [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Int: 5 ]
    Heap: [  ]
    ------------------------------------------
    ----- Step 2 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ HEAP_FIELD_SET(f); BIND(x); SPAWN [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Address: 1, Value: Int: 5 ]
    Heap: [ 1 -> { Class_name: Foo, Fields: {  } } ]
    ------------------------------------------
    ----- Step 3 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ BIND(x); SPAWN [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Address: 1 ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 4 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SPAWN [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f) ]; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 5 - scheduled thread : 2-----
    Threads:
    └──Thread: 2
       └──Instructions: [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f) ]
       └──Stack: [ Env: [ x -> Address: 1 ] ]
    └──Thread: 1
       └──Instructions: [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Thread ID: 2, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 6 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Thread ID: 2, Env: [ x -> Address: 1 ] ]
    └──Thread: 2
       └──Instructions: [ HEAP_FIELD_LOOKUP(f) ]
       └──Stack: [ Value: Address: 1, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 7 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ HEAP_FIELD_LOOKUP(f); POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Address: 1, Value: Thread ID: 2, Env: [ x -> Address: 1 ] ]
    └──Thread: 2
       └──Instructions: [ HEAP_FIELD_LOOKUP(f) ]
       └──Stack: [ Value: Address: 1, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 8 - scheduled thread : 2-----
    Threads:
    └──Thread: 2
       └──Instructions: [ HEAP_FIELD_LOOKUP(f) ]
       └──Stack: [ Value: Address: 1, Env: [ x -> Address: 1 ] ]
    └──Thread: 1
       └──Instructions: [ POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Int: 5, Value: Thread ID: 2, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 9 - scheduled thread : 2-----
    Threads:
    └──Thread: 2
       └──Instructions: [  ]
       └──Stack: [ Value: Int: 5, Env: [ x -> Address: 1 ] ]
    └──Thread: 1
       └──Instructions: [ POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Int: 5, Value: Thread ID: 2, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 10 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP; BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Int: 5, Value: Thread ID: 2, Env: [ x -> Address: 1 ] ]
    └──Thread: 2
       └──Instructions: [  ]
       └──Stack: [ Value: Int: 5, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 11 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ BLOCKED; STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Thread ID: 2, Env: [ x -> Address: 1 ] ]
    └──Thread: 2
       └──Instructions: [  ]
       └──Stack: [ Value: Int: 5, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 12 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ STACK_LOOKUP(x); HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 13 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ HEAP_FIELD_LOOKUP(f); SWAP; POP ]
       └──Stack: [ Value: Address: 1, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 14 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ SWAP; POP ]
       └──Stack: [ Value: Int: 5, Env: [ x -> Address: 1 ] ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 15 - scheduled thread : 1-----
    Threads:
    └──Thread: 1
       └──Instructions: [ POP ]
       └──Stack: [ Env: [ x -> Address: 1 ], Value: Int: 5 ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    ----- Step 16 - OUTPUT STATE --------
    Threads:
    └──Thread: 1
       └──Instructions: [  ]
       └──Stack: [ Value: Int: 5 ]
    Heap: [ 1 -> { Class_name: Foo, Fields: { f: Int: 5 } } ]
    ------------------------------------------
    Output: Int: 5 |}]
