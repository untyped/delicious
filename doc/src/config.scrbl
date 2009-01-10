#reader(lib "docreader.ss" "scribble")

@require[(file "base.ss")]

@title[#:tag "config"]{Configuration}

Use the following parameters to configure the library. All API calls within the current scope are affected.

@section{Basic Configuration}

Before making any API calls, the programmer @italic{must} configure the username and password to use to authenticate with @|api-name|. All communication takes place over SSL, so username and password are secure during transmission over the Internet.

Note that, in the current version of the @api-name API, it is only possible to query/manipulate information in the authenticated account.

@defthing[current-username (parameter string)]{

Sets/retrieves the username to use for subsequent @api-name API calls.

}

@defthing[current-password (parameter string)]{

Sets/retrieves the password to use for subsequent @api-name API calls.

}

For example:

@schemeblock[
  (parameterize ([username "untyped"]
                 [password "password"])
    @code:comment{... authenticated API calls go here ...}
    )]

@section{Advanced Configuration}

@defthing[current-base-url (parameter string)]{

The base URL of the API. By default this is:

@schemeblock["http://api.del.icio.us:443/v1"]

Note the following:

@itemize{

@item{While all communication takes place over SSL, the library does not understand the @litchar{https://} protocol in the URL. Instead use @litchar{http://} and specify a port number of @litchar{443}.}

@item{The URL should @italic{not} end with a @litchar{/} character.}

}

}

@defthing[current-throttle (parameter throttle)]{

The throttle control to use to limit the rate at which API requests are made.

@api-name can get touchy if you make too many requests too quickly. The documentation states that you must leave a minimum of 1 second between requests, otherwise you will be throttled for up to a few minutes. Experience has shown that persistent use of some of the more "expensive" API requests (such as @var{all-posts}) can cause @api-name to throttle clients even if they respect this 1 second gap.

The @var{current-throttle} parameter takes a @var{throttle} structure that is used to rate limit requests. The default value limits the client to the maximum of 1 request per second. You can change this default value if you find you are frequently being throttled by @|api-name|. See @secref["internals"] for more information.

}

@section{Debug Configuration}

The following parameters pare provided to help debug problems with the library:

@defthing[dump-request-urls? (parameter boolean)]{

If this parameter is set to @litchar{#t}, the URLs of API calls are printed immediately before each call is made.

}

@defthing[dump-sxml-responses? (parameter boolean)]{

If this parameter is set to @litchar{#t}, the SXML versions of all responses are printed as they are parsed. Note that this requires the XML response from @api-name to be well-formed.

}
