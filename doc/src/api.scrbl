#reader(lib "docreader.ss" "scribble")

@require[(file "base.ss")]

@title[#:tag "api"]{API Wrappers}

@section{Result Structures}

The following structures are used to encapsulate data returned by API calls. The same structures can also optionally be used as arguments to some API calls:

@defstruct[post ([url string]
                 [description string]
                 [extended (U string #f)]
                 [tags (list-of string)]
                 [date (U srfi-19:date #f)])]{

A @api-name post, comprising a bookmark and some metadata:

@itemize{
  @item{@var{url} - the bookmarked URL;}
  @item{@var{description} - the one-line title of the post;}
  @item{@var{extended} - extended notes on the post;}
  @item{@var{tags} - tags attached to the post;}
  @item{@var{date} - the date the post was originally made;}}
  
}

@defstruct[bundle ([name string]
                   [tags (list-of string)])]{
                   
A @italic{tag bundle}: a named collection of tags. Note that bundles may @italic{not} be used in place of tags, either as members of other bundles or as @var{tag} arguments to API calls. This limits their usefulness in the API, although they still appear on the @api-name web site.

@itemize{
  @item{@var{name} - the name of the bundle;}
  @item{@var{tags} - tags in the bundle.}}

}

@section{Exceptions}

The following exceptions may be raised by any API procedure call:

@defstruct[(exn:delicious exn) ()]{

Abstract exception supertype. Subtypes of this exception represent failures that are typically the fault of the user, rather than this library or @api-name itself.

Applications should respond to exceptions of this type by displaying a "you messed up" style dialog box or feedback message.

}

@defstruct[(exn:fail:delicious exn) ()]{

Abstract exception supertype. Subtypes of this exception represent failures that are typically the fault of this library or @|api-name|.

Applications should respond to exceptions of this type by displaying an "unexpected error" style dialog box or feedback message.

}

@defstruct[(exn:delicious:auth exn:delicious) ()]{

Raised if @api-name returns an HTTP 403 response. This typically means the username/password were invalid.

}

@defstruct[(exn:fail:delicious:throttled exn:fail:delicious) ()]{

Raised if @api-name returns an HTTP 503 response. @api-name is very sensitive to request spamming or over-use. This library contains an auto-throttling element that prevents applications making more than the one permitted request per second, but excessive use of "expensive" requests such as @var{all-posts} can still trigger throttling.

Applications should respond to exceptions of this type by backing off for 30 seconds to a few minutes, until @api-name switches its throttle protection off again.

}

@defstruct[(exn:fail:delicious:parse exn:fail:delicious) ([fragment sxml])]{

Raised if the library was unable to parse an XML response. This implies the result was well-formed XML with an unexpected structure. The @var{fragment} field contains the problematic SXML fragment.

If you get one of these, it's time to switch on the @var[dump-sxml-responses?] parameter and start hunting for bugs in this library. Note that, while bug reports are gratefully received, bug reports @italic{and} fixes are infinitely preferable.

}

@section{API Procedures}

The following procedures are wrappers for the various @api-name API calls. All calls require the @var{current-username} and @var{current-password} parameters to be set.

@defproc[(last-updated) srfi-19:date]{

Returns the (SRFI-19) date of the last post to the account.

}

@defproc[(get-tags) (alist-of string integer)]{

Returns an association list of tags to number of uses.

}

@defproc[(rename-tag! [old-name string] [new-name string]) void]{

Renames a tag and propagates the change to all related posts. For example:

@schemerepl[
  (length (get-posts "untyped"))
  0
  (length (get-posts "un-typed"))
  1
  (rename-tag! "un-typed" "untyped")
  void
  (length (get-posts "untyped"))
  1
  (length (get-posts "un-typed"))
  0]

}

@defproc[(get-posts [tag (U string void) void]
                    [date (U srfi-19:date void) void]
                    [url (U string void) void])
         (list-of post)]{
         
Returns all posts matching the arguments:

@itemize{
  @item{@var[tag] - filter by the specified tag (one tag only);}
  @item{@var[date] - filter by the specified post date;}
  @item{@var[url] - filter by the specified URL (must be an exact match).}}

If all arguments are @var{void}, posts are returned from the most recent day of posting.

}

@defproc[(recent-posts [tag (U string void) void]
                       [count (U integer void) void])
         (list-of post)]{
         
Returns a list of the most recent posts:

@itemize{
  @item{@var[tag] - as above;}
  @item{@var[count] - limit to the specified number of posts: default 15, max 100.}}

The default value of @var{count} is 15.

}

@defproc[(all-posts [tag (U string void) void]) (list-of post)]{

Returns all posts.

The @api-name documentation notes: "Please use sparingly. Call the update function to see if you need to fetch this at all." Frequent use can result in throttling.

}

@defproc[(post-dates [tag (U string void) void]) 
         (alist-of srfi-19:date integer)]{

Returns an association list of post dates to number of posts made on that day.

}

@defproc[(add-post! [post post] 
                    [replace? (U boolean void) void]
                    [shared? (U boolean void) void])
         void]{
         
Creates a new post given a @var{post} structure.

@itemize{
  @item{@var{post} - the post to post;}
  @item{@var{replace?} - replace a previous post if the URL has already been posted: default no;}
  @item{@var{shared?} - make the post public: default no.}}

This procedure delegates to @var[add-post/raw!] to do most of the work. Fields in the post are automatically mapped to @var[void] when appropriate.

}

@defproc[(add-post/raw! [url string]
                        [description string]
                        [extended (U string void) void]
                        [tags (U (list-of string) void) void]
                        [date (U srfi-19:date void) void]
                        [replace? (U boolean void) void]
                        [shared? (U boolean void) void])
         void]{
         
Creates a new post given the constituent parts of a @var{post} structure. @var{url}, @var{description}, @var{extended}, @var{tags} and @var{date} have the same purpose as the relevant fields of @var{post}.

}

@defproc[(delete-post! [post post]) void]{

Deletes an existing post given a @var{post} structure.

}

@defproc[(delete-post/raw! [url string]) void]{

Deletes an existing post given a URL.

}

@defproc[(all-bundles) (list-of bundle)]{

Returns a list of tag bundles in the current account.

}

@defproc[(update-bundle! [bundle bundle]) void]{

Creates or updates a tag bundle given a @var{bundle} structure. This procedure delegates to @var[update-bundle/raw!] to do most of the work. 

}

@defproc[(update-bundle/raw! [name string] [tags (list-of string)]) void]{

Creates or updates a tag bundle given its constituent parts.

@itemize{
  @item{@var{name} - the name of the tag bundle to create/update;}
  @item{@var{tags} - the (new) contents of the bundle.}}

}

@defproc[(delete-bundle! [bundle bundle]) void]{

Deletes a bundle given a @var{bundle} structure.

}

@defproc[(delete-bundle/raw! [name string]) void]{

Deletes a bundle given its name.

}
