REBOL []

all [
"All REBOL words"
{A complete list of all REBOL words.}
]

comparison [
	"Words used for comparison"

	{Used for math, logical, series, string, and other values
	where comparison makes sense.}
]

constant [
	"Constant definitions."
	"A few important constants. Not all constants are listed."
]

context [
	"Related to word values and their contexts."
]

control [
	"Evaluation, looping, conditionals, and more."
]

datatype [
	"Related to datatypes."
	{Includes datatype definitions, datatype tests, and datatype
	conversions.

	Also includes pseudotype tests (like ANY-FUNCTION or
	ANY-STRING.}
]

encryption [
	"Encryption and decryption related"
	{Note that most of these functions require REBOL/Command or REBOL/SDK.}
]

face [
	"Related to graphics faces."
	{A face is the primary graphics object in REBOL (comes from the
	word "interface"). The words in this category are used for
	creating, modifying, and accessing graphics faces.

	See the View category for other graphics system words.}
]

file [
	"File related operations."
]

function [
	"Function related"
	{These words are used for function definition and function related
	operations.}
]

help [
	"Help and debugging."
]

logic [
	"Logical operations."
]

math [
	"Mathematical operations."
]

modify [
	"Functions that modify their arguments."
	{These are important functions to point out
	because they modify their source arguments.}
]

port [
	"Ports related."
	{Used for networking, files, encryption, system access, and more.}
]

request [
	{Requestor and popup related.}
]

series [
	{Operations on series, including blocks and strings.}
	{See the strings category for other string-related functions.}
]

sets [
	"For datasets, including bitsets and blocks."
]

string [
	{Operations for string series.}
	{Includes general series functions but also special string-only
	types of functions.

	See SERIES for general series functions.
	}
]

system [
	{REBOL system related words.}
]

view [
	{REBOL/View graphics related words.}
	{These are the functions used for creating graphics, GUIs,
	windows, popups, faces, and more.}
]

internal [
	"Internal REBOL functions."
	{These words are used internally by REBOL and you should
	avoid them if you can.

	Some of these words may become obsolete and could be removed or
	redefined in future versions of REBOL.}
]

not-found [
	"Undocumented words."
	{These words are not currently described in the dictionary.
	We are working to add them.}
]