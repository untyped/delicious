(module make mzscheme
  
  (require (lib "runtime-path.ss")
           (lib "dirs.ss" "setup")
           (lib "run.ss"  "scribble")
           (lib "file.ss")
           (file "src/index.scrbl")) ; Provides a single variable "doc".
  
  (define-runtime-path input-dir  "src")
  (define-runtime-path link-dir   "link")
  (define-runtime-path output-dir "html")
  
  (parameterize ([current-directory        input-dir]
                 [current-dest-directory   output-dir]
                 [current-render-mixin     html:render-mixin]
                 ;[current-info-output-file link-dir]
                 [current-info-input-files null])
    (build-docs (list doc) (list "index")))
  
  )
