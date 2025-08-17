# Line Lisp (a type of pure Lisp)
- [Line Lisp (a type of pure Lisp)](#line-lisp-a-type-of-pure-lisp)
  - [Overview](#overview)
  - [Usage](#usage)
  - [Notes](#notes)
  - [Test](#test)

## Overview

This is a pure Lisp system using *linear lists* only.

## Usage

Run "main.scm" in a Scheme interpreter such as DrRacket.
The language specification is R5RS.

## Notes

- '<' and '>' are substitutes for parentheses.
- '<' and '>' are symbols. To place symbols next to each other, you need a space between them.
- '!' is substitutes for '.'.
- '!' does not support as many notations as '.', so use it in the same way as the maximally abbreviated '.'.
- "< >" does not mean nil. Type "()" to represent nil.

## Test

    (repl<)⏎
    (importenv plisp1!5)⏎
    (def reverse
      (< quote
         < lambda < x >
           < < label
               rec
               < lambda < x y >
               < cond
                 < < eq () x >
                   y >
                 < t
                   < rec < cdr x >
                         < cons < car x > y > > > > > >
             x () > > >))⏎
    reverse
    (def subst
      (< quote
         < label
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
                          < subst x y < cdr z > > > > > > > >))⏎
    subst
    (< reverse < quote < 1 2 3 4 5 > > > >)⏎
    (< 5 4 3 2 1 >)
    (< subst < quote m > < quote b > < quote < a b < a b c > d > > > >)⏎
    (< a m < a m c > d >)
    (< eval < quote < reverse < quote < 1 2 3 4 5 > > > > *env<* >)⏎
    (< 5 4 3 2 1 >)
    (< eval < quote < subst < quote m > < quote b > < quote < a b < a b c > d > > > > *env<* >)⏎
    (< a m < a m c > d >)
    (exit)
    >
