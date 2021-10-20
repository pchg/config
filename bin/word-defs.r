REBOL [
    Title: "REBOL Dictionary Database" 
    Copyright: "2005 REBOL Technologies. All right reserved." 
    Date: 11-Sep-2005/15:58:57-7:00 
    Version: 2.0.6
]

* [[math] [/ // multiply divide] {

The datatype of the second value may be restricted to
INTEGER or DECIMAL, depending on the datatype of the
first value (e.g. the first value is a time).

^-print 123 * 10

^-print 12.3 * 10

^-print 3:20 * 3

}
] 
** [[math] [power exp log-2 log-10 log-e] {

This is the operator for the POWER function.

^-print 10 ** 2

^-print 12.345 ** 5

}
] 
+ [[math] [- add subtract] {

When adding values of different datatypes, the values
must be compatible.

^-print 123 + 1

^-print 12:00 + 11:00

^-print 31-Dec-1999 + 1

^-print 1.2.3.4 + 4.3.2.1

}
] 
- [[math] [+ add subtract negate absolute] {

If used with only a single value, it negates the
value (unary minus). When subtracting values of
different datatypes, the values must be compatible.

^-print 123 - 1

^-print -123  ; a negative number

^-print - 123  ; negating a positive number (unary)

^-print 12:00 - 11:00

^-print 1-Jan-2000 - 1

^-print 1.2.3.4 - 1.0.3.0

}
] 
/ [[math] [* // divide] {

An error will occur if the second value is zero. When
dividing values of different datatypes they must be
compatible.

^-print 123 / 10

^-print 12.3 / 10

^-print 1:00 / 60

}
] 
// [[math] [* / remainder] {

Returns the value of the remainder after the first
number is divided by the second. If the second
number is zero, an error will occur.

^-print 123 // 10

^-print 25:32 // 24:00

If the first value is positive, then the returned remainder is nonnegative.
If the first value is negative, then the returned remainder is nonpositive.

}
] 
< [[comparison] [lesser? <= > >= = <> min max] {

Returns FALSE for all other values. An error will
occur if the values are not of the same datatype. For
string-based datatypes, the sorting order is used for
comparison with character casing ignored (uppercase =
lowercase).

^-print "abc" < "abcd"

^-print 12-June-1999 < 10-June-1999

^-print 1.2.3.4 < 4.3.2.1

^-print 1:30 < 2:00

^-print [1 2 3] < [1 5 3]
}
] 
<= [[comparison] [lesser-or-equal? < > >= = <> min max] {

Returns FALSE for all other values. For string-based
datatypes, the sorting order is used for comparison
with character casing ignored (uppercase = lowercase).

^-print "abc" <= "abd"

^-print 10-June-1999 <= 12-june-1999

^-print 4.3.2.1 <= 1.2.3.4

^-print 1:23 <= 10:00

}
] 
<> [[comparison] [= == not-equal?] {

String-based datatypes are considered equal when they
are identical or differ only by character casing
(uppercase = lowercase). Use == or find/match/case to
compare strings by casing.

^-print "abc" <> "abcd"

^-print [1 2 4] <> [1 2 3]

^-print 12-sep-98 <> 10:30

}
] 
= [[comparison] [<> == equal?] {

String-based datatypes are considered equal when they
are identical or differ only by character casing
(uppercase = lowercase). Use == or find/match/case to
compare strings by casing.

^-print 123 = 123

^-print "abc" = "abc"

^-print [1 2 3] = [1 2 4]

^-print 12-june-1998 = 12-june-1999

^-print 1.2.3.4 = 1.2.3.0

^-print 1:23 = 1:23

}
] 
== [[comparison] [= <> strict-equal?] {

Strict equality requires the values to not differ by
datatype (so 1 would not be equal to 1.0) nor by
character casing (so "abc" would not be equal to "ABC").

^-print 123 == 123

^-print "abc" == "ABC"

}
] 
=? [[comparison] [= == same?] {

This function returns true if two values are the same.
That is, there is no way to distinguish between them.
For instance, in the case of a string, they would
occupy the same memory.

^-a: "apple"
^-b: a
^-print a =? b

^-b: tail a
^-print a =? (head b)

^-print "apple" =? "apple"

}
] 
> [[comparison] [greater? < <= >= = <> min max] {

Returns FALSE for all other values. The values must be
of the same datatype or an error will occur. For
string-based datatypes, the sorting order is used for
comparison with character casing ignored (uppercase =
lowercase).

^-print "abc" > "abb"

^-print 16-June-1999 > 12-june-1999

^-print 4.3.2.1 > 1.2.3.4

^-print 11:00 > 12:00

^-print [1 2 3] > [1 1 3]

}
] 
>= [[comparison] [greater-or-equal? < <= > = <> min max] {

Returns FALSE for all other values. The values must be
of the same datatype or an error will occur. For
string-based datatypes, the sorting order is used for
comparison with character casing ignored (uppercase =
lowercase).

^-print "abc" >= "abb"

^-print 16-June-1999 >= 12-june-1999

^-print 1.2.3.4 >= 4.3.2.1

^-print 11:00 >= 11:00

}
] 
? [[help] [help what source] {

Synonym for HELP.

^-? switch

}
] 
?? [[help] [help ?] {

Handy for printing the value of a variable while debugging.

^-test: [123 "testing"]
^-?? test

}
] 
about [[help] [license usage help system] {

Displays REBOL title and version information on the REBOL
console.

^-about

}
] 
abs [[math] [- negate absolute] {

Returns a positive value equal in magnitude.

^-print absolute -123

^-print absolute -1:23

}
] 
absolute [[math] [abs - negate] {

A synonym for absolute.

}
] 
action? [[datatype] [function? op? native? any-function? type? any-type?] {

Actions are a special type of function that operates with datatypes.

^-print action? :add

^-print action? :append

^-print action? :+

^-print action? "add"

}
] 
add [[math] [+ - subtract] {

When adding values of different datatypes, the values
must be compatible.

^-print add 123 1

^-print add 1.2.3.4 4.3.2.1

^-print add 3:00 -4:00

^-print add 31-Dec-1999 1

}
] 
alert [[view request] [flash request inform] {

Post a simple alert message to the user.  The only choice
for the user is "OK".

}
] 
alias [[context] [set get] {

Create an alias for a word. The alias will be identical in  every
respect to the aliased word, including symbol comparison and value
referencing.

^-alias 'print "stampa"
^-do {stampa "MONDO Rebol"}

Be careful not to confuse alias with setting another word to the
same value.

The alias cannot be set if the word already appears anywhere within
the script or has been used in any way prior to being aliased. Normally
you will need to load aliases from a separate file or string.

Aliases are special because they work at the symbol table level,
allowing them to be used for refinements and dialect words as well.

}
] 
all [[control logic] [and any or] {

Evaluates each expression in a block until one of the
expressions returns NONE or FALSE, in which case a NONE is
returned. Otherwise, the value of the last expression will be
returned.

^-print all [1 none]

^-print all [none 1]

^-print all [1 2]

^-print all [10 > 1 "yes"]

^-print all [1 > 10 "yes"]

^-time: 10:30
^-if all [time > 10:00 time < 11:00] [print "time is now"]

No other expressions are evaluated beyond the point where
a value fails:

^-a: 0
^-all [none a: 2]
^-print a

^-a: 0
^-all [1 a: 2]
^-print a

^-day: 10
^-time: 9:45
^-ready: all [day > 5  time < 10:00  time: 12:00]
^-print time

}
] 
alter [[series modify sets] [find remove unique intersect exclude difference] {

The ALTER function is a type of data set operation. It either
adds or removes a value depending on whether the value is
already included. The word ALTER is short for the word
"alternate".

For example, let's say you want to keep track of a few options
used by your code. The options may be: FLOUR, SUGAR, SALT, and
PEPPER. The following code will create a new block (to hold
the data set) and add to it:

^-options: copy []
^-alter options 'salt
^-probe options

^-alter options 'sugar
^-probe options

You can use functions like FIND to test the presence of an
option in the set:

^-if find options 'salt [print "Salt was found"]

If you use ALTER a second time for the same option word, it will
be removed:

^-alter options 'salt
^-probe options

Normally ALTER values are symbolic words (such as those shown
above) but any datatype can be used such as integers, strings,
etc.  

^-alter options 120
^-alter options "test"
^-probe options

The return value for ALTER is not defined. Do not depend
on what it returns.
}
] 
and [[math logic] [or all not xor logic? integer?] {

For LOGIC values, both values must be TRUE to return
TRUE, otherwise a FALSE is returned. For integers, each
bit is separately affected (a numerical AND). All
arguments are fully evaluated.

^-print true and true

^-print true and false

^-print (10 < 20) and (20 > 15)

^-print 123 and 1

^-print 1.2.3.4 and 255.0.255.0

}
] 
and~ [[internal] [or~ xor~] {

The trampoline action function for AND operator.

}
] 
any [[control logic] [all or and case] {

Evaluates each expression in a block until one of the
expressions returns a value other than NONE or FALSE, in which
case the value is returned. Otherwise, NONE will be returned.

^-print any [1 none]

^-print any [none 1]

^-print any [none none]

^-print any [false none]

^-print any [true none]

^-time: 10:30
^-if any [time > 10:00  time < 11:00] [print "time is now"]

No other expressions are evaluated beyond the point where
a successful value is found:

^-a: 0
^-any [none a: 2]
^-print a

^-a: 0
^-any [1 a: 2]
^-print a

^-day: 10
^-time: 9:45
^-ready: any [day > 5  time < 10:00  time: 12:00]
^-print time

ANY is useful for setting default values. For example:

^-size: any [size 100]

If SIZE was NONE, then it gets set to 100. This works even
better if there are alternative defaults:

^-size: any [size prefs/size 100]

Another use for ANY is to emulate a sequence of
if...elseif...elseif...else. Instead of writing:

^-either cond-1 [
^-^-code-1
^-] [
^-^-either cond-2 [
^-^-^-code-2
^-^-] [
^-^-^-either cond-3 ...
^-^-]
^-]

it is possible to write:

^-any [
^-^-if cond-1 [
^-^-^-code-1
^-^-^-true ; in case code-1 returns FALSE or NONE
^-^-]
^-^-if cond-2 [
^-^-^-code-2
^-^-^-true
^-^-]
^-^-...
^-]

See the CASE function as well for this type of usage.
}
] 
any-block! [[datatype] [block! paren! path! any-block? any-function! any-string! any-type!] {

Represents any type of block. When
provided within the function's argument specification,
it requests the interpreter verify that the argument
value is of the specified type when the function is
evaluated.

^-fun: func [arg [any-block!]] [probe :arg]
^-fun [1 2 3]

^-fun first [(1 2 3)]

^-fun 'a/b/c

}
] 
any-block? [[datatype] [block? paren? path? any-function? any-string? any-type? any-word?] {

Returns FALSE for all other values.

^-print any-block? [1 2]

^-print any-block? first [(1 2) 3]

^-print any-block? 'a/b/c

^-print any-block? 12

}
] 
any-function! [[datatype function] [function! native! op! any-block! any-string! any-type! any-word!] {

Represents functions of any type. When provided within
the function's argument specification, it requests the
interpreter verify that the argument value is of the
specified type when the function is evaluated.

^-fun: func [arg [any-function!]] [print type? :arg]
^-fun :print

^-fun :fun

^-fun :+

}
] 
any-function? [[datatype function] [function? native? op? any-block? any-string? any-type? any-word?] {

Returns FALSE for all other values.

^-print any-function? :find

^-print any-function? :+

^-print any-function? func [] [print "hi"]

^-print any-function? 123

}
] 
any-string! [[datatype] [string! file! email! url! any-block! any-function! any-type!] {

Represents any type of string. When provided within 
the function's argument specification, it requests the 
interpreter verify that the argument value is of the 
specified type when the function is evaluated.

^-fun: func [arg [any-string!]] [print arg]
^-fun "string"

^-fun %file.txt

^-fun http://www.rebol.com

^-fun email@rebol.com

}
] 
any-string? [[datatype] [string? file? email? url? any-block? any-function? any-type?] {

Returns FALSE for all other values.

^-if any-string? "Hello" [print "a string"]

^-probe any-string? email@rebol.com

^-probe any-string? ftp://ftp.rebol.com

^-probe any-string? %/path/to/file.txt

^-probe any-string? 11-Jan-2000

}
] 
any-type! [[datatype] [any-block! any-function! any-string! any-word!] {

Represents any type of value. When provided within the 
function's argument specification, that argument 
becomes optional to the function. Optional arguments
must be the last specified within a function's argument
specification.

^-fun: func [arg [any-type!]] [
^-^-print either value? 'arg [arg]["no argument specified"]
^-]
^-fun 123

^-fun "test"

^-fun [1 3 4]

^-fun

}
] 
any-type? [[datatype] [any-type! any-block? any-function? any-string? any-word?] {

Returns TRUE for values of any type. Because any value 
that can successfully be passed to ANY-TYPE? is a value
of some type, ANY-TYPE? never returns FALSE. However, 
an error will occur if a value cannot be passed to 
ANY-TYPE?.

^-print any-type? http://www.REBOL.com

}
] 
any-word! [[datatype] [any-word? any-block! any-function! any-string! any-type!] {

Represents any type of word. When provided within the 
function's argument specification, it requests the 
interpreter verify that the argument value is of the 
specified type when the function is evaluated.

^-fun: func [word [any-word!]] [probe type? :word]
^-foreach w [word set-word: 'lit-word :get-word][fun :w]

}
] 
any-word? [[datatype] [any-word! any-block? any-function? any-string? any-type?] {

Returns FALSE for all other values.

^-print any-word? 'word

^-foreach word [word set-word: 'lit-word :get-word 123] [
^-^-print [
^-^-^-rejoin [{"} mold :word {"}] 
^-^-^-either any-word? :word [
^-^-^-^-"is a type of word."]["is not a type of word."]
^-^-]
^-]

}
] 
append [[series string modify] [insert change remove] {

Works on any type of series, including strings and blocks.
Returns the series at its head.

/ONLY forces a block to be inserted as a block element 
(works only if the first argument is a block).

^-string: copy "hello"
^-probe append string " there"

^-file: copy %file
^-probe append file ".txt"

^-url: copy http://
^-probe append url "www.rebol.com"

^-block: copy [1 2 3 4]
^-probe append block [5 6]

^-probe append/only block [a block]

}
] 
arccosine [[math] [arcsine arctangent cosine exp log-10 log-2 log-e pi power 
        sine square-root tangent
    ] {

Inverse function to the cosine.

^-print arccosine .5

}
] 
arcsine [[math] [arccosine arctangent cosine exp log-10 log-2 log-e pi power 
        sine square-root tangent
    ] {

Inverse function to the sine.

^-print arcsine .5

}
] 
arctangent [[math] [arccosine arcsine cosine exp log-10 log-2 log-e pi power 
        sine square-root tangent
    ] {

Inverse function to the tangent.

^-print arctangent .22

}
] 
array [[series] [make pick poke] {

In REBOL, arrays are simply blocks that are initialized to a
specific size with all elements set to an initial value (NONE by
default). The ARRAY function is used to create and initialize
arrays.

Supplying a single integer as the argument to ARRAY will create
an array of a single dimension. The example below creates a five
element array with values set to NONE:

^-block: array 5
^-probe block

^-print length? block

To initialize an array to values other than NONE, use the
/INITIAL refinement. The example below intializes a block with
zero values:

^-block: array/initial 5 0
^-probe block

To create an array of multiple dimensions, provide a block of
integers as the argument to the ARRAY function. Each integer
specifies the size of that dimension of the array. (In REBOL,
such multidimensional arrays are created using blocks of blocks.)

^-xy-block: array [2 3]
^-probe xy-block

^-xy-block: array/initial [2 3] 0
^-probe xy-block

Once an array has been created, you can use paths or the PICK
and POKE functions to set and get values of the block based on
their indices:

^-block/3: 1000
^-poke block 5 now
^-probe block

^-probe block/3

^-repeat n 5 [poke block n n]
^-probe block

^-xy-block/2/1: 1.2.3
^-xy-block/1/3: copy "test"
^-probe xy-block

^-probe xy-block/2/1

^-repeat y 2 [
^-^-dim: pick xy-block y
^-^-repeat x 3 [poke dim x to-pair reduce [x y]]
^-]
^-probe xy-block

Coding style note: REBOL uses the concept of expandable series
for holding and manipulating data, rather than the concept of
fixed size arrays. For example, in REBOL you would normally
write:

^-block: copy []
^-repeat n 5 [append block n]

rather than:

^-block: array 5
^-repeat n 5 [poke block n n]

In other words, REBOL does not require you to specify the size
of data arrays (blocks, bytes, or strings) in advance. They are
dynamic.

}
] 
as-binary [[string datatype] [as-string to-binary to] {

AS-BINARY converts a string datatype to a binary datatype
but without copying the contents of the string. Normally,
if you use TO-BINARY, a new string will be created.

This function is most useful if you have large strings that you need
to access or modify using binary operations.

^-print as-binary "Testing 1...2...3"
^-
^-print as-binary #ABC-def-xyz

^-print as-binary %test-file.txt

}
] 
as-pair [[view datatype] [to-pair pair! pair?] {

Provides a shortcut for creating PAIR values from separate X and
Y integers.

^-print as-pair 100 50

See the PAIR! word for more detail.
}
] 
as-string [[string datatype] [as-binary to-string to] {

AS-STRING converts a binary datatype to a string datatype but
without copying the contents of the binary string. Normally, if you
use TO-STRING, a new string will be created.

This function is most useful if you have large binary strings that
you need to access or modify using other string operations.

^-data: as-string read/binary %bin-file

^-print as-string #{54657374696E6720312E2E2E322E2E2E33}
^-
^-print as-string #{4142432D6465662D78797A}

^-print as-string #{746573742D66696C652E747874}}
] 
ask [[request] [confirm input prin] {

Provides a common prompting function that is the same as
a PRIN followed by an INPUT. The resulting input will
have spaces trimmed from its head and tail. The /HIDE
refinement hides input with "*" characters.

^-print ask "Your name, please? "

}
] 
at [[series string] [skip pick head tail] {

Provides a simple way to index into a series. AT returns
the series at the new index point. Note that the
operation is relative to the current position within the
series.

^-numbers: [11 22 33]
^-print at numbers 2

^-words: [grand grape great good]
^-print first at words 2

^-remove at words 2
^-insert at words 3 [super]
^-probe words

}
] 
attempt [[control] [try error?] {

The ATTEMPT function is a shortcut for the frequent case of:

^-error? try [block]

The format for ATTEMPT is:

^-attempt [block]

ATTEMPT is useful where you either do not care about the error
result or you want to make simple types of decisions based on
the error.

^-attempt [make-dir %fred]

ATTEMPT returns the result of the block if an error did not
occur.  If an error did occur, a NONE is returned.

In the line:

^-value: attempt [load %data]
^-probe value

the value is set to NONE if the %data file cannot be loaded
(e.g. it is missing or contains an error).  This allows you to
write conditional code such as:

^-if not value: attempt [load %data] [print "Problem"]

Or code such as:

^-value: any [attempt [load %data] [12 34]]
^-probe value

}
] 
back [[series string] [next last head tail head? tail?] {

If the series is at its head, it will remain at its
head. BACK will not go past the head, nor will it wrap
to the tail.

^-print back tail "abcd"

^-str: tail "time"
^-until [
^-^-str: back str
^-^-print str
^-^-head? str
^-]

^-blk: tail [1 2 3 4]
^-until [
^-^-blk: back blk
^-^-print first blk
^-^-head? blk
^-]

}
] 
binary! [[datatype] [binary? make type?] {

The binary datatype is a series of 8 bit bytes. The word
BINARY! represents the BINARY datatype both externally
to the user and internally within the system. When
supplied as an argument to the MAKE function, it
specifies the type of value to be created. When provided
within the function's argument specification, it
requests the interpreter to verify that the argument
value is of the specified type when the function is
evaluated.

^-probe make binary! "1234"

}
] 
binary? [[datatype] [binary! type?] {

Returns FALSE for all other values.

^-print binary? #{13ff acd0}

^-print binary? 1234

}
] 
bind [[context] [use do func function does make] {

Binds meaning to words in a block. That is, it gives
words a context in which they can be interpreted.
This allows blocks to be exchanged between different
contexts, which permits their words to be understood.
For instance a function may want to treat words in a
global database as being local to that function.

The second argument to BIND is a word from the
context in which the block is to be bound. Normally, this is
a word from the local context (e.g. one of the function
arguments), but it can be a word from any context within
the system.

BIND will modify the block it is given. To avoid that,
use the /COPY refinement. It will create a new block
that is returned as the result.

^-words: [a b c]
^-fun: func [a b c][print bind words 'a]
^-fun 1 2 3
^-fun "hi" "there" "fred"

^-words: [a b c]
^-object: make object! [
^-^-a: 1
^-^-b: 2
^-^-c: 3
^-^-prove: func [] [print bind words 'a]
^-]
^-object/prove

^-settings: [start + duration]
^-schedule: function [start] [duration] [
^-^-duration: 1:00
^-^-do bind settings 'start
^-]
^-print schedule 10:30

}
] 
bitset! [[datatype sets] [bitset? charset] {

The bitset datatype is a set of bits to represent
existence of characters or small integer numbers. The
bitset! word represents the BITSET datatype, both
externally to the user and internally within the system.
When supplied as an argument to the MAKE function, it
specifies the type of value to be created. When provided
within the function's argument specification, it
requests the interpreter to verify that the argument
value is of the specified type when the function is
evaluated.

^-test-bits: make bitset! "12345"
^-if find test-bits "2" [print "Found it!"]

^-print find test-bits "236"

^-print find test-bits "129"

^-test-bits: make bitset! 96
^-insert test-bits 40
^-print find test-bits 40

^-print find test-bits 37

}
] 
bitset? [[datatype sets] [bitset!] {

Returns FALSE for all other values.

^-print bitset? make bitset! "abc"

^-print bitset? 123

}
] 
block! [[datatype] [block? make type?] {

Represents the BLOCK datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within a
function's argument specification, it requests the
interpreter to verify that the argument value is of that
type when the function is evaluated.

^-block: make block! 100
^-repeat n 10 [insert block random n * 10]
^-print block

^-fun: func [arg [block!]] [print arg]
^-fun [1 2 3]

}
] 
block? [[datatype] [block! type?] {

Returns FALSE for all other values.

^-print block? [1 2 3]

^-print block? "1 2 3"

^-data: load "1 2 3"  ;  converts "1 2 3" into a block
^-if block? data [print data]

}
] 
break [[control] [catch exit return loop repeat for forall foreach forever forskip while until] {

The current loop is immediately terminated and evaluation
resumes after the LOOP function. This function can be placed
anywhere within the block being repeated, even within a sub
block or function.

^-repeat n 5 [
^-^-print n
^-^-if n > 3 [break]
^-]

}
] 
brightness? [[view] [] {

This function converts an RGB tuple to a black and white
brightness value between between 0 and 1.

^-print brightness? 255.255.255

^-print brightness? 0.0.0

^-print brightness? 255.0.0

^-print brightness? 128.128.128

}
] 
browse [[system] [] {

If the browser cannot be found, nothing will happen.

}
] 
build-attach-body [[internal] [] {

Internal REBOL word.

}] 
build-markup [[string] [build-tag parse-xml] {

This function was inspired by the EREBOL concept of Maarten 
Koopmans and Ernie van der Meer. Essentially, the idea is that 
REBOL makes a powerful PHP style markup processor for generating 
web pages and other markup text.

The BUILD-MARKUP function has been added to support this 
operation, and will become a standard part of every REBOL 
implementation.

The BUILD-MARKUP function takes markup text (e.g. HTML) that 
contains tags that begin with "<%" and end with "%>". It 
evaluates the REBOL code within each tag (as if it were a REBOL 
block), and replaces the tag with the result. Any REBOL 
expression can be placed within the tag. As PHP has shown, this 
is a very useful technique.

For example:

^-== build-markup "<%1 + 2%>"
^->> "3"

^-== build-markup "<B><%1 + 2%></B>"
^->> "<B>3</B>"

^-== build-markup "<%now%>"
^->> "2-Aug-2002/18:01:46-7:00"

^-== build-markup "<B><%now%></B>"
^->> "<B>2-Aug-2002/18:01:46-7:00</B>"

Supplying a <%now%> tag to BUILD-MARKUP inserts the current 
date/time in the output.

Here's a short example that generates a web page from a template 
and a custom name and email address:

^-template: {<HTML>
^-    <BODY>
^-    Hi <%name%>, your email is <i><%email%></i>.<P>
^-    </BODY>
^-    </HTML>
^-}

^-name: "Bob"
^-email: bob@example.com
^-page: build-markup template

Don't forget the two % characters within the tag. It's a common 
mistake.

The value that is returned from the tag code is normally "joined" 
into the output. You can also use FORM or MOLD on the result to 
get the type of output you require. The example below loads a 
list of files from the current directory and displays them three 
different ways:

Input: "<PRE><%load %.%></PRE>"
Result: {<PRE>build-markup.rchanges.txt</PRE>}

Input: "<PRE><%form load %.%></PRE>"
Result: {<PRE>build-markup.r changes.txt</PRE>}

Input: "<PRE><%mold load %.%></PRE>"
Result: {<PRE>[%build-markup.r %changes.txt]</PRE>}

If the evaluation of a tag does not return a result (for example 
using code such as print "test"), then nothing is output. In this 
case, the output of PRINT will be sent to the standard output 
device.

Input: {<NO-TEXT><%print "test"%></NO-TEXT>}
test
Result: "<NO-TEXT></NO-TEXT>"

The BUILD-TAG function can be used within the tag for converting 
REBOL values into markup output:

Input: {<%build-tag [font color "red"]%>}
Result: {<font color="red">}

Tags can set and use variables in the same way as any REBOL script. 
For example, the code below loads a list of files from the current 
directory, saves it in a variable, then prints two file names:

Input: "<PRE><%first files: load %.%></PRE>"
Result: {<PRE>build-markup.r</PRE>}

Input: "<PRE><%second files%></PRE>"
Result: {<PRE>changes.txt</PRE>}

Note that variables used within tags are always global variables.

If an error occurs within a tag, an error message will appear as 
the tag's result. This allows you to see web page errors from any 
HTML browser.

Input: "<EXAMPLE><%cause error%></EXAMPLE>"
Result: {<EXAMPLE>***ERROR no-value in: cause error</EXAMPLE>}

If you do not want error messages to be output, use the /QUIET 
refinement. The example above would result in:

Result: "<EXAMPLE></EXAMPLE>"

}
] 
build-tag [[string] [tag! to-tag compose] {

Constructs an HTML or XML tag from a block.  Words
within the block are used to construct the attribute
words within the tag. If they are followed by a value,
that value will be assigned to the attribute. 
Parenthesized elements are evaluated as expressions and 
their resulting value is used.

^-print build-tag [font size 3]

^-print build-tag [font size (10 / 2)]

^-print build-tag [img src %image.jpg]

^-site: http://www.rebol.com/
^-main-index: %index.html
^-print build-tag [a href (join site main-index)]

^-root: %images/
^-download: %download1.gif
^-alt-download: "Download the Latest REBOL!"
^-print build-tag [
^-^-img src (rejoin [site root download])
^-^-alt (alt-download)
^-]

}
] 
call [[control system] [do launch] {

The CALL function interfaces to the operating system's command shell
to execute programs, shell commands, and redirect command input and
output.

CALL function is normally blocked by the security level specified with
the SECURE function. To use it, you must change your SECURE settings
or run the script with reduced security (at your own risk).

The CALL function accepts one argument, which can be a string or a
block specifying a shell command and its arguments. The following
example shows a string as the CALL argument.

^-call "cp source.txt dest.txt"

Use a block argument with CALL when you want to include REBOL values
in the call to a shell command, as shown in the following example:

^-source: %source.txt
^-dest: %dest.txt
^-call reduce ["cp" source dest]

The CALL function translates the file names in a block to the
notation used by the shell. For example:

^-[dir %/c/windows]

will convert the file name to windows shell syntax before doing it.

When shell commands are called, they normally run as a separate
process in parallel with REBOL. They are asynchronous to REBOL.
However, there are times when you want to wait for a shell command
to finish, such as when you are executing multiple shell commands.
In addition, every shell command has a return code, which normally
indicates the success or failure of the command. Typically, a shell
command returns zero when it is successful and a non-zero value when
it is unsuccessful.

The /wait refinement causes the CALL function to wait for a
command's return code and return it to the REBOL program. You can
then use the return code to verify that a command executed
successfully, as shown in the following example:

^-if zero? call/wait "dir" [
^-^-print "worked"
^-]

In the above example, CALL successfully executes the Windows dir
command, which is indicated by the zero return value. However, in
the next example, CALL is unsuccessful at executing the xcopy
command, which is indicated by the return value other than zero.

^-if not zero? code: call/wait "xcopy" [
^-^-print ["failed:" code]
^-]

In Windows and Unix (Linux), input to a shell command can be
redirected from a file, URL, string, or port. By default, a shell
command's output and errors are ignored by REBOL. However, shell
command output and errors can be redirected to a file, URL, port,
string, or the REBOL console.

^-instr: "data"
^-outstr: copy ""
^-errstr: copy ""
^-call/input/output/error "sort" instr outstr errstr
^-print [outstr errstr]
 
See the REBOL Command Shell Interface documentation for more details.

}
] 
caret-to-offset [[view face] [] {

This function is provided to convert from a string character
index position to an xy offset within the text of a face.  This
is used primarily for text editing or for text mapping operations
such as for creating colored or hyperlinked text.

^-out: layout [
^-^-bx: box 10x15 red
^-^-tx: body 100x100
^-]
^-tx/text: {This is an example character string.}
^-xy: caret-to-offset tx at tx/text 14
^-bx/offset: tx/offset + xy
^-view out

Note that the resulting offset (xy) was added to the face
position (tx/offset) to find the correct position to locate the
box (bx).

In the above example the caret-to-offset function was used on a
face that have not yet been shown, but it can also be used after
a face has been shown.

Remember that when making changes to the contents of strings
that are longer than 200 characters, you must set the text face
line-list to NONE to force the recomputation of all line breaks.

See the offset-to-caret function for the reverse conversion.

This function can also work on faces that have never been shown.
This makes pre-display processing, colored text, and
hyperlinking possible using this function in combination with
SIZE-TEXT.

}
] 
case [[control] [switch select] {

The CASE function provides a useful way to evaluate different
expressions depending on specific conditions. It differs from the
SWITCH function because the conditions are evaluated and can be an
expression of any length.

The basic form of CASE is:

^-case [
^-^-cond1 [code1]
^-^-cond2 [code2]
^-^-cond3 [code3]
^-]
 
The conditions can return TRUE, FALSE, NONE, or any other value
(considered to be TRUE). Each condition is evaluated in turn until a
TRUE condition is found.

^-case [
^-^-num < 10 [print "small"]
^-^-num < 100 [print "medium"]
^-^-num < 1000 [print "large"] 
^-]

To create a default case, simply use TRUE as your last condition:

^-case [
^-^-num < 10 [print "small"]
^-^-num < 100 [print "medium"]
^-^-num < 1000 [print "large"] 
^-^-true [print "huge"]
^-]

The CASE function will return the value of the last expression it
evaluated. This can come in handy:

^-value: case [
^-^-num < 10 [num + 2]
^-^-num < 100 [num / 2]
^-^-true [0]
^-]

Normally the CASE function stops after the first true condition is
found and its block evaluated. However, the /all option forces CASE
to evaluate the expressions for all TRUE conditions.

}
] 
catch [[control function] [throw do try] {

CATCH and THROW go together. They provide a way to exit
from a block without evaluating the rest of the block.
To use it, provide CATCH with a block to evaluate. If
within that block a THROW is evaluated, it will return
from the CATCH at that point. The result of the CATCH
will be whatever was passed as the argument to the
THROW. When using multiple CATCH functions, provide
them with a name using the /NAME refinement to identify
which one will CATCH which THROW.

^-write %file.txt "i am a happy little file with no real purpose"
^-print catch [
^-^-if exists? %file.txt [throw "Doc found"]
^-^-"Doc not found"
^-]

}
] 
center-face [[view face] [] {

This function is used for centering a face relative to the
screen or relative to other faces.  It is useful for displaying
dialog boxes or other types of windows that require the user's
attention.

In the example below, a layout face is shown in its default
position, then it is displayed in the center of the screen.

^-out1: layout [
^-^-vh2 "Bust'n Chops"
^-^-body "With the Internet we're bust'n chops worldwide."
^-]
^-view out1
^-center-face out1
^-view out1

To position a face relative to another face use the /with
refinement.

^-out2: layout [vh2 "Ok boss."]
^-out1/offset: 200x200
^-center-face/with out2 out1
^-view/new out1
^-view/new out2
^-wait 1
^-unview/all

The out2 face is centered over the out1 face.

}
] 
change [[series string modify] [append clear insert remove sort] {

If the second argument is a simple value, it will
replace the value at the current position in the first
series. If the second argument is a series compatible
with the first (block or string-based datatype), all of 
its values will replace those of the first argument or
series.

The /PART refinement changes a specified number of 
elements within the target series.

For the convenience of cascading multiple changes the
CHANGE function returns the series position just past the
change.

^-probe head change "bog" "d"

^-probe head change [123 "test"] "the"

^-probe head change/dup "abc" "->" 5

^-probe head change/part "abcde" "1234" 2

^-probe head change [1 4 5] [1 2 3]

^-title: copy "how it REBOL"
^-change title "N"
^-probe title

^-change find title "t" "s"
^-probe title

^-blk: copy ["now" 12:34 "REBOL"]
^-change next blk "is"
^-probe blk

^-probe head change/only [1 4 5] [1 2 3]

^-probe head change/only [1 4 5] [[1 2 3]]

^-string: copy "crush those grapes"
^-change/part string "eat" find/tail string "crush"
^-probe string

}
] 
change-dir [[file] [make-dir what-dir list-dir] {

Changes the value of system/script/path. This value is
used for file-related operations. Any file path that
does not begin with a slash (/) will be relative to the
path in system/script/path. When a script file is
executed using the DO native, the path will
automatically be set to the directory containing the
path. When REBOL starts, it is set to the current
directory where REBOL is started.

^-current: what-dir
^-make-dir %./rebol-temp/
^-probe current

^-change-dir %./rebol-temp/
^-probe what-dir

^-change-dir current
^-delete %./rebol-temp/
^-probe what-dir

}
] 
char! [[datatype] [char? make type?] {

Represents the CHAR datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
specification of the argument of a function, it requests
the interpreter to check that the argument value is of
the specified type when the function is evaluated.

^-char: #"A"
^-print type? char

^-print char

^-print head insert "BCD" char

}
] 
char? [[datatype] [char! type?] {

Returns FALSE for all other values.

^-print char? #"1"

^-print char? 1

}
] 
charset [[sets] [bitset char! char?] {

A shortcut for MAKE BITSET! Used commonly for character
based bit sets.

^-chars: charset "aeiou"
^-print find chars "o"

^-print find "there you go" chars

^-digits: charset "0123456789"
^-area-code: ["(" 3 digits ")"]
^-phone-num: [3 digits "-" 4 digits]
^-print parse "(707)467-8000" [[area-code | none] phone-num]

}
] 
checksum [[string] [string! string? any-string! any-string?] {

Generally, a checksum is a number which accompanies data 
to verify that the data has not changed (did not have 
errors).

^-print checksum "now is the dawning"

^-print checksum "how is the dawning"

The /Secure refinement creates a binary string result that
is cryptographically secure:

^-print checksum/secure "fred-key"

^-print checksum/secure form now

The /TCP refinement is used to compute the standard TCP 
networking checksum. This is a weak but fast checksum method.

^-print checksum/tcp "now is the dawning"

^-print checksum/tcp "how is the dawning"

}
] 
choose [[view] [] {

This function pops-up a list of choices for user selection. The
function does not return until the user has picked one of the
choices or clicked outside of the popup area.

The CHOOSE function takes a block of choices as its first
argument. Its second argument is a function that is called when
a choice has been made.

^-choose ["A" "B" "C"] func [face btn] [print face/text]

}
] 
clean-path [[file string] [split-path change-dir dir? list-dir] {

Rebuilds a directory path after decoding parent (..) and
current (.) path indicators.

^-probe clean-path %com/www/../../../graphics/image.jpg

^-messy-path: %/rebol/scripts/neat-stuff/../../experiments/./tests
^-neat-path: clean-path messy-path
^-probe neat-path

URLs are returned unmodified (because the true paths may not
be known).

}
] 
clear [[series string modify] [remove append change insert sort] {

CLEAR is similar to REMOVE but removes through the end
of the series rather than just a single value.

^-str: copy "with all things considered"
^-clear skip str 8
^-print str

^-str: copy "get there quickly"
^-clear find str "qui"
^-print str

}
] 
clear-face [[view face] [clear-face get-face reset-face set-face] {

This face accessor function makes it easy to clear a face,
so you don't have to remember what facet (property) each
style uses to store its data. It also allows you to write 
generic loops that clear multiple faces.

^-view layout [
^-^-h2 "Enter your name below:"
^-^-f-name: field
^-^-across
^-^-btn "Send" [sendit]
^-^-btn "Clear" [clear-face f-name]
^-]

}
] 
clear-fields [[view] [] {

Clear all the fields of a layout.  This is often used for
input forms each time they are displayed.

}
] 
close [[port file] [open load do send] {

Closes a port opened earlier with the OPEN function. Any changes
to the port data that have been buffered will be written.

^-port: open %test-file.txt
^-insert port "Date: "
^-insert port form now
^-insert port newline
^-close port

^-print read %test-file.txt
}
] 
comment [[help] [do] {

This function can be used to add comments to a script or
to remove a block from evaluation. Note that this
function is only effective in evaluated code and has no
effect in data blocks. That is, within a data block
comments will appear as data. In many cases, using
COMMENT is not necessary. Placing braces around any 
expression will prevent if from being evaluated (so 
long as it is not part of another expression).

^-comment "This is a comment."

^-comment [print "As a comment, this is not printed"]

}
] 
complement [[math logic sets] [negate] {

Used for bitmasking of integer numbers and inverting
bitsets (charsets).

^-print complement 0

^-print complement -1

^-chars: complement charset "ther "
^-print find "there it goes" chars

}
] 
component? [[system] [] {

COMPONENT? is a helper function that checks for the existence of
a named REBOL component.

^-if component? 'crypt [print "Encryption available."]

^-if not component? 'sound [print "No sound."]

}
] 
compose [[series] [reduce build-tag rejoin insert] {

Builds a block of values from another block of values, but
evaluates parenthesized expressions.

^-probe compose [result (1 + 2) ok]

The elements of the input block are placed in the output block
with the exception of parenthesized expressions, which have
their final values placed in the output block.

^-probe compose [time: (now/time) date: (now/date)]

If the result is itself a block, then the elements of that
block are inserted into the output block (in the same way as
INSERT).

^-colors: ["red" "green" "blue"]
^-probe compose [1 2 3 (colors)]

To insert a block instead of its elements, place another block
around it using the REDUCE function, or use the /ONLY
refinement:

^-colors: ["red" "green" "blue"]
^-probe compose [1 2 3 (reduce [colors])]

^-colors: ["red" "green" "blue"]
^-probe compose/only [1 2 3 (colors)]

To evaluate sub-block parens, use the /DEEP refinement:

^-probe compose/deep [1 [2 [(1 + 2) 4]]]

}
] 
compress [[string] [decompress] {

As with all compressed files, keep an uncompressed copy
of the original data file as a backup.

^-print compress "now is the dawning"

^-string: form first system/words
^-print length? string

^-small: compress string
^-print length? small

}
] confine [[view] [inside? outside?] {

This is a common clipping function that is used to keep an object
within a specific area of the screen.

^-print confine 100x100 50x50 150x150 300x300

}] 
confirm [[request] [ask input prin] {

This function provides a method of prompting the user
for a TRUE ("y" or "yes") or FALSE ("n" or "no")
response. Alternate responses can be identified with the
/WITH refinement.

^-confirm "Answer: 14. Y or N? "

^-confirm/with "Use A or B? " ["A" "B"]

}
] 
connected? [[port] [] {

This function returns true if connected over the network. Note,
however, that this function differs between REBOL View and Link,
and it may not be a clear indicator of a true connection to the
Internet.

In View, this function returns TRUE if the Internet interface is
available. This does not mean that the computer is actually
connected to the Internet, because that can only be determined
by actually connecting to another computer, such as a web
server. For example, the function may return true, but your
computer may have lost its Internet connection because your
modem hung-up or local network went down.

^-print connected?

A way to actually check for an Internet connection is to try
to open a port to an known server. For example, this code will
return TRUE if an Internet connection can be made:

^-print not error? try [close open tcp://hq.rebol.net:80]

Note, however, that if the rebol.com site is not available or
unreachable, this line of code will return FALSE.

In REBOL/Link, the connected? function will return TRUE if the
Link client is currently connected to the IOS server. Note
however that the script must include the Link-app header type,
and be launched from within the Link environment.

}
] 
construct [[datatype series] [make context] {

This function creates new objects but without evaluating the
object's specification (as is done in the MAKE and CONTEXT
functions).

When you CONSTRUCT an object, only literal types are accepted.
Functional evaluation is not performed. This allows your code to
directly import objects (such as those sent from unsafe external
sources such as email, cgi, etc.) without concern that they may
include "hidden" side effects using executable code.

CONSTRUCT is used in the same way as the CONTEXT function:

^-obj: construct [
^-^-name: "Fred"
^-^-age: 27
^-^-city: "Ukiah"
^-]
^-probe obj

But, very limited evaluation takes place.  That means object
specifications like:

^-obj: construct [
^-^-name: uppercase "Fred"
^-^-age: 20 + 7
^-^-time: now
^-]
^-probe obj

do not produce evaluated results.

The CONSTRUCT function only performs evaluation on the words
TRUE, FALSE, NONE, ON, and OFF to produce their expected values.
Literal words and paths will also be evaluated to produce their
respective words and paths.  For example:

^-obj: construct [
^-^-a: true
^-^-b: none
^-^-c: 'word
^-]
^-probe obj

The CONSTRUCT function is useful for importing external
objects, such as preference settings from a file,
CGI query responses, encoded email, etc.

To provide a template object that contains default variable
values (similar to MAKE), use the /WITH refinement. The example
below would use an existing object called standard-prefs as the
template.

^-;prefs: construct/with load %prefs.r standard-prefs

}
] 
context [[context] [make] {

This function creates a unique new object. It is just a shortcut
for MAKE OBJECT!.

^-person: context [
^-^-name: "Fred"
^-^-age: 24
^-^-birthday: 20-Jan-1986
^-^-language: "REBOL"
^-]
^-probe person

^-person2: make person [
^-^-name "Bob"
^-]
^-probe person2
}
] 
copy [[series string] [change clear insert make remove] {

Be sure to use COPY on any string or block literal values
in your code if you expect to modify them.

For series, the /PART refinement will
copy a given number of values (specified as either a
count or as an ending series position).

^-str: copy "with all things considered"
^-print str

^-strings: copy ["how" "flies"]
^-print strings

^-insert next strings "time"
^-print strings

}
] 
copy* [[internal] [copy] {

An internal shortcut for COPY.

}
] 
cosine [[math] [arccosine arcsine arctangent pi sine tangent] {

Ratio between the length of the adjacent side to
the length of the hypotenuse of a right triangle.

^-print cosine 90

^-print (cosine 45) = (sine 45)

^-print cosine/radians pi

}
] 
cp [[internal] [copy] {

An internal shortcut for COPY.

}
] 
crlf [[constant string] [tab newline] {

Use CRLF as a shortcut to represent a carriage return and line
feed.

Typically you should use NEWLINE in your REBOL scripts rather
than CRLF.

^-print ["To return" crlf "Or not to return"]

}
] 
crypt-strength? [[encryption] [] {

Due to United States export laws, full strength encryption 
is not available in all countries. To determine the 
strength of your version, use the crypt-strength? function.

The crypt-strength? function returns the maximum encryption 
strength as a word. The result can be:

^-full - Full strength encryption available.  

^-export - Reduced strength encryption.  

^-none - No encryption available.  

For example,

^-if crypt-strength? [print "Encryption is available"]

will indicate that encryption is available. Or:

^-if crypt-strength? = 'full [print "Full encryption strength"]

will indicate that full strength encryption is available.

}
] 
cvs-date [[internal] [] {

Internal REBOL word.

}] 
cvs-version [[internal] [] {

Internal REBOL word.

}] 
datatype! [[datatype] [datatype? make] {

Represents the DATATYPE datatype, both externally to the
user and internally within the system. Any datatype
identifier such as STRING!, NUMBER! or SERIES! are of
the DATATYPE datatype, including DATATYPE! itself. When 
provided within the function's argument specification, 
it requests the interpreter to verify the argument value
is of the datatype DATATYPE when the function is 
evaluated.

^-make-121: func [arg [datatype!]][make arg 121]

^-probe make-121 string!  ; allocates memory for a string

^-probe make-121 block!   ; allocates memory for a block

^-probe make-121 integer! ; makes an integer "121"

^-probe make-121 time!    ; makes a time value (121 seconds)

}
] 
datatype? [[datatype] [datatype!] {

Returns FALSE for all other values.

^-print datatype? integer!

^-print datatype? 1234

}
] 
date! [[datatype] [date? make type? time!] {

Represents the DATE datatype, both externally to the
user and internally within the system. Date value
elements may be delineated either by "/" or "-" 
characters dd/mm/yyyy, or dd-mm-yyyy. Several date
formats are recognized by the language. These formats
are dd/mm/yy, dd/mm/yyyy, yyyy/mm/dd; The 'mm' may be 
represented as a numeric month (1-12), a month name
or the abbreviated month name. Regardless how the 
date is entered, date values are returned by REBOL in 
the dd-mmm-yyyy format with 'mmm' representing the 
abbreviated month. For instance, the third of March 
in the year 2001 is represented as 3-Mar-2001.

When supplied as an argument to the MAKE function, 
it specifies the type of value to be created. When 
provided within the specification of the argument 
of a function, it requests the interpreter to check 
that the argument value is of the specified type 
when the function is evaluated.

The components of a date value may be accessed using
refinements supported by the DATE datatype. These 
refinements are /DAY (get the day), /MONTH (get the
month), /YEAR (get the year), /WEEKDAY (get the 
weekday [1-7/Mon-Sun]), /JULIAN (get the day of the
year), /ZONE (get the time zone if present), /DATE 
(extract the day month and year from a date containing 
the time) and /TIME (get the time if present). Further 
refinements may be used with the /TIME refinement to 
obtain the components a time value pulled from a date. 
These refinements are /HOUR (get the hour), /MINUTE 
(get the minute), and /SECOND (get the second). 

^-when: make date! [30 6 2001]
^-probe when

^-probe when/day

^-probe when/month

^-probe when/year

^-probe pick [Mon Tue Wed Thu Fri Sat Sun] when/weekday

^-probe when/julian

^-when: 12-Jan-2001/18:06:01-8:00
^-probe when/time

^-probe when/time/hour

^-probe when/time/minute

^-probe when/time/second

^-probe when/zone

^-probe when/date

^-fun: func [arg [date!]][
^-^-days: [Monday Tuesday Wednesday Thursday Friday 
^-^-^-Saturday Sunday]
^-^-weekday: pick days arg/weekday
^-^-print [arg/date "is on a" form weekday]
^-]
^-fun 3/3/2001

^-fun when

^-fun now

}
] 
date? [[datatype] [date! type?] {

Returns FALSE for all other values.

^-print date? 1/3/69

^-print date? 12:39

}
] 
dbug [[internal] [] {

This is an internal debugging function used by the View desktop

}
] 
debase [[string] [enbase dehex] {

Converts from an encoded string to the binary value.
Primarily used for BASE-64 decoding.

The /BASE refinement allows selection of number base 
as 64, 16, 2. Default is base64.

^-probe debase "MTIzNA=="

^-probe debase/base "12AB C456" 16

^-enbased: probe enbase "a string of text"

^-probe string? enbased         ; enbased value is a string

^-debased: probe debase enbased ; converts to binary value

^-probe to-string debased       ; converts back to original string

If the input value cannot be decoded (such as when missing the
proper number of characters), a NONE is returned.

^-probe debase "100"

^-probe debase "1001"

}
] 
decimal! [[datatype] [decimal? number! make type?] {

Represents the DECIMAL datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-value: make decimal! "3.1415"
^-print value

^-print make decimal! [32 3]

^-print make decimal! [3.2 45]

}
] 
decimal? [[datatype] [decimal! number? type?] {

Returns FALSE for all other values.

^-print decimal? 1.2

^-print decimal? 1

}
] 
decloak [[encryption string] [encloak] {

DECLOAK is a low strength decryption method that is used with
ENCLOAK. See the ENCLOAK function for a complete description and
examples.
}
] 
decode-cgi [[string] [] {

Constructs a block of word value pairs from a name=value
text string argument delineated with the "&" character.
Obtain CGI queries by using DECODE-CGI to evaluate 
system/options/cgi/query-string, where CGI query strings
are stored for reference.

^-ex-query-string: "fname=John&lname=Doe&email=who@where.dom"
^-cgi-input: make object! decode-cgi ex-query-string
^-print probe cgi-input

^-print ["Name:   " cgi-input/fname cgi-input/lname]
^-print ["Email:  " cgi-input/email]

}
] 
decode-url [[port] [] {

This is a handy function that saves you the effort of writing
your own URL parser.

^- probe decode-url http://user:pass@www.rebol.com/file.txt
^- 
}
] 
decompress [[string] [compress enbase debase] {

If the data passed to the DECOMPRESS function has been
altered or corrupted, a decompression error will occur.

^-write %file.txt read http://hq.rebol.net

^-probe size? %file.txt

^-save %file.comp compress read %file.txt
^-probe size? %file.comp

^-write %file.decomp decompress load %file.comp
^-probe size? %file.decomp

}
] 
deflag-face [[view face] [flag-face flag-face?] {

VID faces have a /flags facet that can be used to store 
settings. You can use whatever values you want, but 
normally words are used. VID uses certain words for 
specific purposes. For example, the 'tabbed flag tells
VID whether a field is in the tab order of a layout.

To remove a field from the tab order, e.g. if you only
show the field under certain circumstances. You can then
hide the field and the user can't tab into it.

^-deflag-face f-my-field 'tabbed
^-hide f-my-field

}
] 
dehex [[string] [to-hex debase enbase] {

Converts the standard URL hex sequence that begins with a 
% followed by a valid hex value. Otherwise, the sequence 
is not converted and will appear as written.

^-print dehex "www.com/a%20dir/file"

^-print dehex "ABCD%45"

}
] 
delete [[file] [exists?] {

Deletes the file or URL object that is specified. If the
file or URL refers to an empty directory, then the
directory will be deleted.

^-write %delete-test.r "This file is no longer needed."
^-delete %delete-test.r

}
] 
delete-dir [[file] [delete make-dir exists?] {

This function deletes an entire directory, including all of its files
and subdirectories (recursively). It is being provided so you don't
need to create your own function for this action. Use it wisely.

^-delete-dir %temp-files/

}
] 
desktop [[system] [] {

You can programatically display the desktop from your scripts, though
normally this will be used directly in the console.

}
] 
detab [[string modify] [entab] {

The REBOL language default tab size is four spaces. Use
the /SIZE refinement for other sizes such as eight.
DETAB will remove tabs from the entire string even beyond
the first non-space character.

The series passed to this function is modified as a
result.

^-text: " lots    of  tabs    here"
^-print detab copy text

^-print detab/size text 8

}
] 
dh-compute-key [[encryption] [dh-make-key dh-generate-key] {

This function computes a session key from a locally 
generated DH private key object and the pub-key binary 
received from the peer. It returns the negotiated session 
key as a binary.

}
] 
dh-generate-key [[encryption] [dh-make-key dh-compute-key] {

This function creates a new DH public/private key pair. 
Before calling this function a dh-key object! has to be 
created using dh-make-key, and the generation environment 
(g, p) has to be filled in. After calling this function 
pub-key contains the public key and priv-key contains the 
private key.

}
] 
dh-make-key [[encryption] [dh-compute-key dh-generate-key] {

This function returns an empty object! laid out as a DH key. 
It does not fill in any data. The function is used in 
preparation for generating a new DH public/private key pair.

The /generate refinement causes the creation of a new 
"generation environment". The "generator" argument is part 
of the generation environment, and usually has the value 2. 
A "generation environment" is a set of numbers (g, p) with 
certain mathematical properties that is shared among a large 
group of participant and can be used to create DH keys of a 
certain size.

The number set describes a convention, is not secret, and is 
usually hard-coded into applications. It is not part of any 
individual DH key, but is needed in order in order to create 
DH keys and to use DH for exchanging session keys. 

Note that creating a new generation environment can take a 
VERY long time, possibly several minutes or hours, depending 
on the key size.

}
] 
difference [[sets series string] [intersect union exclude unique] {

Returns the elements of two series that are not present in both.
Both series arguments must be of the same datatype (string, block, etc.)
Newer versions of REBOL also let you use DIFFERENCE to compute
the difference between date/times.

^-lunch: [ham cheese bread carrot]
^-dinner: [ham salad carrot rice]
^-probe difference lunch dinner

^-probe difference [1 3 2 4] [3 5 4 6]

^-string1: "CBAD"    ; A B C D scrambled
^-string2: "EDCF"    ; C D E F scrambled
^-probe difference string1 string2

Date differences produce a time in hours:

^-probe difference 1-Jan-2002/0:00 1-Feb-2002/0:00

^-probe difference 1-Jan-2003/10:30 now

There is a limit to the time period that can be differenced
between dates (determined by the internal size of the TIME
datatype).

Note that performing this function over very large
data sets can be CPU intensive.

}
] 
dir? [[file] [make-dir modified? exists?] {

Returns FALSE if it is not a directory.

^-print dir? %file.txt

^-print dir? %.

}
] 
dirize [[file string] [] {

Convert a file name to a directory name.

For example:

^-probe dirize %dir

It is useful in cases where paths are used:

^-dir: %files/examples
^-new-dir: dirize dir/new-code
^-probe new-dir

This is useful because the PATH notation does not allow
you to write:

^-new-dir: dirize dir/new-code/

}
] 
disarm [[control] [error! trace try error? attempt] {

DISARM allows access to the values of an error object. If the
error is not disarmed, it will occur again immediately.

^-probe disarm try [1 + "x"]

The error object returned from DISARM can be used to determine
the type of error and its arguments. For example in the case
of a divide by zero error:

^-probe disarm try [1 / 0]

You might write a TRY block that handles the error after it
has happened:

^-if error? err: try [
^-^-value: 1 / 0
^-][
^-^-err: disarm err
^-^-either err/id = 'zero-divide [value: 0] [probe err quit]
^-]
^-print value

}
] 
dispatch [[control port] [wait] {

The DISPATCH function helps you setup complex WAIT situations that
involve multiple ports (for example, multiple Internet connections).

The argument passed to DISPATCH is a block that contains ports
and actions for those ports. The port value can be a port
datatype or a timeout value (the number of seconds as an integer
or decimal, or a time datatype for hours, minutes, and seconds).

The dispatch function then proceeds to wait for the ports
provided, or the timeout if provided. As ports signal their
changes, each port is processed according to the action block
provided. If a timeout occurs, its action block is processed.

^-port-block: [
^-^-tcp-port1 [print "port1 woke up"]
^-^-tcp-port2 [do port2-wakeup-call]
^-^-tcp-port3 [handle-port3]
^-^-tcp-port4 [if do-port4 ['break]]
^-^-0:01:00   [do-periodic-processing]
^-]
^-dispatch port-block

Normally, the DISPATCH function will wait forever, processing
the ports and timeouts that have been specified. However, if a
port action block returns the word BREAK, the DISPATCH function
is terminated and will exit.

Only a single timeout can be specified. If multiple timeouts
values are specified, only the first one is used.

Note: The WAIT awake function callbacks provide a useful
alternative to using DISPATCH, and they work well with GUI code.
The WAIT awake functions are callback functions that are
evaluted directly by the WAIT function when it awakes. A special
system queue keeps the list of awake functions.

}
] 
divide [[math] [* / // multiply] {

If the second value is zero, an error will occur. When
dividing values of different datatypes, they must be
compatible.

^-print divide 123.1 12

^-print divide 10:00 4

}
] 
do [[control file port] [load reduce loop repeat] {

Accepts a block, or loads a string, file, or URL into a block,
then evaluates the expressions of the block. Files and URLs must
have a valid REBOL header. Elements are evaluated left to right.
When an element encountered is a function requiring arguments,
the function's arguments are first evaluated then passed to the
function before it is evaluated. The value of final evaluation
is returned.

The /ARGS refinement allows you to pass arguments to another
script and is used with a file, or URL.  Arguments passed with
/ARGS are stored in  system/script/args within the context of
the loaded script.

The /NEXT refinement returns a block consisting of two elements.
The first element is the evaluated return of the first
expression encountered. The second element is the original block
with the current index placed after  the last evaluated
expression.

^-print do [1 + 2]

^-print do "1 + 2"

^-do "repeat n 3 [print n]"

^-do [print "doing"]

^-blk: [
^-^-[print "test"]
^-^-[loop 3 [print "loop"]]
^-]
^-do second blk

^-do first blk

^-blk: [
^-^-[1 + 2]
^-^-[3 * 4]
^-^-[6 / 3]
^-]
^-while [not empty? blk][
^-^-set [value blk] do/next blk
^-^-print value
^-]

}
] 
do-boot [[internal] [] {

Internal REBOL word.

}] 
do-browser [[internal] [] {

Internal REBOL word.

}] 
do-events [[view control] [] {

Process user events.  When this function is called the program
becomes event driven. This function does not return until all
windows have been closed.

}
] 
do-face [[view face] [do-face-alt] {

This will trigger the action of a face, as if the user 
clicked on it.

^-do-face my-face none

TBD: add docs about how to use the value parameter.

}
] 
do-face-alt [[view face] [do-face] {

This will trigger the action of a face, as if the user 
clicked on it with the right mouse button.

^-do-face-alt my-face none

}
] 
do-thru [[control file port] [do exists-thru? launch-thru load-thru path-thru read-thru] {

Evaluate a file by first reading it from a URL (such as a website)
and storing it locally in a cache file. The next time you evaluate
the same URL file, it will be read from the cache file, rather than
from the network.

}
] 
does [[function] [func function has exit return use] {

DOES provides a shortcut for defining functions that have no
arguments or local variables.

^-rand10: does [random 10]
^-print rand10

^-this-month: does [now/month]
^-print this-month

This function is provided as a coding convenience and it is
otherwise identical to using FUNC or FUNCTION.

}
] 
draw [[view face] [show] {

The DRAW function renders a standard DRAW EFFECT into an image
buffer. It allows DRAW commands (SVG) to be created without needing
a FACE and the TO-IMAGE function. With it, users can easily prebuild
vector graphics, and if the image is static, it is more efficient
too (because a DRAW EFFECT is regenerated each time the face object
is refreshed).

The function can take an existing image and draw on top of it or
create a new image of a given size. The graphics commands are
identical to the DRAW effect (and many new commands are provided
in the 1.3.0 release).

This example draws into an existing image:

^-image: draw logo [box 20x20 40x40]

This example creates a new image of the given size and draws into
it:

^-image: draw 300x300 [box 20x20 40x40 line 0x0 300x300]

Transparency is supported. The resulting image will use the alpha
channel.

}
] 
dsa-generate-key [[encryption] [dsa-make-key dsa-make-signature dsa-verify-signature] {

This function creates a new private/public DSA key pair. 
Before calling this function a dsa-key object! has to be 
created using dsa-make-key, and the generation environment 
(p, q and g) has to be filled in. After calling this 
function pub-key contains the public key and priv-key 
contains the private key.

}
] 
dsa-make-key [[encryption] [dsa-generate-key dsa-make-signature dsa-verify-signature] {

This function returns an empty object! laid out as a DSA key. 
It does not fill in any data. The function is mainly used in 
preparation for creating a DSA key used for signing or 
signature verification.

The /generate refinement causes the creation of a new 
"generation environment". A "generation environment" is a set 
of three numbers (p, q and g) with certain mathematical 
properties that is shared among a large group of participants 
and can be used to create DSA keys of a certain size.

The number set describes a convention, is not secret, and is 
usually hard-coded into applications. It is not part of any 
individual secret or public key, but is needed in order to 
perform secret or public key operations. The following 
generation environments can be used safely:

Note that creating a new generation environment can take a 
long time, possibly several minutes, depending on the key size.

}
] 
dsa-make-signature [[encryption] [dsa-make-key dsa-generate-key dsa-verify-signature] {

This function creates a signature object. Without the 
/sign refinement an empty signature object is created, 
ready to be filled in with a signature received in a 
transmission, for the purpose of signature verification. 
With the /sign refinement dsa-make-signature signs the 
specified data, and stores the signature in the returned 
signature object. The dsa-key passed in needs to contain 
the fields p, q, g, pub-key and priv-key.

Signatures contain two fields, r and s. Both fields 
together form the signature, and have to be sent to the 
recipient in order to allow verification of the signature.

}
] 
dsa-verify-signature [[encryption] [dsa-make-key dsa-generate-key dsa-make-signature] {

This function verifies whether the supplied signature 
is valid for the supplied data and has been generated 
by the private key corresponding to the supplied 
dsa-key. The dsa-key has to be a DSA public key with 
the fields p, q, g and pub-key filled in. The 
dsa-verify-signature returns true (valid signature) or 
false (invalid signature).

}
] 
dump-face [[help view face] [dump-obj help ? ??] {

This function provides an easy way to view the structure of a
face object and its sub-faces. It is an alternative to MOLD and
PROBE which may display far too much information.

^-out-face: layout [
^-^-h2 "Testing"
^-]
^-print dump-face out-face

}
] 
dump-obj [[help] [help ? ??] {

This function provides an easy way to view the contents of an
object. It is an alternative to MOLD and PROBE which may display
too much information for deeply structured objects.

^-print dump-obj system/error

}
] 
dump-pane [[internal] [dump-face] {

DUMP-FACE is a synonym for DUMP-FACE

}
] 
echo [[file help] [print trace] {

Write output to a file in addition to the user console.
The previous contents of a file will be overwritten. The
echo can be stopped with ECHO NONE or by starting
another ECHO.

^-echo %helloworld.txt
^-print "Hello World!"
^-echo none

}
] 
edge-size? [[view face] [] {

Knowing the size of a face's edge is important if you're manually 
positioning sub-faces when building styles with nested faces.

}
] 
editor [[file help system] [probe trace] {

The EDITOR function opens the simple built-in REBOL/View text
editor.

It accepts a variety of arguments. You can provide it with a
file name:

^-editor %script.r

or a URL, and it will download the file then display its text:

^-editor http://www.rebol.com/speed.r

or an object:

^-editor system/options

or other REBOL datatypes:

^-editor mold :append^-^-; source code to append
^-editor now^-^-^-^-; current date/time
^-editor stats/pools

Click the editors HELP button to view its keyboard shortcuts.
For example, pressing CTRL-E will evaluate the contents of the
current file.

}
] 
eighth [[series string] [first second third pick] {

See the FIRST function for examples.

An error will occur if no value is found. Use the PICK function to avoid this error.

}] 
either [[control] [if pick] {

Evaluate either one block or the other depending on a condition.
EITHER is identical to the if-else style comparison in other
languages.

^-grade: 72
^-either grade > 60 [
^-^-print "Passing Grade!"
^-][
^-^-print "Failing Grade!"
^-]

The EITHER function also returns the result of the block that it
evaluates.

^-print either grade > 60 ["Passing"]["Failing"]

}
] 
else [[control] [if either] {

See the EITHER function for if-then-else conditions.

^-either now/time > 10:30 [
^-^-print "later"
^-][
^-^-print "earlier"
^-]

}
] 
email! [[datatype] [email? make type?] {

Represents the EMAIL datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of that
type when the function is evaluated.

^-mail: make email! ["user" "domain.com"]
^-print mail

^-print mail/user

^-print mail/host

}
] 
email? [[datatype] [email! type?] {

Returns FALSE for all other values.

^-print email? info@rebol.com

^-print email? http://www.REBOL.com

}
] 
emailer [[internal] [desktop] {

This is meant to be used by the REBOL Desktop. If you want to use
it yourself (e.g. from the console), you'll need to do the following:

^-alive?: true
^-emailer
^-do-events
 
}
] 
empty? [[series string] [tail? none? found?] {

This is a synonym for TAIL? The check is made relative
to the current location in the series.

^-print empty? []

^-print empty? [1]

The EMPTY? function is useful for all types of series. For
instance, you can use it to check a string returned from the
user:

^-str: ask "Enter name:"
^-if empty? str [print "Name is required"]

It is often used in conjunction with TRIM to remove black spaces
from the ends of a string before checking it:

^-if empty? trim str [print "Name is required"]

}
] 
enbase [[string] [debase dehex] {

Converts from a string or binary into an encode string value.
Primarily used for BASE-64 encoding.

The /BASE refinement allows selection of
base as 64, 16, 2. Default is base64.

^-print enbase "Here is a string."

^-print enbase/base #{12abcd45} 16

The debase function is used to convert the binary back again.
For example:

^-bin: enbase "This is a string"
^-print debase bin

}
] 
encloak [[encryption string] [decloak] {

ENCLOAK is a low strength encryption method that can be useful for
hiding passwords and other such values. It is not a replacement for
AES or Blowfish, but works for noncritical data. Do not use it
for top secret information.

To cloak a string, provide the string and a cloaking key to the
ENCLOAK function:

^-str: encloak "This is a string" "a-key"

The result is an encrypted string which can be decloaked with the
line:

^-print decloak str "a-key"

The stronger your key, the better the encryption. For important data
use a much longer key that is harder to guess. Also, do not forget
your key, or it may be difficult or impossible to recover your data.

Now you have a simple way save out a hidden string, such as a
password:

    key: ask "Cloak key? (do not forget it) "
    data: "string to hide"
    save %data to-binary encloak data key

Note that the cloaked string is converted to a binary value because
it may contain special characters that would cause problems when
used as text.

To read the data and decloak it:

    key: ask "Cloak key? "
    data: load %data
    data: to-string decloak data key

Of course you can cloak any kind of data using these functions, even
binary data such as programs, images, sounds, etc. In those cases
you do not need the TO-BINARY and TO-STRING conversions shown above.

Note that by default, the cloak functions will hash your key strings
into 160 bit SHA1 secure cryptographic hashes. If you have created
your own hash key (of any length), you use the /WITH refinement to
provide it.

}
] 
entab [[string modify] [detab] {

The REBOL language default tab-size is four spaces.
Use the /SIZE refinement for other sizes such as eight.
ENTAB will only place tabs at the beginning of the
line (prior to the first non-space character).

The series passed to this function is modified as a
result.

^-text: {
^-^-no
^-^-tabs
^-^-in
^-^-this
^-^-sentence
^-} 
^-remove head remove back tail text
^-probe text

^-probe entab copy text

^-print entab copy text

^-probe entab/size copy text 2

^-print entab/size copy text 2

The opposite function is DETAB which converts tabs back to spaces:

^-probe entab text

^-probe detab text

}
] 
equal? [[comparison] [= <> == =? strict-equal?] {

String-based datatypes are equal when they are identical
or differ only by character casing (uppercase = lowercase).

^-print equal? 123 123

^-print equal? "abc" "abc"

^-print equal? [1 2 3] [1 2 4]

^-print equal? 12-june-1998 12-june-1999

^-print equal? 1.2.3.4 1.2.3.0

^-print equal? 1:23 1:23

}
] 
error! [[datatype] [error?] {

Represents the ERROR datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated. (Example
commented out so that this script doesn't stop when
error is thrown.)

^-;throw make error! "User Error!"

}
] 
error? [[datatype] [error!] {

Returns FALSE for all other values. This is useful
for determining if a TRY function returned an error.

^-if error? try [1 + "x"][
^-^-print "Did not work."
^-]

}
] 
even? [[math] [odd? zero?] {

Returns TRUE only if the argument is an even integer value.
If the argument is a decimal, only its integer portion is
examined.

^-print even? 100

^-print even? 7

}
] 
event? [[datatype] [] {

Returns true if the value is an event datatype.

}
] 
exclude [[sets series string] [difference intersect union unique] {

Returns the elements of the first set less the elements
of the second set. In other words, it removes from the
first set all elements that are part of the second set.

^-lunch: [ham cheese bread carrot]
^-dinner: [ham salad carrot rice]
^-probe exclude lunch dinner

^-probe exclude [1 3 2 4] [3 5 4 6]

^-string1: "CBAD"    ; A B C D scrambled
^-string2: "EDCF"    ; C D E F scrambled
^-probe exclude string1 string2

^-items: [1 1 2 3 2 4 5 1 2]
^-probe exclude items items  ; get unique set

^-str: "abcacbaabcca"
^-probe exclude str str

Note that performing this function over very large
data sets can be CPU intensive.

}
] 
exists-thru? [[file port] [info do-thru launch-thru load-thru path-thru read-thru] {

The /check refinement allows you to verify whether a file
has a different date, size, or checksum than the value
you pass in.

}
] 
exists? [[file] [read write delete modified? size?] {

Returns FALSE if the file does not exist.

^-print exists? %file.txt

^-print exists? %doc.r

}
] 
exit [[function] [return catch break] {

EXIT is used to return from a function without returning a value.

^-test-str: make function! [str] [
^-^-if not string? str [exit]
^-^-print str
^-]
^-test-str 10
^-test-str "right"

Note: Use QUIT to exit the interpreter.

}
] 
exp [[math] [log-10 log-2 log-e power] {

The EXP function returns the exponential value of the
argument provided.

^-print exp 3

On overflow, an error is returned (which can be trapped
with the TRY function). On underflow, a zero is returned.

}
] 
extract [[sets series string] [] {

Returns a series of values from regularly spaced positions within a
specified series. For example:

^-data: ["Dog" 10 "Cat" 15 "Fish" 20]
^-probe extract data 2

Essentially, extract lets you access a series as a record or "row"
of a given length (specified by the WIDTH argument). The default, as
shown above, extracts the first value. If you wanted to extract the
second value (the second "column" of data):

^-data: ["Dog" 10 "Cat" 15 "Fish" 20]
^-probe extract/index data 2 2

In the example below, the width of each row is three:

^-people: [
^-^-1 "Bob" "Smith"
^-^-2 "Cat" "Walker"
^-^-3 "Ted" "Jones"
^-]
^-block: extract people 3
^-probe block

^-block: extract/index people 3 2
^-probe block

Of course, extract works on any series, not just those that appear
in a row format (such as that above). The example below creates a
block containing every other word from a string:

^-str: "This is a given block here"
^-blk: parse str none
^-probe blk

^-probe extract blk 2

^-probe extract/index blk 2 2

Here is an example that uses EXTRACT to obtain the names of all
the predefined REBOL/View VID styles:

^-probe extract system/view/vid/vid-styles 2

}
] 
face [[view face] [view show hide center-face] {

The FACE object is defined by the standard object found in
system/standard/face. This master face is the parent face for all
other faces. Everything else is based on it, and when creating your
own faces, it is important to inherit from this face object due to
its relationship with the underlying REBOL implementation. Do not
use your own definition of face or your programs may not work
correctly.

Note that the face object used by VID is derived from this master
face. The VID face extends the object to provide additional fields
required by the VID system. However, you can create useful and
functional GUIs with the master face alone. You do not need the VID
object definition unless you are using the VID system.

Within applications, there are several ways to create the necessary
faces. For instance, you can use VID to create the face objects.
It's easy and quick to use.

Of course, as objects, you can create various prototypical faces
(classes) for different types of display objects or control objects
(input methods like fields, buttons, etc.) Then you can make new
object instances easily for each type of face.

New faces (and/or prototypes) can always be created directly from
the master face. The standard object creation method is used:

^-a-face: make face [
^-^-offset: 100x100
^-^-size: 200x100
^-^-color: red
^-^-effect: [gradient]
^-]

This creates a new face object called a-face. All fields are
inherited from the master face, except those new fields that are
specified.

To see what the face looks like, use the view function:

^-view a-face

Read http://www.rebol.com/docs/view-system.html for complete
details about faces.

}] 
false [[constant] [true yes no on off] {

Returns LOGIC value for not TRUE.

^-print false

^-print not true

^-print 1 > 2

}
] 
fifth [[series string] [pick first second third fourth] {

An error will occur if no value is found. Use the PICK
function to avoid this error.

^-print fifth "REBOL"

^-print fifth [11 22 33 44 55 66]

}
] 
file! [[datatype] [file? make type?] {

Represents the FILE datatype, both externally to the
user and internally within the system. A file is 
directly represented in REBOL as a percent symbol (%),
followed by a file name, or path. When supplied as an
argument to the MAKE function, it specifies the type of
value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of
that type when the function is evaluated.

^-probe make file! "image.jpg"

^-write %rebol-test-file.r "some file data"
^-show-contents: func [file [file!]] [
^-^-if exists? file [print read file]
^-]
^-show-contents %rebol-test-file.r

}
] 
file? [[datatype] [file! type?] {

Returns FALSE for all other values. Note that FILE?
does not check for the existence of a file, but 
whether or not a value is the FILE! datatype.

^-print file? %file.txt

^-print file? "REBOL"

}
] 
find [[series string] [select pick] {

Returns NONE if the value was not found. Otherwise, returns
a position in the series where the value was found.
Many refinements to this function are available. 

/CASE specifies that the search should be case sensitive.
Note that using find on a binary string will do a case-insensitive
search. You must add the /CASE refinement to make it case sensitive.

/TAIL indicates that the position just past the match
should be returned.

The /MATCH refinement can be used to perform a 
character by character match of the input value to 
the series. The position just past the match is returned.

Wildcards can be specified with /ANY and case sensitive
comparisons can be made with /CASE.

The /ONLY refinement applies to block values and
is ignored for strings.

The /LAST refinement causes FIND to search from
the TAIL of the series toward the HEAD.

/REVERSE searches backwards from the current position
toward the head.

^-probe find "here and now" "and"

^-probe find/tail "here and now" "and"

^-probe find [12:30 123 c@d.com] 123

^-probe find [1 2 3 4] 5

^-probe find/match "here and now" "here"

^-probe find/match "now and here" "here"

^-probe find [1 2 3 4 3 2 1] 2

^-probe find/last %file.fred.txt "."

^-probe find/last [1 2 3 4 3 2 1] 2

^-probe find/any "here is a string" "s?r"

}
] 
find-key-face [[view] [] {

This function is used internally. You shouldn't need to
call it directly unless you're writing advanced VID
applications where you want to control how access-keys
are handled.

}
] 
find-window [[view face] [in-window?] {

This function is used to find the window for any given face.
It may be used to obtain information about the window (such
as offset or size) or to force a refresh on the entire window.

^-view layout [
^-^-text "Move this window, then click one of these buttons"
^-^-b1: btn "Show window location" [
^-^-^-f: find-window b1
^-^-^-print f/offset
^-^-]
^-^-b2: btn "Center new window over this one" [
^-^-^-f: find-window b2
^-^-^-out: layout [text "Here"]
^-^-^-center-face/with out f
^-^-^-view/new out
^-^-] 
^-]

}] 
first [[series string] [pick second third fourth fifth] {

An error will occur if no value is found. Use the PICK
function to avoid this error.

^-print first "REBOL"

^-print first [11 22 33 44 55 66]

^-print first 1:30

^-print first 199.4.80.1

^-print first 12:34:56.78

}
] 
flag-face [[view face] [deflag-face flag-face?] {

VID faces have a /flags facet that can be used to store 
settings. You can use whatever values you want, but 
normally words are used. VID uses certain words for 
specific purposes. For example, the 'tabbed flag tells
VID whether a field is in the tab order of a layout.

To add a field from the tab order, e.g. if the field is
hidden because you only show it under certain circumstances. 
You can then show the field and the user can tab into it.

^-flag-face f-my-field 'tabbed
^-hide f-my-field

AS-IS^-Preserves text formatting. e.g. line-breaks.

CHECK^-Identifies a face as a check-box style.

DROP^-Indiciates a background/backdrop style.

FIELD^-Indicates face is used as a text entry field (used by CLEAR-FIELDS
function).

FIXED^-Identifies a face as having a fixed offset and size. Used for 
things like BACKDROP.

INPUT^-How does VID know what styles to recognize as values? There is 
a new flag in the /flags field: 'input.  So, if you want your own custom 
faces to be accepted, be sure to set that flag (or inherit it).

ON-UNFOCUS^-Causes the faces action to be evaluated if the face is
unfocused. This allows the face to process the newly entered data
to check it for any restrictions, such as numeric-only fields.

PANEL Sub-panels--other than windows--need to have the 'panel flag set to
indicate that the pane can be scanned for more input styles. This is
necessary because some styles may be using their /pane field for other
things.

RADIO^-Identifies a face as an option-button style. i.e. it may have related
faces that turn off when it turns on. Those other faces are identified
by matching the <w>of facet to the face that changed.

RETURN^-Causes the return (enter) key to evaluate the face's action.
This allows the face to process the newly entered data to check it
for any restrictions, such as numeric-only fields.

TABBED^-Means that a face should be in the list of faces that get focus when
the tab key is pressed; it's in the "tab order".

TOGGLE^-Identifies a face as a dual-state button.

TEXT^-The face is being used for text.

}
] 
flag-face? [[view face] [deflag-face flag-face] {

If the flag in question is set for the face specified, 
it returns the block of flags at the location where the flag
is found; otherwise it returns NONE. 

See FLAG-FACE for more details.

}
] 
flash [[view request] [alert request inform] {

Flash a message to the user. Similar to alert, but without a
button.  This function is normally used to inform the user of an
action as it is occuring.  The UNVIEW function can be used to
remove the flash.

^-flash "Reading site..."
^-data: read http://www.rebol.com
^-unview

The FLASH function returns the window face that is being displayed,
allowing functions such as UNVIEW to explicitly refer to the flash
window.

^-fl: flash "Loading..."
^-;...
^-unview/only fl

}
] 
focus [[view face] [unfocus] {

Specify that the face is to receive keyboard input.
Normally used with the FIELD and AREA styles.

Only one face can have the focus at a time. The focus can be
changed at an time by calling the FOCUS function with a new
face.  To remove the focus, call the UNFOCUS function.

^-out: layout [
^-^-h2 "Focus example:"
^-^-f1: field "field 1"
^-^-f2: field "field 2"
^-^-button "Focus 2" [focus f2]
^-^-button "Focus 1" [focus f1]
^-^-button "Unfocus" [unfocus]
^-^-button "Close" [unview]
^-]
^-focus f1
^-view out

Focus is set automatically when a user clicks on a text face.

}
] 
for [[control] [forall foreach forever forskip] {

The first argument is used as a local variable to keep
track of the current value. It is initially set to the
START value and after each evaluation of the block the
BUMP value is added to it until the END value is reached
(inclusive).

^-for num 0 30 10 [ print num ]

^-for num 4 -37 -15 [ print num ]

}
] 
forall [[control series string] [for foreach forskip] {

The FORALL function moves through a series one value
at a time.

The WORD argument is a variable that moves through the series.
Prior to evaluation, the WORD argument must be set to the
desired starting position within the series (normally the head,
but any position is valid). After each evaluation of the block,
the word will be advanced to the next position within the
series.

^-cities: ["Eureka" "Ukiah" "Santa Rosa" "Mendocino"]
^-forall cities [print first cities]

^-chars: "abcdef"
^-forall chars [print first chars]

Important: The WORD argument is modified as a result of
running this function. The WORD is set to the tail of
the series in most cases.  You can reset it to the 
head of the series with a HEAD function.

For example:

^-chars: "abcdef"
^-forall chars [print first chars]
^-probe chars

Now, reset the chars word to the head of the string:

^-chars: head chars
^-probe chars

The FORALL function can be thought of as a shortcut for:

^-[
^-^-while [not tail? series] [
^-^-^-(your code)
^-^-^-series: next series
^-^-]
^-]
}
] 
foreach [[control series string] [for forall forskip] {

For every value in a series, such as a block or string, this
function will evaluate a block using a variable that holds that
value.

For example, the series below is a block of city names. For each
name in that block, the PRINT function will be evaluated. The
CITY variable holds the name of the city each time.

^-cities: ["Eureka" "Ukiah" "Santa Rosa" "Mendocino"]
^-foreach city cities [print city]

This also works for strings. Each character of the string will
be printed below:

^-chars: "abcdef"
^-foreach char chars [print char]

The second argument can also be a block of words to get multiple
values at the same time from the block:

^-months: ["March" 31 "April" 30 "May" 31 "June" 30]
^-foreach [name days] months [print [name "has" days "days"]]

}
] 
forever [[control] [loop while until] {

Evaluates a block continuously, or until a break or 
error condition is met.

^-forever [
^-^-if (random 10) > 5 [break]
^-]

}
] 
form [[series string] [mold reform remold join] {

FORM creates the user-friendly format of the value, its
standard PRINT format, not its molded (or source)
format. When given a block of values, spaces are
inserted between each values (except after a newline).
To avoid the spaces between values use INSERT or JOIN.
Note that FORM does not evaluate the values within a
block. To do so, either use REFORM or perform a REDUCE
prior to the FORM.

^-print form 10:30

^-print form %image.jpg

^-print form [123 "-string-" now]

^-print reform [123 "-string-" now]

}
] 
forskip [[control series string] [for forall foreach skip] {

Prior to evaluation, the word must be set to the desired
starting position within the series (normally the head,
but any position is valid). After each evaluation of the
block, the word's position in the series is changed by
skipping the number of values specified by the second
argument (see the SKIP function).

^-areacodes: [
^-^-"Ukiah"         707
^-^-"San Francisco" 415
^-^-"Sacramento"    916
^-]
^-forskip areacodes 2 [
^-^-print [ first areacodes "area code is" second areacodes]
^-]

}
] 
found? [[series string logic] [find pick] {

Returns FALSE for all other values. Not usually required
because most conditional function will accept a NONE as
FALSE and all other values as TRUE.

^-if found? find luke@rebol.com ".com" [print "found it"]

}
] 
fourth [[series string] [first second third fifth pick] {

An error will occur if no value is found. Use the PICK
function to avoid this error.

^-print fourth "REBOL"

^-print fourth [11 22 33 44 55 66]

^-print fourth 199.4.80.1

}
] 
free [[series] [] {

FREE does nothing for most datatypes, which are automatically
freed when they are no longer used by your program.

Refer to the REBOL/Command manual for more information about the
use of the FREE function for special Library interfaces.

}
] 
func [[function] [does has function use make function! function? return exit] {

The spec is a block that specifies the interface to
the function. It can begin with an optional string
which will be printed when asking for HELP on the
function. That is followed by the words that specify
the arguments to the function. Each of these words
may include an optional block of datatypes. These
specify the valid datatypes for the argument.
That may be followed by a comment string which describes
the argument in more detail.

The argument words may also specify a few variations
on the way the argument will be evaluated. The most
common is 'word which indicates that a word is
expected that should not be evaluated (the function
wants its name, not its value). A :word may also
be given which will get the value of the argument,
but not perform full evaluation.

To add refinements to a function supply a slash (/) in
front of an argument's word. Within the function the
refinement can be tested to determine if the 
refinement was present. If a refinement is followed
by more arguments, they will be associated with
that refinement and are only evaluated when the
refinement is present.

Local variables are specified after a /LOCAL refinement.

A function returns the last expression it evaluated.
You can also use RETURN and EXIT to exit the function.
A RETURN is given a value to return. EXIT returns no value.

^-sum: func [a b] [a + b]
^-print sum 123 321

^-sum: func [nums [block!] /average /local total] [
^-^-total: 0
^-^-foreach num nums [total: total + num]
^-^-either average [total / (length? nums)][total]
^-]
^-print sum [123 321 456 800]
^-print sum/average [123 321 456 800]

^-print-word: func ['word] [print form word]
^-print-word testing

}
] 
function [[function] [func does has make use function! function? return exit] {

FUNCTION is identical to FUNC but includes a block in
which you can name words considered LOCAL to the
function.

^-average: function [block] [total] [
^-^-total: 0
^-^-foreach number block [total: number + total]
^-^-total / (length? block)
^-]
^-print average [1 10 12.34]

}
] 
function! [[datatype function] [function? make type?] {

Represents the FUNCTION datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated. Setting a
function to a word is optional. The REBOL language also
allows unnamed functions.

^-test: make function! [str] [print str]
^-test "simple"

^-funct: make function! [args body][make function! args body]

^-print do (make function! [n] [n * 123]) 10

}
] 
function? [[datatype function] [any-function? function! type?] {

Returns FALSE for all other values.

^-print function? :func

^-print function? "test"

}
] 
get [[context] [set value? in] {

The argument to GET must be a word, so the argument must
be quoted or extracted from a block. To get the value
of a word residing in an object, use the IN function.

^-value: 123
^-print get 'value

^-print get second [the value here]

^-print get in system/console 'prompt

}
] 
get-env [[internal] [] {

^-probe get-env "path"

^-probe get-env "temp"

}
] 
get-face [[view face] [clear-face reset-face set-face] {

This face accessor function makes it easy to get the current
value of a face, so you don't have to remember what facet 
(property) each style uses to store its data. It also allows 
you to write generic loops that collect values from multiple faces.

^-view layout [
^-^-h2 "Enter your name below:"
^-^-f-name: field
^-^-across
^-^-btn "Show" [print get-face f-name]
^-]

}
] 
get-modes [[port file] [set-modes open read write] {

This function returns a block of special modes for file and
network ports. GET-MODES takes a port and a block of modes that
are being requested.  It returns a block of mode names and their
values (which can in turn be passed back to SET-MODES).

^-port: open/binary %test-file
^-probe get-modes port [direct binary]

The example above shows that the port is opened for binary
access but not for direct access.

A shortcut to query a single mode is to specify a single mode
word as the argument:

^-probe get-modes port 'binary

In this case GET-MODES only returns the value directly, rather
than a block.

Another form of GET-MODES takes a name-value block that is of
the same format as SET-MODES.

^-probe get-modes port [direct: none binary: none]

Here the values specified are ignored.

GET-MODES supports a few special modes which return a list of
applicable modes for a port. They are: file-modes, copy-modes,
network-modes, and port-modes. If any of these modes are
specified in a GET-MODES request then the response contains a
block of matching modes which are available on the current
operating system (and it may vary between systems).

^-probe get-modes port 'file-modes

You can actually use the returned value to get the values of
all available modes:

^-modes: get-modes port 'file-modes
^-probe get-modes port modes

Be sure to close the port when you have completed your queries
and changes:

^-close port

The complete list of all modes includes (note that not all
modes are supported by all operating systems. See REBOL 2.5
addendum for more information):

^-file-modes: [
^-^-status-change-date
^-^-modification-date
^-^-access-date
^-^-backup-date
^-^-creation-date
^-^-owner-name
^-^-group-name
^-^-owner-id
^-^-group-id
^-^-owner-read
^-^-owner-write
^-^-owner-delete
^-^-owner-execute
^-^-group-read
^-^-group-write
^-^-group-delete
^-^-group-execute
^-^-world-read
^-^-world-write
^-^-world-delete
^-^-world-execute
^-^-comment
^-^-script
^-^-archived
^-^-system
^-^-hidden
^-^-hold
^-^-pure
^-^-type
^-^-creator
^-]

^-Port-modes: [
^-^-read
^-^-write
^-^-binary
^-^-lines
^-^-no-wait
^-^-direct
^-]

^-Network-modes: [
^-^-broadcast
^-^-multicast-groups
^-^-type-of-service
^-^-keep-alive
^-^-receive-buffer-size
^-^-send-buffer-size
^-^-multicast-interface
^-^-multicast-ttl
^-^-multicast-loopback
^-^-no-delay
^-^-interfaces
^-]

For example, to obtain a list of network interfaces for your
computer system:

^-port: open tcp://:10000
^-probe get-modes port 'interfaces
^-close port

See the REBOL/Core Addendum for a complete description of
GET-MODES and SET-MODES.

}
] 
get-net-info [[internal] [] {

Internal REBOL word.

}] 
get-style [[view] [stylize] {

If you want to see how a particular style is defined, so you
can modify it, or just to see how it works, this is the 
function to use. It will return all the source code for the 
style. 

^-probe get-style 'button

It's also handy for extracting styles and saving them for 
later use and customization, but be aware that standard 
VID styles are built from many common pieces (e.g. VID-feel).
If you plan to do a lot of custom style development, the
SDK sources can be much more instructive than just using
get-style.

If you don't use the /styles refinement, the style definition
will be pulled from the master style sheet.

}
] 
get-word! [[datatype] [get-word? word! set-word! lit-word!] {

Represents the GET-WORD datatype, both externally to
the user and internally within the system. When
supplied as an argument to the MAKE function, it
specifies the type of value to be created. When
provided within the function's argument specification,
it requests the interpreter to verify that the argument
value is of the specified type when the function is
evaluated.

^-probe make get-word! "test"

}
] 
get-word? [[datatype] [get-word! word? set-word? lit-word?] {

Returns FALSE for all other values.

^-print get-word? second [pr: :print]

}
] 
greater-or-equal? [[comparison] [>= < <= > = <> min max] {

Returns FALSE for all other values. The values must be
of the same datatype or an error will occur. For
string-based datatypes, the sorting order is used for
comparison with character casing ignored (uppercase =
lowercase).

^-print greater-or-equal? "abc" "abb"

^-print greater-or-equal? 16-June-1999 12-june-1999

^-print greater-or-equal? 1.2.3.4 4.3.2.1

^-print greater-or-equal? 1:00 11:00

}
] 
greater? [[comparison] [> < <= >= = <> min max] {

Returns FALSE for all other values. The values must be
of the same datatype or an error will occur. For
string-based datatypes, the sorting order is used for
comparison with character casing ignored (uppercase =
lowercase).

^-print greater? "abc" "abb"

^-print greater? 16-June-1999 12-june-1999

^-print greater? 4.3.2.1 1.2.3.4

^-print greater? 11:00 12:00

}
] 
halt [[control] [quit break exit catch] {

Useful for program debugging.

^-div: 10
^-if error? try [100 / div] [
^-^-print "math error"
^-^-halt
^-]

}
] 
has [[function] [func function does exit return use] {

Defines a function that consists of local variables only.
This is a shortcut for FUNC and FUNCTION.

For example:

^-ask-name: has [name] [
^-^-name: ask "What is your name?"
^-^-print ["Hello" name]
^-]

^-ask-name

The example above is a shortcut for:

^-ask-name: func [/local name] [...]

}
] 
hash! [[datatype] [hash? block! list!] {

Represents the HASH datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
specification of the argument of a function, it requests
the interpreter to check that the argument value is of
the specified type when the function is evaluated. FIND
performs faster with HASH! than with a BLOCK!.

^-blk: ["Doug" "Mary" "Kas" "Jodi" "Patrick" "Polly" "Eli"]
^-hash: make hash! blk
^-find hash "Polly"

}
] 
hash? [[datatype] [hash! block? list?] {

Returns FALSE for all other values.

^-test-hash: make hash! [1 2 3 4]
^-if hash? test-hash [print "It's a hash."]

}
] 
head [[series string] [head? tail tail?] {

^-str: "all things"
^-print head insert str "with "

^-here: find str "all"
^-print here

^-print head here

}
] 
head? [[series string] [head tail tail?] {

^-cds: [
^-^-"Rockin' REBOLs"
^-^-"Carl's Addiction"
^-^-"Jumpin' Jim"
^-]
^-print head? cds

^-cds: tail cds
^-print head? cds

^-until [
^-^-cds: back cds
^-^-print first cds
^-^-head? cds
^-]

}
] 
help [[help] [? what ??] {

The HELP function provides a simple way to get information about
words and values.  To use HELP, supply a word or a value as its
argument:

^-help quit

Other examples:

^-help now

^-help insert

You can also use HELP to find all the words that match
a substring. To do so, provide a string in
quotes:

^-help "path"

^-help "to-"

You can view all words that are of a specific datatype by
specifying the datatype. The example:

^-help tuple!

would list all tuple functions. Other examples: type "help function!"
to list all REBOL defined functions, or even:

^-help datatype!
}
] 
hide [[view face] [show] {

HIDE temporarily removes the face from view. It does not remove
the face from its parent face's pane. The face will become
visible again the next time the face is shown either directly or
indirectly through one of its parent faces.

The example below creates a window with text and buttons. When
clicked, the first two buttons will hide and show the third
button.

^-out: layout [
^-^-vh2 "Hide Button"
^-^-body "Hide the extra button."
^-^-button "Hide It" [hide bt]
^-^-button "Show It" [show bt]
^-^-bt: button "Extra Button"
^-]
^-view out

Multiple faces can be provided to HIDE as a block. The block
normally contains face object references, but it will also
accept the names of variables that hold faces.

To permanently remove a face from view, remove it from its
parent face pane. The BT button above could be permanently
removed with:

^-remove find out/pane bt
^-show out

The button could be put back with:

^-append out/pane bt
^-show out

In both cases, the SHOW is used to refresh the view, showing
the change.

For top level faces (windows), HIDE is used by UNVIEW to close
the window. In addition, UNVIEW removes the top level face from
the screen-face pane.

}
] 
hide-popup [[view request face] [show-popup show inform] {

This function is used to hide a popup window that was created
with the INFORM or SHOW-POPUP functions.  It will hide the most
recent popup that has occurred.

^-inform layout [
^-^-text bold red "Warning..."
^-^-button "OK" [hide-popup]
^-]

The above example will display a popup message until the OK
button is pressed and the HIDE-POPUP function is evaluated.

}
] hilight-all [[view face] [hilight-text unlight-text] {

Selects all the text in the specified face.

}
] 
hilight-text [[view face] [hilight-all unlight-text] {

Selects the specified region of text in the given face.

This is really a low-level function, meant for use internally
by View and VID. If you decide you use it, you may need to do
a bit of work to get the exact behavior you want, e.g. to
control where the caret appears, etc.

^-view layout [
^-^-f: field "Testing" 
^-^-button [
^-^-^-focus f 
^-^-^-hilight-text f at f/text 3 at f/text 6 
^-^-^-show f
^-^-]
^-]

}
] 
hsv-to-rgb [[view] [] {

This conversion is useful if you need the RGB value from the the
brightness (v), color saturation (s), and the hue (h).

The conversion is done in native code in order to get the highest
performance.

}] 
if [[control] [either switch select] {

Skip the block if the value is FALSE. To select an
alternate result (else) use the EITHER function. IF
returns the value of the block it evaluated or NONE
otherwise.

^-age: 4
^-if age > 3 [print "wine is ready"]

^-print if age > 2 ["ready"]

^-print if age < 2 ["not ready"]

A common error is to add a block without specifying /else or
without using the EITHER function. The extra block gets ignored.

}
] 
image? [[datatype] [image! to-image] {

Returns TRUE if the value is an IMAGE datatype.

This function is often used after the LOAD function to verify
that the data is in fact an image. For example:

^-img: load %test-image.png
^-if not image? img [alert "Not an image file!"]

}
] 
import-email [[string] [] {

Constructs an easily referenced object from an email
message inherited by system/standard/email. The object's 
elements are defined by the email's header field names 
and are assigned the value of the corresponding fields.

^-message: trim {
^-^-To: John Doe <johndoe@nowhere.dom>
^-^-From: Jane Doe <janedoe@nowhere.dom>
^-^-Subject: Check Out REBOL!
^-}
^-email: import-email message
^-print email/to

}
] 
in [[context] [set get] {

Return the word from within another context. This function is
normally used with SET and GET.

^-set-console: func ['word value] [
^-^-set in system/console word value
^-]
^-set-console prompt "==>"
^-set-console result "-->"

This is a useful function for accessing the words and values of
an object.  The IN function will obtain a word from an object's
context.  For example, if you create an object:

^-example: make object! [ name: "fred" age: 24 ]

You can access the object's name and age fields with:

^-print example/name
^-print example/age

But you can also access them with:

^-print get in example 'name
^-print get in example 'age

The IN function returns the NAME and AGE words as they are
within the example object. If you type:

^-print in example 'name

The result will be the word NAME, but with a value as it exists
in the example object. The GET function then fetches their
values.  This is the best way to obtain a value from an object,
regardless of its datatype (such as in the case of a function).

A SET can also be used:

^-print set in example 'name "Bob"

Using IN, here is a way to print the values of all the fields of
an object:

^-foreach word next first example [
^-^-probe get in example word
^-]

The FIRST of the object returns the list of words within the
object. The NEXT skips the first word, which is SELF, the object
itself.

Here is another example that sets all the values of an object to
NONE:

^-foreach word next first example [
^-^-set in example word none
^-]

The IN function can also be used to quickly check for the
existence of a word within an object:

^-if in example 'name [print example/name]

^-if in example 'address [print example/address]

This is useful for objects that have optional variables.


}
] 
in-window? [[view face] [] {

Search all the subfaces of a face to determine if the
specified face is within the window.

}
] 
index? [[series string] [length? offset? head head? tail tail? pick skip] {

The index function returns the position within a series. For
example, the first value in a series is an index of one, the
second is an index of two, etc.

^-str: "with all things considered"
^-print index? str

^-print index? find str "things"

^-blk: [264 "Rebol Dr." "Calpella" CA 95418]
^-print index? find blk 95418

Use the OFFSET? function when you need the index difference
between two positions in a series.

}
] 
info? [[file] [exists? dir? modified? size?] {

The information is returned within an object that has
SIZE, DATE, and TYPE words. These can be accessed in
the same manner as other objects.

^-info: info? %file.txt
^-print info/size

^-print info/date

}
] 
inform [[view request] [show-popup hide-popup show layout] {

Display a window as a modal dialog. The inform function does
not return until the user has finished with the dialog.

}
] 
input [[port] [input? ask confirm] {

Returns a string from the standard input device
(normally the keyboard, but can also be a file or an
interactive shell). The string does not include
the new-line character used to terminate it.

The /HIDE refinement hides input with "*" characters.

^-prin "Enter a name: "
^-name: input
^-print [name "is" length? name "characters long"]

}
] 
input? [[port] [input] {

INPUT? can be used to determine if input is waiting to
be read from the standard input device. When it returns
TRUE, input is waiting to be read (with INPUT).

^-print input?

^-if input? [name: input]

}
] 
insert [[series string modify] [append change clear remove join] {

If the value is a series compatible with the first
(block or string-based datatype), then all of its values
will be inserted. The series position just past the
insert is returned, allowing multiple inserts to be
cascaded together.

This function includes many refinements.

/PART allows you to specify how many elements you want
to insert.

/ONLY will force a block to be insert, rather than its
individual elements. (Is only done if first argument
is a block datatype.)

/DUP will cause the inserted series to be repeated a
given number of times.

The series will be modified.

^-str: copy "here this"
^-insert str "now "
^-print str

^-insert tail str " message"
^-print str

^-insert tail str reduce [tab now]
^-print str

^-insert insert str "Tom, " "Tina, "
^-print str

^-insert/dup str "." 7
^-print str

^-insert/part tail str next "!?$" 1
^-print str

^-blk: copy ["hello"]
^-insert blk 'print
^-probe blk

^-insert tail blk http://www.rebol.com
^-probe blk

^-insert/only blk [separate block]
^-probe blk

}
] 
insert-event-func [[view port] [remove-event-func wait] {

Installs a global event handler for the View graphics system. This
function makes it easier for applications to cooperate on the
handling of global events.

You can install as many handler functions as you want this way, and
they will remain active while the REBOL session is running. If you
need to remove one - for example, to insert an updated version of it
while the program is running - you can use REMOVE-EVENT-FUNC.

The argument you provide can be either a function! or a block!. 

So you can insert an event handler like this:

^-insert-event-func func [face event] [... event]

or:

^-my-handler: func [face event] [... event]
^-insert-event-func :my-handler

Or, if you provide a block, it is used as the body of a function that
takes face and event args:

^-insert-event-func [print event/type ... event]

If you want the system to continue to process an event, then your
event handling function must return the event as its result. If your
code has handled the event, and no other processing is required,
your function should return NONE.

A common idiom is to use the SWITCH function to handle different
event types in a handler function. You can handle as many event
types as you want this way and easily ignore events you don't need.

^-insert-event-func [
^-^-switch event/type [
^-^-^-key         [handle-hot-keys event/key]
^-^-^-time        [show-current-time]
^-^-^-close       [cleanup]
^-^-^-offset      [save-window-pos]
^-^-^-resize      [save-window-pos]
^-^-^-scroll-line [scroll-lines event/offset/y]
^-^-^-scroll-page [scroll-pages event/offset/y]
^-^-]
^-^-event
^-]
}] 
inside? [[view comparison] [outside? overlap?] {

^-probe inside? 100x100 50x50
^-
^-probe inside? 100x100 150x150
^-
}
] 
install [[system] [uninstall] {

Restarts the install process for REBOL/View. This can be used
to modify the installation settings.

}
] 
integer! [[datatype] [integer? make type?] {

Represents the INTEGER datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-print make integer! "12345"

^-print make integer! 123.45

}
] 
integer? [[datatype] [integer! type?] {

Returns FALSE for all other values.

^-print integer? -1234

^-print integer? "string"

}
] 
intersect [[sets series string] [difference union exclude unique] {

Returns all elements within two blocks or series that 
exist in both.

^-lunch: [ham cheese bread carrot]
^-dinner: [ham salad carrot rice]
^-probe intersect lunch dinner

^-probe intersect [1 3 2 4] [3 5 4 6]

^-string1: "CBAD"    ; A B C D scrambled
^-string2: "EDCF"    ; C D E F scrambled
^-probe intersect string1 string2

^-items: [1 1 2 3 2 4 5 1 2]
^-probe intersect items items  ; get unique set

^-str: "abcacbaabcca"
^-probe intersect str str

To obtain a unique set (to remove duplicate values)
you can use UNIQUE.

Note that performing this function over very large
data sets can be CPU intensive.

}
] 
issue! [[datatype] [issue? make type?] {

Represents the ISSUE datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-print make issue! "1234-56-7890"

}
] 
issue? [[datatype] [issue! type?] {

Returns FALSE for all other values.

^-print issue? #1234-5678-9012

^-print issue? #467-8000

^-print issue? $12.56

}
] 
join [[series string] [rejoin form reform mold remold insert] {

Creates a new value as the return. The first argument 
determines the datatype of the returned value. When the 
first argument is a type of series, the return value will 
be that type of series (STRING, FILE, URL, BLOCK, etc.). 
When the first argument is a scalar value, the return 
will always be a string. When the second argument is a 
block, it will be evaluated and all of its values joined 
to the return value.

^-probe join "super" "duper"

^-probe join %file ".txt"

^-probe join http:// ["www.rebol.com/" %index.html]

^-probe join "t" ["e" "s" "t"]

^-probe join 11:11 "PM"

^-probe join [1] ["two" 3 "four"]

}
] 
last [[series string] [] {

LAST returns the last value of a series. If the series is empty,
LAST will cause an error.

^-print last "abcde"

^-print last [1 2 3 4 5]

^-print last %file

^-probe last 'system/options

If you do not want an error when the series is empty, use the 
PICK function instead:

^-string: ""
^-print pick back tail string 1

}
] 
launch [[control] [] {

The LAUNCH function is used to run REBOL scripts as a separate
process. When LAUNCH is called, a new process is created and
passed the script file name or URL to be processed. The process
is created as a subprocess of the main REBOL process.

Launch has certain restrictions depending on the REBOL system
used. Also, within Unix/Linux systems, launch will use the
same shell standard files as the main REBOL process, and output
will be merged.

^-launch %calculator.r

^-launch http://www.rebol.com/scripts/news.r

}
] 
launch-thru [[file port] [info launch do-thru exists-thru? load-thru path-thru read-thru] {

The /check refinement allows you to verify whether a file
has a different date, size, or checksum than the value
you pass in.

}
] 
layout [[view face] [view stylize show-popup unview] {

The LAYOUT function takes a layout block as an argument and
returns a layout face as a result. The block describes the
layout according to the rules of the Visual Interface Dialect.
The block is evaluated and a face is returned. 

The result of LAYOUT is can be passed directly to the VIEW
function, but it can also be set to a variable or returned as
the result of a function. The line: 

^-block: [
^-^-h2 "This is a Window"
^-^-button "Close" [unview]
^-]
^-view layout block

can also be written as: 

^-window: layout block
^-view window

The result of the layout function is a face and can be used in
other layouts.

}
] 
length? [[series string] [head] {

The length is the number of values from the current
position to the tail. If the current position is the
head, then the length will be that of the entire series.

^-print length? "REBOL"

^-print length? [1 2 3 4 5]

^-print length? [1 2 3 [4 5]]

}
] 
lesser-or-equal? [[comparison] [<= < > >= = <> min max] {

Returns FALSE for all other values. For string-based
datatypes, the sorting order is used for comparison
with character casing ignored (uppercase = lowercase).

^-print lesser-or-equal? "abc" "abd"

^-print lesser-or-equal? 10-June-1999 12-june-1999

^-print lesser-or-equal? 4.3.2.1 1.2.3.4

^-print lesser-or-equal? 1:23 10:00

}
] 
lesser? [[comparison] [<= > >= = <> min max] {

Returns FALSE for all other values. The values must be
of the same datatype, or an error will occur. For
string-based datatypes, the sorting order is used for
comparison with character casing ignored (uppercase =
lowercase).

^-print lesser? "abc" "abcd"

^-print lesser? 12-june-1999 10-june-1999

^-print lesser? 1.2.3.4 4.3.2.1

^-print lesser? 1:30 2:00

}
] 
library? [[datatype] [] {

Returns TRUE if the value is a LIBRARY datatype.

}
] 
license [[help] [about] {

Returns the REBOL end user license agreement for the currently
running version of REBOL.

^-license

For SDK and other specially licensed versions of REBOL, the
license function may return an empty string.

}
] 
link-app? [[internal] [] {

Returns 'launcher or NONE.

If you write scripts that run under multiple REBOL products, this can
be very handy. For example, if running under Link, you may store files
in different locations, or make calls to the IOS API to sync files.

}
] 
link-relative-path [[internal] [] {

Internal REBOL word.

}] 
link? [[view system] [view?] {

Returns TRUE if you are running an IOS client enabled version
of REBOL.

^-print link?

Note that this function may not be available in older versions
of  REBOL. To define a similar value add this to your code:

^-link?: value? 'send-server

}
] 
list! [[datatype] [list?] {

Represents the LIST datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated. APPEND,
INSERT, and REMOVE perform faster with LIST! than with
BLOCK!.

^-blk: ["Carla" "Brian" "Karen" "Adam" "Jeremy"]
^-list: make list! blk
^-probe list

^-remove list
^-probe list

^-append list "Susan"
^-probe list

}
] 
list-dir [[file] [change-dir make-dir what-dir read] {

Lists the files and directories of the specified path in a
sorted multi-column output. If no path is specified, the
directory specified in system/script/path is listed. Directory
names are followed by a slash (/) in the output listing.

^-list-dir

To obtain a block of files for use by your program, use the LOAD
function. The example below returns a block that contains the names of all
files and directories in the local directory.

^-files: load %./
^-print length? files
^-probe files

}
] 
list? [[datatype] [list!] {

Returns FALSE for all other values.

^-test-list: make list! [1 2 3 4]
^-if list? test-list [print "It's a list."]

}
] 
lit-path! [[datatype] [path! set-path! path?] {

Represents the LIT-PATH datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-probe make lit-path! [a b c]

}
] 
lit-path? [[datatype] [] {

Returns true if the value is a literal path datatype.

}
] 
lit-word! [[datatype] [word! set-word! get-word!] {

Represents the LIT-WORD datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-probe make lit-word! "test"

}
] 
lit-word? [[datatype] [word! set-word? get-word!] {

Returns FALSE for all other values.

^-probe lit-word? first ['foo bar]

}
] 
load [[port file series string] [save read do] {

Reads and converts external data, including programs, data
structures, images, and sounds into memory storage objects that
can be directly accessed and manipulated by programs.

The argument to LOAD can be a file, URL, string, or binary
value. When a file name or URL is provided, the data is read
from disk or network first, then it is loaded. In the case of a
string or binary value, it is loaded directly from memory.

Here are a few examples of using LOAD:

^-script: load %dict-notes.r
^-image: load %image.png
^-sound: load %whoosh.wav

^-;data: load http://www.rebol.com/example.r
^-;data: load ftp://ftp.rebol.com/example.r

^-data: load "1 2 luke fred@example.com"
^-code: load {loop 10 [print "hello"]}

LOAD is often called for a text file that contains REBOL code or
data that needs to be brought into memory. The text is first
searched for a REBOL header, and if a header is found, it os
evaluated first. (However, unlike the DO function, LOAD does not
require that there be a header.)

If the load results in a single value, it will be returned. If
it results in a block, the block will be returned. No evaluation
of the block will be done; however, words in the block will be
bound to the global context.

If the header object is desired, use the /HEADER option to
return it as the first element in the block.

The /ALL refinement is used to load an entire script as a block.
The header is not evaluated.

The /NEXT refinement returns a block consisting of two
elements. The first element is the first value 
loaded in the series. The second element is the original 
series with the current index just past the 
loaded value.

^-data: load "11 22 33 44"
^-print third data

^-set [value data] load/next data
^-print value

^-print data

}
] 
load-image [[view] [] {

When an image is used multiple times, this function allows you
to load a single copy into memory and reuse it.  Depending on
your application, this can save considerable memory.

}
] 
load-stock [[internal] [] {

Internal REBOL function.

}] 
load-stock-block [[internal] [] {

Internal REBOL word.

}] 
load-thru [[control file port] [do exists-thru? launch-thru load-thru path-thru read-thru] {

Load a file by first reading it from a URL (such as a website)
and storing it locally in a cache file. The next time you load
the same URL file, it will be read from the cache file, rather than
from the network.

}
] 
local [[function] [func] {

A special function refinement used to define local arguments
within FUNC.

^-test: func [block /local sum] [
^-^-sum: 0
^-^-foreach val block [
^-^-^-if number? val [sum: sum + num]
^-^-]
^-^-sum
^-]

Note that the /local refinement is used in this way by convention.
Internally to REBOL it is no different than any other function
refinement.

}] 
local-request-file [[internal] [] {

Internal REBOL word.

}] 
log-10 [[math] [exp log-2 log-e power] {

The LOG-10 function returns the base-10 logarithm of the number
provided. The argument must be a positive value, otherwise an
error will occur (which can be trapped with the TRY function).

^-print log-10 100

^-print log-10 1000

^-print log-10 1234

}
] 
log-2 [[math] [exp log-10 log-e power] {

The LOG-10 function returns the base-2 logarithm of the number
provided. The argument must be a positive value, otherwise an
error will occur (which can be trapped with the TRY function).

^-print log-2 2

^-print log-2 4

^-print log-2 256

^-print log-2 1234

}
] 
log-e [[math] [exp log-10 log-2 power] {

The LOG-E function returns the natural logarithm of the number
provided. The argument must be a positive value, otherwise an
error will occur (which can be trapped with the TRY function).

^-print log-e 1234

^-print exp log-e 1234

}
] 
logic! [[datatype] [logic? make type?] {

Represents the LOGIC datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-print make logic! 1

^-print make logic! 0

}
] 
logic? [[datatype] [logic! type?] {

Returns FALSE for all other values. Note that all
conditional functions will accept more than just a LOGIC
value. A NONE will act as FALSE, and all other values
other than logic will act as TRUE.

^-print logic? true

^-print logic? 123

}
] 
loop [[control] [break repeat for while until] {

Repeatedly executes a block for the given number of times. When
finished, the LOOP function returns the value of the final
execution of the block.

^-loop 40 [prin "*"]
^-print ""

The BREAK function can be used to stop the loop at any time (but
no value is returned).

The REPEAT function is similar to LOOP, except that it keeps
track of the current loop count with a variable.

The LOOP function is very efficient, and should be used if no
loop counter is required.

}
] 
lowercase [[string modify] [uppercase trim] {

The series passed to this function is modified as
a result.

^-print lowercase "ABCDEF"

^-print lowercase/part "ABCDEF" 3

}
] 
make [[datatype] [copy type?] {

The TYPE argument indicates the datatype to create.

The form of the constructor is determined by the
datatype. For most series datatypes, a number indicates
the size of the initial allocation.

^-str: make string! 1000

^-blk: make block! 10

^-cash: make money! 1234.56
^-print cash

^-time: make time! [10 30 40]
^-print time

NOTE: MAKE when used with OBJECTS will modify the context of the
spec block (as if BIND was used on it). If you need to reuse the
spec block use MAKE in combination with COPY/deep like this:

^-make object! copy/deep spec

}
] 
make-dir [[file] [change-dir what-dir list-dir delete] {

Creates a new directory at the specified location. This
operation can be performed for files or FTP URLs.

^-make-dir %New-Dir/
^-delete %New-Dir/

}
] 
make-face [[view face] [make layout view] {

Make a face based on a face style.  The LAYOUT function is
not required.

^-img: make-face 'image

}
] 
max [[math series string] [min maximum-of < > maximum] {

Returns the maximum of two values.

^-print max 0 100

^-print max 0 -100

^-print max 4.56 4.2

The maximum value is computed by comparison, so MAX can also be
used for non-numeric datatypes as well.

^-print max 1.2.3 1.2.8

^-print max "abc" "abd"

^-print max 12:00 11:00

^-print max 1-Jan-1920 20-Feb-1952

Using MAX on xy pairs will return the maximum of each X and Y
coordinate separately.

^-print max 100x10 200x20

}
] 
maximum [[math] [max < > min] {

See the MAX function for details.

}
] 
maximum-of [[math series string comparison] [min max] {

Return the series at the position of its maximum value.

^-probe maximum-of [34 6 60 59 5]

^-probe maximum-of ["abc" "def" "xyz" "aaa" "efg"]

}
] 
min [[math series string] [max < > minimum-of maximum-of] {

Returns the minimum of two values.

^-print min 0 100

^-print min 0 -100

^-print min 4.56 4.2

The minimum value is computed by comparison, so MIN can also be
used for non-numeric datatypes as well.

^-print min 1.2.3 1.2.8

^-print min "abc" "abd"

^-print min 12:00 11:00

^-print min 1-Jan-1920 20-Feb-1952

Using min on xy pairs will return the minimum of each X and Y
coordinate separately.

^-print min 100x10 200x20

}
] 
minimum [[math] [< > min max] {

See the MIN function for details.

}
] 
minimum-of [[math series string comparison] [min max] {

Return the series at the position of its minimum value.

^-probe minimum-of [34 20 4 6 60]

^-probe minimum-of ["abc" "def" "xy" "aaaxy" "efg"]

}
] 
mod [[math] [modulo // remainder round] {

Similar to REMAINDER, but the result is always non-negative.

}
] 
modified? [[file] [exists?] {

Returns NONE if the file does not exist.

^-print modified? %file.txt

}
] 
modulo [[math] [mod // remainder round] {

See MOD for details.

}
] 
mold [[series string] [form remold join insert reduce] {

MOLD differs from FORM in that MOLD produces a REBOL
readable string. For example, a block will contain
brackets [ ] and strings will be " " quoted or use
braces { } (if it is long or contains special characters).

When given a block of values, spaces are inserted
between each values (except after a newline). To avoid
the spaces between values use INSERT to insert the block
into a string. MOLD does not evaluate the values within a 
block. To do so use REMOLD.

^-print mold 10:30

^-print mold %image.jpg

^-print mold [1 2 3]

}
] 
money! [[datatype] [money? make type?] {

Represents the MONEY datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-print make money! "123"

^-print make money! [EUR 123.45]

}
] 
money? [[datatype] [money! type?] {

Returns FALSE for all other values.

^-print money? $123

^-print money? EUR$123

^-print money? 123.45

}
] 
multiply [[math] [* / // divide] {

The datatype of the second value may be restricted to
INTEGER or DECIMAL, depending on the datatype of the
first value (e.g. the first value is a time).

^-print multiply 123 10

^-print multiply 3:20 3

^-print multiply 0:01 60

}
] 
native [[internal] [] {

Internal use only.

}
] 
native! [[datatype] [native? make type?] {

Represents the NATIVE datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

}
] 
native? [[datatype] [native! type?] {

Returns FALSE for all other values. When passing a
function to NATIVE? to be checked, it must be denoted
with ":". This is because the ":word" notation passes a
word's reference, not the word's value. NATIVE? can only
determine whether or not a function is a native if it is
passed the function's reference.

^-probe native? :native?   ; it's actually an ACTION!

^-probe native? "Vichy"

^-probe native? :if

}
] 
negate [[math] [+ - positive? negative?] {

Returns the negative of the value provided.

^-print negate 123

^-print negate -123

^-print negate 123.45

^-print negate -123.45

^-print negate 10:30

^-print negate 100x20

^-print negate 100x-20

}
] 
negative? [[math] [positive?] {

Returns FALSE for all other values.

^-print negative? -50

^-print negative? 50

}
] 
net-error [[internal] [] {

Internal REBOL word.

}] 
new-line [[series] [new-line?] {

Where the NEW-LINE? function queries the status of the a 
block for markers, the NEW-LINE function inserts or removes 
them. You can use it to generate formatted blocks.

Given a block at a specified offset, new-line? will return 
true if there is a marker at that position. 

^-dent-block: func [
^-^-"Indent the contents of a block"
^-^-block
^-][
^-^-head new-line tail new-line block on on
^-]

^-b: [1 2 3 4 5 6]
^-probe dent-block b

If you want to put each item in a block on a new line, you 
can insert markers in bulk, using the /all refinement.

^-b: [1 2 3 4 5 6]
^-probe new-line/all b on

If you don't know whether a block contains markers, you may 
want to remove all markers before formatting the data.

^-b: [
^-^-1 2 
^-^-3 4
^-]
^-probe new-line/all b off

Another common need is formatting blocks into lines of fixed 
size groups of items; that's what the /skip refinement is for.

^-b: [1 2 3 4 5 6]
^-probe new-line/skip b on 2

}
] 
new-line? [[series] [new-line] {

Given a block at a specified offset, new-line? will return 
true if there is a line marker at that position. 

^-b: [1 2 3 4 5 6]
^-forall b [if new-line? b [print index? b]]

^-b: [
^-^-1 2
^-^-3 4
^-^-5 6
^-]
^-forall b [if new-line? b [print index? b]]

}
] 
newline [[constant string] [tab crlf prin print] {

Returns a string that, when printed, begins a new line.

^-print ["start" newline "end"]

}
] 
next [[series string] [back first head tail head? tail?] {

If the series is at its tail, it will remain at its
tail. NEXT will not go past the tail, nor will it wrap
to the head.

^-print next "ABCDE"

^-print next next "ABCDE"

^-print next [1 2 3 4]

^-str: "REBOL"
^-loop length? str [
^-^-print str
^-^-str: next str
^-]

^-blk: [red green blue]
^-loop length? blk [
^-^-probe blk
^-^-blk: next blk
^-]

}
] 
ninth [[series string] [first second third pick] {

See the FIRST function for examples.

An error will occur if no value is found. Use the PICK function to avoid this error.

}] 
no [[constant] [true false on off yes] {

Another word for LOGIC FALSE.

^-print no

^-print not no

}
] 
none [[constant] [none? none!] {

A single value that means NONE of something.

^-print none

^-print pick "abc" 4

^-str: "once upon a time"
^-print find str "twice"

^-blk: [values are here]
^-print find blk 'there

}
] 
none! [[datatype] [none none?] {

Represents the NONE datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

}
] 
none? [[datatype] [none none!] {

Returns FALSE for all other values.

^-print none? NONE

^-print none? pick "abc" 4

^-print none? find "abc" "d"

}
] 
not [[math logic] [and or xor] {

Function returns TRUE if the value is FALSE, and FALSE
if it is TRUE. To bitwise complement an INTEGER, use the
COMPLEMENT function.

^-print not true

^-print not (10 = 1)

}
] 
not-equal? [[comparison] [<> = == equal?] {

String-based datatypes are considered equal when they
are identical or differ only by character casing
(uppercase = lowercase).

^-print not-equal? "abc" "abcd"

^-print not-equal? [1 2 4] [1 2 3]

^-print not-equal? 12-sep-98 10:30

}
] 
notify [[request view] [alert confirm flash inform request] {

Post a simple information message to the user. The only choice 
for the user is "OK". 

}
] 
now [[system] [date?] {

For accuracy, first verify that the time, date and
timezone are correctly set on the computer.

^-print now

^-print now/date

^-print now/time

^-print now/zone

^-print now/weekday

}
] 
number! [[datatype] [integer! decimal!] {

Represents both integer and decimal types.
When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-times: func [a [number!] b [number!]] [a * b]
^-print times 10 1.5
^-print times 3.1 5

}
] 
number? [[datatype] [integer? decimal?] {

Returns FALSE for all other values.

^-print number? 1234

^-print number? 12.34

^-print number? "1234"

}
] 
object! [[datatype] [make object? type?] {

Represents the OBJECT datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-test: make object! [
^-^-name: "alpha"
^-^-size: 12
^-^-type: 'rebol
^-^-doit: func [arg][size * arg]
^-]
^-print test/name

^-print test/doit 10

}
] 
object? [[datatype] [object! type?] {

Returns FALSE for all other values.

^-print object? system

}
] 
odd? [[math] [even?] {

Returns TRUE only if the argument is an odd integer value.
If the argument is a decimal, only its integer portion is
examined.

^-print odd? 3

^-print odd? 100

^-print odd? 0

}
] 
off [[constant] [true false yes no on] {

^-test: off
^-print either test ["turned on" ] ["turned off"]

}
] 
offset-to-caret [[view face] [caret-to-offset] {

This function is provided to convert from an xy offset within a
text face to a character index within a string. It is mainly
used for text editing and text mapping operations such as for
colored or hyperlinked text.

Here is an interesting example.  When you click your mouse on the
upper text face, the string from that position forward will be
shown in the lower text face.

^-view layout [
^-^-body 80x50 "This is an example string."
^-^-^-feel [
^-^-^-^-engage: func [face act event] [
^-^-^-^-^-if act = 'down [
^-^-^-^-^-^-bx/text: copy offset-to-caret
^-^-^-^-^-^-^-face event/offset
^-^-^-^-^-^-show bx
^-^-^-^-^-]
^-^-^-^-]
^-^-^-]
^-^-bx: body 80x50 white black
^-]

When the top face is clicked, the event/offset contains the xy
offset that is converted to a string index position with
offset-to-caret. The string from that point forward is copied
and displayed in the lower text box (bx).

Note that the string does not have to be displayed for this
function to work.  Also remember that when making changes to the
contents of strings that are longer than 200 characters, you
must set the text face line-list to NONE to force the
recomputation of all line breaks.

}
] 
offset? [[series string] [index? length? head head? tail tail? pick skip] {

Return the difference of the indexes for two positions within a
series.

^-str: "abcd"
^-p1: next str
^-print offset? str p1

^-str: "abcd"
^-p1: next str
^-p2: find str "d"
^-print offset? p1 p2

}
] 
on [[constant] [true false yes no off] {

^-test: on
^-print either test ["turned on" ] ["turned off"]

}
] 
op! [[datatype] [op?] {

Represents the OP datatype, both externally to the user
and internally within the system. When supplied as an
argument to the MAKE function, it specifies the type of
value to be created. When provided within the
specification of the argument of a function, it requests
the interpreter to check that the argument value is of
the specified type when the function is evaluated.

}
] 
op? [[datatype] [op!] {

Returns FALSE for all other values.

^-print op? :and

^-print op? :+

}
] 
open [[port file] [close load do insert remove read write query get-modes set-modes] {

Opens a port for I/O operations. The value returned from
OPEN can be used to examine or modify the data
associated with the port. The argument must be a
fully-specified port specification, an abbreviated port
specification such as a file path or URL, or a block
which is executed to modify a copy of the default port
specification.

^-autos: open/new %autos.txt
^-insert autos "Ford"
^-insert tail autos " Chevy"
^-close autos
^-print read %autos.txt

}
] 
open-events [[internal] [] {

Opens the internal event port. You shouldn't need to use this function,
unless you're writing your own windowing system in REBOL or something
along those lines.

}
] 
or [[math logic] [and not xor] {

An infix-operator. For LOGIC values, both must be FALSE
to return FALSE; otherwise a TRUE is returned. For
integers, each bit is separately affected. Because it is
an infix operator, OR must be between the two values.

^-print true or false

^-print (10 > 20) or (20 < 100)

^-print 122 or 1

^-print 1.2.3.4 or 255.255.255.0

}
] 
or~ [[internal] [and~ xor~] {

The trampoline action function for OR operator.

}
] 
outside? [[view comparison] [inside? overlap?] {

^-probe outside? 100x100 50x50
^-
^-probe outside? 100x100 150x150

}
] 
overlap? [[view face comparison] [inside? outside?] {

^-out: layout [
^-^-face1: box red
^-^-face2: box blue
^-]

^-probe overlap? face1 face2
^-face2/offset: face2/offset - 0x50
^-probe overlap? face1 face2
}
] 
pair! [[datatype] [pair? as-pair to-pair] {

The pair datatype provides a way to express graphical coordinates
and sizes with a single value. It is commonly used to describe xy
points, positions, sizes, offsets, etc.

A pair datatype consists of two integer values separated by an upper
or lowercase 'x'. The first integer is the horizontal or X position,
the second is the vertical or Y position. Both positive and negative
integers are allowed. Here are examples:

^-position: 10x20
^-size: 1000x550
^-offset: -245x-50
^-shift: 320x-50

You can access the separate X and Y values using the /x and /y
refinements:

^-print size/x
^-print size/y

To create pairs from separate X and Y integer values, use the AS-PAIR
function:

^-size: as-pair 100 200

Pairs can be used within mathematical expressions that can act on
the X and Y parts separately or combined. For example:

^-print 10x20 + 100x50
^-print 10x20 - 5

The first adds 10 to 100 for X and 20 to 50 for Y. The second
subtracts 5 from both X and Y.

Such combined math operations can be useful:

^-offset: 100x100     ; upper left corner
^-size: 300x500       ; xy size
^-print offset + size ; the lower right corner

Here 500 is added to both X and Y. Other math examples are:

^-print 10x20 - 5
^-print 10x20 * 50
^-print 10x20 / 2

It is good to recognize that you can multiply pair values by "unity
pairs" (1x0 and 0x1) to mask specific coordinates. For example:

^-pos: 100x50
^-print pos * 1x0 + 0x500

This would be equivalent to:

^-print as-pair pos/x 500

}] 
pair? [[datatype] [pair! to-pair as-pair] {

Returns true if the value is an xy pair datatype.

^-print pair? 120x40

^-print pair? 1234

See the PAIR! word for more detail.
}
] 
paren! [[datatype] [paren? make type?] {

Represents the PAREN datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
specification of the argument of a function, it requests
the interpreter to check that the argument value is of
the specified type when the function is evaluated.

^-print mold make paren! [1 + 2]

}
] 
paren? [[datatype] [paren! type?] {

Returns FALSE for all other values. A paren is identical
to a block, but is immediately evaluated when found.

^-print paren? second [123 (456 + 7)]

^-print paren? [1 2 3]

}
] 
parse [[series string sets] [trim] {

Parsing provides a means of recognizing a series of
characters that appear in a particular order. Essentially,
it is a method of finding and matching patterns. The
rules argument supplies a block of grammar productions
that are to be matched.

There is also a simple parse
mode that does not require rules, but takes a string of
characters to use for splitting up the input string.

Parse also works in conjunction with bitsets (charset)
to specify groups of special characters.

The result returned from a simple parse is a block of
values. For rule-based parses, it returns TRUE if the
parse succeeded through the end of the input string.

The /ALL refinement indicates that all the characters
within a string will be parsed. Otherwise, spaces, tabs,
newlines, and other non-printable characters will be
treated as spaces. 

The /CASE refinement specifies that a string is to be 
parsed case sensitive.

^-print parse "divide on spaces" none

^-print parse "Harry Haiku, 264 River Rd., Ukiah, 95482" ","

^-page: read http://hq.rebol.net
^-parse page [thru <title> copy title to </title>]
^-print title

^-digits: charset "0123456789"
^-area-code: ["(" 3 digits ")"]
^-phone-num: [3 digits "-" 4 digits]
^-print parse "(707)467-8000" [[area-code | none] phone-num]

}
] 
parse-email-addrs [[internal] [] {

Internal REBOL word.

}] 
parse-header [[internal] [] {

Internal REBOL word.

}] 
parse-header-date [[internal] [] {

Internal REBOL word.

}] 
parse-xml [[string] [parse build-tag] {

A limited XML parser is provided with every REBOL/Core and
REBOL/View. The parser will convert simple XML expressions into
REBOL blocks that can be processed more easily within REBOL.

^-xml: {
^-^-<person>
^-^-^-<name>Fred</name>
^-^-^-<age>24</age>
^-^-^-<address>
^-^-^-^-<street>123 Main Street</street>
^-^-^-^-<city>Ukiah</city>
^-^-^-^-<state>CA</state>
^-^-^-</address>
^-^-</person>
^-}
^-data: parse-xml xml
^-probe data

The XML above is semantically equivalent to writing the REBOL
block:

^-[
^-^-person [
^-^-^-name "Fred"
^-^-^-age 24
^-^-^-address [
^-^-^-^-street "123 Main Street"
^-^-^-^-city "Ukiah"
^-^-^-^-state "Ca"
^-^-^-]
^-^-]
^-]

Here is a small REBOL function that converts the above XML into
such a REBOL block:

^-to-rebol-data: func [block /local out] [
^-^-out: copy []
^-^-foreach [tag attr body] block [
^-^-^-append out to-word tag
^-^-^-foreach item body [
^-^-^-^-either block? item [
^-^-^-^-^-append/only out to-rebol-data item
^-^-^-^-][
^-^-^-^-^-if not empty? trim item [append out item]
^-^-^-^-]
^-^-^-]
^-^-]
^-^-out
^-]
^-probe to-rebol-data data

Note that the function strips extra whitespace from the XML
(using the TRIM function).

If you wish to modify or expand the XML parser for your own
purposes, you can obtain its source code with these lines:

^-source parse-xml

^-probe xml-language

}
] 
path [[internal] [] {

Internal use only.

}
] 
path! [[datatype] [path? lit-path? lit-path! set-path? set-path! get-path? 
        get-path! make refinement? refinement!
    ] {

Represents the PATH datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-the-time: make path! [now time]
^-probe :the-time

^-probe the-time

}
] 
path-thru [[file port] [info launch do-thru exists-thru? launch-thru load-thru read-thru] {

If the url parameter is a file! value, it will be returned
unchanged; only url! values are cache-relative.

}
] 
path? [[datatype] [path! make] {

Returns FALSE for all other values.

^-print path? first [random/seed 10]

}
] 
pi [[constant] [arccosine arcsine arctangent cosine sine tangent] {

Mathematical constant for Pi, 3.14159265358979.

^-print pi

^-print cosine/radians pi

}
] 
pick [[series string port] [first second third fourth fifth find select] {

The value is picked relative to the current position in
the series (not necessarily the head of the series).
The VALUE argument may be INTEGER or LOGIC. A positive
integer positions forward, a negative positions
backward. If the INTEGER is out of range, NONE is
returned. If the value is LOGIC, then TRUE refers to the
first position and FALSE to the second (same order as
EITHER). An attempt to pick a value beyond the limits
of the series will return NONE.

^-str: "REBOL"

^-print pick str 2

^-print pick 199.4.80.1 3

^-print pick ["this" "that"] now/time > 12:00

}
] 
poke [[series string port] [pick change] {

Similar to CHANGE, but also takes an index into the series.

^-str: "ABC"
^-poke str 2 #"/"
^-print str

^-print poke 1.2.3.4 2 10

}
] 
port! [[datatype port] [port? make type?] {

Represents the PORT datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

}
] 
port? [[datatype port] [port! make! type?] {

Returns FALSE for all other values.

^-file: open %newfile.txt
^-print port? file
^-close file

^-print port? "test"

}
] 
positive? [[math] [negative?] {

Returns FALSE for all other values.

^-print positive? 50

^-print positive? -50

}
] 
power [[math] [** exp log-10 log-2 log-e] {

^-print power 10 2

^-print power 12.3 5

}
] 
prin [[port file series string help] [print input echo] {

No line termination is used, so the next value printed
will appear on the same line. If the value is a block,
each of its values will be evaluated first then printed.

^-prin "The value is "
^-prin [1 + 2]

^-prin ["The time is" now/time]

}
] 
print [[port file series string help] [prin input echo] {

If the value is a block, each of its values will be
evaluated first, then printed.

^-print 1234

^-print ["The time is" now/time]

}
] 
probe [[help] [mold print] {

Probe is very useful for debugging. Insert it anywhere a
value is being passed and it will display the value without
interfering with the code.

^-probe ["red" "green" "blue"]

^-if probe now/time > 12:00 [print "now"]

}
] 
protect [[system] [unprotect] {

Prevents a word from being modified using a set operation. An
attempt to modify a locked word generates an error.

^-test: "This word is protected!"
^-protect 'test
^-if error? try [test: "Trying to change test..."] [
^-^-print "Couldn't change test!"
^-]

^-print test
^-unprotect 'test

}
] 
protect-system [[system] [protect unprotect] {

Sets the PROTECT flag for all REBOL system words to prevent your
script from accidentally changing important system words by your
script.

In REBOL/Core and REBOL/View, you can add this function to your
user.r script to automatically protect the system words every
time you run REBOL.

}
] 
q [[control] [halt exit quit] {

Shortcut for QUIT.

See QUIT for details.

}
] 
query [[port] [open update get-modes] {

Its argument is an unopened port specification. The
size, date and status fields in the port specification
will be updated with the appropriate information if the
query succeeds.

}
] 
quit [[control] [halt exit] {

Releases all resources back to the system. Shortcut: Q.
Use EXIT to exit a function without returning a value.

^-time: 10:00
^-if time > 12:00 [
^-^-print "time for lunch"
^-^-quit
^-]

}
] 
random [[math logic series string] [now] {

The value passed can be used to restrict the range of
the random result. For integers random begins at one,
not zero, and is inclusive of the value given. (This
conforms to the indexing style used for all series
datatypes, allowing random to be used directly with
functions like PICK.)

^-loop 4 [print random 10]

^-lunch: ["Italian" "French" "Japanese" "American"]
^-print pick lunch random 4

^-loop 3 [print random true]

^-loop 5 [print random 1:00:00]

To initialize the random number generator to a random state, you
can seed it with a value (to repeat the sequence) or the current
time to start a unique seed.

^-random/seed 123

^-random/seed now

That last line is a good example to provide a fairly random
starting value for the random number generator.

RANDOM can also be used on all series datatypes:

^-print random "abcdef"

^-print random [1 2 3 4 5]

It will return a series that contains the same number of elements.
To cut it down, you can use CLEAR:

^-key: random "abcdefghijklmnopqrstuv0123456789"
^-clear skip key 6
^-print key

Here's an example password generator. Add more partial words
to get more variations:

^-syls: ["ca" "ru" "lo" "ek" "-" "." "!"]
^-print rejoin random syls

}
] 
read [[port file] [write open close load save set-modes get-modes file! url! port!] {

Using READ is the simplest way to get information from
a file or URL. This is a higher level port operation
that opens a port, reads some or all of the data, then
closes the port and returns the data that was read. 
When used on a file, or URL, the contents of the file,
or URL are returned as a string.

The /BINARY refinement forces READ to do a binary read.
When used on a text file, line terminators will not be
converted.

The /STRING refinement translates line terminators to
the operating system's line terminator. This behavior
is default.

The /DIRECT refinement reads without buffering, useful
for reading files too large to contain in memory.

The /LINES refinement returns read content as a series 
of lines. One line is created for each line terminator
found in the read data.

The /PART refinement reads the specified number of 
elements from the file, URL, or port. Reading a file
or URL will read the specified number of characters.
Used with /LINES, it reads a specified number of 
lines. 

The /WITH refinement converts characters, or strings,
specified into line terminators.

See the User's Guide for more detailed explanation of
using READ and its refinements.

^-write %rebol-test-file.r "text file"
^-print read %rebol-test-file.r

^-write %rebol-test-file.r [
^-{A learned blockhead is a greater man
^-than an ignorant blockhead.
^-^--- Rooseveldt Franklin}
^-]
^-probe first read/lines %rebol-test-file.r

^-probe pick (read/lines %rebol-test-file.r) 3

^-probe read/part %rebol-test-file.r 9

^-probe read/with %rebol-test-file.r "blockhead"

}
] 
read-cgi [[string port] [] {

This is a helper function for CGI scripting applications.

}] 
read-io [[port] [write-io] {

This function provides a low level method of reading data from a
port. For most code, this function should not be used because
the COPY function is the proper method of reading data from a
port. However, under some situations, using READ-IO may be
necessary.

The primary difference between READ-IO and COPY is that READ-IO
requires a fixed size buffer and maximum transfer length as its
arguments. Like the READ function of the C language, bytes are
transferred into the buffer up to the maximum length specified.
The length of the transfer is returned as a result, and it can
be zero (for nothing transferred), or even negative in the case
of some types of errors.

Here is a simple example of READ-IO on a file <B>(Note again:
this is a low level IO method; you should normally use the
series functions like COPY, INSERT, NEXT, etc. for reading and
writing to IO ports.)</B>

^-write %testfile "testing"
^-buffer: make string! 100
^-port: open/direct %testfile
^-read-io port buffer 4
^-close port
^-probe buffer

If the length of the transfer is larger than the buffer
provided, the length will be truncated to the buffer size, just
as if that length was provided as the argument (so no data will
be lost).

The code below provides an excellent example of READ-IO for
reading CGI (web server) data:

^-read-cgi: func [
^-^-"Read CGI form data from get or post."
^-^-/local data buf
^-][
^-^-if system/options/cgi/request-method = "post" [
^-^-^-data: make string! 1020
^-^-^-buffer: make string! 16380
^-^-^-while [positive? read-io system/ports/input buffer 16380][
^-^-^-^-append data buffer
^-^-^-^-clear buffer
^-^-^-]
^-^-^-return data
^-^-]
^-^-if system/options/cgi/request-method = "get" [
^-^-^-return system/options/cgi/query-string
^-^-]
^-^-test-data ; if in test mode
^-]

In this example, if the CGI request is a post type, then data is
supplied as a binary stream to REBOL's input port. The code
shows how the port is read until all data has been collected
(while the return value is positive). Note that the BUFFER is a
fixed size and as it is read, data is being accumulated into a
self-expanding DATA buffer.

}
] 
read-net [[view file port] [] {

^-download: func [url] [
^-^-view/new layout [
^-^-^-lbl "Downloading" return text (form url)
^-^-^-bar: progress
^-^-]
^-^-cbk-fn: func [total bytes] [
^-^-^-set-face bar bytes / total
^-^-]
^-^-read-net/progress url :cbk-fn
^-^-unview
^-]
^-download http://www.rebol.com/index.html

}
] 
read-thru [[file port] [exists-thru? do-thru launch-thru load-thru path-thru] {

Read a file from a URL (such as a website) and store it locally in as
cache file. The next time you read the same URL file, it will be
read from the cache file, rather than from the network.

In order to support reading of images, sounds, and other binary files,
this function reads as binary.

}] 
REBOL [[system] [system object! object?] {

Used to mark the beginning of a REBOL code or data file.
Can be followed by a block that provides userful header
information about the contents of the file.

This word should not be used within evaluated code.
(Currently it acts as a synonym of the SYSTEM word
but that result may change.)

}
] 
recycle [[system] [] {

This function will force a garbage collection of unused words
and values found in memory. This function is not required or
recommened for most scripts because the system does it
automatically as necessary.

To disable garbage collection, you can specify /off refinement.

^-recycle/off

To enable it again, use /on:

^-recycle/on

Note that recently used values may not be immediately garbage
collected, even though they are no longer being referenced by
your program.

}
] 
reduce [[control series] [compose do foreach] {

When given a block, evaluates each of its expressions
and returns a block with all of the results. Very
useful for composing blocks of values.

^-values: reduce [1 + 2 3 + 4]
^-probe values

The REDUCE function is a major element of the REBOL language
because it allows you to initialize blocks with values that must
be computed. For example:

^-file: %dict-notes.r
^-info: reduce [now/date size? file modified? file]
^-probe info

}
] 
refinement! [[datatype] [refinement?] {

Represents the REFINEMENT datatype, both externally to
the user and internally within the system. When supplied
as an argument to the MAKE function, it specifies the
type of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

}
] 
refinement? [[datatype] [refinement!] {

Returns FALSE for all other values.

^-print refinement? /any

^-print refinement? 'any

}
] 
reform [[string] [form mold remold join rejoin] {

Identical to FORM but reduces its argument first.
Spaces are inserted between each value.

^-probe reform ["the time is:" now/time]

^-probe form ["the time is:" now/time]

}
] 
rejoin [[series string string] [join form reform] {

Similar to JOIN but accepts only one argument, the
block (which will be reduced first). No spaces are
inserted between values.

^-print rejoin ["time=" now/time]

}
] 
remainder [[math] [// * /] {

If the second number is zero, an error will occur.

^-print remainder 123 10

^-print remainder 10 10

^-print remainder 10.2 10

If the first value is positive, then the returned remainder is nonnegative.

If the first value is negative, then the returned remainder is nonpositive.

}
] 
remold [[string] [mold reduce reform form] {

Identical to MOLD, but reduces its argument first.
Spaces are inserted between each values in a block.

^-print remold ["the time is:" now/time]

}
] 
remove [[series string modify] [append change clear insert sort] {

Normally removes just a single value from the current
position. However, you can remove any number of values
with the /PART refinement.

^-str: copy "send it here"
^-remove str
^-print str

^-remove/part str find str "it"
^-print str

^-remove/part str 3
^-print str

^-blk: copy [red green blue]
^-remove next blk
^-probe blk

}
] 
remove-each [[control series string modify] [foreach remove] {

REMOVE-EACH is similar to FOREACH, but removes values as
it moves through a series.  For each value in the series,
a comparison block is executed. If the block returns true,
then the value will be removed.

^-values: [12 test 30 "C" "D" 10]
^-remove-each value values [word? value]
^-probe values

^-remove-each value values [all [integer? value value > 11]]
^-probe values

Using REMOVE-EACH for removing values provides much greater
performance than using a WHILE or FORALL loop.

This function is not available in older versions of REBOL.

}
] 
remove-event-func [[view port] [insert-event-func wait] {

This function removes an event handler that you installed previously
with INSERT-EVENT-FUNC.

For example:

^-my-handler: func [face event] [... event]
^-insert-event-func :my-handler

^-remove-event-func :my-handler

}] 
rename [[file] [delete list-dir what-dir] {

Renames a file within the same directory:

^-write %testfile now
^-rename %testfile %remove.me
^-probe read %remove.me
^-delete %remove.me

This function cannot be used to move a file from 
one directory to another.

}
] 
repeat [[control] [loop for forall foreach forskip while until] {

If the value is an integer, the word is used to keep
track of the current loop count, which begins at one and
continues up to and including the integer value given.

^-repeat num 5 [print num]

If the value is a series, then the word holds the first
value of each element of the series (see FOREACH).
Returns the value of the final evaluation. The BREAK
function can be used to stop the loop at any time (but
no value is returned). The word is local to the block.

Note that a bug in REPEAT was fixed in Core 2.6.0 to allow REPEAT to
be used recursively.

}
] 
repend [[series string] [append insert reduce join] {

REPEND stands for REDUCE APPEND. It performs the same operation
as APPEND (inserting elements at the tail of a series) but
Reduces the block of inserted elements first. Just like APPEND,
REPEND returns the head of the series.

For example, writing:

^-numbers: [1 2 3]
^-probe repend numbers [2 + 2 2 + 3 3 + 3]

is the same as writing:

^-numbers: [1 2 3]
^-probe append numbers reduce [2 + 2 2 + 3 3 + 3]

REPEND is very useful when you want to add to a series elements
that need to be evaluated first. The example below creates a
list of all the .r files in the current directory, along with
their sizes and modification dates.

^-data: copy []
^-foreach file load %. [
^-^-if %.r = suffix? file [
^-^-^-repend data [file size? file modified? file]
^-^-]
^-]
^-probe data

When used with strings, repend is a useful way to join values.
The example below is a common method of generating HTML web
page code:

^-html: copy "<html><body>"
^-repend html [
^-^-"Date is: " now/date <P>
^-^-"Time is: " now/time <P>
^-^-"Zone is: " now/zone <P>
^-^-</body></html>
^-]
^-print html

}
] 
replace [[series string modify] [insert remove change] {

Searches target block or series for specified data and 
replaces it with data from the replacement block or 
series. Block elements may be of any datatype.

The /ALL refinement replaces all occurrences of the 
searched data in the target block or series.

^-str: "a time a spec a target"
^-replace str "a " "on "
^-print str

^-replace/all str "a " "on "
^-print str

^-fruit: ["apples" "lemons" "bananas"]
^-replace fruit "lemons" "oranges"
^-print fruit

^-numbers: [1 2 3 4 5 6 7 8 9]
^-replace numbers [4 5 6] ["four" "five" "six"]
^-print numbers

}
] 
request [[view] [alert flash inform] {

Request the user to answer a question.  Various refinements
allow for a range of answers. The REQUEST function returns
TRUE, FALSE, or NONE.  TRUE is returned on an affirmative
answer, FALSE is returned on a negative answer, and NONE
is returned on a cancel operation.

^-request "Do you want to save?"

^-request/confirm "Delete the file?"

^-request/ok "File has been removed."

^-request ["Select action:" "Encrypt" "Decrypt" "Cancel"]

The results returned are TRUE, FALSE, or NONE, based on what button
was selected. If the user closes the requestor windown, then the
result will be NONE. For example to act on the above example:

^-req: request "Save file contents?"
^-if none? req [exit]
^-if req [save-file]

}
] 
request-color [[view request] [request] {

Popup a window that requests a color selection from the user.

}
] 
request-date [[view request] [request] {

Popup a window that contains a calendar to request a date
from the user.

}
] 
request-dir [[view request] [request request-file] {

Popup a window to allow the user to select a directory.

Note that it may display a security requestor if security is in effect and
the user navigates outside the sandbox.

}
] 
request-download [[view request] [request] {

Begin downloading a file from a URL and show a progress
bar.  Return the data of the file as a binary value.
The user may cancel the operation at any time, in which
case a NONE is returned.

}
] 
request-file [[view request] [request] {

Popup a window to allow the user to select a file.

}
] 
request-list [[view request] [request] {

Popup a window that requests the user pick an item 
from a list.

}
] 
request-pass [[view request] [request] {

Pop-up a window that requests a username and password from the user.
The password is obscured with *'s as it is entered.

The result is returned as block that contains two strings.  The
first string is the username entry, the second is the password.
If the user cancels the pop-up, a none is returned.

For example:

^-if user-pass: request-pass [
^-^-print ["User:" user-pass/1 "Pass:" user-pass/2]
^-]

You can provide a default username with the user refinement:

^-request-pass/user "Fred"

To specify a password only, use the /only refinement. To provide
a different title for the pop-up, use the /title refinement.

}
] 
request-text [[view request] [request] {

Pop-up a window that requests text from the user. The /title
refinement can be used to change the request question:

^-print request-text/title "Enter your name:"

If the user presses cancel or closes the window, a NONE is
returned.

}
] 
resend [[port] [send] {

Resends an email message to the specified email. Resent
emails are in no way altered leaving even the original 
"To:", "From:", and other fields intact. Messages
resent must be passed to RESEND as a single string
value containing the email.

^-message: "Feel the programming force."

^-resend luke@rebol.com me@here.dom message

}
] 
reset-face [[view face] [clear-face get-face set-face] {

This face accessor function makes it easy to reset a face,
to its default value so you don't have to remember what facet 
(property) each style uses to store its data. It also allows 
you to write generic loops that reset multiple faces.

}
] 
resize-face [[view face] [set-face get-face] {

Resize a face, including any of its internal subfaces. This function
is used mainly by selected VID faces. All VID face styles may not
currently support it.

}] 
return [[function] [break exit catch] {

Exits the current function immediately, returning
a value as the result of the function. To return no
value, use the EXIT function.

^-fun: make function! [this-time] [
^-^-return either this-time >= 12:00 ["after noon"][
^-^-^-"before noon"]
^-]
^-print fun 9:00

^-print fun 18:00

}
] 
reverse [[series string modify] [insert replace sort find] {

Reverses the order of elements in a series or tuple.

^-blk: [1 2 3 4 5 6]
^-reverse blk
^-print blk

The /PART refinement reverses the specified number 
of elements from the current index forward. If the 
number of elements specified exceeds the number of 
elements left in the series or tuple, the elements from 
the current index to the end will be reversed.

^-text: "It is possible to reverse one word in a sentence."
^-reverse/part (find text "reverse") (length? "reverse")
^-print text

Note that reverse returns the starting position it was
given. (This change was made to newer versions.)

^-blk: [1 2 3 4 5 6]
^-print reverse/part blk 4

Reverse also works for pairs and tuples:

	print reverse 10x20
	print reverse 1.2.3

For tuple values the current index cannot be moved so the 
current index is always the beginning of the tuple.

^-print reverse 1.2.3.4

^-print reverse/part 1.2.3.4 2

}
] 
rgb-to-hsv [[view] [] {

This conversion is useful if you need to get the brightness (v),
color saturation (s), or the hue (h) of an RGB value.

The conversion is done in native code in order to get the highest
performance.

}] 
round [[math] [mod modulo // remainder] {

"Rounding is meant to loose precision in a controlled way." -- Volker Nitsch

ROUND is a very flexible rounding function. With the various refinements
and the scale option, you can easily round in various ways. Most of the
refinements are mutually exclusive--that is, you should use only one of
them--the /TO refinement is an obvious exception; it can be combined 
with any other refinement. 

By default, ROUND returns the nearest integer, with halves rounded up (away 
from zero).

^-probe round 1.4999

^-probe round 1.5

^-probe round -1.5

If the result of the rounding operation is a number! with no decimal component, 
and the SCALE value is not time! or money!, an integer will be returned. This 
makes it easy to use the result of ROUND directly with iterator functions such
as LOOP and REPEAT.

The /TO refinment controls the "precision" of the rounding. That is, the result
will be a multiple of the SCALE parameter. In order to round to a given number
of decimal places, you don't pass in the number of decimal places, but rather 
the "level of precision" they represent. For example, to round to two decimal
places, often used for money values, you would do this:

^-probe round/to $1.333 .01

To round to the nearest 1/8, often used for interest rates, you would do this:

^-probe round/to 1.333 .125

To round to the nearst 1K increment (e.g. 1024 bytes):

^-probe round/to 123'456 1024

If the /TO refinement is used, and SCALE is a time! or money! value, the result 
will be coerced to that type. If SCALE is not used, or is not a time! or money! 
value, the datatype of the result will be the same as the valued being rounded.

The /EVEN refinement is designed to reduce bias when rounding large groups of
values. It is sometimes called Banker's rounding, or statistical rounding. For 
cases where the final digit of a number is 5 (e.g. 1.5 or 15), the previous 
digit will be rounded to an even result (2, 4, etc.).

^-repeat i 10 [val: i + .5 print [val round/even val]]

^-repeat i 10 [val: i * 10 + 5 print [val round/even/to val 10]]

The /DOWN refinement rounds toward zero, ignoring discarded digits. It is often
called "truncate".

^-probe round/down 1.999

^-probe round/down -1.999

^-probe round/down/to 1999 1000

^-probe round/down/to 1999 500

The /HALF-DOWN refinement causes halves to round toward zero; by default they are
rounded up.

^-probe round/half-down 1.5

^-probe round/half-down -1.5

^-probe round/half-down 1.50000000001

^-probe round/half-down -1.50000000001

The /HALF-CEILING refinement causes halves to round in a positive direction; by 
default they are rounded up (away from zero). This works like the default 
behavior for positive values, but is not the same for negative values.

^-probe round -1.5

^-probe round/half-ceiling -1.5

/FLOOR causes numbers with any decimal component to be rounded in a negative 
direction. It works like /DOWN for positive numbers, but not for negative numbers.

^-round/floor 1.999

^-round/floor -1.01

^-round/floor -1.00000000001

/CEILING is the reverse of /FLOOR; numbers with any decimal component are rounded
in a positive direction.

^-round/ceiling 1.01

^-round/ceiling 1.0000000001

^-round/ceiling -1.999


If you are rounding extremely large numbers (e.g. 562'949'953'421'314), or using
very high precision decimal values (e.g. 13 or more decimal places), you may run
up against REBOL's native limits for values and its internal rounding rules. The
ROUND function is a mezzanine and has no control over that behavior.


Sometimes, it might appear that ROUND is doing something strange, so before 
submitting a bug to RAMBO, think about what you're actually asking it to do. For 
example, look at the results from this piece of code:

^-repeat i 10 [
^-^-scale: .9 + (i * .01) 
^-^-print [scale  round/down/to 10.55 scale]
^-]

The results approach 10.55 for values from 0.91 to 0.95, but then jump back when 
using values in the range 0.96 to 0.99. Those are the expected results, because 
you're truncating, that is, truncating to the nearest multiple of SCALE. 


The design and development of the ROUND function involved many members 
of the REBOL community. There was much debate about the interface (one
function with refinement versus individual functions for each rounding
type, what words to use for parameter names, behavior with regards to
type coercion).

}
] 
routine? [[datatype] [] {

Returns TRUE if the value is a routine (DLL function) datatype.

}
] 
rsa-encrypt [[encryption] [rsa-generate-key rsa-make-key] {

This function encrypts or decrypts a binary with an RSA 
key. The result is another binary. The /decrypt refinement 
selects decryption (default is encryption). The /private 
refinement selects encryption or decryption using the 
private key (default is to use the public key).

The /padding refinement selects the type of padding to use. 
The default (no /padding refinement) is PKCS1 Type 1 and 
should be used whenever communication takes place among 
REBOL scripts only. For compatibility with other 
environments using RSA the following alternative padding 
methods are supported:

none - No padding. Only works if the amount of data to 
be encrypted is exactly identical to the key size. 

'pkcs1 - PKCS1. Type 1 for private key blocks. Type 2 
for public key blocks. 

'oaep - PKCS1 v2.0 EME-OAEP (RFC 2437). For public key 
blocks only. 

'ssl - This is a slight variation of PKCS1 Type 2, used 
by SSL v2 and v3. For public key blocks only. 

}
] 
rsa-generate-key [[encryption] [rsa-encrypt rsa-make-key] {

This function creates a new, random RSA key (public and 
private portion), and fills the data into the object! 
passed as rsa-key. Size is the number of bits (e.g. 1024). 
Generator is the prime number used as a generator. The 
typical value is 3. An RSA key object contains the 
following fields:

n - Public key. This is the value that has to be published 
in order to allow public key encryption or decryption. 

d - Private key. This value is the secret part of the 
private key. 

e - Generator (usually 3). 

p, q, dmp1, dmq1, iqmp - Parts of the secret key, used to 
improve the performance of private key operations. If only 
n, d and e are saved for a private key then the key can 
still be used for private key operations, but those 
operations will be slower than for a key that contains p, q, 
dmp1, dmq1 and iqmp. 

various mont fields - These are temporary values to further 
improve performance. They do not have to be saved. 

Only the "n" field of a key should be published. The "e" 
field is usually set to 3 by convention. All other fields 
have to be kept secret. When saving a private key it is 
usually most convenient to write the complete molded object 
to a file, instead of individual fields.

}
] 
rsa-make-key [[encryption] [rsa-encrypt rsa-generate-key] {

This function returns an empty object! laid out as an 
RSA key. It does not fill in any data. The function is 
mainly used in preparation for creating an RSA key used 
for public encryption or decryption.

}
] 
run [[internal] [] {

Internal REBOL word.

}] 
same? [[comparison] [=? equal?] {

Returns TRUE if the values are identical objects, not
just in value. For example, a TRUE would be returned if
two strings are the same string (occupy the same
location in memory). Returns FALSE for all other
values.

^-a: "apple"
^-b: a
^-print same? a b

^-print same? a "apple"

}
] 
save [[file] [load mold write] {

Performs the appropriate conversion and formatting to
preserve datatypes. For instance, if the value is a
REBOL block, it will be saved as a REBOL script that,
when loaded, will be identical.

^-save %date.r now
^-print read %date.r

^-date: load %date.r
^-print date

^-save %data.r reduce ["Data" 1234 %filename now/time]
^-print read %data.r

^-probe load %data.r

}
] 
save-user [[internal] [write-user] {

Normally you won't use this function, but if you update user settings
and want to save them, you can. You should note that it doesn't save
any custom data that exists in %user.r, so it's really only good for use
by the desktop.

}
] 
screen-offset? [[view] [win-offset?] {

If you need to know where a face is relative to the top-left corner of the
screen, use this function.

}
] 
script? [[file string] [parse-header] {

If the header is found, the script string will be returned
as of that point. If not found, then NONE is returned.

^-print either script? %file.txt ["found"]["not found"]

}
] 
scroll-drag [[internal] [] {

Internal REBOL word.

}] 
scroll-face [[view face] [set-face get-face resize-face] {

This function will scroll faces that support scrolling, such as
text, areas, tables, etc.. This function is used mainly by selected
VID faces. Some VID face styles may not currently support it.

}] 
scroll-para [[internal] [] {

Internal REBOL word.

}] 
second [[series string] [pick first third fourth fifth] {

An error will occur if no value is found. Use the PICK
function to avoid this error.

^-print second "REBOL"

^-print second [11 22 33 44 55 66]

^-print second 12-jun-1999

^-print second 199.4.80.1

^-print second 12:34:56.78

}
] 
secure [[control file port] [open read write] {

This function controls file and network access. It uses a
dialect to specify security "sandboxes" that allow or deny
access. You can set different security levels and multiple
sandboxes for networking, files, and specific files and
directories.

The argument to the SECURE function can be a word or a block.
If you provide a word, a global security level is set for all
accesses.  If you provide a block, you can specify separate
security for files, directories, and networking.

For example, if you write:

^-secure ask

the user will be prompted on all file and network accesses.
But, if you provide a block as the argument:

^-secure [
^-^-net quit
^-^-file ask
^-^-%./ allow
^-]

you will disable networking (will force a quit if attempted),
but ask for user approval for all file access, except to the
local directory (which will be allowed).

As you can see, the security dialect consists of a block of
paired values. The first value in the pair specifies what is
being secured (file or net), and the second value specifies the
level of security (allow, ask, throw, quit). The second value
can also be a block to further specify read and write security.

The security levels are:

ALLOW - removes all read and/or write restrictions.

ASK - restricts immediate read and/or write access and prompts
the user for each access attempt, requiring approval before the
operation may be  completed.

THROW - denies read and/or write access, throwing an error when a
restricted access attempt is made.

QUIT - denies read and/or write access and quits the script
when restricted access is attempted.

For example, to allow all network access, but to quit on any
file access:

^-secure [
^-^-net allow ;allows any net access
^-^-file quit ;any file access will cause the program to quit
^-]

If a block is used instead of a security level word, it can
contain pairs of security levels and access types. This lets you
specify a greater level of detail about the security you
require. The access types allowed are: 

READ - controls read access.  

WRITE - controls write, delete, and rename access.

EXECUTE - controls execute access.

ALL - controls all access.

The pairs are processed in the order they appear, with later
pairs modifying the effect of earlier pairs. This permits
setting one type of access without explicitly setting all
others. For example: 

^-secure [
^-^-net allow
^-^-file [
^-^-^-ask all
^-^-^-allow read
^-^-^-quit execute
^-^-]
^-]

The above sets the security level to ask for all operations
except for reading (which is allowed).

This technique can also be used for individual files and
directories. For example: 

^-secure [
^-^-net allow
^-^-file quit
^-^-%source/ [ask read]
^-^-%object/ [allow all]
^-]

will prompt the user if an attempt is made to read the %source
directory, but it will allow all operations on the %object
directory. Otherwise, it uses the default (quit). 

If no security access level is specified for either network or
file access, it defaults to ASK. The current settings will not
be modified if an error occurs parsing the security block
argument. 

The SECURE function returns the prior security settings before
the new settings were made. This is a block with the global
network and file settings followed by file or directory
settings. The word QUERY can also be used to obtain the current
security settings without modifying them:

^-probe secure query

Using QUERY, you can modify the current security level by
querying the current settings, modifying them, then using the
secure function to set the new values. 

Note that lowering the security level produces a change security
settings requestor to the user. The exception is when the REBOL
session is running in quiet mode which will, instead, terminate
the REBOL session. No request is generated when security levels
are raised. Note that the security request includes an option to
allow all access for the remainder of the scripts processing. 

When running REBOL, the -s argument can be provided on the
command line to specify an initial security of:

^-secure allow

The +s argument will specify:

^-secure quit

You can also use the --secure argument to specify any other
default security level on REBOL startup.

}
] 
select [[series string] [find switch] {

Similar to the FIND function, but returns the next value
in the series rather than the position of the match.
Returns NONE if search failed.

The /ONLY refinement is evaluated for a block argument 
and is ignored if the argument is a string.

^-blk: [red 123 green 456 blue 789]
^-print select blk 'red

^-weather: [
^-^-"Ukiah"      [clear 78 wind west at 5 MPH]
^-^-"Santa Rosa" [overcast 65 wind north at 10 MPH]
^-^-"Eureka"     [rain 62 wind north at 15 MPH]
^-]
^-probe select weather "Eureka"

}
] 
send [[port] [resend] {

The first argument can be an email address
or block of addresses. The value sent can be
any REBOL datatype, but it will be converted to text
prior to sending. For email, the message header will
be constructed from the default header, unless the
/HEADER refinement and a header object is provided.
The /ONLY refinement will use bulk email, sending
a single message to multiple email addresses.

Before you can use this function you must setup your
network configuration with SET-NET. This can be done
interactively by running the SET-USER function defined
in rebol.r.

^-send luke@rebol.com "Testing REBOL Function Summary"

^-header: make system/standard/email [
^-^-To: [luke@rebol.com]
^-^-From: [user@world.dom]
^-^-Subject: "Message with a header"
^-^-Organization: "REBOL Alliance"
^-]
^-send/header luke@rebol.com trim {
^-^-This is a longer message that also contains a
^-^-header.
^-} header

}
] 
series! [[datatype] [series?] {

Represents the SERIES datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-test-series: func [list [series!]][print length? list]
^-test-series "short string"
^-test-series [short block]

}
] 
series? [[datatype] [type? string? email? file? url? issue? tuple? block? paren?] {

Returns FALSE for all other values.

^-print series? "string"

^-print series? [1 2 3]

^-print series? 1234

}
] 
set [[context] [get in value? unset] {

If the first argument is a block of words and the value
is not a block, all of the words in the block will be
set to the specified value. If the value is a block,
then each of the words in the first block will be set to
the respective values in the second block. If there are
not enough values in the second block, the remaining
words will be set to NONE

The /ANY refinement allows words to be set any datatype
including those such as UNSET! that are not normally
allowed. This is useful in situations where all values
must be handled.

^-set 'test 1234
^-print test

^-set [a b] 123
^-print a

^-print b

^-set [d e] [1 2]
^-print d

^-print e

}
] 
set-face [[view face] [clear-face get-face reset-face] {

This face accessor function makes it easy to set the current
value of a face, so you don't have to remember what facet 
(property) each style uses to store its data. It also allows 
you to write generic loops that assign values to multiple faces.

^-view layout [
^-^-h2 "Enter date:"
^-^-f-date: field
^-^-across
^-^-btn "System Date" [set-face f-date now]
^-]

}
] 
set-font [[internal] [] {

Internal REBOL word.

}] 
set-modes [[port file] [get-modes open read write] {

This function sets a wide range of special modes for file and
network ports. SET-MODES takes a port and a block of modes that
contains words and values to specify the modes should be set.

^-port: open %test-file.txt
^-set-modes port [
^-^-binary: true
^-^-world-read: true
^-^-world-write: true
^-^-world-execute: true
^-]

The mode block accepted by set-modes is actually an object-style
initialization block and allows multiple names to reference the
same value.

^-set-modes port [binary: world-read: world-write: false]

Be sure to close the port when you are done:

^-close port

Note that a block returned by GET-MODES can be passed as an
argument to SET-MODES.

SET-MODES returns the port that was passed as an argument. 

See GET-MODES for a list of all port mode words.

}
] 
set-net [[port] [] {

See the manual for a detailed description of this 
function. The block contains a series of values 
used for network settings. Use SET-NET to establish
the network settings REBOL will use to access your
LAN, or WAN. 

The first value is your email address and it is 
used when sending email and connecting to FTP. 
This value is stored in the REBOL system object 
at: SYSTEM/USER/EMAIL

The second value is your SMTP (outgoing email) 
server name or address. This is stored in the 
REBOL system object at: SYSTEM/SCHEMES/DEFAULT/HOST

The third value is an optional POP (incoming 
email) server name or address. This is stored at:
SYSTEM/SCHEMES/POP/HOST

The fourth value is an optional proxy server name 
or address. See the manual for a complete 
description. This is at: SYSTEM/SCHEMES/DEFAULT/PROXY/HOST

The fifth value is an optional proxy port number.
This is at: SYSTEM/SCHEMES/DEFAULT/PROXY/PORT-ID

The sixth value is an optional proxy protocol. It 
can be socks, socks5, socks4, generic, or none. This 
is at: SYSTEM/SCHEMES/DEFAULT/PROXY/TYPE

This is a helper function. You can always set any 
of the protocols directly.

^-set-net [
^-^-user@domain.name
^-^-smtp.domain.name
^-]

^-set-net [
^-^-user@domain.name
^-^-smtp.domain.name
^-^-pop.domain.name
^-^-proxy.domain.name
^-^-1080
^-^-socks
^-]

}
] 
set-para [[internal] [] {

Internal REBOL word.

}] 
set-path! [[datatype] [path? make type?] {

Represents the SET-PATH datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-probe make set-path! [object field]

}
] 
set-path? [[datatype] [path! make] {

Returns FALSE for all other values.

^-if set-path? first [a/b/c: 10] [print "Path found"]

}
] 
set-style [[internal] [] {

Internal REBOL word.

}] 
set-user-name [[internal] [] {

Internal REBOL word.

}] 
set-word! [[datatype] [set-word?] {

Represents the SET-WORD datatype, both externally to
the user and internally within the system. When
supplied as an argument to the MAKE function, it
specifies the type of value to be created. When
provided within the function's argument specification,
it requests the interpreter to verify that the argument
value is of the specified type when the function is
evaluated.

^-probe make set-word! "test"

}
] 
set-word? [[datatype] [set-word!] {

Returns FALSE for all other values.

^-if set-word? first [word: 10] [print "it will be set"]

}
] 
seventh [[series string] [first second third pick] {

See the FIRST function for examples.

An error will occur if no value is found. Use the PICK function to avoid this error.

}] 
show [[view face] [hide view unview] {

This is a low-level View function that is used to display or
update a face. The face being displayed must be part of a
pane that is part of a window display.

The SHOW function is called frequently to update the display of
a face after changes have been made.  If the face contains a
pane of sub-faces, all of those faces will be redisplayed.

If you attempt to show a face and nothing happens, make sure
that the face is part of the display hierarchy.  That is, the
face must be present in the pane list of another face that is
being displayed.

For example, if you modify any of the attributes of a face,
you call the SHOW function to display the change.  The code
below shows this:

^-view layout [
^-^-bx: box 100x24 black
^-^-button "Red" [bx/color: red  show bx]
^-^-button "Green" [bx/color: green  show bx]
^-]

The example below creates a layout face and then removes faces
from its pane.  The SHOW function is called each time to refresh
the face and display what has happened.

^-out: layout [
^-^-h1 "Show Example"
^-^-t1: text "Text 1"
^-^-t2: text "Text 2"
^-]
^-view/new out
^-wait 1
^-remove find out/pane t2
^-show out
^-wait 1
^-remove find out/pane t1
^-show out
^-wait 1
^-append out/pane t2
^-show out
^-wait 1
^-unview

}
] 
show-popup [[view face request] [show hide-popup] {

Show a popup window.

}
] 
sign? [[math comparison] [abs negate] {

The SIGN? function returns a positive, zero, or negative integer
based on the sign of its argument.

^-print sign? 1000

^-print sign? 0

^-print sign? -1000

The sign is returned as an integer to allow it to be used
as a multiplication term within an expression:

^-val: -5
^-new: 2000 * sign? val
^-print new

^-size: 20
^-num: -30
^-if size > 10 [xy: 10x20 * sign? num]
^-print xy

}
] 
sine [[math] [arccosine arcsine arctangent cosine pi tangent] {

Ratio between the length of the opposite side to the
length of the hypotenuse of a right triangle.

^-print sine 90

^-print (sine 45) = (cosine 45)

^-print sine/radians pi

}
] 
sixth [[series string] [first second third pick] {

See the FIRST function for examples.

An error will occur if no value is found. Use the PICK function to avoid this error.

}] 
sixth [[series string] [first second third pick] {

See the FIRST function for examples.

An error will occur if no value is found. Use the PICK function to avoid this error.

}] 
size-text [[view face] [show] {

Returns the xy size of face text. This function can be used to
determine the size of text in advance, allowing code to make
adjustments before displaying the text.

Note that the face does not need to be shown for this function
to work correctly.

^-f: make face [text: "Hello there"]
^-size-text f

}
] 
size? [[file] [modified? exists?] {

If the file or URL is a directory, it returns the number
of entries in the directory.

^-print size? %file.txt

}
] 
skip [[series string] [at index? next back] {

For example, SKIP series 1 is the same as NEXT. If skip
attempts to move beyond the head or tail it will be
stopped at the head or tail.

^-str: "REBOL"
^-print skip str 3

^-blk: [11 22 33 44 55]
^-print skip blk 3

}
] 
sort [[series string modify] [append change clear insert remove] {

If you are sorting records of a fixed size, you will
need to use the /SKIP refinement to specify how many
elements to ignore.

Normally sorting is not sensitive to character cases,
but you can make it sensitive with the /CASE refinement.

A /COMPARE function can be specified to perform the
comparison. This allows you to change the ordering of the
SORT.

Sorting will modify the series passed as the argument.

^-blk: [799 34 12 934 -24 0]
^-print sort blk

^-names: ["Fred" "fred" "FRED"]
^-print sort/case names

^-name-ages: [
^-^-"Larry" 45
^-^-"Curly" 50
^-^-"Mo" 42
^-]
^-print sort/skip name-ages 2

^-names: [
^-^-"Larry"
^-^-"Curly"
^-^-"Mo"
^-]
^-print sort/compare names func [a b] [a < b]

^-print sort "edcba"

The ALL refinement will force the entire record to be passed to
the compare function.  This is useful if you need to compare one
or more fields of a record while also doing a skip operation.

}
] 
source [[help function] [help ?] {

Displays the source code for a function by molding it in a
formatted manner from the internal loaded block strucures.
Only provides the source code to REBOL defined functions,
not native (machine code) functions.

This function is useful for learning how mezzanine (higher
level) functions are defined.

^-source source

If the function specified is a native, SOURCE returns the
function's argument specification.

^-source copy

}
] 
span? [[view face] [] {

This function examines all the faces that are provided in a
block, and returns the minimum and maximum positions that
includes all of those faces.  In other words this function
returns the rectangle that would enclose all of the faces
provided in the block.  This is useful if you want to create a
special rectangular area that encloses a set of faces.

This function returns a block that contains the coordinate pairs
of the upper left and lower right bounds.

^-out: layout [h1 "Heading" button "Test"]
^-probe span? out/pane

}
] 
split-path [[port file string] [clean-path suffix?] {

Returns a block consisting of two elements, the path and the file.
Can be used on URLs and files alike.

^-probe split-path %tests/math/add.r

^-set [path file] split-path http://www.rebol.com/graphics/logo.gif
^-print path

^-print file

}
] 
square-root [[math] [exp log-10 log-2 log-e power] {

Returns the square-root of the number provided. If the
number is negative, an error will occur (which you can
trap with the TRY function).

^-print square-root 4

^-print square-root 2

}
] 
stats [[system help] [help trace] {

The STATS function returns a wide range of useful REBOL system
statistics, including information about memory usage, interpreter
cycles, and more.

If no refinement is provide, STATS returns the amount of memory
that it is using. This value must be computed from tables.

The /pools refinement returns information about the memory pools
that REBOL uses for managing its memory.

The /types refinement provides a summary of the number of each
datatype currently allocated by the system.

^-foreach [type num] stats/types [
^-^-print [type num]
^-]

The /series shows the number of series values, both string and
block oriented, as free space, etc.

The /frames provides the number of context frames used for objects
and functions.

The /recycle option summarizes garbage collection information.

The /evals provides counters for the number of interpreter cycles,
functions invoked, and blocks evaluated.

The /clear refinement can be used with the /evals refinement to clear
its counters.

^-stats/evals/clear
^-loop 100 [print "hello"]
^-print stats/evals

}] 
strict-equal? [[comparison] [== = <>] {

Strict equality requires the values to not differ by
datatype (so 1 would not be equal to 1.0) nor by
character casing (so "abc" would not be equal to "ABC").

^-print strict-equal? 123 123

}
] 
strict-not-equal? [[comparison] [<> = ==] {

A FALSE is returned if the values differ by datatype
(so 1 would not be equal to 1.0) nor by character casing
(so "abc" would not be equal to "ABC").

^-print strict-not-equal? 124 123

^-print strict-not-equal? 12-sep-98 10:30

}
] 
string! [[datatype] [string? make type?] {

Represents the STRING datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-str: make string! 20
^-insert str "hello"
^-print str

}
] 
string? [[datatype] [string! type?] {

Returns FALSE for all other values.

^-print string? "with all things considered"

^-print string? 123

}
] 
struct? [[datatype] [] {

Returns TRUE if the value is a STRUCT datatype.

}
] 
stylize [[view] [layout] {

This function allows you to define a set of face styles that can
be used in multiple layouts.  For instance, if you want to
define a standard style of text or a standard button style, you
can place it in a stylesheet using STYLIZE.  The stylesheet
can then be used in one or more layouts.

Each style is specified in a format that is similar to LAYOUT.
The STYLIZE function returns a stylesheet block that can be used
in a layout.

The code below defines a stylesheet that contains three styles:

^-text-styles: stylize [
^-^-big-text: text font-size 50
^-^-red-text: text red
^-^-bold-blue-text: text bold blue font-size 50
^-]

^-view layout [
^-^-styles text-styles
^-^-big-text "One big heading..."
^-^-red-text "This text will appear red."
^-^-bold-blue-text "This is big, bold, and blue."
^-]

Multiple stylesheets can be used in a layout.

The stylize function also allows you to modify the master styles
for your current REBOL session.  However, be careful, as all
scripts that are run after modifying the master stylesheet will
be affected.

}
] 
subtract [[math] [- + add absolute] {

When subtracting values of different datatypes the
values must be compatible.

^-print subtract 123 1

^-print subtract 1.2.3.4 1.0.3.0

^-print subtract 12:00 11:00

^-print subtract 1-Jan-2000 1

}
] 
suffix? [[file string] [find split-path] {

The SUFFIX? function can be used to obtain the file extention
(e.g. .exe, .txt, .jpg, etc.) that is part of a filename.

^-print suffix? %document.txt

^-print suffix? %program.exe

^-print suffix? %dir/path/doc.txt

^-print suffix? %file.type.r

^-print suffix? http://www.rebol.com/doc.txt

If there is no suffix, a NONE is returned:

^-print suffix? %filename

The suffix function can be used with any string datatype, but always
returns a FILE! datatype if the suffix was found.

^-print type? suffix? %file.txt

^-print type? suffix? "file.txt"

^-print type? suffix? http://www.rebol.com/file.txt

This was done to allow code such as:

^-url: http://www.rebol.com/docs.html
^-if find [%.txt %.html %.htm %.doc] suffix? url [
^-^-print [url "is a document file."]
^-]

}
] 
switch [[control] [select find] {

Switch also returns the value of the block it executes. The cases
can be any datatype. If none of the other cases match, use the
/DEFAULT refinement to specify a default case.

^-switch 22 [
^-^-11 [print "here"]
^-^-22 [print "there"]
^-]

^-person: 'mom
^-switch person [    ; words
^-^-dad [print "here"]
^-^-mom [print "there"]
^-^-kid [print "everywhere"]
^-]

^-file: %user.r
^-switch file [
^-^-%user.r [print "here"]
^-^-%rebol.r [print "everywhere"]
^-^-%file.r [print "there"]
^-]

^-url: ftp://ftp.rebol.org
^-switch url [  
^-^-http://www.rebol.com [print "here"]
^-^-http://www.cnet.com [print "there"]
^-^-ftp://ftp.rebol.org [print "everywhere"]
^-]

^-html-tag: <title>
^-print switch html-tag [
^-^-<pre>   ["preformatted text"]
^-^-<title> ["page title"]
^-^-<li>    ["bulleted list item"]
^-]

^-time: 12:30
^-switch time [
^-^- 8:00 [send wendy@domain.dom "Hey, get up"]
^-^-12:30 [send cindy@dom.dom "Join me for lunch."]
^-^-16:00 [send group@every.dom "Dinner anyone?"]
^-]

^-car: pick [Ford Chevy Dodge] random 3
^-print switch car [
^-^-Ford [351 * 1.4]
^-^-Chevy [454 * 5.3]
^-^-Dodge [154 * 3.5]
^-]

}
] 
system [[system] [REBOL object! object?] {

The system object used by the REBOL interpreter.  Most of
this is not for user modification.

For advanced discussion on system, see the Users Guide.

^-print system/version

^-print system/product

}
] 
tab [[constant string] [crlf newline] {

Use TAB as a shortcut to #"", the ASCII representation of 
a tab.

^-print ["there be" tab "tabs" tab "amongst" tab tab "us."]

}
] 
tag! [[datatype] [tag?] {

Represents the TAG datatype, both externally to the user
and internally within the system. When supplied as an
argument to the MAKE function, it specifies the type of
value to be created. When provided within the function's
argument specification, it requests the interpreter to
verify that the argument value is of the specified type
when the function is evaluated.

^-print make tag! "body"

^-print make tag! "/body"

}
] 
tag? [[datatype] [tag!] {

Returns FALSE for all other values.

^-print tag? <title>

^-print tag? "title"

}
] 
tail [[series string] [tail? head head?] {

Access to the tail allows insertion at the end of a
series (because insertion always occurs before the
specified element).

^-blk: copy [11 22 33]
^-insert tail blk [44 55 66]
^-print blk

}
] 
tail? [[series string] [empty? tail head head?] {

This function is the best way to detect the end of a
series while moving through it.

^-print tail? "string"

^-print tail? tail "string"

^-str: "Ok"
^-print tail? tail str

^-print tail? next next str

^-items: [oven sink stove blender]
^-while [not tail? items] [
^-^-print first items
^-^-items: next items
^-]

^-blk: [1 2]
^-print tail? tail blk

^-print tail? next next blk

}
] 
tangent [[math] [arccosine arcsine arctangent cosine pi tangent] {

Ratio between the length of the opposite side to
the length of the adjacent side of a right triangle.

^-print tangent 30

^-print tangent/radians 2 * pi

}
] 
tenth [[series string] [first second third pick] {

See the FIRST function for examples.

An error will occur if no value is found. Use the PICK function to avoid this error.

}] 
textinfo [[view face] [] {

This is a lower-level text mapping function. This is more of an
internal function that was created for text editing purposes, but
can be quite useful at times. (And notice that it is not named
according to standard REBOL function naming conventions - making it
more difficult to remember.)

The textinfo function provides text line information for the text
that is rendered in a face. The form of the function is:

^-result: textinfo face line-info line

The result is either none if the text cannot be rendered, or it is
the line-info object (when successful).

The function arguments are:

  face The face that specifies the text and its facets.  

  line-info A special text line object that is passed to the
  function and gets modified to hold the result. See details below.
  

  line The string index position or line number (zero based) to get
  information about.  

The line-info object is defined by system/view/line-info. It is set
by calling the textinfo function. It includes these fields:

  start Offset of start of line in the string (string!)  

  num-chars Number of chars in the line (integer!)  

  offset XY position of the line (pair!)  

  size Width and height of the line (pair!)  


}] 
third [[series string] [first second fourth fifth pick] {

An error will occur if no value is found. Use the PICK
function to avoid this error.

^-print third "REBOL"

^-print third [11 22 33 44 55 66]

^-print third 12-jun-1999

^-print third 199.4.80.1

^-print third 12:34:56.78

}
] 
throw [[control function] [catch return exit] {

CATCH and THROW go together. They provide a method of
exiting from a block without evaluating the rest of the
block. To use it, provide CATCH with a block to
evaluate. If within that block a THROW is evaluated,
the script will return from the CATCH at that point. The
result of the CATCH will be the value that was passed as
the argument to the THROW. When using multiple CATCH
functions, provide them with a name to identify which
one will CATCH which THROW.

^-print catch [
^-^-if exists? %file.txt [throw "Doc file!"]
^-]

}
] 
throw-on-error [[internal] [] {

Internal REBOL word.

}] 
time! [[datatype] [time? make type?] {

Represents the TIME datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-time: make time! [5 30 15] ;hour min sec
^-print time

}
] 
time? [[datatype] [time! type?] {

Returns FALSE for all other values.

^-print time? 12:00

^-print time? 123

}
] 
to [[datatype] [make] {

Every datatype provides a TO method to allow conversions from
other datatypes. The to-binary, to-block, and all other to-
functions are mezzanine functions that are based on this TO
function.

Here are a few examples:

^-probe to file! "test.r"

^-probe to list! [1 2 3]

The TO function lets the target datatype be specified as an
argument, allowing you to write code such as:

^-flag: true
^-value: to either flag [integer!][decimal!] 123
^-print value

The conversions that are allowed depend on the specific
datatype. Some datatypes allow special conversions, such as:

^-print to integer! false

^-print to integer! true

^-print to logic! 1

^-print to time! 600  ; # of seconds

}
] 
to-binary [[datatype] [to binary!] {

Returns a binary! value made from the given value.

^-probe to-binary "123456"

}
] 
to-bitset [[datatype] [to bitset!] {

Returns a bitset! value made from the given value.

^-probe to-bitset [#"a" - #"z" #"A" - #"Z"]

}
] 
to-block [[datatype] [to block!] {

Returns a block! value made from the given value.

^-print to-block "123 10:30"

}
] 
to-char [[datatype] [to char!] {

Returns a char! value made from the given value.

^-print to-char "a"

^-print to-char 65

}
] 
to-datatype [[datatype] [make to datatype!] {

Returns a datatype! value made from the given value.

^-probe to-datatype "REBOL"

}
] 
to-date [[datatype] [to date!] {

Returns a date! value made from the given value.

^-print to-date "12-April-1999"

}
] 
to-decimal [[datatype] [to decimal!] {

Returns a decimal! value made from the given value.

^-print to-decimal 12.3

}
] 
to-email [[datatype] [to email!] {

Returns an email! value made from the given value.

^-print to-email [luke rebol.com]

}
] 
to-error [[datatype] [make to error!] {

Returns an error! value made from the given value.

^-probe disarm try [to-error "Oops! My error."]

Note that this differs from TO and MAKE in that you
have to wrap the call in a TRY block to catch the
error it makes.

}
] 
to-file [[datatype] [to file!] {

Returns a file! value made from the given value.

^-print to-file ask "What file would you like to create? "

}
] 
to-get-word [[datatype] [to get-word!] {

Returns a get-word! value made from the given value.

^-probe to-get-word "test"

}
] 
to-hash [[datatype] [to hash!] {

Returns a hash! value made from the given value.

^-test-hash: to-hash [Bob Tina Fred Sandra Linda]
^-probe find test-hash 'Fred

}
] 
to-hex [[datatype] [to-integer] {

The TO-HEX function provides an easy way to convert an integer to
a hexidecimal value.

^-print to-hex 123

The value returned is a string of the ISSUE datatype (not the BINARY
datatype). This allows you to convert hex values back to integers:

^-print to-integer #7B

Note: To convert HTML hex color values (like #80FF80) to REBOL
color values, it is easier to do the conversion to binary and
then use a base 16 encoding:

^-to-html-color: func [color [tuple!]] [
^-^-to-issue enbase/base to-binary color 16
^-]
^-print to-html-color 255.155.50

The TO-ISSUE function is just used to add the # to it.

To convert from an HTML color back to a REBOL color tuple, you
can use this:

^-to-rebol-color: func [color [issue!]] [
^-^-to-tuple debase/base color 16
^-]
^-to-rebol-color #FF9B32

If the HTML color value is a string, convert it to an issue first.
The function below will work for strings and issues:

^-to-rebol-color2: func [color [string! issue!]] [
^-^-if string? color [
^-^-^-if find/match color "#" [color: next color]
^-^-^-color: to-issue color
^-^-]
^-^-to-tuple debase/base color 16
^-]
^-to-rebol-color2 "#FF9B32"

}
] 
to-idate [[datatype] [date! date?] {

Internet date format is day, date, month, year, time
(24-hour clock), timezone offset from GMT.

^-print to-idate now

}
] 
to-image [[datatype] [to image!] {

This is a special conversion function that is used for
converting a FACE object (such as those created by the layout
function) into an image bitmap in memory.

For example, the code below converts the OUT layout to a bitmap
image, then writes it out as a PNG file:

^-out: layout [
^-^-h2 "Title"
^-^-field
^-^-button "Done"
^-]
^-image: to-image out
^-save/png %test-image.png image

This function provides a useful way to save REBOL generated
images for use in other programs or web pages (which also allows
you to print the images). For example, you can display the image
above in a web browser with this code:

^-write %test-page.html trim/auto {
^-^-<html><body>
^-^-<h2>Image:</h2>
^-^-<img src="test-image.png">
^-^-</body></html>
^-}
^-browse %test-page.html

}
] 
to-integer [[datatype] [to to-hex integer!] {

Returns an integer! value made from the given value.

^-print to-integer "123"

^-print to-integer 123.9

^-print to-integer #"A" ; convert to the character value

^-print to-integer #102030 ; convert hex value (see to-hex for info)
}
] 
to-issue [[datatype] [to to-hex issue!] {

Returns an issue! value made from the given value.

^-print to-issue "1234-56-7890"

To convert HTML RGB color values (that look like #000000), see
the to-hex function.

}
] 
to-itime [[datatype] [make to time! to-idate] {

Returns an HH:MM:SS formatted time value.

^-probe to-itime now/time

}
] 
to-library [[datatype] [make to load library!] {

Returns a library value made from the given value.

^-probe to-library %kernel32.dll

}
] 
to-list [[datatype] [to list!] {

Returns a list! value made from the given value.

^-test-list: to-list [Bob Tina Fred Sandra Linda]
^-insert next test-list "Alice"
^-probe test-list

}
] 
to-lit-path [[datatype] [to] {

Returns a lit-path! value made from the given value.

^-probe to-lit-path [a b c]

}
] 
to-lit-word [[datatype] [to lit-word!] {

Returns a ilt-word! value made from the given value.

^-probe to-lit-word "test"

}
] 
to-local-file [[file] [to-rebol-file] {

This function provides a way to convert standard, system
independent REBOL file formats into the file format used by
the local operating system.

^-probe to-local-file %/c/temp

^-probe to-local-file what-dir

Note that the format of the file path depends on your local
system. Be careful how you use this function across systems.

}
] 
to-logic [[datatype] [to logic!] {

Returns a logic! value made from the given value.

^-print to-logic 1
^-print to-logic 0

}
] 
to-money [[datatype] [to money!] {

Returns a money! value made from the given value.

^-print to-money 123.4

^-print to-money [AUS 123.4]

}
] 
to-none [[internal] [make to none!] {

Returns a none! value made from the given value.

^-probe to-none "REBOL"

This function is not of significant use. It is automatically
generated by the system for reasons of completion.
}
] 
to-pair [[datatype] [to as-pair pair! pair?] {

Returns a pair! value made from the given value.

^-print to-pair [120 50]

^-x: 100
^-y: 80
^-print to-pair reduce [x y]

This last line is done so often that the AS-PAIR function was
created.

See the PAIR! word for more detail.
}
] 
to-paren [[datatype] [to paren!] {

Returns a paren! value made from the given value.

^-print to-paren "123 456"

}
] 
to-path [[datatype] [to path!] {

Returns a path! value made from the given value.

^-colors: make object! [reds: ["maroon" "brick" "sunset"]]
^-p-reds: to-path [colors reds]
^-print form :p-reds

^-print p-reds

^-insert tail p-reds "bright"
^-print colors/reds

^-print p-reds

}
] 
to-port [[datatype] [make to port!] {

Returns a port! value made from the given value.

^-probe to-port [scheme: 'checksum]

}
] 
to-rebol-file [[file] [to-local-file] {

This function provides a standard way to convert local operating
system files into REBOL's standard machine independent format.

^-probe to-rebol-file "c:\temp"

^-probe to-rebol-file "e:\program files\rebol"

Note that the format of the file path depends on your local
system. Be careful how you use this function across systems.

}
] 
to-refinement [[datatype] [to refinement!] {

Returns a refinement! value made from the given value.

^-probe to-refinement 'REBOL

}
] 
to-set-path [[datatype] [to set-path!] {

Returns a set-path! value made from the given value.

^-colors: make object! [blues: ["sky" "sea" "midnight"]]
^-ps-blues: to-set-path [colors blues]
^-print form :ps-blues

^-print ps-blues

^-ps-blues compose [(ps-blues) "light"]
^-print colors/blues

^-print ps-blues

}
] 
to-set-word [[datatype] [to set-word!] {

Returns a set-word! value made from the given value.

^-probe to-set-word "test"

}
] 
to-string [[datatype] [to string!] {

Returns a string! value made from the given value.

^-print to-string [123 456]

}
] 
to-tag [[datatype] [to tag!] {

Returns a tag! value made from the given value.

^-print to-tag ";comment:"

}
] 
to-time [[datatype] [to time!] {

Returns a time! value made from the given value.

^-print to-time 75
^-
Integer values are interpreted as a number of seconds.

A block may contain up to three values. The first two must be 
integers, and correspond to the hour and minute values. The
third value can be an integer or decimal value, and corresponds
to the number of seconds.

}
] 
to-tuple [[datatype] [to to-hex tuple!] {

Returns a tuple! value made from the given value.

^-print to-tuple [12 34 56]

To convert REBOL RGB color tuples to HTML hex color values, see
the to-hex function.

Tuples can have up to 10 segments.

}
] 
to-url [[datatype] [to url!] {

Returns a url! value made from the given value.

^-print to-url "info@rebol.com"

}
] 
to-word [[datatype] [to word!] {

Returns a word! value made from the given value.

^-print to-word "test"

}
] 
trace [[help] [echo probe] {

Used for debugging a script. TRACE ON turns it on. TRACE
OFF turns it off. To limit the amount of output
selective place trace around the parts of the script
that need it. TRACE/NET allows watching what the
network protocols are doing.

}
] 
trim [[string modify] [parse remove clear trim-last] {

The default for TRIM is to remove whitespace characters (tabs
and spaces) from the heads and tails of every line of a string.

^-str: "  string   "
^-probe trim str

When a string includes multiple lines, the head and tail
whitespace will be trimmed from each line (but not within the
line):

^-str: {
^-^-Now is the winter
^-^-of our discontent
^-^-made glorious summer
^-^-by this sun of York.
^-}
^-probe trim str

The final line terminator is preserved.

Note that TRIM modifies the string in the process.

^-str: "  string   "
^-trim str
^-probe str

TRIM does not copy the string. If that's what you want, then use
TRIM with COPY to copy the string before trimming it.

Several refinements to TRIM are available. To trim just the head
and/or tail of a string you can use the /HEAD or /TAIL refinements.

^-probe trim/head "  string  "

^-probe trim/tail "  string  "

^-probe trim/head/tail "  string  "

When using /HEAD or /TAIL, multiple lines are not affected:

^-probe trim/head {  line 1
^-^-line 2
^-^-line 3
^-}

To trim just the head and tail of a multiline string, but none
of its internal spacing:

^-str: {  line 1
^-^-line 2
^-^-^-line 3
^-^-^-^-line 4
^-^-^-^-^-line 5  }
^-probe trim/head/tail str

If you use TRIM/LINES then all lines and extra spaces will be
removed from the text. This is useful for word wrapping and web
page kinds of applications.

^-str: {
^-^-Now   is
^-^-the
^-^-winter
^-}
^-probe trim/lines str

You can also remove /ALL space:

^-probe trim/all " Now is   the winter "

^-str: {
^-^-Now   is
^-^-the
^-^-winter
^-}
^-probe trim/all str

One of the most useful TRIM refinements is /AUTO which will do a
"smart" trim of the indentation of text lines. This mode detects
the indentation from the first line and preserves indentation
for the lines to follow:

^-probe trim/auto {
^-^-line 1
^-^-^-line 2
^-^-^-line 3
^-^-^-^-line 4
^-^-line 5
^-}

This is useful for sections of text that are embedded within
code and indented to the level of the code.

To trim other characters, the /WITH refinement is provided.
It takes an additional string that specifies what characters
to be removed.

^-str: {This- is- a- line.}
^-probe trim/with str "-"

^-str: {This- is- a- line.}
^-probe trim/with str "- ."
}
] 
true [[constant] [false yes no on off] {

Returns the LOGIC value for TRUE. Synonyms are YES, ON.

^-if true [print "of course"]

}
] 
try [[control] [error? disarm do] {

TRY provides a useful means of capturing errors and
handling them within a script. For instance, use TRY to
test an expression that could fail and stop the script.
TRY returns an error value if an error happened,
otherwise it returns the normal result of the block.

^-if error? try [1 + "x"] [print "Did not work."]

^-if error? try [load "$10,20,30"] [print "No good"]

}
] 
tuple! [[datatype] [tuple? make type?] {

Represents the TUPLE datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-print make tuple! [10 30 40 50]

}
] 
tuple? [[datatype] [tuple! type?] {

Returns FALSE for all other values.

^-print tuple? 1.2.3.4

^-version: 0.1.0
^-if tuple? version [print version]

}
] 
type? [[datatype] [
        make none? logic? integer? decimal? money? tuple? time? 
        date? character? string? email? file? url? issue? word? 
        block? paren? path? native? function? object? port?
    ] {

To check for a single datatype, use its datatype test
function (e.g. string?, time?) The /WORD refinement
returns the type as a word so you can use if for FIND,
SELECT, SWITCH, and other functions.

^-print type? 10

^-print type? :type?

^-value: 10:30
^-print switch type?/word value [
^-^-integer! [value + 10]
^-^-decimal! [to-integer value]
^-^-time! [value/hour]
^-^-date! [first value/time]
^-]

}
] 
unfocus [[view face] [focus] {

Removes the focus from the current focal face.  The face was
previously specified with the FOCUS function to set it as the
focal point for input events. If the face had text highlighted,
the highlighting is cleared.

^-out: layout [
^-^-h2 "Input your info:"
^-^-f1: field
^-^-button "Unfocus" [unfocus]
^-^-button "Close" [unview]
^-]
^-focus f1
^-view out

Setting FOCUS to NONE is equivalent to UNFOCUS:

^-focus none

If UNFOCUS is called when there is no focal face, it will be
ignored.

}
] 
uninstall [[system] [install] {

Invokes the uninstall process. This is a quick way to uninstall
REBOL/View if you need to.

}
] 
union [[sets series string] [difference intersect exclude unique] {

Returns all elements present within two blocks or strings 
ignoring the duplicates.

^-lunch: [ham cheese bread carrot]
^-dinner: [ham salad carrot rice]
^-probe union lunch dinner

^-probe sort union [1 3 2 4] [3 5 4 6]

^-string1: "CBDA"    ; A B C D scrambled
^-string2: "EDCF"    ; C D E F scrambled
^-probe sort union string1 string2

^-items: [1 1 2 3 2 4 5 1 2]
^-probe union items items  ; get unique set

^-str: "abcacbaabcca"
^-probe union str str

To obtain a unique set (to remove duplicate values)
you can use UNIQUE.

Note that performing this function over very large
data sets can be CPU intensive.

}
] 
unique [[sets series string] [intersect union difference exclude] {

Removes all duplicate values from a set or series:

^-lunch: [ham cheese bread carrot ham ham carrot]
^-probe unique lunch

^-probe unique [1 3 2 4 3 5 4 6]

^-string: "CBADEDCF"
^-probe unique string

Note that performing this function over very large
data sets can be CPU intensive.

}
] 
unless [[control] [if either] {

UNLESS is equivalent to IF NOT. It has been provided to make PERL
programmers happier.

^-unless now/time > 12:00 [print "It's still morning"]

}] 
unlight-text [[internal] [hilight-all hilight-text] {

De-selects the currently selected text the active face.

}
] 
unprotect [[system] [protect] {

Unlocks a word locked with PROTECT so its value may be 
modified.

^-test: "I'm protected, no-one may change me!"
^-protect 'test
^-if error? try [test: "Trying to change test..."] [
^-^-print "Couldn't change test!"
^-]

^-unprotect 'test
^-either error? try [test: "Trying to change test..."] [
^-^-print "Couldn't change test!"
^-][
^-^-print "Changed test word"
^-]

}
] 
unset [[context] [set] {

Using UNSET, the word's current value will be lost. If
a block is specified, all the words within the block
will be unset.

^-test: "a value"
^-unset 'test
^-print value? 'test

}
] 
unset? [[datatype] [value? unset!] {

Returns TRUE if a value is UNSET. Normally you should
use VALUE? to test if a word has a value.

^-if unset? do [print "test"] [print "Nothing was returned"]

}
] 
until [[control] [while repeat for] {

Evaluates a block until the block returns a TRUE value
(that is, the last expression in the block is TRUE).

^-str: "string"
^-until [
^-^-print str
^-^-tail? str: next str
^-]

}
] 
unview [[view face] [view show hide flash inform] {

The UNVIEW function is used to close a window previously opened
with the VIEW function. By default, the last window that has
been opened will be closed.  To close a specific window, use the
/only refinement and specify the window's face (that which was
returned from a layout, for example).  All windows can be closed
with the /all refinement.

The example below opens a window that displays a Close button.
Clicking on the button will evaluate the UNVIEW function and the
window will be closed.

^-view layout [button "Close" [unview]]

Note that the VIEW function will not return until all windows
have been closed. (Use VIEW/new to return immediately after
the window is opened.)

The next example will open two windows, then use UNVIEW/only
to close each one separately.

^-out1: layout [button "Close 2" [unview out2]]
^-out2: layout [button "Close 1" [unview out1]]
^-view/new out1
^-view/new out2
^-do-events

You could have closed both windows with the line:

^-unview/all

}
] 
update [[port] [read write insert remove query] {

Updates the input or output of a port. If input is
expected, the port is checked for more input. If output
is pending then that output is written.

^-out: open/new %trash.me
^-insert out "this is a test"
^-update out
^-insert out "this is just a test"
^-close out

}
] 
upgrade [[system] [about license] {

Checks your version of REBOL against the latest released
version (requires a network connection) and prompts you
to download the latest version if your current version
is outdated. If your current version of REBOL is up to
date, this is indicated.

^-upgrade

}
] 
uppercase [[string modify] [lowercase trim] {

The series passed to this function is modified as a
result.

^-print uppercase "abcdef"

^-print uppercase/part "abcdef" 1

}
] 
url! [[datatype] [url? make type?] {

Represents the URL datatype, both externally to the user
and internally within the system. When supplied as an
argument to the MAKE function, it specifies the type of
value to be created. When provided within the function's
argument specification, it requests the interpreter to
verify that the argument value is of the specified type
when the function is evaluated.

^-print make url! "http://www.REBOL.com"

}
] 
url? [[datatype] [url! type?] {

Returns FALSE for all other values.

^-print url? http://www.REBOL.com

^-print url? "test"

}
] 
usage [[help] [help ?] {

Displays REBOL command line arguments, including
options and examples.

^-usage

SDK and special versions of REBOL may not include usage
information.

}
] 
use [[context function] [function! object!] {

The first block contains a list of words which will be
local to the second block. The second block will be
evaluated and its results returned from the USE.

^-total: 1234
^-nums: [123 321 456]
^-use [total] [
^-^-total: 0
^-^-foreach n nums [total: total + n]
^-^-print total
^-]

^-print total

Note: The USE function modifies the context (bindings) of the code
block (as if BIND was used on it). This can lead to problems for
recursive functions. To use the USE function recusively, you will
need to COPY/deep the code block first:

^-words: [a]
^-body: [print a * b]
^-use words copy/deep body

}
] 
value? [[context] [unset? equal? strict-equal? same?] {

Returns FALSE for all other values. The word can be
passed as a literal or as the result of other
operations.

^-test: 1234
^-print value? 'test

^-print value? second [test this]

}
] 
vbug [[internal] [] {

Internal REBOL word.

}] 
view [[view face] [unview hide show flash inform] {

The view function creates and updates windows. It takes a face
as its argument. The contents of the window is determined from a
face that holds  a block of the graphical objects. The window
face is normally created with the LAYOUT function, but faces can
be constructed directly from face objects and displayed as well.

The example below opens a window and displays some text and a
button.

^-view layout [
^-^-h2 "The time is currently:"
^-^-h3 form now
^-^-button "Close" [unview]
^-]

The position and size of the window is determined from the  face
to be displayed.  In the example above, the size of the window
is automatically computed by the LAYOUT function. The window is
shown in the default position in the upper left area of the
screen.

The window's caption will be default be the title of the script
that is being run.  To provide a different caption, use the
/title refinement and a string.

^-view/title layout [h1 "Window"] "A Window"

The first use of view within an application is special. It
displays the window and initializes the graphical interface
system. Subsequent calls to VIEW update the window, they do not
create new windows unless the /new refinement is provided.

^-view layout [
^-^-button "Change" [
^-^-^-view layout [button "Stop" [unview]]
^-^-]
^-]

The first call to the VIEW function will not return immediately.
At that point your code becomes event driven, calling the
functions associated with various faces. While the first call to
VIEW remains active, any other calls to VIEW will return
immediately. The first call will return only after all windows
have been closed. 

Additionally, calls to view can specify options, such as whether
the window has borders and is resizable.  Single options are
provided as a word and multiple options are specified in a block.

^-out: layout [vh1 "This is a window."]
^-view/options out [resize no-title]

}
] 
view? [[view system] [view] {

Returns TRUE if you are running a graphics enabled version
of REBOL.

^-print view?

Note that this function may not be available in older versions
of  REBOL. To define a similar value add this to your code:

^-view?: value? 'layout

}
] 
viewed? [[view face] [view] {

This function provides an easy way to determine if a face is
currently shown.

^-out-face: layout [
^-^-h2 "Testing"
^-]
^-print viewed? out-face

^-view/new out-face
^-print viewed? out-face

^-unview

Note that if the face is off-screen or minimized this function
will still return TRUE.

}
] 
wait [[control port] [time! date!] {

If the value is a TIME, delay for that period. If the
value is a DATE (with time), wait until then. If the
value is an INTEGER or DECIMAL, wait that number of
seconds. If the value is a PORT, wait for an event from
that port. If a block is specified, wait for any of the
times or ports to occur. Return the port that caused
the wait to complete or return NONE if the timeout
occurred.

^-print now/time

^-wait 1
^-print now/time

^-wait 0:00:01
^-print now/time

}
] 
what [[help] [help ?] {

Lists in alphabetic order all the functions of REBOL and their
arguments. A useful summary for interactive programming.

Also see the HELP function, which allows searching for functions
by wildcard strings.

SDK and special versions of REBOL may not include usage
information.

}
] 
what-dir [[file] [change-dir make-dir list-dir] {

Returns the value of system/script/path, the default
directory for file operations.

^-print what-dir

}
] 
while [[control] [loop repeat for until] {

The first block will be executed each time, and if it returns
true the second block will be executed. Both blocks can include
any number of expressions.

^-str: "string"
^-while [not tail? str: next str] [
^-^-print ["length of" str "is" length? str]
^-]

The most common mistake is to forget to provide a block for the
first argument (the condition argument).

BREAK can be used to escape from the WHILE loop at any point.

}
] 
win-offset? [[view] [screen-offset?] {

For sub-faces--faces in panels or other faces--the offset facet of the face
only takes into account the most direct parent face, which makes sense. If
you need to know where a face is relative to the top-level face (its 
furthest ancestor), use this function.

}
] 
within? [[view] [] {

This function is used to determine if a point is within a
graphical area.  You provide the position of the point, the
upper left corner of the area, and the area's size.  The
function will return TRUE if the point is within that area, or
FALSE otherwise.

For example, this returns TRUE because the point 50x50 is within
the bounds of the area:

^-print within? 50x50 20x30 200x300

}
] 
word! [[datatype] [make type? word?] {

Represents the WORD datatype, both externally to the
user and internally within the system. When supplied as
an argument to the MAKE function, it specifies the type
of value to be created. When provided within the
function's argument specification, it requests the
interpreter to verify that the argument value is of the
specified type when the function is evaluated.

^-print make word! "test"

}
] 
word? [[datatype] [word! type?] {

Returns FALSE for all other values. To test for "word:",
":word", or "'word", use the SET?, GET?, and LITERAL?
functions.

^-print word? second [1 two "3"]

}
] 
write [[port file] [read open close load save file! url! form set-modes get-modes] {

WRITE is typically used to write a file to disk, but
many other operations, such as writing data to URLs and
ports, are possible. 

Normally a string or binary value is provided to this
function, but other types of data such as a number or a
time can be written. They will be converted to text.

The /BINARY refinement will write out data as its exact
representation. This is good for writing image, sound
and other binary data.

The /STRING refinement translates line terminators to
the operating system's line terminator. This behavior
is default.

The /APPEND refinement is useful logging purposes, as
it won't overwrite existing data.

The /LINES refinement can take a block of values and 
will write each value to a line. By default, WRITE will
write the block of values as a concatonated string of
formed values.

The /PART refinement will read the specified number of
elements from the data being written.
The /WITH refinement converts characters, or strings,
specified into line terminators.

See the User's Guide for more detailed explanation of
using READ and its refinements.

^-write %junkme.txt "This is a junk file."

^-write %datetime.txt now

^-write/binary %data compress "this is compressed data"

^-write %rebol-test-file.r "some text"
^-print read %rebol-test-file.r

^-write/append %rebol-test-file.r "some more text"
^-print read %rebol-test-file.r

^-write %rebol-test-file.r reduce ["the time is:" form now/time]
^-print read %rebol-test-file.r

^-write/lines %rebol-test-file.r reduce ["time is:" form now/time]
^-print read %rebol-test-file.r

^-write/part %rebol-test-file.r "this is the day!" 7
^-print read %rebol-test-file.r

}
] 
write-io [[port] [read-io] {

This function provides a low level method of writing data from a
port. For most code, this function should not be used because
the INSERT function is the proper method of writing data to a
port.

The primary difference between WRITE-IO and INSERT is that
WRITE-IO takes a maximum transfer length as one of its
arguments. Like the WRITE function of the C language, bytes are
transferred from the buffer up to the maximum length specified.
The length of the transfer is returned as a result, and it can
be zero (for nothing transferred), or even negative in the case
of some types of errors.

Here is a simple example of WRITE-IO on a file <B>(Note again:
this is a low level IO method; you should normally use the
series functions like COPY, INSERT, NEXT, etc. for reading and
writing to IO ports.)</B>

^-attempt [delete %testfile]
^-port: open/direct %testfile
^-buffer: "testing"
^-write-io port buffer 4
^-close port
^-probe read %testfile

}
] 
write-user [[internal] [save-user] {

See SAVE-USER for details.

}
] 
xor [[math logic] [and or not] {

For integers, each bit
is exclusively-or'd. For logic values, this is the
same as the not-equal function.

^-print 122 xor 1

^-print true xor false

^-print false xor false

^-print 1.2.3.4 xor 1.0.0.0

}
] 
xor~ [[internal] [and~ or~] {

The trampoline action function for XOR operator.

}
] 
yes [[constant] [true false on off no] {

Another word for LOGIC TRUE.

}
] 
zero [[constant] [zero? positive? negative?] {

Returns a zero.

^-a: zero

^-set [a b] zero
^-print zero? a

^-print b

}
] 
zero? [[math] [positive? negative?] {

Check the value of a word is zero.

^-print zero? 50

^-print zero? 0

}
]