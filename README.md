# repl-backend-swank

SLIME [Swank](https://github.com/slime/slime) wire backend for [`repl-protocol`](https://github.com/egao1980/repl-protocol).

```lisp
(asdf:load-system "repl-backend-swank")
(stack-repl:repl-connect (repl-backend-swank:make-swank-backend) :port 4005)   ; attach
(stack-repl:repl-spawn (repl-backend-swank:make-swank-backend))                ; fresh image
```

`repl-spawn` starts `ros +Q run` (no Quicklisp) and loads Swank with `asdf:load-system` from the directory this image finds it in (`repl-protocol:system-registry-form`; install it with cl-repo: `ghcr.io/egao1980/cl-systems/swank`, here an `:ci :with` root) and calls `swank:start-server`. Tests run the shared `repl-protocol/conformance` suite against a spawned SBCL.

Stepping uses `sldb-step` / `-next` / `-out`. Swank has no channels (`repl-open-channel` signals `repl-not-supported`); use the Slynk backend for several REPLs per connection.

## License

MIT
