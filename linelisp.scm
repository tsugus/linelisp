;;; Line Lisp

; -------------------------------------
;; prepartions

(define (atom? x) (not (pair? x)))

(define (atom x) (cond ((atom? x) 't)
                       (else '())))

(define (eq x y) (cond ((eq? x y) 't)
                       (else '())))

(define (error err-code s-exp)
  (cond ((eqv? err-code 1) (display "Not found"))
        ((eqv? err-code 2) (display "Invalid form"))
        (else (display "Error")))
  (display ": ")
  (display s-exp)
  (newline)
  '())

(define (isSUBR? x)
  (cond ((eq? x 'atom) #t)
        ((eq? x 'eq) #t)
        ((eq? x 'car) #t)
        ((eq? x 'cdr) #t)
        ((eq? x 'cons) #t)
        ((eq? x 'error) #t)
        (else #f)))

; =====================================
;; Line Lisp (main body)

; (block '(< < 1 2 3 > 4 5 > 6 7)) ==> ((< < 1 2 3 > 4 5 >) < 6 7)
; (block '(< < 1 2 3 > 4 5)) ==> ()
; (block '(1 ! 2 3)) ==> (1 . 2)
; (block '(1 2 3 4 5)) ==> (1 < 2 3 4 5)
(define (block exp)
  (cond ((eq? '< (car exp))
         (block-rec '(<) (list (car exp)) (cdr exp)))
        (else
         (cond ((eq? '! (cadr exp)) (cons (car exp) (caddr exp)))
               (else (cons (car exp) (cons '< (cdr exp))))))))

(define (block-rec stack done exp)
  (cond
    ((null? exp)
     (cond
       ((null? stack) (cons (reverse done) exp))
       (else '())))  ; irregular list
    ((null? stack)
     (cond
       ((null? done) exp)
       (else
        (cond
          ((eq? '! (car exp)) (cons (reverse done) (cadr exp)))
          (else (cons (reverse done) (cons '< exp)))))))
    ((eq? '< (car exp))
     (block-rec (cons '< stack) (cons (car exp) done) (cdr exp)))
    ((eq? '> (car exp))
     (block-rec (cdr stack) (cons (car exp) done) (cdr exp)))
    (else
     (block-rec stack (cons (car exp) done) (cdr exp)))))

(define (car< x)
  (cond ((eq? '< (car x))
         (cond ((eq? '! (cadr x)) (car '()))
               ((eq? '> (cadr x)) (car '()))
               (else (car (block (cdr x))))))
        (else (car x))))

(define (cdr< x)
  (cond ((eq? '< (car x))
         (cond ((eq? '! (cadr x)) (cdr '()))
               ((eq? '> (cadr x)) (cdr '()))
               ((atom? (cdr (block (cdr x)))) (cdr (block (cdr x))))
               (else
                (cond
                  ((eq? '> (caddr (block (cdr x)))) '())
                  (else (cdr (block (cdr x))))))))
        (else (cdr x))))

(define (conect x y)
  (cond ((atom? x) (cons x y))
        (else (append x y))))

(define (cons< x y)
  (cond
    ((atom? y)
     (cond ((null? y) (cons '< (conect x '(>))))
           (else (cons '< (conect x (list '! y '>))))))
    ((eq? '< (car y))
     (cons '< (conect x (cdr y))))
    (else (cons '< (append (cons x y) '(>))))))

(define (caar< x) (car< (car< x)))
(define (cadr< x) (car< (cdr< x)))
(define (cdar< x) (cdr< (car< x)))
(define (cddr< x) (cdr< (cdr< x)))
(define (caaar< x) (car< (caar< x)))
(define (caadr< x) (car< (cadr< x)))
(define (cadar< x) (car< (cdar< x)))
(define (caddr< x) (car< (cddr< x)))
(define (cdaar< x) (cdr< (caar< x)))
(define (cdadr< x) (cdr< (cadr< x)))
(define (cddar< x) (cdr< (cdar< x)))
(define (cdddr< x) (cdr< (cddr< x)))

; (pairlis< '(< x y >) '(< 1 2 >) '(< < z ! 3 > >))
;  ==> (< < x ! 1 > < y ! 2 > < z ! 3 > >)
; (pairlis< '(< x y ! z >) '(< 1 2 3 4 5 >) '())
;  ==> (< < x ! 1 > < y ! 2 > < z 3 4 5 > >)
(define (pairlis< v e a)
  (cond ((null? v) a)
        ((atom? v) (cons< (cons< v e) a))
        (else (cons< (cons< (car< v) (car< e))
                     (pairlis< (cdr< v) (cdr< e) a)))))

(define (assoc< x a)
  (cond ((null? a) (error '1 x))
        ((eq? x (caar< a)) (car< a))
        (else (assoc< x (cdr< a)))))

(define (eval< e a)
  (cond
    ((eq? e 't) 't)
    ((eq? e '()) '())
    ((atom? e) (cdr< (assoc< e a)))
    ((isSUBR? (car< e)) (apply< (car< e) (evlis< (cdr< e) a) a))
    ((atom? (car< e)) (apply< (car< e) (cdr< e) a))
    ((eq? (caar< e) 'lambda) (apply< (car< e) (evlis< (cdr< e) a) a))
    (else (apply< (car< e) (cdr< e) a))))

(define (apply< fn args a)
  (cond
    ((atom? fn)
     (cond
       ((eq? fn 'quote) (car< args))
       ((eq? fn 'atom) (atom (car< args)))
       ((eq? fn 'eq) (eq (car< args) (cadr< args)))
       ((eq? fn 'car) (car< (car< args)))
       ((eq? fn 'cdr) (cdr< (car< args)))
       ((eq? fn 'cons) (cons< (car< args) (cadr< args)))
       ((eq? fn 'cond) (evcon< args a))
       ((eq? fn 'error) (error (car< args) (cadr< args)))
       (else (eval< (cons< (cdr< (assoc< fn a)) args) a))))
    ((eq? (car< fn) 'label)
     (eval< (cons< (caddr< fn) args)
            (cons< (cons< (cadr< fn) (caddr< fn)) a)))
    ((eq? (car< fn) 'lambda)
     (eval< (caddr< fn) (pairlis< (cadr< fn) args a)))
    (else (error '2 (cons< fn args)))))

(define (evcon< c a)
  (cond ((null? (eval< (caar< c) a)) (evcon< (cdr< c) a))
        (else (eval< (cadar< c) a))))

(define (evlis< m a)
  (cond ((null? m) '())
        (else (cons< (eval< (car< m) a) (evlis< (cdr< m) a)))))
