#reader(lib "docreader.ss" "scribble")

@require[(file "base.ss")]

@title{@lib-name}

Dave Gurnell and Noel Welsh (@tt{{dave, noel} at untyped})

@; ----------------------------------------------------------------------

@section{Introduction}

This library provides structures and procedures for accessing the HTTP API of the @api-name social bookmarking service. The library handles all connection, encryption and authentication with @api-name, allowing the programmer to concentrate on application logic.

This release of the library supports version 1.0 of the @api-name API.

@table-of-contents[]

@include-section{config.scrbl}
@include-section{api.scrbl}
@include-section{internals.scrbl}
@include-section{testing.scrbl}

@section{Acknowledgements}

Many thanks to the following contributors:

@itemize{@item{Eric Hanchrow}}
