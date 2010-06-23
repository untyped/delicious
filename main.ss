#lang scheme

; Scheme wrapper for the del.icio.us HTTP API.
;
; The API is described here:
;     http://del.icio.us/help/api/
;
; Example use:
;     (parameterize ([current-username "username"]
;                    [current-password "password"])
;       (get-posts))
;
; See:
;     api.ss for the API commands;
;     config.ss for useful parameters;
;     result-struct.ss for the post and bundle structure types.

(require "api.ss"
         "base.ss"
         "config.ss"
         "result-struct.ss"
         "url.ss")

; Provides ---------------------------------------

(provide (all-from-out "api.ss"
                       "config.ss"
                       "result-struct.ss")
         ; From base.ss:
         (struct-out exn:delicious)
         (struct-out exn:delicious:auth)
         (struct-out exn:fail:delicious)
         (struct-out exn:fail:delicious:throttled)
         (struct-out exn:fail:delicious:parse))
