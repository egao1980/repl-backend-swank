(defsystem "repl-backend-swank"
  :version "0.2.2"
  :description "SLIME Swank wire backend for repl-protocol"
  :author "egao1980"
  :license "MIT"
  :depends-on ((:version "repl-protocol" "0.2.4"))
  ;; Spawned images load swank (ghcr.io/egao1980/cl-systems/swank) with ASDF;
  ;; the server image never loads it, so it is an install root, not a dependency.
  :properties (:cl-repo (:ci (:with ("swank"))))
  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "backend"))
  :in-order-to ((test-op (test-op "repl-backend-swank/tests"))))

(defsystem "repl-backend-swank/tests"
  :depends-on ("repl-backend-swank" "repl-protocol/conformance" "process-backend-uiop" "rove")
  :pathname "tests"
  :serial t
  :components ((:file "package")
               (:file "backend-test"))
  :perform (test-op (o c)
             (unless (symbol-call :rove :run c)
               (error "tests failed for ~A" (component-name c)))))
