#lang scheme

(require "test-base.ss")

(require "all-tests.ss"
         "config.ss"
         "throttle.ss")

(kill-throttle! (current-throttle))

(parameterize ([current-throttle (make-throttle 5000)]
               [current-username "plttest"]
               [current-password "jej1ima"])
  (run-tests all-tests))
