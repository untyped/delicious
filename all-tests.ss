#lang scheme

(require "test-base.ss")

(require "api-test.ss"
         "throttle-test.ss")

; Tests ------------------------------------------

(define/provide-test-suite all-tests
  throttle-tests
  api-tests)
