(* Copyright (C) 2009,2019 Matthew Fluet.
 * Copyright (C) 1999-2008 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 * Copyright (C) 1997-2000 NEC Research Institute.
 *
 * MLton is released under a HPND-style license.
 * See the file MLton-LICENSE for details.
 *)

signature CONTROL =
   sig
      include CONTROL_FLAGS

      (* Tracing and other informative messages.
       * Some take a verbosity argument that specifies the verbosity level at
       * which messages should be printed. 
       *)
      val message: verbosity * (unit -> Layout.t) -> unit
      val messageStr: verbosity * string -> unit
      val sizeMessage: string * 'a -> Layout.t
      val trace: verbosity * string -> ('a -> 'b) -> 'a -> 'b
      type traceAccum
      val traceAccum: verbosity * string -> (traceAccum * (unit -> unit))
      val traceAdd: traceAccum * string -> ('a -> 'b) -> 'a -> 'b
      val traceBatch: verbosity * string -> ('a -> 'b) -> 
                      (('a -> 'b) * (unit -> unit))
      val indent: unit -> unit
      val unindent: unit -> unit
      val getDepth: unit -> int

      (*------------------------------------*)
      (*          Error Reporting           *)
      (*------------------------------------*)
      val checkFile: File.t * {fail: string -> 'a,
                               name: string,
                               ok: unit -> 'a} -> 'a
      val checkForErrors: string -> unit
      val error: Region.t * Layout.t * Layout.t -> unit
      val errorStr: Region.t * string -> unit
      (* abort compilation once this many errors reached *)
      val errorThreshhold: int ref
      val numErrors: int ref
      val warning: Region.t * Layout.t * Layout.t -> unit

      (*------------------------------------*)
      (*          Compiler Passes           *)
      (*------------------------------------*)
      datatype style = No | Assembly | C | Dot | LLVM | ML

      datatype 'a display =
         NoDisplay
       | Layout of 'a -> Layout.t
       | Layouts of 'a * (Layout.t -> unit) -> unit

      val diagnostic: (unit -> Layout.t) -> unit
      val diagnostics: ((Layout.t -> unit) -> unit) -> unit
      val maybeSaveToFile:
         {arg: 'a,
          name: (string * string option),
          toFile: {display: 'a display, style: style, suffix: string}} -> unit
      val saveToFile:
         {arg: 'a,
          name: string option,
          toFile: {display: 'a display, style: style, suffix: string}} -> unit
      val outputHeader: style * (Layout.t -> unit) -> unit
      val outputHeader': style * Out.t -> unit

      val pass: {name: (string * string option),
                 stats: 'a -> Layout.t,
                 thunk: unit -> 'a,
                 toFile: {display: 'a display, style: style, suffix: string}} -> 'a

      val passTypeCheck: {name: (string * string option),
                          stats: 'a -> Layout.t,
                          thunk: unit -> 'a,
                          toFile: {display: 'a display, style: style, suffix: string},
                          typeCheck: 'a -> unit} -> 'a

      val simplifyPass: {arg: 'a,
                         doit: 'a -> 'a,
                         execute: bool,
                         name: string,
                         stats: 'a -> Layout.t,
                         toFile: {display: 'a display, style: style, suffix: string},
                         typeCheck: 'a -> unit} -> 'a
      val simplifyPasses: {arg: 'a,
                           passes: {doit: 'a -> 'a, execute: bool, name: string} list,
                           stats: 'a -> Layout.t,
                           toFile: {display: 'a display, style: style, suffix: string},
                           typeCheck: 'a -> unit} -> 'a
   end
