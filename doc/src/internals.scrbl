#reader(lib "docreader.ss" "scribble")

@require[(file "base.ss")]

@title[#:tag "internals"]{Internal Procedures}

@section{Throttle}

The file @file{throttle.ss} contains procedures that control the rate at which the client sends requests to @|api-name|.

@defproc[(make-throttle [delay integer]) throttle]{

Creates a @var{throttle} structure that manages a queue of @italic{requests} to run "throttled sections" of code. The throttle responds to requests in the order in which they are received, ensuring that @var{delay} milliseconds are allowed to pass between the @italic{end} of one call and the @italic{beginning} of the next. This behaviour is enforced in single- and multi-threaded environments.

Use this procedure in conjunction with the @var{current-throttle} parameter to change the rate at which the client makes calls to @|api-name|. For example:

@schemeblock[
  (let ([throttle (make-throttle 2000)])
    (parameterize ([current-throttle throttle])
      @code:comment{... API calls throttled to at most 1 every 2 seconds ...})
    (kill-throttle! throttle))]

}

@defproc[(call-with-throttle [throttle throttle] [thunk (-> any)]) any]{

Makes a throttled call to @var{thunk}. @var{call-with-throttle} sends a message to @var{throttle}, asking if it can run the throttled section in @var{thunk}. @var{throttle} adds the requests to its queue and behaves as described in the documentation for @var{make-throttle} above. 

}

@defproc[(throttle? [x any]) boolean]{

Returns @litchar{#t} if @var{x} is a @var{throttle}, @litchar{#t} otherwise.

}

@defproc[(throttle-delay [throttle throttle]) integer]{

Returns the delay enforced by @var{throttle} in milliseconds.

}

@defproc[(kill-throttle! [throttle throttle]) void]{

@var{throttle} objects use threads to handle requests. When you have finished using a @var{throttle}, you can (and should) call this procedure to kill its thread and free up the system resources it was using. Once a throttle has been killed, it can no longer be used in calls to @var{call-with-throttle}.

You can also kill a throttle by shutting down the custodian that was current when it was created.

}

@defproc[(throttle-alive? [throttle throttle]) boolean]{

This procedure determines whether or not a throttle has been killed with the @var{kill-throttle} procedure.

}

