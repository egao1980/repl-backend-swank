(in-package #:repl-backend-swank)

(defclass swank-backend (repl-backend) ()
  (:documentation "SLIME's Swank wire."))

(defun make-swank-backend () (make-instance 'swank-backend))

(defclass swank-connection (swank-family-connection) ()
  (:default-initargs :rpc-package "SWANK"))

(defparameter *swank-rpcs*
  '((:connection-info . "CONNECTION-INFO")
    (:compile-string . "COMPILE-STRING-FOR-EMACS")
    (:compile-file . "COMPILE-FILE-FOR-EMACS")
    (:load-file . "LOAD-FILE")
    (:backtrace . "BACKTRACE")
    (:frame-locals . "FRAME-LOCALS-AND-CATCH-TAGS")
    (:frame-source-location . "FRAME-SOURCE-LOCATION")
    ;; EVAL-STRING-IN-FRAME also wants echo-area LINES and WIDTH (NIL errors)
    (:eval-in-frame . "PPRINT-EVAL-STRING-IN-FRAME")
    (:invoke-restart . "INVOKE-NTH-RESTART-FOR-EMACS")
    (:return-from-frame . "SLDB-RETURN-FROM-FRAME")
    (:restart-frame . "RESTART-FRAME")
    (:step-into . "SLDB-STEP")
    (:step-next . "SLDB-NEXT")
    (:step-out . "SLDB-OUT")
    (:init-inspector . "INIT-INSPECTOR")
    (:inspect-nth-part . "INSPECT-NTH-PART")
    (:inspector-call-nth-action . "INSPECTOR-CALL-NTH-ACTION")
    (:inspector-pop . "INSPECTOR-POP")
    (:inspector-next . "INSPECTOR-NEXT")
    (:inspect-frame-var . "INSPECT-FRAME-VAR")
    (:inspect-current-condition . "INSPECT-CURRENT-CONDITION")
    (:describe-symbol . "DESCRIBE-SYMBOL")
    (:documentation-symbol . "DOCUMENTATION-SYMBOL")
    (:operator-arglist . "OPERATOR-ARGLIST")
    (:apropos . "APROPOS-LIST-FOR-EMACS")
    (:completions . "SIMPLE-COMPLETIONS")
    (:macroexpand-1 . "SWANK-MACROEXPAND-1")
    (:macroexpand-all . "SWANK-MACROEXPAND-ALL")
    (:xref . "XREF")
    (:find-definitions . "FIND-DEFINITIONS-FOR-EMACS")
    (:list-threads . "LIST-THREADS")
    (:kill-thread . "KILL-NTH-THREAD"))
  "Operation keyword → Swank function name.")

(defmethod rpc-symbol ((conn swank-connection) operation)
  (let ((name (cdr (assoc operation *swank-rpcs*))))
    (unless name
      (error 'repl-protocol-error :message (format nil "Swank has no RPC for ~S" operation)))
    (wsym "SWANK" name)))

(defmethod repl-connect ((backend swank-backend) &key (host "127.0.0.1") port)
  (open-wire-connection 'swank-connection host port :backend backend))

(defun swank-loader-forms (port-file)
  "--eval forms that load Swank (Quicklisp when present, else ASDF) and start
a server writing its port to PORT-FILE."
  (list "(require :asdf)"
        "(if (find-package :ql) (funcall (intern \"QUICKLOAD\" :ql) :swank :silent t) (asdf:load-system :swank))"
        (format nil "(funcall (intern \"START-SERVER\" :swank) ~S :dont-close t)" port-file)))

(defmethod repl-spawn ((backend swank-backend) &key (command *default-image-command*) directory env (timeout 180))
  (multiple-value-bind (port process) (spawn-image #'swank-loader-forms :command command
                                                                        :directory directory :env env
                                                                        :timeout timeout)
    (let ((conn (repl-connect backend :port port)))
      (setf (connection-process conn) process)
      conn)))
