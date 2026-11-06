# repl-backend-swank

SLIME [Swank](https://github.com/slime/slime) wire backend for [`repl-protocol`](https://github.com/egao1980/repl-protocol).

```lisp
(asdf:load-system "repl-backend-swank")
(stack-repl:repl-connect (repl-backend-swank:make-swank-backend) :port 4005)   ; attach
(stack-repl:repl-spawn (repl-backend-swank:make-swank-backend))                ; fresh image
```

`repl-spawn` loads Swank in the child with `ql:quickload` (or `asdf:load-system` when Quicklisp is absent) and calls `swank:start-server`. Tests run the shared `repl-protocol/conformance` suite against a spawned SBCL.

## License

MIT
