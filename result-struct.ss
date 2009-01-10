(module result-struct mzscheme
  
  (require (lib "contract.ss")
           (lib "time.ss" "srfi" "19"))
  
  ; Structure types ------------------------------
  
  ;; post : (struct string string (U string #f) (list-of string) date)
  (define-struct post (url description extended tags date) #f)
  
  ;; bundle : (struct string (list-of string))
  (define-struct bundle (name tags) #f)
  
  ; Provide statements --------------------------- 
  
  (provide/contract
   [struct post   ([url         string?]
                   [description string?]
                   [extended    (or/c string? false/c)]
                   [tags        (listof string?)]
                   [date        (or/c srfi:date? false/c)])]
   [struct bundle ([name        string?]
                   [tags        (listof string?)])])
  
  )
