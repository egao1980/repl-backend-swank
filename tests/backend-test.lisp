(in-package #:repl-backend-swank/tests)

(deftest rpc-table
  (let ((conn (make-instance 'swank-connection :socket nil :stream nil)))
    (ok (equal (wire-symbol-name (repl-protocol:rpc-symbol conn :backtrace)) "BACKTRACE"))
    (ok (equal (wire-symbol-package (repl-protocol:rpc-symbol conn :backtrace)) "SWANK"))
    (ok (signals (repl-protocol:rpc-symbol conn :no-such-op) 'repl-protocol-error))))

(deftest swank-conformance
  (process-backend-uiop:use-uiop-process-backend)
  (let ((conn (repl-spawn (make-swank-backend))))
    (unwind-protect (repl-protocol/conformance:run-conformance conn)
      (repl-disconnect conn :kill t))))
