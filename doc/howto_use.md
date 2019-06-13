
# How To Use CTT

## Description

## Preparatory Steps

First, we need to obtain LLVM IR for the desired source code. For a utility script see 
`scripts/llvmir/compile2ir-O2.sh`.

## Run Atrox pass

This pass is responsible for extracting a target loop to a separate function by cloning its body and using any live-ins
and live-outs from the surrounding context as the function parameters.

In more detail, the transformation is:

1. Using [Iterator Recognition][1] analysis to separate the target loop blocks in just iterator or just payload basic
blocks.
2. It performs a heuristics-based weighted selection of the "largest" continuous control flow subgraph of payload blocks
to use as the target for extraction.
3. It finally clones the target blocks in a separate function, and optionally exports a report (see below).

The main invocation script is `run-atrox.sh` in the installation's `bin` directory.

Current limitations:

- It can operate only on top-level loops.

### Report generation

Currently, the pass has the ability to export a report per exported loop in JSON format.

An example of the format of the exported JSON is:

**NOTE**: This is subject to change.

```JSON
{
  "args": {
    "argspecs": [
      {
        "direction": 1,
        "iterator dependent": false
      }
    ]
  },
  "func": "main_for.body.split1.clone",
  "loop": {
    "di": {
      "column": 3,
      "filename": "map_simple.c",
      "function": "main",
      "line": 11
    },
    "latch": "  br i1 %exitcond, label %for.cond.cleanup, label %for.body, !dbg !11, !llvm.loop !32"
  }
}

```

The `args` object is an array of `argspecs` which describe traits of the arguments of the extracted function, such as
argument direction (1 for input, 2 for output, 3 for both) and iterator dependence as a boolean. The rest of the fields
are dealing with information related to the source or the IR and are self-explanatory.

The invocation script for this is `run-atrox-export.sh` in the installation's `bin` directory.


## Run Ephippion pass

This pass is responsible for setting up the symbolic execution context for the aforementioned extracted function. In
more detail it performs the following operations:

- Generates a harness functions which contains:
  - Allocation of the target function's arguments.
  - Declaration of the target function's arguments as symbolic.
  - Generate code for the execution of the target function in 2 loops with permuted iteration orders (initial order and 
  reverse).
  - Addition of symbolic assertions on the live-out variables.

The invocation script for this is `run-ephippion-file.sh` in the installation's `bin` directory, where its input is the
bitcode file along with the aforementioned export report in JSON format.


## Symbolic Execution via KLEE

Symbolic execution via the KLEE engine can be specified using the extracted function as an entry point, e.g.:

  `klee -entry-point=foo foo.bc`


[1]: https://github.com/compor/IteratorRecognition

