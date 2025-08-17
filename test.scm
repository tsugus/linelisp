;; Test

(define reverse2
  '(< lambda < x >
      < < label
          rec
          < lambda < x y >
          < cond
            < < eq () x >
              y >
            < t
              < rec < cdr x >
                    < cons < car x > y > > > > > >
        x () > >))

(define subst
  '(< label
      subst
      < lambda < x y z >
        < cond
          < < atom z >
            < cond
              < < eq z y >
                x >
              < t
                z > > >
          < t
            < cons < subst x y < car z > >
                   < subst x y < cdr z > > > > > > >))

(set! *env<* plisp1!5)
(set! *env<* (cons< (cons< 'reverse reverse2) *env<*))
(set! *env<* (cons< (cons< 'subst subst) *env<*))
(set! *env<* (cons< (cons< '*env<* *env<*) *env<*))

;(appned '(1 2 3) '(4 5 6))
;(display *env<*)

(display "*** Test of 'eval<' ***")
(newline)
(display
 (eval< '(< reverse < quote < 1 2 3 4 5 > > > >) *env<*))
(newline)
(display
 (eval< '(< subst < quote m > < quote b > < quote < a b < a b c > d > > > >) *env<*))
(newline) (newline)

(display "*** Test of plisp1!5's 'eval' ***")
(newline)
(display
 (eval<
  '(< eval
      < quote
        < reverse < quote < 1 2 3 4 5 > > >
      > *env<* >)
  *env<*))
(newline)
(display
 (eval<
  '(< eval
      < quote
        < subst < quote m > < quote b > < quote < a b < a b c > d > > >
      > *env<* >)
  *env<*))
(newline) (newline)
