(* Copyright (C) 2017 Matthew Fluet.
 * Copyright (C) 1999-2005, 2008 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 * Copyright (C) 1997-2000 NEC Research Institute.
 *
 * MLton is released under a HPND-style license.
 * See the file MLton-LICENSE for details.
 *)

functor Global (S: GLOBAL_STRUCTS): GLOBAL = 
struct

open S
open Exp

fun equalss (xs, xs') = Vector.equals (xs, xs', Var.equals)

val expEquals =
   fn (ConApp {con = c, args}, ConApp {con = c', args = args'}) =>
         Con.equals (c, c') andalso equalss (args, args')
    | (Const c, Const c') => Const.equals (c, c')
    | (PrimApp {prim = p, targs = ts, args = xs},
       PrimApp {prim = p', targs = ts', args = xs'}) =>
         let
            datatype z = datatype Prim.Name.t
            val n = Prim.name p
            val n' = Prim.name p'
         in
            case (n, n') of
               (Vector_vector, Vector_vector) =>
                  Vector.equals (ts, ts', Type.equals)
                  andalso equalss (xs, xs')
             | _ => false
         end
    | (Tuple xs, Tuple xs') => equalss (xs, xs')
    | _ => false

fun make () =
   let
      type bind = {var: Var.t, ty: Type.t, exp: Exp.t}
      val binds: bind list ref = ref []
      fun all () = Vector.fromList
                   (List.revMap
                    (!binds, fn {var, ty, exp} =>
                     Statement.T {var = SOME var, ty = ty, exp = exp}))
                   before binds := []
      val table: (Exp.t, bind) HashTable.t =
         HashTable.new {equals = expEquals,
                        hash = Exp.hash}
      fun new (ty: Type.t, exp: Exp.t): Var.t =
         #var
         (HashTable.lookupOrInsert
          (table, exp, fn () =>
           let
              val x = Var.newString "global"
              val bind = {var = x, ty = ty, exp = exp}
           in List.push (binds, bind)
              ; bind
           end))
   in {new = new, all = all}
   end
end
