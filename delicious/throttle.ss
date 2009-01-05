(module throttle mzscheme
  
  (require (lib "contract.ss")
           (lib "plt-match.ss")
           (lib "cut.ss" "srfi" "26"))
  
  (require (file "base.ss"))
 
  ; Structure types ------------------------------
  
  ;; throttle : (struct thread-descriptor channel channel)
  ;;
  ;; Interface to a throttle server:
  ;;   - thread-descriptor is the thread descriptor of the server thread;
  ;;   - delay is the number of milliseconds to wait between throttled sections;
  ;;   - start is a channel with which to request to start a throttled section;
  ;;   - finish is a channel with which to acknowledge that a throttled section
  ;;     has finished.
  (define-struct throttle (thread-descriptor delay start-channel finish-channel) #f)
  
  ; Private stuff --------------------------------
  
  ;; make-throttle-evt : integer -> alarm-evt
  ;;
  ;; Returns an alarm event that delays for delay milliseconds.
  (define (make-throttle-evt delay)
    (alarm-evt (+ (current-inexact-milliseconds) delay)))

  ; Public stuff ---------------------------------
  
  ;; create-throttle : integer -> throttle
  (define (create-throttle delay)
    (letrec ([start      (make-channel)]
             [finish     (make-channel)]
             [loop       (lambda ()
                           ; Wait until someone wants to start a thread.
                           ; Tell them they can go by posting #t back to them.
                           (channel-put (channel-get start) #t)
                           ; Wait until the request is finished.
                           (channel-get finish)
                           ; Sleep for 1 second.
                           (sync (make-throttle-evt delay))
                           ; On to the next request.
                           (loop))]
             [descriptor (thread loop)])
      (make-throttle descriptor delay start finish)))
  
  ;; kill-throttle! : throttle -> void
  ;;
  ;; Terminates a throttle's server thread.
  (define (kill-throttle! throttle)
    (if (throttle-alive? throttle)
        (let ([descriptor (throttle-thread-descriptor throttle)])
          (kill-thread descriptor))
        (raise-exn exn:fail:contract
          (format "The throttle has been killed: ~a" throttle))))
  
  ;; throttle-alive? : throttle -> boolean
  ;;
  ;; Returns #t if the throttle control is still able to receive requests,
  ;; or #f if it has been killed with kill-throttle!.
  (define (throttle-alive? throttle)
    (not (thread-dead? (throttle-thread-descriptor throttle))))
  
  ;; call-with-throttle : throttle (-> a) -> a
  (define (call-with-throttle throttle thunk)
    (if (throttle-alive? throttle)
        (let ([start    (throttle-start-channel throttle)]
              [finish   (throttle-finish-channel throttle)]
              [response (make-channel)])
          (dynamic-wind
           (lambda ()
             (channel-put start response)
             (channel-get response))
           thunk
           (lambda ()
             (channel-put finish #t))))
        (raise-exn exn:fail:contract
          (format "The throttle has been killed: ~a" throttle))))
  
  ; Provide statements --------------------------- 
  
  (provide throttle?)
  
  (provide/contract
   [rename create-throttle make-throttle (-> (and/c integer? (>=/c 0)) throttle?)]
   [throttle-delay                       (-> throttle? integer?)]
   [throttle-alive?                      (-> throttle? boolean?)]
   [kill-throttle!                       (-> throttle? void?)]
   [call-with-throttle                   (-> throttle? procedure? any)])
  
  )
