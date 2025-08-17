;; Virtual REPL

; The global environment list '*env<*'
;
(define *env<* '(< < *env<* > >))

; Add (x . y) to *env<*.
;
(define (<<< x y)
  (set! *env<* (cons< (cons< '*env<* (cons< (cons< x y) (cdr< *env<*)))
                      (cons< (cons< x y) (cdr< *env<*))))
  x)

; Eval x on the environment *env<*.
;
(define (>> an_eval x)
  ((eval an_eval (interaction-environment)) x *env<*))

; import a environment.
;
(define (importenv<! env)
  (set! *env<* (cons< (cons< '*env<* env) env))
  't)

; export the environment "*env<*.
;
(define (exportenv!) *env<*)

; Reset the environment "*env<*".
;
(define (resetenv<!)
  (set! *env<* '(< < *env<* > >))
  't)

; The top level expression
;
(define top-exp '())

; Virtual REPL
;
(define (repl-body< an_eval exp)
  (cond
    ((pair? exp)
     (cond
       ((eq? 'importenv (car exp))
        (display (importenv<! (eval (cadr exp) (interaction-environment)))))
       ((eq? 'exportenv (car exp))
        (display (exportenv!)))
       ((eq? 'resetenv (car exp))
        (display (resetenv<!)))
       ((eq? 'def (car exp))
        (display (<<< (cadr exp) (eval< (caddr exp) *env<*))))
       (else (display (>> an_eval exp)))))
    (else (display (>> an_eval exp))))
  (newline))
;
(define (repl-loop< an_eval)
  (repl-body< an_eval top-exp)
  (repl< an_eval))
;
(define repl<
  (lambda args
    (if (null? args) (set! args '(eval<)))  ; the defalut eval function is 'eval<'.
    (set! top-exp (read))
    (cond
      ((atom? top-exp) (repl-loop< (car args)))
      ((eq? 'exit (car top-exp)) (display ""))
      (else (repl-loop< (car args))))))
