(module delicious mzscheme
  
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
  
  (require (file "api.ss")
           (file "base.ss")
           (file "config.ss")
           (file "result-struct.ss")
           (file "url.ss"))
           
  (provide (all-from (file "api.ss"))
           (all-from (file "base.ss"))
           (all-from (file "config.ss"))
           (all-from (file "result-struct.ss"))
           ; From url.ss (use for unspecified arguments):
           empty
           empty?)
  
  )