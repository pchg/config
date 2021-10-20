#!/bin/sh
# This is the standalone Tcl script of poImgview.tcl.
# This file is generated auto. from different Tcl package files.
# To find the start of the main Tcl file, search for:
# Original file: poImgview.tcl
# 
# The next line restarts using wish \
exec wish "$0" -- ${1+"$@"}

set PO_ONE_SCRIPT 1


############################################################################
# Original file: poExtlib/combobox.tcl
############################################################################

# Copyright (c) 1998-2002, Bryan Oakley
# All Rights Reservered
#
# Bryan Oakley
# oakley@bardo.clearlight.com
#
# combobox v2.2 September 22, 2002
#
# a combobox / dropdown listbox (pick your favorite name) widget 
# written in pure tcl
#
# this code is freely distributable without restriction, but is 
# provided as-is with no warranty expressed or implied. 
#
# thanks to the following people who provided beta test support or
# patches to the code (in no particular order):
#
# Scott Beasley     Alexandre Ferrieux      Todd Helfter
# Matt Gushee       Laurent Duperval        John Jackson
# Fred Rapp         Christopher Nelson
# Eric Galluzzo     Jean-Francois Moine
#
# A special thanks to Martin M. Hunt who provided several good ideas, 
# and always with a patch to implement them. Jean-Francois Moine, 
# Todd Helfter and John Jackson were also kind enough to send in some 
# code patches.
#
# ... and many others over the years.

package require Tk 8.0
package provide poExtlib 1.0
package provide combobox 2.2

namespace eval ::combobox {

    # this is the public interface
    namespace export combobox

    # these contain references to available options
    variable widgetOptions

    # these contain references to available commands and subcommands
    variable widgetCommands
    variable scanCommands
    variable listCommands
}

# ::combobox::combobox --
#
#     This is the command that gets exported. It creates a new
#     combobox widget.
#
# Arguments:
#
#     w        path of new widget to create
#     args     additional option/value pairs (eg: -background white, etc.)
#
# Results:
#
#     It creates the widget and sets up all of the default bindings
#
# Returns:
#
#     The name of the newly create widget

proc ::combobox::combobox {w args} {
    variable widgetOptions
    variable widgetCommands
    variable scanCommands
    variable listCommands

    # perform a one time initialization
    if {![info exists widgetOptions]} {
	Init
    }

    # build it...
    eval Build $w $args

    # set some bindings...
    SetBindings $w

    # and we are done!
    return $w
}


# ::combobox::Init --
#
#     Initialize the namespace variables. This should only be called
#     once, immediately prior to creating the first instance of the
#     widget
#
# Arguments:
#
#    none
#
# Results:
#
#     All state variables are set to their default values; all of 
#     the option database entries will exist.
#
# Returns:
# 
#     empty string

proc ::combobox::Init {} {
    variable widgetOptions
    variable widgetCommands
    variable scanCommands
    variable listCommands
    variable defaultEntryCursor

    array set widgetOptions [list \
	    -background          {background          Background} \
	    -bd                  -borderwidth \
	    -bg                  -background \
	    -borderwidth         {borderWidth         BorderWidth} \
	    -command             {command             Command} \
	    -commandstate        {commandState        State} \
	    -cursor              {cursor              Cursor} \
	    -disabledbackground  {disabledBackground  DisabledBackground} \
	    -disabledforeground  {disabledForeground  DisabledForeground} \
            -dropdownwidth       {dropdownWidth       DropdownWidth} \
	    -editable            {editable            Editable} \
	    -fg                  -foreground \
	    -font                {font                Font} \
	    -foreground          {foreground          Foreground} \
	    -height              {height              Height} \
	    -highlightbackground {highlightBackground HighlightBackground} \
	    -highlightcolor      {highlightColor      HighlightColor} \
	    -highlightthickness  {highlightThickness  HighlightThickness} \
	    -image               {image               Image} \
	    -maxheight           {maxHeight           Height} \
	    -opencommand         {opencommand         Command} \
	    -relief              {relief              Relief} \
	    -selectbackground    {selectBackground    Foreground} \
	    -selectborderwidth   {selectBorderWidth   BorderWidth} \
	    -selectforeground    {selectForeground    Background} \
	    -state               {state               State} \
	    -takefocus           {takeFocus           TakeFocus} \
	    -textvariable        {textVariable        Variable} \
	    -value               {value               Value} \
	    -width               {width               Width} \
	    -xscrollcommand      {xScrollCommand      ScrollCommand} \
    ]


    set widgetCommands [list \
	    bbox      cget     configure    curselection \
	    delete    get      icursor      index        \
	    insert    list     scan         selection    \
	    xview     select   toggle       open         \
            close     \
    ]

    set listCommands [list \
	    delete       get      \
            index        insert       size \
    ]

    set scanCommands [list mark dragto]

    # why check for the Tk package? This lets us be sourced into 
    # an interpreter that doesn't have Tk loaded, such as the slave
    # interpreter used by pkg_mkIndex. In theory it should have no
    # side effects when run 
    if {[lsearch -exact [package names] "Tk"] != -1} {

	##################################################################
	#- this initializes the option database. Kinda gross, but it works
	#- (I think). 
	##################################################################

	# the image used for the button...
	if {$::tcl_platform(platform) == "windows"} {
	    image create bitmap ::combobox::bimage -data {
		#define down_arrow_width 12
		#define down_arrow_height 12
		static char down_arrow_bits[] = {
		    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		    0xfc,0xf1,0xf8,0xf0,0x70,0xf0,0x20,0xf0,
		    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00;
		}
	    }
	} else {
	    image create bitmap ::combobox::bimage -data  {
		#define down_arrow_width 15
		#define down_arrow_height 15
		static char down_arrow_bits[] = {
		    0x00,0x80,0x00,0x80,0x00,0x80,0x00,0x80,
		    0x00,0x80,0xf8,0x8f,0xf0,0x87,0xe0,0x83,
		    0xc0,0x81,0x80,0x80,0x00,0x80,0x00,0x80,
		    0x00,0x80,0x00,0x80,0x00,0x80
		}
	    }
	}

	# compute a widget name we can use to create a temporary widget
	set tmpWidget ".__tmp__"
	set count 0
	while {[winfo exists $tmpWidget] == 1} {
	    set tmpWidget ".__tmp__$count"
	    incr count
	}

	# get the scrollbar width. Because we try to be clever and draw our
	# own button instead of using a tk widget, we need to know what size
	# button to create. This little hack tells us the width of a scroll
	# bar.
	#
	# NB: we need to be sure and pick a window  that doesn't already
	# exist... 
	scrollbar $tmpWidget
	set sb_width [winfo reqwidth $tmpWidget]
	destroy $tmpWidget

	# steal options from the entry widget
	# we want darn near all options, so we'll go ahead and do
	# them all. No harm done in adding the one or two that we
	# don't use.
	entry $tmpWidget 
	foreach foo [$tmpWidget configure] {
	    # the cursor option is special, so we'll save it in
	    # a special way
	    if {[lindex $foo 0] == "-cursor"} {
		set defaultEntryCursor [lindex $foo 4]
	    }
	    if {[llength $foo] == 5} {
		set option [lindex $foo 1]
		set value [lindex $foo 4]
		option add *Combobox.$option $value widgetDefault

		# these options also apply to the dropdown listbox
		if {[string compare $option "foreground"] == 0 \
			|| [string compare $option "background"] == 0 \
			|| [string compare $option "font"] == 0} {
		    option add *Combobox*ComboboxListbox.$option $value \
			    widgetDefault
		}
	    }
	}
	destroy $tmpWidget

	# these are unique to us...
	option add *Combobox.dropdownWidth       {}     widgetDefault
	option add *Combobox.openCommand         {}     widgetDefault
	option add *Combobox.cursor              {}     widgetDefault
	option add *Combobox.commandState        normal widgetDefault
	option add *Combobox.editable            1      widgetDefault
	option add *Combobox.maxHeight           10     widgetDefault
	option add *Combobox.height              0
    }

    # set class bindings
    SetClassBindings
}

# ::combobox::SetClassBindings --
#
#    Sets up the default bindings for the widget class
#
#    this proc exists since it's The Right Thing To Do, but
#    I haven't had the time to figure out how to do all the
#    binding stuff on a class level. The main problem is that
#    the entry widget must have focus for the insertion cursor
#    to be visible. So, I either have to have the entry widget
#    have the Combobox bindtag, or do some fancy juggling of
#    events or some such. What a pain.
#
# Arguments:
#
#    none
#
# Returns:
#
#    empty string

proc ::combobox::SetClassBindings {} {

    # make sure we clean up after ourselves...
    bind Combobox <Destroy> [list ::combobox::DestroyHandler %W]

    # this will (hopefully) close (and lose the grab on) the
    # listbox if the user clicks anywhere outside of it. Note
    # that on Windows, you can click on some other app and
    # the listbox will still be there, because tcl won't see
    # that button click
    set this {[::combobox::convert %W -W]}
    bind Combobox <Any-ButtonPress>   "$this close"
    bind Combobox <Any-ButtonRelease> "$this close"

    # this helps (but doesn't fully solve) focus issues. The general
    # idea is, whenever the frame gets focus it gets passed on to
    # the entry widget
    bind Combobox <FocusIn> {::combobox::tkTabToWindow [::combobox::convert %W -W].entry}

    # this closes the listbox if we get hidden
    bind Combobox <Unmap> {[::combobox::convert %W -W] close}

    return ""
}

# ::combobox::SetBindings --
#
#    here's where we do most of the binding foo. I think there's probably
#    a few bindings I ought to add that I just haven't thought
#    about...
#
#    I'm not convinced these are the proper bindings. Ideally all
#    bindings should be on "Combobox", but because of my juggling of
#    bindtags I'm not convinced thats what I want to do. But, it all
#    seems to work, its just not as robust as it could be.
#
# Arguments:
#
#    w    widget pathname
#
# Returns:
#
#    empty string

proc ::combobox::SetBindings {w} {
    upvar ::combobox::${w}::widgets  widgets
    upvar ::combobox::${w}::options  options

    # juggle the bindtags. The basic idea here is to associate the
    # widget name with the entry widget, so if a user does a bind
    # on the combobox it will get handled properly since it is
    # the entry widget that has keyboard focus.
    bindtags $widgets(entry) \
	    [concat $widgets(this) [bindtags $widgets(entry)]]

    bindtags $widgets(button) \
	    [concat $widgets(this) [bindtags $widgets(button)]]

    # override the default bindings for tab and shift-tab. The
    # focus procs take a widget as their only parameter and we
    # want to make sure the right window gets used (for shift-
    # tab we want it to appear as if the event was generated
    # on the frame rather than the entry. 
    bind $widgets(entry) <Tab> \
	    "::combobox::tkTabToWindow \[tk_focusNext $widgets(entry)\]; break"
    bind $widgets(entry) <Shift-Tab> \
	    "::combobox::tkTabToWindow \[tk_focusPrev $widgets(this)\]; break"
    
    # this makes our "button" (which is actually a label)
    # do the right thing
    bind $widgets(button) <ButtonPress-1> [list $widgets(this) toggle]

    # this lets the autoscan of the listbox work, even if they
    # move the cursor over the entry widget.
    bind $widgets(entry) <B1-Enter> "break"

    bind $widgets(listbox) <ButtonRelease-1> \
        "::combobox::Select [list $widgets(this)] \
         \[$widgets(listbox) nearest %y\]; break"

    bind $widgets(vsb) <ButtonPress-1>   {continue}
    bind $widgets(vsb) <ButtonRelease-1> {continue}

    bind $widgets(listbox) <Any-Motion> {
	%W selection clear 0 end
	%W activate @%x,%y
	%W selection anchor @%x,%y
	%W selection set @%x,%y @%x,%y
	# need to do a yview if the cursor goes off the top
	# or bottom of the window... (or do we?)
    }

    # these events need to be passed from the entry widget
    # to the listbox, or otherwise need some sort of special
    # handling. 
    foreach event [list <Up> <Down> <Tab> <Return> <Escape> \
	    <Next> <Prior> <Double-1> <1> <Any-KeyPress> \
	    <FocusIn> <FocusOut>] {
	bind $widgets(entry) $event \
            [list ::combobox::HandleEvent $widgets(this) $event]
    }

    # like the other events, <MouseWheel> needs to be passed from
    # the entry widget to the listbox. However, in this case we
    # need to add an additional parameter
    catch {
	bind $widgets(entry) <MouseWheel> \
	    [list ::combobox::HandleEvent $widgets(this) <MouseWheel> %D]
    }
}

# ::combobox::Build --
#
#    This does all of the work necessary to create the basic
#    combobox. 
#
# Arguments:
#
#    w        widget name
#    args     additional option/value pairs
#
# Results:
#
#    Creates a new widget with the given name. Also creates a new
#    namespace patterened after the widget name, as a child namespace
#    to ::combobox
#
# Returns:
#
#    the name of the widget

proc ::combobox::Build {w args } {
    variable widgetOptions

    if {[winfo exists $w]} {
	error "window name \"$w\" already exists"
    }

    # create the namespace for this instance, and define a few
    # variables
    namespace eval ::combobox::$w {

	variable ignoreTrace 0
	variable oldFocus    {}
	variable oldGrab     {}
	variable oldValue    {}
	variable options
	variable this
	variable widgets

	set widgets(foo) foo  ;# coerce into an array
	set options(foo) foo  ;# coerce into an array

	unset widgets(foo)
	unset options(foo)
    }

    # import the widgets and options arrays into this proc so
    # we don't have to use fully qualified names, which is a
    # pain.
    upvar ::combobox::${w}::widgets widgets
    upvar ::combobox::${w}::options options

    # this is our widget -- a frame of class Combobox. Naturally,
    # it will contain other widgets. We create it here because
    # we need it in order to set some default options.
    set widgets(this)   [frame  $w -class Combobox -takefocus 0]
    set widgets(entry)  [entry  $w.entry -takefocus 1]
    set widgets(button) [label  $w.button -takefocus 0] 

    # this defines all of the default options. We get the
    # values from the option database. Note that if an array
    # value is a list of length one it is an alias to another
    # option, so we just ignore it
    foreach name [array names widgetOptions] {
	if {[llength $widgetOptions($name)] == 1} continue

	set optName  [lindex $widgetOptions($name) 0]
	set optClass [lindex $widgetOptions($name) 1]

	set value [option get $w $optName $optClass]
	set options($name) $value
    }

    # a couple options aren't available in earlier versions of
    # tcl, so we'll set them to sane values. For that matter, if
    # they exist but are empty, set them to sane values.
    if {[string length $options(-disabledforeground)] == 0} {
        set options(-disabledforeground) $options(-foreground)
    }
    if {[string length $options(-disabledbackground)] == 0} {
        set options(-disabledbackground) $options(-background)
    }

    # if -value is set to null, we'll remove it from our
    # local array. The assumption is, if the user sets it from
    # the option database, they will set it to something other
    # than null (since it's impossible to determine the difference
    # between a null value and no value at all).
    if {[info exists options(-value)] \
	    && [string length $options(-value)] == 0} {
	unset options(-value)
    }

    # we will later rename the frame's widget proc to be our
    # own custom widget proc. We need to keep track of this
    # new name, so we'll define and store it here...
    set widgets(frame) ::combobox::${w}::$w

    # gotta do this sooner or later. Might as well do it now
    pack $widgets(entry)  -side left  -fill both -expand yes
    pack $widgets(button) -side right -fill y    -expand no

    # I should probably do this in a catch, but for now it's
    # good enough... What it does, obviously, is put all of
    # the option/values pairs into an array. Make them easier
    # to handle later on...
    array set options $args

    # now, the dropdown list... the same renaming nonsense
    # must go on here as well...
    set widgets(dropdown)   [toplevel  $w.top]
    set widgets(listbox) [listbox   $w.top.list]
    set widgets(vsb)     [scrollbar $w.top.vsb]

    pack $widgets(listbox) -side left -fill both -expand y

    # fine tune the widgets based on the options (and a few
    # arbitrary values...)

    # NB: we are going to use the frame to handle the relief
    # of the widget as a whole, so the entry widget will be 
    # flat. This makes the button which drops down the list
    # to appear "inside" the entry widget.

    $widgets(vsb) configure \
	    -command "$widgets(listbox) yview" \
	    -highlightthickness 0

    $widgets(button) configure \
	    -highlightthickness 0 \
	    -borderwidth 1 \
	    -relief raised \
	    -width [expr {[winfo reqwidth $widgets(vsb)] - 2}]

    $widgets(entry) configure \
	    -borderwidth 0 \
	    -relief flat \
	    -highlightthickness 0 

    $widgets(dropdown) configure \
	    -borderwidth 1 \
	    -relief sunken

    $widgets(listbox) configure \
	    -selectmode browse \
	    -background [$widgets(entry) cget -bg] \
	    -yscrollcommand "$widgets(vsb) set" \
	    -exportselection false \
	    -borderwidth 0


#    trace variable ::combobox::${w}::entryTextVariable w \
#	    [list ::combobox::EntryTrace $w]
	
    # do some window management foo on the dropdown window
    wm overrideredirect $widgets(dropdown) 1
    wm transient        $widgets(dropdown) [winfo toplevel $w]
    wm group            $widgets(dropdown) [winfo parent $w]
    wm resizable        $widgets(dropdown) 0 0
    wm withdraw         $widgets(dropdown)
    
    # this moves the original frame widget proc into our
    # namespace and gives it a handy name
    rename ::$w $widgets(frame)

    # now, create our widget proc. Obviously (?) it goes in
    # the global namespace. All combobox widgets will actually
    # share the same widget proc to cut down on the amount of
    # bloat. 
    proc ::$w {command args} \
        "eval ::combobox::WidgetProc $w \$command \$args"


    # ok, the thing exists... let's do a bit more configuration. 
    if {[catch "::combobox::Configure [list $widgets(this)] [array get options]" error]} {
	catch {destroy $w}
	error "internal error: $error"
    }

    return ""

}

# ::combobox::HandleEvent --
#
#    this proc handles events from the entry widget that we want
#    handled specially (typically, to allow navigation of the list
#    even though the focus is in the entry widget)
#
# Arguments:
#
#    w       widget pathname
#    event   a string representing the event (not necessarily an
#            actual event)
#    args    additional arguments required by particular events

proc ::combobox::HandleEvent {w event args} {
    upvar ::combobox::${w}::widgets  widgets
    upvar ::combobox::${w}::options  options
    upvar ::combobox::${w}::oldValue oldValue

    # for all of these events, if we have a special action we'll
    # do that and do a "return -code break" to keep additional 
    # bindings from firing. Otherwise we'll let the event fall
    # on through. 
    switch $event {

        "<MouseWheel>" {
	    if {[winfo ismapped $widgets(dropdown)]} {
                set D [lindex $args 0]
                # the '120' number in the following expression has
                # it's genesis in the tk bind manpage, which suggests
                # that the smallest value of %D for mousewheel events
                # will be 120. The intent is to scroll one line at a time.
                $widgets(listbox) yview scroll [expr {-($D/120)}] units
            }
        } 

	"<Any-KeyPress>" {
	    # if the widget is editable, clear the selection. 
	    # this makes it more obvious what will happen if the 
	    # user presses <Return> (and helps our code know what
	    # to do if the user presses return)
	    if {$options(-editable)} {
		$widgets(listbox) see 0
		$widgets(listbox) selection clear 0 end
		$widgets(listbox) selection anchor 0
		$widgets(listbox) activate 0
	    }
	}

	"<FocusIn>" {
	    set oldValue [$widgets(entry) get]
	}

	"<FocusOut>" {
	    if {![winfo ismapped $widgets(dropdown)]} {
		# did the value change?
		set newValue [$widgets(entry) get]
		if {$oldValue != $newValue} {
		    CallCommand $widgets(this) $newValue
		}
	    }
	}

	"<1>" {
	    set editable [::combobox::GetBoolean $options(-editable)]
	    if {!$editable} {
		if {[winfo ismapped $widgets(dropdown)]} {
		    $widgets(this) close
		    return -code break;

		} else {
		    if {$options(-state) != "disabled"} {
			$widgets(this) open
			return -code break;
		    }
		}
	    }
	}

	"<Double-1>" {
	    if {$options(-state) != "disabled"} {
		$widgets(this) toggle
		return -code break;
	    }
	}

	"<Tab>" {
	    if {[winfo ismapped $widgets(dropdown)]} {
		::combobox::Find $widgets(this) 0
		return -code break;
	    } else {
		::combobox::SetValue $widgets(this) [$widgets(this) get]
	    }
	}

	"<Escape>" {
#	    $widgets(entry) delete 0 end
#	    $widgets(entry) insert 0 $oldValue
	    if {[winfo ismapped $widgets(dropdown)]} {
		$widgets(this) close
		return -code break;
	    }
	}

	"<Return>" {
	    # did the value change?
	    set newValue [$widgets(entry) get]
	    if {$oldValue != $newValue} {
		CallCommand $widgets(this) $newValue
	    }

	    if {[winfo ismapped $widgets(dropdown)]} {
		::combobox::Select $widgets(this) \
			[$widgets(listbox) curselection]
		return -code break;
	    } 

	}

	"<Next>" {
	    $widgets(listbox) yview scroll 1 pages
	    set index [$widgets(listbox) index @0,0]
	    $widgets(listbox) see $index
	    $widgets(listbox) activate $index
	    $widgets(listbox) selection clear 0 end
	    $widgets(listbox) selection anchor $index
	    $widgets(listbox) selection set $index

	}

	"<Prior>" {
	    $widgets(listbox) yview scroll -1 pages
	    set index [$widgets(listbox) index @0,0]
	    $widgets(listbox) activate $index
	    $widgets(listbox) see $index
	    $widgets(listbox) selection clear 0 end
	    $widgets(listbox) selection anchor $index
	    $widgets(listbox) selection set $index
	}

	"<Down>" {
	    if {[winfo ismapped $widgets(dropdown)]} {
		::combobox::tkListboxUpDown $widgets(listbox) 1
		return -code break;

	    } else {
		if {$options(-state) != "disabled"} {
		    $widgets(this) open
		    return -code break;
		}
	    }
	}
	"<Up>" {
	    if {[winfo ismapped $widgets(dropdown)]} {
		::combobox::tkListboxUpDown $widgets(listbox) -1
		return -code break;

	    } else {
		if {$options(-state) != "disabled"} {
		    $widgets(this) open
		    return -code break;
		}
	    }
	}
    }

    return ""
}

# ::combobox::DestroyHandler {w} --
# 
#    Cleans up after a combobox widget is destroyed
#
# Arguments:
#
#    w    widget pathname
#
# Results:
#
#    The namespace that was created for the widget is deleted,
#    and the widget proc is removed.

proc ::combobox::DestroyHandler {w} {

    # if the widget actually being destroyed is of class Combobox,
    # crush the namespace and kill the proc. Get it? Crush. Kill. 
    # Destroy. Heh. Danger Will Robinson! Oh, man! I'm so funny it
    # brings tears to my eyes.
    if {[string compare [winfo class $w] "Combobox"] == 0} {
	upvar ::combobox::${w}::widgets  widgets
	upvar ::combobox::${w}::options  options

	# delete the namespace and the proc which represents
	# our widget
	namespace delete ::combobox::$w
	rename $w {}
    }   

    return ""
}

# ::combobox::Find
#
#    finds something in the listbox that matches the pattern in the
#    entry widget and selects it
#
#    N.B. I'm not convinced this is working the way it ought to. It
#    works, but is the behavior what is expected? I've also got a gut
#    feeling that there's a better way to do this, but I'm too lazy to
#    figure it out...
#
# Arguments:
#
#    w      widget pathname
#    exact  boolean; if true an exact match is desired
#
# Returns:
#
#    Empty string

proc ::combobox::Find {w {exact 0}} {
    upvar ::combobox::${w}::widgets widgets
    upvar ::combobox::${w}::options options

    ## *sigh* this logic is rather gross and convoluted. Surely
    ## there is a more simple, straight-forward way to implement
    ## all this. As the saying goes, I lack the time to make it
    ## shorter...

    # use what is already in the entry widget as a pattern
    set pattern [$widgets(entry) get]

    if {[string length $pattern] == 0} {
	# clear the current selection
	$widgets(listbox) see 0
	$widgets(listbox) selection clear 0 end
	$widgets(listbox) selection anchor 0
	$widgets(listbox) activate 0
	return
    }

    # we're going to be searching this list...
    set list [$widgets(listbox) get 0 end]

    # if we are doing an exact match, try to find,
    # well, an exact match
    set exactMatch -1
    if {$exact} {
	set exactMatch [lsearch -exact $list $pattern]
    }

    # search for it. We'll try to be clever and not only
    # search for a match for what they typed, but a match for
    # something close to what they typed. We'll keep removing one
    # character at a time from the pattern until we find a match
    # of some sort.
    set index -1
    while {$index == -1 && [string length $pattern]} {
	set index [lsearch -glob $list "$pattern*"]
	if {$index == -1} {
	    regsub {.$} $pattern {} pattern
	}
    }

    # this is the item that most closely matches...
    set thisItem [lindex $list $index]

    # did we find a match? If so, do some additional munging...
    if {$index != -1} {

	# we need to find the part of the first item that is 
	# unique WRT the second... I know there's probably a
	# simpler way to do this... 

	set nextIndex [expr {$index + 1}]
	set nextItem [lindex $list $nextIndex]

	# we don't really need to do much if the next
	# item doesn't match our pattern...
	if {[string match $pattern* $nextItem]} {
	    # ok, the next item matches our pattern, too
	    # now the trick is to find the first character
	    # where they *don't* match...
	    set marker [string length $pattern]
	    while {$marker <= [string length $pattern]} {
		set a [string index $thisItem $marker]
		set b [string index $nextItem $marker]
		if {[string compare $a $b] == 0} {
		    append pattern $a
		    incr marker
		} else {
		    break
		}
	    }
	} else {
	    set marker [string length $pattern]
	}
	
    } else {
	set marker end
	set index 0
    }

    # ok, we know the pattern and what part is unique;
    # update the entry widget and listbox appropriately
    if {$exact && $exactMatch == -1} {
	# this means we didn't find an exact match
	$widgets(listbox) selection clear 0 end
	$widgets(listbox) see $index

    } elseif {!$exact}  {
	# this means we found something, but it isn't an exact
	# match. If we find something that *is* an exact match we
	# don't need to do the following, since it would merely 
	# be replacing the data in the entry widget with itself
	set oldstate [$widgets(entry) cget -state]
	$widgets(entry) configure -state normal
	$widgets(entry) delete 0 end
	$widgets(entry) insert end $thisItem
	$widgets(entry) selection clear
	$widgets(entry) selection range $marker end
	$widgets(listbox) activate $index
	$widgets(listbox) selection clear 0 end
	$widgets(listbox) selection anchor $index
	$widgets(listbox) selection set $index
	$widgets(listbox) see $index
	$widgets(entry) configure -state $oldstate
    }
}

# ::combobox::Select --
#
#    selects an item from the list and sets the value of the combobox
#    to that value
#
# Arguments:
#
#    w      widget pathname
#    index  listbox index of item to be selected
#
# Returns:
#
#    empty string

proc ::combobox::Select {w index} {
    upvar ::combobox::${w}::widgets widgets
    upvar ::combobox::${w}::options options

    # the catch is because I'm sloppy -- presumably, the only time
    # an error will be caught is if there is no selection. 
    if {![catch {set data [$widgets(listbox) get [lindex $index 0]]}]} {
	::combobox::SetValue $widgets(this) $data

	$widgets(listbox) selection clear 0 end
	$widgets(listbox) selection anchor $index
	$widgets(listbox) selection set $index

    }
    $widgets(entry) selection range 0 end

    $widgets(this) close

    return ""
}

# ::combobox::HandleScrollbar --
# 
#    causes the scrollbar of the dropdown list to appear or disappear
#    based on the contents of the dropdown listbox
#
# Arguments:
#
#    w       widget pathname
#    action  the action to perform on the scrollbar
#
# Returns:
#
#    an empty string

proc ::combobox::HandleScrollbar {w {action "unknown"}} {
    upvar ::combobox::${w}::widgets widgets
    upvar ::combobox::${w}::options options

    if {$options(-height) == 0} {
	set hlimit $options(-maxheight)
    } else {
	set hlimit $options(-height)
    }		    

    switch $action {
	"grow" {
	    if {$hlimit > 0 && [$widgets(listbox) size] > $hlimit} {
		pack $widgets(vsb) -side right -fill y -expand n
	    }
	}

	"shrink" {
	    if {$hlimit > 0 && [$widgets(listbox) size] <= $hlimit} {
		pack forget $widgets(vsb)
	    }
	}

	"crop" {
	    # this means the window was cropped and we definitely 
	    # need a scrollbar no matter what the user wants
	    pack $widgets(vsb) -side right -fill y -expand n
	}

	default {
	    if {$hlimit > 0 && [$widgets(listbox) size] > $hlimit} {
		pack $widgets(vsb) -side right -fill y -expand n
	    } else {
		pack forget $widgets(vsb)
	    }
	}
    }

    return ""
}

# ::combobox::ComputeGeometry --
#
#    computes the geometry of the dropdown list based on the size of the
#    combobox...
#
# Arguments:
#
#    w     widget pathname
#
# Returns:
#
#    the desired geometry of the listbox

proc ::combobox::ComputeGeometry {w} {
    upvar ::combobox::${w}::widgets widgets
    upvar ::combobox::${w}::options options
    
    if {$options(-height) == 0 && $options(-maxheight) != "0"} {
	# if this is the case, count the items and see if
	# it exceeds our maxheight. If so, set the listbox
	# size to maxheight...
	set nitems [$widgets(listbox) size]
	if {$nitems > $options(-maxheight)} {
	    # tweak the height of the listbox
	    $widgets(listbox) configure -height $options(-maxheight)
	} else {
	    # un-tweak the height of the listbox
	    $widgets(listbox) configure -height 0
	}
	update idletasks
    }

    # compute height and width of the dropdown list
    set bd [$widgets(dropdown) cget -borderwidth]
    set height [expr {[winfo reqheight $widgets(dropdown)] + $bd + $bd}]
    if {[string length $options(-dropdownwidth)] == 0 || 
        $options(-dropdownwidth) == 0} {
        set width [winfo width $widgets(this)]
    } else {
        set m [font measure [$widgets(listbox) cget -font] "m"]
        set width [expr {$options(-dropdownwidth) * $m}]
    }

    # figure out where to place it on the screen, trying to take into
    # account we may be running under some virtual window manager
    set screenWidth  [winfo screenwidth $widgets(this)]
    set screenHeight [winfo screenheight $widgets(this)]
    set rootx        [winfo rootx $widgets(this)]
    set rooty        [winfo rooty $widgets(this)]
    set vrootx       [winfo vrootx $widgets(this)]
    set vrooty       [winfo vrooty $widgets(this)]

    # the x coordinate is simply the rootx of our widget, adjusted for
    # the virtual window. We won't worry about whether the window will
    # be offscreen to the left or right -- we want the illusion that it
    # is part of the entry widget, so if part of the entry widget is off-
    # screen, so will the list. If you want to change the behavior,
    # simply change the if statement... (and be sure to update this
    # comment!)
    set x  [expr {$rootx + $vrootx}]
    if {0} { 
	set rightEdge [expr {$x + $width}]
	if {$rightEdge > $screenWidth} {
	    set x [expr {$screenWidth - $width}]
	}
	if {$x < 0} {set x 0}
    }

    # the y coordinate is the rooty plus vrooty offset plus 
    # the height of the static part of the widget plus 1 for a 
    # tiny bit of visual separation...
    set y [expr {$rooty + $vrooty + [winfo reqheight $widgets(this)] + 1}]
    set bottomEdge [expr {$y + $height}]

    if {$bottomEdge >= $screenHeight} {
	# ok. Fine. Pop it up above the entry widget isntead of
	# below.
	set y [expr {($rooty - $height - 1) + $vrooty}]

	if {$y < 0} {
	    # this means it extends beyond our screen. How annoying.
	    # Now we'll try to be real clever and either pop it up or
	    # down, depending on which way gives us the biggest list. 
	    # then, we'll trim the list to fit and force the use of
	    # a scrollbar

	    # (sadly, for windows users this measurement doesn't
	    # take into consideration the height of the taskbar,
	    # but don't blame me -- there isn't any way to detect
	    # it or figure out its dimensions. The same probably
	    # applies to any window manager with some magic windows
	    # glued to the top or bottom of the screen)

	    if {$rooty > [expr {$screenHeight / 2}]} {
		# we are in the lower half of the screen -- 
		# pop it up. Y is zero; that parts easy. The height
		# is simply the y coordinate of our widget, minus
		# a pixel for some visual separation. The y coordinate
		# will be the topof the screen.
		set y 1
		set height [expr {$rooty - 1 - $y}]

	    } else {
		# we are in the upper half of the screen --
		# pop it down
		set y [expr {$rooty + $vrooty + \
			[winfo reqheight $widgets(this)] + 1}]
		set height [expr {$screenHeight - $y}]

	    }

	    # force a scrollbar
	    HandleScrollbar $widgets(this) crop
	}	   
    }

    if {$y < 0} {
	# hmmm. Bummer.
	set y 0
	set height $screenheight
    }

    set geometry [format "=%dx%d+%d+%d" $width $height $x $y]

    return $geometry
}

# ::combobox::DoInternalWidgetCommand --
#
#    perform an internal widget command, then mung any error results
#    to look like it came from our megawidget. A lot of work just to
#    give the illusion that our megawidget is an atomic widget
#
# Arguments:
#
#    w           widget pathname
#    subwidget   pathname of the subwidget 
#    command     subwidget command to be executed
#    args        arguments to the command
#
# Returns:
#
#    The result of the subwidget command, or an error

proc ::combobox::DoInternalWidgetCommand {w subwidget command args} {
    upvar ::combobox::${w}::widgets widgets
    upvar ::combobox::${w}::options options

    set subcommand $command
    set command [concat $widgets($subwidget) $command $args]
    if {[catch $command result]} {
	# replace the subwidget name with the megawidget name
	regsub $widgets($subwidget) $result $widgets(this) result

	# replace specific instances of the subwidget command
	# with out megawidget command
	switch $subwidget,$subcommand {
	    listbox,index  {regsub "index"  $result "list index"  result}
	    listbox,insert {regsub "insert" $result "list insert" result}
	    listbox,delete {regsub "delete" $result "list delete" result}
	    listbox,get    {regsub "get"    $result "list get"    result}
	    listbox,size   {regsub "size"   $result "list size"   result}
	}
	error $result

    } else {
	return $result
    }
}


# ::combobox::WidgetProc --
#
#    This gets uses as the widgetproc for an combobox widget. 
#    Notice where the widget is created and you'll see that the
#    actual widget proc merely evals this proc with all of the
#    arguments intact.
#
#    Note that some widget commands are defined "inline" (ie:
#    within this proc), and some do most of their work in 
#    separate procs. This is merely because sometimes it was
#    easier to do it one way or the other.
#
# Arguments:
#
#    w         widget pathname
#    command   widget subcommand
#    args      additional arguments; varies with the subcommand
#
# Results:
#
#    Performs the requested widget command

proc ::combobox::WidgetProc {w command args} {
    upvar ::combobox::${w}::widgets widgets
    upvar ::combobox::${w}::options options
    upvar ::combobox::${w}::oldFocus oldFocus
    upvar ::combobox::${w}::oldFocus oldGrab

    set command [::combobox::Canonize $w command $command]

    # this is just shorthand notation...
    set doWidgetCommand \
	    [list ::combobox::DoInternalWidgetCommand $widgets(this)]

    if {$command == "list"} {
	# ok, the next argument is a list command; we'll 
	# rip it from args and append it to command to
	# create a unique internal command
	#
	# NB: because of the sloppy way we are doing this,
	# we'll also let the user enter our secret command
	# directly (eg: listinsert, listdelete), but we
	# won't document that fact
	set command "list-[lindex $args 0]"
	set args [lrange $args 1 end]
    }

    set result ""

    # many of these commands are just synonyms for specific
    # commands in one of the subwidgets. We'll get them out
    # of the way first, then do the custom commands.
    switch $command {
	bbox -
	delete -
	get -
	icursor -
	index -
	insert -
	scan -
	selection -
	xview {
	    set result [eval $doWidgetCommand entry $command $args]
	}
	list-get 	{set result [eval $doWidgetCommand listbox get $args]}
	list-index 	{set result [eval $doWidgetCommand listbox index $args]}
	list-size 	{set result [eval $doWidgetCommand listbox size $args]}

	select {
	    if {[llength $args] == 1} {
		set index [lindex $args 0]
		set result [Select $widgets(this) $index]
	    } else {
		error "usage: $w select index"
	    }
	}

	subwidget {
	    set knownWidgets [list button entry listbox dropdown vsb]
	    if {[llength $args] == 0} {
		return $knownWidgets
	    }

	    set name [lindex $args 0]
	    if {[lsearch $knownWidgets $name] != -1} {
		set result $widgets($name)
	    } else {
		error "unknown subwidget $name"
	    }
	}

	curselection {
	    set result [eval $doWidgetCommand listbox curselection]
	}

	list-insert {
	    eval $doWidgetCommand listbox insert $args
	    set result [HandleScrollbar $w "grow"]
	}

	list-delete {
	    eval $doWidgetCommand listbox delete $args
	    set result [HandleScrollbar $w "shrink"]
	}

	toggle {
	    # ignore this command if the widget is disabled...
	    if {$options(-state) == "disabled"} return

	    # pops down the list if it is not, hides it
	    # if it is...
	    if {[winfo ismapped $widgets(dropdown)]} {
		set result [$widgets(this) close]
	    } else {
		set result [$widgets(this) open]
	    }
	}

	open {

	    # if this is an editable combobox, the focus should
	    # be set to the entry widget
	    if {$options(-editable)} {
		focus $widgets(entry)
		$widgets(entry) select range 0 end
		$widgets(entry) icur end
	    }

	    # if we are disabled, we won't allow this to happen
	    if {$options(-state) == "disabled"} {
		return 0
	    }

	    # if there is a -opencommand, execute it now
	    if {[string length $options(-opencommand)] > 0} {
		# hmmm... should I do a catch, or just let the normal
		# error handling handle any errors? For now, the latter...
		uplevel \#0 $options(-opencommand)
	    }

	    # compute the geometry of the window to pop up, and set
	    # it, and force the window manager to take notice
	    # (even if it is not presently visible).
	    #
	    # this isn't strictly necessary if the window is already
	    # mapped, but we'll go ahead and set the geometry here
	    # since its harmless and *may* actually reset the geometry
	    # to something better in some weird case.
	    set geometry [::combobox::ComputeGeometry $widgets(this)]
	    wm geometry $widgets(dropdown) $geometry
	    raise $widgets(dropdown)
	    update idletasks

	    # if we are already open, there's nothing else to do
	    if {[winfo ismapped $widgets(dropdown)]} {
		return 0
	    }

	    # save the widget that currently has the focus; we'll restore
	    # the focus there when we're done
	    set oldFocus [focus]

	    # ok, tweak the visual appearance of things and 
	    # make the list pop up
	    $widgets(button) configure -relief sunken
	    raise $widgets(dropdown) [winfo parent $widgets(this)]
	    wm deiconify $widgets(dropdown) 

	    # force focus to the entry widget so we can handle keypress
	    # events for traversal
	    focus -force $widgets(entry)

	    # select something by default, but only if its an
	    # exact match...
	    ::combobox::Find $widgets(this) 1

	    # save the current grab state for the display containing
	    # this widget. We'll restore it when we close the dropdown
	    # list
	    set status "none"
	    set grab [grab current $widgets(this)]
	    if {$grab != ""} {set status [grab status $grab]}
	    set oldGrab [list $grab $status]
	    unset grab status

	    # *gasp* do a global grab!!! Mom always told me not to
	    # do things like this, but sometimes a man's gotta do
	    # what a man's gotta do.
	    grab -global $widgets(this)

	    # fake the listbox into thinking it has focus. This is 
	    # necessary to get scanning initialized properly in the
	    # listbox.
	    event generate $widgets(listbox) <B1-Enter>

	    return 1
	}

	close {
	    # if we are already closed, don't do anything...
	    if {![winfo ismapped $widgets(dropdown)]} {
		return 0
	    }

	    # restore the focus and grab, but ignore any errors...
	    # we're going to be paranoid and release the grab before
	    # trying to set any other grab because we really really
	    # really want to make sure the grab is released.
	    catch {focus $oldFocus} result
	    catch {grab release $widgets(this)}
	    catch {
		set status [lindex $oldGrab 1]
		if {$status == "global"} {
		    grab -global [lindex $oldGrab 0]
		} elseif {$status == "local"} {
		    grab [lindex $oldGrab 0]
		}
		unset status
	    }

	    # hides the listbox
	    $widgets(button) configure -relief raised
	    wm withdraw $widgets(dropdown) 

	    # select the data in the entry widget. Not sure
	    # why, other than observation seems to suggest that's
	    # what windows widgets do.
	    set editable [::combobox::GetBoolean $options(-editable)]
	    if {$editable} {
		$widgets(entry) selection range 0 end
		$widgets(button) configure -relief raised
	    }


	    # magic tcl stuff (see tk.tcl in the distribution 
	    # lib directory)
	    ::combobox::tkCancelRepeat

	    return 1
	}

	cget {
	    if {[llength $args] != 1} {
		error "wrong # args: should be $w cget option"
	    }
	    set opt [::combobox::Canonize $w option [lindex $args 0]]

	    if {$opt == "-value"} {
		set result [$widgets(entry) get]
	    } else {
		set result $options($opt)
	    }
	}

	configure {
	    set result [eval ::combobox::Configure {$w} $args]
	}

	default {
	    error "bad option \"$command\""
	}
    }

    return $result
}

# ::combobox::Configure --
#
#    Implements the "configure" widget subcommand
#
# Arguments:
#
#    w      widget pathname
#    args   zero or more option/value pairs (or a single option)
#
# Results:
#    
#    Performs typcial "configure" type requests on the widget

proc ::combobox::Configure {w args} {
    variable widgetOptions
    variable defaultEntryCursor

    upvar ::combobox::${w}::widgets widgets
    upvar ::combobox::${w}::options options

    if {[llength $args] == 0} {
	# hmmm. User must be wanting all configuration information
	# note that if the value of an array element is of length
	# one it is an alias, which needs to be handled slightly
	# differently
	set results {}
	foreach opt [lsort [array names widgetOptions]] {
	    if {[llength $widgetOptions($opt)] == 1} {
		set alias $widgetOptions($opt)
		set optName $widgetOptions($alias)
		lappend results [list $opt $optName]
	    } else {
		set optName  [lindex $widgetOptions($opt) 0]
		set optClass [lindex $widgetOptions($opt) 1]
		set default [option get $w $optName $optClass]
		if {[info exists options($opt)]} {
		    lappend results [list $opt $optName $optClass \
			    $default $options($opt)]
		} else {
		    lappend results [list $opt $optName $optClass \
			    $default ""]
		}
	    }
	}

	return $results
    }
    
    # one argument means we are looking for configuration
    # information on a single option
    if {[llength $args] == 1} {
	set opt [::combobox::Canonize $w option [lindex $args 0]]

	set optName  [lindex $widgetOptions($opt) 0]
	set optClass [lindex $widgetOptions($opt) 1]
	set default [option get $w $optName $optClass]
	set results [list $opt $optName $optClass \
		$default $options($opt)]
	return $results
    }

    # if we have an odd number of values, bail. 
    if {[expr {[llength $args]%2}] == 1} {
	# hmmm. An odd number of elements in args
	error "value for \"[lindex $args end]\" missing"
    }
    
    # Great. An even number of options. Let's make sure they 
    # are all valid before we do anything. Note that Canonize
    # will generate an error if it finds a bogus option; otherwise
    # it returns the canonical option name
    foreach {name value} $args {
	set name [::combobox::Canonize $w option $name]
	set opts($name) $value
    }

    # process all of the configuration options
    # some (actually, most) options require us to
    # do something, like change the attributes of
    # a widget or two. Here's where we do that...
    #
    # note that the handling of disabledforeground and
    # disabledbackground is a little wonky. First, we have
    # to deal with backwards compatibility (ie: tk 8.3 and below
    # didn't have such options for the entry widget), and
    # we have to deal with the fact we might want to disable
    # the entry widget but use the normal foreground/background
    # for when the combobox is not disabled, but not editable either.

    set updateVisual 0
    foreach option [array names opts] {
	set newValue $opts($option)
	if {[info exists options($option)]} {
	    set oldValue $options($option)
	}

	switch -- $option {
	    -background {
		set updateVisual 1
		set options($option) $newValue
	    }

	    -borderwidth {
		$widgets(frame) configure -borderwidth $newValue
		set options($option) $newValue
	    }

	    -command {
		# nothing else to do...
		set options($option) $newValue
	    }

	    -commandstate {
		# do some value checking...
		if {$newValue != "normal" && $newValue != "disabled"} {
		    set options($option) $oldValue
		    set message "bad state value \"$newValue\";"
		    append message " must be normal or disabled"
		    error $message
		}
		set options($option) $newValue
	    }

	    -cursor {
		$widgets(frame) configure -cursor $newValue
		$widgets(entry) configure -cursor $newValue
		$widgets(listbox) configure -cursor $newValue
		set options($option) $newValue
	    }

	    -disabledforeground {
		set updateVisual 1
		set options($option) $newValue
	    }

	    -disabledbackground {
		set updateVisual 1
		set options($option) $newValue
	    }

            -dropdownwidth {
                set options($option) $newValue
            }

	    -editable {
		set updateVisual 1
		if {$newValue} {
		    # it's editable...
		    $widgets(entry) configure \
			    -state normal \
			    -cursor $defaultEntryCursor
		} else {
		    $widgets(entry) configure \
			    -state disabled \
			    -cursor $options(-cursor)
		}
		set options($option) $newValue
	    }

	    -font {
		$widgets(entry) configure -font $newValue
		$widgets(listbox) configure -font $newValue
		set options($option) $newValue
	    }

	    -foreground {
		set updateVisual 1
		set options($option) $newValue
	    }

	    -height {
		$widgets(listbox) configure -height $newValue
		HandleScrollbar $w
		set options($option) $newValue
	    }

	    -highlightbackground {
		$widgets(frame) configure -highlightbackground $newValue
		set options($option) $newValue
	    }

	    -highlightcolor {
		$widgets(frame) configure -highlightcolor $newValue
		set options($option) $newValue
	    }

	    -highlightthickness {
		$widgets(frame) configure -highlightthickness $newValue
		set options($option) $newValue
	    }
	    
	    -image {
		if {[string length $newValue] > 0} {
		    $widgets(button) configure -image $newValue
		} else {
		    $widgets(button) configure -image ::combobox::bimage
		}
		set options($option) $newValue
	    }

	    -maxheight {
		# ComputeGeometry may dork with the actual height
		# of the listbox, so let's undork it
		$widgets(listbox) configure -height $options(-height)
		HandleScrollbar $w
		set options($option) $newValue
	    }

	    -opencommand {
		# nothing else to do...
		set options($option) $newValue
	    }

	    -relief {
		$widgets(frame) configure -relief $newValue
		set options($option) $newValue
	    }

	    -selectbackground {
		$widgets(entry) configure -selectbackground $newValue
		$widgets(listbox) configure -selectbackground $newValue
		set options($option) $newValue
	    }

	    -selectborderwidth {
		$widgets(entry) configure -selectborderwidth $newValue
		$widgets(listbox) configure -selectborderwidth $newValue
		set options($option) $newValue
	    }

	    -selectforeground {
		$widgets(entry) configure -selectforeground $newValue
		$widgets(listbox) configure -selectforeground $newValue
		set options($option) $newValue
	    }

	    -state {
		if {$newValue == "normal"} {
		    set updateVisual 1
		    # it's enabled

		    set editable [::combobox::GetBoolean \
			    $options(-editable)]
		    if {$editable} {
			$widgets(entry) configure -state normal
			$widgets(entry) configure -takefocus 1
		    }

                    # note that $widgets(button) is actually a label,
                    # not a button. And being able to disable labels
                    # wasn't possible until tk 8.3. (makes me wonder
		    # why I chose to use a label, but that answer is
		    # lost to antiquity)
                    if {[info patchlevel] >= 8.3} {
                        $widgets(button) configure -state normal
                    }

		} elseif {$newValue == "disabled"}  {
		    set updateVisual 1
		    # it's disabled
		    $widgets(entry) configure -state disabled
		    $widgets(entry) configure -takefocus 0
                    # note that $widgets(button) is actually a label,
                    # not a button. And being able to disable labels
                    # wasn't possible until tk 8.3. (makes me wonder
		    # why I chose to use a label, but that answer is
		    # lost to antiquity)
                    if {$::tcl_version >= 8.3} {
                        $widgets(button) configure -state disabled 
                    }

		} else {
		    set options($option) $oldValue
		    set message "bad state value \"$newValue\";"
		    append message " must be normal or disabled"
		    error $message
		}

		set options($option) $newValue
	    }

	    -takefocus {
		$widgets(entry) configure -takefocus $newValue
		set options($option) $newValue
	    }

	    -textvariable {
		$widgets(entry) configure -textvariable $newValue
		set options($option) $newValue
	    }

	    -value {
		::combobox::SetValue $widgets(this) $newValue
		set options($option) $newValue
	    }

	    -width {
		$widgets(entry) configure -width $newValue
		$widgets(listbox) configure -width $newValue
		set options($option) $newValue
	    }

	    -xscrollcommand {
		$widgets(entry) configure -xscrollcommand $newValue
		set options($option) $newValue
	    }
	}	    

	if {$updateVisual} {UpdateVisualAttributes $w}
    }
}

# ::combobox::UpdateVisualAttributes --
#
# sets the visual attributes (foreground, background mostly) 
# based on the current state of the widget (normal/disabled, 
# editable/non-editable)
#
# why a proc for such a simple thing? Well, in addition to the
# various states of the widget, we also have to consider the 
# version of tk being used -- versions from 8.4 and beyond have
# the notion of disabled foreground/background options for various
# widgets. All of the permutations can get nasty, so we encapsulate
# it all in one spot.
#
# note also that we don't handle all visual attributes here; just
# the ones that depend on the state of the widget. The rest are 
# handled on a case by case basis
#
# Arguments:
#    w		widget pathname
#
# Returns:
#    empty string

proc ::combobox::UpdateVisualAttributes {w} {

    upvar ::combobox::${w}::widgets     widgets
    upvar ::combobox::${w}::options     options

    if {$options(-state) == "normal"} {

	set foreground $options(-foreground)
	set background $options(-background)
	
    } elseif {$options(-state) == "disabled"} {

	set foreground $options(-disabledforeground)
	set background $options(-disabledbackground)
    }

    $widgets(entry)   configure -foreground $foreground -background $background
    $widgets(listbox) configure -foreground $foreground -background $background
    $widgets(button)  configure -foreground $foreground 
    $widgets(vsb)     configure -background $background -troughcolor $background
    $widgets(frame)   configure -background $background

    # we need to set the disabled colors in case our widget is disabled. 
    # We could actually check for disabled-ness, but we also need to 
    # check whether we're enabled but not editable, in which case the 
    # entry widget is disabled but we still want the enabled colors. It's
    # easier just to set everything and be done with it.
    
    if {$::tcl_version >= 8.4} {
	$widgets(entry) configure \
	    -disabledforeground $foreground \
	    -disabledbackground $background
	$widgets(button)  configure -disabledforeground $foreground
	$widgets(listbox) configure -disabledforeground $foreground
    }
}

# ::combobox::SetValue --
#
#    sets the value of the combobox and calls the -command, 
#    if defined
#
# Arguments:
#
#    w          widget pathname
#    newValue   the new value of the combobox
#
# Returns
#
#    Empty string

proc ::combobox::SetValue {w newValue} {

    upvar ::combobox::${w}::widgets     widgets
    upvar ::combobox::${w}::options     options
    upvar ::combobox::${w}::ignoreTrace ignoreTrace
    upvar ::combobox::${w}::oldValue    oldValue

    if {[info exists options(-textvariable)] \
	    && [string length $options(-textvariable)] > 0} {
	set variable ::$options(-textvariable)
	set $variable $newValue
    } else {
	set oldstate [$widgets(entry) cget -state]
	$widgets(entry) configure -state normal
	$widgets(entry) delete 0 end
	$widgets(entry) insert 0 $newValue
	$widgets(entry) configure -state $oldstate
    }

    # set our internal textvariable; this will cause any public
    # textvariable (ie: defined by the user) to be updated as
    # well
#    set ::combobox::${w}::entryTextVariable $newValue

    # redefine our concept of the "old value". Do it before running
    # any associated command so we can be sure it happens even
    # if the command somehow fails.
    set oldValue $newValue


    # call the associated command. The proc will handle whether or 
    # not to actually call it, and with what args
    CallCommand $w $newValue

    return ""
}

# ::combobox::CallCommand --
#
#   calls the associated command, if any, appending the new
#   value to the command to be called.
#
# Arguments:
#
#    w         widget pathname
#    newValue  the new value of the combobox
#
# Returns
#
#    empty string

proc ::combobox::CallCommand {w newValue} {
    upvar ::combobox::${w}::widgets widgets
    upvar ::combobox::${w}::options options
    
    # call the associated command, if defined and -commandstate is
    # set to "normal"
    if {$options(-commandstate) == "normal" && \
	    [string length $options(-command)] > 0} {
	set args [list $widgets(this) $newValue]
	uplevel \#0 $options(-command) $args
    }
}


# ::combobox::GetBoolean --
#
#     returns the value of a (presumably) boolean string (ie: it should
#     do the right thing if the string is "yes", "no", "true", 1, etc
#
# Arguments:
#
#     value       value to be converted 
#     errorValue  a default value to be returned in case of an error
#
# Returns:
#
#     a 1 or zero, or the value of errorValue if the string isn't
#     a proper boolean value

proc ::combobox::GetBoolean {value {errorValue 1}} {
    if {[catch {expr {([string trim $value])?1:0}} res]} {
	return $errorValue
    } else {
	return $res
    }
}

# ::combobox::convert --
#
#     public routine to convert %x, %y and %W binding substitutions.
#     Given an x, y and or %W value relative to a given widget, this
#     routine will convert the values to be relative to the combobox
#     widget. For example, it could be used in a binding like this:
#
#     bind .combobox <blah> {doSomething [::combobox::convert %W -x %x]}
#
#     Note that this procedure is *not* exported, but is intended for
#     public use. It is not exported because the name could easily 
#     clash with existing commands. 
#
# Arguments:
#
#     w     a widget path; typically the actual result of a %W 
#           substitution in a binding. It should be either a
#           combobox widget or one of its subwidgets
#
#     args  should one or more of the following arguments or 
#           pairs of arguments:
#
#           -x <x>      will convert the value <x>; typically <x> will
#                       be the result of a %x substitution
#           -y <y>      will convert the value <y>; typically <y> will
#                       be the result of a %y substitution
#           -W (or -w)  will return the name of the combobox widget
#                       which is the parent of $w
#
# Returns:
#
#     a list of the requested values. For example, a single -w will
#     result in a list of one items, the name of the combobox widget.
#     Supplying "-x 10 -y 20 -W" (in any order) will return a list of
#     three values: the converted x and y values, and the name of 
#     the combobox widget.

proc ::combobox::convert {w args} {
    set result {}
    if {![winfo exists $w]} {
	error "window \"$w\" doesn't exist"
    }

    while {[llength $args] > 0} {
	set option [lindex $args 0]
	set args [lrange $args 1 end]

	switch -exact -- $option {
	    -x {
		set value [lindex $args 0]
		set args [lrange $args 1 end]
		set win $w
		while {[winfo class $win] != "Combobox"} {
		    incr value [winfo x $win]
		    set win [winfo parent $win]
		    if {$win == "."} break
		}
		lappend result $value
	    }

	    -y {
		set value [lindex $args 0]
		set args [lrange $args 1 end]
		set win $w
		while {[winfo class $win] != "Combobox"} {
		    incr value [winfo y $win]
		    set win [winfo parent $win]
		    if {$win == "."} break
		}
		lappend result $value
	    }

	    -w -
	    -W {
		set win $w
		while {[winfo class $win] != "Combobox"} {
		    set win [winfo parent $win]
		    if {$win == "."} break;
		}
		lappend result $win
	    }
	}
    }
    return $result
}

# ::combobox::Canonize --
#
#    takes a (possibly abbreviated) option or command name and either 
#    returns the canonical name or an error
#
# Arguments:
#
#    w        widget pathname
#    object   type of object to canonize; must be one of "command",
#             "option", "scan command" or "list command"
#    opt      the option (or command) to be canonized
#
# Returns:
#
#    Returns either the canonical form of an option or command,
#    or raises an error if the option or command is unknown or
#    ambiguous.

proc ::combobox::Canonize {w object opt} {
    variable widgetOptions
    variable columnOptions
    variable widgetCommands
    variable listCommands
    variable scanCommands

    switch $object {
	command {
	    if {[lsearch -exact $widgetCommands $opt] >= 0} {
		return $opt
	    }

	    # command names aren't stored in an array, and there
	    # isn't a way to get all the matches in a list, so
	    # we'll stuff the commands in a temporary array so
	    # we can use [array names]
	    set list $widgetCommands
	    foreach element $list {
		set tmp($element) ""
	    }
	    set matches [array names tmp ${opt}*]
	}

	{list command} {
	    if {[lsearch -exact $listCommands $opt] >= 0} {
		return $opt
	    }

	    # command names aren't stored in an array, and there
	    # isn't a way to get all the matches in a list, so
	    # we'll stuff the commands in a temporary array so
	    # we can use [array names]
	    set list $listCommands
	    foreach element $list {
		set tmp($element) ""
	    }
	    set matches [array names tmp ${opt}*]
	}

	{scan command} {
	    if {[lsearch -exact $scanCommands $opt] >= 0} {
		return $opt
	    }

	    # command names aren't stored in an array, and there
	    # isn't a way to get all the matches in a list, so
	    # we'll stuff the commands in a temporary array so
	    # we can use [array names]
	    set list $scanCommands
	    foreach element $list {
		set tmp($element) ""
	    }
	    set matches [array names tmp ${opt}*]
	}

	option {
	    if {[info exists widgetOptions($opt)] \
		    && [llength $widgetOptions($opt)] == 2} {
		return $opt
	    }
	    set list [array names widgetOptions]
	    set matches [array names widgetOptions ${opt}*]
	}

    }

    if {[llength $matches] == 0} {
	set choices [HumanizeList $list]
	error "unknown $object \"$opt\"; must be one of $choices"

    } elseif {[llength $matches] == 1} {
	set opt [lindex $matches 0]

	# deal with option aliases
	switch $object {
	    option {
		set opt [lindex $matches 0]
		if {[llength $widgetOptions($opt)] == 1} {
		    set opt $widgetOptions($opt)
		}
	    }
	}

	return $opt

    } else {
	set choices [HumanizeList $list]
	error "ambiguous $object \"$opt\"; must be one of $choices"
    }
}

# ::combobox::HumanizeList --
#
#    Returns a human-readable form of a list by separating items
#    by columns, but separating the last two elements with "or"
#    (eg: foo, bar or baz)
#
# Arguments:
#
#    list    a valid tcl list
#
# Results:
#
#    A string which as all of the elements joined with ", " or 
#    the word " or "

proc ::combobox::HumanizeList {list} {

    if {[llength $list] == 1} {
	return [lindex $list 0]
    } else {
	set list [lsort $list]
	set secondToLast [expr {[llength $list] -2}]
	set most [lrange $list 0 $secondToLast]
	set last [lindex $list end]

	return "[join $most {, }] or $last"
    }
}

# This is some backwards-compatibility code to handle TIP 44
# (http://purl.org/tcl/tip/44.html). For all private tk commands
# used by this widget, we'll make duplicates of the procs in the
# combobox namespace. 
#
# I'm not entirely convinced this is the right thing to do. I probably
# shouldn't even be using the private commands. Then again, maybe the
# private commands really should be public. Oh well; it works so it
# must be OK...
foreach command {TabToWindow CancelRepeat ListboxUpDown} {
    if {[llength [info commands ::combobox::tk$command]] == 1} break;

    set tmp [info commands tk$command]
    set proc ::combobox::tk$command
    if {[llength [info commands tk$command]] == 1} {
        set command [namespace which [lindex $tmp 0]]
        proc $proc {args} "uplevel $command \$args"
    } else {
        if {[llength [info commands ::tk::$command]] == 1} {
            proc $proc {args} "uplevel ::tk::$command \$args"
        }
    }
}

catch {puts "Loaded Package poExtlib (Module [info script])"}

# end of combobox.tcl


############################################################################
# Original file: poTcllib/poCfgFile.tcl
############################################################################

package provide poTcllib  1.0
package provide poCfgFile 1.0

namespace eval ::poCfgFile {
    namespace export GetCfgFilename
    namespace export ReadCfgFile
    namespace export SaveCfgFile

    namespace export Test
}

proc ::poCfgFile::Init {} {
}

proc ::poCfgFile::GetCfgFilename { module { cfgDir "" } } {
    if { [string compare $cfgDir ""] == 0 } {
        set dir "~"
    } else {
        set dir $cfgDir
    }
    set cfgName [format "%s.cfg" $module]
    return [file join $dir $cfgName]
}

# cfgFile - configuration filename
# cmds - allowed 'commands' in the configuration file as a list where each
# element is {cmdName defVal}
# returns: cmdName Value cmdName Value [...] _errorMsg <rc> (<rc> empty if ok)
#
proc ::poCfgFile::ReadCfgFile { cfgFile cmds } {
    catch {
        set id [interp create -safe]
        # Maximum security in the slave: Delete all available commands.
        interp eval $id {
            foreach cmd [info commands] {
                if {$cmd != {rename} && $cmd != {if}} {
                    rename $cmd {}
                }
            }
            rename if {}; rename rename {}
        }
        array set temp $cmds
        proc set$id {key args} {
            upvar 1 temp myArr; set myArr($key) [join $args]
        }
        # Define aliases in the slave for each available configuration-'command'
        # and map each command to the set$id procedure.
        foreach {cmd default} $cmds {
            interp alias $id $cmd {} poCfgFile::set$id $cmd; # arg [...]
        }
        # Source the configuration file.
        $id invokehidden source $cfgFile

        # Clean up.
        interp delete $id
        rename set$id {}
    } rc
    if { $rc != "" } {
        error "Could not read configuration file \"$cfgFile\" ($rc)."
    }
    return [array get temp]
}

proc ::poCfgFile::SaveCfgFile { cfgFile cmds } {
    set retVal [catch {open $cfgFile w} fp]
    if { $retVal == 0 } {
        foreach { key val } $cmds {
            puts $fp "$key $val"
        }
    } else {
        error "Could not open file \"$cfgFile\" for writing."
    }
    close $fp
}

proc ::poCfgFile::Test { } {
    array set opts {
        integer0         0
        integer1         1
        float0           0.0
        float1           0.00001
        str0             String
        str1             "This is a string"
        list0            {List}
        list1            {El1 El2 El3}
        list2            { {El1_1 El1_1} {El2_1 El2_2} }
    }
    set cfgFile [file join [::poMisc::GetTmpDir] "poCfgFile.test"]

    puts "Writing these values to configuration file $cfgFile"
    parray opts

    ::poCfgFile::SaveCfgFile $cfgFile [array get opts]

    array set new [::poCfgFile::ReadCfgFile $cfgFile [array get opts]]
    puts "Read these values from written configuration file $cfgFile"
    parray new

    foreach el $new(list1) {
        puts "list1: $el"
    }
}

::poCfgFile::Init
catch {puts "Loaded Package poTcllib (Module [info script])"}

############################################################################
# Original file: poTcllib/poCsv.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poCsv
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poCsv.tcl
#
#       First Version:  2000 / 07 / 01
#       Author:         Paul Obermeier
#
#       Description:
#			This package provides methods to read and write
#			CSV files. These files are e.g. used by MS Excel.
#			
#       Additional documentation:
#
#			Maybe MS has something.
#
#       Exported functions:
#                       ::poCsv::Init
#			::poCsv::GetSeparatorChar
#			::poCsv::SetSeparatorChar
#			::poCsv::GetNumHeaderLines
#			::poCsv::SetNumHeaderLines
#                       ::poCsv::Line2List
#                       ::poCsv::List2Line
#                       ::poCsv::Read
#                       ::poCsv::Write
#
############################################################################

package provide poTcllib 1.0
package provide poCsv   1.0

namespace eval ::poCsv {
    namespace export Init
    namespace export GetSeparatorChar
    namespace export SetSeparatorChar
    namespace export GetNumHeaderLines
    namespace export SetNumHeaderLines
    namespace export Line2List
    namespace export List2Line
    namespace export Read
    namespace export Write

    namespace export Test

    variable sepChar
    variable numHeadLines
}

proc ::poCsv::matchList { l exp { caseSensitive 0 } { useWildCard 1 } } {
    # Quote all regexp special chars: "*+.?()|[]\"
    # if useWildCard is set, we use * as a wildcard for 
    # 0 and more characters, like Unix shell's do.
    if { $useWildCard } {
        regsub -all {\+|\.|\?|\(|\)|\||\[|\]|\\} $exp {\\&} tmpExp1
        regsub -all {\*} $tmpExp1 {.*} tmpExp
    } else {
        regsub -all {\*|\+|\.|\?|\(|\)|\||\[|\]|\\} $exp {\\&} tmpExp
    }

    set elemNo 0
    foreach elem $l {
        if { $caseSensitive } {
            set found [regexp $tmpExp $elem]
        } else {
            set found [regexp -nocase $tmpExp $elem]
        }
	if { $found } {
	    return $elemNo
	}
	incr elemNo
    }
    return -1
}

proc ::poCsv::GetSeparatorChar {} {
    variable sepChar

    return $sepChar
}

proc ::poCsv::SetSeparatorChar { { separatorChar ";" } } {
    variable sepChar

    set sepChar $separatorChar
}

proc ::poCsv::GetNumHeaderLines {} {
    variable numHeadLines

    return $numHeadLines
}

proc ::poCsv::SetNumHeaderLines { { numHeaderLines 0 } } {
    variable numHeadLines

    set numHeadLines $numHeaderLines
}

proc ::poCsv::Init {} {
    ::poCsv::SetSeparatorChar
    ::poCsv::SetNumHeaderLines
}

proc ::poCsv::Line2List { lineStr } {
    variable sepChar

    set tmpList {}
    set wordCount 1
    set combine 0

    set wordList [split $lineStr $sepChar]

    foreach word $wordList {
	set len [string length $word]
	if { [string compare [string index $word end] "\""] == 0 } {
	    set endQuote 1
        } else {
	    set endQuote 0
        }
	if { [string compare [string index $word 0] "\""] == 0 } {
	    set begQuote 1
        } else {
	    set begQuote 0
        }

        # puts "Word=<$word> (Combine=$combine / Length=[string length $word])"
	if { $begQuote && $endQuote && ($len % 2 == 1) } {
	    set onlyQuotes [regexp {^[\"]+$} $word]
	    # puts "Odd: Len = $len onlyQuotes=$onlyQuotes"
	    if { $onlyQuotes } {
	        if { $combine } {
		    set begQuote 0
	        } else {
		    set endQuote 0
	        }
	    }
	}
	if { $begQuote && $endQuote && ($len == 2) } {
	    set begQuote 0
	    set endQuote 0
	}

        if { $begQuote && $endQuote } {
	    lappend tmpList [string map {\"\" \"} [string range $word 1 end-1]]
	    set combine 0
	    incr wordCount
	} elseif { !$begQuote && $endQuote } {
	    append tmpWord [string range $word 0 end-1]
	    lappend tmpList [string map {\"\" \"} $tmpWord]
	    set combine 0
	    incr wordCount
	} elseif { $begQuote && !$endQuote } {
	    set tmpWord [string range $word 1 end]
	    append tmpWord $sepChar
	    set combine 1
	} else {
	    if { $combine } {
	        append tmpWord  [string map {\"\" \"} $word]
	        append tmpWord $sepChar
	    } else {
	       lappend tmpList [string map {\"\" \"} $word]
	       set combine 0
	       incr wordCount
	    }
	}
    }
    return $tmpList
}

proc ::poCsv::List2Line { lineList } {
    variable sepChar

    set lineStr ""
    set len1 [expr [llength $lineList] -1]
    set curVal 0
    foreach val $lineList {
        # regsub -all {\n|\r} $val { } tmp
	# OPa >>> Unteres Konstrujt noch testen
	set tmp [string map {\n\r \ } $val]
        if { [string first $sepChar $tmp] >= 0 || [string first "\"" $tmp] >= 0 } {
            regsub -all {"} $tmp {""} tmp
            set tmp [format "\"%s\"" $tmp]
        }
        if { $curVal < $len1 } {
            append lineStr $tmp $sepChar
        } else {
	    append lineStr $tmp
	}
        incr curVal
    }
    return $lineStr
}

###########################################################################
#[@e
#       Name:           ::poCsv::Read
#
#       Usage:          Read a CSV file.
#
#       Synopsis:       proc ::poCsv::Read { csvFile }
#
#       Description:    csvFile: string 
#
#			The CSV file name.
#
#       Return Value:   The representation of the CSV file as a list of lists.
#
#       See also:	::poCsv::Write
#
###########################################################################

proc ::poCsv::Read { csvFile { exp "" } { caseSensitive 0 } { useWildCard 1 } } {
    variable sepChar
    variable numHeadLines

    set csvList {}
    set lineCount 1

    set catchVal [catch {open $csvFile r} fp] 
    if { $catchVal != 0 } {  
        error "Could not open file \"$csvFile\" for reading."
    }

    while { [gets $fp line] >= 0 } {
	if { $lineCount <= $numHeadLines } {
            # We are still reading a header line
            incr lineCount
            continue
        }

	set tmpList [Line2List $line]

	if { [string compare $exp ""] != 0 && \
	     [matchList $tmpList $exp $caseSensitive $useWildCard] < 0 } {
	    continue
	}
	lappend csvList $tmpList
    }

    close $fp
    return $csvList
}

proc ::poCsv::Write { csvList csvFile } {

    set catchVal [catch {open $csvFile w} fp] 
    if { $catchVal != 0 } {  
        error "Could not open file \"$csvFile\" for writing."
    }

    foreach line $csvList {
	puts $fp [List2Line $line]
    }
    close $fp
}

proc ::poCsv::Test { csvFile } {

}

::poCsv::Init
catch {puts "Loaded Package poTcllib (Module [info script])"}

############################################################################
# Original file: poTcllib/poEnv.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poEnv
#       Copyright:      Paul Obermeier 2001-2003 / paul@poSoft.de
#       Filename:       poEnv.tcl
#
#       First Version:  2001 / 04 / 01
#       Author:         Paul Obermeier
#
#       Description:
#			This package provides methods to read and write
#			files which set environment variables.
#			
#       Additional documentation:
#
#			On Windows you have files with lines as follows,
#			which you would execute to have the environment 
#			variables available in your DOS-Box:
#				rem This is a comment
#				set POSRCDIR=c:\tmp\poSrc
#				set CC=cl /nologo /Zm1000 -c
#			These files must have an extension of ".bat".
#
#			On Unix you have files with lines as follows, which 
#			you would "source" to set the environment variables
#			in your shell:
#			C-Shell and descendants:
#				# This is a comment
#				setenv POSRCDIR /c/tmp/poSrc
#				setenv CC "gcc -c"
#			These files must have an extension of ".csh" or ".tcsh".
#
#			Bourne Shell and descendants:
#				# This is a comment
#				POSRCDIR=/c/tmp/poSrc ; export POSRCDIR
#				CC="gcc -c" ; export CC
#			These files must have an extension of ".sh" or ".bash".
#
#       Exported functions:
#                       ::poEnv::Init
#                       ::poEnv::Read
#                       ::poEnv::Write
#                       ::poEnv::Test
#
############################################################################

package provide poTcllib 1.0
package provide poEnv    1.0

namespace eval ::poEnv {
    namespace export Init
    namespace export Read
    namespace export Write

    namespace export Test
}

proc ::poEnv::GetShellType { fileName } {
    set ext [file extension $fileName]
    if { [string compare $ext ".bat"] == 0 } {
        set shell "dos"
    } elseif { [string match "*csh" $ext] } {
        set shell "csh"
    } elseif { [string match "*sh" $ext] } {
        set shell "sh"
    } else {
        error "Invalid file extension: \"$ext\"."
    }
    return $shell
}

proc ::poEnv::Init { } {
}

###########################################################################
#[@e
#       Name:           ::poEnv::Read
#
#       Usage:          Read an environment file.
#
#       Synopsis:       proc ::poEnv::Read { envFile }
#
#       Description:    envFile: string 
#
#			The environment file name.
#
#			If anything goes wrong, an error is thrown.
#
#       Return Value:   The contents of the environment file as a list of
#			{VariableName VariableValue} pairs.
#
#       See also:	::poEnv::Write
#
###########################################################################

proc ::poEnv::Read { envFile } {

    set envList {}
    set lineCount 1

    set catchVal [catch {open $envFile r} fp] 
    if { $catchVal != 0 } {  
        error "Could not open file \"$envFile\" for reading."
    }

    # GetShellType throws an error, if envFile has an unknown extension.
    set shell [::poEnv::GetShellType $envFile]
    switch $shell {
	"dos" {
	    set varExp {^set ([A-z,0-9]+)=(.*)}
	    set comExp "rem"
	}
	"csh" {
	    set varExp {^setenv ([A-z,0-9]+)[ |\t](.*)}
	    set comExp "#"
	}
	"sh" {
	    set varExp {^([A-z,0-9]+)=(.*);}
	    set comExp "#"
	}
    }

    while { [gets $fp line] >= 0 } {
	if { [string compare $line ""] == 0 } {
	    # Empty line
	    continue
	}

	if { [string first $comExp $line] == 0 } {
	    # Comment line
	    continue
	}

	set ret [regexp $varExp $line total var val]
	if { $ret == 1 } {
	    set tmpVal [string trim $val]
	    lappend envList [list $var $tmpVal]
	}

	incr lineCount
    }

    close $fp
    return $envList
}

proc ::poEnv::ReadFiles { args } {
    foreach envFile $args {
	set envList [::poEnv::Read $envFile]
    }
}

###########################################################################
#[@e
#       Name:           ::poEnv::Write
#
#       Usage:          Write an environment file.
#
#       Synopsis:       proc ::poEnv::Write { envList envFile }
#
#       Description:    envList: list
#			         The contents to be written as a list of
#			         {VariableName VariableValue} pairs.
#			envFile: string 
#			         The environment file name.
#
#			If anything goes wrong, an error is thrown.
#
#       Return Value:	None.
#
#       See also:	::poEnv::Read
#
###########################################################################

proc ::poEnv::Write { envList envFile } {

    # GetShellType throws an error, if envFile has an unknown extension.
    set shell [::poEnv::GetShellType $envFile]

    set catchVal [catch {open $envFile w} fp] 
    if { $catchVal != 0 } {  
        error "Could not open file \"$envFile\" for writing."
    }

    switch $shell {
	"dos" {
	    fconfigure $fp -translation crlf
	    set comExp "rem"
	}
	"csh" {
	    fconfigure $fp -translation lf
	    set comExp "#"
	}
	"sh" {
	    fconfigure $fp -translation lf
	    set comExp "#"
	}
    }
    puts $fp "$comExp Autogenerated environment file for $shell"
    puts $fp ""

    foreach pair $envList {
	set var [lindex $pair 0]
	set val [lindex $pair 1]
	switch $shell {
	    "dos" {
		puts $fp "set $var=$val"
	    }
	    "csh" {
		puts $fp "setenv $var $val"
	    }
	    "sh" {
		puts $fp "$var=$val ; export $var"
	    }
	}
    }
    close $fp
}

###########################################################################
#[@e
#       Name:           ::poEnv::Test
#
#       Usage:          Test procedure for the environment file module.
#
#       Synopsis:       proc ::poEnv::Test { envFile shell }
#
#       Description:	envFileIn: string
#		            The environment file to read.
#       		envFileOut: string
#			    The environment file to write.
#
#			If anything goes wrong, an error is thrown.
#
#       Return Value:	1, if test succeeds, 0 otherwise.
#
#       See also:	::poEnv::Read
#			::poEnv::Write
#
###########################################################################

proc ::poEnv::Test { envFileIn envFileOut } {
    puts "-----------------------------------------------------"
    puts ""
    puts "Reading environment file: $envFileIn"
    puts ""
    set catchVal [catch {::poEnv::Read $envFileIn} envList] 
    if { $catchVal } {  
	puts "$::errorInfo"
	return 0
    }
    foreach pair $envList {
	set var [lindex $pair 0]
	set val [lindex $pair 1]
	puts "Variable $var: $val"
    }
    set catchVal [catch {::poEnv::Write $envList $envFileOut}] 
    if { $catchVal } {
	puts "$::errorInfo"
	return 0
    }
    puts "Writing environment file: $envFileOut"
    return 1
}

::poEnv::Init
catch {puts "Loaded Package poTcllib (Module [info script])"}

############################################################################
# Original file: poTcllib/poExec.tcl
############################################################################

package provide poTcllib 1.0
package provide poExec 1.0

namespace eval ::poExec {
    variable running     ; #
    variable exectrace 1 ; # 1: display on stdout what's going on
    variable force 1     ; # 1: force use of the VFS-internal program.
                         ; # (if 0, look
                         ; # first if an external program is available and use
                         ; # internal copy only, if no external found)
}

# Check for starkit availability.
# package require starkit
# set wrapmode [starkit::startup]

proc ::poExec::setforce {setting} {
    set ::poExec::force $setting
}

proc ::poExec::settrace {setting} {
    set ::poExec::exectrace $setting
}

proc ::poExec::gettemps {} {
    return [array get ::poExec::running]; # untested so far
}

proc ::poExec::exec { args } {
    variable running
    set progIdx -1
    set force   -1
    # locate the programspec in the exec-cmd
    foreach a $args {
        incr progIdx
        if {$a ne "-keepnewline" && $a ne "--"} {
            break
        }
    }
    set progCallOrg [lindex $args $progIdx]
    set progCallTst ""
    set progCallNew ""
    if {!$::poExec::force} {
        # search for external callable program
        set progCallTst [auto_execok $progCallOrg]
    }
    if {$progCallTst eq ""} {
        # no external program available, or 'force' specified
        if { [info exists      starkit::topdir] && \
             [file isdirectory $starkit::topdir] } {
            set toolDir  [file join $starkit::topdir "programs"]
        } else {
            set toolDir  [file dirname [info script]]
        }
        set progName [file tail $progCallOrg]
        if { $::tcl_platform(platform) eq "windows" } {
            if { [file extension $progName] ne ".exe" } {
                append progName ".exe"
            }
        }
        set prog [file join $toolDir $progName]
        if { ! [file exists $prog] } {
            error "Requested program $prog does not exist"
        }
        set progCallNew [file join [::poMisc::GetTmpDir] $progName]
        if { ! [file exists $progCallNew] } {
            puts "Copy $prog --> $progCallNew"
            set retVal [catch { file copy -force -- $prog $progCallNew }]
            if { $retVal != 0 } {
                error "Error copying program to temp dir"
            }
            if { $::tcl_platform(platform) ne "windows" } {
                file attributes $progCallNew -permissions "u+x"
            }
        } else {
            puts "No need to copy"
        }
        lset args $progIdx [list $progCallNew]
    }
    if {$::poExec::exectrace} {
        puts -nonewline {>>> }
        puts $args
    }
    catch {eval ::exec $args} rc
    if {$progCallNew ne ""} {
        if {[lindex $args end] ne "&"} {
            # on can add an switch for -nodeltemp, if required
            # catch {file delete -force -- $progCallNew}
        } else {
            # see notes
            set running($rc) $progCallNew
        }
    }
    return $rc
}

proc ::poExec::kill { progName } {
    global tcl_platform

    if { $tcl_platform(platform) eq "windows" } {
        package require twapi
        set pids [concat [twapi::get_process_ids -name $progName] \
                         [twapi::get_process_ids -path $progName]]
        foreach pid $pids {
            # Catch the error in case process does not exist any more
            catch {twapi::end_process $pid -force}
        }
    }
}

catch {puts "Loaded Package poTcllib (Module [info script])"}

############################################################################
# Original file: poTcllib/poExif.tcl
############################################################################

# EXIF parser in Tcl
# Author: Darren New <dnew@san.rr.com>
# Translated directly from the Perl version
# by Chris Breeze <chris@breezesys.com>
# http://www.breezesys.com
# See the original comment block, reproduced
# at the bottom.
# Most of the inline comments about the meanings of fields
# are copied verbatim and without understanding from the
# original, unless "DNew" is there.
# Much of the structure is preserved, except in
# makerNote, where I got tired of typing as verbosely
# as the original Perl. But thanks for making it so
# readable that even someone who doesn't know Perl
# could translate it, Chris! ;-)
# PLEASE read and understand exif::fieldnames
# BEFORE making any changes here! Thanks!

# Usage of this version:
#     exif::analyze $stream ?$thumbnail?
# Stream should be an open file handle
# rewound to the start. It gets set to
# binary mode and is left at EOF or 
# possibly pointing at image data.
# You have to open and close the
# stream yourself.
# The return is a serialized array
# (a la [array get]) with informative
# english text about what was found.
# Errors in parsing or I/O or whatever
# throw errors.
#     exif::allfields
# returns a list of all possible field names.
# Added by DNew. Funky implementation.
#
# New
#     exif::analyzeFile $filename ?$thumbnail?
#
# If you find any mistakes here, feel free to correct them
# and/or send them to me. I just cribbed this - I don't even
# have a camera that puts this kind of info into the file.

# LICENSE: Standard BSD License.

# There's probably something here I'm using without knowing it.
package require Tcl 8.3

package provide poTcllib 1.0
package provide poExif   1.0

namespace eval ::poExif {
    namespace export analyze analyzeFile fieldnames
    variable debug 0 ; # set to 1 for puts of debug trace
    variable cameraModel ; # used internally to understand options
    variable jpeg_markers ; # so we only have to do it once
    variable intel ; # byte order - so we don't have to pass to every read
    variable cached_fieldnames ; # just what it says
    array set jpeg_markers {
        SOF0  \xC0
        DHT   \xC4
        SOI   \xD8
        EOI   \xD9
        SOS   \xDA
        DQT   \xDB
        DRI   \xDD
        APP1  \xE1
    }
}

proc ::poExif::debug {str} {
    variable debug
    if {$debug} {puts $str}
}

proc ::poExif::streq {s1 s2} {
    return [string equal $s1 $s2]
}

proc ::poExif::analyzeFile {file {thumbnail {}}} {
    set stream [open $file]
    set res [analyze $stream $thumbnail]
    close $stream
    return $res
}

proc ::poExif::analyze {stream {thumbnail {}}} {
    variable jpeg_markers
    array set result {}
    fconfigure $stream -translation binary -encoding binary
    while {![eof $stream]} {
        set ch [read $stream 1]
        if {1 != [string length $ch]} {error "End of file reached @1"}
        if {![streq "\xFF" $ch]} {break} ; # skip image data
        set marker [read $stream 1]
        if {1 != [string length $marker]} {error "End of file reached @2"}
        if {[streq $marker $jpeg_markers(SOI)]} {
            debug "SOI"
        } elseif {[streq $marker $jpeg_markers(EOI)]} {
            debug "EOI"
        } else {
            set msb [read $stream 1]
            set lsb [read $stream 1]
            if {1 != [string length $msb] || 1 != [string length $lsb]} {
                error "File truncated @1"
            }
            scan $msb %c msb ; scan $lsb %c lsb
            set size [expr {256 * $msb + $lsb}]
            set data [read $stream [expr {$size-2}]]
	    debug "read [expr {$size - 2}] bytes of data"
            if {[expr {$size-2}] != [string length $data]} {
                error "File truncated @2"
            }
            if {[streq $marker $jpeg_markers(APP1)]} {
                debug "APP1\t$size"
                array set result [app1 $data $thumbnail]
            } elseif {[streq $marker $jpeg_markers(DQT)]} {
                debug "DQT\t$size"
            } elseif {[streq $marker $jpeg_markers(SOF0)]} {
                debug "SOF0\t$size"
            } elseif {[streq $marker $jpeg_markers(DHT)]} {
                debug "DHT\t$size"
            } elseif {[streq $marker $jpeg_markers(SOS)]} {
                debug "SOS\t$size"
            } else {
                binary scan $marker H* x
                debug "UNKNOWN MARKER $x"
            }
        }
    }
    return [array get result]
}

proc ::poExif::app1 {data thumbnail} {
    variable intel
    variable cameraModel
    array set result {}
    if {![string equal [string range $data 0 5] "Exif\0\0"]} {
        error "APP1 does not contain EXIF"
    }
    debug "Reading EXIF data"
    set data [string range $data 6 end]
    set t [string range $data 0 1]
    if {[streq $t "II"]} {
        set intel 1
        debug "Intel byte alignment"
    } elseif {[streq $t "MM"]} {
        set intel 0
        debug "Motorola byte alignment"
    } else {
        error "Invalid byte alignment: $t"
    }
    if {[readShort $data 2]!=0x002A} {error "Invalid tag mark"}
    set curoffset [readLong $data 4] ; # just called "offset" in the Perl - DNew
    debug "Offset to first IFD: $curoffset"
    set numEntries [readShort $data $curoffset]
    incr curoffset 2
    debug "Number of directory entries: $numEntries"
    for {set i 0} {$i < $numEntries} {incr i} {
        set head [expr {$curoffset + 12 * $i}]
        set entry [string range $data $head [expr {$head+11}]]
        set tag [readShort $entry 0]
        set format [readShort $entry 2]
        set components [readLong $entry 4]
        set offset [readLong $entry 8]
        set value [readIFDEntry $data $format $components $offset]
        if {$tag==0x010e} {
            set result(ImageDescription) $value
        } elseif {$tag==0x010f} {
            set result(CameraMake) $value
        } elseif {$tag==0x0110} {
            set result(CameraModel) $value
            set cameraModel $value
        } elseif {$tag==0x0112} {
            set result(Orientation) $value
        } elseif {$tag == 0x011A} {
            set result(XResolution) $value
        } elseif {$tag == 0x011B} {
            set result(YResolution) $value
        } elseif {$tag == 0x0128} {
            set result(ResolutionUnit) "unknown"
            if {$value==2} {set result(ResolutionUnit) "inch"}
            if {$value==3} {set result(ResolutionUnit) "centimeter"}
        } elseif {$tag==0x0131} {
            set result(Software) $value
        } elseif {$tag==0x0132} {
            set result(DateTime) $value
        } elseif {$tag==0x0213} {
            set result(YCbCrPositioning) "unknown"
            if {$value==1} {set result(YCbCrPositioning) "Center of pixel array"}
            if {$value==2} {set result(YCbCrPositioning) "Datum point"}
        } elseif {$tag==0x8769} {
            # EXIF sub IFD
	    debug "==CALLING exifSubIFD=="
            array set result [exifSubIFD $data $offset]
        } else {
            debug "Unrecognized entry: Tag=$tag, value=$value"
        }
    }
    set offset [readLong $data [expr {$curoffset + 12 * $numEntries}]]
    debug "Offset to next IFD: $offset"
    array set thumb_result [exifSubIFD $data $offset]

    if {$thumbnail != {}} {
	set jpg [string range $data \
		$thumb_result(JpegIFOffset) \
		[expr {$thumb_result(JpegIFOffset) + $thumb_result(JpegIFByteCount) - 1}]]

        set         to [open $thumbnail w]
        fconfigure $to -translation binary -encoding binary
	puts       $to $jpg
        close      $to

        #can be used (with a JPG-aware TK) to add the image to the result array
	#set result(THUMB) [image create photo -file $thumbnail]
    }

    return [array get result]
}

# Extract EXIF sub IFD info
proc ::poExif::exifSubIFD {data curoffset} {
    debug "EXIF: offset=$curoffset"
    set numEntries [readShort $data $curoffset]
    incr curoffset 2
    debug "Number of directory entries: $numEntries"
    for {set i 0} {$i < $numEntries} {incr i} {
        set head [expr {$curoffset + 12 * $i}]
        set entry [string range $data $head [expr {$head+11}]]
        set tag [readShort $entry 0]
        set format [readShort $entry 2]
        set components [readLong $entry 4]
        set offset [readLong $entry 8]
        if {$tag==0x9000} {
            set result(ExifVersion) [string range $entry 8 11]
        } elseif {$tag==0x9101} {
            set result(ComponentsConfigured) [format 0x%08x $offset]
        } elseif {$tag == 0x927C} {
            array set result [makerNote $data $offset]
        } elseif {$tag == 0x9286} {
            # Apparently, this doesn't usually work.
            set result(UserComment) "$offset - [string range $data $offset [expr {$offset+8}]]"
            set result(UserComment) [string trim $result(UserComment) "\0"]
        } elseif {$tag==0xA000} {
            set result(FlashPixVersion) [string range $entry 8 11]
        } elseif {$tag==0xA300} {
            # 3 means digital camera
            if {$offset == 3} {
                set result(FileSource) "3 - Digital camera"
            } else {
                set result(FileSource) $offset
            }
        } else {
            set value [readIFDEntry $data $format $components $offset]
            if {$tag==0x829A} {
                if {0.3 <= $value} {
                    # In seconds...
                    set result(ExposureTime) "$value seconds"
                } else {
                    set result(ExposureTime) "1/[expr {1.0/$value}] seconds"
                }
            } elseif {$tag == 0x829D} {
                set result(FNumber) $value
            } elseif {$tag == 0x8822} {
		set result(ExposureProgram) "unknown"
                if {$value == 1} {
		    set result(ExposureProgram) "manual control"
                } elseif {$value == 2} {
		    set result(ExposureProgram) "program normal"
                } elseif {$value == 3} {
		    set result(ExposureProgram) "aperture priority"
                } elseif {$value == 4} {
		    set result(ExposureProgram) "shutter priority"
                } elseif {$value == 5} {
		    set result(ExposureProgram) "program creative"
                } elseif {$value == 6} {
		    set result(ExposureProgram) "program action"
                } elseif {$value == 7} {
		    set result(ExposureProgram) "portrait mode"
                } elseif {$value == 8} {
		    set result(ExposureProgram) "landscape mode"
		}
            } elseif {$tag == 0x9208} {
		set result(LightSource) "unknown"
                if {$value == 1} {
		    set result(LightSource) "daylight"
                } elseif {$value == 2} {
		    set result(LightSource) "fluorescent"
                } elseif {$value == 3} {
		    set result(LightSource) "tungsten"
                } elseif {$value == 10} {
		    set result(LightSource) "flash"
                } elseif {$value == 17} {
		    set result(LightSource) "standard light A"
                } elseif {$value == 18} {
		    set result(LightSource) "standard light B"
                } elseif {$value == 19} {
		    set result(LightSource) "standard light C"
                } elseif {$value == 20} {
		    set result(LightSource) "D55"
                } elseif {$value == 21} {
		    set result(LightSource) "D65"
                } elseif {$value == 22} {
		    set result(LightSource) "D75"
                } elseif {$value == 255} {
		    set result(LightSource) "other"
		}
            } elseif {$tag == 0x8827} {
                # D30 stores ISO here, G1 uses MakerNote Tag 1 field 16
                set result(ISOSpeedRatings) $value
            } elseif {$tag == 0x9003} {
                set result(DateTimeOriginal) $value
            } elseif {$tag == 0x9004} {
                set result(DateTimeDigitized) $value
            } elseif {$tag == 0x9102} {
                if {$value == 5} {
                    set result(ImageQuality) "super fine"
                } elseif {$value == 3} {
                    set result(ImageQuality) "fine"
                } elseif {$value == 2} {
                    set result(ImageQuality) "normal"
                } else {
                    set result(CompressedBitsPerPixel) $value
                }
            } elseif {$tag == 0x9201} {
                # Not very accurate, use Exposure time instead.
                #  (That's Chris' comment. I don't know what it means.)
                set value [expr {pow(2,$value)}]
                if {$value < 4} {
                    set value [expr {1.0 / $value}]
                    set value [expr {int($value * 10 + 0.5) / 10.0}]
                } else {
                    set value [expr {int($value + 0.49)}]
                }
                set result(ShutterSpeedValue) "$value Hz"
            } elseif {$tag == 0x9202} {
                set value [expr {int(pow(sqrt(2.0), $value) * 10 + 0.5) / 10.0}]
                set result(AperatureValue) $value
            } elseif {$tag == 0x9204} {
                set value [compensationFraction $value]
                set result(ExposureBiasValue) $value
            } elseif {$tag == 0x9205} {
                set value [expr {int(pow(sqrt(2.0), $value) * 10 + 0.5) / 10.0}]
            } elseif {$tag == 0x9206} {
                # May need calibration
                set result(SubjectDistance) "$value m"
            } elseif {$tag == 0x9207} {
                set result(MeteringMode) "other"
                if {$value == 0} {set result(MeteringMode) "unknown"} 
                if {$value == 1} {set result(MeteringMode) "average"} 
                if {$value == 2} {set result(MeteringMode) "center weighted average"} 
                if {$value == 3} {set result(MeteringMode) "spot"} 
                if {$value == 4} {set result(MeteringMode) "multi-spot"} 
                if {$value == 5} {set result(MeteringMode) "multi-segment"} 
                if {$value == 6} {set result(MeteringMode) "partial"} 
            } elseif {$tag == 0x9209} {
                if {$value == 0} {
                    set result(Flash) no
                } elseif {$value == 1} {
                    set result(Flash) yes
                } else {
                    set result(Flash) "unknown: $value"
                }
            } elseif {$tag == 0x920a} {
                set result(FocalLength) "$value mm"
            } elseif {$tag == 0xA001} {
                set result(ColorSpace) $value
            } elseif {$tag == 0xA002} {
                set result(ExifImageWidth) $value
            } elseif {$tag == 0xA003} {
                set result(ExifImageHeight) $value
            } elseif {$tag == 0xA005} {
                set result(ExifInteroperabilityOffset) $value
            } elseif {$tag == 0xA20E} {
                set result(FocalPlaneXResolution) $value
            } elseif {$tag == 0xA20F} {
                set result(FocalPlaneYResolution) $value
            } elseif {$tag == 0xA210} {
                set result(FocalPlaneResolutionUnit) "none"
                if {$value == 2} {set result(FocalPlaneResolutionUnit) "inch"}
                if {$value == 3} {set result(FocalPlaneResolutionUnit) "centimeter"} 
            } elseif {$tag == 0xA217} {
                # 2 = 1 chip color area sensor
                set result(SensingMethod) $value
            } elseif {$tag == 0xA401} {
		#TJE
		set result(SensingMethod) "normal"
                if {$value == 1} {set result(SensingMethod) "custom"}
            } elseif {$tag == 0xA402} {
		#TJE
                set result(ExposureMode) "auto"
                if {$value == 1} {set result(ExposureMode) "manual"}
                if {$value == 2} {set result(ExposureMode) "auto bracket"}
            } elseif {$tag == 0xA403} {
		#TJE
                set result(WhiteBalance) "auto"
                if {$value == 1} {set result(WhiteBalance) "manual"}
            } elseif {$tag == 0xA404} {
                # digital zoom not used if number is zero
		set result(DigitalZoomRatio) "not used"
                if {$value != 0} {set result(DigitalZoomRatio) $value}
            } elseif {$tag == 0xA405} {
		set result(FocalLengthIn35mmFilm) "unknown"
                if {$value != 0} {set result(FocalLengthIn35mmFilm) $value}
            } elseif {$tag == 0xA406} {
                set result(SceneCaptureType) "Standard"
                if {$value == 1} {set result(SceneCaptureType) "Landscape"} 
                if {$value == 2} {set result(SceneCaptureType) "Portrait"}
                if {$value == 3} {set result(SceneCaptureType) "Night scene"}
            } elseif {$tag == 0xA407} {
                set result(GainControl) "none"
                if {$value == 1} {set result(GainControl) "Low gain up"} 
                if {$value == 2} {set result(GainControl) "High gain up"}
                if {$value == 3} {set result(GainControl) "Low gain down"}
                if {$value == 4} {set result(GainControl) "High gain down"}
            } elseif {$tag == 0x0103} {
		#TJE
		set result(Compression) "unknown"
		if {$value == 1} {set result(Compression) "none"}
		if {$value == 6} {set result(Compression) "JPEG"}
            } elseif {$tag == 0x011A} {
		#TJE
		set result(XResolution) $value
            } elseif {$tag == 0x011B} {
		#TJE
		set result(YResolution) $value
            } elseif {$tag == 0x0128} {
		#TJE
		set result(ResolutionUnit) "unknown"
		if {$value == 1} {set result(ResolutionUnit) "inch"}
		if {$value == 6} {set result(ResolutionUnit) "cm"}
            } elseif {$tag == 0x0201} {
		#TJE
		set result(JpegIFOffset) $value
		debug "offset = $value"
            } elseif {$tag == 0x0202} {
		#TJE
		set result(JpegIFByteCount) $value
		debug "bytecount = $value"
            } else {
                error "Unrecognized EXIF Tag: $tag (0x[string toupper [format %x $tag]])"
            }
        }
    }
    return [array get result]
}

# Canon proprietary data that I didn't feel like translating to Tcl yet.
proc ::poExif::makerNote {data curoffset} {
    variable cameraModel
    debug "MakerNote: offset=$curoffset"

    array set result {}
    set numEntries [readShort $data $curoffset]
    incr curoffset 2
    debug "Number of directory entries: $numEntries"
    for {set i 0} {$i < $numEntries} {incr i} {
        set head [expr {$curoffset + 12 * $i}]
        set entry [string range $data $head [expr {$head+11}]]
        set tag [readShort $entry 0]
        set format [readShort $entry 2]
        set components [readLong $entry 4]
        set offset [readLong $entry 8]
        debug "$i)\tTag: $tag, format: $format, components: $components"

        if {$tag==6} {
            set value [readIFDEntry $data $format $components $offset]
            set result(ImageFormat) $value
        } elseif {$tag==7} {
            set value [readIFDEntry $data $format $components $offset]
            set result(FirmwareVersion) $value
        } elseif {$tag==8} {
            set value [string range $offset 0 2]-[string range $offset 3 end]
            set result(ImageNumber) $value
        } elseif {$tag==9} {
            set value [readIFDEntry $data $format $components $offset]
            set result(Owner) $value
        } elseif {$tag==0x0C} {
            # camera serial number
            set msw [expr {($offset >> 16) & 0xFFFF}]
            set lsw [expr {$offset & 0xFFFF}]
            set result(CameraSerialNumber) [format %04X%05d $msw $lsw]
        } elseif {$tag==0x10} {
            set result(UnknownTag-0x10) $offset
        } else {
            if {$format == 3 && 1 < $components} {
                debug "MakerNote $i: TAG=$tag"
                catch {unset field}
                array set field {}
                for {set j 0} {$j < $components} {incr j} {
                    set field($j) [readShort $data [expr {$offset+2*$j}]]
                    debug "$j : $field($j)"
                }
                if {$tag == 1} {
                    if {![string match -nocase "*Pro90*" $cameraModel]} {
                        if {$field(1)==1} {
                            set result(MacroMode) macro
                        } else {
                            set result(MacroMode) normal
                        }
                    }
                    if {0 < $field(2)} {
                        set result(SelfTimer) "[expr {$field(2)/10.0}] seconds"
                    }
                    set result(ImageQuality) [switch $field(3) {
                        2 {format Normal}
                        3 {format Fine}
                        4 {format "CCD Raw"}
                        5 {format "Super fine"}
                        default {format ""}
                    }]
                    set result(FlashMode) [switch $field(4) {
                        0 {format off}
                        1 {format auto}
                        2 {format on}
                        3 {format "red eye reduction"}
                        4 {format "slow synchro"}
                        5 {format "auto + red eye reduction"}
                        6 {format "on + red eye reduction"}
                        default {format ""}
                    }]
                    if {$field(5)} {
                        set result(ShootingMode) "Continuous"
                    } else {
                        set result(ShootingMode) "Single frame"
                    }
                    # Field 6 - don't know what it is.
                    set result(AutoFocusMode) [switch $field(7) {
                        0 {format "One-shot"}
                        1 {format "AI servo"}
                        2 {format "AI focus"}
                        3 - 6 {format "MF"}
                        5 {format "Continuous"}
                        4 {
                            # G1: uses field 32 to store single/continuous,
                            # and always sets 7 to 4.
                            if {[info exists field(32)] && $field(32)} {
                                format "Continuous"
                            } else {
                                format "Single"
                            }
                        }
                        default {format unknown}
                    }]
                    # Field 8 and 9 are unknown
                    set result(ImageSize) [switch $field(10) {
                        0 {format "large"}
                        1 {format "medium"}
                        2 {format "small"}
                        default {format "unknown"}
                    }]
                    # Field 11 - easy shooting - see field 20
                    # Field 12 - unknown
                    set NHL {
                        0 {format "Normal"}
                        1 {format "High"}
                        65536 {format "Low"}
                        default {format "Unknown"}
                    }
                    set result(Contrast) [switch $field(13) $NHL]
                    set result(Saturation) [switch $field(14) $NHL]
		    set result(Sharpness) [switch $field(15) $NHL]
                    set result(ISO) [switch $field(16) {
                        15 {format Auto}
                        16 {format 50}
                        17 {format 100}
                        18 {format 200}
                        19 {format 400}
                        default {format "unknown"}
                    }]
                    set result(MeteringMode) [switch $field(17) {
                        3 {format evaluative}
                        4 {format partial}
                        5 {format center-weighted}
                        default {format unknown}
                    }]
                    # Field 18 - unknown
                    set result(AFPoint) [switch -- [expr {$field(19)-0x3000}] {
                        0 {format none}
                        1 {format auto-selected}
                        2 {format right}
                        3 {format center}
                        4 {format left}
                        default {format unknown}
                    }] ; # {}
		    if {[info exists field(20)]} {
			if {$field(20) == 0} {
			    set result(ExposureMode) [switch $field(11) {
				0 {format auto}
				1 {format manual}
				2 {format landscape}
				3 {format "fast shutter"}
				4 {format "slow shutter"}
				5 {format "night scene"}
				6 {format "black and white"}
				7 {format sepia}
				8 {format portrait}
				9 {format sports}
				10 {format close-up}
				11 {format "pan focus"}
				default {format unknown}
			    }] ; # {}
			} elseif {$field(20) == 1} {
			    set result(ExposureMode) program
			} elseif {$field(20) == 2} {
			    set result(ExposureMode) Tv
			} elseif {$field(20) == 3} {
			    set result(ExposureMode) Av
			} elseif {$field(20) == 4} {
			    set result(ExposureMode) manual
			} elseif {$field(20) == 5} {
			    set result(ExposureMode) A-DEP
			} else {
			    set result(ExposureMode) unknown
			}
		    }
                    # Field 21 and 22 are unknown
                    # Field 23: max focal len, 24 min focal len, 25 units per mm
		    if {[info exists field(23)] && [info exists field(25)]} {
			set result(MaxFocalLength) \
				"[expr {1.0 * $field(23) / $field(25)}] mm"
		    }
                    if {[info exists field(24)] && [info exists field(25)]} {
			set result(MinFocalLength) \
				"[expr {1.0 * $field(24) / $field(25)}] mm"
		    }
                    # Field 26-28 are unknown.
		    if {[info exists field(29)]} {
			if {$field(29) & 0x0010} {
			    lappend result(FlashMode) "FP_sync_enabled"
			}
			if {$field(29) & 0x0800} {
			    lappend result(FlashMode) "FP_sync_used"
			}
			if {$field(29) & 0x2000} {
			    lappend result(FlashMode) "internal_flash"
			}
			if {$field(29) & 0x4000} {
			    lappend result(FlashMode) "external_E-TTL"
			}
		    }
                    if {[info exists field(34)] && \
			    [string match -nocase "*pro90*" $cameraModel]} {
                        if {$field(34)} {
                            set result(ImageStabilisation) on
                        } else {
                            set result(ImageStabilisation) off
                        }
                    }
                } elseif {$tag == 4} {
                    set result(WhiteBalance) [switch $field(7) {
                        0 {format Auto}
                        1 {format Daylight}
                        2 {format Cloudy}
                        3 {format Tungsten}
                        4 {format Fluorescent}
                        5 {format Flash}
                        6 {format Custom}
                        default {format Unknown}
                    }]
                    if {$field(14) & 0x07} {
                        set result(AFPointsUsed) \
                            [expr {($field(14)>>12) & 0x0F}]
                        if {$field(14)&0x04} {
                            append result(AFPointsUsed) " left"
                        }
                        if {$field(14)&0x02} {
                            append result(AFPointsUsed) " center"
                        }
                        if {$field(14)&0x01} {
                            append result(AFPointsUsed) " right"
                        }
                    }
		    if {[info exists field(15)]} {
			set v $field(15)
			if {32768 < $v} {incr v -65536}
			set v [compensationFraction [expr {$v / 32.0}]]
			set result(FlashExposureCompensation) $v
		    }
		    if {[info exists field(19)]} {
			set result(SubjectDistance) "$field(19) m"
		    }
                } elseif {$tag == 15} {
                    foreach k [array names field] {
                        set func [expr {($field($k) >> 8) & 0xFF}]
                        set v [expr {$field($k) & 0xFF}]
                        if {$func==1 && $v} {
                            set result(LongExposureNoiseReduction) on
                        } elseif {$func==1 && !$v} {
                            set result(LongExposureNoiseReduction) off
                        } elseif {$func==2} {
                            set result(Shutter/AE-Lock) [switch $v {
                                0 {format "AF/AE lock"}
                                1 {format "AE lock/AF"}
                                2 {format "AF/AF lock"}
                                3 {format "AE+release/AE+AF"}
                                default {format "Unknown"}
                            }]
                        } elseif {$func==3} {
                            if {$v} {
                                set result(MirrorLockup) enable
                            } else {
                                set result(MirrorLockup) disable
                            }
                        } elseif {$func==4} {
                            if {$v} {
                                set result(Tv/AvExposureLevel) "1/3 stop"
                            } else {
                                set result(Tv/AvExposureLevel) "1/2 stop"
                            }
                        } elseif {$func==5} {
                            if {$v} {
                                set result(AFAssistLight) off
                            } else {
                                set result(AFAssistLight) on
                            }
                        } elseif {$func==6} {
                            if {$v} {
                                set result(ShutterSpeedInAVMode) "Fixed 1/200"
                            } else {
                                set result(ShutterSpeedInAVMode) "Auto"
                            }
                        } elseif {$func==7} {
                            set result(AEBSeq/AutoCancel) [switch $v {
                                0 {format "0, -, + enabled"}
                                1 {format "0, -, + disabled"}
                                2 {format "-, 0, + enabled"}
                                3 {format "-, 0, + disabled"}
                                default {format unknown}
                            }]
                        } elseif {$func==8} {
                            if {$v} {
                                set result(ShutterCurtainSync) "2nd curtain sync"
                            } else {
                                set result(ShutterCurtainSync) "1st curtain sync"
                            }
                        } elseif {$func==9} {
                            set result(LensAFStopButtonFnSwitch) [switch $v {
                                0 {format "AF stop"}
                                1 {format "operate AF"}
                                2 {format "lock AE and start timer"}
                                default {format unknown}
                            }]
                        } elseif {$func==10} {
                            if {$v} {
                                set result(AutoReductionOfFillFlash) disable
                            } else {
                                set result(AutoReductionOfFillFlash) enable
                            }
                        } elseif {$func==11} {
                            if {$v} {
                                set result(MenuButtonReturnPosition) previous
                            } else {
                                set result(MenuButtonReturnPosition) top
                            }
                        } elseif {$func==12} {
                            set result(SetButtonFuncWhenShooting) [switch $v {
                                0 {format "not assigned"}
                                1 {format "change quality"}
                                2 {format "change ISO speed"}
                                3 {format "select parameters"}
                                default {format unknown}
                            }]
                        } elseif {$func==13} {
                            if {$v} {
                                set result(SensorCleaning) enable
                            } else {
                                set result(SensorCleaning) disable
                            }
                        } elseif {$func==0} {
                            # Discovered by DNew?
                            set result(CameraOwner) $v
                        } else {
                            append result(UnknownCustomFunc) "$func=$v "
                        }
                    }
                }
            } else {
                debug [format "makerNote: Unrecognized TAG: 0x%x" $tag]
            }
        }
    }
    return [array get result]
}

proc ::poExif::readShort {data offset} {
    variable intel
    if {[string length $data] < [expr {$offset+2}]} {
        error "readShort: end of string reached"
    }
    set ch1 [string index $data $offset]
    set ch2 [string index $data [expr {$offset+1}]]
    scan $ch1 %c ch1 ; scan $ch2 %c ch2
    if {$intel} {
        return [expr {$ch1 + 256 * $ch2}]
    } else {
        return [expr {$ch2 + 256 * $ch1}]
    }
}

proc ::poExif::readLong {data offset} {
    variable intel
    if {[string length $data] < [expr {$offset+4}]} {
        error "readLong: end of string reached"
    }
    set ch1 [string index $data $offset]
    set ch2 [string index $data [expr {$offset+1}]]
    set ch3 [string index $data [expr {$offset+2}]]
    set ch4 [string index $data [expr {$offset+3}]]
    scan $ch1 %c ch1 ; scan $ch2 %c ch2
    scan $ch3 %c ch3 ; scan $ch4 %c ch4
    if {$intel} {
        return [expr {(((($ch4 * 256) + $ch3) * 256) + $ch2) * 256 + $ch1}]
    } else {
        return [expr {(((($ch1 * 256) + $ch2) * 256) + $ch3) * 256 + $ch4}]
    }
}

proc ::poExif::readIFDEntry {data format components offset} {
    variable intel
    if {$format == 2} {
        # ASCII string
        set value [string range $data $offset [expr {$offset+$components-1}]]
        return [string trimright $value "\0"]
    } elseif {$format == 3} {
        # unsigned short
        if {!$intel} {
            set offset [expr {0xFFFF & ($offset >> 16)}]
        }
        return $offset
    } elseif {$format == 4} {
        # unsigned long
        return $offset
    } elseif {$format == 5} {
        # unsigned rational
        # This could be messy, if either is >2**31
        set numerator [readLong $data $offset]
        set denominator [readLong $data [expr {$offset + 4}]]
        return [expr {(1.0*$numerator)/$denominator}]
    } elseif {$format == 10} {
        # signed rational
        # Should work normally, since everything in Tcl is signed
        set numerator [readLong $data $offset]
        set denominator [readLong $data [expr {$offset + 4}]]
        return [expr {(1.0*$numerator)/$denominator}]
    } else {
        set x [format %08x $format]
        error "Invalid IFD entry format: $x"
    }
}

proc ::poExif::compensationFraction {value} {
    if {$value==0} {return 0}
    if {$value < 0} {
        set result "-"
        set value [expr {0-$value}]
    } else {
        set result "+"
    }
    set value [expr {int(0.5 + $value * 6)}]
    set integer [expr {int($value / 6)}]
    set sixths [expr {$value % 6}]
    if {$integer != 0} {
        append result $integer
        if {$sixths != 0} {
            append result " "
        }
    }
    if {$sixths == 2} {
        append result "1/3"
    } elseif {$sixths == 3} {
        append result "1/2" 
    } elseif {$sixths == 4} {
        append result "2/3"
    } else {
        # Added by DNew
        append result "$sixths/6"
    }
    return $result
}

# This returns the list of all possible fieldnames
# that analyze might return.
proc ::poExif::fieldnames {} {
    variable cached_fieldnames 
    if {[info exists cached_fieldnames]} {
        return $cached_fieldnames
    }
    # Otherwise, parse the source to find the fieldnames.
    # Cool, huh? Don'tcha just love Tcl?
    # Because of this, "result(...)" should only appear
    # in these functions when "..." is the literal name
    # of a field to be returned.
    array set namelist {}
    foreach proc {analyze app1 exifSubIFD makerNote} {
        set body [info body ::poExif::$proc]
        foreach line [split $body \n] {
            if {[regexp {result\(([^)]+)\)} $line junk name]} {
                set namelist($name) {}
            }
        }
    }
    set cached_fieldnames [lsort -dictionary [array names namelist]]
    return $cached_fieldnames
}

proc ::poExif::Init {} {
}

::poExif::Init
catch {puts "Loaded Package poTcllib (Module [info script])"}

############################################################################
# Original file: poTcllib/poLock.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poLock
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poLock.tcl
#
#       First Version:  2000 / 06 / 19
#       Author:         Paul Obermeier
#
#       Description:
#			This package provides methods used by the WebFlop
#			distribution.
#			WebFlop stands for "WebServer on a Floppy disk".
#			
#       Additional documentation:
#
#
#       Exported functions:
#                       ::poLock::Init
#                       ::poLock::LockFile
#                       ::poLock::UnlockFile
#
############################################################################

package provide poTcllib 1.0
package provide poLock  1.0

namespace eval ::poLock {
    namespace export Init
    namespace export LockFile
    namespace export UnlockFile
    namespace export SetVerboseMode
    namespace export SetLockExtension

    namespace export Test

    variable lockExt
    variable verbose
}

proc ::poLock::SetVerboseMode { { verboseMode 0 } } {
    variable verbose

    set verbose $verboseMode
}

proc ::poLock::SetLockExtension { { lockExtension "lck" } } {
    variable lockExt

    set lockExt $lockExtension
}

###########################################################################
#[@e
#       Name:           ::poLock::Init
#
#       Usage:          Initialize this package.
#
#       Synopsis:       proc ::poLock::Init {}
#
#       Description:    
#
#       Return Value:   None.
#
#       See also:	::poLock::LockFile
#       		::poLock::UnlockFile
#
###########################################################################

proc ::poLock::Init {} {
    ::poLock::SetVerboseMode
    ::poLock::SetLockExtension
}

###########################################################################
#[@e
#       Name:           ::poLock::LockFile
#
#       Usage:          Lock a file.
#
#       Synopsis:       proc ::poLock::LockFile { fileName { timeOutSec 10.0 } }
#
#       Description:    fileName:   string
#			timeOutSec: double
#
#			Simple platform independent file locking.
#			
#
#       Return Value:   1, if the file could be locked, 0 otherwise.
#
#       See also:	::poLock::UnlockFile
#
###########################################################################

proc ::poLock::LockFile { fileName { timeOutSec 10.0 } } {
    variable lockExt
    variable verbose

    set lockFile "$fileName.$lockExt"
    set checkTime 0.0
    set checkInterval 1.0
    if { $verbose } {
        puts -nonewline "Trying to lock $fileName "
        flush stdout
    }

    while { [file exists $lockFile] } {
	if { $verbose } {
	    puts -nonewline "."
	    flush stdout
	}
	after [expr int ($checkInterval * 1000.0)]
	set checkTime [expr $checkTime + $checkInterval]
	if { $checkTime > $timeOutSec } {
	    if { $verbose } {
		set catchVal [catch {open $lockFile r} fp] 
    		if { $catchVal != 0 } {  
        	    puts "Could not open lockfile \"$lockFile\" for reading."
    		} else {
		    set lockedBy [gets $fp]
		    close $fp
	        }
	        puts "\nLocking of file $fileName failed."
	        puts "File is locked by host $lockedBy."
	    }
	    return 0
	}
    }

    set catchVal [catch { open $lockFile "w" } fp] 
    if { $catchVal != 0 } {  
	if { $verbose } {
            puts "Could not open lockfile \"$lockFile\" for reading."
	}
	return 0
    } else {
        puts $fp "[info hostname]"
        close $fp
    }
    if { $verbose } {
        puts "\nLocking of file $fileName successful"
        flush stdout
    }
    return 1
}

###########################################################################
#[@e
#       Name:           ::poLock::UnlockFile
#
#       Usage:          Unlock a file.
#
#       Synopsis:       proc ::poLock::UnlockFile { fileName }
#
#       Description:    fileName: string
#
#       Return Value:   1, if the file could be unlocked, 0 otherwise.
#
#       See also:	::poLock::LockFile
#
###########################################################################

proc ::poLock::UnlockFile { fileName } {
    variable lockExt
    variable verbose

    set lockFile "$fileName.$lockExt"
    file delete $lockFile
    if { $verbose } {
        puts "File $fileName unlocked."
        flush stdout
    }
    return 1
}

###########################################################################
#[@e
#       Name:           ::poLock::Test
#
#       Usage:          Test function of this package.
#
#       Synopsis:       proc ::poLock::Test { fileName }
#
#       Description:    fileName: string
#
#       Return Value:   1, if the file could be unlocked, 0 otherwise.
#
#       See also:	::poLock::LockFile
#       		::poLock::UnlockFile
#
###########################################################################

proc ::poLock::Test { testFile } {
    SetVerboseMode true
    set retVal [catch {open $testFile w} fp]
    if { $retVal != 0 } {
        tk_messageBox -message "Could not open $testFile for writing" \
                      -icon warning -type ok
        return false
    }
    if { ! [LockFile $testFile] } {
	tk_messageBox -message "Could not lock file $testFile" \
                      -icon warning -type ok
        return false 
    }

    puts $fp "Written to file"

    if { ! [UnlockFile $testFile] } {
	tk_messageBox -message "Could not unlock file $testFile" \
                      -icon warning -type ok
        return false 
    }
    close $fp
    return true
}

::poLock::Init
catch {puts "Loaded Package poTcllib (Module [info script])"}

############################################################################
# Original file: poTcllib/poLog.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poLog
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poLog.tcl
#
#       First Version:  2000 / 03 / 20
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#                       ::poLog::ShowConsole
#                       ::poLog::GetConsoleMode
#                       ::poLog::GetDebugLevels
#                       ::poLog::SetDebugLevels
#                       ::poLog::Info
#                       ::poLog::Warning
#                       ::poLog::Error
#                       ::poLog::Debug
#                       ::poLog::Callstack
#                       ::poLog::Test
#
############################################################################

package provide poTcllib 1.0
package provide poLog 1.0

# OPA TODO
#  set ::DEBUG 1
#  if {[info exists ::DEBUG] && $::DEBUG} \
#  { interp alias {} PUTS {} puts } \
#  else \
#  {
#    proc NULL {args} {}
#    interp alias {} PUTS {} NULL
#  }
#

namespace eval ::poLog {
    namespace export ShowConsole
    namespace export GetConsoleMode
    namespace export GetDebugLevels
    namespace export SetDebugLevels
    namespace export Info
    namespace export Warning
    namespace export Error
    namespace export Debug
    namespace export Callstack

    namespace export Test

    # Public variables.
    variable levelOff       0
    variable levelInfo      1
    variable levelWarning   2
    variable levelError     3
    variable levelDebug     4
    variable levelCallstack 5

    # Private variables.
    variable debugLevels
    variable debugFp
    variable consoleMode
}

# Init is called at package load time.

proc ::poLog::Init {} {
    variable debugLevels
    variable debugFp
    variable levelOff

    ::poLog::SetDebugLevels $levelOff
    ::poLog::ShowConsole 0
    set debugFp stderr
}

###########################################################################
#[@e
#       Name:           ::poLog::ShowConsole
#
#       Usage:          Show logging console.
#
#       Synopsis:       proc ::poLog::ShowConsole { { onOff 1 } }
#
#       Description:    Switch logging console on or off.
#
#       Return Value:   None.
#
#       See also:       ::poLog::GetConsoleMode
#                       ::poLog::SetDebugLevels
#                       ::poLog::GetDebugLevels
#                       ::poLog::Info
#                       ::poLog::Warning
#                       ::poLog::Error
#                       ::poLog::Debug
#                       ::poLog::Callstack
#
###########################################################################

proc ::poLog::ShowConsole { { onOff 1 } } {
    global tcl_platform
    variable levelOff
    variable consoleMode

    if { $onOff } {
        catch { ::poConsole::create .poSoft:console {po> } {poSoft Console} }
        set consoleMode 1
    } else {
        catch { destroy .poSoft:console }
        set consoleMode 0
    }
}

###########################################################################
#[@e
#       Name:           ::poLog::GetConsoleMode
#
#       Usage:          Logging console mode.
#
#       Synopsis:       proc ::poLog::GetConsoleMode {}
#
#       Description:    Get current console mode.
#
#       Return Value:   1, if console mode is on, 0 otherwise.
#
#       See also:       ::poLog::ShowConsole
#                       ::poLog::SetDebugLevels
#                       ::poLog::GetDebugLevels
#                       ::poLog::Info
#                       ::poLog::Warning
#                       ::poLog::Error
#                       ::poLog::Debug
#                       ::poLog::Callstack
#
###########################################################################

proc ::poLog::GetConsoleMode {} {
    variable consoleMode

    return $consoleMode
}

###########################################################################
#[@e
#       Name:           ::poLog::GetDebugLevels
#
#       Usage:          Get current debug levels.
#
#       Synopsis:       proc ::poLog::GetDebugLevels {}
#
#       Description:   
#
#
#       Return Value:   List of debug levels.
#
#       See also:       ::poLog::SetDebugLevels
#                       ::poLog::Info
#                       ::poLog::Warning
#                       ::poLog::Error
#                       ::poLog::Debug
#                       ::poLog::Callstack
#
###########################################################################

proc ::poLog::GetDebugLevels {} {
    variable debugLevels

    return $debugLevels
}

###########################################################################
#[@e
#       Name:           ::poLog::SetDebugLevels
#
#       Usage:          Set current debug levels.
#
#       Synopsis:       proc ::poLog::SetDebugLevels { levelList }
#
#       Description:    A list of debug levels, which may be any of:
#                       ::poLog::levelOff       Switch off debugging output.
#                       ::poLog::levelInfo
#                       ::poLog::levelWarning
#                       ::poLog::levelError
#                       ::poLog::levelDebug
#                       ::poLog::levelCallstack
#
#       Return Value:   None.
#
#       See also:       ::poLog::GetDebugLevels
#                       ::poLog::Info
#                       ::poLog::Warning
#                       ::poLog::Error
#                       ::poLog::Debug
#                       ::poLog::Callstack
#
###########################################################################

proc ::poLog::SetDebugLevels { { levelList {::poLog::levelOff} } } {
    variable debugLevels
    variable levelOff

    set debugLevels {}
    foreach lev $levelList {
        if { $lev > $levelOff } {
            lappend debugLevels $lev
        } else {
            set debugLevels $levelOff
            return
        }
    }
}

# Utility function for the following message setting functions.
proc ::poLog::PrintDebug { str level } {
    variable debugLevels
    variable debugFp
    variable levelOff
    variable consoleMode

    if { ! $consoleMode } {
        return
    }

    if { [lsearch -exact $debugLevels $level] >= 0 } {
        for { set i 0 } { $i < [info level] } { incr i } {
            catch { puts -nonewline $debugFp "  " }
        }
        catch { puts $debugFp "[info level -1]" }
    }
}

###########################################################################
#[@e
#       Name:           ::poLog::Info
#
#       Usage:          Print debugging message at information level.
#
#       Synopsis:       proc ::poLog::Info { str }
#
#       Description:    str:   string
#
#                       Print debug message "str", if ::poLog::levelInfo was
#                       set with ::poLog::SetDebugLevels.
#
#       Return Value:   None.
#
#       See also:       ::poLog::GetDebugLevels
#                       ::poLog::SetDebugLevels
#
###########################################################################

proc ::poLog::Info { str } {
    variable levelInfo
    PrintDebug $str $levelInfo
}

proc ::poLog::Warning { str } {
    variable levelWarning
    PrintDebug $str $levelWarning
}

proc ::poLog::Error { str } {
    variable levelError
    PrintDebug $str $levelError
}

proc ::poLog::Debug { str } {
    variable levelDebug
    PrintDebug $str $levelDebug
}

proc ::poLog::Callstack { str } {
    variable levelCallstack
    PrintDebug $str $levelCallstack
}

# Utility function for Test.

proc ::poLog::P { str verbose } {
    if { $verbose } {
        puts $str
    }
}

###########################################################################
#[@e
#       Name:           ::poLog::Test
#
#       Usage:          Test the debug package.
#
#       Synopsis:       proc ::poLog::Test { { verbose true } }
#
#       Description:    verbose: boolean (Default: true)
#
#                       Simple test to check the correctness of this package.
#                       if "verbose" is true, messages are printed out,
#                       otherwise test runs silently.
#
#       Return Value:   true / false.
#
#       See also:       ::poLog::GetDebugLevels
#                       ::poLog::SetDebugLevels
#                       ::poLog::Info
#                       ::poLog::Warning
#                       ::poLog::Error
#                       ::poLog::Debug
#                       ::poLog::Callstack
#
###########################################################################

proc ::poLog::Test { { verbose true } } {
    variable levelOff
    variable levelInfo
    variable levelWarning
    variable levelError
    variable levelDebug
    variable levelCallstack

    set retVal 1

    P "" $verbose
    P "Start of debug test" $verbose

    ShowConsole 1
    for { set l $levelOff } { $l <= $levelDebug } { incr l } {
        P "Setting debug level to: $l" $verbose
        SetDebugLevels $l

        Info      "This debug message should be printed at level Info"
        Warning   "This debug message should be printed at level Warning"
        Error     "This debug message should be printed at level Error"
        Debug     "This debug message should be printed at level Debug"
        Callstack "This debug message should be printed at level Callstack"

        P "" $verbose
    }

    P "Test finished" $verbose
    return $retVal
}

::poLog::Init
catch {puts "Loaded Package poTcllib (Module [info script])"}

############################################################################
# Original file: poTcllib/poMisc.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poMisc
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poMisc.tcl
#
#       First Version:  2000 / 01 / 23
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#
############################################################################

package provide poTcllib 1.0
package provide poMisc 1.0

namespace eval ::poMisc {
    namespace export Init
    namespace export FileIdent
    namespace export SearchInFile
    namespace export ReplaceInFile
    namespace export SearchReplaceInFile
    namespace export FileCat
    namespace export FileConvert
    namespace export DiskUsage
    namespace export GetFileInfoLabels
    namespace export FormatByteSize
    namespace export FileInfo
    namespace export FileIsBinary
    namespace export FileSlashName
    namespace export HexDump
    namespace export QuoteSpaces
    namespace export CompactSpaces
    namespace export SplitMultSpaces
    namespace export AddNewlines
    namespace export Abs
    namespace export Min
    namespace export Max
    namespace export Plural
    namespace export RandomInit
    namespace export Random
    namespace export RandomRange
    namespace export DegToRad
    namespace export RadToDeg
    namespace export ArrayToList
    namespace export ListToArray
    namespace export GetTmpDir
    namespace export GetDesktopDir
    namespace export GetHomeDir
    namespace export GetCfgFile
    namespace export GetFileAttr
    namespace export IsHiddenFile
    namespace export GetDirList
    namespace export PrintMachineInfo
    namespace export PrintTclInfo
    namespace export GetExecutable
    namespace export DecToRgb
    namespace export RgbToDec
    namespace export Bitset
    namespace export GetBitsetIndices
    namespace export CharToNum
    namespace export NumToChar

    variable PI 3.1415926535
    variable randomSeed 1.0
    variable tclVers84Up 0
}

proc ::poMisc::Init {} {
    variable tclVers84Up

    # Check if Tcl version is greater than 8.4.
    # glob semantics has changed slightly with 8.4.
    if { [package vcompare "8.4" [info tclversion]] <= 0 } {
        set tclVers84Up 1
    }

    # Check if glob patch exists. If yes, use the fast routines.
    set catchVal [catch { glob -types !d * }]
    if { $catchVal } {
        if { $tclVers84Up } {
            rename ::poMisc::GetDirListSlow84Up ::poMisc::GetDirList
        } else {
            #rename ::poMisc::GetDirListSlow ::poMisc::GetDirList
            rename ::poMisc::GetDirListSlow84Up ::poMisc::GetDirList
        }
    } else {
        rename ::poMisc::GetDirListFast ::poMisc::GetDirList
    }
}

proc ::poMisc::FileSlashName { fileName } {
    global tcl_platform

    # Convert file or directory name to Unix slash notation
    set slashName [file join $fileName ""]
    # Use the long name on Windows. Looks nicer in file lists. :-)
    if { [string compare $tcl_platform(platform) "windows"] == 0 } {
        if { [file exists $slashName] } {
            set slashName [file attributes $slashName -longname]
        }
    }
    return $slashName
}

proc ::poMisc::FileIsBinary { fileName } {
    set catchVal [catch { open $fileName r } fp]
    if { $catchVal } {
        error "Could not open file \"$fileName\" for reading."
    }
    set sample [read $fp 1024]
    close $fp
    set numNulls [string first \x00 $sample]
    return [expr $numNulls >= 0]
}

proc ::poMisc::FileCat {args} {
    foreach filename $args {
        # Don't bother catching errors, just let them propagate up
        set fd [open $filename r]
        # Use the [file size] command to get the size, which preallocates
        # memory rather than trying to grow it as the read progresses.
        set size [file size $filename]
        if {$size} {
            append data [read $fd $size]
        } else {
            # if the file has zero bytes it is either empty, or something 
            # where [file size] reports 0 but the file actually has data (like
            # the files in the /proc filesystem on Linux)
            append data [read $fd]
        }
        close $fd
    }
    return $data
}

proc ::poMisc::FileConvert { fileName mode } {
    set size [file size $fileName]
    if { $size } {
        set catchVal [catch { open $fileName r } fpIn]
        if { $catchVal } {
            error "Could not open file \"$fileName\" for reading."
        }
        fconfigure $fpIn -translation auto
        set data [read $fpIn $size]
        close $fpIn
        set catchVal [catch { open $fileName w } fpOut]
        if { $catchVal } {
            error "Could not open file \"$fileName\" for writing."
        }
        fconfigure $fpOut -translation $mode
        puts -nonewline $fpOut $data
        close $fpOut
    }
}

# Return the size of a folder in bytes. Similar to Unix du command.
# By default, hidden folders and files are counted, too.
proc ::poMisc::DiskUsage { dirName { countHidden true } } {
    set res 0
    foreach item [glob -nocomplain $dirName/*] {
        switch -- [file type $item] {
            directory {
                set res [expr {$res + [::poMisc::DiskUsage $item $countHidden]}]
            }
            file {
                set res [expr {$res + [file size $item]}]
            }
        }
    }

    if { $countHidden } {
        foreach item [glob -nocomplain -types {hidden} $dirName/*] {
            switch -- [file type $item] {
                directory {
                    set res [expr {$res + [::poMisc::DiskUsage $item $countHidden]}]
                }
                file {
                    set res [expr {$res + [file size $item]}]
                }
            }
        }
    }
    return $res
}

proc ::poMisc::GetFileInfoLabels {} {
    global tcl_platform

    set infoLabels [list "Filename" "Path" "Type" "Size in Bytes" \
                         "Last time modified" "Last time accessed"]
    
    if { [string compare $tcl_platform(platform) "windows"] == 0 } {
        lappend infoLabels "Archiv"
        lappend infoLabels "Hidden"
        lappend infoLabels "Readonly"
        lappend infoLabels "System"
    } elseif { [string compare $tcl_platform(platform) "unix"] == 0 } {
        lappend infoLabels "Owner"
        lappend infoLabels "Group"
        lappend infoLabels "Permissions"
    } 
    return $infoLabels
}

proc ::poMisc::FormatByteSize { sizeInBytes } {
    set KB 1024.0
    set MB [expr {$KB * $KB}]
    set GB [expr {$MB * $KB}]

    if { $sizeInBytes < $KB } {
        return [format "%d Bytes" $sizeInBytes]
    } elseif { $sizeInBytes < $MB } {
        return [format "%.2f KBytes" [expr {$sizeInBytes / $KB}]]
    } elseif { $sizeInBytes < $GB } {
        return [format "%.2f MBytes" [expr {$sizeInBytes / $MB}]]
    } else {
        return [format "%.2f GBytes" [expr {$sizeInBytes / $GB}]]
    }
}

proc ::poMisc::FileInfo { fileName } {
    global tcl_platform

    if { ! [file readable $fileName] } {
        return {}
    }

    set KB 1024.0
    set MB [expr $KB * $KB]
    set GB [expr $MB * $KB]
    set attrList {}
    set labelList [::poMisc::GetFileInfoLabels]
    set ind 0

    # Note: If adding another element, don't forget to update
    #       proc GetFileInfoLabels accordingly.
    set tmp [file tail $fileName]
    lappend attrList [list [lindex $labelList $ind] $tmp]
    incr ind
    set tmp [file nativename [file dirname $fileName]]
    lappend attrList [list [lindex $labelList $ind] $tmp]
    incr ind
    set tmp [::poType::GetFileType $fileName]
    lappend attrList [list [lindex $labelList $ind] $tmp]
    incr ind

    set tmp [file size $fileName]
    if { $tmp < $KB } {
        lappend attrList [list [lindex $labelList $ind] $tmp]
    } elseif { $tmp < $MB } {
        lappend attrList [list [lindex $labelList $ind] \
                [format "%d (%.2f KBytes)" $tmp [expr $tmp / $KB]]]
    } elseif { $tmp < $GB } {
        lappend attrList [list [lindex $labelList $ind] \
                [format "%d (%.2f MBytes)" $tmp [expr $tmp / $MB]]]
    } else {
        lappend attrList [list [lindex $labelList $ind] \
                [format "%d (%.2f GBytes)" $tmp [expr $tmp / $GB]]]
    }
    incr ind

    set tmp [clock format [file mtime $fileName] -format "%Y-%m-%d %H:%M"]
    lappend attrList [list [lindex $labelList $ind] $tmp]
    incr ind
    set tmp [clock format [file atime $fileName] -format "%Y-%m-%d %H:%M"]
    lappend attrList [list [lindex $labelList $ind] $tmp]
    incr ind

    if { [string compare $tcl_platform(platform) "windows"] == 0 } {
        set tmp [file attributes $fileName -archive]
        lappend attrList [list [lindex $labelList $ind] $tmp]
        incr ind
        set tmp [file attributes $fileName -hidden]
        lappend attrList [list [lindex $labelList $ind] $tmp]
        incr ind
        set tmp [file attributes $fileName -readonly]
        lappend attrList [list [lindex $labelList $ind] $tmp]
        incr ind
        set tmp [file attributes $fileName -system]
        lappend attrList [list [lindex $labelList $ind] $tmp]
        incr ind
    } elseif { [string compare $tcl_platform(platform) "unix"] == 0 } {
        set tmp [file attributes $fileName -owner]
        lappend attrList [list [lindex $labelList $ind] $tmp]
        incr ind
        set tmp [file attributes $fileName -group]
        lappend attrList [list [lindex $labelList $ind] $tmp]
        incr ind
        set tmp [file attributes $fileName -permissions]
        lappend attrList [list [lindex $labelList $ind] $tmp]
        incr ind
    } else {
        error "Unsupported platform $tcl_platform(platform)"
    }
    return $attrList
}

proc ::poMisc::FileIdent { f1 f2 { cmpMode 2 } { ignEOL 0 } { bufSize 2048 } } {
    if { ! [file isfile $f1] } {
        error "Parameter $f1 is not a file"
    }
    if { ! [file isfile $f2] } {
        error "Parameter $f2 is not a file"
    }

    if { ([file size $f1] != [file size $f2]) && \
         ($cmpMode == 2 && $ignEOL == 0) } {
        return 0
    } elseif { $cmpMode == 0 } {
        return 1
    }

    if { $cmpMode == 1 } {
        if { [file mtime $f1] == [file mtime $f2] } {
            return 1
        } else {
            return 0
        }
    }

    set retVal 0
    set catchVal [catch { open $f1 r } fp1]
    if { $catchVal } {
        error "Could not open file \"$f1\" for reading."
    }

    set catchVal [catch { open $f2 r } fp2]
    if { $catchVal } {
        close $fp1
        error "Could not open file \"$f2\" for reading."
    }
    if { $ignEOL } {
        fconfigure $fp1 -translation auto
        fconfigure $fp2 -translation auto
    } else {
        fconfigure $fp1 -translation binary
        fconfigure $fp2 -translation binary
    }

    set str1 [read $fp1 $bufSize]
    while { 1 } {
        set str2 [read $fp2 $bufSize]
        if { [string compare $str1 $str2] != 0 } {
            # Files differ
            set retVal 0
            break
        }
        set str1 [read $fp1 $bufSize]
        if { [string compare $str1 ""] == 0 } {
            # Files are identical
            set retVal 1
            break
        }
    }
    close $fp1
    close $fp2
    return $retVal
}

proc ::poMisc::SearchInFile { fileName searchPatt {ignCase 0} } {
    return [::poMisc::SearchReplaceInFile $fileName $searchPatt "" 0 $ignCase]
}

proc ::poMisc::ReplaceInFile { fileName searchPatt replacePatt {ignCase 0} } {
    return [::poMisc::SearchReplaceInFile $fileName $searchPatt \
                                          $replacePatt 1 $ignCase]
}

proc ::poMisc::SearchReplaceInFile { fileName searchPatt \
                                     replacePatt doReplace {ignCase 0} } {
    set catchVal [catch { open $fileName r } fp]
    if { $catchVal } {
        error "Could not open file \"$fileName\" for reading."
    }
    fconfigure $fp -translation binary
    set srcCont [read $fp [file size $fileName]]
    close $fp

    if { $ignCase } {
        set numSubst [regsub -nocase -all -- "$searchPatt" $srcCont \
                                             "$replacePatt" substCont]
    } else {
        set numSubst [regsub -all -- "$searchPatt" $srcCont \
                                     "$replacePatt" substCont]
    }
    if { $numSubst > 0 } {
        if { $doReplace } {
            set catchVal [catch { open $fileName w } fp]
            if { $catchVal } {
                error "Could not open file \"$fileName\" for writing."
            }
            fconfigure $fp -translation binary
            puts -nonewline $fp $substCont
            close $fp
        }
    }
    return $numSubst
}

proc ::poMisc::HexDump { fileName { channel "" } { textWidget "" } } {
    # Open the file, and set up to process it in binary mode.
    set catchVal [catch { open $fileName r } fp]
    if { $catchVal } {
        error "Could not open file \"$fileName\" for reading."
    }
    fconfigure $fp -translation binary -encoding binary \
                   -buffering full -buffersize 16384

    while { 1 } {
        # Record the seek address.  Read 16 bytes from the file.
        set addr [tell $fp]
        set s [read $fp 16]

        # Convert the data to hex and to characters.
        binary scan $s H*@0a* hex ascii

        # Replace non-printing characters in the data.
        regsub -all {[^[:graph:] ]} $ascii {.} ascii

        # Split the 16 bytes into two 8-byte chunks
        set hex1 [string range $hex 0 15]
        set hex2 [string range $hex 16 31]
        set ascii1 [string range $ascii 0 7]
        set ascii2 [string range $ascii 8 16]

        # Convert the hex to pairs of hex digits
        regsub -all {..} $hex1 {& } hex1
        regsub -all {..} $hex2 {& } hex2

        # Put the hex and Latin-1 data to the channel
        set hexStr [format {%08x  %-24s %-24s %-8s %-8s} \
                            $addr $hex1 $hex2 $ascii1 $ascii2]
        if { $channel != "" } {
            puts $channel $hexStr
        }
        if { $textWidget != "" } {
            $textWidget insert end $hexStr
            $textWidget insert end "\n"
        }
        # Stop if we've reached end of file
        if { [string length $s] == 0 } {
            break
        }
    }

    close $fp
    return
}

proc ::poMisc::QuoteSpaces { str } {
    regsub -all { } $str {\\&} quoted
    return $quoted
}

proc ::poMisc::CompactSpaces { str {replaceChar " "} } {
    regsub -all {\s+} $str "$replaceChar" compact
    return $compact
}

# Like split, but eliminates multiple whitespaces in string before splitting.
proc ::poMisc::SplitMultSpaces { str } {
    return [regexp -all -inline {\S+} $str]
}

# Add newlines to a string at word boundaries.
proc ::poMisc::AddNewlines { str { maxChars 10 } } {
    set newStr ""
    set sum 0
    set l [regexp -all -inline {\S+} $str]
    foreach word $l {
        append newStr $word " "
        incr sum [string length $word]
        if { $sum >= $maxChars } {
            append newStr "\n"
            set sum 0
        }
    }
    return $newStr
}

proc ::poMisc::Plural { num } {
    if { $num == 1 } {
        return ""
    } else {
        return "s"
    }
}

proc ::poMisc::RandomInit { seed } {
    variable randomSeed
    set randomSeed $seed
}

proc ::poMisc::Random { } {
    variable randomSeed
    set randomSeed [expr ($randomSeed * 9301 + 49297) % 233280]
    return [expr $randomSeed/double(233280)]
}

proc ::poMisc::RandomRange { range } {
    expr int ([Random]*$range)
}

proc ::poMisc::DegToRad { phi } {
    variable PI
    return [expr $phi * $PI / 180.0]
}

proc ::poMisc::RadToDeg { rad } {
    variable PI
    return [expr $rad * 180.0 / $PI]
}

proc ::poMisc::ArrayToList { arr noElem } {
    upvar $arr a
    set tmpList {}
    for { set i 0 } { $i < $noElem } { incr i } {
        lappend tmpList $a($i)
    }
    return $tmpList
}

proc ::poMisc::ListToArray { lst noElem arr } {
    upvar $arr a
    for { set i 0 } { $i < $noElem } { incr i } {
        set a($i) [lindex $lst $i]
    }
}

proc ::poMisc::Abs { a } {
    if { $a < 0 } {
        return [expr -1 * $a]
    } else {
        return $a
    }
}

proc ::poMisc::Min { a b } {
    if { $a < $b } {
        return $a
    } else {
        return $b
    }
}

proc ::poMisc::Max { a b } {
    if { $a > $b } {
        return $a
    } else {
        return $b
    }
}

proc ::poMisc::GetTmpDir {} {
    global tcl_platform env

    set tmpDir ""
    # Try different environment variables.
    if { [info exists env(TMP)] && [file isdirectory $env(TMP)] } {
        set tmpDir $env(TMP)
    } elseif { [info exists env(TEMP)] && [file isdirectory $env(TEMP)] } {
        set tmpDir $env(TEMP)
    } elseif { [info exists env(TMPDIR)] && [file isdirectory $env(TMPDIR)] } {
        set tmpDir $env(TMPDIR)
    } else {
        # Last resort. These directories should be available at least.
        switch $tcl_platform(platform) {
            windows {
                if { [file isdirectory "C:/Windows/Temp"] } {
                    set tmpDir "C:/Windows/Temp"
                } elseif { [file isdirectory "C:/Winnt/Temp"] } {
                    set tmpDir "C:/Winnt/Temp"
                }
            }
            unix {
                if { [file isdirectory "/tmp"] } {
                    set tmpDir "/tmp"
                }
            }
        }
    }
    return [file nativename $tmpDir]
}

proc ::poMisc::GetDesktopDir {} {
    global tcl_platform env

    set desktopDir ""
    switch $tcl_platform(platform) {
        windows {
            # Load the registry package
            package require registry

            # Define likely registry locations
            set keys [list \
                {HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders}\
                {HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\ProfileList}\
                {HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders}]
    
            # Try each location till we find a result
            foreach key $keys {
                if ![catch "registry get \"$key\" Desktop" result] {
                    set desktopDir $result
                    break
                }
            }
        }
        unix {
            set tmpDir [file join [::poMisc::GetHomeDir] "KDesktop"]
            if { [file isdirectory $tmpDir] } {
                set desktopDir $tmpDir
            }
        }
    }
    if { ! [file isdirectory $desktopDir] } {
        set desktopDir ""
    }
    return [file nativename $desktopDir]
}

proc ::poMisc::GetHomeDir {} {
    global tcl_platform env

    set homeDir "~"
    if { ! [file isdirectory $homeDir] } {
        set homeDir ""
    }
    return [file nativename $homeDir]
}

proc ::poMisc::GetCfgFile { module { cfgDir "" } } {
    if { [string compare $cfgDir ""] == 0 } {
        set dir "~"
    } else {
        set dir $cfgDir
    }
    set cfgName [format "%s.cfg" $module]
    return [file join $dir $cfgName]
}

proc ::poMisc::GetFileAttr { fileList dirName } {
    set fileLongList  {}
    foreach f $fileList {
        set af   [file join $dirName $f]
        set date [clock format [file mtime $af] -format "%Y-%m-%d %H:%M"]
        set size [file size  $af]
        lappend fileLongList [list $f $size $date]
    }
    return $fileLongList
}

proc ::poMisc::GetDirCont { dirName patt } {
    global tcl_platform env

    ::poLog::Debug "::poMisc::GetDirCont $dirName $patt"

    set fileList {}

    set curDir [pwd]
    set catchVal [catch {cd $dirName}]
    if { $catchVal } {
        return $fileList
    }

    set fileList [eval {glob -nocomplain} $patt]

    cd $curDir
    return [lsort $fileList]
}

proc ::poMisc::IsHiddenFile { absName } {
    global tcl_platform

    switch $tcl_platform(platform) {
        unix {
            return  [string match ".*" [file tail $absName]] 
        }
        windows {
            return [file attributes $absName -hidden]
        }
        macintosh {
            return [file attributes $absName -hidden]
        }
        default {
            error "Missing implementation of ::poMisc::IsHidden \
                   for platform $tcl_platform(platform)"
        }
    }
}

proc ::poMisc::GetDirListSlow {dirName \
                               {showDirs 1} {showFiles 1} \
                               {showHiddenDirs 1} {showHiddenFiles 1} \
                               {dirPattern *} {filePattern *}} {
    global tcl_platform

    ::poLog::Debug "::poMisc::GetDirListSlow $dirName $showDirs $showFiles \
                    $showHiddenDirs $showHiddenFiles $dirPattern $filePattern"

    switch $tcl_platform(platform) {
        unix {
            set dirCont [::poMisc::GetDirCont $dirName $filePattern]
        }
        default {
            set dirCont [::poMisc::GetDirCont $dirName $filePattern]
        }
    }
    set dirList     {}
    set relFileList {}
    foreach name $dirCont {
        set absName [file join $dirName $name]
        if { [file isdirectory $absName] } {
            if { $showDirs } {
                if { [IsHiddenFile $absName] } {
                    if { $showHiddenDirs } {
                        lappend dirList $absName
                    }
                } else {
                    lappend dirList $absName
                }
            }
        } else {
            if { $showFiles } {
                if { [IsHiddenFile $absName] } {
                    if { $showHiddenFiles } {
                        lappend relFileList $name
                    }
                } else {
                    lappend relFileList $name
                }
            }
        }
    }
    return [list $dirList $relFileList]
}

proc ::poMisc::GetDirListSlow84Up {dirName \
                                   {showDirs 1} {showFiles 1} \
                                   {showHiddenDirs 1} {showHiddenFiles 1} \
                                   {dirPattern *} {filePattern *}} {
    global tcl_platform

    ::poLog::Debug "::poMisc::GetDirListSlow84Up $dirName $showDirs $showFiles \
                    $showHiddenDirs $showHiddenFiles $dirPattern $filePattern"

    set curDir [pwd]
    set catchVal [catch {cd $dirName}]
    if { $catchVal } {
        return {}
    }

    set absDirList  {}
    set relFileList {}

    if { $showDirs } {
        set relDirList [eval {glob -nocomplain -types d} $dirPattern]
        foreach dir $relDirList {
            if { [string index $dir 0] == "~" } {
                set dir [format "./%s" $dir]
            }
            set absName [file join $dirName $dir]
            lappend absDirList $absName
        }
        if { $showHiddenDirs } {
            set relHiddenDirList \
                [eval {glob -nocomplain -types {d hidden}} $dirPattern]
            foreach dir $relHiddenDirList {
                if { [string compare $dir "."] == 0 || \
                     [string compare $dir ".."] == 0 } {
                    continue
                }
                set absName [file join $dirName $dir]
                lappend absDirList $absName
            }
        }
    }
    if { $showFiles } {
        set relFileList [eval {glob -nocomplain -types f} $filePattern]
        if { $showHiddenFiles } {
            set relHiddenFileList \
                [eval {glob -nocomplain -types {f hidden}} $filePattern]
            if { [llength $relHiddenFileList] != 0 } {
                set relFileList [concat $relFileList $relHiddenFileList]
            }
        }
    }
    cd $curDir

    return [list $absDirList $relFileList]
}

proc ::poMisc::GetDirListFast {dirName \
                               {showDirs 1} {showFiles 1} \
                               {showHiddenDirs 1} {showHiddenFiles 1} \
                               {dirPattern *} {filePattern *}} {
    global tcl_platform

    ::poLog::Debug "::poMisc::GetDirListFast $dirName $showDirs $showFiles \
                    $showHiddenDirs $showHiddenFiles $dirPattern $filePattern"

    set curDir [pwd]
    set catchVal [catch {cd $dirName}]
    if { $catchVal } {
        return {}
    }

    set absDirList  {}
    set relFileList {}
    if { $showDirs } {
        if { $showHiddenDirs } {
            set relDirList [eval {glob -nocomplain -types d} $dirPattern]
        } else {
            set relDirList [eval {glob -nocomplain -types {d !hidden}} $dirPattern]
        }
        foreach dir $relDirList {
            set absName [file join $dirName $dir]
            lappend absDirList $absName
        }
    }
    if { $showFiles } {
        if { $showHiddenFiles } {
            set relFileList [eval {glob -nocomplain -types !d} $filePattern]
        } else {
            set relFileList [eval {glob -nocomplain -types {!d !hidden}} $filePattern]
        }
    }
    cd $curDir

    return [list $absDirList $relFileList]
}

proc ::poMisc::PrintMachineInfo {} {
    global tcl_platform

    puts ""
    puts "Machine specific information:"
    puts "  platform    : $tcl_platform(platform)"
    puts "  os          : $tcl_platform(os)"
    puts "  osVersion   : $tcl_platform(osVersion)"
    puts "  machine     : $tcl_platform(machine)"
    puts "  hostname    : [info hostname]"
}

proc ::poMisc::PrintTclInfo {} {
    global tcl_platform

    set loadedPackages [info loaded]

    puts ""
    puts "Tcl specific information:"
    puts "  Tcl version : [info patchlevel]"

    set i 1
    foreach pckg $loadedPackages {
        if { $i == 1 } {
            puts  [format "  Packages    : %-8s (%s)" \
                          [lindex $pckg 1] [lindex $pckg 0]]
        } else {
            puts  [format "                %-8s (%s)" \
                          [lindex $pckg 1] [lindex $pckg 0]]
        }
        incr i
    }
}

proc ::poMisc::GetExecutable { title } {
    global tcl_platform

    set progSuffix "*"
    if { [string compare $tcl_platform(platform) windows] == 0 } {
        set progSuffix ".exe"
    }
    set fileTypes [list \
        [list Programs  $progSuffix] \
        [list "All files" *]]

    set fileName [tk_getOpenFile -filetypes $fileTypes -title $title]
    if { [string compare $fileName ""] != 0 } {
        set fileName [format "\"%s\"" $fileName]
    }
    return $fileName
}

# dec2rgb --
#
#   Takes a color name or dec triplet and returns a #RRGGBB color.
#   If any of the incoming values are greater than 255,
#   then 16 bit value are assumed, and #RRRRGGGGBBBB is
#   returned, unless $clip is set.
#
# Arguments:
#   r           red dec value, or list of {r g b} dec value or color name
#   g           green dec value, or the clip value, if $r is a list
#   b           blue dec value
#   clip        Whether to force clipping to 2 char hex
# Results:
#   Returns a #RRGGBB or #RRRRGGGGBBBB color
#
proc ::poMisc::DecToRgb {r {g 0} {b UNSET} {clip 0}} {
    if {![string compare $b "UNSET"]} {
        set clip $g
        if {[regexp {^-?(0-9)+$} $r]} {
            foreach {r g b} $r {break}
        } else {
            foreach {r g b} [winfo rgb . $r] {break}
        }
    } 
    set max 255
    set len 2
    if {($r > 255) || ($g > 255) || ($b > 255)} {
        if {$clip} {
            set r [expr {$r>>8}]; set g [expr {$g>>8}]; set b [expr {$b>>8}]
        } else {
            set max 65535
            set len 4
        }
    }
    return [format "#%.${len}X%.${len}X%.${len}X" \
            [expr {($r>$max)?$max:(($r<0)?0:$r)}] \
            [expr {($g>$max)?$max:(($g<0)?0:$g)}] \
            [expr {($b>$max)?$max:(($b<0)?0:$b)}]]
}

# rgb2dec --
#
#   Turns #rgb into 3 elem list of decimal vals.
#
# Arguments:
#   c           The #rgb hex of the color to translate
# Results:
#   Returns a #RRGGBB or #RRRRGGGGBBBB color
#
proc ::poMisc::RgbToDec { c } {
    set c [string tolower $c]
    if {[regexp {^\#([0-9a-f])([0-9a-f])([0-9a-f])$} $c x r g b]} {
        # double'ing the value make #9fc == #99ffcc
        scan "$r$r $g$g $b$b" "%x %x %x" r g b
    } else {
        if {![regexp {^\#([0-9a-f]+)$} $c junk hex] || \
                [set len [string length $hex]]>12 || $len%3 != 0} {
            return -code error "bad color value \"$c\""
        }
        set len [expr {$len/3}]
        scan $hex "%${len}x%${len}x%${len}x" r g b
    }
    return [list $r $g $b]
}

# Implementation of a bitset datastructure with Tcl lists.
# Taken from the Tcl'ers Wiki. Original by Richard Suchenwirth.
proc ::poMisc::Bitset { varName pos {bitval {}} } {
    variable tclVers84Up

    upvar 1 $varName var
    if {![info exist var]} {
        set var 0
    }
    set element [expr {$pos/32}]
    while {$element >= [llength $var]} {
        lappend var 0
    }
    set bitpos [expr {$pos%32}]
    set word [lindex $var $element]
    if {$bitval != ""} {
        if {$bitval} {
            set word [expr {$word | 1 << $bitpos}]
        } else {
            set word [expr {$word & ~(1 << $bitpos)}]
        }
        if { $tclVers84Up } {
            lset var $element $word
        } else {
            set var [lreplace $var $element $element $word]
        }
    }
    expr {($word & 1 << $bitpos) != 0}
}

# Return the numeric indices of all set bits in a bitset.
proc ::poMisc::GetBitsetIndices { bitset } {
    set res {}
    set pos 0
    foreach word $bitset {
        for { set i 0 } { $i<32 } { incr i } {
            if { $word & 1<<$i } {
                lappend res $pos
            }
            incr pos
        }
    }
    return $res
}

proc ::poMisc::CharToNum { char } {
    scan $char %c value
    return $value
}

proc ::poMisc::NumToChar { value } {
    return [format %c $value]
}

::poMisc::Init
catch {puts "Loaded Package poTcllib (Module [info script])"}


############################################################################
# Original file: poTcllib/poType.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poType
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poType.tcl
#
#       First Version:  2000 / 07 / 01
#       Author:         Paul Obermeier
#
#       Description:	This package provides some simple heuristics to
#			determine file types.
#			
#       Additional documentation:
#
#       Exported functions:
#                       ::poType::GetFileType
#
############################################################################

package provide poTcllib 1.0
package provide poType   1.0

namespace eval ::poType {
    namespace export GetFileType
    namespace export IsBinary
}

proc ::poType::Init {} {
}

###########################################################################
#[@e
#       Name:           ::poType::GetFileType
#
#       Usage:          Determine type of a file.
#
#       Synopsis:       proc ::poType::GetFileType { fileName }
#
#       Description:    fileName: string 
#			Name of the file to test.
#
#			Note: This is an enhanced version of procedure
#			      ::fileutil::fileType from tcllib.
#
#       Return Value:	Type of the file.  May be a list if multiple tests
#                       are positive (eg, a file could be both a directory 
#                       and a link).  In general, the list proceeds from most
#                       general (eg, binary) to most specific (eg, gif), so
#                       the full type for a GIF file would be 
#			"binary graphic gif".
#
#                       At present, the following types can be detected:
#                       directory
#                       empty
#                       binary
#                       text
#                       script <interpreter>
#                       executable elf
#                       binary graphic [gif, jpeg, png, tiff, ppm, sun, sgi,
#                                       pcx, ico, bmp, tga]
#                       ps, eps, pdf
#                       html
#                       xml <doctype>
#                       message pgp
#                       bzip, gzip
#                       gravity_wave_data_frame
#                       link
#
#       See also:
#
###########################################################################

proc ::poType::GetFileType { fileName } {
    # Existence test
    if { ! [ file exists $fileName ] } {
        set err "file not found: '$fileName'"
        return -code error $err
    }
    # Directory test
    if { [ file isdirectory $fileName ] } {
        set type directory
        if { ! [ catch {file readlink $fileName} ] } {
            lappend type link
        }
        return $type
    }
    # Empty file test
    if { ! [ file size $fileName ] } {
        set type empty
        if { ! [ catch {file readlink $fileName} ] } {
            lappend type link
        }
        return $type
    }
    set bin_rx {[\x00-\x08\x0b\x0e-\x1f]}

    if { [ catch {
        set fid [ open $fileName r ]
        fconfigure $fid -translation binary
        fconfigure $fid -buffersize 1024
        fconfigure $fid -buffering full
        set test [ read $fid 1024 ]
        ::close $fid
    } err ] } {
        catch { ::close $fid }
        return -code error "::fileutil::fileType: $err"
    }

    if { [ regexp $bin_rx $test ] } {
        set type binary
        set binary 1
    } else {
        set type text
        set binary 0
        set dos_eol "*\r\n*"
        if { [ string match $dos_eol $test ] } {
            lappend type "dos"
        } else {
            lappend type "unix"
        }
    }

    if { [ regexp {^\#\!\s*(\S+)} $test -> terp ] } {
        lappend type script $terp
    } elseif { $binary && [ regexp {^[\x7F]ELF} $test ] } {
        lappend type executable elf
    } elseif { $binary && [string match "BZh91AY\&SY*" $test] } {
        lappend type compressed bzip
    } elseif { $binary && [string match "\x1f\x8b*" $test] } {
        lappend type compressed gzip
    } elseif { $binary && [string match "GIF*" $test] } {
        lappend type graphic gif
    } elseif { $binary && [string match "\x89PNG*" $test] } {
        lappend type graphic png
    } elseif { $binary && [string match "\xFF\xD8\xFF\xE0\x00\x10JFIF*" $test] } {
        lappend type graphic jpeg
    } elseif { $binary && [string match "\xFF\xD8\xFF???Exif*" $test] } {
	# Possibly add subtype exif here ?
        lappend type graphic jpeg
    } elseif { $binary && [string match "\xFF\xD8\xFF*" $test] } {
        lappend type graphic jpeg
    } elseif { $binary && \
               ([string match "MM\x00\**" $test] || \
	        [string match "II\*\x00*" $test])} {
        lappend type graphic tiff
    } elseif { [string match "P6\x0a*" $test] || \
	       [string match "P5\x0a*" $test] || \
               [string match "P3\x0a*" $test]} {
        lappend type graphic ppm
    } elseif { $binary && [string match "\x59\xa6\x6a\x95*" $test] } {
        lappend type graphic sun
    } elseif { $binary && [string match "\x01\xda*" $test] } {
        lappend type graphic sgi
    } elseif { $binary && [regexp {^[\x0a].+.+[\x01\x08]} $test] } {
        lappend type graphic pcx
    } elseif { $binary && [string match "\x00\x00\x01\x00*" $test] } {
        lappend type graphic ico
    } elseif { $binary && [string match "BM*" $test] } {
        lappend type graphic bmp
    } elseif { $binary && \
               [regexp {^.+[\x00\x01][\x01-\x03\x09-\x0b].{13}[\x08\x0f\x10\x18\x20]} $test] } {
        lappend type graphic tga
    } elseif { $binary && [string match "\%PDF\-*" $test] } {
        lappend type pdf
    } elseif { ! $binary && [string match -nocase "*\<html\>*" $test] } {
        lappend type html
    } elseif { [string match "\%\!PS\-*" $test] } {
        lappend type ps
        if { [string match "* EPSF\-*" $test] } {
            lappend type eps
        }
    } elseif { [string match -nocase "*\<\?xml*" $test] } {
        lappend type xml
        if { [ regexp -nocase {\<\!DOCTYPE\s+(\S+)} $test -> doctype ] } {
            lappend type $doctype
        }
    } elseif { [string match {*BEGIN PGP MESSAGE*} $test] } {
        lappend type message pgp
    } elseif { $binary && [string match {IGWD*} $test] } {
        lappend type gravity_wave_data_frame
    } elseif {[string match "JL\x1a\x00*" $test] && \
              ([file size $fileName] >= 27)} {
	lappend type metakit smallendian
    } elseif {[string match "LJ\x1a\x00*" $test] && \
              ([file size $fileName] >= 27)} {
	lappend type metakit bigendian
    }

    # Lastly, is it a link?
    if { ! [ catch {file readlink $fileName} ] } {
        lappend type link
    }
    return $type
}

proc ::poType::IsBinary { fileName } {
    set retVal [::poType::GetFileType $fileName]
    if { [lsearch $retVal "binary"] >= 0 } {
        return true
    } else {
        return false
    }
}

::poType::Init
catch {puts "Loaded Package poTcllib (Module [info script])"}

############################################################################
# Original file: poTcllib/poWatch.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poWatch
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poWatch.tcl
#
#       First Version:  2000 / 03 / 13
#       Author:         Paul Obermeier
#
#       Description:
#			The "clock clicks" command is used to simulate a simple
#                       stop watch. You can generate multiple stop watches, 
#			which are identified by its names.
#
#			Typical usage (see also ::poWatch::Test):
#
#			::poWatch::Reset watch1	# Reset watch1 to zero
#			::poWatch::Start watch1 # Start watch1 running
#			# After some time
#			set sec [::poWatch::Lookup watch1] # Get current time 
#
#       Additional documentation:
#
#			Command "clock" in the Tcl manuals.
#
#       Exported functions:
#                       ::poWatch::Reset
#                       ::poWatch::Start
#                       ::poWatch::Stop
#                       ::poWatch::Lookup
#                       ::poWatch::Test
#
############################################################################

package require poLog 1.0
package provide poTcllib 1.0
package provide poWatch 1.0

namespace eval ::poWatch {
    namespace export Reset
    namespace export Start
    namespace export Stop
    namespace export Lookup

    namespace export Test

    # If calcClickFactor is 1, then clickFactor is determined at package
    # load time. This takes 0.1 seconds.
    # To avoid this overhead, set calcClickFactor to 0, and set the correct 
    # clickFactor for your system by hand.
    # This is 1.0E-3 on my NT system, and 1.0E-6 on SGI and Linux.
    # Don't know about other systems.

    variable clickFactor 1.0E-3
    variable calcClickFactor 1
    variable watches
}

# Init is called at package load time to determine the resolution of the
# "clock clicks" command.

proc ::poWatch::Init {} {
    variable clickFactor
    variable calcClickFactor

    if { ! $calcClickFactor } {
	return
    }
    set t1 [clock clicks]
    after 100
    set t2 [clock clicks]
    set diff [expr $t2 - $t1]
    set clickMult 1
    while { 1 } {
	set res [expr $diff / $clickMult]
        if { $res == 1 || $res == 0 } {
	    set clickMult [expr $clickMult * 10]
	    set clickFactor [expr 1.0 / $clickMult]
	    ::poLog::Info "::poWatch::clickFactor = $clickFactor"
	    return 
	}
	set clickMult [expr $clickMult * 10]
    }
}

###########################################################################
#[@e
#       Name:           ::poWatch::Reset
#
#       Usage:          Reset a stop watch.
#
#       Synopsis:       proc ::poWatch::Reset { name }
#
#       Description:    name: String
#
#			Stop watch "name" is reset to 0.0 seconds, but its
#			state (stopped or running) is not changed. 
#
#       Return Value:   None.
#
#       See also:	::poWatch::Start
#			::poWatch::Stop
#			::poWatch::Lookup
#
###########################################################################

proc ::poWatch::Reset { name } {
    variable watches 
    variable clickFactor

    set t [clock clicks]

    if { [info exists watches($name,running)] } {
       if { $watches($name,running) } {
	    set watches($name,starttime) [expr $t * $clickFactor]
	}
    } else {
	set watches($name,running) 0
	set watches($name,starttime) 0.0
    }
    set watches($name,acctime) 0.0
}

###########################################################################
#[@e
#       Name:           ::poWatch::Start
#
#       Usage:          Start a stop watch.
#
#       Synopsis:       proc ::poWatch::Start { name }
#
#       Description:    name: String
#
#			Stop watch "name" starts or continues to run.
#
#       Return Value:   None.
#
#       See also:	::poWatch::Reset
#			::poWatch::Stop
#			::poWatch::Lookup
#
###########################################################################

proc ::poWatch::Start { name } {
    variable watches 
    variable clickFactor

    set t [clock clicks]

    if { ![info exists watches($name,running)] } {
        Reset $name
    }
    set watches($name,starttime) [expr $t * $clickFactor]
    set watches($name,running) 1
}

###########################################################################
#[@e
#       Name:           ::poWatch::Stop
#
#       Usage:          Stop a stop watch.
#
#       Synopsis:       proc ::poWatch::Stop { name }
#
#       Description:    name: String
#
#			Stop watch "name" is stopped, but not reset.
#
#       Return Value:   None.
#
#       See also:	::poWatch::Reset
#			::poWatch::Start
#			::poWatch::Lookup
#
###########################################################################

proc ::poWatch::Stop { name } {
    variable watches 
    variable clickFactor

    set t [clock clicks]

    if { ![info exists watches($name,running)] } {
	Reset $name
    }
    if { $watches($name,running) } {
	set watches($name,acctime) [expr $watches($name,acctime) + \
				    $t * $clickFactor - \
				    $watches($name,starttime)]
	set watches($name,running) 0
    }
}

###########################################################################
#[@e
#       Name:           ::poWatch::Lookup
#
#       Usage:          Lookup a stop watch.
#
#       Synopsis:       proc ::poWatch::Lookup { name }
#
#       Description:    name: String
#
#			Lookup stop watch "name" to get it's current time.
#			The number of seconds since the last call to Reset
#			is returned.
#			The precision depends on the high resolution counter
#			available on the system.
#
#       Return Value:   double.
#
#       See also:	::poWatch::Reset
#			::poWatch::Start
#			::poWatch::Stop
#
###########################################################################

proc ::poWatch::Lookup { name } {
    variable watches 
    variable clickFactor

    set t [clock clicks]

    if { ![info exists watches($name,running)] } {
	Reset $name
    }
    if { $watches($name,running) } {
	set retVal [expr $watches($name,acctime) + \
			 $t * $clickFactor - \
			 $watches($name,starttime)]
    } else {
	set retVal $watches($name,acctime)
    }
    return $retVal
}

# Utility functions for Test.

proc ::poWatch::P { str verbose } {
    if { $verbose } {
	puts $str
    }
}

proc ::poWatch::CheckLookup { watch acc cmp v } {
    set t [Lookup $watch]
    P "Lookup of watch $watch after $acc seconds: $t (Should be around $cmp)" $v
    P "" $v
    if { $t - $cmp < 0.2 } {
	return 1
    }
    puts stderr "Clock time ($t) and compare value ($cmp) \
                 differ by more than 0.2 seconds."
    return 0
}

###########################################################################
#[@e
#       Name:           ::poWatch::Test
#
#       Usage:          Test the stop watch package.
#
#       Synopsis:       proc ::poWatch::Test { { maxTime 4 } { verbose true } }
#
#       Description:    maxTime: integer (Default: 4)
#			verbose: boolean (Default: true)
#
#			Simple test to check the correctness of this package.
#			if "verbose" is true, messages are printed out,
#			otherwise test runs silently.
#			"MaxTime" determines the duration of the test.
#
#       Return Value:   true / false.
#
#       See also:	::poWatch::Reset
#			::poWatch::Start
#			::poWatch::Stop
#			::poWatch::Lookup
#
###########################################################################

proc ::poWatch::Test { { maxTime 4 } { verbose true } } {
    set retVal 1

    if { $maxTime < 4 } {
	set maxTime 4
    }

    P "" $verbose
    P "Start of watch test" $verbose

    Reset a
    Reset b

    P "Starting watch a and b" $verbose
    P "" $verbose

    Start a
    Start b
    after 1000
    set retVal [expr [CheckLookup a 1 1.0 $verbose] && $retVal]
    after 1000
    set retVal [expr [CheckLookup b 2 2.0 $verbose] && $retVal]

    P "Stopping watch a" $verbose
    P "" $verbose
    Stop a
    after 1000

    set retVal [expr [CheckLookup a 3 2.0 $verbose] && $retVal]
    set retVal [expr [CheckLookup b 3 3.0 $verbose] && $retVal]

    P "Starting watch a again" $verbose
    P "" $verbose
    Start a
    after [expr ($maxTime - 3) * 1000]

    set accTime  $maxTime
    set accTime1 [expr $accTime - 1]
    set retVal [expr [CheckLookup a $accTime $accTime1 $verbose] && $retVal]
    set retVal [expr [CheckLookup b $accTime $accTime  $verbose] && $retVal]
    P "Test finished" $verbose
    return $retVal
}

::poWatch::Init
catch {puts "Loaded Package poTcllib (Module [info script])"}

############################################################################
# Original file: poTklib/poBmpData.tcl
############################################################################

package provide poTklib 1.0
package provide poBmpData 1.0

namespace eval ::poBmpData {
    namespace export appendToFile
    namespace export bottom
    namespace export bottomleft
    namespace export bottomright
    namespace export browse
    namespace export camera
    namespace export cell
    namespace export center
    namespace export circle
    namespace export clear
    namespace export clearall
    namespace export clearleft
    namespace export clearright
    namespace export closedfolder
    namespace export copy
    namespace export createfolder
    namespace export cut
    namespace export delete
    namespace export delfolder
    namespace export diff
    namespace export down
    namespace export edit
    namespace export eject
    namespace export endless
    namespace export entity
    namespace export first
    namespace export fliphori
    namespace export flipvert
    namespace export halt
    namespace export hidden
    namespace export histo
    namespace export hundred
    namespace export info
    namespace export invert
    namespace export last
    namespace export left
    namespace export lightmodel
    namespace export lightsource
    namespace export logerror
    namespace export logident
    namespace export logignore
    namespace export material
    namespace export maximize
    namespace export move
    namespace export newfile
    namespace export nocell
    namespace export open
    namespace export openIndex
    namespace export openTemplate
    namespace export openleft
    namespace export openright
    namespace export paste
    namespace export pause
    namespace export playbegin
    namespace export playend
    namespace export playfwd
    namespace export playfwdstep
    namespace export playrev
    namespace export playrevstep
    namespace export polygon
    namespace export pptToIndex
    namespace export preview
    namespace export print
    namespace export questionmark
    namespace export rectangle
    namespace export redo
    namespace export renCtrl
    namespace export renIn
    namespace export renOut
    namespace export rename
    namespace export rescan
    namespace export right
    namespace export rotate
    namespace export save
    namespace export saveleft
    namespace export saveright
    namespace export scale
    namespace export search
    namespace export searchleft
    namespace export searchright
    namespace export selectall
    namespace export stamp
    namespace export stampall
    namespace export stop
    namespace export subscan
    namespace export texture
    namespace export top
    namespace export topleft
    namespace export topright
    namespace export undo
    namespace export unselectall
    namespace export up
    namespace export update
    namespace export view
    namespace export wheel
    namespace export white
}

proc ::poBmpData::appendToFile {} {
return {
#define appendToFile_width 16
#define appendToFile_height 16
static char appendToFile_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0xf8, 0x07,
  0x08, 0x0c,
  0x08, 0x14,
  0x08, 0x3c,
  0x48, 0x20,
  0xc8, 0x20,
  0xfe, 0x21,
  0xfe, 0x21,
  0xc8, 0x20,
  0x48, 0x20,
  0x08, 0x20,
  0x08, 0x20,
  0xf8, 0x3f,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::appendToFile

proc ::poBmpData::bottom {} {
return {
#define bottom_width 16
#define bottom_height 16
static char bottom_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0xc0, 0x01,
  0xc0, 0x01,
  0xc0, 0x01,
  0xf8, 0x0f,
  0xf0, 0x07,
  0xe0, 0x03,
  0xc0, 0x01,
  0x80, 0x00,
  0x00, 0x00,
  0xf8, 0x0f,
  0xf8, 0x0f,
  0xf8, 0x0f,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::bottom

proc ::poBmpData::bottomleft {} {
return {
#define bottomleft_width 16
#define bottomleft_height 16
static unsigned char bottomleft_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x7d, 0xbe, 0x45, 0xa2, 0x45, 0xa2, 0x45, 0xa2,
   0x7d, 0xbe, 0x01, 0x80, 0x01, 0x80, 0x7d, 0xbe, 0x7d, 0xa2, 0x7d, 0xa2,
   0x7d, 0xa2, 0x7d, 0xbe, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::bottomleft

proc ::poBmpData::bottomright {} {
return {
#define bottomright_width 16
#define bottomright_height 16
static unsigned char bottomright_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x7d, 0xbe, 0x45, 0xa2, 0x45, 0xa2, 0x45, 0xa2,
   0x7d, 0xbe, 0x01, 0x80, 0x01, 0x80, 0x7d, 0xbe, 0x45, 0xbe, 0x45, 0xbe,
   0x45, 0xbe, 0x7d, 0xbe, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::bottomright

proc ::poBmpData::browse {} {
return {
#define browse_width 16
#define browse_height 16
static char browse_bits[] = {
  0x00, 0x00,
  0x04, 0x00,
  0xc4, 0x03,
  0x7c, 0x02,
  0xc4, 0x03,
  0x04, 0x00,
  0xc4, 0x03,
  0x7c, 0x02,
  0xc4, 0x03,
  0x04, 0x00,
  0xc4, 0x03,
  0x7c, 0x02,
  0xc4, 0x03,
  0x04, 0x00,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::browse

proc ::poBmpData::camera {} {
return {
#define camera_width 16
#define camera_height 16
static char camera_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x0c,
  0xfc, 0x3f,
  0xfc, 0x3f,
  0x04, 0x20,
  0x04, 0x20,
  0x84, 0x21,
  0x44, 0x22,
  0x44, 0x22,
  0x84, 0x21,
  0x04, 0x20,
  0x04, 0x20,
  0xfc, 0x3f,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::camera

proc ::poBmpData::cell {} {
return {
#define cell_width 12
#define cell_height 12
static unsigned char cell_bits[] = {
   0xff, 0x0f, 0x01, 0x08, 0x01, 0x08, 0x01, 0x08, 0x01, 0x08, 0x01, 0x08,
   0x01, 0x08, 0x01, 0x08, 0x01, 0x08, 0x01, 0x08, 0x01, 0x08, 0xff, 0x0f};
}
} ; # End of proc ::poBmpData::cell

proc ::poBmpData::center {} {
return {
#define center_width 16
#define center_height 16
static unsigned char center_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0xe1, 0x87,
   0xe1, 0x87, 0xe1, 0x87, 0xe1, 0x87, 0xe1, 0x87, 0xe1, 0x87, 0x01, 0x80,
   0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::center

proc ::poBmpData::circle {} {
return {
#define circle_width 16
#define circle_height 16
static char circle_bits[] = {
  0xc0, 0x07,
  0x30, 0x18,
  0x08, 0x20,
  0x04, 0x40,
  0x04, 0x40,
  0x02, 0x80,
  0x02, 0x80,
  0x02, 0x80,
  0x02, 0x80,
  0x02, 0x80,
  0x04, 0x40,
  0x04, 0x40,
  0x08, 0x20,
  0x30, 0x18,
  0xc0, 0x07,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::circle

proc ::poBmpData::clear {} {
return {
#define clear_width 16
#define clear_height 16
static unsigned char clear_bits[] = {
   0x30, 0x00, 0x30, 0x00, 0x60, 0x00, 0x60, 0x00, 0xc0, 0x00, 0xc0, 0x00,
   0x80, 0x01, 0x80, 0x01, 0xfc, 0x3f, 0xfe, 0x7f, 0x24, 0x49, 0xb6, 0x6d,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe, 0x7f};
}
} ; # End of proc ::poBmpData::clear

proc ::poBmpData::clearall {} {
return {
#define clearall_width 16
#define clearall_height 16
static unsigned char clearall_bits[] = {
   0x30, 0x00, 0x30, 0x00, 0x60, 0x00, 0x60, 0x00, 0xc0, 0x00, 0xc0, 0x00,
   0x80, 0x01, 0x80, 0x01, 0xfc, 0x3f, 0xfe, 0x7f, 0x24, 0x49, 0xb6, 0x6d,
   0x00, 0x00, 0xfe, 0x7f, 0x00, 0x00, 0xfe, 0x7f};
}
} ; # End of proc ::poBmpData::clearall

proc ::poBmpData::clearleft {} {
return {
#define clearleft_width 16
#define clearleft_height 16
static char clearleft_bits[] = {
  0x30, 0x04,
  0x30, 0x7e,
  0x60, 0x7e,
  0x60, 0x04,
  0xc0, 0x00,
  0xc0, 0x00,
  0x80, 0x01,
  0x80, 0x01,
  0xfc, 0x3f,
  0xfe, 0x7f,
  0x24, 0x49,
  0xb6, 0x6d,
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0xfe, 0x7f};
}
} ; # End of proc ::poBmpData::clearleft

proc ::poBmpData::clearright {} {
return {
#define clearright_width 16
#define clearright_height 16
static char clearright_bits[] = {
  0x30, 0x20,
  0x30, 0x7e,
  0x60, 0x7e,
  0x60, 0x20,
  0xc0, 0x00,
  0xc0, 0x00,
  0x80, 0x01,
  0x80, 0x01,
  0xfc, 0x3f,
  0xfe, 0x7f,
  0x24, 0x49,
  0xb6, 0x6d,
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0xfe, 0x7f};
}
} ; # End of proc ::poBmpData::clearright

proc ::poBmpData::closedfolder {} {
return {
#define closedfolder_width 16
#define closedfolder_height 16
#define closedfolder_x_hot 0
#define closedfolder_y_hot 0
static unsigned char closedfolder_bits[] = {
   0x00, 0x00, 0xf8, 0x00, 0x04, 0x01, 0xfe, 0x7f, 0x02, 0x40, 0x02, 0x40,
   0x02, 0x40, 0x02, 0x40, 0x02, 0x40, 0x02, 0x40, 0x02, 0x40, 0x02, 0x40,
   0xfe, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::closedfolder

proc ::poBmpData::copy {} {
return {
#define copy_width 16
#define copy_height 16
static unsigned char copy_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x3f, 0x00, 0x61, 0x00, 0xa1, 0x00, 0xed, 0x0f,
   0x41, 0x18, 0x7d, 0x28, 0x41, 0x7b, 0x7d, 0x40, 0x41, 0x5f, 0x7f, 0x40,
   0x40, 0x5f, 0x40, 0x40, 0xc0, 0x7f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::copy

proc ::poBmpData::createfolder {} {
return {
#define createfolder_width 16
#define createfolder_height 16
#define createfolder_x_hot 0
#define createfolder_y_hot 4
static unsigned char createfolder_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0xf8, 0x24,
   0x04, 0x19, 0xfe, 0x0f, 0x02, 0x18, 0x02, 0x28, 0x02, 0x08, 0x02, 0x08,
   0x02, 0x08, 0x02, 0x08, 0xfe, 0x0f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::createfolder

proc ::poBmpData::cut {} {
return {
#define cut_width 16
#define cut_height 16
static unsigned char cut_bits[] = {
   0x00, 0x00, 0x20, 0x02, 0x20, 0x02, 0x20, 0x02, 0x60, 0x03, 0x40, 0x01,
   0xc0, 0x01, 0x80, 0x00, 0xc0, 0x01, 0x40, 0x07, 0x70, 0x09, 0x48, 0x09,
   0x48, 0x09, 0x48, 0x06, 0x30, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::cut

proc ::poBmpData::delete {} {
return {
#define delete_width 16
#define delete_height 16
static unsigned char delete_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x0c, 0x30, 0x18, 0x18, 0x30, 0x0c, 0x60, 0x06,
   0xc0, 0x03, 0x80, 0x01, 0xc0, 0x03, 0x60, 0x06, 0x30, 0x0c, 0x18, 0x18,
   0x0c, 0x30, 0x04, 0x20, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::delete

proc ::poBmpData::delfolder {} {
return {
#define delfolder_width 16
#define delfolder_height 16
#define delfolder_x_hot 0
#define delfolder_y_hot 4
static unsigned char delfolder_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0x00,
   0x04, 0x01, 0xfe, 0x0f, 0x12, 0x09, 0xb2, 0x09, 0xe2, 0x08, 0xe2, 0x08,
   0xb2, 0x09, 0x12, 0x09, 0xfe, 0x0f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::delfolder

proc ::poBmpData::diff {} {
return {
#define diff_width 16
#define diff_height 16
static unsigned char diff_bits[] = {
   0xff, 0x01, 0x01, 0x03, 0x3d, 0x05, 0x01, 0x0f, 0x3d, 0x08, 0x01, 0x0f,
   0x9d, 0x10, 0x41, 0x20, 0x5d, 0x20, 0x41, 0x20, 0x5d, 0x20, 0x81, 0x10,
   0x3d, 0x6f, 0x01, 0xe8, 0xff, 0xcf, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::diff

proc ::poBmpData::down {} {
return {
#define down_width 16
#define down_height 16
static char down_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0xc0, 0x01,
  0xc0, 0x01,
  0xc0, 0x01,
  0xf8, 0x0f,
  0xf0, 0x07,
  0xe0, 0x03,
  0xc0, 0x01,
  0x80, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::down

proc ::poBmpData::edit {} {
return {
#define edit_width 16
#define edit_height 16
static char edit_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0x60, 0x00,
  0x60, 0x00,
  0xc0, 0x00,
  0xc0, 0x00,
  0x80, 0x01,
  0x80, 0x01,
  0x00, 0x03,
  0x00, 0x03,
  0x00, 0x06,
  0x00, 0x06,
  0x00, 0x04,
  0x00, 0x00,
  0xfe, 0x7f,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::edit

proc ::poBmpData::eject {} {
return {
#define eject_width 16
#define eject_height 16
static char eject_bits[] = {
  0xff, 0xff,
  0x01, 0x80,
  0x01, 0x80,
  0x81, 0x81,
  0xc1, 0x83,
  0xe1, 0x87,
  0xf1, 0x8f,
  0xf9, 0x9f,
  0xfd, 0xbf,
  0x01, 0x80,
  0x01, 0x80,
  0xfd, 0xbf,
  0xfd, 0xbf,
  0xfd, 0xbf,
  0x01, 0x80,
  0xff, 0xff};
}
} ; # End of proc ::poBmpData::eject

proc ::poBmpData::endless {} {
return {
#define endless_width 16
#define endless_height 16
static char endless_bits[] = {
  0xff, 0xff,
  0x01, 0x80,
  0x01, 0x80,
  0xf1, 0x81,
  0x09, 0x82,
  0x05, 0x84,
  0x05, 0x84,
  0x05, 0x84,
  0x05, 0x9f,
  0x05, 0x8e,
  0x09, 0x84,
  0x71, 0x80,
  0x01, 0x80,
  0x01, 0x80,
  0x01, 0x80,
  0xff, 0xff};
}
} ; # End of proc ::poBmpData::endless

proc ::poBmpData::entity {} {
return {
#define entity_width 16
#define entity_height 16
static char entity_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0x80, 0x01,
  0xc0, 0x03,
  0xe0, 0x07,
  0xc0, 0x03,
  0xc0, 0x03,
  0x80, 0x01,
  0x80, 0x01,
  0x80, 0x01,
  0xf0, 0x0f,
  0xf8, 0x1f,
  0xf8, 0x1f,
  0xf8, 0x1f,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::entity

proc ::poBmpData::first {} {
return {
#define first_width 16
#define first_height 16
static unsigned char first_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x04, 0x1c, 0x06,
   0x1c, 0x07, 0x9c, 0x3f, 0xdc, 0x3f, 0x9c, 0x3f, 0x1c, 0x07, 0x1c, 0x06,
   0x1c, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::first

proc ::poBmpData::fliphori {} {
return {
#define fliphori_width 16
#define fliphori_height 16
static char fliphori_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0x80, 0x01,
  0xc0, 0x03,
  0xe0, 0x07,
  0x00, 0x00,
  0x00, 0x00,
  0xfc, 0x3f,
  0xfc, 0x3f,
  0x00, 0x00,
  0x00, 0x00,
  0xe0, 0x07,
  0xc0, 0x03,
  0x80, 0x01,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::fliphori

proc ::poBmpData::flipvert {} {
return {
#define flipvert_width 16
#define flipvert_height 16
static char flipvert_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0x80, 0x01,
  0x80, 0x01,
  0x80, 0x01,
  0x90, 0x09,
  0x98, 0x19,
  0x9c, 0x39,
  0x9c, 0x39,
  0x98, 0x19,
  0x90, 0x09,
  0x80, 0x01,
  0x80, 0x01,
  0x80, 0x01,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::flipvert

proc ::poBmpData::halt {} {
return {
#define halt_width 16
#define halt_height 16
static unsigned char halt_bits[] = {
   0x00, 0x00, 0xe0, 0x07, 0x10, 0x08, 0x88, 0x11, 0x84, 0x21, 0x82, 0x41,
   0x82, 0x41, 0x82, 0x41, 0x82, 0x41, 0x82, 0x41, 0x02, 0x40, 0x84, 0x21,
   0x88, 0x11, 0x10, 0x08, 0xe0, 0x07, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::halt

proc ::poBmpData::hidden {} {
return {
#define hidden_width 16
#define hidden_height 16
static unsigned char hidden_bits[] = {
   0x00, 0x00, 0x04, 0x00, 0xc4, 0x03, 0xfc, 0x03, 0xc4, 0x03, 0x04, 0x00,
   0xc4, 0x03, 0xfc, 0x03, 0xc4, 0x03, 0x04, 0x00, 0xc4, 0x03, 0xfc, 0x03,
   0xc4, 0x03, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::hidden

proc ::poBmpData::histo {} {
return {
#define histo_width 16
#define histo_height 16
static unsigned char histo_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x84, 0x22, 0x84, 0x23,
   0xc6, 0x33, 0xc6, 0x33, 0xd6, 0x7b, 0xf6, 0x7f, 0xfe, 0x7f, 0xfe, 0x7f,
   0xfe, 0x7f, 0xfe, 0x7f, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::histo

proc ::poBmpData::hundred {} {
return {
#define hundred_width 16
#define hundred_height 16
static unsigned char hundred_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0xcc, 0x71, 0x2a, 0x8a, 0x29, 0x8a, 0x28, 0x8a,
   0x28, 0x8a, 0x28, 0x8a, 0x28, 0x8a, 0x28, 0x8a, 0x28, 0x8a, 0x28, 0x8a,
   0x28, 0x8a, 0xc8, 0x71, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::hundred

proc ::poBmpData::info {} {
return {
#define info_width 16
#define info_height 16
static unsigned char info_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x80, 0x01, 0x00, 0x00, 0x00, 0x00,
   0xc0, 0x03, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01,
   0x80, 0x01, 0xe0, 0x07, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::info

proc ::poBmpData::invert {} {
return {
#define invert_width 16
#define invert_height 16
static char invert_bits[] = {
  0xff, 0xff,
  0x01, 0x80,
  0x7d, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x7d, 0xbe,
  0x01, 0x80,
  0xff, 0xff};
}
} ; # End of proc ::poBmpData::invert

proc ::poBmpData::last {} {
return {
#define last_width 16
#define last_height 16
static unsigned char last_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x38, 0x60, 0x38,
   0xe0, 0x38, 0xfc, 0x39, 0xfc, 0x3b, 0xfc, 0x39, 0xe0, 0x38, 0x60, 0x38,
   0x20, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::last

proc ::poBmpData::left {} {
return {
#define left_width 16
#define left_height 16
static unsigned char left_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x80, 0x01,
   0xc0, 0x01, 0xe0, 0x0f, 0xf0, 0x0f, 0xe0, 0x0f, 0xc0, 0x01, 0x80, 0x01,
   0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::left

proc ::poBmpData::lightmodel {} {
return {
#define lightmodel_width 16
#define lightmodel_height 16
static char lightmodel_bits[] = {
  0x00, 0x00,
  0xf8, 0x0f,
  0x04, 0x04,
  0x02, 0x02,
  0x02, 0x09,
  0x82, 0x10,
  0x42, 0x22,
  0x22, 0x04,
  0x92, 0x08,
  0x0a, 0x11,
  0x26, 0x02,
  0x42, 0x04,
  0x88, 0x08,
  0x10, 0x01,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::lightmodel

proc ::poBmpData::lightsource {} {
return {
#define light_width 16
#define light_height 16
static char light_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0x80, 0x01,
  0x80, 0x01,
  0x80, 0x01,
  0x80, 0x01,
  0x40, 0x02,
  0x20, 0x04,
  0x10, 0x08,
  0x08, 0x10,
  0xfc, 0x3f,
  0x40, 0x02,
  0x40, 0x02,
  0x80, 0x01,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::lightsource

proc ::poBmpData::logerror {} {
return {
#define logerr_width 16
#define logerr_height 16
static unsigned char logerr_bits[] = {
   0xfe, 0x0f, 0x02, 0x18, 0x02, 0x28, 0x02, 0x78, 0x02, 0x40, 0x3a, 0x40,
   0x0a, 0x40, 0x0a, 0x40, 0x9a, 0x4d, 0x8a, 0x44, 0x8a, 0x44, 0x8a, 0x44,
   0xba, 0x44, 0x02, 0x40, 0xfe, 0x7f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::logerror

proc ::poBmpData::logident {} {
return {
#define logident_width 16
#define logident_height 16
static unsigned char logident_bits[] = {
   0xfe, 0x0f, 0x02, 0x18, 0x02, 0x28, 0x02, 0x78, 0x02, 0x40, 0x02, 0x40,
   0x02, 0x40, 0x02, 0x40, 0xe2, 0x47, 0x02, 0x40, 0xe2, 0x47, 0x02, 0x40,
   0x02, 0x40, 0x02, 0x40, 0xfe, 0x7f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::logident

proc ::poBmpData::logignore {} {
return {
#define logignore_width 16
#define logignore_height 16
static unsigned char logignore_bits[] = {
   0xfe, 0x0f, 0x02, 0x18, 0x02, 0x28, 0x02, 0x78, 0x02, 0x40, 0x02, 0x40,
   0x02, 0x40, 0x02, 0x40, 0xf2, 0x47, 0x02, 0x44, 0x02, 0x44, 0x02, 0x44,
   0x02, 0x40, 0x02, 0x40, 0xfe, 0x7f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::logignore

proc ::poBmpData::material {} {
return {
#define material_width 16
#define material_height 16
static char material_bits[] = {
  0x00, 0x00,
  0xf8, 0x07,
  0x04, 0x08,
  0x02, 0x10,
  0x12, 0x21,
  0xb2, 0x41,
  0x52, 0x41,
  0x12, 0x41,
  0x12, 0x41,
  0x12, 0x41,
  0x02, 0x20,
  0x04, 0x10,
  0x08, 0x08,
  0x10, 0x04,
  0xe0, 0x03,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::material

proc ::poBmpData::maximize {} {
return {
#define maximize_width 16
#define maximize_height 16
static char maximize_bits[] = {
  0x00, 0x00,
  0xfe, 0x7f,
  0xfe, 0x7f,
  0xfe, 0x7f,
  0xfe, 0x7f,
  0x06, 0x60,
  0x06, 0x60,
  0x06, 0x60,
  0x06, 0x60,
  0x06, 0x60,
  0x06, 0x60,
  0x06, 0x60,
  0x06, 0x60,
  0x06, 0x60,
  0xfe, 0x7f,
  0xfe, 0x7f};
}
} ; # End of proc ::poBmpData::maximize

proc ::poBmpData::move {} {
return {
#define move_width 16
#define move_height 16
static char move_bits[] = {
  0x00, 0x00,
  0x80, 0x01,
  0xc0, 0x03,
  0x80, 0x01,
  0x80, 0x01,
  0x80, 0x01,
  0x84, 0x21,
  0xfe, 0x7f,
  0xfe, 0x7f,
  0x84, 0x21,
  0x80, 0x01,
  0x80, 0x01,
  0x80, 0x01,
  0xc0, 0x03,
  0x80, 0x01,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::move

proc ::poBmpData::newfile {} {
return {
#define newfile_width 16
#define newfile_height 16
static unsigned char newfile_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0xfc, 0x03, 0x04, 0x06, 0x04, 0x0a, 0x04, 0x1e,
   0x04, 0x10, 0x04, 0x10, 0x04, 0x10, 0x04, 0x10, 0x04, 0x10, 0x04, 0x10,
   0x04, 0x10, 0x04, 0x10, 0xfc, 0x1f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::newfile

proc ::poBmpData::nocell {} {
return {
#define nocell_width 12
#define nocell_height 12
static unsigned char nocell_bits[] = {
   0xff, 0x0f, 0x03, 0x0c, 0x05, 0x0a, 0x09, 0x09, 0x91, 0x08, 0x61, 0x08,
   0x61, 0x08, 0x91, 0x08, 0x09, 0x09, 0x05, 0x0a, 0x03, 0x0c, 0xff, 0x0f};
}
} ; # End of proc ::poBmpData::nocell

proc ::poBmpData::open {} {
return {
#define open_width 16
#define open_height 16
static unsigned char open_bits[] = {
   0x00, 0x00, 0x00, 0x0e, 0x00, 0x51, 0x00, 0x60, 0x0e, 0x70, 0xf1, 0x07,
   0x01, 0x04, 0x01, 0x04, 0xe1, 0xff, 0x11, 0x40, 0x09, 0x20, 0x05, 0x10,
   0x03, 0x08, 0xff, 0x07, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::open

proc ::poBmpData::openIndex {} {
return {
#define openIndex_width 16
#define openIndex_height 16
static unsigned char openIndex_bits[] = {
   0x00, 0xe0, 0x00, 0x40, 0x00, 0x40, 0x00, 0x40, 0x0e, 0x40, 0xf1, 0xe7,
   0x01, 0x04, 0x01, 0x04, 0xe1, 0xff, 0x11, 0x40, 0x09, 0x20, 0x05, 0x10,
   0x03, 0x08, 0xff, 0x07, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::openIndex

proc ::poBmpData::openTemplate {} {
return {
#define openTemplate_width 16
#define openTemplate_height 16
static char openTemplate_bits[] = {
  0x00, 0xf8,
  0x00, 0x20,
  0x00, 0x20,
  0x00, 0x20,
  0x0e, 0x20,
  0xf1, 0x07,
  0x01, 0x04,
  0x01, 0x04,
  0xe1, 0xff,
  0x11, 0x40,
  0x09, 0x20,
  0x05, 0x10,
  0x03, 0x08,
  0xff, 0x07,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::openTemplate

proc ::poBmpData::openleft {} {
return {
#define openleft_width 16
#define openleft_height 16
static unsigned char openleft_bits[] = {
   0x00, 0x04, 0x00, 0x7e, 0x00, 0x7e, 0x00, 0x04, 0x0e, 0x00, 0xf1, 0x07,
   0x01, 0x04, 0x01, 0x04, 0xe1, 0xff, 0x11, 0x40, 0x09, 0x20, 0x05, 0x10,
   0x03, 0x08, 0xff, 0x07, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::openleft

proc ::poBmpData::openright {} {
return {
#define openright_width 16
#define openright_height 16
static unsigned char openright_bits[] = {
   0x00, 0x20, 0x00, 0x7e, 0x00, 0x7e, 0x00, 0x20, 0x0e, 0x00, 0xf1, 0x07,
   0x01, 0x04, 0x01, 0x04, 0xe1, 0xff, 0x11, 0x40, 0x09, 0x20, 0x05, 0x10,
   0x03, 0x08, 0xff, 0x07, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::openright

proc ::poBmpData::paste {} {
return {
#define paste_width 16
#define paste_height 16
static unsigned char paste_bits[] = {
   0x00, 0x00, 0xe0, 0x01, 0x3e, 0x1f, 0xd1, 0x22, 0x09, 0x24, 0xf9, 0x27,
   0x01, 0x20, 0xc1, 0x3f, 0x41, 0x30, 0x41, 0x50, 0x41, 0xf7, 0x41, 0x80,
   0x41, 0xbf, 0x7e, 0x80, 0xc0, 0xff, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::paste

proc ::poBmpData::pause {} {
return {
#define pause_width 16
#define pause_height 16
static char pause_bits[] = {
  0xff, 0xff,
  0x01, 0x80,
  0x01, 0x80,
  0x61, 0x86,
  0x61, 0x86,
  0x61, 0x86,
  0x61, 0x86,
  0x61, 0x86,
  0x61, 0x86,
  0x61, 0x86,
  0x61, 0x86,
  0x61, 0x86,
  0x61, 0x86,
  0x61, 0x86,
  0x01, 0x80,
  0xff, 0xff};
}
} ; # End of proc ::poBmpData::pause

proc ::poBmpData::playbegin {} {
return {
#define playbegin_width 16
#define playbegin_height 16
static unsigned char playbegin_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x01, 0x80, 0x39, 0x90, 0x39, 0x98, 0x39, 0x9c,
   0x39, 0x9e, 0x39, 0x9f, 0xb9, 0x9f, 0x39, 0x9f, 0x39, 0x9e, 0x39, 0x9c,
   0x39, 0x98, 0x39, 0x90, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::playbegin

proc ::poBmpData::playend {} {
return {
#define playend_width 16
#define playend_height 16
static unsigned char playend_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x01, 0x80, 0x09, 0x9c, 0x19, 0x9c, 0x39, 0x9c,
   0x79, 0x9c, 0xf9, 0x9c, 0xf9, 0x9d, 0xf9, 0x9c, 0x79, 0x9c, 0x39, 0x9c,
   0x19, 0x9c, 0x09, 0x9c, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::playend

proc ::poBmpData::playfwd {} {
return {
#define play_width 16
#define play_height 16
static unsigned char play_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x01, 0x80, 0x21, 0x80, 0x61, 0x80, 0xe1, 0x80,
   0xe1, 0x81, 0xe1, 0x83, 0xe1, 0x87, 0xe1, 0x83, 0xe1, 0x81, 0xe1, 0x80,
   0x61, 0x80, 0x21, 0x80, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::playfwd

proc ::poBmpData::playfwdstep {} {
return {
#define playfwdstep_width 16
#define playfwdstep_height 16
static char playfwdstep_bits[] = {
  0xff, 0xff,
  0x01, 0x80,
  0x01, 0x80,
  0x39, 0x81,
  0x39, 0x83,
  0x39, 0x87,
  0x39, 0x8f,
  0x39, 0x9f,
  0x39, 0xbf,
  0x39, 0x9f,
  0x39, 0x8f,
  0x39, 0x87,
  0x39, 0x83,
  0x39, 0x81,
  0x01, 0x80,
  0xff, 0xff};
}
} ; # End of proc ::poBmpData::playfwdstep

proc ::poBmpData::playrev {} {
return {
#define playrev_width 16
#define playrev_height 16
static unsigned char playrev_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x01, 0x80, 0x01, 0x84, 0x01, 0x86, 0x01, 0x87,
   0x81, 0x87, 0xc1, 0x87, 0xe1, 0x87, 0xc1, 0x87, 0x81, 0x87, 0x01, 0x87,
   0x01, 0x86, 0x01, 0x84, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::playrev

proc ::poBmpData::playrevstep {} {
return {
#define playrevstep_width 16
#define playrevstep_height 16
static char playrevstep_bits[] = {
  0xff, 0xff,
  0x01, 0x80,
  0x01, 0x80,
  0x81, 0x9c,
  0xc1, 0x9c,
  0xe1, 0x9c,
  0xf1, 0x9c,
  0xf9, 0x9c,
  0xfd, 0x9c,
  0xf9, 0x9c,
  0xf1, 0x9c,
  0xe1, 0x9c,
  0xc1, 0x9c,
  0x81, 0x9c,
  0x01, 0x80,
  0xff, 0xff};
}
} ; # End of proc ::poBmpData::playrevstep

proc ::poBmpData::polygon {} {
return {
#define polygon_width 16
#define polygon_height 16
static char polygon_bits[] = {
  0x00, 0x00,
  0xf8, 0x07,
  0x04, 0x08,
  0x02, 0x10,
  0x02, 0x20,
  0x02, 0x40,
  0x02, 0x20,
  0x02, 0x10,
  0x02, 0x08,
  0x02, 0x04,
  0x02, 0x02,
  0x04, 0x01,
  0x88, 0x00,
  0x50, 0x00,
  0x20, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::polygon

proc ::poBmpData::pptToIndex {} {
return {
#define pptToIndex_width 54
#define pptToIndex_height 16
static char pptToIndex_bits[] = {
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x3e, 0x9f, 0x0f, 0x00, 0x9f, 0x90, 0x07,
  0x22, 0x11, 0x02, 0x00, 0x84, 0x91, 0x08,
  0x22, 0x11, 0x02, 0x00, 0x84, 0x91, 0x08,
  0x22, 0x11, 0x02, 0x08, 0x84, 0x92, 0x08,
  0x22, 0x11, 0x02, 0x18, 0x84, 0x92, 0x08,
  0x3e, 0x1f, 0xc2, 0x3f, 0x84, 0x92, 0x08,
  0x02, 0x01, 0xc2, 0x3f, 0x84, 0x94, 0x08,
  0x02, 0x01, 0x02, 0x18, 0x84, 0x94, 0x08,
  0x02, 0x01, 0x02, 0x08, 0x84, 0x94, 0x08,
  0x02, 0x01, 0x02, 0x00, 0x84, 0x98, 0x08,
  0x02, 0x01, 0x02, 0x00, 0x84, 0x98, 0x08,
  0x02, 0x01, 0x02, 0x00, 0x9f, 0x90, 0x07,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::pptToIndex

proc ::poBmpData::preview {} {
return {
#define preview_width 16
#define preview_height 16
static char preview_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0xff, 0xff,
  0xff, 0xff,
  0x01, 0x80,
  0x01, 0x80,
  0x7d, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x45, 0xbe,
  0x7d, 0xbe,
  0x01, 0x80,
  0x01, 0x80,
  0xff, 0xff,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::preview

proc ::poBmpData::print {} {
return {
#define print_width 16
#define print_height 16
static unsigned char print_bits[] = {
   0x00, 0x00, 0xe0, 0x3f, 0x10, 0x20, 0xd0, 0x17, 0x08, 0x10, 0xe8, 0x7b,
   0x04, 0xa8, 0xfe, 0xd7, 0x01, 0xa8, 0xff, 0x9f, 0x01, 0x50, 0x01, 0x70,
   0xff, 0x5f, 0x02, 0x28, 0xfc, 0x1f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::print

proc ::poBmpData::questionmark {} {
return {
#define questionmark_width 16
#define questionmark_height 16
static char questionmark_bits[] = {
  0x80, 0x01,
  0x40, 0x02,
  0x20, 0x04,
  0x00, 0x04,
  0x00, 0x04,
  0x00, 0x02,
  0x80, 0x01,
  0x40, 0x00,
  0x20, 0x00,
  0x20, 0x00,
  0x20, 0x04,
  0x40, 0x02,
  0x80, 0x01,
  0x00, 0x00,
  0x80, 0x01,
  0x80, 0x01};
}
} ; # End of proc ::poBmpData::questionmark

proc ::poBmpData::rectangle {} {
return {
#define rectangle_width 16
#define rectangle_height 16
static char rectangle_bits[] = {
  0x00, 0x00,
  0xfe, 0x7f,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0xfe, 0x7f,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::rectangle

proc ::poBmpData::redo {} {
return {
#define redo_width 16
#define redo_height 16
static char redo_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0xc0, 0x07,
  0x20, 0x08,
  0x10, 0x10,
  0x10, 0x10,
  0x10, 0x10,
  0x10, 0x7c,
  0x10, 0x38,
  0x20, 0x10,
  0x40, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::redo

proc ::poBmpData::renCtrl {} {
return {
#define renctrl_width 16
#define renctrl_height 16
static char renctrl_bits[] = {
  0xfe, 0x7f,
  0xfe, 0x7f,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x40,
  0x02, 0x48,
  0x02, 0x44,
  0xe2, 0x42,
  0x22, 0x41,
  0x22, 0x42,
  0x22, 0x42,
  0x22, 0x42,
  0xe2, 0x43,
  0x02, 0x40,
  0x02, 0x40,
  0xfe, 0x7f};
}
} ; # End of proc ::poBmpData::renCtrl

proc ::poBmpData::renIn {} {
return {
#define renin_width 16
#define renin_height 16
static char renin_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0xfc, 0x00,
  0x84, 0x01,
  0x84, 0x02,
  0x84, 0x07,
  0x04, 0x14,
  0x04, 0x34,
  0xc4, 0x7f,
  0xc4, 0x7f,
  0x04, 0x34,
  0x04, 0x14,
  0x04, 0x04,
  0x04, 0x04,
  0xfc, 0x07,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::renIn

proc ::poBmpData::renOut {} {
return {
#define renOut_width 16
#define renOut_height 16
static char renOut_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0xf8, 0x07,
  0x08, 0x0c,
  0x08, 0x14,
  0x08, 0x3c,
  0x48, 0x20,
  0xc8, 0x20,
  0xfe, 0x21,
  0xfe, 0x21,
  0xc8, 0x20,
  0x48, 0x20,
  0x08, 0x20,
  0x08, 0x20,
  0xf8, 0x3f,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::renOut

proc ::poBmpData::rename {} {
return {
#define rename_width 16
#define rename_height 16
static unsigned char rename_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x11, 0xf8, 0x11, 0x88, 0x11, 0x88, 0x11, 0x88,
   0x91, 0x88, 0x91, 0x89, 0xd1, 0xfb, 0x91, 0x89, 0x91, 0x88, 0x11, 0x88,
   0x11, 0x88, 0x1f, 0x88, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::rename

proc ::poBmpData::rescan {} {
return {
#define rescan_width 16
#define rescan_height 16
static unsigned char rescan_bits[] = {
   0x00, 0x00, 0x08, 0x00, 0x08, 0x00, 0x88, 0x1f, 0x88, 0x10, 0xfe, 0x10,
   0xae, 0x10, 0xae, 0x1f, 0x2e, 0x00, 0x2e, 0x7e, 0x2e, 0x42, 0xee, 0x43,
   0x0e, 0x42, 0x1f, 0x7e, 0x0e, 0x00, 0x04, 0x00};
}
} ; # End of proc ::poBmpData::rescan

proc ::poBmpData::right {} {
return {
#define right_width 16
#define right_height 16
static unsigned char right_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x01,
   0x80, 0x03, 0xf0, 0x07, 0xf0, 0x0f, 0xf0, 0x07, 0x80, 0x03, 0x80, 0x01,
   0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::right

proc ::poBmpData::rotate {} {
return {
#define rotate_width 16
#define rotate_height 16
static char rotate_bits[] = {
  0x00, 0x08,
  0x7e, 0x7c,
  0x02, 0x48,
  0x02, 0x40,
  0xf7, 0x4f,
  0x12, 0x48,
  0x10, 0x48,
  0x10, 0x08,
  0x10, 0x08,
  0x12, 0x08,
  0x12, 0x48,
  0xf2, 0xef,
  0x02, 0x40,
  0x12, 0x40,
  0x3e, 0x7e,
  0x10, 0x00};
}
} ; # End of proc ::poBmpData::rotate

proc ::poBmpData::save {} {
return {
#define save_width 16
#define save_height 16
static unsigned char save_bits[] = {
   0x00, 0x00, 0xfe, 0x7f, 0x0a, 0x50, 0x0a, 0x70, 0x0e, 0x50, 0x0e, 0x50,
   0x0e, 0x50, 0x0a, 0x50, 0xf2, 0x4f, 0x02, 0x40, 0xf2, 0x5f, 0xf2, 0x53,
   0xf2, 0x53, 0xf2, 0x53, 0xfc, 0x7f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::save

proc ::poBmpData::saveleft {} {
return {
#define saveleft_width 16
#define saveleft_height 16
static unsigned char saveleft_bits[] = {
   0x00, 0x00, 0xfe, 0x7f, 0x0a, 0x50, 0x4a, 0x70, 0xee, 0x57, 0xee, 0x57,
   0x4e, 0x50, 0x0a, 0x50, 0xf2, 0x4f, 0x02, 0x40, 0xf2, 0x5f, 0xf2, 0x53,
   0xf2, 0x53, 0xf2, 0x53, 0xfc, 0x7f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::saveleft

proc ::poBmpData::saveright {} {
return {
#define saveright_width 16
#define saveright_height 16
static unsigned char saveright_bits[] = {
   0x00, 0x00, 0xfe, 0x7f, 0x0a, 0x50, 0x0a, 0x72, 0xee, 0x57, 0xee, 0x57,
   0x0e, 0x52, 0x0a, 0x50, 0xf2, 0x4f, 0x02, 0x40, 0xf2, 0x5f, 0xf2, 0x53,
   0xf2, 0x53, 0xf2, 0x53, 0xfc, 0x7f, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::saveright

proc ::poBmpData::scale {} {
return {
#define scale_width 16
#define scale_height 16
static char scale_bits[] = {
  0x00, 0x00,
  0xfe, 0x7f,
  0x02, 0x40,
  0x3a, 0x5c,
  0x0a, 0x50,
  0xea, 0x57,
  0x22, 0x44,
  0x22, 0x44,
  0x22, 0x44,
  0x22, 0x44,
  0xea, 0x57,
  0x0a, 0x50,
  0x3a, 0x5c,
  0x02, 0x40,
  0xfe, 0x7f,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::scale

proc ::poBmpData::search {} {
return {
#define search_width 16
#define search_height 16
static unsigned char search_bits[] = {
   0xff, 0x01, 0x01, 0x03, 0x01, 0x05, 0x01, 0x0f, 0x01, 0x08, 0x01, 0x0f,
   0x81, 0x10, 0x41, 0x20, 0x41, 0x20, 0x41, 0x20, 0x41, 0x20, 0x81, 0x10,
   0x01, 0x6f, 0x01, 0xe8, 0xff, 0xcf, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::search

proc ::poBmpData::searchleft {} {
return {
#define searchleft_width 16
#define searchleft_height 16
static char searchleft_bits[] = {
  0xff, 0x01,
  0x01, 0x03,
  0x01, 0x05,
  0x01, 0x0f,
  0x01, 0x08,
  0x01, 0x0f,
  0x81, 0x10,
  0x41, 0x20,
  0xc1, 0x27,
  0xc1, 0x27,
  0x41, 0x20,
  0x81, 0x10,
  0x01, 0x6f,
  0x01, 0xe8,
  0xff, 0xcf,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::searchleft

proc ::poBmpData::searchright {} {
return {
#define searchright_width 16
#define searchright_height 16
static char searchright_bits[] = {
  0xff, 0x01,
  0x01, 0x03,
  0x01, 0x05,
  0x01, 0x0f,
  0x01, 0x08,
  0x01, 0x0f,
  0x81, 0x10,
  0x41, 0x20,
  0x41, 0x3e,
  0x41, 0x3e,
  0x41, 0x20,
  0x81, 0x10,
  0x01, 0x6f,
  0x01, 0xe8,
  0xff, 0xcf,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::searchright

proc ::poBmpData::selectall {} {
return {
#define selectall_width 16
#define selectall_height 16
static char selectall_bits[] = {
  0xff, 0xff,
  0x01, 0x80,
  0x7d, 0xbe,
  0x7d, 0xbe,
  0x7d, 0xbe,
  0x7d, 0xbe,
  0x7d, 0xbe,
  0x01, 0x80,
  0x01, 0x80,
  0x7d, 0xbe,
  0x7d, 0xbe,
  0x7d, 0xbe,
  0x7d, 0xbe,
  0x7d, 0xbe,
  0x01, 0x80,
  0xff, 0xff};
}
} ; # End of proc ::poBmpData::selectall

proc ::poBmpData::stamp {} {
return {
#define stamp_width 16
#define stamp_height 16
static unsigned char stamp_bits[] = {
   0x80, 0x01, 0xc0, 0x03, 0xe0, 0x07, 0xc0, 0x03, 0xc0, 0x03, 0x80, 0x01,
   0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0xf0, 0x0f, 0xf8, 0x1f, 0xf8, 0x1f,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0x1f};
}
} ; # End of proc ::poBmpData::stamp

proc ::poBmpData::stampall {} {
return {
#define stampall_width 16
#define stampall_height 16
static unsigned char stampall_bits[] = {
   0x80, 0x01, 0xc0, 0x03, 0xe0, 0x07, 0xc0, 0x03, 0xc0, 0x03, 0x80, 0x01,
   0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0xf0, 0x0f, 0xf8, 0x1f, 0xf8, 0x1f,
   0x00, 0x00, 0xf8, 0x1f, 0x00, 0x00, 0xf8, 0x1f};
}
} ; # End of proc ::poBmpData::stampall

proc ::poBmpData::stop {} {
return {
#define stop_width 16
#define stop_height 16
static unsigned char stop_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x01, 0x80, 0xe1, 0x87, 0xe1, 0x87, 0xe1, 0x87,
   0xe1, 0x87, 0xe1, 0x87, 0xe1, 0x87, 0xe1, 0x87, 0xe1, 0x87, 0xe1, 0x87,
   0xe1, 0x87, 0xe1, 0x87, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::stop

proc ::poBmpData::subscan {} {
return {
#define subscan_width 16
#define subscan_height 16
static unsigned char subscan_bits[] = {
   0x00, 0x00, 0x04, 0x00, 0x04, 0x00, 0xc4, 0x0f, 0x44, 0x08, 0x7c, 0x08,
   0x54, 0x08, 0xd4, 0x0f, 0x14, 0x00, 0x14, 0x3f, 0x14, 0x21, 0xf4, 0x21,
   0x04, 0x21, 0x04, 0x3f, 0x04, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::subscan

proc ::poBmpData::texture {} {
return {
#define texture_width 16
#define texture_height 16
static char texture_bits[] = {
  0x00, 0x00,
  0xf8, 0x07,
  0x04, 0x08,
  0x02, 0x10,
  0xe2, 0x23,
  0x82, 0x40,
  0x82, 0x40,
  0x82, 0x40,
  0x82, 0x40,
  0x82, 0x40,
  0x82, 0x20,
  0x04, 0x10,
  0x08, 0x08,
  0x10, 0x04,
  0xe0, 0x03,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::texture

proc ::poBmpData::top {} {
return {
#define top_width 16
#define top_height 16
static char top_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0xfc, 0x0f,
  0xfc, 0x0f,
  0xfc, 0x0f,
  0x00, 0x00,
  0x80, 0x00,
  0xc0, 0x01,
  0xe0, 0x03,
  0xf0, 0x07,
  0xf8, 0x0f,
  0xc0, 0x01,
  0xc0, 0x01,
  0xc0, 0x01,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::top

proc ::poBmpData::topleft {} {
return {
#define topleft_width 16
#define topleft_height 16
static unsigned char topleft_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x7d, 0xbe, 0x7d, 0xa2, 0x7d, 0xa2, 0x7d, 0xa2,
   0x7d, 0xbe, 0x01, 0x80, 0x01, 0x80, 0x7d, 0xbe, 0x45, 0xa2, 0x45, 0xa2,
   0x45, 0xa2, 0x7d, 0xbe, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::topleft

proc ::poBmpData::topright {} {
return {
#define topright_width 16
#define topright_height 16
static unsigned char topright_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x7d, 0xbe, 0x45, 0xbe, 0x45, 0xbe, 0x45, 0xbe,
   0x7d, 0xbe, 0x01, 0x80, 0x01, 0x80, 0x7d, 0xbe, 0x45, 0xa2, 0x45, 0xa2,
   0x45, 0xa2, 0x7d, 0xbe, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::topright

proc ::poBmpData::undo {} {
return {
#define undo_width 16
#define undo_height 16
static char undo_bits[] = {
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0xc0, 0x07,
  0x20, 0x08,
  0x10, 0x10,
  0x10, 0x10,
  0x10, 0x10,
  0x7c, 0x10,
  0x38, 0x10,
  0x10, 0x08,
  0x00, 0x04,
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::undo

proc ::poBmpData::unselectall {} {
return {
#define unselectall_width 16
#define unselectall_height 16
static char unselectall_bits[] = {
  0xff, 0xff,
  0x01, 0x80,
  0x7d, 0xbe,
  0x45, 0xa2,
  0x45, 0xa2,
  0x45, 0xa2,
  0x7d, 0xbe,
  0x01, 0x80,
  0x01, 0x80,
  0x7d, 0xbe,
  0x45, 0xa2,
  0x45, 0xa2,
  0x45, 0xa2,
  0x7d, 0xbe,
  0x01, 0x80,
  0xff, 0xff};
}
} ; # End of proc ::poBmpData::unselectall

proc ::poBmpData::up {} {
return {
#define top_width 16
#define top_height 16
static unsigned char top_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xc0, 0x01,
   0xe0, 0x03, 0xf0, 0x07, 0xf8, 0x0f, 0xc0, 0x01, 0xc0, 0x01, 0xc0, 0x01,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
}
} ; # End of proc ::poBmpData::up

proc ::poBmpData::update {} {
return {
#define update_width 16
#define update_height 16
static char update_bits[] = {
  0x00, 0x00,
  0x08, 0x00,
  0x08, 0x00,
  0x88, 0x1f,
  0x88, 0x10,
  0xfe, 0x10,
  0xae, 0x10,
  0xae, 0x1f,
  0x2e, 0x00,
  0x2e, 0x7e,
  0x2e, 0x42,
  0xee, 0x43,
  0x0e, 0x42,
  0x1f, 0x7e,
  0x0e, 0x00,
  0x04, 0x00};
}
} ; # End of proc ::poBmpData::update

proc ::poBmpData::view {} {
return {
#define view_width 16
#define view_height 16
static char view_bits[] = {
  0x00, 0x00,
  0x00, 0x20,
  0xfc, 0x11,
  0x04, 0x0a,
  0x04, 0x04,
  0x04, 0x0a,
  0x04, 0x11,
  0xe4, 0x10,
  0x24, 0x11,
  0x24, 0x12,
  0x24, 0x12,
  0x24, 0x12,
  0xe4, 0x13,
  0x04, 0x10,
  0xfc, 0x1f,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::view

proc ::poBmpData::wheel {} {
return {
#define wheel_width 16
#define wheel_height 16
static char wheel_bits[] = {
  0xc0, 0x07,
  0x30, 0x19,
  0x08, 0x21,
  0x14, 0x51,
  0x24, 0x49,
  0x42, 0x85,
  0x82, 0x83,
  0xfe, 0xff,
  0x82, 0x83,
  0x42, 0x85,
  0x24, 0x49,
  0x14, 0x51,
  0x08, 0x21,
  0x30, 0x19,
  0xc0, 0x07,
  0x00, 0x00};
}
} ; # End of proc ::poBmpData::wheel

proc ::poBmpData::white {} {
return {
#define white_width 16
#define white_height 16
static unsigned char white_bits[] = {
   0xff, 0xff, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80,
   0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80,
   0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0xff, 0xff};
}
} ; # End of proc ::poBmpData::white


catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poCalendar.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poCalendar
#       Copyright:      Paul Obermeier 2001-2003 / paul@poSoft.de
#       Filename:       poCalendar.tcl
#
#       First Version:  2001 / 08 / 04
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#
############################################################################ 

if { [file tail [info script]] != [file tail $::argv0] } {
    package provide poTklib 1.0
    package provide poCalendar 1.0
} else {
    package require Tk
}

namespace eval ::poCalendar {
    variable a

    set now [clock scan now]
    set a(year) [clock format $now -format "%Y"]
    scan [clock format $now -format "%m"] %d a(month)
    scan [clock format $now -format "%d"] %d a(day)

    proc chooser {w args} {
        variable a

        array set a {
            -font {Helvetica 9} -titlefont {Helvetica 12} -bg white
            -highlight orange -mon 1
        }
        # The -mon switch gives the position of Monday (1 or 0)
        array set a $args
        set a(canvas) [canvas $w -bg $a(-bg) -width 200 -height 180]
        $w bind day <1> {
                set item [%W find withtag current]
                set ::poCalendar::a(day) [%W itemcget $item -text]
                ::poCalendar::display
            }
        cbutton $w 60  10 << {::poCalendar::adjust  0 -1}
        cbutton $w 80  10 <  {::poCalendar::adjust -1  0}
        cbutton $w 120 10 >  {::poCalendar::adjust  1  0}
        cbutton $w 140 10 >> {::poCalendar::adjust  0  1}
        display
        set w
    }

    proc adjust {dmonth dyear} {
        variable a

        incr a(year)  $dyear
        incr a(month) $dmonth
        if {$a(month)>12} {set a(month) 1; incr a(year)}
        if {$a(month)<1}  {set a(month) 12; incr a(year) -1}
        set maxday [numberofdays $a(month) $a(year)]
        if {$maxday < $a(day)} {set a(day) $maxday}
        display
    }

    proc display {} {
        variable a

        set c $a(canvas)
        foreach tag {title otherday day} {$c delete $tag}
        set x0 20; set x $x0; set y 50
        set dx 25; set dy 20
        set xmax [expr {$x0+$dx*6}]
        set a(date) [clock scan $a(month)/$a(day)/$a(year)]
        set title [format [monthname $a(month)] $a(year)]
        $c create text [expr ($xmax+$dx)/2] 30 -text $title -fill blue \
            -font $a(-titlefont) -tag title
        set weekdays $a(weekdays,$a(language))
        if !$a(-mon) {lcycle weekdays}
        foreach i $weekdays {
            $c create text $x $y -text $i -fill blue \
                -font $a(-font) -tag title
            incr x $dx
        }
        set first $a(month)/1/$a(year)
        set weekday [clock format [clock scan $first] -format %w]
        if !$a(-mon) {set weekday [expr {($weekday+6)%7}]}
        set x [expr {$x0+$weekday*$dx}]
        set x1 $x; set offset 0
        incr y $dy
        while {$weekday} {
            set t [clock scan "$first [incr offset] days ago"]
            scan [clock format $t -format "%d"] %d day
            $c create text [incr x1 -$dx] $y -text $day \
                -fill grey -font $a(-font) -tag otherday
            incr weekday -1
        }
        set dmax [numberofdays $a(month) $a(year)]
        for {set d 1} {$d<=$dmax} {incr d} {
            set id [$c create text $x $y -text $d -tag day -font $a(-font)]
            if {$d==$a(day)} {
                eval $c create rect [$c bbox $id] \
                    -fill $a(-highlight) -outline $a(-highlight) -tag day
            }
            $c raise $id
            if {[incr x $dx]>$xmax} {set x $x0; incr y $dy}
        }
        if {$x != $x0} {
            for {set d 1} {$x<=$xmax} {incr d; incr x $dx} {
                $c create text $x $y -text $d \
                    -fill grey -font $a(-font) -tag otherday
            }
        }
    }

    proc format {month year} {
        variable a

        if ![info exists a(format,$a(language))] {
            set format "%m %y" ;# default
        } else {set format $a(format,$a(language))}
        foreach {from to} [list %m $month %y $year] {
            regsub $from $format $to format
        }
        subst $format
    }

    proc monthname {month {language default}} {
        variable a

        if {$language=="default"} {set language $a(language)}
        if {[info exists a(mn,$language)]} {
            set res [lindex $a(mn,$language) $month]
        } else {set res $month}
    }

    array set a {
        language en
        mn,de {
        . Januar Februar März April Mai Juni Juli August
        September Oktober November Dezember
        }
        weekdays,de {So Mo Di Mi Do Fr Sa}

        mn,en {
        . January February March April May June July August
        September October November December
        }
        weekdays,en {Sun Mon Tue Wed Thu Fri Sat}

        mn,es {
        . Enero Febrero Marzo Abril Mayo Junio Julio Agosto
        Septiembre Octubre Noviembre Diciembre
        }
        weekdays,es {Do Lu Ma Mi Ju Vi Sa}

        mn,fr {
        . Janvier Février Mars Avril Mai Juin Juillet Août
        Septembre Octobre Novembre Décembre
        }
        weekdays,fr {Di Lu Ma Me Je Ve Sa}

        mn,it {
        . Gennaio Febraio Marte Aprile Maggio Giugno Luglio Agosto
        Settembre Ottobre Novembre Dicembre
        }
        weekdays,it {Do Lu Ma Me Gi Ve Sa}

        format,ja {%y\u5e74 %m\u6708}
        weekdays,ja {\u65e5 \u6708 \u706b \u6c34 \u6728 \u91d1 \u571f}

        mn,nl {
        . januari februari maart april mei juni juli augustus
        september oktober november december
        }
        weekdays,nl {Zo Ma Di Wo Do Vr Za}

        mn,ru {
        . \u42f\u43d\u432\u430\u440\u44c \u424\u435\u432\u440\u430\u43b\u44c
        \u41c\u430\u440\u442 \u410\u43f\u440\u435\u43b\u44c
        \u41c\u430\u439 \u418\u44e\u43d\u439 \u418\u44e\u43b\u439
        \u410\u432\u433\u443\u441\u442
        \u421\u435\u43d\u442\u44f\u431\u440\u44c
        \u41e\u43a\u442\u44f\u431\u440 \u41d\u43e\u44f\u431\u440
        \u414\u435\u43a\u430\u431\u440
        }
        weekdays,ru {
            \u432\u43e\u441 \u43f\u43e\u43d \u432\u442\u43e \u441\u440\u435
            \u447\u435\u442 \u43f\u44f\u442 \u441\u443\u431
        }

        mn,sv {
            . januari februari mars april maj juni juli augusti
            september oktober november december
        }
        weekdays,sv {sön mån tis ons tor fre lör}

        format,zh {%y\u5e74 %m\u6708}
        mn,zh {
            . \u4e00 \u4e8c \u4e09 \u56db \u4e94 \u516d \u4e03
              \u516b \u4e5d \u5341 \u5341\u4e00 \u5341\u4e8c
        }
        weekdays,zh {\u65e5 \u4e00 \u4e8c \u4e09 \u56db \u4e94 \u516d}
    }

    proc numberofdays {month year} {
        if {$month==12} {set month 0; incr year}
        clock format [clock scan "[incr month]/1/$year  1 day ago"] \
            -format %d
    }
} ;# end namespace ::poCalendar

proc lcycle _list {
    upvar $_list list
    set list [concat [lrange $list 1 end] [list [lindex $list 0]]]
}

proc cbutton {w x y text command} {
    set txt [$w create text $x $y -text " $text "]
    set btn [eval $w create rect [$w bbox $txt] \
        -fill grey -outline grey]
    $w raise $txt
    foreach i [list $txt $btn] {$w bind $i <1> $command}
}

if { [file tail [info script]] == [file tail $::argv0] && \
     ![info exists PO_ONE_SCRIPT] } {
    # Start as standalone program.
    ::poCalendar::chooser .poCalendar:mainWin
    entry .2 -textvar ::poCalendar::a(date)
    regsub -all weekdays, [array names ::poCalendar::a weekdays,*] "" languages
    foreach i [lsort $languages] {
        radiobutton .b$i -text $i -variable ::poCalendar::a(language) -value $i -pady 0
    }
    trace variable ::poCalendar::a(language) w {::poCalendar::display ;#}
    checkbutton .mon -variable ::poCalendar::a(-mon) -text "Sunday starts week"
    trace variable ::poCalendar::a(-mon) w {::poCalendar::display ;#}

    eval pack [winfo children .] -fill x -anchor w

    # TODO wm withdraw .
} else {
    catch {puts "Loaded Package poTklib (Module [info script])"}
}

############################################################################
# Original file: poTklib/poConsole.tcl
############################################################################

package provide poTklib 1.0
package provide poConsole 1.0

namespace eval ::poConsole {
    namespace export create
}

proc ::poConsole::addMenuCmd { menu label acc cmd } {
    $menu add command -label $label -accelerator $acc -command $cmd
}

proc ::poConsole::create {w prompt title} {
    upvar #0 $w.t v
    if {[winfo exists $w]} {destroy $w}
    if {[info exists v]} {unset v}
    toplevel $w
    wm title $w $title
    wm iconname $w $title

    set mnu $w.mb
    menu $mnu -borderwidth 2 -relief sunken
    $mnu add cascade -menu $mnu.file -label File -underline 0
    $mnu add cascade -menu $mnu.edit -label Edit -underline 0

    set fileMenu $mnu.file
    set editMenu $mnu.edit

    menu $fileMenu -tearoff 0
    ::poConsole::addMenuCmd $fileMenu "Save as ..." "" "::poConsole::SaveFile $w.t"
    ::poConsole::addMenuCmd $fileMenu "Close"       "" "destroy $w"
    ::poConsole::addMenuCmd $fileMenu "Quit"        "" "exit"

    ::poConsole::createChild $w $prompt $editMenu
    $w configure -menu $mnu
}

proc ::poConsole::createChild {w prompt editmenu} {
    upvar #0 $w.t v
    if {$editmenu!=""} {
        menu $editmenu -tearoff 0

        ::poConsole::addMenuCmd $editmenu "Cut"   "" "::poConsole::Cut $w.t"
        ::poConsole::addMenuCmd $editmenu "Copy"  "" "::poConsole::Copy $w.t"
        ::poConsole::addMenuCmd $editmenu "Paste" "" "::poConsole::Paste $w.t"
        ::poConsole::addMenuCmd $editmenu "Clear" "" "::poConsole::Clear $w.t"
        $editmenu add separator
        ::poConsole::addMenuCmd $editmenu "Source ..." "" "::poConsole::SourceFile $w.t"
        catch {$editmenu config -postcommand "::poConsole::EnableEditMenu $w"}
    }
    scrollbar $w.sb -orient vertical -command "$w.t yview"
    pack $w.sb -side right -fill y
    text $w.t -font fixed -yscrollcommand "$w.sb set"
    pack $w.t -side right -fill both -expand 1
    bindtags $w.t Console
    set v(editmenu) $editmenu
    set v(text) $w.t
    set v(history) 0
    set v(historycnt) 0
    set v(current) -1
    set v(prompt) $prompt
    set v(prior) {}
    set v(plength) [string length $v(prompt)]
    set v(x) 0
    set v(y) 0
    $w.t mark set insert end
    $w.t tag config ok -foreground blue
    $w.t tag config err -foreground red
    $w.t insert end $v(prompt)
    $w.t mark set out 1.0
    catch {rename ::puts ::poConsole::oldputs$w}
    proc ::puts args [format {
        if {![winfo exists %s]} {
            rename ::puts {}
            rename ::poConsole::oldputs%s puts
            return [uplevel #0 puts $args]
        }
        switch -glob -- "[llength $args] $args" {
            {1 *} {
                set msg [lindex $args 0]\n
                set tag ok
            }
            {2 stdout *} {
                set msg [lindex $args 1]\n
                set tag ok
            }
            {2 stderr *} {
                set msg [lindex $args 1]\n
                set tag err
            }
            {2 -nonewline *} {
                set msg [lindex $args 1]
                set tag ok
            }
            {3 -nonewline stdout *} {
                set msg [lindex $args 2]
                set tag ok
            }
            {3 -nonewline stderr *} {
                set msg [lindex $args 2]
                set tag err
            }
            default {
                uplevel #0 ::poConsole::oldputs%s $args
                return
            }
        }
        ::poConsole::Puts %s $msg $tag
    } $w $w $w $w.t]
    after idle "focus $w.t"
}

bind Console <1> {::poConsole::Button1 %W %x %y}
bind Console <B1-Motion> {::poConsole::B1Motion %W %x %y}
bind Console <B1-Leave> {::poConsole::B1Leave %W %x %y}
bind Console <B1-Enter> {::poConsole::cancelMotor %W}
bind Console <ButtonRelease-1> {::poConsole::cancelMotor %W}
bind Console <KeyPress> {::poConsole::Insert %W %A}
bind Console <Left> {::poConsole::Left %W}
bind Console <Control-b> {::poConsole::Left %W}
bind Console <Right> {::poConsole::Right %W}
bind Console <Control-f> {::poConsole::Right %W}
bind Console <BackSpace> {::poConsole::Backspace %W}
bind Console <Control-h> {::poConsole::Backspace %W}
bind Console <Delete> {::poConsole::Delete %W}
bind Console <Control-d> {::poConsole::Delete %W}
bind Console <Home> {::poConsole::Home %W}
bind Console <Control-a> {::poConsole::Home %W}
bind Console <End> {::poConsole::End %W}
bind Console <Control-e> {::poConsole::End %W}
bind Console <Return> {::poConsole::Enter %W}
bind Console <KP_Enter> {::poConsole::Enter %W}
bind Console <Up> {::poConsole::Prior %W}
bind Console <Control-p> {::poConsole::Prior %W}
bind Console <Down> {::poConsole::Next %W}
bind Console <Control-n> {::poConsole::Next %W}
bind Console <Control-k> {::poConsole::EraseEOL %W}
bind Console <<Cut>> {::poConsole::Cut %W}
bind Console <<Copy>> {::poConsole::Copy %W}
bind Console <<Paste>> {::poConsole::Paste %W}
bind Console <<Clear>> {::poConsole::Clear %W}

proc ::poConsole::Puts {w t tag} {
    set nc [string length $t]
    set endc [string index $t [expr $nc-1]]
    if {$endc=="\n"} {
        if {[$w index out]<[$w index {insert linestart}]} {
            $w insert out [string range $t 0 [expr $nc-2]] $tag
            $w mark set out {out linestart +1 lines}
        } else {
            $w insert out $t $tag
        }
    } else {
        if {[$w index out]<[$w index {insert linestart}]} {
            $w insert out $t $tag
        } else {
            $w insert out $t\n $tag
            $w mark set out {out -1 char}
        }
    }
    $w yview insert
}

proc ::poConsole::Insert {w a} {
    $w insert insert $a
    $w yview insert
}

proc ::poConsole::Left {w} {
    upvar #0 $w v
    scan [$w index insert] %d.%d row col
    if {$col>$v(plength)} {
        $w mark set insert "insert -1c"
    }
}

proc ::poConsole::Backspace {w} {
    upvar #0 $w v
    scan [$w index insert] %d.%d row col
    if {$col>$v(plength)} {
        $w delete {insert -1c}
    }
}

proc ::poConsole::EraseEOL {w} {
    upvar #0 $w v
    scan [$w index insert] %d.%d row col
    if {$col>=$v(plength)} {
        $w delete insert {insert lineend}
    }
}

proc ::poConsole::Right {w} {
    $w mark set insert "insert +1c"
}

proc ::poConsole::Delete w {
    $w delete insert
}

proc ::poConsole::Home w {
    upvar #0 $w v
    scan [$w index insert] %d.%d row col
    $w mark set insert $row.$v(plength)
}

proc ::poConsole::End w {
    $w mark set insert {insert lineend}
}

proc ::poConsole::Enter w {
    upvar #0 $w v
    scan [$w index insert] %d.%d row col
    set start $row.$v(plength)
    set line [$w get $start "$start lineend"]
    if {$v(historycnt)>0} {
        set last [lindex $v(history) [expr $v(historycnt)-1]]
        if {[string compare $last $line]} {
            lappend v(history) $line
            incr v(historycnt)
        }
    } else {
        set v(history) [list $line]
        set v(historycnt) 1
    }
    set v(current) $v(historycnt)
    $w insert end \n
    $w mark set out end
    if {$v(prior)==""} {
        set cmd $line
    } else {
        set cmd $v(prior)\n$line
    }
    if {[info complete $cmd]} {
        set rc [catch {uplevel #0 $cmd} res]
        if {![winfo exists $w]} return
        if {$rc} {
            $w insert end $res\n err
        } elseif {[string length $res]>0} {
            $w insert end $res\n ok
        }
        set v(prior) {}
        $w insert end $v(prompt)
    } else {
        set v(prior) $cmd
        regsub -all {[^ ]} $v(prompt) . x
        $w insert end $x
    }
    $w mark set insert end
    $w mark set out {insert linestart}
    $w yview insert
}

proc ::poConsole::Prior w {
    upvar #0 $w v
    if {$v(current)<=0} return
    incr v(current) -1
    set line [lindex $v(history) $v(current)]
    ::poConsole::SetLine $w $line
}

proc ::poConsole::Next w {
    upvar #0 $w v
    if {$v(current)>=$v(historycnt)} return
    incr v(current) 1
    set line [lindex $v(history) $v(current)]
    ::poConsole::SetLine $w $line
}

proc ::poConsole::SetLine {w line} {
    upvar #0 $w v
    scan [$w index insert] %d.%d row col
    set start $row.$v(plength)
    $w delete $start end
    $w insert end $line
    $w mark set insert end
    $w yview insert
}

proc ::poConsole::Button1 {w x y} {
    global tkPriv
    upvar #0 $w v
    set v(mouseMoved) 0
    set v(pressX) $x
    set p [::poConsole::nearestBoundry $w $x $y]
    scan [$w index insert] %d.%d ix iy
    scan $p %d.%d px py
    if {$px==$ix} {
        $w mark set insert $p
    }
    $w mark set anchor $p
    focus $w
}

proc ::poConsole::nearestBoundry {w x y} {
    set p [$w index @$x,$y]
    set bb [$w bbox $p]
    if {![string compare $bb ""]} {return $p}
    if {($x-[lindex $bb 0])<([lindex $bb 2]/2)} {return $p}
    $w index "$p + 1 char"
}

proc ::poConsole::SelectTo {w x y} {
    upvar #0 $w v
    set cur [::poConsole::nearestBoundry $w $x $y]
    if {[catch {$w index anchor}]} {
        $w mark set anchor $cur
    }
    set anchor [$w index anchor]
    if {[$w compare $cur != $anchor] || (abs($v(pressX) - $x) >= 3)} {
        if {$v(mouseMoved)==0} {
            $w tag remove sel 0.0 end
        }
        set v(mouseMoved) 1
    }
    if {[$w compare $cur < anchor]} {
        set first $cur
        set last anchor
    } else {
        set first anchor
        set last $cur
    }
    if {$v(mouseMoved)} {
        $w tag remove sel 0.0 $first
        $w tag add sel $first $last
        $w tag remove sel $last end
        update idletasks
    }
}

proc ::poConsole::B1Motion {w x y} {
    upvar #0 $w v
    set v(y) $y
    set v(x) $x
    ::poConsole::SelectTo $w $x $y
}

proc ::poConsole::B1Leave {w x y} {
    upvar #0 $w v
    set v(y) $y
    set v(x) $x
    ::poConsole::motor $w
}

proc ::poConsole::motor w {
    upvar #0 $w v
    if {![winfo exists $w]} return
    if {$v(y)>=[winfo height $w]} {
        $w yview scroll 1 units
    } elseif {$v(y)<0} {
        $w yview scroll -1 units
    } else {
        return
    }
    ::poConsole::SelectTo $w $v(x) $v(y)
    set v(timer) [after 50 ::poConsole::motor $w]
}

proc ::poConsole::cancelMotor w {
    upvar #0 $w v
    catch {after cancel $v(timer)}
    catch {unset v(timer)}
}

proc ::poConsole::Copy w {
    if {![catch {set text [$w get sel.first sel.last]}]} {
        clipboard clear -displayof $w
        clipboard append -displayof $w $text
    }
}

proc ::poConsole::canCut w {
    set r [catch {
        scan [$w index sel.first] %d.%d s1x s1y
        scan [$w index sel.last] %d.%d s2x s2y
        scan [$w index insert] %d.%d ix iy
    }]
    if {$r==1} {return 0}
    if {$s1x==$ix && $s2x==$ix} {return 1}
    return 2
}

proc ::poConsole::Cut w {
    if {[::poConsole::canCut $w]==1} {
        ::poConsole::Copy $w
        $w delete sel.first sel.last
    }
}

proc ::poConsole::Paste w {
    if {[::poConsole::canCut $w]==1} {
        $w delete sel.first sel.last
    }
    if {[catch {selection get -displayof $w -selection CLIPBOARD} topaste]} {
        return
    }
    set prior 0
    foreach line [split $topaste \n] {
        if {$prior} {
            ::poConsole::Enter $w
            update
        }
        set prior 1
        $w insert insert $line
    }
}

proc ::poConsole::EnableEditMenu w {
    upvar #0 $w.t v
    set m $v(editmenu)
    if {$m=="" || ![winfo exists $m]} return
    switch [::poConsole::canCut $w.t] {
        0 {
            $m entryconf Copy -state disabled
            $m entryconf Cut -state disabled
        }
        1 {
            $m entryconf Copy -state normal
            $m entryconf Cut -state normal
        }
        2 {
            $m entryconf Copy -state normal
            $m entryconf Cut -state disabled
        }
    }
}

proc ::poConsole::SourceFile w {
    set types {
        {{TCL Scripts}  {.tcl}}
        {{All Files}    *}
    }
    set f [tk_getOpenFile -filetypes $types -title "TCL Script To Source..."]
    if {$f!=""} {
        uplevel #0 source $f
    }
}

proc ::poConsole::SaveFile w {
    set types {
        {{Text Files}  {.txt}}
        {{All Files}    *}
    }
    set f [tk_getSaveFile -filetypes $types -title "Write Screen To..."]
    if {$f!=""} {
        if {[catch {open $f w} fd]} {
            tk_messageBox -type ok -icon error -message $fd
        } else {
            puts $fd [string trimright [$w get 1.0 end] \n]
            close $fd
        }
    }
}

proc ::poConsole::Clear w {
    $w delete 1.0 {insert linestart}
}

catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poExtProg.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poExtProg
#       Copyright:      Paul Obermeier 2001-2003 / paul@poSoft.de
#       Filename:       poExtProg.tcl
#
#       First Version:  2001 / 07 / 06
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#                       ::poExtProg::ShowConsole
#                       ::poExtProg::Test
#
############################################################################

package provide poTklib   1.0
package provide poExtProg 1.0

namespace eval ::poExtProg {
    namespace export StartAssoProg
    namespace export StartEditProg
    namespace export StartOneEditProg
    namespace export StartDiffProg

    namespace export StartFileBrowser

    namespace export ShowSimpleTextEdit
    namespace export ShowSimpleHexEdit
    namespace export ShowSimpleTextDiff

    namespace export Test

    variable maxShowWin
    variable simpleDiffCount
    variable simpleEditCount
    variable simpleHexEditCount
    variable stopScan
}

proc ::poExtProg::AddMenuCmd { menu label acc cmd args } {
    eval {$menu add command -label $label -accelerator $acc -command $cmd} $args
}

# Init is called at package load time.
proc ::poExtProg::Init {} {
    variable maxShowWin
    variable simpleDiffCount
    variable simpleEditCount
    variable simpleHexEditCount

    set maxShowWin 4
    set simpleDiffCount 0
    set simpleEditCount 0
    set simpleHexEditCount 0
}

proc ::poExtProg::StopScan {} {
    variable stopScan
    set stopScan 1
}

proc ::poExtProg::LoadFileIntoTextWidget { w fileName } {
    set retVal [catch {open $fileName r} fp]
    if { $retVal != 0 } {
        error "Could not open file $fileName for reading."
    }
    $w delete 1.0 end
    while { ![eof $fp] } {
    	$w insert end [read $fp 2048]
    }
    close $fp
}

proc ::poExtProg::DumpFileIntoTextWidget { w fileName { updFlag false } } {
    variable stopScan

    # Open the file, and set up to process it in binary mode.
    set catchVal [catch { open $fileName r } fp]
    if { $catchVal } {
	error "Could not open file \"$fileName\" for reading."
    }
    fconfigure $fp -translation binary -encoding binary \
                   -buffering full -buffersize 16384

    if { $updFlag } {
	set stopScan 0
	bind $w <Escape> "::poExtProg::StopScan"
    }
    while { 1 } {
	# Record the seek address.  Read 16 bytes from the file.
        set addr [tell $fp]
        set s [read $fp 16]

        # Convert the data to hex and to characters.
        binary scan $s H*@0a* hex ascii

        # Replace non-printing characters in the data.
        regsub -all {[^[:graph:] ]} $ascii {.} ascii

        # Split the 16 bytes into two 8-byte chunks
        set hex1 [string range $hex 0 15]
        set hex2 [string range $hex 16 31]

        # Convert the hex to pairs of hex digits
        regsub -all {..} $hex1 {& } hex1
        regsub -all {..} $hex2 {& } hex2

        # Put the hex and Latin-1 data to the channel
	set hexStr [format "%08x  %-24s %-24s %-16s\n" \
			    $addr $hex1 $hex2 $ascii]
	$w insert end $hexStr

        # Stop if we've reached end of file
        if { [string length $s] == 0 } {
	    break
        }
	if { $updFlag } {
	    if { $addr % 1000 == 0 } {
		update
	    }
	    if { $stopScan } {
		break
	    }
	}
    }

    close $fp
    return
}

proc ::poExtProg::ShowSimpleTextDiff { fileName1 fileName2 } {
    variable simpleDiffCount

    incr simpleDiffCount

    set titleStr \
    	"SimpleDiff: [file tail $fileName1] versus [file tail $fileName2]"
    set tw ".poExtProg:SimpleDiff_$simpleDiffCount"

    toplevel $tw
    wm title $tw $titleStr
    frame $tw.workfr -relief sunken -borderwidth 1
    pack  $tw.workfr -side top -fill both -expand 1

    set hMenu $tw.menufr
    menu $hMenu -borderwidth 2 -relief sunken

    $hMenu add cascade -menu $hMenu.file -label "File" -underline 0

    set fileMenu $hMenu.file
    menu $fileMenu -tearoff 0
    AddMenuCmd $fileMenu Close "Ctrl+W" "destroy $tw"

    bind $tw <Control-w> "destroy $tw"
    bind $tw <Escape>    "destroy $tw"
    wm protocol $tw WM_DELETE_WINDOW "destroy $tw"
    
    $tw configure -menu $hMenu

    set textList [::poWin::CreateSyncText $tw.workfr \
    		  "$fileName1" "$fileName2" -wrap none]

    set textId1 [lindex $textList 0]
    set textId2 [lindex $textList 1]

    ::poExtProg::LoadFileIntoTextWidget $textId1 $fileName1
    ::poExtProg::LoadFileIntoTextWidget $textId2 $fileName2

    $textId1 configure -state disabled -cursor top_left_arrow
    $textId2 configure -state disabled -cursor top_left_arrow
    focus $tw
}

proc ::poExtProg::ShowSimpleTextEdit { fileName } {
    variable simpleEditCount

    incr simpleEditCount

    set titleStr "SimpleEdit: [file tail $fileName]"
    set tw ".poExtProg:SimpleEdit_$simpleEditCount"

    toplevel $tw
    wm title $tw $titleStr
    frame $tw.workfr -relief sunken -borderwidth 1
    pack  $tw.workfr -side top -fill both -expand 1

    set hMenu $tw.menufr
    menu $hMenu -borderwidth 2 -relief sunken
    $hMenu add cascade -menu $hMenu.file -label File -underline 0

    set fileMenu $hMenu.file
    menu $fileMenu -tearoff 0
    AddMenuCmd $fileMenu Close "Ctrl+W" "destroy $tw"

    bind $tw <Control-w> "destroy $tw"
    bind $tw <Escape>    "destroy $tw"
    wm protocol $tw WM_DELETE_WINDOW "destroy $tw"

    $tw configure -menu $hMenu 

    set textId [::poWin::CreateScrolledText $tw.workfr "$fileName"]

    ::poExtProg::LoadFileIntoTextWidget $textId $fileName
    $textId configure -state disabled -cursor top_left_arrow
    focus $tw
}

proc ::poExtProg::SaveHexEdit { w fileName } {
    set fileTypes {
	    {"Ascii Dump files" ".dump"}
	    {"All files"        "*"} }

    set dumpDir  [file dirname $fileName]
    set dumpFile [format "%s.dump" [file tail $fileName]]
    set saveName [tk_getSaveFile -filetypes $fileTypes \
			  -initialfile $dumpFile -initialdir $dumpDir \
			  -title "Save hexdump to Asciii file"]
    if { $saveName != "" } {
	set retVal [catch {open $saveName w} fp]
	if { $retVal != 0 } {
	    error "Could not open file $saveName for writing."
	}
	puts $fp [$w get 1.0 end]
	close $fp
    }
}

proc ::poExtProg::CloseHexEdit { w } {
    variable stopScan

    set stopScan 1
    update
    destroy $w
}

proc ::poExtProg::ShowSimpleHexEdit { fileName } {
    variable simpleHexEditCount

    incr simpleHexEditCount

    set titleStr "SimpleHexEdit: [file tail $fileName]"
    set tw ".poExtProg:SimpleHexEdit_$simpleHexEditCount"

    toplevel $tw
    wm title $tw $titleStr
    frame $tw.workfr -relief sunken -borderwidth 1
    pack  $tw.workfr -side top -fill both -expand 1

    set hMenu $tw.menufr
    menu $hMenu -borderwidth 2 -relief sunken
    $hMenu add cascade -menu $hMenu.file -label File -underline 0

    set textId [::poWin::CreateScrolledText $tw.workfr "$fileName" -wrap none]

    set fileMenu $hMenu.file
    menu $fileMenu -tearoff 0
    AddMenuCmd $fileMenu "Save as" "Ctrl+S" "::poExtProg::SaveHexEdit $textId [list $fileName]"
    AddMenuCmd $fileMenu "Close" "Ctrl+W" "::poExtProg::CloseHexEdit $tw"

    bind $tw <Control-s> "::poExtProg::SaveHexEdit $textId [list $fileName]"
    bind $tw <Control-w> "::poExtProg::CloseHexEdit $tw"
    wm protocol $tw WM_DELETE_WINDOW "::poExtProg::CloseHexEdit $tw"

    $tw configure -menu $hMenu 

    focus $textId
    $textId configure -cursor watch
    $textId configure -font [::poWin::GetFixedFont]
    update

    ::poExtProg::DumpFileIntoTextWidget $textId $fileName true
    catch {$textId configure -state disabled -cursor top_left_arrow}
}

###########################################################################
#[@e
#       Name:           ::poExtProg::StartAssoProg
#
#       Usage:          Start program associated with a file.
#
#       Synopsis:       proc ::poExtProg::StartAssoProg { 
#			      fileList infoCB serialize }
#
#       Description:   	This function is available only on operating systems,
#			which provide association rules with files.
#			Windows uses the file extension for association.
#
#			fileList: List of files to open.
#			infoCB:   Callback function with one string parameter.
#			serialize: 1: Start programs immediately.
#				   0: Ask before loading next file.
#
#       Return Value:   None.
#
#       See also:	::poExtProg::StartEditProg
#                       ::poExtProg::StartDiffProg
#
###########################################################################

proc ::poExtProg::StartAssoProg { fileList infoCB serialize } {
    ::poExtProg::StartEditProg $fileList $infoCB $serialize 1
}

proc ::poExtProg::StartEditProg { fileList infoCB serialize { assoc 0 } } {
    global env tcl_platform
    variable maxShowWin

    set count 0
    foreach fileName $fileList {
	# Convert native name back to Unix notation
	set name [file join $fileName ""]

        set prog [::poFiletype::GetEditProg $name]
	if { $prog eq "" && !$assoc } {
	    ::poExtProg::ShowSimpleTextEdit $name
	    $infoCB "No editor rule found for: $name"
	    continue
	}

	set fork "&"
	if { $serialize } {
	    set fork ""
	}
	incr count
	if { $serialize || $count > $maxShowWin } {
            set retVal [tk_messageBox \
              -title "Confirmation" \
              -message "Load next file $name ?" \
              -type yesnocancel -default yes -icon question]
            if { $retVal eq "cancel" } {
                return
            } elseif { $retVal eq "no" } {
	        continue
	    }
        }
	if { $assoc && $tcl_platform(platform) eq "windows" } {
	    set winFileName $name
	    set winFileName [file nativename $name]
            $infoCB "Loading file $name with associated program"
	    if {[file exists $env(COMSPEC)]} {
		eval exec [list $env(COMSPEC)] /c start \
		          [list $winFileName] $fork
	    } else {
		eval exec command /c start [list $winFileName] $fork
	    }
	} else {
            $infoCB "Loading file $name with program $prog"
            eval exec $prog [list $name] $fork
        }
    }
}

proc ::poExtProg::StartOneEditProg { fileList infoCB { assoc 0 } } {
    global env tcl_platform

    set firstFile [lindex $fileList 0]
    set prog [::poFiletype::GetEditProg $firstFile]
    if { $prog eq "" && !$assoc } {
        ::poExtProg::ShowSimpleTextEdit $fileList
        $infoCB "No editor rule found for: $firstFile"
        return
    } else {
	if { $assoc && $tcl_platform(platform) eq "windows" } {
            $infoCB "Loading files with associated program"
	    if {[file exists $env(COMSPEC)]} {
		eval exec [list $env(COMSPEC)] /c start $fileList &
	    } else {
		eval exec command /c start $fileList &
	    }
	} else {
            $infoCB "Loading files with program $prog"
            eval exec $prog $fileList &
        }
    }
}

proc ::poExtProg::StartHexEditProg { fileList {infoCB ""} {serialize 1} } {
    global env tcl_platform
    variable maxShowWin

    set count 0
    foreach fileName $fileList {
	# Convert native name back to Unix notation
	set name [file join $fileName ""]

        set prog [::poFiletype::GetHexEditProg $name]
	if { $prog eq "" } {
	    ::poExtProg::ShowSimpleHexEdit $name
	    if { $infoCB ne "" } {
		$infoCB "No hexdump rule found for: $name"
	    }
	    continue
	}

	set fork "&"
	if { $serialize } {
	    set fork ""
	}
	incr count
	if { $serialize || $count > $maxShowWin } {
            set retVal [tk_messageBox \
              -title "Confirmation" \
              -message "Load next file $name ?" \
              -type yesnocancel -default yes -icon question]
            if { $retVal eq "cancel" } {
                return
            } elseif { $retVal eq "no" } {
	        continue
	    }
        }
	if { $infoCB ne "" } {
	    $infoCB "Loading file $name with program $prog"
	}
	eval exec $prog [list $name] $fork
    }
}

proc ::poExtProg::StartDiffProg { leftFileList rightFileList \
                                  infoCB { serialize 0 } } {
    variable maxShowWin

    set count 0
    foreach fileName1 $leftFileList fileName2 $rightFileList {
	# Convert native name back to Unix notation
	set name1 [file join $fileName1 ""]
	set name2 [file join $fileName2 ""]

	set prog [::poFiletype::GetDiffProg $name1]
	if { $prog eq "" } {
	    $infoCB "No diff rule found for: $name1"
	    ::poExtProg::ShowSimpleTextDiff $name1 $name2
	    continue
	}

	set fork "&"
	if { $serialize } {
	    set fork ""
	}

	incr count
	if { $serialize || $count > $maxShowWin } {
            set retVal [tk_messageBox \
              -title "Confirmation" \
              -message "Load next diff: $name1 vs. $name2 ?" \
              -type yesnocancel -default yes -icon question]
            if { $retVal eq "cancel" } {
                return
            } elseif { $retVal eq "no" } {
	        continue
	    }
        }
        $infoCB "Diff'ing $name1 and $name2 with program $prog"
        eval exec $prog [list $name1] [list $name2] $fork
    }
}

proc ::poExtProg::StartFileBrowser { dir } {
    if { $::tcl_platform(platform) eq "windows" } {
        set browserProg "explorer"
    } elseif { $::tcl_platform(os) eq "Linux" } {
        set browserProg "konqueror"
    } elseif { $::tcl_platform(os) eq "Darwin" } {
        set browserProg "open"
    } elseif { $::tcl_platform(os) eq "SunOS" } {
        set browserProg "filemgr -d"
    } elseif { [string match "IRIX*" $::tcl_platform(os)] } {
        set browserProg "fm"
    } else {
        set browserProg "xterm -e ls"
    }
    if { [file isdirectory $dir] } {
        eval exec $browserProg [list [file nativename $dir]] &
    }
}

# Utility function for Test.

proc ::poExtProg::P { str verbose } {
    if { $verbose } {
	puts $str
    }
}

###########################################################################
#[@e
#       Name:           ::poExtProg::Test
#
#       Usage:          Test the debug package.
#
#       Synopsis:       proc ::poExtProg::Test { { verbose true } }
#
#       Description:    verbose: boolean (Default: true)
#
#			Simple test to check the correctness of this package.
#			if "verbose" is true, messages are printed out,
#			otherwise test runs silently.
#
#       Return Value:   true / false.
#
#       See also:	::poExtProg::GetDebugLevels
#
###########################################################################

proc ::poExtProg::Test { { verbose true } } {

    set retVal 1

    P "" $verbose
    P "Start of test" $verbose

    P "Not yet implemented" $verbose

    P "Test finished" $verbose
    return $retVal
}

::poExtProg::Init
catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poFiletype.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poFiletype
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poFiletype.tcl
#
#       First Version:  2000 / 05 / 01
#       Author:         Paul Obermeier
#
#       Description:	
#			OPa Todo
#
#       Additional documentation:
#
#			None.
#
#       Exported functions:
#    			::poFiletype::OpenWin
#    			::poFiletype::GetDiffProg
#    			::poFiletype::GetEditProg
#    			::poFiletype::GetHexEditProg
#    			::poFiletype::GetColor
#    			::poFiletype::LoadFromFile
#    			::poFiletype::SaveToFile
#    			::poFiletype::Test
#
############################################################################

package provide poTklib 1.0
package provide poFiletype 1.0

namespace eval ::poFiletype {
    namespace export OpenWin
    namespace export GetDiffProg
    namespace export GetEditProg
    namespace export GetHexEditProg
    namespace export GetColor
    namespace export LoadFromFile
    namespace export SaveToFile

    namespace export Test

    variable winName
    variable sett
    variable curType
    variable langStr
    variable curLang
    variable reservedTypes
}

proc ::poFiletype::Init {} {
    variable winName
    variable sett
    variable langStr
    variable curLang
    variable reservedTypes

    set winName ".poFiletype:SettWin"

    set sett(x) 100
    set sett(y) 100
    set sett(changed) false

    set reservedTypes 2
    set sett(typeList) [list "Makefiles" "Image type" "Default type"]
    # Make files. Example setting.
    set curType [lindex $sett(typeList) 0]
    set sett($curType,guiDiff) "tkdiff"
    set sett($curType,editor)  "gvim"
    set sett($curType,hexedit) ""
    set sett($curType,color)   "green"
    set sett($curType,match)   [list "*akefile*" "*.mk"]
    # Image files. Not removable.
    set curType [lindex $sett(typeList) 1]
    set sett($curType,guiDiff) "poImgdiff"
    set sett($curType,editor)  "poImgview"
    set sett($curType,hexedit) ""
    set sett($curType,color)   "purple"
    set sett($curType,match)   [list "*.gif" "*.ppm"]
    # Default file type. Not removable.
    set curType [lindex $sett(typeList) 2]
    set sett($curType,guiDiff) "tkdiff"
    set sett($curType,editor)  "gvim"
    set sett($curType,hexedit) ""
    set sett($curType,color)   "black"
    set sett($curType,match)   [list "*" ".??*"]

    set curLang 0
    array set langStr [list \
	NewType     { "Create a new file type (Ctrl+N)" \
                      "Generiere neuen Dateityp (Ctrl+N)" } \
	DelType     { "Delete current file type from list (Del)" \
		      "Aktuellen Dateityp löschen (Del)" } \
	RenameType  { "Rename current file type (Ctrl+R)" \
		      "Aktuellen Dateityp umbenennen (Ctrl+R)" } \
	UpdImgType  { "Update image matching from poImgtype.cfg" \
		      "Regeln für Bilddateien von poImgtype.cfg übernehmen" } \
	FileType    { "File type:" \
		      "Dateityp:" } \
	GuiDiff     { "GUI Diff:" \
		      "GUI Diff:" } \
	Editor      { "Editor:" \
		      "Editor:" } \
	HexEdit     { "Hex Editor:" \
		      "Hex Editor:" } \
	Color       { "Color:" \
		      "Farbe:" } \
	TestField   { "Test field" \
		      "Test Feld" } \
	FileMatch   { "File match:" \
		      "Datei Regeln:" } \
	NewTypeName { "New type" \
		      "Neuer Typ" } \
	SelHexEdit  { "Select Hex Editor" \
		      "Hex Editor auswählen" } \
	SelEditor   { "Select editor" \
		      "Editor auswählen" } \
	SelGuiDiff  { "Select graphical diff program" \
		      "Graphisches Diff-Programm auswählen" } \
	MsgSelType  { "Please select a file type first." \
		      "Bitte erst Dateityp auswählen" } \
	MsgNoRename { "You cannot rename \"Default type\" and \"Image type\"." \
		      "Dateityp \"Default type\" und \"Image type\" kann nicht umbenannt werden." } \
	EnterType   { "Enter file type name" \
		      "Dateityp-Namen eingeben" } \
	TypeExists  { "Filetype %s already exists." \
		      "Dateityp %s existiert bereits." } \
	MsgDelType  { "Delete file type \"%s\"?" \
		      "Dateityp \"%s\" löschen?" } \
	Confirm     { "Confirmation" \
		      "Bestätigung" } \
	WinTitle    { "File type settings" \
		      "Dateityp Einstellungen" } \
    ]
}

proc ::poFiletype::Str { key args } {
    variable langStr
    variable curLang

    set str [lindex $langStr($key) $curLang]
    return [eval {format $str} $args]
}

proc ::poFiletype::UpdateCombo { cb typeList showInd } {
    $cb list delete 0 end
    foreach type $typeList {
        $cb list insert end $type
    }
    $cb configure -value [lindex $typeList $showInd]
    $cb select $showInd
}

proc ::poFiletype::SettChanged {} {
    variable sett

    set sett(changed) true
}

proc ::poFiletype::CloseWin { w } {
    destroy $w
}

proc ::poFiletype::CancelWin { w args } {
    variable sett

    ::poToolhelp::HideToolhelp
    foreach pair $args {
        set var [lindex $pair 0]
        set val [lindex $pair 1]
        set cmd [format "set %s %s" $var $val]
        eval $cmd
    }
    ::poFiletype::CloseWin $w
}

proc ::poFiletype::SaveFileMatch { textWidget } {
    variable sett
    variable curType

    set fileType $curType
    set widgetCont [$textWidget get 1.0 end]
    regsub -all {\n} $widgetCont " " matchStr
    set sett($fileType,match) $matchStr
}

proc ::poFiletype::AskColor { w } {
    variable sett
    variable curType

    set newColor [tk_chooseColor -initialcolor $sett($curType,color)]
    if { [string compare $newColor ""] != 0 } {
        set sett($curType,color) $newColor
	# Settings window may have already been closed. So catch it.
	catch { $w configure -fg $newColor }
	::poFiletype::SettChanged
    }
}

proc ::poFiletype::GetEditor { w } {
    variable sett
    variable curType

    set tmp [::poMisc::GetExecutable [Str SelEditor]]
    if { [string compare $tmp ""] != 0 } {
        set sett($curType,editor) $tmp
	# Settings window may have already been closed.
	if { ![winfo exists $w] } {
	    return
	}
        if { [string length $tmp] > [$w cget -width] } {
	    $w xview moveto 1
	}
    }
}

proc ::poFiletype::GetHexEditor { w } {
    variable sett
    variable curType

    set tmp [::poMisc::GetExecutable [Str SelHexEdit]]
    if { [string compare $tmp ""] != 0 } {
        set sett($curType,hexedit) $tmp
	# Settings window may have already been closed.
	if { ![winfo exists $w] } {
	    return
	}
        if { [string length $tmp] > [$w cget -width] } {
	    $w xview moveto 1
	}
    }
}

proc ::poFiletype::GetGuiDiff { w } {
    variable sett
    variable curType

    set tmp [::poMisc::GetExecutable [Str SelGuiDiff]]
    if { [string compare $tmp ""] != 0 } {
        set sett($curType,guiDiff) $tmp
	# Settings window may have already been closed.
	if { ![winfo exists $w] } {
	    return
	}
        if { [string length $tmp] > [$w cget -width] } {
	    $w xview moveto 1
	}
    }
}

proc ::poFiletype::ComboCB { guiDiffEntry editorEntry hexEditEntry colorList matchText args } {
    variable sett
    variable curType

    # Restore the file match entries of the previous type.
    SaveFileMatch $matchText

    set curType [lindex $args 1]
    if { [string equal $curType "Image type"] } {
        $sett(updImgButton) configure -state normal
    } else {
        $sett(updImgButton) configure -state disabled
    }
    $guiDiffEntry configure -textvariable ::poFiletype::sett($curType,guiDiff)
    $editorEntry  configure -textvariable ::poFiletype::sett($curType,editor)
    $hexEditEntry configure -textvariable ::poFiletype::sett($curType,hexedit)
    $colorList    configure -fg $::poFiletype::sett($curType,color)
    $guiDiffEntry xview moveto 1
    $editorEntry  xview moveto 1
    $hexEditEntry xview moveto 1
    $matchText delete 1.0 end
    foreach match $::poFiletype::sett($curType,match) {
        $matchText insert end "$match\n"
    }
}

proc ::poFiletype::AskRename {} {
    variable sett
    variable curType
    variable reservedTypes

    set curInd [$sett(combo) curselection]
    if { [string compare $curInd ""] == 0 } {
	tk_messageBox -message [Str MsgSelType] -icon info -type ok
	return
    }

    if { $curInd >= [llength $sett(typeList)] - $reservedTypes } {
	tk_messageBox -message [Str MsgNoRename] \
		      -icon info -type ok
	return
    }

    ::poWin::ShowEntryBox ::poFiletype::Rename $curType [Str EnterType] "" 30
}

proc ::poFiletype::Rename { val } {
    variable sett
    variable curType
    variable reservedTypes

    if { [lsearch -exact $sett(typeList) $val] >= 0 } {
	tk_messageBox -message [Str TypeExists $val] \
		      -icon warning -type ok
	return
    }
    set oldTypeInd [lsearch -exact $sett(typeList) $curType]
    set tmp1List [lrange $sett(typeList) 0 end-$reservedTypes]
    set tmp2List [lsort [lreplace $tmp1List $oldTypeInd $oldTypeInd $val]]

    set reservedTypes1 [expr $reservedTypes - 1]
    set sett(typeList) [concat $tmp2List \
                        [lrange $sett(typeList) end-$reservedTypes1 end]]

    set valInd [lsearch $sett(typeList) $val]
    set sett($val,editor)  $sett($curType,editor) 
    set sett($val,guiDiff) $sett($curType,guiDiff)
    set sett($val,hexedit) $sett($curType,hexedit)
    set sett($val,color)   $sett($curType,color)
    set sett($val,match)   $sett($curType,match)
    unset sett($curType,editor)
    unset sett($curType,guiDiff)
    unset sett($curType,hexedit)
    unset sett($curType,color)
    unset sett($curType,match)
    UpdateCombo $sett(combo) $sett(typeList) $valInd
}

proc ::poFiletype::AskNew {} {
    ::poWin::ShowEntryBox ::poFiletype::New \
	[Str NewTypeName] [Str EnterType] "" 30
}

proc ::poFiletype::New { val } {
    variable sett
    variable reservedTypes

    if { [lsearch -exact $sett(typeList) $val] >= 0 } {
	tk_messageBox -message [Str TypeExists $val] \
		      -icon warning -type ok
	return
    }
    set tmp1List [lrange $sett(typeList) 0 end-$reservedTypes]
    lappend tmp1List $val

    set tmp2List [lsort $tmp1List]
    set reservedTypes1 [expr $reservedTypes - 1]
    set sett(typeList) [concat $tmp2List \
                        [lrange $sett(typeList) end-$reservedTypes1 end]]

    set valInd [lsearch $sett(typeList) $val]
    set sett($val,guiDiff) ""
    set sett($val,editor)  ""
    set sett($val,hexedit) ""
    set sett($val,color)   "black"
    set sett($val,match)   ""
    UpdateCombo $sett(combo) $sett(typeList) $valInd
}

proc ::poFiletype::AskDel {} {
    variable sett
    variable reservedTypes

    set curInd [$sett(combo) curselection]
    if { [string compare $curInd ""] == 0 } {
	tk_messageBox -message [Str MsgSelType] -icon info -type ok
	return
    }

    if { $curInd >= [llength $sett(typeList)] - $reservedTypes } {
	tk_messageBox -message [Str MsgNoRename] -icon info -type ok
	return
    }
    set type [lindex $sett(typeList) $curInd]
    set retVal [tk_messageBox -icon question -type yesno -default yes \
	    -message [Str MsgDelType $type] -title [Str Confirm]]
    if { [string compare $retVal "yes"] == 0 } {
	if { $curInd > 0 } {
	    set tmpList [lrange $sett(typeList) 0 [expr $curInd -1]]
	} else {
	    set tmpList {}
	}
	foreach elem [lrange $sett(typeList) [expr $curInd +1] end] {
	    lappend tmpList $elem
	}
	set sett(typeList) $tmpList
	unset sett($type,editor)
	unset sett($type,guiDiff)
	unset sett($type,hexedit)
	unset sett($type,color)
	unset sett($type,match)
	UpdateCombo $sett(combo) $sett(typeList) 0
    }
}

proc ::poFiletype::UpdImgType {} {
    variable sett

    ::poImgtype::LoadFromFile
    $sett(fileMatchWidget) delete 1.0 end
    foreach ext [lsort [::poImgtype::GetExtList]] {
	$sett(fileMatchWidget) insert end [format "*%s\n" $ext]
    }
}

###########################################################################
#[@e
#       Name:           ::poFiletype::OpenWin
#
#       Usage:          Open the filetype selection window.
#
#       Synopsis:       proc ::poFiletype::OpenWin { { language 0 } }
#
#       Description:	language: Integer
#
#			The filetype selection window is opened and ready for
#			user input.
#			Standard filetypes and associated actions:
#			OPa Blabla
#			Use ::poFiletype::LoadFromFile before calling this
#			function to load user specific associations.
#
#       Return Value:   None.
#
#       See also: 	::poFiletype::GetDiffProg
#    			::poFiletype::GetEditProg
#    			::poFiletype::GetHexEditProg
#    			::poFiletype::GetColor
#    			::poFiletype::LoadFromFile
#    			::poFiletype::SaveToFile
#
###########################################################################

proc ::poFiletype::OpenWin { { language 0 } } {
    variable winName
    variable sett
    variable curType
    variable curLang

    set tw $winName

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    set curLang $language

    toplevel $tw
    wm title $tw [Str WinTitle]
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $sett(x) $sett(y)]

    frame $tw.toolfr -relief raised -borderwidth 1
    frame $tw.workfr  -borderwidth 1
    pack  $tw.toolfr -side top -fill x
    pack  $tw.workfr -side top -fill both -expand 1

    # Add new toolbar group and associated buttons.
    set btnFrame [::poToolbar::AddGroup $tw.toolfr]

    ::poToolbar::AddButton $btnFrame.new [::poBmpData::newfile] \
                           ::poFiletype::AskNew \
			   [Str NewType] -activebackground white
    ::poToolbar::AddButton $btnFrame.del [::poBmpData::delete] \
                           ::poFiletype::AskDel \
                           [Str DelType] -activebackground red
    ::poToolbar::AddButton $btnFrame.ren [::poBmpData::rename] \
			   ::poFiletype::AskRename \
			   [Str RenameType] -activebackground white
    ::poToolbar::AddButton $btnFrame.upd [::poBmpData::update] \
			   ::poFiletype::UpdImgType \
			   [Str UpdImgType] -activebackground white \
			   -state disabled
    set sett(updImgButton) $btnFrame.upd

    bind $tw <Control-n> "::poFiletype::AskNew"
    bind $tw <Delete>    "::poFiletype::AskDel"
    bind $tw <Control-r> "::poFiletype::AskRename"

    set ww $tw.workfr
    # Generate left column with text labels.
    set row 0
    foreach labelStr [list \
		       [Str FileType] \
		       [Str GuiDiff] \
		       [Str Editor] \
		       [Str HexEdit] \
		       [Str Color] \
		       [Str FileMatch] ] {
	label $ww.l$row -text $labelStr
        grid  $ww.l$row -row $row -column 0 -sticky nw -pady 2
	incr row
    }

    set varList {}
    set curInd 0
    set curType [lindex $sett(typeList) $curInd]

    # Generate right column with entries and buttons.
    # Row 0: File types
    set row 0
    frame $ww.fr$row -relief ridge -borderwidth 1
    grid $ww.fr$row -row $row -column 1 -sticky news -pady 2

    set sett(combo) $ww.fr$row.cb
    ::combobox::combobox $ww.fr$row.cb -editable 0 -relief sunken 
    UpdateCombo $sett(combo) $sett(typeList) 0
    $sett(combo) select $curInd

    bind  $ww.fr$row.cb <KeyPress-Return> "::poFiletype::SettChanged"
    pack $ww.fr$row.cb -side top -anchor w -fill x -expand 1 -in $ww.fr$row
    set tmpList [list [list sett(typeList)] [list $sett(typeList)]]
    lappend varList $tmpList

    # Row 1: External GUI diff
    incr row
    frame $ww.fr$row -relief ridge -borderwidth 1
    grid $ww.fr$row -row $row -column 1 -sticky news -pady 2

    entry  $ww.fr$row.e -textvariable ::poFiletype::sett($curType,guiDiff) \
                        -bg white
    $ww.fr$row.e xview moveto 1
    button $ww.fr$row.b -text "..." -borderwidth 0 \
                        -command "::poFiletype::GetGuiDiff $ww.fr$row.e"
    bind  $ww.fr$row.e <KeyPress-Return> "::poFiletype::SettChanged"
    pack $ww.fr$row.e $ww.fr$row.b -side left -anchor w -in $ww.fr$row
    foreach t $sett(typeList) {
	set tmpList [list [list sett($t,guiDiff)] [list $sett($t,guiDiff)]]
	lappend varList $tmpList
    }

    # Row 2: External editor
    incr row
    frame $ww.fr$row -relief ridge -borderwidth 1
    grid $ww.fr$row -row $row -column 1 -sticky news -pady 2

    entry  $ww.fr$row.e -textvariable ::poFiletype::sett($curType,editor) \
                        -bg white
    $ww.fr$row.e xview moveto 1
    button $ww.fr$row.b -text "..." -borderwidth 0 \
                        -command "::poFiletype::GetEditor $ww.fr$row.e"
    bind  $ww.fr$row.e <KeyPress-Return> "::poFiletype::SettChanged"
    pack $ww.fr$row.e $ww.fr$row.b -side left -anchor w -in $ww.fr$row
    foreach t $sett(typeList) {
	set tmpList [list [list sett($t,editor)] [list $sett($t,editor)]]
	lappend varList $tmpList
    }

    # Row 3: Hexdump editor
    incr row
    frame $ww.fr$row -relief ridge -borderwidth 1
    grid $ww.fr$row -row $row -column 1 -sticky news -pady 2

    entry  $ww.fr$row.e -textvariable ::poFiletype::sett($curType,hexedit) \
                        -bg white
    $ww.fr$row.e xview moveto 1
    button $ww.fr$row.b -text "..." -borderwidth 0 \
                        -command "::poFiletype::GetHexEditor $ww.fr$row.e"
    bind  $ww.fr$row.e <KeyPress-Return> "::poFiletype::SettChanged"
    pack $ww.fr$row.e $ww.fr$row.b -side left -anchor w -in $ww.fr$row
    foreach t $sett(typeList) {
	set tmpList [list [list sett($t,hexedit)] [list $sett($t,hexedit)]]
	lappend varList $tmpList
    }

    # Row 4: Color coding for this type
    incr row
    frame $ww.fr$row -relief ridge -borderwidth 1
    grid $ww.fr$row -row $row -column 1 -sticky news -pady 2

    listbox $ww.fr$row.l -height 1 -bg white -fg $sett($curType,color) \
			 -selectmode extended -exportselection false
    $ww.fr$row.l insert end [Str TestField]
    button $ww.fr$row.b -text "..." -borderwidth 0 \
                        -command "::poFiletype::AskColor $ww.fr$row.l"
    pack $ww.fr$row.l $ww.fr$row.b -side left -anchor w -in $ww.fr$row
    foreach t $sett(typeList) {
	set tmpList [list [list sett($t,color)] [list $sett($t,color)]]
	lappend varList $tmpList
    }

    # Row 5: File matching rules (glob style)
    incr row
    frame $ww.fr$row -relief ridge -borderwidth 1
    grid $ww.fr$row -row $row -column 1 -sticky news -pady 2
    set fileMatch [::poWin::CreateScrolledText $ww.fr$row \
		     "" -bg white -wrap none -width 20 -height 6]
    set sett(fileMatchWidget) $fileMatch

    # Fill the text widgets with the entries of the ignore lists.
    foreach match $sett($curType,match) {
	$fileMatch insert end "$match\n"
    }
    foreach t $sett(typeList) {
	set tmpList [list [list sett($t,match)] [list $sett($t,match)]]
	lappend varList $tmpList
    }
    $ww.fr0.cb configure \
         -command "::poFiletype::ComboCB $ww.fr1.e $ww.fr2.e $ww.fr3.e $ww.fr4.l $fileMatch"
    bind $fileMatch <Any-KeyRelease> "::poFiletype::SaveFileMatch $fileMatch"

    # Create Cancel and OK buttons
    incr row
    frame $ww.fr$row
    grid  $ww.fr$row -row $row -column 0 -columnspan 2 -sticky news

    bind  $tw <KeyPress-Escape> "::poFiletype::CancelWin $tw $varList"
    button $ww.fr$row.b1 -text "Cancel" \
                         -command "::poFiletype::CancelWin $tw $varList"
    button $ww.fr$row.b2 -text "OK" -default active \
	-command "::poFiletype::SaveFileMatch $fileMatch ; ::poFiletype::CloseWin $tw"
    pack $ww.fr$row.b1 $ww.fr$row.b2 -side left -fill x -padx 2 -expand 1
    focus $tw
}

proc ::poFiletype::GetProgByFile { fileName progType } {
    variable sett

    foreach type $sett(typeList) {
	foreach match $sett($type,match) {
	    if { [string match -nocase $match $fileName] } {
		return $sett($type,$progType)
	    }
	}
    }     
    return ""
}

###########################################################################
#[@e
#       Name:           ::poFiletype::GetDiffProg
#
#       Usage:          Get the associated diff program.
#
#       Synopsis:       proc ::poFiletype::GetDiffProg { fileName }
#
#       Description:	fileName: String
#
#			Return the diff program associated with "fileName".
#			Association is not limited to an extension, but can be
#			any valid glob-style expression.
#
#       Return Value:   String.
#
#       See also: 	::poFiletype::OpenWin
#    			::poFiletype::GetEditProg
#    			::poFiletype::GetHexEditProg
#    			::poFiletype::GetColor
#    			::poFiletype::LoadFromFile
#    			::poFiletype::SaveToFile
#
###########################################################################

proc ::poFiletype::GetDiffProg { fileName } {
    return [::poFiletype::GetProgByFile $fileName guiDiff]
}

###########################################################################
#[@e
#       Name:           ::poFiletype::GetEditProg
#
#       Usage:          Get the associated Editor or Viewer program.
#
#       Synopsis:       proc ::poFiletype::GetEditProg { fileName }
#
#       Description:	fileName: String
#
#			Return the edit/view program associated with "fileName".
#			Association is not limited to an extension, but can be
#			any valid glob-style expression.
#
#       Return Value:   String.
#
#       See also: 	::poFiletype::OpenWin
#    			::poFiletype::GetDiffProg
#    			::poFiletype::GetHexEditProg
#    			::poFiletype::GetColor
#    			::poFiletype::LoadFromFile
#    			::poFiletype::SaveToFile
#
###########################################################################

proc ::poFiletype::GetEditProg { fileName } {
    return [::poFiletype::GetProgByFile $fileName editor]
}

###########################################################################
#[@e
#       Name:           ::poFiletype::GetHexEditProg
#
#       Usage:          Get the associated HexDump Editor program.
#
#       Synopsis:       proc ::poFiletype::GetHexEditProg { fileName }
#
#       Description:	fileName: String
#
#			Return the hexdump program associated with "fileName".
#			Association is not limited to an extension, but can be
#			any valid glob-style expression.
#
#       Return Value:   String.
#
#       See also: 	::poFiletype::OpenWin
#    			::poFiletype::GetEditProg
#    			::poFiletype::GetDiffProg
#    			::poFiletype::GetColor
#    			::poFiletype::LoadFromFile
#    			::poFiletype::SaveToFile
#
###########################################################################

proc ::poFiletype::GetHexEditProg { fileName } {
    return [::poFiletype::GetProgByFile $fileName hexedit]
}

###########################################################################
#[@e
#       Name:           ::poFiletype::GetColor
#
#       Usage:          Get the associated color.
#
#       Synopsis:       proc ::poFiletype::GetColor { fileName }
#
#       Description:	fileName: String
#
#			Return the color associated with "fileName".
#			Association is not limited to an extension, but can be
#			any valid glob-style expression.
#
#       Return Value:   String.
#
#       See also: 	::poFiletype::OpenWin
#    			::poFiletype::GetDiffProg
#    			::poFiletype::GetEditProg
#    			::poFiletype::GetHexEditProg
#    			::poFiletype::LoadFromFile
#    			::poFiletype::SaveToFile
#
###########################################################################

proc ::poFiletype::GetColor { fileName } {
    return [::poFiletype::GetProgByFile $fileName color]
}

###########################################################################
#[@e
#       Name:           ::poFiletype::LoadFromFile
#
#       Usage:          Load stored association rules from a file.
#
#       Synopsis:       proc ::poFiletype::LoadFromFile { { fileName "" } }
#
#       Description:	fileName: String (default: "")
#
#			Load association rules from file "fileName". If 
#			"fileName" is empty, then the function tries to read
#			file "~/poFiletype.cfg".
#
#			Note: "~" (the user's home directory on Unix systems)
#			      is typically mapped to "C:\" on Win9x systems.
#
#       Return Value:   true / false.
#
#       See also: 	::poFiletype::OpenWin
#    			::poFiletype::GetDiffProg
#    			::poFiletype::GetEditProg
#    			::poFiletype::GetHexEditProg
#    			::poFiletype::SaveToFile
#
###########################################################################

proc ::poFiletype::LoadFromFile { { fileName "" } } {
    variable sett

    if { [string compare $fileName ""] == 0 } {
	set cfgFile [::poMisc::GetCfgFile poFiletype] 
    } else {
 	set cfgFile $fileName
    }
    if { [file readable $cfgFile] } {
	source $cfgFile
	return 1
    } else {
	::poLog::Warning "Could not read cfg file $cfgFile"
	return 0
    }
}

###########################################################################
#[@e
#       Name:           ::poFiletype::SaveToFile
#
#       Usage:          Store association rules to a file.
#
#       Synopsis:       proc ::poFiletype::SaveToFile { { fileName "" } }
#
#       Description:	fileName: String (default: "")
#
#			Store association rules to file "fileName". If 
#			"fileName" is empty, then the function tries to write
#			file "~/poFiletype.cfg".
#
#			Note: "~" (the user's home directory on Unix systems)
#			      is typically mapped to "C:\" on Win9x systems.
#
#       Return Value:   true / false.
#
#       See also: 	::poFiletype::OpenWin
#    			::poFiletype::GetDiffProg
#    			::poFiletype::GetEditProg
#    			::poFiletype::GetHexEditProg
#    			::poFiletype::LoadFromFile
#
###########################################################################

proc ::poFiletype::SaveToFile { { fileName "" } } {
    variable winName
    variable sett
    variable reservedTypes

    if { [string compare $fileName ""] == 0 } {
	set cfgFile [::poMisc::GetCfgFile poFiletype] 
    } else {
 	set cfgFile $fileName
    }
    set retVal [catch {open $cfgFile w} fp]
    if { $retVal != 0 } {  
	error "Cannot write to cfg file $cfgFile"
	return 0
    }

    puts $fp "# Do not change the last $reservedTypes entries in the following list."
    puts $fp "set ::poFiletype::sett(typeList)    \{$sett(typeList)\}"
    foreach type $sett(typeList) {
	set qu [::poMisc::QuoteSpaces $type]
	puts $fp "set ::poFiletype::sett($qu,guiDiff) \{$sett($type,guiDiff)\}"
	puts $fp "set ::poFiletype::sett($qu,editor)  \{$sett($type,editor)\}"
	puts $fp "set ::poFiletype::sett($qu,hexedit) \{$sett($type,hexedit)\}"
	puts $fp "set ::poFiletype::sett($qu,color)   \{$sett($type,color)\}"
	puts $fp "set ::poFiletype::sett($qu,match)   \{$sett($type,match)\}"
    }
    if { [winfo exists $winName] } {
	puts $fp "set ::poFiletype::sett(x) \{[winfo x $winName]\}"
	puts $fp "set ::poFiletype::sett(y) \{[winfo y $winName]\}"
    } else {
	puts $fp "set ::poFiletype::sett(x) \{$sett(x)\}"
	puts $fp "set ::poFiletype::sett(y) \{$sett(y)\}"
    }
    close $fp
    return 1
}

###########################################################################
#[@e
#       Name:           ::poFiletype::Test
#
#       Usage:          Test the file type package.
#
#       Synopsis:       proc ::poFiletype::Test {}
#
#       Description:
#
#       Return Value:   None.
#
#       See also: 	::poFiletype::OpenWin
#    			::poFiletype::GetDiffProg
#    			::poFiletype::GetEditProg
#    			::poFiletype::LoadFromFile
#    			::poFiletype::SaveToFile
#
###########################################################################

proc ::poFiletype::Test {} {
    button .b -text "Open Settings Window" -command ::poFiletype::OpenWin
    button .b1 -text "Save Settings" -command ::poFiletype::SaveToFile
    button .b2 -text "Load Settings" -command ::poFiletype::LoadFromFile
    pack .b .b1 .b2
}

::poFiletype::Init
catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poFontSel.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poFontSel
#       Copyright:      Paul Obermeier 2001-2003 / paul@poSoft.de
#       Filename:       poFontSel.tcl
#
#       First Version:  2001 / 11 / 12
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#
############################################################################ 

if { [file tail [info script]] != [file tail $::argv0] } {
    package provide poTklib 1.0
    package provide poFontSel
} else {
    package require combobox 
}

namespace eval ::poFontSel {
    namespace export OpenWin
    namespace export GetFont

    variable pkgInt
    variable fontSpec
}

proc ::poFontSel::GetFont {} {
    variable fontSpec

    return $fontSpec
}

proc ::poFontSel::OpenWin {} {
    variable pkgInt

    set tw .poFontSel:mainWin
    catch {destroy $tw}

    # default values
    set pkgInt(size)       12
    set pkgInt(family)     [lindex [lsort [font families]] 0]
    set pkgInt(slant)      roman
    set pkgInt(weight)     normal
    set pkgInt(overstrike) 0
    set pkgInt(underline)  0

    # the main two areas: a frame to hold the font picker widgets
    # and a label to display a sample from the font
    toplevel $tw
    wm title $tw "Font Selector"
    set fp  [frame $tw.fp]
    set msg [label $tw.msg -borderwidth 2 -relief groove -width 30 -height 4]
    set btn [frame $tw.btn]

    pack $fp  -side top -fill x
    pack $msg -side top -fill both -expand y -pady 2
    pack $btn -side top -fill x

    $msg configure -text [join [list \
	    "ABCDEFGHIJKLMNOPQRSTUVWXYZ" \
	    "abcdefghijklmnopqrstuvwxyz" \
	    "0123456789~`!@#$%^&*()_-+=" \
	    "{}[]:;\"'<>,.?/"] "\n"]

    # this will set the font of the message according to our defaults
    ::poFontSel::ChangeFont $msg

    # font family...
    label $fp.famLabel -text "Font Family:"
    ::combobox::combobox $fp.famCombo \
	    -textvariable ::poFontSel::pkgInt(family) \
	    -editable false \
	    -highlightthickness 1 \
	    -command [list ::poFontSel::ChangeFont $msg]

    pack $fp.famLabel -side left
    pack $fp.famCombo -side left -fill x -expand y

    # we'll do these one at a time so we can find the widest one and
    # set the width of the combobox accordingly (hmmm... wonder if this
    # sort of thing should be done by the combobox itself...?)
    set widest 0
    foreach family [lsort [font families]] {
	if {[set length [string length $family]] > $widest} {
	    set widest $length
	}
	$fp.famCombo list insert end $family
    }
    $fp.famCombo configure -width $widest

    # the font size. We know we are puting a fairly small, finite
    # number of items in this combobox, so we'll set its maxheight
    # to zero so it will grow to fit the number of items
    label $fp.sizeLabel -text "Font Size:"
    ::combobox::combobox $fp.sizeCombo \
	    -highlightthickness 1 \
	    -maxheight 0 \
	    -width 3 \
	    -textvariable ::poFontSel::pkgInt(size) \
	    -editable true \
	    -command [list ::poFontSel::ChangeFont $msg]

    pack $fp.sizeLabel -side left
    pack $fp.sizeCombo -side left
    eval $fp.sizeCombo list insert end [list 8 9 10 12 14 16 18 20 24 28 32 36]

    # a dummy frame to give a little spacing...
    frame $fp.dummy -width 5
    pack $fp.dummy -side left

    # bold
    set bold "bold"
    checkbutton $fp.bold -variable ::poFontSel::pkgInt(weight) \
            -indicatoron false -onvalue bold -offvalue normal \
	    -text "B" -width 2 -height 1 \
	    -font {-weight bold -family Times -size 10} \
	    -highlightthickness 1 -padx 0 -pady 0 -borderwidth 1 \
	    -command [list ::poFontSel::ChangeFont $msg]
    pack $fp.bold -side left

    # underline
    checkbutton $fp.underline -variable ::poFontSel::pkgInt(underline) \
            -indicatoron false -onvalue 1 -offvalue 0 \
	    -text "U" -width 2 -height 1 \
	    -font {-underline 1 -family Times -size 10} \
	    -highlightthickness 1 -padx 0 -pady 0 -borderwidth 1 \
	    -command [list ::poFontSel::ChangeFont $msg]
    pack $fp.underline -side left

    # italic
    checkbutton $fp.italic -variable ::poFontSel::pkgInt(slant) \
            -indicatoron false -onvalue italic -offvalue roman \
	    -text "I" -width 2 -height 1 \
	    -font {-slant italic -family Times -size 10} \
	    -highlightthickness 1 -padx 0 -pady 0 -borderwidth 1 \
	    -command [list ::poFontSel::ChangeFont $msg]
    pack $fp.italic -side left

    # overstrike
    checkbutton $fp.overstrike -variable ::poFontSel::pkgInt(overstrike) \
            -indicatoron false -onvalue 1 -offvalue 0 \
	    -text "O" -width 2 -height 1 \
	    -font {-overstrike 1 -family Times -size 10} \
	    -highlightthickness 1 -padx 0 -pady 0 -borderwidth 1 \
	    -command [list ::poFontSel::ChangeFont $msg]
    pack $fp.overstrike -side left 

    button $btn.close -text "Close" -command "destroy $tw"
    pack $btn.close -side left -expand 1 -fill x

    # put focus on the first widget
    catch {focus $fp.famCombo}
}

# this proc changes the font. It is called by various methods, so
# the only parameter we are guaranteed is the first one, since
# we supply it ourselves...
proc ::poFontSel::ChangeFont {w args} {
    variable fontSpec
    variable pkgInt

    foreach foo [list family size weight underline slant overstrike] {
	if {[set ::poFontSel::pkgInt($foo)] == ""} {
	    return
	}
    }
    set fontSpec [list \
	    -family     $pkgInt(family) \
	    -size       $pkgInt(size) \
	    -weight     $pkgInt(weight) \
	    -underline  $pkgInt(underline) \
	    -slant      $pkgInt(slant) \
	    -overstrike $pkgInt(overstrike) \
    ]
    $w configure -font $fontSpec
}

if { [file tail [info script]] == [file tail $::argv0] && \
     ![info exists PO_ONE_SCRIPT] } {
    # Start as standalone program.
    ::poFontSel::OpenWin
    wm withdraw .
} else {
    catch {puts "Loaded Package poTklib (Module [info script])"}
}

############################################################################
# Original file: poTklib/poImgBrowse.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poImgBrowse
#       Copyright:      Paul Obermeier 2000-2008 / paul@poSoft.de
#       Filename:       poImgBrowse.tcl
#
#       First Version:  2000 / 10 / 22
#       Author:         Paul Obermeier
#
#       Description:    
#                       OPa Todo
#
#       Additional documentation:
#
#                       None.
#
#       Exported functions:
#                       ::poImgBrowse::Init
#                       ::poImgBrowse::OpenDir
#                       ::poImgBrowse::OpenWin
#                       ::poImgBrowse::LoadFromFile
#                       ::poImgBrowse::SaveToFile
#                       ::poImgBrowse::Test
#
############################################################################

if { [file tail [info script]] != [file tail $::argv0] } {
    package provide poTklib 1.0
    package provide poImgBrowse 1.0
} else {
    package require poTcllib
    package require poTklib
    package require poExtlib
    package require Tktable
    package require Img
}

namespace eval ::poImgBrowse {
    namespace export OpenWin
    namespace export OpenDir
    namespace export LoadFromFile
    namespace export SaveToFile
    namespace export Init
    namespace export GetThumbFile
    namespace export CreateThumbImg

    variable pkgOpt 
    variable pkgInt 
    variable winGeom
    variable curLang
    variable langStr
    variable detailWinNo 1
    variable pkgCol
}

# Init module specific variables to default values.
proc ::poImgBrowse::Init {} {
    variable pkgCol
    variable pkgOpt
    variable pkgInt
    variable winGeom
    variable curLang
    variable langStr

    set pkgInt(settWin) .poImgBrowse:SettWin
    set pkgInt(mainWin) .poImgBrowse:MainWin

    set pkgInt(colList)  [list Ind  Img   Name  Type  Size Date       Width Height]
    set pkgInt(sortList) [list real ascii ascii ascii real dictionary real  real]

    set pkgCol(Ind)    0
    set pkgCol(Img)    1
    set pkgCol(Name)   2
    set pkgCol(Type)   3
    set pkgCol(Size)   4
    set pkgCol(Date)   5
    set pkgCol(Width)  6
    set pkgCol(Height) 7

    set pkgInt(winNo) 0
    set pkgInt(maxThumbSize) 100
    set pkgInt(selMode) "none"
    set pkgInt(allFiles) "All files"
    set pkgInt(allImgs)  "All images"
    set pkgInt(rowVis1) 1
    set pkgInt(rowVis2) 1

    set winGeom(sett,x) 100
    set winGeom(sett,y) 100
    set winGeom(main,x) 100
    set winGeom(main,y) 100
    set winGeom(main,w) 500
    set winGeom(main,h) 400

    set pkgOpt(thumbSize)      60
    set pkgOpt(saveThumb)      0
    set pkgOpt(hiddenThumbDir) 1
    set pkgOpt(showThumb)      1
    set pkgOpt(showImgInfo)    1
    set pkgOpt(showFileInfo)   1
    set pkgOpt(showFileType)   1
    set pkgOpt(slideZoom)      1 
    set pkgOpt(slideInfo)      1 

    set pkgOpt(prefixFilter)   "*"
    set pkgOpt(suffixFilter)   $pkgInt(allImgs)
    set pkgOpt(panePercent)    0.3
    set pkgOpt(lastDir)        [pwd]

    set curLang 0
    array set langStr [list \
        SaveOpts     { "Save options: " \
                       "Speicheroptionen: " } \
        ViewOpts     { "View options: " \
                       "Anzeigeoptionen: " } \
        SlideOpts    { "Slide show options: " \
                       "Vorführoptionen: " } \
        ThumbSize    { "Thumbnail size (10-100): " \
                       "Größe des Vorschaubildes (10-100): " } \
        SaveThumb    { "Generate thumbnails" \
                       "Vorschaubilder generieren" } \
        HiddenThumbDir { "Hidden thumbnail directory" \
                         "Vorschaubilder-Verzeichnis verstecken" } \
        ShowThumb    { "Show thumbnail" \
                       "Vorschaubild anzeigen" } \
        GenAllThumbs { "Generate all thumbnails" \
                       "Alle Vorschaubilder generieren" } \
        DelAllThumbs { "Delete all thumbnails" \
                       "Alle Vorschaubilder löschen" } \
        ShowImgInfo  { "Show image info" \
                       "Bildinformationen anzeigen" } \
        ShowFileInfo { "Show file info" \
                       "Dateiinformationen anzeigen" } \
        ShowFileType { "Show file type" \
                       "Dateityp anzeigen" } \
        SlideShowZoom { "Scale to fit" \
                        "Passend skalieren" } \
        SlideShowInfo { "Show image info" \
                        "Bildinformationen anzeigen" } \
        OpenFile     { "Open selected files" \
                       "Selektierte Dateien öffnen" } \
        DelFile      { "Delete selected files" \
                       "Selektierte Dateien löschen" } \
        RenameFile   { "Rename selected files" \
                       "Selektierte Dateien umbenennen" } \
        UpdateList   { "Update file list (F5)" \
                       "Dateiliste erneuern (F5)" } \
        Cancel       { "Cancel" \
                       "Abbrechen" } \
        OK           { "OK" \
                       "OK" } \
        Confirm      { "Confirmation" \
                       "Bestätigung" } \
        WinTitle     { "Image browser options" \
                       "Vorschaubild Optionen" } \
        ProgressWinTitle { "Thumbnail generation progress" \
                           "Vorschaubild-Generier Fortschritt" } \
    ]
}

proc ::poImgBrowse::Str { key args } {
    variable langStr
    variable curLang

    set str [lindex $langStr($key) $curLang]
    return [eval {format $str} $args]
}

# Functions for handling the settings window of this module.

proc ::poImgBrowse::CloseWin { w } {
    variable winGeom

    set winGeom(sett,x) [winfo x $w]
    set winGeom(sett,y) [winfo y $w]
    destroy $w
}

proc ::poImgBrowse::CancelWin { w args } {
    variable pkgOpt

    foreach pair $args {
        set var [lindex $pair 0]
        set val [lindex $pair 1]
        set cmd [format "set %s %s" $var $val]
        eval $cmd
    }
    ::poImgBrowse::CloseWin $w
}

proc ::poImgBrowse::CheckThumbSettings { entryId { updEntry 1 } } {
    variable pkgInt

    set minVal 10
    set maxVal $pkgInt(maxThumbSize)

    set tmpVal [$entryId get]
    set retVal [catch {set curVal [expr int ($tmpVal)] }]
    if { $retVal == 0 } {
        if { $curVal >= $minVal && $curVal <= $maxVal } {
            if { $updEntry } {
                $entryId configure -bg green
            }
            return 1
        }
    }
    if { $updEntry } {
        $entryId configure -bg red
    }
    return 0
}

proc ::poImgBrowse::UpdThumbSettings { tw es } {
 
    set esColor [$es cget -bg]
    if { $esColor == "red" } {
        tk_messageBox -message "Please correct the invalid red entries." \
                      -type ok -icon warning
        return
    }
    ::poImgBrowse::CloseWin $tw
    return
}

###########################################################################
#[@e
#       Name:           ::poImgBrowse::OpenWin
#
#       Usage:          Open the image browser settings window.
#
#       Synopsis:       proc ::poImgBrowse::OpenWin { { language 0 } }
#
#       Description:    language: Integer
#
#       Return Value:   None.
#
#       See also: 
#
###########################################################################

proc ::poImgBrowse::OpenWin { { language 0 } } {
    variable winGeom
    variable curLang
    variable pkgOpt
    variable pkgInt

    set tw $pkgInt(settWin)

    if { [winfo exists $tw] } {
        ::poWin::Raise $tw
        return
    }

    set curLang $language

    toplevel $tw
    wm title $tw [Str WinTitle]
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $winGeom(sett,x) $winGeom(sett,y)]

    # Generate left column with text labels.
    set row 0
    foreach labelStr [list \
                       [Str ThumbSize] \
                       [Str SaveOpts] \
                       [Str ViewOpts] \
                       [Str SlideOpts] ] {
        label $tw.l$row -text $labelStr
        grid  $tw.l$row -row $row -column 0 -sticky nw
        incr row
    }

    set varList {}

    # Generate right column with entries and buttons.
    # Row 0: Thumbnail size option
    set row 0
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky news

    entry $tw.fr$row.es -textvariable ::poImgBrowse::pkgOpt(thumbSize) \
                        -bg white -width 3
    pack $tw.fr$row.es -side top -anchor w -in $tw.fr$row
    bind $tw.fr$row.es <Any-KeyRelease> \
         "::poImgBrowse::CheckThumbSettings $tw.fr$row.es"

    set tmpList [list [list pkgOpt(thumbSize)] [list $pkgOpt(thumbSize)]]
    lappend varList $tmpList

    # Row 2: Save options
    incr row
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky news

    checkbutton $tw.fr$row.cb1 -text [Str SaveThumb] \
                -variable ::poImgBrowse::pkgOpt(saveThumb) \
                -onvalue 1 -offvalue 0
    checkbutton $tw.fr$row.cb2 -text [Str HiddenThumbDir] \
                -variable ::poImgBrowse::pkgOpt(hiddenThumbDir) \
                -onvalue 1 -offvalue 0
    pack $tw.fr$row.cb1 $tw.fr$row.cb2 -side top -anchor w -in $tw.fr$row

    set tmpList [list [list pkgOpt(saveThumb)] [list $pkgOpt(saveThumb)]]
    lappend varList $tmpList
    set tmpList [list [list pkgOpt(hiddenThumbDir)] [list $pkgOpt(hiddenThumbDir)]]
    lappend varList $tmpList

    # Row 3: View options
    incr row
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky news

    checkbutton $tw.fr$row.cb1 -text [Str ShowThumb] \
                -variable ::poImgBrowse::pkgOpt(showThumb) \
                -onvalue 1 -offvalue 0
    ::poToolhelp::AddBinding $tw.fr$row.cb1 "Column: Image"
    checkbutton $tw.fr$row.cb2 -text [Str ShowFileType] \
                -variable ::poImgBrowse::pkgOpt(showFileType) \
                -onvalue 1 -offvalue 0
    ::poToolhelp::AddBinding $tw.fr$row.cb2 "Column: Type"
    checkbutton $tw.fr$row.cb3 -text [Str ShowImgInfo] \
                -variable ::poImgBrowse::pkgOpt(showImgInfo) \
                -onvalue 1 -offvalue 0
    ::poToolhelp::AddBinding $tw.fr$row.cb3 "Columns: Width,Height"
    checkbutton $tw.fr$row.cb4 -text [Str ShowFileInfo] \
                -variable ::poImgBrowse::pkgOpt(showFileInfo) \
                -onvalue 1 -offvalue 0
    ::poToolhelp::AddBinding $tw.fr$row.cb4 "Columns: Size, Date"
    pack $tw.fr$row.cb1 $tw.fr$row.cb2 $tw.fr$row.cb3 $tw.fr$row.cb4 \
         -side top -anchor w -in $tw.fr$row

    set tmpList [list [list pkgOpt(showThumb)] [list $pkgOpt(showThumb)]]
    lappend varList $tmpList
    set tmpList [list [list pkgOpt(showFileType)] [list $pkgOpt(showFileType)]]
    lappend varList $tmpList
    set tmpList [list [list pkgOpt(showImgInfo)] [list $pkgOpt(showImgInfo)]]
    lappend varList $tmpList
    set tmpList [list [list pkgOpt(showFileInfo)] [list $pkgOpt(showFileInfo)]]
    lappend varList $tmpList

    # Row 4: Slide show options
    incr row
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky news

    checkbutton $tw.fr$row.cb1 -text [Str SlideShowZoom] \
                -variable ::poImgBrowse::pkgOpt(slideZoom) \
                -onvalue 1 -offvalue 0
    checkbutton $tw.fr$row.cb2 -text [Str SlideShowInfo] \
                -variable ::poImgBrowse::pkgOpt(slideInfo) \
                -onvalue 1 -offvalue 0

    pack $tw.fr$row.cb1 $tw.fr$row.cb2 -side top -anchor w -in $tw.fr$row

    set tmpList [list [list pkgOpt(slideZoom)] [list $pkgOpt(slideZoom)]]
    lappend varList $tmpList
    set tmpList [list [list pkgOpt(slideInfo)] [list $pkgOpt(slideInfo)]]
    lappend varList $tmpList

    # Create Cancel and OK buttons
    incr row
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 0 -columnspan 2 -sticky news 

    bind  $tw <KeyPress-Escape> "::poImgBrowse::CancelWin $tw $varList"
    bind  $tw <KeyPress-Return> \
                    "::poImgBrowse::UpdThumbSettings $tw $tw.fr0.es"
    button $tw.fr$row.b1 -text [Str Cancel] \
            -command "::poImgBrowse::CancelWin $tw $varList"
    button $tw.fr$row.b2 -text [Str OK] -default active \
            -command "::poImgBrowse::UpdThumbSettings $tw $tw.fr0.es"
    pack $tw.fr$row.b1 $tw.fr$row.b2 -side left -fill x -padx 2 -expand 1
    focus $tw
}

proc ::poImgBrowse::ReadThumbInfoFile { thumbFile printWarning } {
    set thumbInfoFile [::poImgBrowse::GetThumbInfoFile $thumbFile]
    set retVal [catch {open $thumbInfoFile r} fp]
    if { $retVal != 0 } {  
        if { $printWarning } {
            ::poLog::Warning "Can't read thumbnail info file $thumbInfoFile"
        }
        return [list -1 -1]
    }
    gets $fp line
    close $fp
    if { [scan $line "%d %d" w h] != 2 } {
        ::poLog::Warning "Thumbnail info file $thumbInfoFile contains invalid data"
        file delete $thumbInfoFile
        set w -1
        set h -1
    }
    return [list $w $h]
}

proc ::poImgBrowse::ReadThumbFile { thumbFile } {
    set retVal [catch {image create photo -file $thumbFile} photoName]
    if { $retVal != 0 } {
        ::poLog::Warning "Can't read thumbnail $thumbFile ($photoName)"
        return [list "None" -1 -1]
    } else {
        set thumbInfo [::poImgBrowse::ReadThumbInfoFile $thumbFile 1]
        set w [lindex $thumbInfo 0]
        set h [lindex $thumbInfo 1]
        return [list $photoName $w $h]
    }
}

proc ::poImgBrowse::CreateThumbImg { phImg } {
    variable pkgOpt

    set w [image width  $phImg]
    set h [image height $phImg]

    if { $w > $h } { 
        set ws [expr int ($pkgOpt(thumbSize))]
        set hs [expr int ((double($h)/double($w)) * $pkgOpt(thumbSize))]
    } else {
        set ws [expr int ((double($w)/double($h)) * $pkgOpt(thumbSize))]
        set hs [expr int ($pkgOpt(thumbSize))]
    }
    set thumbImg [image create photo -width $ws -height $hs]
    set xsub [expr ($w / $ws) + 1]
    set ysub [expr ($h / $hs) + 1]
    $thumbImg copy $phImg -subsample $xsub $ysub -to 0 0
    return $thumbImg
}

proc ::poImgBrowse::ReadImgAndGenThumb { imgName thWidth thHeight } {
    variable pkgOpt

    set ext [file extension $imgName]
    set fmtStr [::poImgtype::GetFmtByExt $ext]
    if { [string compare $fmtStr ""] == 0 } {
        ::poLog::Warning "Extension \"$ext\" not in image type list."
        set fmtCmd ""
    } else {
        set optStr [::poImgtype::GetOptByFmt $fmtStr "read"]
        set fmtCmd [format "-format \"%s %s\"" $fmtStr $optStr]
    }

    # Try to read an image from file. 
    # 1. If the shroud option is set, try using the appr. shroud program.
    # 2. If this fails (user tries to read an unshrouded file (a) or
    #    has specified the wrong shroud value (b)) try to read it with
    #    standard Tk image procs or by using the Img extension.
    # 3. If we did not succeed until now, try using the poImg extension, if it
    #    exists.
    set found  1
    set retVal 1
    set poImg ""
    set shroudVal [::poImgtype::GetShroudVal]
    if { $shroudVal } {
        # Case (1)
        ::poLog::Info "Reading shrouded image"
        set fp [open "|poShroud $shroudVal $imgName" r]
        fconfigure $fp -translation binary
        set dat [read -nonewline $fp]
        close $fp
        set phImg [image create photo]
        set retVal [catch {eval {$phImg put $dat} $fmtCmd}]
    }
    if { $retVal != 0 } {
        # Case (2)
        set retVal [catch {set phImg [eval {image create photo -file $imgName} \
                                      $fmtCmd]} err1]
    }
    if { $retVal != 0 } {
        # Case (3)
        set retVal [catch {poImageMode file_desc $imgName w h} err2]
        if { $retVal != 0 } {
            ::poLog::Warning "Can't read image $imgName ($err1 $err2)"
            return [list "None" -1 -1]
        } else {
            ::poLog::Debug "Reading $imgName with poImage"
            set xzoom [expr ($w / $thWidth)  + 1]
            set yzoom [expr ($h / $thHeight) + 1]
            set zoomFact [::poMisc::Max $xzoom $yzoom]

            set poImg [poImage allocimage [expr $w / $zoomFact] \
                                          [expr $h / $zoomFact]]
            $poImg readimage $imgName true

            set phThumb [image create photo]
            # Check stored channels in poImage.
            $poImg img_fmt fmtList
            set chanMap [list $::RED $::GREEN $::BLUE]
            if { [lindex $fmtList $::RED]   || \
                 [lindex $fmtList $::GREEN] || \
                 [lindex $fmtList $::BLUE] } {
                 if { [lindex $fmtList $::MATTE] } {
                    ::poLog::Debug "Reading $imgName as RGB image with matte"
                    set chanMap [list $::RED $::GREEN $::BLUE $::MATTE]
                } else {
                    ::poLog::Debug "Reading $imgName as RGB image"
                    set chanMap [list $::RED $::GREEN $::BLUE]
                }
            } elseif { [lindex $fmtList $::MATTE] && \
                       [lindex $fmtList $::BRIGHTNESS] } {
                ::poLog::Debug "Reading $imgName as gray-scale image with matte"
                set chanMap [list $::BRIGHTNESS $::BRIGHTNESS $::BRIGHTNESS $::MATTE]
            } elseif { [lindex $fmtList $::BRIGHTNESS] } {
                ::poLog::Debug "Reading $imgName as gray-scale image"
                set chanMap [list $::BRIGHTNESS $::BRIGHTNESS $::BRIGHTNESS]
            } elseif { [lindex $fmtList $::DEPTH] } {
                ::poLog::Debug "Reading $imgName as depth image"
                set chanMap [list $::DEPTH $::DEPTH $::DEPTH]
            } elseif { [lindex $fmtList $::MATTE] } {
                ::poLog::Debug "Reading $imgName as gray-scale image"
                set chanMap [list $::MATTE $::MATTE $::MATTE]
            }
            $poImg img_photo $phThumb $chanMap
            deleteimg $poImg
            return [list $phThumb $w $h]
        }
    } else {
        ::poLog::Debug "Reading $imgName with Img extension"
        set w [image width  $phImg]
        set h [image height $phImg]

        set xzoom [expr ($w / $thWidth)  + 1]
        set yzoom [expr ($h / $thHeight) + 1]
        set zoomFact [::poMisc::Max $xzoom $yzoom]

        if { $zoomFact > 1 } {
            set phThumb [image create photo \
                     -width  [expr $w / $zoomFact] \
                     -height [expr $h / $zoomFact]]
            $phThumb copy $phImg -subsample $zoomFact
            image delete $phImg
            return [list $phThumb $w $h]
        } else {        
            return [list $phImg $w $h]
        }
    }
}

proc ::poImgBrowse::GetFileList {dirName} {
    variable pkgInt
    variable pkgOpt

    set fmt $pkgOpt(suffixFilter)
    if { [string compare $pkgOpt(suffixFilter) $pkgInt(allFiles)] == 0 } {
        set extStr [format "%s*" $pkgOpt(prefixFilter)]
    } else {
        if { [string compare $pkgOpt(suffixFilter) $pkgInt(allImgs)]  == 0 } {
            set fmt ""
        }
        set extStr ""
        foreach ext [::poImgtype::GetExtList $fmt] {
            append extStr [format "%s*%s " $pkgOpt(prefixFilter) $ext]
        }
    }

    set imgFileList [lsort [lindex \
                            [::poMisc::GetDirList $dirName 0 1 1 1 * $extStr] 1] ]

    set curDir [pwd]
    cd "$dirName"

    if { $pkgOpt(showFileInfo) } {
        set fileInfoList {}
        foreach imgFile $imgFileList {
            if { [file exists $imgFile] } {
                set date [clock format [file mtime $imgFile] \
                          -format "%Y-%m-%d %H:%M"]
                set size [file size $imgFile]
                lappend fileInfoList [list $imgFile $size $date]
            }
        }
    }
    cd $curDir
    if { $pkgOpt(showFileInfo) } {
        return $fileInfoList
    } else {
        return $imgFileList
    }
}

proc ::poImgBrowse::GetSelRows { tbl } {
    set rcList [$tbl cursel]
    set len [llength $rcList]
    set noCols [$tbl cget -cols]
    set noRows [$tbl cget -rows]

    if { $len == 0  || $noRows == 1 } {
        return {}
    }
    set noCols1 [expr $noCols -1]
    set rowList [list [lindex [split [lindex $rcList 0] ,] 0]]
    for { set i $noCols1 } { $i < $len } { incr i $noCols1 } {
        set row [lindex [split [lindex $rcList $i] ,] 0]
        if { $row != [lindex $rowList 0] } {
            lappend rowList $row
        } else {
            break
        }
    }
    return $rowList
}

proc ::poImgBrowse::GetSelCols { tbl } {
    set rcList [$tbl cursel]
    set len [llength $rcList]

    set colList [list [lindex [split [lindex $rcList 0] ,] 1]]
    for { set i 1 } { $i < $len } { incr i } {
        set col [lindex [split [lindex $rcList $i] ,] 1]
        if { $col != [lindex $colList 0] } {
            lappend colList $col
        } else {
            break
        }
    }
    return $colList
}

proc ::poImgBrowse::GetSelFiles { tw tbl } {
    variable pkgCol

    set fileList {}
    set rowList [::poImgBrowse::GetSelRows $tbl]
    set dirName [::poImgBrowse::GetCurImgDir $tw]

    foreach row [lsort -integer $rowList] {
        set fileName [file join $dirName [$tbl get $row,$pkgCol(Name)]]
        lappend fileList $fileName
    }
    return $fileList
}

proc ::poImgBrowse::SortCol { tw tbl col sortOrder sortMode } {
    variable pkgCol
    variable pkgOpt

    set winId [::poImgBrowse::GetCurWinId $tw]
    upvar ::poImgBrowse::TblArr$winId tblArr

    set noRows [$tbl cget -rows]
    set noCols [$tbl cget -cols]
    set tmpList {}
    for { set i 1 } { $i < $noRows } { incr i } {
        lappend tmpList [$tbl get $i,1 $i,$noCols]
    }
    set sortedList [lsort -index [expr $col-1] -$sortMode \
                    -$sortOrder $tmpList]
    for { set r 1 } { $r < $noRows } { incr r } {
        set rowList [lindex $sortedList [expr {$r -1}] ]
        set photoTag [lindex $rowList 0]
        $tbl tag cell $photoTag $r,$pkgCol(Img)
        set c1 0
        for { set c 1 } { $c < $noCols } { incr c } {
            set tblArr($r,$c) [lindex $rowList $c1]
            incr c1
        }
    }
    if { $pkgOpt(showThumb) } {
        ::poImgBrowse::UpdateVisImgs $tw $tbl 1
    }
}

proc ::poImgBrowse::OpenContextMenu { tw tbl x y selFunc } {
    variable pkgInt

    set w .poImgBrowse:contextMenu
    catch { destroy $w }
    menu $w -tearoff false -disabledforeground white

    set rcList [$tbl cursel]
    set len [llength $rcList]
    set noRows [$tbl cget -rows]
    set noCols [$tbl cget -cols]

    if { $noRows == 1 } {
        set menuTitle "No files in directory"
        $w add command -label "$menuTitle" -state disabled -background "#303030"
    } elseif { $len == 0 } {
        set menuTitle "Nothing selected"
        $w add command -label "$menuTitle" -state disabled -background "#303030"
    } elseif { [ColsSelected] } {
        set colList [::poImgBrowse::GetSelCols $tbl]
        if { [llength $colList] == 1 } {
            set curCol [lindex $colList 0]
            set menuTitle "Column $curCol selected"
        } else {
            set menuTitle "[llength $colList] columns selected"
        }
        $w add command -label "$menuTitle" -state disabled -background "#303030"
        if { [llength $colList] == 1 } {
            $w add command -label "Sort increasing" \
                   -command "::poImgBrowse::SortCol $tw $tbl $curCol \
                             increasing [lindex $pkgInt(sortModeList) $curCol]"
            $w add command -label "Sort decreasing" \
                   -command "::poImgBrowse::SortCol $tw $tbl $curCol \
                             decreasing [lindex $pkgInt(sortModeList) $curCol]"
        }
        # Here evtl. HideColumn
    } elseif { [RowsSelected] } {
        set fileList [::poImgBrowse::GetSelFiles $tw $tbl]
        if { [llength $fileList] == 1 } {
            set menuTitle "[file tail [lindex $fileList 0]] selected"
            set imgStr "image"
        } else {
            set menuTitle "[llength $fileList] files selected"
            set imgStr "images"
        }
        $w add command -label "$menuTitle" -state disabled -background "#303030"
        $w add command -label "Info" \
                   -command "::poImgBrowse::ShowImgInfo $tw $tbl"
        if { [llength $fileList] == 1 } {
            $w add command -label "View fullscreen" \
                       -command "::poImgBrowse::ViewFile $tw $tbl"
        } else {
            $w add command -label "Slide show" \
                       -command "::poImgBrowse::ViewFile $tw $tbl"
        }
        $w add command -label "HexDump" \
                   -command "::poExtProg::StartHexEditProg [list $fileList]"
        $w add separator
        $w add command -label "Open" \
                   -command "::poImgBrowse::LoadImgs $selFunc $fileList"
        if { [llength $fileList] == 1 } {
            $w add separator
            $w add command -label "Rename ..." \
                           -command "::poImgBrowse::AskRenameFile $tw $tbl"
        } elseif { [llength $fileList] == 2 } {
            $w add separator
            $w add command -label "Diff ..." \
                           -command "::poImgBrowse::DiffFiles $tw $tbl"
        }
        $w add separator
        $w add command -label "Copy to ..." -underline 0 \
                   -command "::poImgBrowse::AskCopyOrMoveTo $tw $tbl copy"
        $w add command -label "Move to ..." -underline 0 \
                   -command "::poImgBrowse::AskCopyOrMoveTo $tw $tbl move"
        $w add separator
        $w add command -label "Delete ..." -activebackground "#FC3030" \
                   -command "::poImgBrowse::AskDelFile $tw $tbl"
    }
    tk_popup $w [expr $x +5] [expr $y +5]
}

proc ::poImgBrowse::SelectionCB { tw tbl cell } {
    variable pkgInt
    variable pkgOpt

    set noCols [$tbl cget -cols]
    set retVal [catch { set curRow [$tbl index active row] }]
    if { $retVal != 0 } {
        set curRow 1
        $tbl selection set $curRow,0 $curRow,$noCols
        $tbl activate $curRow,0
    }
    set curCol [$tbl index active col]
    if { $curRow == 0 && $curCol == 0 } {
        set pkgInt(selMode) "all"
    } elseif { $curCol == 0 } {
        set pkgInt(selMode) "row"
        set pkgInt(curRow) $curRow
    } elseif { $curRow == 0 } {
        set pkgInt(selMode) "col"
        set pkgInt(curCol) $curCol
    } else {
        set pkgInt(selMode) "row"
        set pkgInt(curRow) $curRow
        set pkgInt(curCol) $curCol
    }

    if { $pkgInt(selMode) == "row" } {
        $tbl selection set $curRow,0 $curRow,$noCols
        set noSel [llength [::poImgBrowse::GetSelRows $tbl]]
        set msgStr "$noSel file[::poMisc::Plural $noSel] selected"
        ::poImgBrowse::WriteInfoStr $tw $msgStr
        ::poImgBrowse::PrintInfo $tw $tbl $curRow
    } elseif { $pkgInt(selMode) == "col" } {
        set noSel [llength [::poImgBrowse::GetSelCols $tbl]]
        set msgStr "$noSel column[::poMisc::Plural $noSel] selected"
        ::poImgBrowse::WriteInfoStr $tw $msgStr
    } elseif { $pkgInt(selMode) == "all" } {
        set msgStr "All files selected"
        ::poImgBrowse::WriteInfoStr $tw $msgStr
    }
    if { $pkgOpt(showThumb) } {
        ::poImgBrowse::UpdateVisImgs $tw $tbl 0
    }
}

proc ::poImgBrowse::FreeResources { w } {
    variable pkgInt

    ::poImgBrowse::StopBrowsing

    set phImg [$pkgInt($w,previewImg) cget -image]
    catch { image delete $phImg }

    destroy $w
    if {$pkgInt(standAlone) } {
        destroy .
    }
}

proc ::poImgBrowse::StopBrowsing {} {
    variable pkgInt

    set pkgInt(stopBrowse) 1
}

proc ::poImgBrowse::DeletePhotos { tw r1 r2 } {
    variable pkgCol

    set winId [::poImgBrowse::GetCurWinId $tw]
    upvar ::poImgBrowse::TblArr$winId tblArr

    for { set row $r1 } { $row <= $r2 } { incr row } {
        if { $tblArr($row,$pkgCol(Img)) != "None" } {
            image delete $tblArr($row,$pkgCol(Img))
        }
    }
}

proc ::poImgBrowse::DelAllThumbs { tw tbl } {
    variable pkgCol

    set dirName  [::poImgBrowse::GetCurImgDir $tw]
    set thumbDir [::poImgBrowse::GetThumbDir $dirName]
    file delete -force $thumbDir
    ::poImgBrowse::WriteInfoStr $tw "Deleted thumbnails of directory $dirName"
    return
}

proc ::poImgBrowse::CloseProgressWin {} {
    variable pkgInt

    set tw .poImgBrowse:ProgressWin
    destroy $tw
}

proc ::poImgBrowse::OpenProgressWin { dirName } {
    variable pkgInt
    variable pkgOpt

    set tw .poImgBrowse:ProgressWin

    if { [winfo exists $tw] } {
        ::poWin::Raise $tw
        return
    }

    toplevel $tw
    wm title $tw [Str ProgressWinTitle]
    wm resizable $tw false false

    label $tw.dir1 -text "Directory:"
    label $tw.dir2 -text "$dirName" -width 30 -anchor w

    label $tw.todo1 -text "Still to do:"
    label $tw.todo2 -textvariable ::poImgBrowse::pkgInt(progressTodo) -width 30 -anchor w

    label $tw.name1 -text "Current image:"
    label $tw.name2 -textvariable ::poImgBrowse::pkgInt(progressName) -width 30 -anchor w

    if { $pkgOpt(showThumb) } {
        set size $pkgOpt(thumbSize)
    } else {
        set size 1
    }
    set pkgInt(progressImg) [image create photo -width $size -height $size]
    label $tw.img -image $pkgInt(progressImg)

    button $tw.cancel -textvariable ::poImgBrowse::pkgInt(progressBtn) \
        -command "::poImgBrowse::StopBrowsing ; ::poImgBrowse::CloseProgressWin"
    bind $tw <KeyPress-Escape> { ::poImgBrowse::StopBrowsing }

    grid $tw.dir1   -row 0 -column 0 -sticky w
    grid $tw.dir2   -row 0 -column 1 -sticky w
    grid $tw.todo1  -row 1 -column 0 -sticky w
    grid $tw.todo2  -row 1 -column 1 -sticky w
    grid $tw.name1  -row 2 -column 0 -sticky w
    grid $tw.name2  -row 2 -column 1 -sticky w
    grid $tw.img    -row 3 -column 0 -columnspan 2 -sticky news
    grid $tw.cancel -row 4 -column 0 -columnspan 2 -sticky news
    focus $tw
}

proc ::poImgBrowse::GenAllThumbs { tw tbl { withSubDirs 0 } } {
    variable pkgInt
    variable pkgOpt
    variable pkgCol

    set winId [::poImgBrowse::GetCurWinId $tw]
    upvar ::poImgBrowse::TblArr$winId tblArr

    set pkgInt(stopBrowse) 0
    set noRows [expr [$tbl cget -rows] -1]
    set dirName  [::poImgBrowse::GetCurImgDir $tw]
    set thumbDir [::poImgBrowse::GetThumbDir $dirName]
    set pkgInt(progressTodo) "$noRows"
    set pkgInt(progressName) "Initializing ..."
    set pkgInt(progressBtn)  "Cancel"
    ::poImgBrowse::OpenProgressWin $dirName
    if { ! [::poImgBrowse::CreateThumbDir $thumbDir] } {
        ::poLog::Warning "Unable to create thumbs directory $thumbDir. \
                          Check permissions."
        tk_messageBox -title "Warning" -type ok -icon warning -message \
           "Unable to create thumbs directory $thumbDir. Check permissions."
    }
    for { set row 1 } { $row <= $noRows } { incr row } {
        set imgName $tblArr($row,$pkgCol(Name))
        set imgFile   [file join $dirName $imgName]
        set thumbFile [::poImgBrowse::BuildThumbFileName $thumbDir $imgName]
        set thumbInfoFile [::poImgBrowse::GetThumbInfoFile $thumbFile]
        set thumbExists [expr [file exists $thumbFile] && \
                              [file exists $thumbInfoFile]]
        set msgStr "Image: $imgName Thumb: "
        set pkgInt(progressTodo) [expr {$noRows - $row}]
        set pkgInt(progressName) $imgName
        if { !$thumbExists } {
            set imgInfo [::poImgBrowse::ReadImgAndGenThumb $imgFile \
                                       $pkgOpt(thumbSize) $pkgOpt(thumbSize)]
            set photoName [lindex $imgInfo 0]
            if { $photoName != "None" } {
                if { $pkgOpt(showThumb) } {
                    $pkgInt(progressImg) blank
                    $pkgInt(progressImg) copy $photoName
                }
                set retVal [catch {$photoName write $thumbFile -format PNG}]
                if { $retVal != 0 } {
                    append msgStr "NOT generated"
                } else {
                    #puts "Img: $imgFile (Thumb: $thumbFile Info: $thumbInfoFile)"
                    set retVal [catch {open $thumbInfoFile w} fp]
                    if { $retVal != 0 } {
                        append msgStr "NOT generated"
                    } else {
                        puts $fp "[lindex $imgInfo 1] [lindex $imgInfo 2]"
                        close $fp
                        append msgStr "Generated"
                    }
                }
                image delete $photoName
            } else {
                append msgStr "NOT generated"
            }
        } else {
            append msgStr "Already exists"
        }
    
        ::poLog::Info $msgStr
        update
        if { $pkgInt(stopBrowse) == 1 } {
            ::poImgBrowse::CloseProgressWin
            return
        }
    }
    set pkgInt(progressTodo) 0
    set pkgInt(progressName) "Finished"
    set pkgInt(progressBtn)  "Close"
    update
    return
}

proc ::poImgBrowse::LoadPhotos { tw tbl r1 r2 } {
    variable pkgInt
    variable pkgOpt
    variable pkgCol

    set winId [::poImgBrowse::GetCurWinId $tw]
    upvar ::poImgBrowse::TblArr$winId tblArr

    ::poLog::Debug "Loading photos $r1 $r2"
    set pkgInt(stopBrowse) 0
    set dirName  [::poImgBrowse::GetCurImgDir $tw]
    set thumbDir [::poImgBrowse::GetThumbDir $dirName]
    if { $pkgOpt(saveThumb) } {
        ::poImgBrowse::CreateThumbDir $thumbDir 
    }
    for { set row $r1 } { $row <= $r2 } { incr row } {
    
        set imgName $tblArr($row,$pkgCol(Name))
        set imgFile   [file join $dirName $imgName]
        set thumbFile [::poImgBrowse::BuildThumbFileName $thumbDir $imgName]
        set thumbInfoFile [::poImgBrowse::GetThumbInfoFile $thumbFile]
        set thumbExists [expr [file exists $thumbFile] && \
                              [file exists $thumbInfoFile]]
        ::poLog::Debug "Row $row: Reading image $imgFile (Have thumbnail: $thumbExists)"

        if { $thumbExists } {
            set imgInfo [::poImgBrowse::ReadThumbFile $thumbFile]
        } else {
            set imgInfo [::poImgBrowse::ReadImgAndGenThumb $imgFile \
                                       $pkgOpt(thumbSize) $pkgOpt(thumbSize)]
        }
        set photoName [lindex $imgInfo 0]
  
        set tblArr($row,$pkgCol(Img))    $photoName
        set tblArr($row,$pkgCol(Width))  [lindex $imgInfo 1]
        set tblArr($row,$pkgCol(Height)) [lindex $imgInfo 2]
  
        if { [lindex $imgInfo 0] != "None" } {
            $tbl tag config $photoName -image $photoName
            $tbl tag cell $photoName $row,$pkgCol(Img)
            if { $pkgOpt(saveThumb) } {
                if { ! $thumbExists } {
                    set retVal [catch {$photoName write $thumbFile -format PNG}]
                    if { $retVal != 0 } {
                        ::poLog::Warning "Cannot write thumb $thumbInfoFile"
                    } else {
                        set retVal [catch {open $thumbInfoFile w} fp]
                        if { $retVal != 0 } {
                            ::poLog::Warning "Cannot write info file $thumbInfoFile"
                        } else {
                            puts $fp "[lindex $imgInfo 1] [lindex $imgInfo 2]"
                            close $fp
                        }
                    }
                }
            }
        }
    
        update idletasks
        if { $pkgInt(stopBrowse) == 1 } {
            break
        }
    }
}

proc ::poImgBrowse::UpdateVisImgs { tw tbl { force 0 } } {
    variable pkgInt

    if { [$tbl cget -rows] == 1 } {
        return
    }

    set rowVis1 [$tbl index topleft row]
    set rowVis2 [$tbl index bottomright row]
    # puts "Old rows: $pkgInt(rowVis1) $pkgInt(rowVis2) New rows: $rowVis1 $rowVis2"

    if { $force } {
        # puts "Modus: Force"
        ::poImgBrowse::DeletePhotos $tw $rowVis1 $rowVis2
        ::poImgBrowse::LoadPhotos $tw $tbl $rowVis1 $rowVis2

    } elseif { $rowVis1 == $pkgInt(rowVis1) } {
        # puts "Modus: Equal"
        return

    } elseif { $rowVis1 > $pkgInt(rowVis2) } {
        # puts "Modus: All underneath"
        ::poImgBrowse::DeletePhotos $tw $pkgInt(rowVis1) $pkgInt(rowVis2)
        ::poImgBrowse::LoadPhotos   $tw $tbl $rowVis1 $rowVis2

    } elseif { $rowVis2 < $pkgInt(rowVis1) } {
        # puts "Modus: All above"
        ::poImgBrowse::DeletePhotos $tw $pkgInt(rowVis1) $pkgInt(rowVis2)
        ::poImgBrowse::LoadPhotos   $tw $tbl $rowVis1 $rowVis2

    } elseif { $rowVis1 > $pkgInt(rowVis1) } {
        # puts "Modus: Some underneath"
        ::poImgBrowse::DeletePhotos $tw $pkgInt(rowVis1) [expr $rowVis1 -1]
        ::poImgBrowse::LoadPhotos   $tw $tbl [expr $pkgInt(rowVis2) +1] $rowVis2

    } elseif { $rowVis2 < $pkgInt(rowVis2) } {
        # puts "Modus: Some above"
        ::poImgBrowse::DeletePhotos $tw [expr $rowVis2 +1] $pkgInt(rowVis2)
        ::poImgBrowse::LoadPhotos   $tw $tbl $rowVis1 [expr $pkgInt(rowVis1) -1]
    } else {
        # puts "Modus: Size change"
        ::poImgBrowse::DeletePhotos $tw $rowVis1 $rowVis2
        ::poImgBrowse::LoadPhotos   $tw $tbl $rowVis1 $rowVis2
    }

    set pkgInt(rowVis1) $rowVis1
    set pkgInt(rowVis2) $rowVis2
}

proc ::poImgBrowse::yScrollImgTable { tw tbl args } {
    variable pkgOpt

    eval $tbl yview $args
    update idletasks
    if { $pkgOpt(showThumb) } {
        ::poImgBrowse::UpdateVisImgs $tw $tbl
    }
}

proc ::poImgBrowse::DestroyIcoDetail { w args } {
    foreach phImg $args {
        image delete $phImg
    }
    destroy $w
}

proc ::poImgBrowse::ShowIcoDetail { fileName } {
    variable detailWinNo

    set tw .poImgBrowse:IcoDetail$detailWinNo
    incr detailWinNo

    toplevel $tw
    wm title $tw "Details of [file tail $fileName]"
    wm resizable $tw true true

    set retVal 0
    set ind    0
    set row    0

    frame $tw.fr -relief sunken
    grid  $tw.fr -row 0 -column 0 -sticky news
    grid rowconfigure    $tw 0 -weight 1
    grid columnconfigure $tw 0 -weight 1
    set icofr [::poWin::CreateScrolledFrame $tw.fr "$fileName" \
               -height 300 -width 200]

    set phImgList {}
    while { $retVal == 0 } {
        set retVal [catch {set phImg [image create photo -file $fileName \
                                  -format "ICO -verbose 1 -index $ind"]} err]
        if { $retVal == 0 } {
            lappend phImgList $phImg
            set msg [format "Icon %2d: %3d x %3d" $ind \
                    [image width $phImg] [image height $phImg]]
            label $icofr.l$row -text $msg
            grid  $icofr.l$row -row $row -column 0 -sticky w

            frame $icofr.fr$row
            grid $icofr.fr$row -row $row -column 1 -sticky news

            button $icofr.fr$row.b -image $phImg
            pack   $icofr.fr$row.b -anchor w -in $icofr.fr$row -pady 5 -padx 5
        }
        incr ind
        incr row
    }

    # Create Close button
    frame $tw.okfr
    grid $tw.okfr -row 1 -column 0 -sticky we

    bind $tw <KeyPress-Escape> "::poImgBrowse::DestroyIcoDetail $tw $phImgList"
    button $tw.okfr.b -text "Close" \
           -command "::poImgBrowse::DestroyIcoDetail $tw $phImgList"
    wm protocol $tw WM_DELETE_WINDOW \
           "::poImgBrowse::DestroyIcoDetail $tw $phImgList"

    pack $tw.okfr.b -side left -fill x -padx 2 -expand 1
    focus $tw
}

proc ::poImgBrowse::DestroyAniGifDetail { w args } {
    foreach phImg $args {
        image delete $phImg
    }
    destroy $w
}

proc ::poImgBrowse::ShowAniGifDetail { fileName } {
    variable detailWinNo

    set tw .poImgBrowse:AniGifDetail$detailWinNo
    incr detailWinNo

    toplevel $tw
    wm title $tw "Details of [file tail $fileName]"
    wm resizable $tw true true

    set retVal 0
    set ind    0
    set row    0

    frame $tw.fr -relief sunken
    grid  $tw.fr -row 0 -column 0 -sticky news
    grid rowconfigure    $tw 0 -weight 1
    grid columnconfigure $tw 0 -weight 1
    set icofr [::poWin::CreateScrolledFrame $tw.fr "$fileName" \
               -height 300 -width 200]

    set phImgList {}
    while { $retVal == 0 } {
        set retVal [catch {set phImg [image create photo -file $fileName \
                                  -format "GIF -index $ind"]} err]
        if { $retVal == 0 } {
            lappend phImgList $phImg
            set msg [format "Icon %2d: %3d x %3d" $ind \
                    [image width $phImg] [image height $phImg]]
            label $icofr.l$row -text $msg
            grid  $icofr.l$row -row $row -column 0 -sticky w

            frame $icofr.fr$row
            grid $icofr.fr$row -row $row -column 1 -sticky news

            button $icofr.fr$row.b -image $phImg
            pack   $icofr.fr$row.b -anchor w -in $icofr.fr$row -pady 5 -padx 5
        }
        incr ind
        incr row
    }

    # Create Close button
    frame $tw.okfr
    grid $tw.okfr -row 1 -column 0 -sticky we

    bind $tw <KeyPress-Escape> "::poImgBrowse::DestroyAniGifDetail $tw $phImgList"
    button $tw.okfr.b -text "Close" \
           -command "::poImgBrowse::DestroyAniGifDetail $tw $phImgList"
    wm protocol $tw WM_DELETE_WINDOW \
           "::poImgBrowse::DestroyAniGifDetail $tw $phImgList"

    pack $tw.okfr.b -side left -fill x -padx 2 -expand 1
    focus $tw
}

proc ::poImgBrowse::ShowImgInfo { tw tbl } {
    variable pkgCol
    variable pkgInt

    ::poLog::Info "::poImgBrowse::ShowImgInfo $tw $tbl"

    if { ! [RowsSelected] } {
        ::poImgBrowse::WriteInfoStr $tw "No files selected for info"
        return
    }
    set rowList [::poImgBrowse::GetSelRows $tbl]
    set dirName [::poImgBrowse::GetCurImgDir $tw]
    set noImgs  [llength $rowList]

    if { $noImgs == 0 } {
        ::poImgBrowse::WriteInfoStr $tw "No files selected for info"
        return
    }

    $tw configure -cursor watch
    update

    foreach row $rowList {
        set imgName  [$tbl get $row,$pkgCol(Name)]
        set fileName [file join $dirName $imgName]
        set attrList [::poMisc::FileInfo $fileName]

        if { [$tbl cget -cols] > 5 } {
            set w [$tbl get $row,$pkgCol(Width)]
            set h [$tbl get $row,$pkgCol(Height)]
        } else {
            set w "Unknown"
            set h "Unknown"
        }
        lappend attrList [list "Width"  $w]  
        lappend attrList [list "Height" $h]

        set fmtStr [::poImgtype::GetFmtByExt [file extension $imgName]]
        set viewCmd ""
        # Check for animated GIF's
        if { [string compare $fmtStr "GIF"] == 0 } {
            if { [::poImgtype::CheckAniGifIndex $fileName 1] } {
                set ind 10
                while { [::poImgtype::CheckAniGifIndex $fileName $ind] } {
                    incr ind 10
                }
                incr ind -1
                while { ! [::poImgtype::CheckAniGifIndex $fileName $ind] } {
                    incr ind -1
                }
                lappend attrList \
                        [list "Animated GIF" "[expr $ind +1] frames"]
                set viewCmd "::poImgBrowse::ShowAniGifDetail"
            }
        # Check for Windows Icons
        } elseif { [string compare $fmtStr "ICO"] == 0 } {
            set ind 0
            while { [::poImgtype::CheckIcoIndex $fileName $ind] } {
                incr ind
            }
            lappend attrList \
                    [list "File contains" "$ind icons"]
            set viewCmd "::poImgBrowse::ShowIcoDetail"
        # Check for EXIF tags
        } elseif { [string compare $fmtStr "JPEG"] == 0 } {
            # OPA TODO Exif Viewer doesn't recognize my Camera tags.
            if { 0 } {
                set exifInfo [::poImgtype::GetExifInfo $fileName]
                puts "EXIF INFO <$exifInfo>"
                if {0} {
                set len [llist $exitInfo]
                lappend attrList \
                        [list "File contains" "$len EXIF tags"]
                set viewCmd "::poImgBrowse::ShowExifDetail"
                }
            }
        }

        # Copy the selected thumbnail image for display in the info window.
        # Thumbnail images are available only for table entries visible.
        set phImg ""
        if { ![string equal [$tbl get $row,$pkgCol(Img)] "None"] } {
            set phImg [image create photo]
            $phImg copy [$tbl get $row,$pkgCol(Img)]
        }
        ::poWin::CreateOneFileInfoWin "$fileName" $attrList \
                                      $phImg $viewCmd
    }
    $tw configure -cursor top_left_arrow
}

proc ::poImgBrowse::ColsSelected {} {
    variable pkgInt

    if { $pkgInt(selMode) == "col" } {
        return 1
    }
    return 0
}

proc ::poImgBrowse::RowsSelected {} {
    variable pkgInt

    if { $pkgInt(selMode) == "row" || $pkgInt(selMode) == "all" } {
        return 1
    }
    return 0
}

proc ::poImgBrowse::AskCopyOrMoveTo { tw tbl mode } {
    variable pkgCol
    variable pkgInt
    variable pkgOpt

    ::poLog::Info "AskCopyOrMoveTo $tw $tbl $mode"

    if { ! [RowsSelected] } {
        ::poImgBrowse::WriteInfoStr $tw "No files selected for copy or move"
        return
    }

    set rowList [::poImgBrowse::GetSelRows $tbl]
    set dirName [::poImgBrowse::GetCurImgDir $tw]
    if { [llength $rowList] == 0 } {
        ::poImgBrowse::WriteInfoStr $tw "No files selected for copy or move"
        return
    }

    set tmpDir [::poTree::GetDir -initialdir $pkgOpt(lastDir) -showfiles 0 \
                                 -title "Select directory to copy files into"]
    if { [string compare $tmpDir ""] != 0 && \
         [file isdirectory $tmpDir] } {
        set pkgOpt(lastDir) $tmpDir

        foreach row $rowList {
            set imgName [$tbl get $row,$pkgCol(Name)]
            set srcName [file join $dirName $imgName]
            set dstName [file join $tmpDir  $imgName]
            if { [file exists $dstName] } {
                set retVal [tk_messageBox \
                  -title "Confirmation" \
                  -message "Overwrite existing file $dstName ?" \
                  -type yesnocancel -default yes -icon question]
                if { [string compare $retVal "cancel"] == 0 } {
                    return
                } elseif { [string compare $retVal "no"] == 0 } {
                    continue
                }
            }
            if { $mode == "copy" } {
                ::poImgBrowse::WriteInfoStr $tw \
                    "Copying file $srcName to $tmpDir"
                update
                file copy -force -- $srcName $tmpDir
            } else {
                ::poImgBrowse::WriteInfoStr $tw \
                    "Moving file $srcName to $tmpDir"
                update
                file rename -force -- $srcName $tmpDir
            }
        }
        if { $mode != "copy" } {
            ::poImgBrowse::ShowFileList $tw
        }
    }
}

proc ::poImgBrowse::DiffFiles { tw tbl } {
    variable pkgCol
    variable pkgInt

    if { ! [RowsSelected] } {
        ::poImgBrowse::WriteInfoStr $tw "No files selected for diffing"
        return
    }
    set rowList [::poImgBrowse::GetSelRows $tbl]
    set dirName [::poImgBrowse::GetCurImgDir $tw]

    set noSel [llength $rowList]
    if { $noSel != 2 } {
        ::poImgBrowse::WriteInfoStr $tw "Diffing only possible for 2 files"
        return
    }

    set row1 [lindex $rowList 0]
    set imgName [$tbl get $row1,$pkgCol(Name)]
    set leftFile [file join $dirName $imgName]
    set row2 [lindex $rowList 1]
    set imgName [$tbl get $row2,$pkgCol(Name)]
    set rightFile [file join $dirName $imgName]

    ::poExtProg::StartDiffProg $leftFile $rightFile ::WriteInfoStr 0
}

proc ::poImgBrowse::AskRenameFile { tw tbl } {
    variable pkgCol
    variable pkgInt

    if { ! [RowsSelected] } {
        ::poImgBrowse::WriteInfoStr $tw "No file selected for renaming"
        return
    }

    set rowList [::poImgBrowse::GetSelRows $tbl]
    set dirName [::poImgBrowse::GetCurImgDir $tw]

    set noSel [llength $rowList]
    if { $noSel == 0 } {
        ::poImgBrowse::WriteInfoStr $tw "No file selected for renaming"
        return
    } elseif { $noSel != 1 } {
        ::poImgBrowse::WriteInfoStr $tw "Renaming only possible for one file"
        return
    }

    set row [lindex $rowList 0]
    set imgName [$tbl get $row,$pkgCol(Name)]
    set srcName [file join $dirName $imgName]

    set retName [::poWin::EntryBox $imgName $pkgInt(mouse,x) $pkgInt(mouse,y)]

    if { [string compare $retName ""] == 0 } {
        ::poImgBrowse::WriteInfoStr $tw \
            "No file name specified or empty file name. No renaming."
        return
    }

    set newName [file join $dirName $retName]
    if { [file exists $newName] } {
        set retVal [tk_messageBox -icon question -type yesno -default yes \
            -message "File $newName already exists. Overwrite?" \
            -title "Confirmation"]
        if { [string compare $retVal "no"] == 0 } {
            return
        }
    }
    set catchVal [catch { file rename -force -- $srcName $newName } errorInfo]
    if { $catchVal } {
        tk_messageBox -message [lindex [split "$errorInfo" "\n"] 0] \
                      -title "Error message" -icon error -type ok
        return
    }
    ::poImgBrowse::WriteInfoStr $tw "Renamed $imgName to: $newName"
    ::poImgBrowse::ShowFileList $tw
    focus $tbl
}

proc ::poImgBrowse::UpdateDirList { tw dirToShow } {
    variable pkgInt

    set treeId $pkgInt(treeId,$tw)
    ::poTree::OpenBranch $treeId $dirToShow
    ::poTree::Setselection $treeId $dirToShow
    ::poImgBrowse::ShowFileList $tw
}

proc ::poImgBrowse::AskRenameDir { tw } {
    variable pkgInt

    set dirList [::poImgBrowse::GetSelDirectories $tw]
    set noSel [llength $dirList]
    if { $noSel == 1 } {
        set dirName [lindex $dirList 0]
    } else {
        ::poImgBrowse::WriteInfoStr $tw "No directory or more than 1 selected."
        return
    }
    set retName [::poWin::EntryBox [file tail $dirName] \
                                    $pkgInt(mouse,x) $pkgInt(mouse,y)]

    if { [string compare $retName ""] == 0 } {
        ::poImgBrowse::WriteInfoStr $tw "Empty directory name. Can not rename."
        return
    }

    set newName [file join [file dirname $dirName] $retName]
    if { [file isdirectory $newName] } {
        tk_messageBox -icon warning -type ok  -title "Warning" \
            -message "Directory $newName exists. No overwrite possible."
        return
    }
    ::poLog::Info "Renaming directory $dirName to $newName"

    set catchVal [catch { file rename $dirName $newName } errorInfo]
    if { $catchVal } {
        tk_messageBox -message [lindex [split "$errorInfo" "\n"] 0] \
                      -icon error -type ok -title "Error message"
        return
    }
    ::poTree::delitem $pkgInt(treeId,$tw) $dirName
    ::poImgBrowse::UpdateDirList $tw $newName
}

proc ::poImgBrowse::AskDelDir { tw } {
    variable pkgInt

    set dirList [::poImgBrowse::GetSelDirectories $tw]
    set noSel [llength $dirList]
    if { $noSel == 1 } {
        set dirName [lindex $dirList 0]
    } else {
        ::poImgBrowse::WriteInfoStr $tw "No directory or more than 1 selected."
        return
    }

    set msgStr "Delete directory $dirName and all its contents ?"
    set retVal [tk_messageBox \
      -title "Confirmation" -message $msgStr \
      -type yesno -default yes -icon question]
    if { [string compare $retVal "no"] == 0 } {
        focus $pkgInt(treeId,$tw)
        return
    }
    ::poLog::Info "Deleting directory $dirName"

    set catchVal [catch { file delete -force -- $dirName } errorInfo]
    if { $catchVal } {
        tk_messageBox -message [lindex [split "$errorInfo" "\n"] 0] \
                      -icon error -type ok -title "Error message"
        return
    }
    ::poTree::delitem $pkgInt(treeId,$tw) $dirName
    ::poImgBrowse::UpdateDirList $tw [file dirname $dirName]
}

proc ::poImgBrowse::AskNewDir { tw } {
    variable pkgInt

    set dirList [::poImgBrowse::GetSelDirectories $tw]
    set noSel [llength $dirList]
    if { $noSel == 1 } {
        set dirName [lindex $dirList 0]
    } else {
        tk_messageBox -icon warning -type ok -title "Warning" \
        -message "No directory or more than 1 selected."
        return
    }
    set retName [::poWin::EntryBox "New directory" \
                                    $pkgInt(mouse,x) $pkgInt(mouse,y)]

    if { [string compare $retName ""] == 0 } {
        ::poImgBrowse::WriteInfoStr $tw "Empty directory name. Can not create."
        return
    }
    set newName [file join $dirName $retName]
    if { [file isdirectory $newName] } {
        tk_messageBox -icon warning -type ok  -title "Warning" \
            -message "Directory $newName exists. No creation possible."
        return
    }
    ::poLog::Info "Creating directory $newName"
    file mkdir "$newName"
    ::poImgBrowse::UpdateDirList $tw [file join $dirName]
}

proc ::poImgBrowse::AskCopyOrMoveDir { tw mode } {
    variable pkgInt
    variable pkgOpt

    set dirList [::poImgBrowse::GetSelDirectories $tw]
    set noSel [llength $dirList]
    if { $noSel == 1 } {
        set dirName [lindex $dirList 0]
    } else {
        tk_messageBox -icon warning -type ok -title "Warning" \
        -message "No directory or more than 1 selected."
        return
    }

    set tmpDir [::poTree::GetDir -initialdir $pkgOpt(lastDir) -showfiles 0 \
                                 -title "Select directory to copy to"]
    if { [string compare $tmpDir ""] != 0 && \
         [file isdirectory $tmpDir] } {
        set pkgOpt(lastDir) $tmpDir
        set newName [file join $tmpDir [file tail $dirName]]
        if { [file isdirectory $newName] } {
            tk_messageBox -icon warning -type ok  -title "Warning" \
                -message "Directory $newName already exists. Use file copy instead."
            return
        }
        if { $mode == "copy" } {
            ::poImgBrowse::WriteInfoStr $tw \
                        "Copying directory $dirName to $newName"
            file copy -force -- $dirName $newName
            ::poImgBrowse::UpdateDirList $tw [file join $dirName]
        } else {
            ::poImgBrowse::WriteInfoStr $tw \
                        "Moving directory $dirName to $newName"
            file rename -force -- $dirName $newName
            ::poTree::delitem $pkgInt(treeId,$tw) $dirName
            ::poImgBrowse::UpdateDirList $tw [file dirname $dirName]
        }
    } else {
        ::poImgBrowse::WriteInfoStr $tw "Empty directory name. Can not create."
        return
    }
}

proc ::poImgBrowse::AskDelFile { tw tbl } {
    variable pkgCol
    variable pkgInt
    variable pkgOpt

    ::poLog::Info "AskDelFile $tw $tbl"
    if { ! [RowsSelected] } {
        ::poImgBrowse::WriteInfoStr $tw "No files selected for deletion"
        return
    }

    set rowList [::poImgBrowse::GetSelRows $tbl]
    set dirName [::poImgBrowse::GetCurImgDir $tw]

    set noSel [llength $rowList]
    if { $noSel == 0 } {
        ::poImgBrowse::WriteInfoStr $tw "No files selected for deletion"
        return
    } elseif { $noSel == 1 } {
        set msgStr "Delete file [$tbl get [lindex $rowList 0],$pkgCol(Name)] ?"
    } else {
        set msgStr "Delete selected $noSel files ?"
    }
    set retVal [tk_messageBox \
      -title "Confirmation" -message $msgStr \
      -type yesno -default yes -icon question]
    if { [string compare $retVal "no"] == 0 } {
        focus $tbl
        return
    }

    set delError 0
    foreach row $rowList {
        set imgName [$tbl get $row,$pkgCol(Name)]
        set srcName [file join $dirName $imgName]
        ::poImgBrowse::WriteInfoStr $tw "Deleting file $srcName"
        update
        set catchVal [catch { file delete -force -- $srcName } errorInfo]
        if { $catchVal } {
            tk_messageBox -message [lindex [split "$errorInfo" "\n"] 0] \
                          -title "Error message" -icon error -type ok
            set delError 1
            break
        }
    }
    ::poImgBrowse::ShowFileList $tw

    if { $delError } {
        ::poImgBrowse::WriteInfoStr $tw "Error trying to delete file $imgName"
    } elseif { $noSel == 1 } {
        ::poImgBrowse::WriteInfoStr $tw "Deleted file $imgName"
    } else {
        ::poImgBrowse::WriteInfoStr $tw "Deleted $noSel files"
    }
    focus $tbl
}

proc ::poImgBrowse::LoadImgs { selFunc args } {
    variable pkgInt

    set pkgInt(stopBrowse) 0

    foreach fileName $args {
        $selFunc $fileName
        update
        if { $pkgInt(stopBrowse) } {
            break
        }
    }
}

proc ::poImgBrowse::OpenFiles { tw tbl selFunc } {

    if { ! [RowsSelected] } {
        ::poImgBrowse::WriteInfoStr $tw "No files selected for opening"
        return
    }

    set fileList [::poImgBrowse::GetSelFiles $tw $tbl]
    if { [llength $fileList] == 0 } {
        ::poImgBrowse::WriteInfoStr $tw "No files selected for opening"
        return
    }

    foreach f $fileList {
        ::poImgBrowse::LoadImgs $selFunc $f
    }
}

proc ::poImgBrowse::ViewFullScreen { canv fileName infoStr sw sh } {
    variable pkgOpt

    $canv configure -cursor watch
    update
    set xpos [expr $sw / 2]
    set ypos [expr $sh / 2]
    set phImg [image create photo -file $fileName]
    set phWidth  [image width $phImg]
    set phHeight [image height $phImg]
    set xzoom [expr ($phWidth  / $sw) + 1]
    set yzoom [expr ($phHeight / $sh) + 1]
    set zoomFact [::poMisc::Max $xzoom $yzoom]
    if { $pkgOpt(slideZoom) && $zoomFact > 1 } {
        set zoomImg [image create photo \
                     -width [expr $phWidth / $zoomFact] \
                     -height [expr $phHeight / $zoomFact]]
        $zoomImg copy $phImg -subsample $zoomFact
        $canv create image $xpos $ypos -anchor center -image $zoomImg -tags img
    } else {
        $canv create image $xpos $ypos -anchor center -image $phImg -tags img
    }
    if { $pkgOpt(slideInfo) } {
        $canv create text 10 10 -anchor nw -fill white -text $infoStr -tags info
    }
    $canv configure -cursor top_left_arrow
    update
    tkwait variable ::poImgBrowse::pkgInt(slideIncr)
    image delete $phImg
    if { [info exists zoomImg] } {
        image delete $zoomImg
    }
    $canv delete img
    if { $pkgOpt(slideInfo) } {
        $canv delete info
    }
}

proc ::poImgBrowse::ViewFile { tblWin tbl } {
    variable pkgCol
    variable pkgInt
    variable pkgOpt

    if { ! [RowsSelected] } {
        ::poImgBrowse::WriteInfoStr $tblWin "No files selected for viewing"
        return
    }
    set rowList [::poImgBrowse::GetSelRows $tbl]
    set dirName [::poImgBrowse::GetCurImgDir $tblWin]
    set noImgs  [llength $rowList]

    if { $noImgs == 0 } {
        ::poImgBrowse::WriteInfoStr $tblWin "No files selected for viewing"
        return
    }

    set tw .poImgBrowse:ViewFileWin
    catch { destroy $tw }

    set master .
    toplevel $tw
    canvas $tw.img -bg black -borderwidth 0
    pack $tw.img -fill both -expand 1 -side left

    set sh [winfo screenheight $master]
    set sw [winfo screenwidth $master]

    wm minsize $master $sw $sh
    wm maxsize $master $sw $sh
    set fmtStr [format "%dx%d+0+0" $sw $sh]
    wm geometry $tw $fmtStr
    wm overrideredirect $tw 1

    # Escape and Space keys for terminating slide show.
    bind $tw     <Escape> "set ::poImgBrowse::pkgInt(slideIncr) 0"
    bind $tw.img <Escape> "set ::poImgBrowse::pkgInt(slideIncr) 0"
    bind $tw     <space>  "set ::poImgBrowse::pkgInt(slideIncr) 0"
    bind $tw.img <space>  "set ::poImgBrowse::pkgInt(slideIncr) 0"
    # Mouse buttons and Arrow keys for stepping through images.
    bind $tw     <Left>  "set ::poImgBrowse::pkgInt(slideIncr) -1"
    bind $tw.img <Left>  "set ::poImgBrowse::pkgInt(slideIncr) -1"
    bind $tw     <Right> "set ::poImgBrowse::pkgInt(slideIncr)  1"
    bind $tw.img <Right> "set ::poImgBrowse::pkgInt(slideIncr)  1"
    bind $tw <ButtonRelease-1> "set ::poImgBrowse::pkgInt(slideIncr) -1"
    bind $tw <ButtonRelease-3> "set ::poImgBrowse::pkgInt(slideIncr)  1"
    focus -force $tw

    set pkgInt(slideIncr) 0
    set ind 0

    while { 1 } {
        set row [lindex $rowList $ind]
        set fileName [file join $dirName [$tbl get $row,$pkgCol(Name)]]
        set infoStr "Image: $fileName"
        if { $pkgOpt(showFileInfo) } {
            append infoStr " Size(kB): [$tbl get $row,$pkgCol(Size)]"
            append infoStr " Date: [$tbl get $row,$pkgCol(Date)]"
        }
        if { $pkgOpt(showImgInfo) } {
            append infoStr " Pixel: [$tbl get $row,$pkgCol(Width)]"
            append infoStr " x [$tbl get $row,$pkgCol(Height)]"
        }
        ::poImgBrowse::ViewFullScreen $tw.img $fileName $infoStr $sw $sh
        if { $pkgInt(slideIncr) == 0 } {
            break
        } else {
            set ind [expr ($ind + $pkgInt(slideIncr)) % $noImgs]
        }
    }
    destroy $tw
}

proc ::poImgBrowse::GetCurWinId { tw } {
    variable pkgInt
    return $pkgInt(winId,$tw)
}

proc ::poImgBrowse::GetCurImgDir { tw } {
    variable pkgInt
    return [lindex [::poTree::Getselection $pkgInt(treeId,$tw)] 0]
}

proc ::poImgBrowse::GetThumbDir { dirName } {
    global tcl_platform
    variable pkgOpt

    set name "poThumbs"
    if { $pkgOpt(hiddenThumbDir) && \
         [string compare $tcl_platform(platform) "unix"] == 0 } {
        set name ".poThumbs"
    }
    return [file join $dirName $name]
}

proc ::poImgBrowse::BuildThumbFileName { thumbDir imgName } {
    return [format "%s%s" [file join $thumbDir $imgName] ".png"]
}

proc ::poImgBrowse::GetThumbFile { imgFileName } {
    set dirName [file dirname $imgFileName]
    set imgName [file tail $imgFileName]

    set thumbDir [::poImgBrowse::GetThumbDir $dirName]
    return [file join $thumbDir $imgName]
}

proc ::poImgBrowse::GetThumbInfoFile { thumbFileName } {
    return [format "%s%s" $thumbFileName "_info"]
}

proc ::poImgBrowse::CreateThumbDir { thumbDir } {
    global tcl_platform
    variable pkgOpt

    if { ! [file isdirectory $thumbDir] } {
        if { [catch {file mkdir $thumbDir} ] } {
            ::poLog::Warning "Unable to create thumbs directory $thumbDir."
            ::poLog::Warning "Check permissions."
            return 0
        }
        if { $pkgOpt(hiddenThumbDir) && \
             [string compare $tcl_platform(platform) "windows"] == 0 } {
            file attributes $thumbDir -hidden 1
        }
    }
    return 1
}

proc ::poImgBrowse::ShowFileList { tw } {
    variable pkgInt
    variable pkgOpt
    variable pkgCol
    global tcl_platform

    set winId [::poImgBrowse::GetCurWinId $tw]
    upvar ::poImgBrowse::TblArr$winId tblArr

    $tw configure -cursor watch
    ::poImgBrowse::WriteInfoStr $tw "Getting file list ..."
    update
    set dirName [::poImgBrowse::GetCurImgDir $tw]
    set imgFileList [::poImgBrowse::GetFileList $dirName]

    wm title $tw "$dirName: [llength $imgFileList] files match filter"

    if { [llength $imgFileList] == 0 } {
        ::poLog::Info "No files match filter in directory $dirName"
        $pkgInt(tableId,$tw) configure -rows 0
        $tw configure -cursor top_left_arrow
        ::poImgBrowse::WriteInfoStr $tw "Scanning finished."
        return
    } else {
        $pkgInt(tableId,$tw) configure -rows [expr [llength $imgFileList] + 1]
    }

    set thumbDir [::poImgBrowse::GetThumbDir $dirName]

    if { $pkgOpt(saveThumb) } {
        if { ! [::poImgBrowse::CreateThumbDir $thumbDir] } {
            set pkgOpt(saveThumb) 0
        }
    }

    set dummyImg [image create photo -width 1 -height 1]
    set row 1
    set pkgInt(stopBrowse) 0
    foreach imgFileInfo $imgFileList {
    
        if { $pkgOpt(showFileInfo) } {
            set imgFile [lindex $imgFileInfo 0]
            set size    [lindex $imgFileInfo 1]
            set date    [lindex $imgFileInfo 2]
        } else {
            set imgFile $imgFileInfo
        }

        set tblArr($row,$pkgCol(Ind))  $row
        set tblArr($row,$pkgCol(Img))  "None"
        set tblArr($row,$pkgCol(Name)) $imgFile
        set pathName [file join $dirName $imgFile]
        if { $pkgOpt(showFileType) } {
            set retVal [catch {::poType::GetFileType $pathName} typeList]
            if { $retVal == 0 } {
                set type [lindex $typeList end]
                set tblArr($row,$pkgCol(Type)) $type
            }
        }
        if { $pkgOpt(showFileInfo) } {
            set tblArr($row,$pkgCol(Size)) [format "%.1f" [expr $size / 1024.0]]
            set tblArr($row,$pkgCol(Date)) $date
        }
        if { $pkgOpt(showImgInfo) } {
            set thumbFile [::poImgBrowse::GetThumbFile $pathName]
            set imgInfo [::poImgBrowse::ReadThumbInfoFile $thumbFile 0]
            set tblArr($row,$pkgCol(Width))  [lindex $imgInfo 0]
            set tblArr($row,$pkgCol(Height)) [lindex $imgInfo 1]
        }
        if { $pkgOpt(showThumb) } {
            $pkgInt(tableId,$tw) height $row [expr -1 * $pkgOpt(thumbSize)]
        }
        $pkgInt(tableId,$tw) tag config "None" -image $dummyImg
        $pkgInt(tableId,$tw) tag cell "None" $row,$pkgCol(Img)

        incr row
        if { $row % 20 == 0 } {
            ::poImgBrowse::WriteInfoStr $tw "Scanned $row files ..."
            update
            if { $pkgInt(stopBrowse) } {
                $pkgInt(tableId,$tw) configure -rows $row
                ::poImgBrowse::WriteInfoStr $tw "Scanning cancelled."
                break
            }
        }
    }
    if { $pkgInt(stopBrowse) == 0 } {
        ::poImgBrowse::WriteInfoStr $tw "Scanning finished."
    }
    $tw configure -cursor top_left_arrow
    update

    set pkgInt(rowVis1) [$pkgInt(tableId,$tw) index topleft row]
    set pkgInt(rowVis2) [$pkgInt(tableId,$tw) index bottomright row]

    if { $pkgOpt(showThumb) } {
        ::poImgBrowse::UpdateVisImgs $tw $pkgInt(tableId,$tw) 1
    }
}

proc ::poImgBrowse::CreateTree { par selDir tw } {
    variable pkgInt

    set treeId \
        [::poWin::CreateScrolledTree $par "" -bg white -width 150 ]
    ::poTree::InitOpen $treeId $selDir
    bind $treeId <1> "+focus $treeId"
    $treeId bind x <Button-1>      "+ ::poImgBrowse::ShowFileList $tw"
    bind $treeId <KeyPress-Return> "+ ::poImgBrowse::ShowFileList $tw"
    bind $treeId <Key-Down>        "+ ::poImgBrowse::ShowFileList $tw"
    bind $treeId <Key-Up>          "+ ::poImgBrowse::ShowFileList $tw"
    bind $treeId <Key-Left>        "+ ::poImgBrowse::ShowFileList $tw"
    bind $treeId <Key-Right>       "+ ::poImgBrowse::ShowFileList $tw"

    $treeId bind x <Button-3> "::poImgBrowse::DirectoryContextMenu $tw %X %Y"

    return $treeId
}

proc ::poImgBrowse::GetSelDirectories { tw } {
    set dirList [::poTree::Getselection $::poImgBrowse::pkgInt(treeId,$tw)]
    return $dirList
}

proc ::poImgBrowse::CountDirsAndFiles { root } {
    set noDirs  0
    set noFiles 0

    set dirAndFileList [::poMisc::GetDirList $root 1 1 1 1]
    incr noDirs  [llength [lindex $dirAndFileList 0]]
    incr noFiles [llength [lindex $dirAndFileList 1]]

    foreach dir [lindex $dirAndFileList 0] {
        set subDirCount [::poImgBrowse::CountDirsAndFiles [file join $root $dir]]
        incr noDirs  [lindex $subDirCount 0]
        incr noFiles [lindex $subDirCount 1]
    }
    return [list $noDirs $noFiles]
}

proc ::poImgBrowse::InfoDir { tw } {
    variable pkgInt

    $tw configure -cursor watch
    update

    set dirList [::poImgBrowse::GetSelDirectories $tw]
    set noSelDir [llength $dirList]

    set w .poImgBrowse:InfoDirWin
    catch { destroy $w }

    toplevel $w
    wm title $w "Directory Information"
    wm resizable $w true true

    frame $w.fr0 -relief sunken -borderwidth 1
    grid  $w.fr0 -row 0 -column 0 -sticky nwse
    set textId [::poWin::CreateScrolledText $w.fr0 "" -wrap word \
                         -height [::poMisc::Min 10 $noSelDir]]

    foreach selDir $dirList {
        ::poImgBrowse::WriteInfoStr $tw "Scanning directory $selDir ..."
        update
        set name [file tail $selDir]
        set dirInfo [::poImgBrowse::CountDirsAndFiles $selDir]
        set msgStr "Directory $name: [lindex $dirInfo 0] subdirs, [lindex $dirInfo 1] files\n"
        $textId insert end $msgStr
    }
    $textId configure -state disabled

    # Create OK button
    frame $w.fr1 -relief sunken -borderwidth 1
    grid  $w.fr1 -row 1 -column 0 -sticky nwse
    button $w.fr1.b -text "OK" -command "destroy $w" -default active
    bind $w.fr1.b <KeyPress-Return> "destroy $w"
    pack $w.fr1.b -side left -fill x -padx 2 -expand 1

    grid columnconfigure $w 0 -weight 1
    grid rowconfigure    $w 0 -weight 1

    bind $w <Escape> "destroy $w"
    bind $w <Return> "destroy $w"
    $tw configure -cursor top_left_arrow
    focus $w
}

proc ::poImgBrowse::DirectoryContextMenu { tw x y } {
    set w .poImgBrowse:directoryContextMenu
    catch { destroy $w }
    menu $w -tearoff false -disabledforeground white

    set selList [::poImgBrowse::GetSelDirectories $tw]
    set noSel [llength $selList]
    if { $noSel == 0 } {
        set menuTitle "Nothing selected"
    } else {
        set menuTitle "$noSel selected"
    }
    $w add command -label "$menuTitle" -state disabled -background "#303030"
    if { $noSel == 0 } {
        tk_popup $w $x $y
        return
    }

    $w add command -label "Info" -command "::poImgBrowse::InfoDir $tw"
    if { $noSel == 1 } {
        # All of these commands are currently supported only for 1 directory.
        $w add command -label "Update" \
                       -command "::poImgBrowse::UpdateDirList $tw $selList"
        $w add separator
        $w add command -label "New ..." \
                       -command "::poImgBrowse::AskNewDir $tw"
        $w add separator
        $w add command -label "Rename ..." \
                       -command "::poImgBrowse::AskRenameDir $tw"
        $w add separator
        $w add command -label "Copy to ..." \
                       -command "::poImgBrowse::AskCopyOrMoveDir $tw copy"
        $w add command -label "Move to ..." \
                       -command "::poImgBrowse::AskCopyOrMoveDir $tw move"
        $w add separator
        $w add command -label "Delete ..." \
                       -command "::poImgBrowse::AskDelDir $tw"
    }
    tk_popup $w $x $y
}

proc ::poImgBrowse::HelpCont { parWin } {
    tk_messageBox -message "Sorry, no online help available yet." \
                           -type ok -icon info -title "Online Help"
    focus $parWin
}

proc ::poImgBrowse::HelpProg { {splashWin ""} } {
    ::poSoftLogo::ShowLogo \
        "poImgBrowse Version 0.3" \
        "Copyright 2000-2008 Paul Obermeier" \
        $splashWin
    if { [string compare $splashWin ""] != 0 } {
        ::poSoftLogo::DestroyLogo
    }
}

proc ::poImgBrowse::HelpTcl {} {
    ::poSoftLogo::ShowTclLogo 0 Tk Img Tktable combobox mktclapp
}

proc ::poImgBrowse::UpdateCombo { cb typeList showInd } {
    $cb list delete 0 end
    foreach type $typeList {
        $cb list insert end $type
    }
    $cb configure -value [lindex $typeList $showInd]
    $cb select $showInd
}

proc ::poImgBrowse::ComboCB { tw args } {
    variable pkgOpt

    set pkgOpt(suffixFilter) [lindex $args 1]
    ::poImgBrowse::ShowFileList $tw
}

proc ::poImgBrowse::DummyFunc { fileName } {
    variable pkgInt

    ::poLog::Info "Opening image file $fileName"
    return
}

proc ::poImgBrowse::PreviewFunc { fileName tw } {
    variable pkgInt

    ::poLog::Info "Previewing image file $fileName"
    # Delete the image already stored in the preview label.
    set oldImg [$pkgInt($tw,previewImg) cget -image]
    catch { image delete $oldImg }

    set sw [winfo width  $pkgInt($tw,previewPar)]
    set sh [winfo height $pkgInt($tw,previewPar)]
    set minSize [::poMisc::Min $sw $sh]

    set imgInfo [::poImgBrowse::ReadImgAndGenThumb $fileName $sw $sh]
    set phImg [lindex $imgInfo 0]
    if { [string compare $phImg "None"] == 0 } {
        $pkgInt($tw,previewImg) configure -image {}
        $pkgInt($tw,previewImg) configure -text  ""
        set retVal [catch {::poType::GetFileType $fileName} typeList]
        if { $retVal == 0 } {
            if { [lsearch -exact $typeList "text"] >= 0 } {
                set fp [open $fileName "r"]
                set head [read $fp 1024]
                close $fp
                $pkgInt($tw,previewImg) configure -text $head -justify left -anchor nw
            }
        }
    } else {
        $pkgInt($tw,previewImg) configure -image $phImg
    }
    $pkgInt($tw,previewTxt) configure -text [file tail $fileName]
    return
}

proc ::poImgBrowse::AddMenuCmd { menu label acc cmd args } {
    eval {$menu add command -label $label -accelerator $acc -command $cmd} $args
}

###########################################################################
#[@e
#       Name:           ::poImgBrowse::OpenDir
#
#       Usage:          Open an image browser window.
#
#       Synopsis:       proc ::poImgBrowse::OpenDir { dirName selFunc }
#
#       Description:    dirName: string
#
#       Return Value:   None.
#
#       See also:       
#
###########################################################################

proc ::poImgBrowse::OpenDir { dirName { selFunc ::poImgBrowse::DummyFunc } } {
    variable pkgInt
    variable pkgOpt
    variable pkgCol
    variable winGeom

    set tw "$pkgInt(mainWin)_$pkgInt(winNo)"
    set pkgInt(winId,$tw) $pkgInt(winNo)
    set winId $pkgInt(winNo)
    incr pkgInt(winNo)

    if { [catch {toplevel $tw -visual truecolor}] } {
        toplevel $tw
    }

    focus $tw
    wm geometry $tw [format "%dx%d+%d+%d" $winGeom(main,w) $winGeom(main,h) \
                                          $winGeom(main,x) $winGeom(main,y)]
    frame $tw.fr
    pack $tw.fr -expand 1 -fill both
    set fr $tw.fr

    frame $fr.toolfr -relief sunken -borderwidth 1
    frame $fr.workfr -relief sunken -borderwidth 1
    frame $fr.infofr -relief sunken -borderwidth 1
    grid $fr.toolfr -row 0 -column 0 -sticky news
    grid $fr.workfr -row 1 -column 0 -sticky news
    grid $fr.infofr -row 2 -column 0 -sticky news
    grid rowconfigure    $fr 1 -weight 1
    grid columnconfigure $fr 0 -weight 1

    frame $fr.workfr.fr
    pack  $fr.workfr.fr -expand 1 -fill both

    set pane $fr.workfr.fr.pane
    panedwindow $pane -orient horizontal -sashpad 4 -sashwidth 2 -opaqueresize true
    pack $pane -side top -expand 1 -fill both

    set lf $pane.lfr
    set rf $pane.rfr
    frame $lf
    frame $rf
    pack $lf -expand 1 -fill both -side left
    pack $rf -expand 1 -fill both -side left
    $pane add $lf $rf

    panedwindow $lf.pane -orient vertical -sashpad 4 -sashwidth 2 -opaqueresize true
    pack $lf.pane -side top -expand 1 -fill both

    frame $lf.pane.dirfr -relief raised
    frame $lf.pane.icofr -relief raised
    frame $rf.tblfr -relief raised
    grid $lf.pane.dirfr -row 0 -column 0 -sticky news
    grid $lf.pane.icofr -row 1 -column 0 -sticky news
    grid $rf.tblfr -row 0 -column 0 -sticky news
    $lf.pane add $lf.pane.dirfr $lf.pane.icofr

    grid rowconfigure    $lf 0 -weight 1
    grid columnconfigure $lf 0 -weight 1
    grid rowconfigure    $rf 0 -weight 1
    grid columnconfigure $rf 0 -weight 1

    set sx      $rf.tblfr.tabfr.sx
    set sy      $rf.tblfr.tabfr.sy
    set tableId $rf.tblfr.tabfr.table

    # Create menus File, Edit, Settings and Help
    set hMenu $tw.menufr
    menu $hMenu -borderwidth 2 -relief sunken
    $hMenu add cascade -menu $hMenu.file -label File     -underline 0
    $hMenu add cascade -menu $hMenu.edit -label Edit     -underline 0
    $hMenu add cascade -menu $hMenu.view -label View     -underline 0
    $hMenu add cascade -menu $hMenu.sett -label Settings -underline 0
    $hMenu add cascade -menu $hMenu.help -label Help     -underline 0

    set fileMenu $hMenu.file
    menu $fileMenu -tearoff 0
    AddMenuCmd $fileMenu "Open ..." "Ctrl+O" \
                         "::poImgBrowse::OpenFiles $tw $tableId $selFunc" 
    AddMenuCmd $fileMenu "Close" "Ctrl+W" \
                         "::poImgBrowse::FreeResources $tw" 
    bind $tw <Control-o> "::poImgBrowse::OpenFiles $tw $tableId $selFunc"
    bind $tw <Control-w> "::poImgBrowse::FreeResources $tw"
    wm protocol $tw WM_DELETE_WINDOW "::poImgBrowse::FreeResources $tw"

    set editMenu $hMenu.edit
    set thumbMenu $editMenu.thumb
    menu $editMenu -tearoff 0

    AddMenuCmd $editMenu "Delete" "Del" \
                         "::poImgBrowse::AskDelFile $tw $tableId"
    AddMenuCmd $editMenu "Rename" "Ctrl+R" \
                         "::poImgBrowse::AskRenameFile $tw $tableId"
    AddMenuCmd $editMenu "Copy to ..." "" \
                         "::poImgBrowse::AskCopyOrMoveTo $tw $tableId copy"
    AddMenuCmd $editMenu "Move to ..." "" \
                         "::poImgBrowse::AskCopyOrMoveTo $tw $tableId move"

    bind $tw <Delete>    "::poImgBrowse::AskDelFile $tw $tableId"
    bind $tw <Control-r> "::poImgBrowse::AskRenameFile $tw $tableId"

    $editMenu add separator
    $editMenu add cascade -label "Thumbnails" -menu $thumbMenu

    menu $thumbMenu -tearoff 0
    AddMenuCmd $thumbMenu "Update all" \
                          "" "::poImgBrowse::GenAllThumbs $tw $tableId 0"
    AddMenuCmd $thumbMenu "Update all with subdirs" \
                          "" "::poImgBrowse::GenAllThumbs $tw $tableId 1"
    AddMenuCmd $thumbMenu "Delete all" "" \
                          "::poImgBrowse::DelAllThumbs $tw $tableId"

    set viewMenu $hMenu.view
    menu $viewMenu -tearoff 0
    AddMenuCmd $viewMenu "Info" "Ctrl+I" \
                         "::poImgBrowse::ShowImgInfo $tw $tableId" 
    AddMenuCmd $viewMenu "Fullscreen" "Ctrl+E" \
                         "::poImgBrowse::ViewFile $tw $tableId" 
    bind $tw <Control-i> "::poImgBrowse::ShowImgInfo $tw $tableId"
    bind $tw <Control-e> "::poImgBrowse::ViewFile    $tw $tableId"

    set settMenu $hMenu.sett
    menu $settMenu -tearoff 0
    ::poImgBrowse::AddMenuCmd $settMenu "Logging ..." "" "::poLogOpt::OpenWin"
    ::poImgBrowse::AddMenuCmd $settMenu "File types ..." "" "::poFiletype::OpenWin"
    ::poImgBrowse::AddMenuCmd $settMenu "Image types ..." "" "::poImgtype::OpenWin"
    ::poImgBrowse::AddMenuCmd $settMenu "Image browser ..." "" "::poImgBrowse::OpenWin"
    ::poImgBrowse::AddMenuCmd $settMenu "Save settings"     "" "::poImgBrowse::SaveToFile"

    set helpMenu $hMenu.help
    menu $helpMenu -tearoff 0
    AddMenuCmd $helpMenu "Content"            "F1" "::poImgBrowse::HelpCont $tw"
    AddMenuCmd $helpMenu "About poImgBrowse ..." ""   ::poImgBrowse::HelpProg
    AddMenuCmd $helpMenu "About Tcl/Tk ..."      ""   ::poImgBrowse::HelpTcl
    bind $tw <Key-F1>  HelpCont

    # Make the menus available
    $tw configure -menu $hMenu

    # Add new toolbar group and associated buttons.
    set btnFrame [::poToolbar::AddGroup $fr.toolfr]

    ::poToolbar::AddButton $btnFrame.new [::poBmpData::open] \
                           "::poImgBrowse::OpenFiles $tw $tableId $selFunc" \
                           [Str OpenFile] -activebackground white
    ::poToolbar::AddButton $btnFrame.del [::poBmpData::delete] \
                           "::poImgBrowse::AskDelFile $tw $tableId" \
                           [Str DelFile] -activebackground red
    ::poToolbar::AddButton $btnFrame.ren [::poBmpData::rename] \
                           "::poImgBrowse::AskRenameFile $tw $tableId" \
                           [Str RenameFile] -activebackground white

    # Add new toolbar group and associated widgets.
    set filterFrame [::poToolbar::AddGroup $fr.toolfr]
    label $filterFrame.str -text "Filter:"
    pack $filterFrame.str -side left
    entry $filterFrame.pre -width 10 \
                           -textvariable ::poImgBrowse::pkgOpt(prefixFilter)
    ::poToolhelp::AddBinding $filterFrame.pre "Image prefix"
    pack $filterFrame.pre -side left
    ::combobox::combobox $filterFrame.suf -editable 0 -relief sunken -width 10
    set fmtList [list $pkgInt(allFiles) $pkgInt(allImgs)]
    set fmtInd 0
    set curInd 2
    foreach fmt [::poImgtype::GetFmtList] {
        lappend fmtList $fmt
        if { [string compare $fmt $pkgOpt(suffixFilter)] == 0 } {
            set fmtInd $curInd
        }
        incr curInd
    }
    UpdateCombo $filterFrame.suf $fmtList $fmtInd
    $filterFrame.suf select $fmtInd
    $filterFrame.suf configure -command "::poImgBrowse::ComboCB $tw"
    ::poToolhelp::AddBinding $filterFrame.suf "Image format"
    pack $filterFrame.suf -side left
    ::poToolbar::AddButton $filterFrame.upd [::poBmpData::update] \
                           "::poImgBrowse::ShowFileList $tw" \
                           [Str UpdateList] -activebackground white
    bind $tw <Key-F5> "::poImgBrowse::ShowFileList $tw"

    frame $rf.tblfr.tabfr -relief raised
    pack $rf.tblfr.tabfr -fill both -expand 1

    set treeId [::poImgBrowse::CreateTree $lf.pane.dirfr $dirName $tw]
    set pkgOpt(lastDir) $dirName

    label $lf.pane.icofr.ltxt
    pack  $lf.pane.icofr.ltxt
    frame $lf.pane.icofr.fr -relief sunken -borderwidth 2
    pack  $lf.pane.icofr.fr -fill both -expand 1
    label $lf.pane.icofr.fr.limg
    pack  $lf.pane.icofr.fr.limg
    set pkgInt($tw,previewPar) $lf.pane.icofr.fr
    set pkgInt($tw,previewTxt) $lf.pane.icofr.ltxt
    set pkgInt($tw,previewImg) $lf.pane.icofr.fr.limg

    $tw configure -cursor watch
    update

    upvar ::poImgBrowse::TblArr$winId tblArr
    set tblArr(0,$pkgCol(Ind))    "Index"
    set tblArr(0,$pkgCol(Img))    "Image"
    set tblArr(0,$pkgCol(Name))   "Filename"
    set tblArr(0,$pkgCol(Type))   "Type"
    set tblArr(0,$pkgCol(Size))   "Size (kB)"
    set tblArr(0,$pkgCol(Date))   "Date"
    set tblArr(0,$pkgCol(Width))  "Width"
    set tblArr(0,$pkgCol(Height)) "Height"

    set colInf(size,Ind)     5
    set colInf(size,Img)    -1  ;# Will be set automatically based on thumb size
    set colInf(size,Name)   20
    set colInf(size,Type)    8
    set colInf(size,Size)    9
    set colInf(size,Date)   16
    set colInf(size,Width)   6
    set colInf(size,Height)  6

    set colInf(anch,Ind)     e
    set colInf(anch,Img)     center
    set colInf(anch,Name)    w
    set colInf(anch,Type)    w
    set colInf(anch,Size)    e
    set colInf(anch,Date)    w
    set colInf(anch,Width)   e
    set colInf(anch,Height)  e

    set noCols 8
    set pkgInt(sortModeList) [list real ascii ascii ascii real dictionary real real]

    table $tableId \
        -rows 1 \
        -cols $noCols \
        -variable ::poImgBrowse::TblArr$winId \
        -titlerows 1 \
        -titlecols 1 \
        -maxheight 500 \
        -maxwidth  400 \
        -invertselected 1 \
        -colstretch unset \
        -rowstretch none \
        -resizeborders col \
        -selecttype cell \
        -selecttitle 0 \
        -state disabled \
        -cursor top_left_arrow \
        -exportselection 0 \
        -selectmode extended \
        -takefocus 1 \
        -browsecommand "::poImgBrowse::SelectionCB $tw %W %S" \
        -xscrollcommand "$sx set" \
        -yscrollcommand "$sy set"

    foreach colAnch [array names colInf "anch,*"] {
        set colName [lindex [split $colAnch ","] 1]
        $tableId tag col $colName $pkgCol($colName)
        $tableId tag configure $pkgCol($colName) -anchor $colInf(anch,$colName)
    }

    foreach colSize [array names colInf "size,*"] {
        set colName [lindex [split $colSize ","] 1]
        $tableId width $pkgCol($colName) $colInf(size,$colName)
    }

    if { ! $pkgOpt(showThumb) } {
        $tableId width $pkgCol(Img) 0
    } else {
        $tableId width $pkgCol(Img) [expr -1 * $pkgOpt(thumbSize)]
    }
    if { ! $pkgOpt(showFileType) } {
        $tableId width $pkgCol(Type) 0
    }
    if { ! $pkgOpt(showFileInfo) } {
        $tableId width $pkgCol(Size) 0
        $tableId width $pkgCol(Date) 0
    }
    if { ! $pkgOpt(showImgInfo) } {
        $tableId width $pkgCol(Width)  0
        $tableId width $pkgCol(Height) 0
    }

    scrollbar $sy -command [list ::poImgBrowse::yScrollImgTable $tw $tableId]
    scrollbar $sx -command [list $tableId xview] -orient horizontal

    grid $tableId $sy -sticky news 
    grid $sx -sticky ew
    grid columnconfigure $rf.tblfr.tabfr 0 -weight 1
    grid rowconfigure    $rf.tblfr.tabfr 0 -weight 1  

    # Overwrite Tktable's default bindings for mouse button 3
    bind Table <Shift-ButtonPress-3> {
        %W border mark %x %y
    }
    bind Table <Shift-B3-Motion> { %W border dragto %x %y }

    bind $tableId <ButtonPress-3> \
               "::poImgBrowse::OpenContextMenu $tw %W %X %Y $selFunc"
    bind Table <B3-Motion> {}

    bind $tableId <Double-1> "::poImgBrowse::OpenFiles $tw $tableId $selFunc"
    bind $tableId <Return>   "::poImgBrowse::OpenFiles $tw $tableId $selFunc"
    bind $tableId <KeyRelease-Down>  "::poImgBrowse::SelectionCB $tw $tableId 1"
    bind $tableId <KeyRelease-Up>    "::poImgBrowse::SelectionCB $tw $tableId 1"
    bind $tableId <KeyRelease-Left>  "::poImgBrowse::SelectionCB $tw $tableId 1"
    bind $tableId <KeyRelease-Right> "::poImgBrowse::SelectionCB $tw $tableId 1"

    bind $tw <Control-a> "$tableId selection set origin end"
    bind $tw <KeyPress-Escape> { ::poImgBrowse::StopBrowsing }
    bind $tw <Motion> "::poImgBrowse::StoreCurMousePos $tw %W %x %y %X %Y"

    label $fr.infofr.label -text "No files selected" -anchor w
    pack  $fr.infofr.label -side top -fill x

    set pkgInt(infoId,$tw)  $fr.infofr.label
    set pkgInt(tableId,$tw) $tableId
    set pkgInt(treeId,$tw)  $treeId
    $tw configure -cursor top_left_arrow
    update

    if { [file isdirectory $dirName] } {
        ::poImgBrowse::ShowFileList $tw
    } else {
        ::poImgBrowse::WriteInfoStr $tw "Directory $dirName does not exist."
        wm title $tw "No directory selected"
    }
}

proc ::poImgBrowse::PrintInfo { tw tbl row } {
    variable pkgInt
    variable pkgCol

    set dirName [::poImgBrowse::GetCurImgDir $tw]
    set fileName [file join $dirName [$tbl get $row,$pkgCol(Name)]]

    ::poImgBrowse::PreviewFunc $fileName $tw
    catch { unset pkgInt(afterId) }
}

proc ::poImgBrowse::StoreCurMousePos { tw tbl x y X Y } {
    variable pkgInt

    set pkgInt(mouse,x) $X
    set pkgInt(mouse,y) $Y

    if { [info exists pkgInt(afterId)] } {
        after cancel $pkgInt(afterId)
    }

    if { [winfo class $tbl] == "Table" } {
        set row [lindex [split [$tbl index @$x,$y] ","] 0]
        if { $row < 1 } {
            return
        }

        set pkgInt(afterId) \
            [after 500 ::poImgBrowse::PrintInfo $tw $tbl $row]
    }
}

proc ::poImgBrowse::WriteInfoStr { tw str } {
    variable pkgInt

    $pkgInt(infoId,$tw) configure -text $str
}

###########################################################################
#[@e
#       Name:           ::poImgBrowse::LoadFromFile
#
#       Usage:          Load settings for image browser window from a file.
#
#       Synopsis:       proc ::poImgBrowse::LoadFromFile { { fileName "" } }
#
#       Description:    fileName: String (default: "")
#
#                       Load association rules from file "fileName". If 
#                       "fileName" is empty, then the function tries to read
#                       file "~/poImgBrowse.cfg".
#
#                       Note: "~" (the user's home directory on Unix systems)
#                             is typically mapped to "C:\" on Win9x systems.
#
#       Return Value:   true / false.
#
#       See also:       ::poImgBrowse::OpenWin
#                       ::poImgBrowse::SaveToFile
#
###########################################################################

proc ::poImgBrowse::LoadFromFile { { fileName "" } } {
    variable pkgOpt
    variable winGeom

    if { [string compare $fileName ""] == 0 } {
        set cfgFile [::poMisc::GetCfgFile poImgBrowse] 
    } else {
        set cfgFile $fileName
    }
    if { [file readable $cfgFile] } {
        source $cfgFile
        return 1
    } else {
        ::poLog::Warning "Could not read cfg file $cfgFile"
        return 0
    }
}

###########################################################################
#[@e
#       Name:           ::poImgBrowse::SaveToFile
#
#       Usage:          Save settings for image browser to a file.
#
#       Synopsis:       proc ::poImgBrowse::SaveToFile { { fileName "" } }
#
#       Description:    fileName: String (default: "")
#
#                       Store image browser settings to file "fileName". If 
#                       "fileName" is empty, then the function tries to write
#                       file "~/poImgBrowse.cfg".
#
#                       Note: "~" (the user's home directory on Unix systems)
#                             is typically mapped to "C:\" on Win9x systems.
#
#       Return Value:   true / false.
#
#       See also:       ::poImgBrowse::OpenWin
#                       ::poImgBrowse::LoadFromFile
#
###########################################################################

proc ::poImgBrowse::SaveToFile { { fileName "" } } {
    variable pkgInt
    variable pkgOpt
    variable winGeom

    if { [string compare $fileName ""] == 0 } {
        set cfgFile [::poMisc::GetCfgFile poImgBrowse] 
    } else {
        set cfgFile $fileName
    }
    set retVal [catch {open $cfgFile w} fp]
    if { $retVal != 0 } {  
        error "Cannot write to cfg file $cfgFile"
        return 0
    }

    foreach opt [array names pkgOpt] {
        puts $fp "set pkgOpt($opt) \{$pkgOpt($opt)\}"
    }
    if { [winfo exists $pkgInt(settWin)] } {
        puts $fp "set winGeom(sett,x) \{[winfo x $pkgInt(settWin)]\}"
        puts $fp "set winGeom(sett,y) \{[winfo y $pkgInt(settWin)]\}"
    } else {
        puts $fp "set winGeom(sett,x) \{$winGeom(sett,x)\}"
        puts $fp "set winGeom(sett,y) \{$winGeom(sett,y)\}"
    }

    set foundOpenWin 0
    foreach elem [lsort -decreasing -dictionary [array names pkgInt "winId,*"]] {
        set winName [split $elem ","]
        if { [winfo exists $winName] } {
            puts $fp "set winGeom(main,x) \{[winfo x $winName]\}"
            puts $fp "set winGeom(main,y) \{[winfo y $winName]\}"
            puts $fp "set winGeom(main,w) \{[winfo width  $winName]\}"
            puts $fp "set winGeom(main,h) \{[winfo height $winName]\}"
            set foundOpenWin 1
            break
        }
    }
    if { ! $foundOpenWin } {
        puts $fp "set winGeom(main,x) \{$winGeom(main,x)\}"
        puts $fp "set winGeom(main,y) \{$winGeom(main,y)\}"
        puts $fp "set winGeom(main,w) \{$winGeom(main,w)\}"
        puts $fp "set winGeom(main,h) \{$winGeom(main,h)\}"
    }
    close $fp
    return 1
}

::poImgBrowse::Init

if { [file tail [info script]] == [file tail $::argv0] && \
     ![info exists PO_ONE_SCRIPT] } {
    # Start as standalone program.
    set ::poImgBrowse::pkgInt(standAlone) 1
    ::poImgBrowse::LoadFromFile
    set dirName [pwd]
    if { $::argc >= 1 && [file isdirectory [lindex $::argv 0]]} {
        set dirName [lindex $::argv 0]
    }
    wm withdraw .
    ::poImgBrowse::OpenDir $dirName
} else {
    # Load as a package.
    set ::poImgBrowse::pkgInt(standAlone) 0
    catch {puts "Loaded Package poTklib (Module [info script])"}
}

############################################################################
# Original file: poTklib/poImgData.tcl
############################################################################

package provide poTklib 1.0
package provide poImgData 1.0

namespace eval ::poImgData {
    namespace export cdromdrive16
    namespace export closedfolder16
    namespace export diskdrive16
    namespace export floppydrive16
    namespace export openfolder16
    namespace export poLogo100_text
    namespace export poLogo100_text_flip
    namespace export poLogo200_text
    namespace export poLogo200_text_compr
    namespace export poLogo200_text_flip
    namespace export pwrdLogo200
}

proc ::poImgData::cdromdrive16 {} {
return {
R0lGODlhEAAQALMAAAD/AACAAMDAwAD//4CAgP//AAAAAP///wAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAACH5BAkIAAgALAAAAAAQABAAAARTEMk5iaVY2lLE
zQgxDJxgGiABkJ1woBghAABhEMcZm4DxmgJYBWgT6SxImctUGBQPUKgsx7OF
qERl0IDCAQLccNjTpUahQHIoyU7CxHAxaE6vRwAAOw==}
} ; # End of proc ::poImgData::cdromdrive16

proc ::poImgData::closedfolder16 {} {
return {
R0lGODlhEAAQALMAAICAgAAAAMDAwP//AP///////////////wAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAACH5BAkIAAgALAAAAAAQABAAAAQ9EMlJKwUY2ytG
F8CGAJ/nZZkEEGzrskAwEmZZxrNdn/K667iVzhakDU3F46f42wVRUJQMEaha
r1eRdluJAAA7}
} ; # End of proc ::poImgData::closedfolder16

proc ::poImgData::diskdrive16 {} {
return {
R0lGODlhEAAQALMAAACAAAAAAMDAwICAgP///////////////wAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAACH5BAkIAAgALAAAAAAQABAAAAQxEMlJq7046z26
/540CGRpkkMwEGzrsp16noAQj/N52+DHy6/Xr0dMSQLIpDK5aTqfEQA7}
} ; # End of proc ::poImgData::diskdrive16

proc ::poImgData::floppydrive16 {} {
return {
R0lGODlhEAAQALMAAICAgP8AAMDAwAAAAP///////////////wAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAACH5BAkIAAgALAAAAAAQABAAAAQ2EMlJq704V8C7
7xIgjGQ5AgNArGy7cqlpBgIskl5p1/Dgd7wYqaVDfY6dgcTHbDY10Kh0aokA
ADs=}
} ; # End of proc ::poImgData::floppydrive16

proc ::poImgData::openfolder16 {} {
return {
R0lGODlhEAAQALMAAMDAwP//AICAgAAAAP///////////////wAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAACH5BAkIAAgALAAAAAAQABAAAARFEMlJKxUY20t6
FxsiEEBQAkSWSaPpol46iORrA8Kg7mqQj7FgDqernWy6HO3I/M1azJduRru5
clQeb0BFcL9gcGhMrkQAADs=}
} ; # End of proc ::poImgData::openfolder16

proc ::poImgData::poLogo100_text {} {
return {
R0lGODdhZABUAPcAAAAAAAEBAQUFBQ8PDyQkJERERGhoaIODg4iIiHZ2dlRU
VDIyMhgYGAkJCQMDAwsLCxwcHDs7O2VlZYyMjJ+fn5aWlnV1dUpKSiYmJhAQ
EEZGRm1tbYeHh0BAQCEhIQ4ODgwMDB8fH2tra5KSkqSkpJmZmUtLSwQEBCMj
I5CQkKGhoZeXl3l5eVFRUS0tLRUVFQgICAICAiIiIkVFRXFxcaioqJubmx4e
Hj09PWZmZo2NjaampqWlpYuLi2RkZDw8PCUlJUlJSampqZqamnR0dEhISDMz
M1lZWaKioqurq01NTSkpKRISEgYGBnh4eJycnHBwcA0NDREREScnJ3Nzc6ys
rF1dXTU1NRkZGUxMTKenp5WVlUJCQiAgIB0dHTo6OmJiYpSUlGxsbEFBQQcH
BxQUFFJSUn19faCgoK2trXp6ek9PTyoqKnd3d29vb0NDQ1xcXDQ0NJiYmHJy
cgoKChsbGzk5OT4+Pi8vL1ZWVoKCgq6urm5ubp2dnX9/f1NTUxMTE5OTk4qK
il5eXj8/P05OTigoKImJiWlpaXx8fH5+fkdHR1BQUI6OjoGBgYWFhaqqqp6e
nnt7eysrK4CAgCwsLI+Pjy4uLhoaGjg4OGNjY1dXVzY2Nl9fX2FhYTc3N6Oj
ozExMTAwMFtbWxYWFoaGhlpaWmBgYJGRkVVVVYSEhBcXF1hYWGdnZ2pqaq+v
r8bGxv///+Li4ra2tr6+vszMzMPDw8rKytbW1tDQ0Li4uLS0tM7OztjY2NPT
08HBwc3NzcXFxbq6usjIyLOzs7m5ub+/v729vbW1tbe3t7KysrCwsLGxsf//
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////yH5BAAAAAAALAAAAABkAFQAQAj/AAEIHEiwYEEB
BAwgUMDAgcGHECNKLPggwoQKFzIEmMix40MHXnLwcISHjMeTHQNE0TCEghKN
KGNKVFlgRZ9CUjbK3Enxy4QdmiA45ClTgAcwKiJ18tCEqFODDkitWQGqFQaT
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}
} ; # End of proc ::poImgData::poLogo100_text

proc ::poImgData::poLogo100_text_flip {} {
return {
R0lGODdhZABUAPcAANjY2NbW1ri4uLe3t9DQ0M7OzsHBwb+/v8rKysjIyLOz
s7Kysr29vbq6ur6+vrGxsczMzNPT07W1tWZmZmVlZTw8PDs7O8XFxcPDw21t
bWxsbEJCQkFBQVFRUVBQUIeHh4aGhpGRkZCQkEVFRURERGFhYWBgYK+vr35+
fn19fZeXl5aWll5eXl1dXYKCgoGBgSgoKCcnJ5+fn56enhwcHBsbGzQ0NDMz
MxQUFBMTE3Z2dnV1dWRkZElJSUhISHBwcG9vb6enp6ampq6urkBAQI+Pj2tr
a4CAgC4uLi0tLZWVlSYmJlxcXDk5OSIiIiEhIYyMjIuLi5ubm5qamk5OTq2t
rXt7e4SEhKKioqGhoUdHR2NjYxoaGhcXFxYWFjExMXNzc6ysrKWlpSUlJSAg
ID4+PpmZmZOTk1paWqurq2hoaOLi4jg4OExMTFVVVVNTU4mJiSoqKnl5eR4e
HqqqqjY2Nqmpqf///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD0AGwAQABAA
+0H3v9gEAABcTvW/BNsBAAAAAAAAAAAACAAAAET0cAAAAAAAIAAAADCEyYC/
FU8GVwAAAD0AGwAAAAAAEAAQABAAEACUhAAAAAAAAFigIAAAAAAAOgAYABAA
AAD2GAAAdkUAACYY978AAAAAAwADAOxC+b+4Gfe/NIRwAND4cAB0hAAAH5EX
BZT0hwbkI6cGIADMABEAEAAAAAAAAAB3RT0AGwAAADYgEQBG9IcGgBaHA3AE
QAEbAD0AKwBOABsAPQArAE4A97+jAsDAwACWFOQjAAAAABAAEQDmGMr7lPSH
BgAAqPRwAKwAAAAcAQAAZGFRAJGj978AAE4AgGJRAKwAAAAAAAAADABOAAAA
TgBkYVEAQAAAAAAAAAAWBQAAFwUAAND0cABBpfe/AABOAFil978AAE4AQQAA
AEEAAAAAAAAAmWFRAAAAAAAAAAAA5JFDAJlhUQAUok8AaGFRAJ1hUQCp93AA
/////wAAAABgkkMAmWFRACH5BAAAAAAALAAAAABkAFQAQAj/APEIHEiwoEGB
S3bIoEDjoMOHECPiyXFDhwsSOSRq3EgwhpwqYJxwHKkRhxsZRSyQXPkwh4Uo
QbY0ZEmzoEc6P0TWXImDBMwdSHYKNZijwgs6H8pkHFqQohUhcDYsZUrVoRMj
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
GZGAAAA7}
} ; # End of proc ::poImgData::poLogo100_text_flip

proc ::poImgData::poLogo200_text {} {
return {
R0lGODdhyACpAPcAAAAAAAEBAQUFBQ8PDyQkJERERGhoaIODg4iIiHZ2dlRU
VDIyMhgYGAkJCQMDAwsLCxwcHDs7O2VlZYyMjJ+fn5aWlnV1dUpKSiYmJhAQ
EEZGRm1tbYeHh0BAQCEhIQ4ODgwMDB8fH2tra5KSkqSkpJmZmUtLSwQEBCMj
I5CQkKGhoZeXl3l5eVFRUS0tLRUVFQgICAICAiIiIkVFRXFxcaioqJubmx4e
Hj09PWZmZo2NjaampqWlpYuLi2RkZDw8PCUlJUlJSampqZqamnR0dEhISDMz
M1lZWaKioqurq01NTSkpKRISEgYGBnh4eJycnHBwcA0NDREREScnJ3Nzc6ys
rF1dXTU1NRkZGUxMTKenp5WVlUJCQiAgIB0dHTo6OmJiYpSUlGxsbEFBQQcH
BxQUFFJSUn19faCgoK2trXp6ek9PTyoqKnd3d29vb0NDQ1xcXDQ0NJiYmHJy
cgoKChsbGzk5OT4+Pi8vL1ZWVoKCgq6urm5ubp2dnX9/f1NTUxMTE5OTk4qK
il5eXj8/P05OTigoKImJiWlpaXx8fH5+fkdHR1BQUI6OjoGBgYWFhaqqqp6e
nnt7eysrK4CAgCwsLI+Pjy4uLhoaGjg4OGNjY1dXVzY2Nl9fX2FhYTc3N6Oj
ozExMTAwMFtbWxYWFoaGhlpaWmBgYJGRkVVVVYSEhBcXF1hYWGdnZ2pqaq+v
r8bGxv///+Li4ra2tr6+vszMzMPDw8rKytbW1tDQ0Li4uLS0tM7OztjY2NPT
08HBwc3NzcXFxbq6usjIyLOzs7m5ub+/v729vbW1tbe3t7KysrCwsLGxsf//
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////ywAAAAAyACpAAAI/wABCBxIsKDBgwgHBhAwgEAB
AwcQJFCwgEEDBwkTJkyYMGHChAkTOngAIYKECRQqWLiAIYOAAAkTJkyYMGHC
hAkBBBAwgICGDRMqcJDQwcMHAQESJkyYMGHChAkTInQAIkQHESNIlEhgAkMG
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
Ow==}
} ; # End of proc ::poImgData::poLogo200_text

proc ::poImgData::poLogo200_text_compr {} {
return {
R0lGODdhyACpAPYAANjY2NbW1ri4uLe3t9DQ0M7OzsHBwb+/v8rKysjIyLOz
s7Kysr29vbq6ur6+vrGxsczMzNPT07W1tWZmZmVlZTw8PDs7O8XFxcPDw21t
bWxsbEJCQkFBQVFRUVBQUIeHh4aGhpGRkZCQkEVFRURERGFhYWBgYK+vr35+
fn19fZeXl5aWll5eXl1dXYKCgoGBgSgoKCcnJ5+fn56enhwcHBsbGzQ0NDMz
MxQUFBMTE3Z2dnV1dWRkZElJSUhISHBwcG9vb6enp6ampq6urkBAQI+Pj2tr
a4CAgC4uLi0tLZWVlSYmJlxcXDk5OSIiIiEhIYyMjIuLi5ubm5qamk5OTq2t
rXt7e4SEhKKioqGhoUdHR2NjYxoaGhcXFxYWFjExMXNzc6ysrKWlpSUlJSAg
ID4+PpmZmZOTk1paWqurq2hoaOLi4jg4OExMTFVVVVNTU4mJiSoqKnl5eR4e
HqqqqjY2Nqmpqf///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAAyACp
AEYH/oB4goOEhYaHiIU5TiRqLh86bjddiZWWl5iZmok5XBYUUDIrOz1LOZuo
qaqpOWQbQCpDQh9Mk6eruLm6gjhjPTtSQSpgI2O3u8jJmDlzFhNFQjJHbkg4
ytfYhDlPWmBmYTJWbabZ5dk5XhUUIkJYLtTW5vK4nRXP0dPV8/u5zK8qdGZY
8RDjGL+Dy7pY2AJFiBAoW5rQMIiwoiIaGzKECOIOzQ0vFC2KRETDAgsQWNLM
SOHmi5eR/JiV2QIiCx0ZLkxYeBISpk9EOXIk8aBjhR0xUSZsWALyp65WG9QU
CUJHCZARTno63XppEYctH7CEyfKhBBFjXC0tGpHhTBo6/iLUcMiatm6/HGM2
TICTRYgZOZK44NEqsgsMombETJHTIclLu5CTBSVTAayYKlg+8OAwJp7FRb+k
DMHyAl7k0+VO0WBjIgrVEBMq0DgYNEkHFGLN/MBKGPVICwnuCB8u3E2ykhSm
BolSgg2X3rtwxKBiZUYYKWC0oMVEvLv3O2tmFzpBfA2d8+UPDa9xiI3wH4bo
lD8vf/gaQzu+d4eCSH/3Sr30oINoMsjRRkHmMDMCGFKcgAUKbyQBXSFrvEdS
hXfAJ8hwlbgnHBuDQFFcIheMOAiHiXh4B4iGFCEcf5q4IRwdqqBzAxMfiCFE
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
QgJvgAZtUAfNnQmBAAA7}
} ; # End of proc ::poImgData::poLogo200_text_compr

proc ::poImgData::poLogo200_text_flip {} {
return {
R0lGODdhyACpAPYAANjY2NbW1ri4uLe3t9DQ0M7OzsHBwb+/v8rKysjIyLOz
s7Kysr29vbq6ur6+vrGxsczMzNPT07W1tWZmZmVlZTw8PDs7O8XFxcPDw21t
bWxsbEJCQkFBQVFRUVBQUIeHh4aGhpGRkZCQkEVFRURERGFhYWBgYK+vr35+
fn19fZeXl5aWll5eXl1dXYKCgoGBgSgoKCcnJ5+fn56enhwcHBsbGzQ0NDMz
MxQUFBMTE3Z2dnV1dWRkZElJSUhISHBwcG9vb6enp6ampq6urkBAQI+Pj2tr
a4CAgC4uLi0tLZWVlSYmJlxcXDk5OSIiIiEhIYyMjIuLi5ubm5qamk5OTq2t
rXt7e4SEhKKioqGhoUdHR2NjYxoaGhcXFxYWFjExMXNzc6ysrKWlpSUlJSAg
ID4+PpmZmZOTk1paWqurq2hoaOLi4jg4OExMTFVVVVNTU4mJiSoqKnl5eR4e
HqqqqjY2Nqmpqf///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAAyACp
AEYH/oB4goOEhYaHiIk5Sz07KzJQFBY0OYmWl5iZmpuIOTg3bjofLmokY5Wc
qaqrmzlPI2AqQVM7PaesuLm6gzldNkwfYlUqP6aou8jJl14xVHIzVVNgI07H
ytfYnkhuRzJCRROT2OPkeDlJ3N5FFBU05e+6XOguWEHrFVzW8PutXRZbUYQE
gbJlkj5+CC/laPaMDjFqBxNKNNfli5sUM9JgAcGCDaWJIDHlyPEFDb0gSjJs
eBIxJDYcY0hMiFJPxQ4PSHC43KlpJJkKJl7MoIPlQ4ky1VryzJSDDJESIGRU
KUqBw62lWFXlGDMigxI69tRsqJZVEQ1QVlQIwQJnwoYl/krLytWEwwkRIyLs
pEk54lRchHU58PiAZeqHLRVYzl2srFeSDnKmCDGjw0OSv+OaVlATwk6QKCbY
5GNMupyXbS+wDJGiowdcfp6amIgSxE4RHu2SubnDuzfvBBZKz2264YcZjUc6
xMGcC2YbOVJnyLEV17d134iKXL/+w9Aa33TAfu+dxtAO3mwO0eh9aDzv8EHc
3ylfaI787dZ7OtECRkoVGVZQAQNzrHBRhwlwiCHGB0x8gQOBhdDBmxucQMEb
FIew0VsTlrA3yG53XJAIiBgKoiFvHCbiIR4/8LaGO4e0eMcareQQxxtHiLHa
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
YAIZYARvYANbzBinIWQukAJc+tOJEAgAOw==}
} ; # End of proc ::poImgData::poLogo200_text_flip

proc ::poImgData::pwrdLogo200 {} {
return {
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
LvOc1AmdqDmV1ZmdwhmW6aGd3vmdSxAEADs=}
} ; # End of proc ::poImgData::pwrdLogo200


catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poImgUtil.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poImgtype
#       Copyright:      Paul Obermeier 2001-2003 / paul@poSoft.de
#       Filename:       poImgtype.tcl
#
#       First Version:  2001 / 03 / 01
#       Author:         Paul Obermeier
#
#       Description:	
#			OPa Todo
#
#       Additional documentation:
#
#			None.
#
#       Exported functions:
#    			::poImgtype::OpenWin
#
############################################################################

package provide poTklib 1.0
package provide poImgUtil 1.0

namespace eval ::poImgUtil {
    namespace export Rotate
}

proc poImgUtil::Rotate { img angle } {
    set w [image width  $img]
    set h [image height $img]

    switch -- $angle {
        180 {
            set tmp [image create photo -width $w -height $h]
            $tmp copy $img -subsample -1 -1
            return $tmp
        }
        90 - -90 {
            set tmp [image create photo -width $h -height $w]
            set matrix [string repeat "{[string repeat {0 } $h]} " $w]
            if { $angle == -90 } {
                set x0 0; set y [expr {$h-1}]; set dx 1; set dy -1
            } else {
                set x0 [expr {$w-1}]; set y 0; set dx -1; set dy 1
            }
            foreach row [$img data] {
                set x $x0
                foreach pixel $row {
                    lset matrix $x $y $pixel
                    incr x $dx
                }
                incr y $dy
            }
            $tmp put $matrix
            return $tmp
        }
        default {
            return $img
        }
    }
}

############################################################################
# Original file: poTklib/poImgtype.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poImgtype
#       Copyright:      Paul Obermeier 2001-2003 / paul@poSoft.de
#       Filename:       poImgtype.tcl
#
#       First Version:  2001 / 03 / 01
#       Author:         Paul Obermeier
#
#       Description:	
#			OPa Todo
#
#       Additional documentation:
#
#			None.
#
#       Exported functions:
#    			::poImgtype::OpenWin
#    			::poImgtype::GetSelBoxTypes
#    			::poImgtype::GetFmtList
#    			::poImgtype::GetExtList
#    			::poImgtype::GetOptByExt
#    			::poImgtype::GetOptByFmt
#    			::poImgtype::LoadFromFile
#    			::poImgtype::SaveToFile
#    			::poImgtype::ChangedOpts
#			::poImgtype::CheckAniGifIndex
#			::poImgtype::CheckIcoIndex
#    			::poImgtype::Test
#
############################################################################

package provide poTklib 1.0
package provide poImgtype 1.0

namespace eval ::poImgtype {
    namespace export OpenWin
    namespace export GetSelBoxTypes
    namespace export GetFmtList
    namespace export GetExtList
    namespace export GetOptByExt
    namespace export GetOptByFmt
    namespace export LoadFromFile
    namespace export SaveToFile
    namespace export ChangedOpts
    namespace export CheckAniGifIndex
    namespace export CheckIcoIndex
    namespace export GetExifInfo

    namespace export Test

    variable sett
    variable curType
    variable langStr
    variable curLang
}

proc ::poImgtype::GetFmtList {} {
    variable sett

    return $sett(imgFmtList)
}

proc ::poImgtype::GetExtList { { fmt "" } } {
    variable sett

    set retList {}
    if { [string compare $fmt ""] == 0 } {
	foreach fmt $sett(imgFmtList) {
	    set extList $sett($fmt,extension)
	    foreach ext $extList {
		lappend retList $ext
	    }
	}
	return [lsort -unique $retList]
    } else {
	return $sett($fmt,extension)
    }
}

proc ::poImgtype::RestoreOptValues { fmt } {
    variable sett

    set sett($fmt,extension) $sett($fmt,ext)
    foreach opt $sett($fmt,read) {
	if { $opt == {} } {
	    break
	}
	set useOpt  [lindex $opt 0]
	set optName [lindex $opt 1]
	set optVal  [lindex $opt 3]
	set sett($fmt,read,$optName,useOpt) $useOpt
	set sett($fmt,read,$optName,optVal) $optVal
    }
    foreach opt $sett($fmt,write) {
	if { $opt == {} } {
	    break
	}
	set useOpt  [lindex $opt 0]
	set optName [lindex $opt 1]
	set optVal  [lindex $opt 3]
	set sett($fmt,write,$optName,useOpt) $useOpt
	set sett($fmt,write,$optName,optVal) $optVal
    }
}

proc ::poImgtype::RestoreAllOptValues {} {
    variable sett

    foreach fmt $sett(imgFmtList) {
    	::poImgtype::RestoreOptValues $fmt
    }
}

proc ::poImgtype::SetOptValues { fmt } {
    variable sett

    set sett($fmt,ext) $sett($fmt,extension)
    set newOptList {}
    foreach opt $sett($fmt,read) {
	if { $opt == {} } {
	    lappend newOptList [list]
	    break
	}
	set optName [lindex $opt 1]
	set optType [lindex $opt 2]
	set useOpt $sett($fmt,read,$optName,useOpt)
	set optVal $sett($fmt,read,$optName,optVal)

	set newOpt [lreplace $opt 0 3 $useOpt $optName $optType $optVal]
	lappend newOptList $newOpt
    }
    set sett($fmt,read) $newOptList

    set newOptList {}
    foreach opt $sett($fmt,write) {
	if { $opt == {} } {
	    lappend newOptList [list]
	    break
	}
	set optName [lindex $opt 1]
	set optType [lindex $opt 2]
	set useOpt $sett($fmt,write,$optName,useOpt)
	set optVal $sett($fmt,write,$optName,optVal)

	set newOpt [lreplace $opt 0 3 $useOpt $optName $optType $optVal]
	lappend newOptList $newOpt
    }
    set sett($fmt,write) $newOptList
}

proc ::poImgtype::SetAllOptValues {} {
    variable sett

    foreach fmt $sett(imgFmtList) {
    	::poImgtype::SetOptValues $fmt
    }
}

proc ::poImgtype::ChangedOpts { } {
    variable sett
    
    return $sett(changed)
}

proc ::poImgtype::GetShroudVal { } {
    variable sett
    
    if { $sett(optShroud) && [string compare $sett(shroudVal) ""] != 0 } {
	return $sett(shroudVal)
    }
    return 0
}

proc ::poImgtype::SetShroudOpt { onOff } {
    variable sett
    
    set sett(optShroud) $onOff
}

proc ::poImgtype::AddType { fmt fmtName extList readOptList writeOptList } {
    variable sett

    if { ! [info exists sett(imgFmtList)] } {
	set sett(imgFmtList) {}
    }
    if { [lsearch -exact $sett(imgFmtList) $fmt] < 0 } {
	lappend sett(imgFmtList) $fmt
    }

    set sett($fmt,tip)   $fmtName
    set sett($fmt,ext)   $extList
    set sett($fmt,read)  $readOptList
    set sett($fmt,write) $writeOptList

    ::poImgtype::RestoreOptValues $fmt
}

proc ::poImgtype::Init {} {
    variable sett
    variable langStr
    variable curLang

    set sett(x) 100
    set sett(y) 100
    set sett(changed) false
    set sett(optToShow) "read"
    set sett(optShroud) 0
    set sett(shroudVal) ""

    AddType BMP "Windows Bitmap" [list .bmp] \
	    [list [list ]] \
            [list [list ]]

    AddType DTED "DTED elevation data" [list .dt0 .dt1 .dt2] \
            [list [list 0 -verbose   enum  false true false] \
		  [list 1 -nchan     int   1] \
		  [list 0 -nomap     enum  false true false] \
		  [list 0 -gamma     float 1.0] \
		  [list 0 -min       int   0] \
		  [list 0 -max       int   32767]] \
	    [list [list 0 -verbose   enum  false true false] \
		  [list 1 -nchan     int   1]]

    AddType GIF "Graphics Interchange Format" [list .gif] \
	    [list [list 0 -index int 0]] \
            [list [list ]]

    AddType ICO "Windows Icon Format" [list .ico] \
	    [list [list 0 -index   int   0] \
                  [list 0 -verbose enum  false true false]] \
            [list [list ]]

    AddType JPEG "JPEG" [list .jpg .jpeg .jfif] \
	    [list [list 0 -fast      "" ""] \
	          [list 0 -grayscale "" ""]] \
            [list [list 0 -optimize    "" ""] \
                  [list 0 -grayscale   "" ""] \
		  [list 0 -progressive "" ""] \
                  [list 0 -quality     int 75] \
		  [list 0 -smooth      int 0]]

    AddType PCX "Paint Brush PCX" [list .pcx] \
	    [list [list 0 -verbose     enum false true false]] \
	    [list [list 0 -verbose     enum false true false] \
                  [list 0 -compression enum rle   none rle]]

    AddType PNG "Portable Network Graphics" [list .png] \
	    [list [list ]] \
            [list [list ]]

    AddType PPM "PPM and PGM" [list .ppm .pgm] \
	    [list [list ]] \
            [list [list ]]

    AddType POSTSCRIPT "Postscript" [list .ps] \
	    [list [list 0 -index int   0] \
		  [list 0 -zoom  float 1.0]] \
            [list [list ]]

    AddType RAW "Raw image data" [list .dat .raw] \
            [list [list 1 -useheader enum  true true false] \
		  [list 0 -verbose   enum  false true false] \
		  [list 0 -nchan     int   1] \
		  [list 0 -nomap     enum  false true false] \
		  [list 0 -scanorder enum  TopDown TopDown BottomUp] \
		  [list 0 -byteorder enum  Intel Intel Motorola] \
		  [list 0 -width     int   128] \
		  [list 0 -height    int   128] \
		  [list 0 -gamma     float 1.0] \
		  [list 0 -min       float 0.0] \
		  [list 0 -max       float 255.0] \
		  [list 0 -pixeltype enum  byte byte short float]] \
	    [list [list 1 -useheader enum  true true false] \
		  [list 0 -verbose   enum  false true false] \
		  [list 1 -nchan     int   3] \
                  [list 0 -scanorder enum  TopDown TopDown BottomUp]]

    AddType SGI "SGI native format" [list .bw .int .inta .rgb .rgba] \
	    [list [list 0 -matte       enum true  true false] \
		  [list 0 -verbose     enum false true false]] \
	    [list [list 0 -matte       enum true  true false] \
		  [list 0 -verbose     enum false true false] \
		  [list 0 -compression enum rle   rle  none]]

    AddType SUN "SUN raster format" [list .ras] \
	    [list [list 0 -matte       enum true  true false] \
		  [list 0 -verbose     enum false true false]] \
	    [list [list 0 -matte       enum true  true false] \
		  [list 0 -verbose     enum false true false] \
		  [list 0 -compression enum rle   rle  none]]

    AddType TGA "Truevision format" [list .tga] \
	    [list [list 0 -matte       enum true  true false] \
		  [list 0 -verbose     enum false true false]] \
	    [list [list 0 -matte       enum true  true false] \
		  [list 0 -verbose     enum false true false] \
		  [list 0 -compression enum rle   rle  none]]

    AddType TIFF "Tagged image format" [list .tif .tiff] \
	    [list [list ]] \
            [list [list 0 -compression enum none none jpeg packbits deflate] \
                  [list 0 -byteorder   enum none none bigendian littleendian \
                                                      network smallendian]]

    AddType XBM "X Windows Bitmap" [list .xbm] \
	    [list [list ]] \
            [list [list ]]

    AddType XPM "X Windows Pixmap" [list .xpm] \
	    [list [list ]] \
            [list [list ]]

    AddType POI "poSoft native format" [list .poi .bsh] \
	    [list [list ]] \
            [list [list ]]

    set curLang 0
    array set langStr [list \
	ImgType     { "Image type:" \
		      "Bildtyp:" } \
	ViewSel     { "View select:" \
		      "Ansichts-Auswahl:" } \
	Shroud      { "Encryption:" \
		      "Verschlüsselung:" } \
	FileExt     { "File extension:" \
		      "Datei Endung:" } \
	SelEditor   { "Select editor" \
		      "Editor auswählen" } \
	SelGuiDiff  { "Select graphical diff program" \
		      "Graphisches Diff-Programm auswählen" } \
	MsgSelType  { "Please select a file type first." \
		      "Bitte erst Dateityp auswählen" } \
	MsgNoRename { "You can not rename \"Default type\"." \
		      "Dateityp \"Default type\" kann nicht umbenannt werden." } \
	EnterType   { "Enter file type name" \
		      "Dateityp-Namen eingeben" } \
	TypeExists  { "Filetype %s already exists." \
		      "Dateityp %s existiert bereits." } \
	MsgDelType  { "Delete file type \"%s\"?" \
		      "Dateityp \"%s\" löschen?" } \
	Confirm     { "Confirmation" \
		      "Bestätigung" } \
	WinTitle    { "Image type settings" \
		      "Bildtyp Einstellungen" } \
    ]
}

proc ::poImgtype::Str { key args } {
    variable langStr
    variable curLang

    set str [lindex $langStr($key) $curLang]
    return [eval {format $str} $args]
}

proc ::poImgtype::UpdateCombo { cb typeList showInd } {
    $cb list delete 0 end
    foreach type $typeList {
        $cb list insert end $type
    }
    $cb configure -value [lindex $typeList $showInd]
    $cb select $showInd
}

proc ::poImgtype::CloseWin { w } {
    ::poImgtype::SetAllOptValues
    destroy $w
}

proc ::poImgtype::CancelWin { w args } {
    variable sett

    ::poImgtype::RestoreAllOptValues
    set sett(changed) false
    destroy $w
}

proc ::poImgtype::LoadFileExt {} {
    variable sett
    variable curType

    $sett(fileExt) delete 1.0 end
    foreach ext $sett($curType,extension) {
        $sett(fileExt) insert end "$ext\n"
    }
}

proc ::poImgtype::SaveFileExt {} {
    variable sett
    variable curType

    set fileType $curType
    set widgetCont [$sett(fileExt) get 1.0 end]
    regsub -all {\n} $widgetCont " " extStr
    set extStr [string trim $extStr]
    set sett($fileType,extension) $extStr
}

proc ::poImgtype::GetSelBoxTypes { { firstFmt "" } } {
    variable sett

    set typeList {}
    if { [string compare $firstFmt ""] != 0 && \
         [info exists sett($firstFmt,tip)] } {
	lappend typeList [list $sett($firstFmt,tip) $sett($firstFmt,extension)]
    }
    lappend typeList [list "All files" *]
    foreach fmt $sett(imgFmtList) {
	if { [string compare $firstFmt $fmt] != 0 } {
	    lappend typeList [list $sett($fmt,tip) $sett($fmt,extension)]
	}
    }
    return $typeList
}

proc ::poImgtype::GetFmtByExt { ext } {
    variable sett

    set fmtFound 0
    set ext [string tolower $ext]
    foreach fmt $sett(imgFmtList) {
	set extList $sett($fmt,extension)
	if { [lsearch $extList $ext] >= 0 } {
	    set fmtFound 1
	    break
	}
    }
    if { $fmtFound == 0 } {
	::poLog::Warning "No format found for extension $ext"
	return ""
    }
    return $fmt
}

proc ::poImgtype::GetOptByExt { ext mode } {
    variable sett

    set fmt [::poImgtype::GetFmtByExt $ext]
    return [::poImgtype::GetOptByFmt $fmt $mode]
}

proc ::poImgtype::GetOptByFmt { fmt mode } {
    variable sett

    set optStr ""
    if { [string compare -nocase $mode "write"] == 0 } {
	foreach opt $sett($fmt,write) {
	    if { $opt == {} } {
		return $optStr
	    }
	    set optName [lindex $opt 1]
	    set optType [lindex $opt 2]
	    set useOpt  $sett($fmt,write,$optName,useOpt)
	    set optVal  $sett($fmt,write,$optName,optVal)
	    if { $useOpt } {
		append optStr " $optName $optVal"
	    }
	}
    } else {
	foreach opt $sett($fmt,read) {
	    if { $opt == {} } {
		return $optStr
	    }
	    set optName [lindex $opt 1]
	    set optType [lindex $opt 2]
	    set useOpt  $sett($fmt,read,$optName,useOpt)
	    set optVal  $sett($fmt,read,$optName,optVal)
	    if { $useOpt } {
		append optStr " $optName $optVal"
	    }
	}
    }
    return $optStr
}

proc ::poImgtype::ComboCB { args } {
    variable sett
    variable curType

    # Restore the file extensions of the previous type.
    SaveFileExt

    set curType [lindex $args 1]

    # Load the file extensions of the currently selected type.
    ::poImgtype::LoadFileExt
    ::poImgtype::GenOptWidgets
}

proc ::poImgtype::ScrSaver { args } {
    ::poWin::StartScreenSaver . "I said: Do not switch on"
    set ::poImgtype::sett(optShroud) 0
    update
}

proc ::poImgtype::CheckAniGifIndex { fileName ind } {
    set retVal [catch {set phImg [image create photo -file $fileName \
				  -format "GIF -index $ind"]} err]
    if { $retVal == 0 } {
	image delete $phImg
        return 1
    }
    return 0
}

proc ::poImgtype::CheckIcoIndex { fileName ind } {
    set retVal [catch {set phImg [image create photo -file $fileName \
				  -format "ICO -index $ind"]} err]
    if { $retVal == 0 } {
	image delete $phImg
        return 1
    }
    return 0
}

proc ::poImgtype::GetExifInfo { fileName } {
    return [::poExif::analyzeFile $fileName]
}

###########################################################################
#[@e
#       Name:           ::poImgtype::OpenWin
#
#       Usage:          Open the filetype selection window.
#
#       Synopsis:       proc ::poImgtype::OpenWin { { language 0 } }
#
#       Description:	language: Integer
#
#			The filetype selection window is opened and ready for
#			user input.
#			Standard filetypes and associated actions:
#			OPa Blabla
#			Use ::poImgtype::LoadFromFile before calling this
#			function to load user specific associations.
#
#       Return Value:   None.
#
#       See also: 	::poImgtype::GetDiffProg
#    			::poImgtype::GetEditProg
#    			::poImgtype::LoadFromFile
#    			::poImgtype::SaveToFile
#
###########################################################################

proc ::poImgtype::OpenWin { { fmtOrExt "" } { language 0 } } {
    variable sett
    variable curType
    variable curLang

    set tw .poImgtype:SettWin

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    set curInd 0
    set curType [lindex $sett(imgFmtList) $curInd]
    if { [string first "." $fmtOrExt] >= 0 } {
	set curType [::poImgtype::GetFmtByExt $fmtOrExt]
        set curInd [lsearch -exact $sett(imgFmtList) $curType]
	if { $curInd < 0 } {
	    set curInd 0
	    set curType [lindex $sett(imgFmtList) $curInd]
	    ::poLog::Warning "No extension \"$fmtOrExt\" registered"
	}
    } elseif { [string compare $fmtOrExt ""] != 0 } {
	set curType $fmtOrExt
        set curInd [lsearch -exact $sett(imgFmtList) $curType]
	if { $curInd < 0 } {
	    set curInd 0
	    set curType [lindex $sett(imgFmtList) $curInd]
	    ::poLog::Warning "No format \"$fmtOrExt\" registered"
	}
    }

    set curLang $language

    toplevel $tw
    wm title $tw [Str WinTitle]
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $sett(x) $sett(y)]

    frame $tw.top -borderwidth 1 -relief ridge
    frame $tw.mid -borderwidth 1 -relief ridge
    frame $tw.bot -borderwidth 1 -relief ridge
    pack $tw.top $tw.mid $tw.bot -side top -expand 1 -fill both

    set sett(mainWid) $tw
    set sett(topWid)  $tw.top
    set sett(midWid)  $tw.mid
    set sett(botWid)  $tw.bot
    set sett(changed) true
   
    set top $tw.top
    set bot $tw.bot

    # Generate left column with text labels.
    set row 0
    foreach labelStr [list [Str ImgType] [Str FileExt] \
                           [Str Shroud] [Str ViewSel] ] {
	label $top.l$row -text $labelStr
        grid  $top.l$row -row $row -column 0 -sticky nw -pady 2
	incr row
    }

    # Generate right column with entries and buttons.
    # Row 0: Image types
    set row 0
    frame $top.fr$row -relief ridge -borderwidth 1
    grid  $top.fr$row -row $row -column 1 -sticky news -pady 2

    set sett(combo) $top.fr$row.cb
    ::combobox::combobox $top.fr$row.cb -editable 0 -relief sunken 
    UpdateCombo $sett(combo) $sett(imgFmtList) 0
    $sett(combo) select $curInd

    pack  $top.fr$row.cb -side top -anchor w -fill x -expand 1 -in $top.fr$row

    # Row 1: File extension text widget
    incr row
    frame $top.fr$row -relief ridge -borderwidth 1
    grid $top.fr$row -row $row -column 1 -sticky news -pady 2
    set sett(fileExt) [::poWin::CreateScrolledText $top.fr$row \
		        "" -bg white -wrap none -width 10 -height 3]
    # Load the file extensions of the currently selected type.
    ::poImgtype::LoadFileExt

    # Row 2: Button to switch on/off shrouding of images.
    incr row
    frame $top.fr$row -borderwidth 1
    grid  $top.fr$row -row $row -column 1 -sticky nws -pady 2
    checkbutton $top.fr$row.rb -text "Shroud" \
                -variable ::poImgtype::sett(optShroud)
    # OPA 
    trace variable ::poImgtype::sett(optShroud) w  ::poImgtype::ScrSaver
    entry $top.fr$row.e -show "*" -width 3 \
                        -textvariable ::poImgtype::sett(shroudVal)
    ::poToolhelp::AddBinding $top.fr$row.rb "Not yet implemented. Do NOT switch on!"
    pack $top.fr$row.rb $top.fr$row.e -side left -fill both -expand 1 -padx 4

    # Row 3: Buttons to show either read or write format options.
    incr row
    frame $top.fr$row -borderwidth 1
    grid  $top.fr$row -row $row -column 1 -sticky nws -pady 2
    radiobutton $top.fr$row.ro -text "Show read options" \
                -variable ::poImgtype::sett(optToShow) -value "read" \
	 	-command "::poImgtype::GenOptWidgets"
    radiobutton $top.fr$row.wo -text "Show write options" \
                -variable ::poImgtype::sett(optToShow) -value "write" \
	 	-command "::poImgtype::GenOptWidgets"
    pack $top.fr$row.ro $top.fr$row.wo -side top -fill both -expand 1

    ::poImgtype::GenOptWidgets

    $top.fr0.cb configure -command "::poImgtype::ComboCB"
    bind $sett(fileExt) <Any-KeyRelease> "::poImgtype::SaveFileExt"

    # Create Cancel and OK buttons
    incr row

    bind  $tw <KeyPress-Escape> "::poImgtype::CancelWin $tw"
    button $bot.b1 -text "Cancel" -command "::poImgtype::CancelWin $tw"
    button $bot.b2 -text "OK" -default active \
		   -command "::poImgtype::CloseWin $tw"
    pack $bot.b1 $bot.b2 -side left -fill x -padx 2 -expand 1
    focus $tw
}

proc ::poImgtype::GenOptWidgets {} {
    variable sett
    variable curType
    variable curLang

    # Destroy the middle frame before inserting new values.
    set mid $sett(midWid).fr
    catch { destroy $mid }
    frame $mid
    pack $mid -in $sett(midWid) -expand 1 -fill both

    if { $sett(optToShow) == "read" } {
	set strNone "No read format options"
	set mode "read"
	set optList $sett($curType,read)
    } else {
	set strNone "No write format options"
	set mode "write"
	set optList $sett($curType,write)
    }

    set row 0
    foreach opt $optList {
	if { $opt == {} } {
	    label $mid.l$row -text $strNone
	    grid $mid.l$row -row $row -column 0 -columnspan 2 -sticky news
	    break
	}
	set useOpt  [lindex $opt 0]
	set optName [lindex $opt 1]
	set optType [lindex $opt 2]
	set optVal  [lindex $opt 3]

	checkbutton $mid.opt$row -text $optName \
		    -variable ::poImgtype::sett($curType,$mode,$optName,useOpt)
	grid $mid.opt$row -row $row -column 0 -sticky w -pady 2
	switch $optType {
	    bool {
		frame $mid.fr$row
		radiobutton $mid.fr$row.t -text "true" -value true \
		    -variable ::poImgtype::sett($curType,$mode,$optName,optVal)
		radiobutton $mid.fr$row.f -text "false" -value false \
		    -variable ::poImgtype::sett($curType,$mode,$optName,optVal)
		grid $mid.fr$row -row $row -column 1 -sticky news -pady 2
		pack $mid.fr$row.t $mid.fr$row.f -side left -in $mid.fr$row
	    }
	    int -
	    float {
		entry $mid.e$row -width 10 \
	         -textvariable ::poImgtype::sett($curType,$mode,$optName,optVal)
		grid  $mid.e$row -row $row -column 1 -sticky news -pady 2
	    }
	    enum {
		set curEnum 1
		frame $mid.fr$row
		grid $mid.fr$row -row $row -column 1 -sticky news -pady 2
		foreach vals [lrange $opt 4 end] {
		    radiobutton $mid.fr$row.cb$curEnum -text $vals -variable \
                        ::poImgtype::sett($curType,$mode,$optName,optVal) \
		        -value $vals
		    pack $mid.fr$row.cb$curEnum -side left -in $mid.fr$row
		    incr curEnum
		}
	    }
	    default {
	        ::poLog::Error "Unknown option type $optType"
	    }
	}
	incr row
    }
}

###########################################################################
#[@e
#       Name:           ::poImgtype::GetDiffProg
#
#       Usage:          Get the associated diff program.
#
#       Synopsis:       proc ::poImgtype::GetDiffProg { fileName }
#
#       Description:	fileName: String
#
#			Return the diff program associated with "fileName".
#			Association is not limited to an extension, but can be
#			any valid glob-style expression.
#
#       Return Value:   String.
#
#       See also: 	::poImgtype::OpenWin
#    			::poImgtype::GetEditProg
#    			::poImgtype::LoadFromFile
#    			::poImgtype::SaveToFile
#
###########################################################################

###########################################################################
#[@e
#       Name:           ::poImgtype::LoadFromFile
#
#       Usage:          Load stored association rules from a file.
#
#       Synopsis:       proc ::poImgtype::LoadFromFile { { fileName "" } }
#
#       Description:	fileName: String (default: "")
#
#			Load association rules from file "fileName". If 
#			"fileName" is empty, then the function tries to read
#			file "~/poImgtype.cfg".
#
#			Note: "~" (the user's home directory on Unix systems)
#			      is typically mapped to "C:\" on Win9x systems.
#
#       Return Value:   true / false.
#
#       See also: 	::poImgtype::OpenWin
#    			::poImgtype::GetDiffProg
#    			::poImgtype::GetEditProg
#    			::poImgtype::SaveToFile
#
###########################################################################

proc ::poImgtype::LoadFromFile { { fileName "" } } {
    variable sett

    if { [string compare $fileName ""] == 0 } {
	set cfgFile [::poMisc::GetCfgFile poImgtype] 
    } else {
 	set cfgFile $fileName
    }
    if { [file readable $cfgFile] } {
	source $cfgFile
	return 1
    } else {
	::poLog::Warning "Could not read cfg file $cfgFile"
	return 0
    }
}

###########################################################################
#[@e
#       Name:           ::poImgtype::SaveToFile
#
#       Usage:          Store association rules to a file.
#
#       Synopsis:       proc ::poImgtype::SaveToFile { { fileName "" } }
#
#       Description:	fileName: String (default: "")
#
#			Store association rules to file "fileName". If 
#			"fileName" is empty, then the function tries to write
#			file "~/poImgtype.cfg".
#
#			Note: "~" (the user's home directory on Unix systems)
#			      is typically mapped to "C:\" on Win9x systems.
#
#       Return Value:   true / false.
#
#       See also: 	::poImgtype::OpenWin
#    			::poImgtype::GetDiffProg
#    			::poImgtype::GetEditProg
#    			::poImgtype::LoadFromFile
#
###########################################################################

proc ::poImgtype::SaveToFile { { fileName "" } } {
    variable sett

    if { [string compare $fileName ""] == 0 } {
	set cfgFile [::poMisc::GetCfgFile poImgtype] 
    } else {
 	set cfgFile $fileName
    }
    set retVal [catch {open $cfgFile w} fp]
    if { $retVal != 0 } {  
	error "Cannot write to cfg file $cfgFile"
	return 0
    }

    puts $fp "::poImgtype::SetShroudOpt $sett(optShroud)"

    foreach fmt $sett(imgFmtList) {
        set tip [list $sett($fmt,tip)]
        set ext [list $sett($fmt,ext)]
        set ro  [list $sett($fmt,read)]
        set wo  [list $sett($fmt,write)]

	puts $fp "::poImgtype::AddType $fmt $tip $ext $ro $wo"
    }
    close $fp
    return 1
}

proc ::poImgtype::OpenImgFile { w } {
    set fileTypes [::poImgtype::GetSelBoxTypes]
    set imgName [tk_getOpenFile -filetypes $fileTypes \
                 -title "Select an image file"]
    if { $imgName != "" } {
	set ext [file extension $imgName]
	set fmt [GetOptByExt $ext "read"]
	::poLog::Debug "Loading image with format: \"$fmt\""
	set ph [image create photo -file $imgName -format $fmt]
	$w configure -image $ph
    }
}

###########################################################################
#[@e
#       Name:           ::poImgtype::Test
#
#       Usage:          Test the file type package.
#
#       Synopsis:       proc ::poImgtype::Test {}
#
#       Description:
#
#       Return Value:   None.
#
#       See also: 	::poImgtype::OpenWin
#    			::poImgtype::GetDiffProg
#    			::poImgtype::GetEditProg
#    			::poImgtype::LoadFromFile
#    			::poImgtype::SaveToFile
#
###########################################################################

proc ::poImgtype::Test {} {
    label  .l
    button .b1 -text "Open Settings Window" -command ::poImgtype::OpenWin
    button .b2 -text "Open Settings Window GIF" -command "::poImgtype::OpenWin GIF"
    button .b3 -text "Open Settings Window .tga" -command "::poImgtype::OpenWin .tga"
    button .b4 -text "Open Settings Window BBB" -command "::poImgtype::OpenWin BBB"
    button .b5 -text "Open Settings Window .asd" -command "::poImgtype::OpenWin .asd"
    button .b6 -text "Save Settings" -command ::poImgtype::SaveToFile
    button .b7 -text "Load Settings" -command ::poImgtype::LoadFromFile
    button .b8 -text "Select image file" -command "::poImgtype::OpenImgFile .l"
    pack .b1 .b2 .b3 .b4 .b5 .b6 .b7 .b8 .l -fill x
}

::poImgtype::Init
catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poLogOpt.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poLogOpt
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poLogOpt.tcl
#
#       First Version:  2000 / 12 / 02
#       Author:         Paul Obermeier
#
#       Description:	
#			OPa Todo
#
#       Additional documentation:
#
#			None.
#
#       Exported functions:
#    			::poLogOpt::OpenWin
#    			::poLogOpt::Test
#
############################################################################

package provide poTklib 1.0
package provide poLogOpt 1.0

namespace eval ::poLogOpt {
    namespace export OpenWin
    namespace export ChangedOpts

    namespace export Test

    variable winGeom
    variable settChanged
    variable logOptions
    variable consEnable
    variable consOldMode
    variable langStr
    variable curLang
}

proc ::poLogOpt::Init {} {
    variable langStr
    variable curLang
    variable winGeom
    variable settChanged
    variable logOptions
    variable consEnable
    variable consOldMode

    set winGeom(x) 100
    set winGeom(y) 100
    set consEnable 0
    set consOldMode $consEnable
    set logOptions($::poLog::levelInfo)      $::poLog::levelOff 
    set logOptions($::poLog::levelWarning)   $::poLog::levelOff 
    set logOptions($::poLog::levelError)     $::poLog::levelOff 
    set logOptions($::poLog::levelDebug)     $::poLog::levelOff 
    set logOptions($::poLog::levelCallstack) $::poLog::levelOff 

    set settChanged false

    set curLang 0
    array set langStr [list \
	ConsEnable { "Show logging console" \
		     "Aufzeichnungs-Konsole einschalten" } \
	LogInfo    { "Log info messages" \
		     "Info Meldungen aufzeichnen" } \
	LogWarn    { "Log warning messages" \
		     "Warnung Meldungen aufzeichnen" } \
	LogError   { "Log error messages" \
		     "Fehler Meldungen aufzeichnen" } \
	LogDebug   { "Log debug messages" \
		     "Debug Meldungen aufzeichnen" } \
	LogCall    { "Log callstack messages" \
		     "Callstack Meldungen aufzeichnen" } \
	Cancel     { "Cancel" \
		     "Abbrechen" } \
	OK         { "OK" \
		     "OK" } \
	Confirm    { "Confirmation" \
		     "Bestätigung" } \
	WinTitle   { "Logging options" \
		     "Aufzeichnungs Optionen" } \
    ]
}

proc ::poLogOpt::Str { key args } {
    variable langStr
    variable curLang

    set str [lindex $langStr($key) $curLang]
    return [eval {format $str} $args]
}

proc ::poLogOpt::CloseWin { w } {
    variable winGeom

    set winGeom(x) [winfo x $w]
    set winGeom(y) [winfo y $w]
    destroy $w
}

proc ::poLogOpt::CancelWin { w args } {
    variable logOptions
    variable consEnable
    variable settChanged

    foreach pair $args {
        set var [lindex $pair 0]
        set val [lindex $pair 1]
        set cmd [format "set %s %s" $var $val]
        eval $cmd
    }
    set settChanged false
    ::poLogOpt::CloseWin $w
}

proc ::poLogOpt::SetOpt { } {
    variable winGeom
    variable consEnable
    variable consOldMode
    variable logOptions

    if { $consEnable == 0 } {
        ::poLog::ShowConsole 0
    } else {
        if { $consEnable != $consOldMode } {
	    ::poLog::ShowConsole 1
	}
    }

    set logList {}
    foreach name [array names logOptions] {
    	if { $logOptions($name) != $::poLog::levelOff } {
	     lappend logList $logOptions($name)
	}
    }
    ::poLog::SetDebugLevels $logList
}

proc ::poLogOpt::ChangedOpts {} {
    variable settChanged

    return $settChanged
}

###########################################################################
#[@e
#       Name:           ::poLogOpt::OpenWin
#
#       Usage:          Open the debug level selection window.
#
#       Synopsis:       proc ::poLogOpt::OpenWin { { language 0 } }
#
#       Description:	language: Integer
#
#			The debug level selection window is opened and ready for
#			user input.
#			Use ::poLogOpt::LoadFromFile before calling this
#			function to load user specific associations.
#
#       Return Value:   None.
#
#       See also: 	::poLogOpt::Test
#
###########################################################################

proc ::poLogOpt::OpenWin { { language 0 } } {
    variable winGeom
    variable settChanged
    variable consEnable
    variable consOldMode
    variable logOptions
    variable curLang

    set tw .poLogOpt:SettWin

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    set curLang $language

    toplevel $tw
    wm title $tw [Str WinTitle]
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $winGeom(x) $winGeom(y)]

    foreach lev [::poLog::GetDebugLevels] {
        set logOptions($lev) $lev
    }
    set consEnable [::poLog::GetConsoleMode]
    set consOldMode $consEnable

    set settChanged true

    set varList {}
    frame $tw.fr1
    frame $tw.fr2
    pack $tw.fr1 $tw.fr2 -side top -fill x -expand 1
    checkbutton $tw.fr1.cb1 -text [Str ConsEnable] \
	        -variable ::poLogOpt::consEnable \
    	        -onvalue 1 -offvalue 0
    checkbutton $tw.fr2.cb2 -text [Str LogInfo] \
	        -variable ::poLogOpt::logOptions($::poLog::levelInfo) \
    	        -onvalue $::poLog::levelInfo -offvalue $::poLog::levelOff
    checkbutton $tw.fr2.cb3 -text [Str LogWarn] \
                -variable ::poLogOpt::logOptions($::poLog::levelWarning) \
    	        -onvalue $::poLog::levelWarning -offvalue $::poLog::levelOff
    checkbutton $tw.fr2.cb4 -text [Str LogError] \
                -variable ::poLogOpt::logOptions($::poLog::levelError) \
    	        -onvalue $::poLog::levelError -offvalue $::poLog::levelOff
    checkbutton $tw.fr2.cb5 -text [Str LogDebug] \
                -variable ::poLogOpt::logOptions($::poLog::levelDebug) \
    	        -onvalue $::poLog::levelDebug -offvalue $::poLog::levelOff
    checkbutton $tw.fr2.cb6 -text [Str LogCall] \
                -variable ::poLogOpt::logOptions($::poLog::levelCallstack) \
    	        -onvalue $::poLog::levelCallstack -offvalue $::poLog::levelOff
    pack $tw.fr1.cb1 -side top -anchor w -in $tw.fr1 -pady 4
    pack $tw.fr2.cb2 $tw.fr2.cb3 $tw.fr2.cb4 $tw.fr2.cb5 $tw.fr2.cb6 \
         -side top -anchor w -in $tw.fr2

    set tmpList [list [list consEnable] [list $consEnable]]
    lappend varList $tmpList
    set tmpList [list [list logOptions($::poLog::levelInfo)] \
                      [list $logOptions($::poLog::levelInfo)]]
    lappend varList $tmpList
    set tmpList [list [list logOptions($::poLog::levelWarning)] \
                      [list $logOptions($::poLog::levelWarning)]]
    lappend varList $tmpList
    set tmpList [list [list logOptions($::poLog::levelError)] \
                      [list $logOptions($::poLog::levelError)]]
    lappend varList $tmpList
    set tmpList [list [list logOptions($::poLog::levelDebug)] \
                      [list $logOptions($::poLog::levelDebug)]]
    lappend varList $tmpList
    set tmpList [list [list logOptions($::poLog::levelCallstack)] \
                      [list $logOptions($::poLog::levelCallstack)]]
    lappend varList $tmpList

    # Create Cancel and OK buttons
    frame $tw.okfr
    pack $tw.okfr -side top -fill x -expand 1

    bind  $tw <KeyPress-Escape> "::poLogOpt::CancelWin $tw $varList"
    bind  $tw <KeyPress-Return> "::poLogOpt::SetOpt ; ::poLogOpt::CloseWin $tw"
    button $tw.okfr.b1 -text [Str Cancel] \
                         -command "::poLogOpt::CancelWin $tw $varList"
    button $tw.okfr.b2 -text [Str OK] -default active \
	-command "::poLogOpt::SetOpt ; ::poLogOpt::CloseWin $tw"
    pack $tw.okfr.b1 -side left -fill x -padx 2 -expand 1
    pack $tw.okfr.b2 -side left -fill x -padx 2 -expand 1
    focus $tw
}

###########################################################################
#[@e
#       Name:           ::poLogOpt::Test
#
#       Usage:          Test the file type package.
#
#       Synopsis:       proc ::poLogOpt::Test {}
#
#       Description:
#
#       Return Value:   None.
#
#       See also: 	::poLogOpt::OpenWin
#
###########################################################################

proc ::poLogOpt::Test {} {
    button .b1 -text "Open Log Options Window" -command ::poLogOpt::OpenWin
    button .b2 -text "Save Log Options" -command ::poLogOpt::SaveToFile
    button .b3 -text "Load Log Options" -command ::poLogOpt::LoadFromFile
    pack .b1 .b2 .b3
}

::poLogOpt::Init
::poLog::ShowConsole 1
catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poPane.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poPane
#       Copyright:      Paul Obermeier 2001-2003 / paul@poSoft.de
#       Filename:       poPane.tcl
#
#       First Version:  2001 / 06 / 12
#       Author:         Paul Obermeier
#
#       Description:	
#			OPa Todo
#
#       Additional documentation:
#
#			None.
#
#       Exported functions:
#    			::poPane::Create
#    			::poPane::Set
#    			::poPane::Test
#
############################################################################

package provide poTklib 1.0
package provide poPane  1.0

namespace eval ::poPane {
    namespace export Create
    namespace export Set
    namespace export Get

    namespace export Test
}

proc ::poPane::Create {f1 f2 args} {
    ### Map optional arguments into array values ###
    set t(-orient) horizontal
    set t(-percent) 0.5
    set t(-in) [winfo parent $f1]
    array set t $args

    ### Keep state in an array associated with the master frame ###
    set master $t(-in)
    pack $master -expand true -fill both
    pack propagate $master off
    upvar #0 [namespace current]::Pane$master pane
    array set pane [array get t]

    set pane(1) $f1
    set pane(2) $f2
    set pane(grip) $master.grip

    frame $pane(grip) -bg orange -width 10 -height 10 -bd 1 -relief raised

    if {[string match vert* $pane(-orient)]} {
        ### Adjust boundary in Y direction ###
	set pane(D) Y
        place $pane(1) -in $master -x 0 -rely 0.0 \
	               -anchor nw -relwidth 1.0 -height -1
        place $pane(2) -in $master -x 0 -rely 1.0 \
	               -anchor sw -relwidth 1.0 -height -1
        place $pane(grip) -in $master -anchor c -relx 0.9
        $pane(grip) configure -cursor sb_v_double_arrow

    } else {
	### Adjust boundary in X direction ###
        set pane(D) X
        place $pane(1) -in $master -relx 0.0 -y 0 \
	               -anchor nw -relheight 1.0 -width -1
        place $pane(2) -in $master -relx 1.0 -y 0 \
	               -anchor ne -relheight 1.0 -width -1
        place $pane(grip) -in $master -anchor c -rely 0.2
        $pane(grip) configure -cursor sb_h_double_arrow
    }

    $master configure -background orange

    ### bindings for resize AKA <Configure>, and dragging the grip. ###
    bind $master     <Configure> [namespace code [list  Geometry $master]]
    bind $pane(grip) <B1-Motion> [namespace code [list  Drag $master %$pane(D)]]
    bind $pane(grip) <ButtonRelease-1> [namespace code [list  Stop $master]]

    ### Do the initial layout ###
    Geometry $master
}

proc ::poPane::Set {master value} {
    set [namespace current]::Pane${master}(-percent) $value
    Geometry $master
}

proc ::poPane::Get {master} {
    set [namespace current]::Pane${master}(-percent)
}

proc ::poPane::Drag {master D} {
    upvar #0 [namespace current]::Pane$master pane
    if [info exists pane(lastD)] {
	set delta [expr {double($pane(lastD)-$D)/$pane(size)}]
        set pane(-percent) [expr {$pane(-percent) - $delta}]
        if {$pane(-percent) < 0.0} {
            set pane(-percent) 0.0
        } elseif {$pane(-percent) > 1.0} {
            set pane(-percent) 1.0
        }
        Geometry $master
    }
    set pane(lastD) $D
}

proc ::poPane::Stop {master} {
    upvar #0 [namespace current]::Pane$master pane
    catch {unset pane(lastD)}
}

proc ::poPane::Geometry {master} {
    upvar #0 [namespace current]::Pane$master pane

    if {$pane(D) == "X"} {
        place $pane(1) -relwidth $pane(-percent)
        place $pane(2) -relwidth [expr {1.0 - $pane(-percent)}]
        place $pane(grip) -relx $pane(-percent)
        set pane(size) [winfo width $master]

    } else { # $pane(D) == "Y"
        place $pane(1) -relheight $pane(-percent)
        place $pane(2) -relheight [expr {1.0 - $pane(-percent)}]
        place $pane(grip) -rely $pane(-percent)
        set pane(size) [winfo height $master]
    }
}

proc ::poPane::Test {{p .p} {orient hori}} {
    catch {destroy $p}
    frame $p -width 200 -height 200 ;# needed: no propagation
    message $p.1 -bg bisque -text [info procs] -relief ridge
    frame $p.2
    label $p.2.foo -bg pink -text foo -relief ridge
    label $p.2.bar -bg grey75 -text bar -relief ridge
    pack $p -expand true -fill both
    pack propagate $p off
    ::poPane::Create $p.2.foo $p.2.bar -orient vert
    ::poPane::Create $p.1 $p.2 -orient $orient -percent 0.7
    raise .
}

catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poSoftLogo.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poSoftLogo
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poSoftLogo.tcl
#
#       First Version:  2000 / 02 / 20
#       Author:         Paul Obermeier
#
#       Description:
#			Functions for displaying a poSoft and Tcl logo window. 
#
#       Additional documentation:
#
#       Exported functions:
#			::poSoftLogo::ShowLogo
#			::poSoftLogo::DestroyLogo
#			::poSoftLogo::ShowTclLogo
#
############################################################################ 

package provide poTklib 1.0
package provide poSoftLogo 1.0

namespace eval poSoftLogo {
    namespace export ShowLogo
    namespace export DestroyLogo
    namespace export ShowTclLogo

    variable langStr
    variable language
    variable url
    variable wackel
    variable logoWinId
}

proc ::poSoftLogo::ShrinkWindow { tw dir } {
    set width  [winfo width $tw]
    set height [winfo height $tw]
    set x      [winfo x $tw]
    set y      [winfo y $tw]
    set inc -1

    if { [string compare $dir "x"] == 0 } {
	for { set w $width } { $w >= 20 } { incr w $inc } {
            if { [winfo exists $tw] } {
                wm geometry $tw [format "%dx%d+%d+%d" $w $height $x $y]
                update
            }
	    incr inc -1
	}
    } else {
	for { set h $height } { $h >= 20 } { incr h $inc } {
            if { [winfo exists $tw] } {
                wm geometry $tw [format "%dx%d+%d+%d" $width $h $x $y]
                update
            }
	    incr inc -1
	}
    }
}

proc ::poSoftLogo::DestroyLogo {} {
    variable wackel
    variable logoWinId
    variable withdrawnWinId

    if { [info exists logoWinId] && [winfo exists $logoWinId] } {
	ShrinkWindow $logoWinId x
	set wackel(onoff) 0
	catch {image delete $wackel(0)}
	catch {image delete $wackel(1)}
	destroy $logoWinId
        if { [winfo exists $withdrawnWinId] } {
	    wm deiconify $withdrawnWinId
	}
    }
}

proc ::poSoftLogo::ShowLogo { version copyright {withdrawWin ""} } {
    variable wackel
    variable logoWinId
    variable withdrawnWinId

    set t ".poShowLogo"
    set logoWinId $t
    set withdrawnWinId $withdrawWin
    if { [winfo exists $t] } {
	::poWin::Raise $t
	return
    }

    set wackel(0) [image create photo -data [::poImgData::poLogo200_text]]
    set wackel(1) [image create photo -data [::poImgData::poLogo200_text_flip]]
    set wackel(onoff)  0
    set wackel(curImg) 0
    set wackel(wackelSpeed) 500

    if { [catch {toplevel $t -visual truecolor}] } {
        toplevel $t
    }
    frame $t.f
    pack $t.f
    wm resizable $t false false
    if { [string compare $withdrawWin ""] == 0 } {
	wm title $t "poSoft Information"
    } else {
	if { [string compare $withdrawWin "."] != 0 } {
	    wm withdraw .
	}
	if { [winfo exists $withdrawWin] } {
	    wm withdraw $withdrawWin
	    set withdrawnWinId $withdrawWin
	}
	wm overrideredirect $t 1
        set xmax [winfo screenwidth $t]
        set ymax [winfo screenheight $t]
        set x0 [expr {($xmax - [image width  $wackel(0)])/2}]
        set y0 [expr {($ymax - [image height $wackel(0)])/2}]
        wm geometry $t "+$x0+$y0"
	$t.f configure -borderwidth 10
	raise $t
	update
    }

    label $t.f.l1 -text "Paul Obermeier's Portable Software"
    pack $t.f.l1 -fill x
    button $t.f.l2 -image $wackel(0)
    ::poToolhelp::AddBinding $t.f.l2 "http://www.poSoft.de"
    bind $t.f.l2 <Motion> { ::poSoftLogo::SetWackelDelay %x %y }
    bind $t.f.l2 <Shift-Button-1> "::poSoftLogo::StartWackel $t.f.l2"
    bind $t.f.l2 <Button-1> "::poSoftLogo::SwitchLogo $t.f.l2"
    pack $t.f.l2
    label $t.f.l3 -text $version
    pack $t.f.l3 -fill x
    label $t.f.l4 -text $copyright
    pack $t.f.l4 -fill x
    if { [string compare $withdrawWin ""] == 0 } {
	button $t.f.b -text "OK" -command "::poSoftLogo::DestroyLogo"
	pack $t.f.b -fill x
	bind $t <KeyPress-Escape> "::poSoftLogo::DestroyLogo" 
	bind $t <KeyPress-Return> "::poSoftLogo::DestroyLogo"
	focus $t
	update
    } else {
	focus $t
	update
	after 500
	::poSoftLogo::SwitchLogo $t.f.l2
	update
	after 300
    }
}

proc ::poSoftLogo::SetWackelDelay { mouseX mouseY } {
    variable wackel

    set wackel(wackelSpeed) [expr $mouseX + $mouseY]
}

proc ::poSoftLogo::SwitchLogo { b } {
    variable wackel

    if { $wackel(onoff) == 1 } {
	set wackel(onoff) 0
    }
    set wackel(curImg) [expr 1 - $wackel(curImg)]
    $b configure -image $wackel($wackel(curImg))
}

proc ::poSoftLogo::StartWackel { b } {
    variable wackel

    if { $wackel(onoff) == 0 } {
	set wackel(onoff) 1
	::poSoftLogo::Wackel $b
    } else {
	::poSoftLogo::StopWackel $b
    }
}

proc ::poSoftLogo::StopWackel { b } {
    variable wackel 

    set wackel(onoff)  0
    set wackel(curImg) 1
    after $wackel(wackelSpeed) ::poSoftLogo::Wackel $b
}

proc ::poSoftLogo::Wackel { b } {
    variable wackel

    if { $wackel(onoff) == 1 } {
        set wackel(curImg) [expr 1 - $wackel(curImg)]
        $b configure -image $wackel($wackel(curImg))
	update
        after $wackel(wackelSpeed) "::poSoftLogo::Wackel $b"
    }
}

proc ::poSoftLogo::Str { key args } {
    variable langStr 
    variable language

    set str [lindex $langStr($key) $language]
    return [eval {format $str} $args]
}

proc ::poSoftLogo::DestroyTclLogo { w img } {
    ShrinkWindow $w y
    image delete $img
    destroy $w
}

proc ::poSoftLogo::ShowTclLogo { lang args } {
    variable language 
    variable langStr
    variable url

    set t ".poShowTclLogo"
    if { [winfo exists $t] } {
	::poWin::Raise $t
	return
    }

    array set langStr [list \
	WithHelp   { "With a little help from my Tcl friends ..." \
		     "With a little help from my Tcl friends ..." } \
	Thanks     { "Thanks to %s" \
		     "Dank an %s" } \
	CopyAdr    { "Copy URL to copy-and-paste buffer" \
		     "Kopiere URL in Zwischenablage" } \
    ]
    set language $lang

    if { [catch {toplevel $t -visual truecolor}] } {
        toplevel $t
    }
    wm title $t "Tcl/Tk Information"
    wm resizable $t false false

    set ph [image create photo -data [::poImgData::pwrdLogo200]]
    button $t.img -image $ph
    pack $t.img
    label $t.l1 -anchor w -text [Str WithHelp] 
    pack $t.l1

    set row 0
    frame $t.f -relief sunken -borderwidth 2
    pack $t.f -fill both -expand 1
    foreach extension $args {
	set retVal [catch {package present $extension} versionStr]
	if { $retVal != 0 } {
	    set versionStr "(not loaded)"
	}
	switch $extension {
	    Tk       { set progName  "Tcl/Tk [info patchlevel]"
		        set url($row) "http://www.tcl.tk"
		        set author    "all Tcl/Tk core developers" 
		      }
	    Img       { set progName  "Img $versionStr"
		        set url($row) "http://sourceforge.net/projects/tkImg/"
		        set author    "Jan Nijtmans, Andreas Kupries"
		      }
	    Tktable   { set progName  "Tktable $versionStr"
		        set url($row) "https://sourceforge.net/projects/tktable/"
		        set author    "Jeffrey Hobbs"
		      }
	    mktclapp  { set progName  "mktclapp 3.9"
		        set url($row) "http://www.hwaci.com/sw/mktclapp"
		        set author    "D. Richard Hipp" 
		      }
	    combobox  { set progName  "combobox $versionStr"
		        set url($row) "http://www2.clearlight.com/~oakley"
		        set author    "Bryan Oakley" 
		      }
	    mysqltcl  { set progName  "mysqltcl $versionStr"
		        set url($row) "http://www.xdobry.de/mysqltcl"
		        set author    "Hakan Soderlund, Tobias Ritzau ..." 
		      }
	    tcom      { set progName  "tcom $versionStr"
		        set url($row) "http://www.vex.net/~cthuang/tcom"
		        set author    "Chin Huang" 
		      }
	    tablelist { set progName  "tablelist $versionStr"
		        set url($row) "http://www.nemethi.de"
		        set author    "Csaba Nemethi" 
		      }
	}
	label $t.f.lext$row -text $progName
	set bgColor [$t.f.lext$row cget -bg]
	eval entry $t.f.rext$row -state normal -width 35 -relief flat \
			    -bg $bgColor -textvariable ::poSoftLogo::url($row)
	::poToolhelp::AddBinding $t.f.lext$row [Str Thanks $author]
	grid $t.f.lext$row -row $row -column 0 -sticky w
	grid $t.f.rext$row -row $row -column 1 -sticky w
	incr row
    }
    button $t.b -text "OK" -command "::poSoftLogo::DestroyTclLogo $t $ph"
    pack $t.b -fill x
    bind $t <KeyPress-Escape> "::poSoftLogo::DestroyTclLogo $t $ph" 
    bind $t <KeyPress-Return> "::poSoftLogo::DestroyTclLogo $t $ph"
    focus $t
}

catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poToolbar.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poToolbar
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poToolbar.tcl
#
#       First Version:  2000 / 02 / 20
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#			::poToolbar::AddGroup
#			::poToolbar::AddLabel
#			::poToolbar::AddButton
#			::poToolbar::AddCheckButton
#			::poToolbar::AddRadioButton
#			::poToolbar::AddEntry
#
############################################################################ 

package provide poTklib 1.0
package provide poToolbar 1.0

namespace eval ::poToolbar {
    namespace export AddGroup
    namespace export AddLabel
    namespace export AddButton
    namespace export AddCheckButton
    namespace export AddRadioButton
    namespace export AddEntry

    variable groupNum
}

proc ::poToolbar::Init {} {
    variable groupNum

    set groupNum 1
}

proc ::poToolbar::AddGroup { w { padx 0 } } {
    variable groupNum

    if { ![info exists groupNum]} {
	Init
    }

    set newFrame $w.fr$groupNum
    frame $newFrame -relief raised -borderwidth 1
    pack  $newFrame -side left -fill y -padx $padx
    incr groupNum
    return $newFrame
}

proc ::poToolbar::AddLabel { btnName bmpData txt str args } {
    variable groupNum

    if { ![info exists groupNum]} {
        Init
    }

    if { $bmpData eq "" } {
        eval label $btnName -text [list $txt] -relief flat $args
    } else {
        set img [image create bitmap -data $bmpData]
        eval label $btnName -image $img -relief flat $args
    }
    if { $str ne "" } {
        ::poToolhelp::AddBinding $btnName $str
    }
    pack $btnName -side left
}

proc ::poToolbar::AddButton { btnName bmpData cmd str args } {
    variable groupNum

    if { ![info exists groupNum]} {
	Init
    }

    if { $bmpData eq "" } {
        eval button $btnName -relief flat -takefocus 0 \
                             -command [list $cmd] $args
    } else {
        set img [image create bitmap -data $bmpData]
        eval button $btnName -image $img -relief flat -takefocus 0 \
                             -command [list $cmd] $args
    }
    if { $str ne "" } {
        ::poToolhelp::AddBinding $btnName $str
    }
    pack $btnName -side left
}

proc ::poToolbar::AddCheckButton { btnName bmpData cmd str args } {
    variable groupNum

    if { ![info exists groupNum]} {
	Init
    }

    if { $bmpData eq "" } {
        eval checkbutton $btnName -relief flat -indicatoron 0 \
  		         -takefocus 0 -command [list $cmd] $args
    } else {
        set img [image create bitmap -data $bmpData]
        eval checkbutton $btnName -image $img -relief flat -indicatoron 0 \
  		         -takefocus 0 -command [list $cmd] $args
    }
    if { $str ne "" } {
        ::poToolhelp::AddBinding $btnName $str
    }
    pack $btnName -side left
}

proc ::poToolbar::AddRadioButton { btnName bmpData cmd str args } {
    variable groupNum

    if { ![info exists groupNum]} {
	Init
    }

    if { $bmpData eq "" } {
        eval radiobutton $btnName -relief flat -indicatoron 0 \
  		         -takefocus 0 -command [list $cmd] $args
    } else {
        set img [image create bitmap -data $bmpData]
        eval radiobutton $btnName -image $img -relief flat -indicatoron 0 \
  		         -takefocus 0 -command [list $cmd] $args
    }
    if { $str ne "" } {
        ::poToolhelp::AddBinding $btnName $str
    }
    pack $btnName -side left
}

proc ::poToolbar::AddEntry { entryName var str args } {
    upvar $var ::txtvar_$entryName
    variable groupNum

    if { ![info exists groupNum]} {
	Init
    }

    eval entry $entryName -relief flat -takefocus 1 \
                           -textvariable ::txtvar_$entryName $args
    if { $str ne "" } {
        ::poToolhelp::AddBinding $entryName $str
    }
    pack $entryName -side left
}

catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poToolhelp.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poToolhelp
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poToolhelp.tcl
#
#       First Version:  2000 / 01 / 22
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#                       ::poToolhelp::AddBinding
#                       ::poToolhelp::Init
#
############################################################################ 

package provide poTklib 1.0
package provide poToolhelp 1.0

namespace eval ::poToolhelp {
    namespace export AddBinding
    namespace export Init

    variable topWidget
}

proc ::poToolhelp::Init { w { bgColor yellow } { fgColor black } } {
    variable topWidget

    ::poLog::Callstack "::poToolhelp::Init $w $bgColor $fgColor"
    # Create Toolbar help window with a simple label in it.
    if { [winfo exists $w] } {
        destroy $w
    }
    toplevel $w
    set topWidget $w
    label $w.l -text "This is toolhelp" -bg $bgColor -fg $fgColor -relief ridge
    pack $w.l
    wm overrideredirect $w true
    if {[string equal [tk windowingsystem] aqua]}  {
        ::tk::unsupported::MacWindowStyle style $w help none
    }
    wm geometry $w [format "+%d+%d" -100 -100]
}

proc ::poToolhelp::ShowToolhelp { x y str } {
    variable topWidget

    ::poLog::Callstack "::poToolhelp::ShowToolhelp $x $y $str"
    $topWidget.l configure -text $str
    raise $topWidget
    wm geometry $topWidget [format "+%d+%d" $x [expr $y +10]]
}

proc ::poToolhelp::HideToolhelp {} {
    variable topWidget

    ::poLog::Callstack "::poToolhelp::HideToolhelp"
    wm geometry $topWidget [format "+%d+%d" -100 -100]
}

proc ::poToolhelp::AddBinding { w str } {
    variable topWidget

    ::poLog::Callstack "::poToolhelp::AddBinding $w $str"
    if { ![info exists topWidget]} {
        Init .poToolhelp
    }
    bind $w <Enter>  "::poToolhelp::ShowToolhelp %X %Y [list $str]"
    bind $w <Leave>  { ::poToolhelp::HideToolhelp }
    bind $w <Button> { ::poToolhelp::HideToolhelp }
}

catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poTree.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poTree
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poTree.tcl
#
#       First Version:  2000 / 03 / 14
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#
############################################################################ 

package provide poTklib 1.0
package provide poTree 1.0

namespace eval ::poTree {
    namespace export GetDrives
    namespace export Create
    namespace export Open
    namespace export Labelat
    namespace export Setselection
    namespace export Getselection
    namespace export Addselection

    namespace export InitOpen
    namespace export GetDir
    namespace export UseSubScan

    variable gStatic
    variable Tree

    variable selectedDir
    variable listboxId
}

proc ::poTree::UseSubScan { onOff } {
    variable gStatic

    set gStatic(useSubScan) $onOff
}

proc ::poTree::Rescan { w } {
    variable Tree

    ::poLog::Callstack "::poTree::Rescan $w"

    set selItem [::poTree::Getselection $w]
    delitem $w $selItem
    OpenBranch $w $selItem
}

proc ::poTree::NewFolder { val } {
    variable Tree

    set curTree $Tree(curTreeWidget)
    if { [string compare [file pathtype $val] "relative"] == 0 } {
	set newFolder [file join [::poTree::Getselection $curTree 1] $val]
    } else { 
	set newFolder $val
    }
    catch { file mkdir $newFolder }
    Open $curTree [::poTree::Getselection $curTree 1]
}

proc ::poTree::AskNewFolder { w } {
    variable Tree

    ::poLog::Callstack "::poTree::AskNewFolder"

    set curDir [::poTree::Getselection $w 1]
    set Tree(curTreeWidget) $w
    ::poWin::ShowEntryBox ::poTree::NewFolder \
			   "New directory" "Create new directory" \
			   "Current directory: $curDir" 40

}

# Just a dummy procedure for the poToolbar::CheckButton function.

proc ::poTree::ShowHiddenDirs { } {
    ::poLog::Callstack "::poTree::ShowHiddenDirs"
}

# Just a dummy procedure for the poToolbar::CheckButton function.

proc ::poTree::DoSubscan { } {
    ::poLog::Callstack "::poTree::DoSubscan"
}

proc ::poTree::OkCmd { w } {
    variable selectedDir

    ::poLog::Callstack "::poTree::OkCmd $w"

    set selectedDir [::poTree::Getselection $w 1]
}

proc ::poTree::CancelCmd { w } {
    variable selectedDir

    ::poLog::Callstack "::poTree::CancelCmd $w"

    set selectedDir ""
}

proc ::poTree::IsVolume { v } {
    variable gStatic

    foreach volume $gStatic(volList) {
	if { [string compare $volume $v] == 0} {
	    return 1
	}
    }
    return 0
}

proc ::poTree::InitOpen { tree initialDir } {
    variable gStatic

    set gStatic(volList) [::poTree::GetDrives]
    foreach volume $gStatic(volList) {
	if { [string compare $volume "A:/"] == 0} {
	    # Don't try to read the diskette drive when initializing the window.
	    continue
	}
	::poTree::OpenBranch $tree $volume
    }
    ::poTree::OpenBranch $tree $initialDir
    ::poTree::Setselection $tree $initialDir 1
}

# Syntax as tk_getOpenFile.
# Supports only two options: 
# -title name		 Default: Open
# -initialdir name	 Default: [pwd]
# -rootdir name  	 Default: [poTree::GetDrives]
# -hlinecolor colorname	 Default: gray50
# -vlinecolor colorname	 Default: gray50
# -background colorname	 Default: white
# -hilitecolor colorname Default: skyblue
# -subscan 1|0           Default: No subdirectory scanning (0)
# -showhidden 1|0        Default: No hidden files are shown (0)

proc ::poTree::GetDir { args } {
    variable selectedDir
    variable listboxId
    variable gStatic

    ::poLog::Callstack "::poTree::GetDir $args"

    # Set default values for parameters.
    set initialDir [pwd]
    set title "Select directory"

    set gStatic(volList) [::poTree::GetDrives]

    # Scan parameters.
    foreach { opt val } $args {
	switch -exact -- $opt {
	    -hlinecolor  { if { $val != "" } { set gStatic(hlinecolor)  $val } }
	    -vlinecolor  { if { $val != "" } { set gStatic(vlinecolor)  $val } }
	    -hilitecolor { if { $val != "" } { set gStatic(hilitecolor) $val } }
	    -background  { if { $val != "" } { set gStatic(background)  $val } }
	    -subscan     { if { $val != "" } { set gStatic(useSubScan)  $val } }
	    -showhidden  { if { $val != "" } { set gStatic(showHidden)  $val } }
	    -showfiles   { if { $val != "" } { set gStatic(showFiles)   $val } }
	    -rootdir     { if { $val != "" } { set gStatic(volList) [list $val] } }
	    -initialdir  { if { $val != "" && \
                                [file isdirectory [file nativename $val]] } {
			       set initialDir $val 
			   }
			 }
	    -title       { set title $val }
	}
    }

    # Create toplevel window.
    set tw .poTree:GetDir

    if { [winfo exists $tw] } {
	destroy $tw
    }
    toplevel $tw

    # Toplevel container.
    frame $tw.fr -width 300 -height 200
    pack $tw.fr -fill both -expand 1

    $tw config -cursor watch
    wm title $tw "Scanning directories, please wait ..."
    update

    # A container for the tree and one for the buttons.
    set span 1
    frame $tw.fr.toolfr -relief raised -borderwidth 1
    frame $tw.fr.dirfr
    frame $tw.fr.okfr
    if { $gStatic(showFiles) } {
        frame $tw.fr.filefr
	set span 2
    }
    grid $tw.fr.toolfr -row 0 -column 0 -sticky news -ipady 2 -columnspan $span
    grid $tw.fr.dirfr  -row 1 -column 0 -sticky news -ipady 2
    grid $tw.fr.okfr   -row 2 -column 0 -sticky news -ipady 2 -columnspan $span
    grid rowconfigure $tw.fr 1 -weight 1
    grid columnconfigure $tw.fr 0 -weight 1

    if { $gStatic(showFiles) } {
	grid $tw.fr.filefr -row 1 -column 1 -sticky news -ipady 2
	grid columnconfigure $tw.fr 1 -weight 2
	set listboxId [::poWin::CreateScrolledListbox $tw.fr.filefr \
                       "File list" -bg $gStatic(background) \
		       -selectmode extended -exportselection false \
		       -width 30 -height 20]
    }

    set tree [::poWin::CreateScrolledTree \
              $tw.fr.dirfr "Select directory" -rootlist $gStatic(volList) \
	      -bg $gStatic(background) -width 200 -height 300]

    foreach volume $gStatic(volList) {
	if { [string compare $volume "A:/"] == 0} {
	    # Don't try to read the diskette drive when initializing the window.
	    continue
	}
	::poTree::OpenBranch $tree $volume
    }
    ::poTree::OpenBranch $tree $initialDir
    ::poTree::Setselection $tree $initialDir 1

    # Add toolbar group and associated buttons.
    set btnFrame [::poToolbar::AddGroup $tw.fr.toolfr]

    ::poToolbar::AddButton $btnFrame.newfolder \
	[::poBmpData::createfolder] "::poTree::AskNewFolder $tree" \
	"Create new directory" -activebackground white
    ::poToolbar::AddButton $btnFrame.rescan \
	[::poBmpData::rescan] "::poTree::Rescan $tree" \
	"Rescan current directory" -activebackground white

    # Add toolbar group and associated checkbuttons.
    set chkFrame [::poToolbar::AddGroup $tw.fr.toolfr]
    ::poToolbar::AddCheckButton $chkFrame.showhidden \
      [::poBmpData::hidden] ::poTree::ShowHiddenDirs "Show hidden directories" \
      -activebackground white -variable ::poTree::gStatic(showHidden)
    ::poToolbar::AddCheckButton $chkFrame.subscan \
	[::poBmpData::subscan] ::poTree::DoSubscan "Do a subdirectory scan" \
	-activebackground white -variable ::poTree::gStatic(useSubScan)

    # Create Cancel and OK buttons
    button $tw.fr.okfr.b1 -text "Cancel" -command "::poTree::CancelCmd $tree"
    button $tw.fr.okfr.b2 -text "OK"     -command "::poTree::OkCmd $tree" \
			  -default active
    wm protocol $tw WM_DELETE_WINDOW "::poTree::CancelCmd $tree"
    bind  $tw <KeyPress-Escape> "::poTree::CancelCmd $tree"
    bind  $tw <KeyPress-Return> "::poTree::OkCmd $tree"
    pack $tw.fr.okfr.b1 $tw.fr.okfr.b2 -side left -fill x -padx 2 -expand 1

    wm title $tw $title
    $tw config -cursor top_left_arrow

    set oldFocus [focus]
    set oldGrab [grab current $tw]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $tw
    focus $tw

    tkwait variable ::poTree::selectedDir

    catch {focus $oldFocus}
    grab release $tw
    wm withdraw $tw
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

    return $selectedDir
}

proc ::poTree::GetDrives {} {
    global tcl_platform

    ::poLog::Callstack "::poTree::GetDrives"
    set drives {}
    switch $tcl_platform(platform) {
        windows {
    	    set drives [list [list A:/]]
            foreach drive \
             [list B C D E F G H I J K L M N O P Q R S T U V W X Y Z] {
                 if {[catch {file stat ${drive}: dummy}] == 0} {
                     lappend drives [list [format "%s:/" $drive]]
                 }
            }
        }
        default {
            set drives [file volume]
        }
    }
    return $drives
}

proc ::poTree::DriveIcon { dir } {
    global tcl_platform
    variable gStatic

    ::poLog::Callstack "::poTree::DriveIcon $dir"

    switch $tcl_platform(platform) {
        windows {
	    set dir [string trimright $dir "/"]
	    set dir [string trimright $dir "\\"]
	    if { [string compare "A:" $dir] == 0 || \
	       [string compare "B:" $dir] == 0 } {
		return $gStatic(floppydrive)
	    }
            foreach drive \
             [list C D E F G H I J K L M N O P Q R S T U V X Y Z] {
                 if { [string compare [format "%s:" $drive] $dir] == 0} {
                     return $gStatic(diskdrive)
                 }
            }
	    return {}
        }
        default {
	    if { [string compare $dir "/"] == 0} {
		return $gStatic(diskdrive)
	    }
	    return {}
        }
    }
}

proc ::poTree::Init {} {
    variable gStatic
    variable Tree
    global tcl_platform

    ::poLog::Callstack "::poTree::Init"

    option add *highlightThickness 0

    switch $tcl_platform(platform) {
	unix {
	    set gStatic(font) \
	      -adobe-helvetica-medium-r-normal-*-11-80-100-100-p-56-iso8859-1
	}
	windows {
	    set gStatic(font) \
	      -adobe-helvetica-medium-r-normal-*-14-100-100-100-p-76-iso8859-1
	}
	default {
	    set gStatic(font) "Courier"
	}
    }

    #
    # Bitmaps used to show which parts of the tree can be opened.
    #
    set maskdata "#define solid_width 9\n#define solid_height 9"
    append maskdata {
	static unsigned char solid_bits[] = {
	    0xff, 0x01, 0xff, 0x01, 0xff, 0x01, 0xff, 0x01, 0xff,
	    0x01, 0xff, 0x01, 0xff, 0x01, 0xff, 0x01, 0xff, 0x01
	};
    }
    set data "#define open_width 9\n#define open_height 9"
    append data {
	static unsigned char open_bits[] = {
	    0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x7d,
	    0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01
	};
    }
    set gStatic(openbm) [image create bitmap -data $data -maskdata $maskdata \
	  -foreground black -background white]
    set data "#define closed_width 9\n#define closed_height 9"
    append data {
	static unsigned char closed_bits[] = {
	    0xff, 0x01, 0x01, 0x01, 0x11, 0x01, 0x11, 0x01, 0x7d,
	    0x01, 0x11, 0x01, 0x11, 0x01, 0x01, 0x01, 0xff, 0x01
	};
    }
    set gStatic(closedbm) [image create bitmap -data $data -maskdata $maskdata \
	  -foreground black -background white]

    #
    # Images used as folder and drive icons.
    #
    set gStatic(closedfolder) [image create photo -data {
	R0lGODlhEAAQALMAAICAgAAAAMDAwP//AP///////////////wAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAACH5BAkIAAgALAAAAAAQABAAAAQ9EMlJKwUY2ytG
	F8CGAJ/nZZkEEGzrskAwEmZZxrNdn/K667iVzhakDU3F46f42wVRUJQMEaha
	r1eRdluJAAA7
    }]

    set gStatic(openfolder) [image create photo -data {
	R0lGODlhEAAQALMAAMDAwP//AICAgAAAAP///////////////wAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAACH5BAkIAAgALAAAAAAQABAAAARFEMlJKxUY20t6
	FxsiEEBQAkSWSaPpol46iORrA8Kg7mqQj7FgDqernWy6HO3I/M1azJduRru5
	clQeb0BFcL9gcGhMrkQAADs=
    }]

    set gStatic(floppydrive) [image create photo -data {
	R0lGODlhEAAQALMAAICAgP8AAMDAwAAAAP///////////////wAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAACH5BAkIAAgALAAAAAAQABAAAAQ2EMlJq704V8C7
	7xIgjGQ5AgNArGy7cqlpBgIskl5p1/Dgd7wYqaVDfY6dgcTHbDY10Kh0aokA
	ADs=
    }]

    set gStatic(diskdrive) [image create photo -data {
	R0lGODlhEAAQALMAAACAAAAAAMDAwICAgP///////////////wAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAACH5BAkIAAgALAAAAAAQABAAAAQxEMlJq7046z26
	/540CGRpkkMwEGzrsp16noAQj/N52+DHy6/Xr0dMSQLIpDK5aTqfEQA7
    }]

    set gStatic(plainfile) [image create photo -data {
	R0lGODdhEAAQAPIAAAAAAHh4eLi4uPj4+P///wAAAAAAAAAAACwAAAAAEAAQAAADPkixzPOD
	yADrWE8qC8WN0+BZAmBq1GMOqwigXFXCrGk/cxjjr27fLtout6n9eMIYMTXsFZsogXRKJf6u
	P0kCADv/
    }]

    set gStatic(xstart) 10
    set gStatic(ystart) 30
    set gStatic(xinc)   18

    InitDirSel
}

proc ::poTree::InitDirSel {} {
    variable gStatic

    ::poLog::Callstack "::poTree::InitDirSel"

    set gStatic(hlinecolor)  gray50
    set gStatic(vlinecolor)  gray50
    set gStatic(hilitecolor) skyblue
    set gStatic(background)  white
    set gStatic(useSubScan)  0
    set gStatic(showHidden)  0
    set gStatic(showFiles)   0
    set gStatic(volList)     [::poTree::GetDrives]
}

proc ::poTree::GotoNextDir { w } {
    ::poLog::Callstack "::poTree::GotoNextDir $w"
    ::poTree::GotoDir $w next
}

proc ::poTree::GotoPrevDir { w } {
    ::poLog::Callstack "::poTree::GotoPrevDir $w"
    ::poTree::GotoDir $w prev
}

proc ::poTree::GotoParentDir { w } {
    ::poLog::Callstack "::poTree::GotoParentDir $w"
    ::poTree::GotoDir $w parent
}

proc ::poTree::GotoChildDir { w } {
    ::poLog::Callstack "::poTree::GotoChildDir $w"
    ::poTree::GotoDir $w child
}

proc ::poTree::GotoDir { w direction } {
    variable Tree
    variable gStatic

    ::poLog::Callstack "::poTree::GotoDir $w $direction"

    set retVal ""
    set selDir [::poTree::Getselection $w 1]

    set rootInd [lsearch -exact $gStatic(rootList) $selDir]
    if { $rootInd >= 0 } {
	if { [string compare $direction "parent"] == 0 } {
	    ::poLog::Debug "Can not go to parent of $selDir (its root)"
	    return $retVal
	} elseif { [string compare $direction "next"] == 0 } {
	    if { $rootInd < [expr [llength $gStatic(rootList)] -1] } {
		set nextRootInd [expr $rootInd + 1]
		set retVal [lindex $gStatic(rootList) $nextRootInd]
		::poTree::Setselection $w $retVal 1
	    }
	    return $retVal
	} elseif { [string compare $direction "prev"] == 0 } {
	    if { $rootInd >= 1 } {
		set nextRootInd [expr $rootInd - 1]
		set retVal [lindex $gStatic(rootList) $nextRootInd]
		::poTree::Setselection $w $retVal 1
	    }
            return $retVal
	}
    }

    set selPar [file dirname $selDir]
    set selRel [file tail $selDir]

    if { [string compare $direction "parent"] == 0 } {
	::poTree::Setselection $w $selPar 1
	return $selPar
    }
    if { [string compare $direction "child"] == 0 } {
	if { [info exists Tree($w,$selDir,children)] } {
	    if { ! $Tree($w,$selDir,open) } {
		::poTree::OpenBranch $w $selDir
	    }
	    set childDir [lindex $Tree($w,$selDir,children) 0]
	    set retVal [file join $selDir $childDir]
	    ::poTree::Setselection $w $retVal 1
	}
	return $retVal
    }

    set ind [lsearch -exact $Tree($w,$selPar,children) $selRel]

    if { $ind < 0 } {
	error "Fatal error: Could not find directory $selRel"
    }
    if { [string compare $direction "next"] == 0 && \
	 $ind < [expr [llength $Tree($w,$selPar,children)] -1] } {
	set nextInd [expr $ind + 1]
    } elseif { [string compare $direction "prev"] == 0 && $ind >= 1 } {
	set nextInd [expr $ind - 1]
    } else {
        if { [string compare $direction "prev"] == 0 } {
	    set retVal [file dirname $selDir]
	    ::poTree::Setselection $w $retVal 1
	} elseif { [string compare $direction "next"] == 0 } {
	    set rootDir [file dirname $selDir]
            if { [lsearch -exact $gStatic(rootList) $rootDir] < 0 } {
		::poTree::Setselection $w $rootDir 0
		return [GotoDir $w $direction]
	    }
	}
	return $retVal
    }

    set nextRel [lindex $Tree($w,$selPar,children) $nextInd]
    set retVal [file join $selPar $nextRel]
    ::poTree::Setselection $w $retVal 1
}

#
# Create a new tree widget. 
# Parameters in "args" are passed through to the canvas widget, from which
# the tree widget is built of.
# Exception:
#  -rootlist
#  -keepbinding 0|1 (Default: 0)
#  -selectmode single|extended (Default: extended)
#
proc ::poTree::Create {w args} {
    variable Tree
    variable gStatic

    ::poLog::Debug "::poTree::Create $w $args"

    set canvasArgs  {}
    set rootList    {}
    set keepbinding 0
    set selectmode  "extended" 
    foreach { param val } $args {
        if { [string compare $param "-rootlist"] == 0 } {
            set rootList $val
        } elseif { [string compare $param "-keepbinding"] == 0 } {
            set keepbinding $val
        } elseif { [string compare $param "-selectmode"] == 0 } {
            set selectmode $val
        } else {
            lappend canvasArgs $param
            lappend canvasArgs $val
        }
    }
    if { [winfo exists $w] } {
        $w delete all
        unset Tree
    } else {
        eval canvas $w $canvasArgs
    }
    if { [llength $rootList] == 0 } {
        set gStatic(rootList) [::poTree::GetDrives]
    } else {
        set gStatic(rootList) $rootList
    }
    foreach root $gStatic(rootList) {
        ::poTree::Dfltconfig $w $root
    }
    ::poTree::Buildwhenidle $w
    set Tree($w,selection) {}
    set Tree($w,selidx) {}

    focus $w

    if { $keepbinding } {
        return
    }

    $w bind x <Button-1> {
        ::poTree::Setselection %W [::poTree::Labelat %W %x %y]
    }
    if { $selectmode == "extended" } {
	$w bind x <Control-Button-1> {
	    ::poTree::Addselection %W [::poTree::Labelat %W %x %y]
	}
	$w bind x <Shift-Button-1> {
	    ::poTree::AddselectionRange %W [::poTree::Labelat %W %x %y] 
	}
    }
    $w bind x <Double-1> {
        ::poTree::Open %W [::poTree::Labelat %W %x %y]
    }
    catch {bind $w <Key-Down>      "::poTree::GotoNextDir $w"}
    catch {bind $w <Key-Up>        "::poTree::GotoPrevDir $w"}
    catch {bind $w <Key-Left>      "::poTree::GotoParentDir $w"}
    catch {bind $w <Key-Right>     "::poTree::GotoChildDir $w"}
    catch {bind $w <Key-Page_Down> "$w yview scroll  1 pages"}
    catch {bind $w <Key-Page_Up>   "$w yview scroll -1 pages"}
    catch {bind $w <Key-Next>      "$w yview scroll  1 pages"}
    catch {bind $w <Key-Prior>     "$w yview scroll -1 pages"}
    catch {bind $w <Key-Home>      "$w yview moveto 0.0"}
    catch {bind $w <Key-End>       "$w yview moveto 1.0"}
    catch {bind $w <Key-plus>      "::poTree::OpenBranchCB  $w"}
    catch {bind $w <Key-minus>     "::poTree::CloseBranchCB $w"}
    catch {bind $w <Key-r>         "::poTree::Rescan $w"}
}

# Initialize an element of the tree.
#
proc ::poTree::Dfltconfig {w v} {
    variable Tree

    ::poLog::Callstack "::poTree::Dfltconfig $w $v"

    set Tree($w,$v,children) {}
    set Tree($w,$v,open) 0
    set Tree($w,$v,icon) {}
    set Tree($w,$v,tags) {}
}

#
# Insert a new element $v into the tree $w.
#
proc ::poTree::Newitem {w v args} {
    variable Tree

    ::poLog::Callstack "::poTree::Newitem $w $v $args"

    set dir [file dirname $v]
    set n [file tail $v]
  
    if { ! [info exists Tree($w,$dir,children)] } {
        set Tree($w,$dir,children) {}
    }
    set i [lsearch -exact $Tree($w,$dir,children) $n]
    if { $i < 0 } {
	lappend Tree($w,$dir,children) $n
	set Tree($w,$dir,children) [lsort -dictionary $Tree($w,$dir,children)]
	::poTree::Dfltconfig $w $v
	foreach {op arg} $args {
	    switch -exact -- $op {
                -image {set Tree($w,$v,icon) $arg}
                -tags {set Tree($w,$v,tags) $arg}
            }
	}
    }
}

#
# Delete element $v from the tree $w.  If $v is /, then the widget is
# deleted.
#
proc ::poTree::delitem {w v} {
    variable Tree

    ::poLog::Callstack "::poTree::delitem $w $v"

    if {![info exists Tree($w,$v,open)]} return

    foreach c $Tree($w,$v,children) {
	catch {::poTree::delitem $w [file join $v $c]}
    }
    unset Tree($w,$v,open)
    unset Tree($w,$v,children)
    unset Tree($w,$v,icon)

    if { ! [::poTree::IsVolume $v] } {
	set dir [file dirname $v]
        set n [file tail $v]
        set i [lsearch -exact $Tree($w,$dir,children) $n]
        if { $i >= 0 } {
	    set Tree($w,$dir,children) [lreplace $Tree($w,$dir,children) $i $i]
        }
    }
    ::poTree::Buildwhenidle $w
}

proc ::poTree::AddToListbox { dir lbox fileList } {
    poLog::Info "AddToListbox $dir"
    $lbox delete 0 end
    foreach elem $fileList {
	$lbox insert end $elem
    }
    ::poWin::SetScrolledTitle $lbox "[llength $fileList] files"
}

#
# Change the selection to the indicated item
#
proc ::poTree::Setselection {w v { jump 0 } } {
    variable Tree
    variable gStatic
    variable listboxId

    ::poLog::Callstack "::poTree::Setselection $w $v $jump"

    if { [string length $v] == 0 } {
        return
    }
    ::poTree::Drawselection $w $jump
    set Tree($w,selection) [list $v]
    ::poTree::Drawselection $w $jump
    ::poWin::SetScrolledTitle $w [::poTree::Getselection $w 1]

    if { $gStatic(showFiles) } {
	AddToListbox $v $listboxId [lindex [::poMisc::GetDirList $v 0 $gStatic(showFiles) $gStatic(showHidden) $gStatic(showHidden)] 1]
    }
}

proc ::poTree::Addselection {w v} {
    variable Tree

    ::poLog::Callstack "::poTree::Addselection $w $v"

    set vInd [lsearch -exact $Tree($w,selection) $v]
    if { $vInd >= 0 } {
	set Tree($w,selection) [lreplace $Tree($w,selection) $vInd $vInd]
    } else {
	set Tree($w,selection) [lsort -dictionary \
			       [lappend Tree($w,selection) $v]]
    }
    ::poTree::Drawselection $w
}

proc ::poTree::AddselectionRange {w v} {
    variable Tree
    variable gStatic

    ::poLog::Callstack "::poTree::AddselectionRange $w $v"

    set vInd [lsearch -exact $Tree($w,selection) $v]
    if { $vInd >= 0 } {
	set Tree($w,selection) [lreplace $Tree($w,selection) $vInd $vInd]
    } else {
	set Tree($w,selection) [lsort -dictionary \
			       [lappend Tree($w,selection) $v]]
    }
    ::poTree::Drawselection $w
}

# 
# Retrieve the current selection
#
proc ::poTree::Getselection { w { firstEntryOnly 0 } } {
    variable Tree

    ::poLog::Callstack "::poTree::Getselection $w $firstEntryOnly"
    if { $firstEntryOnly } {
        return [lindex $Tree($w,selection) 0]
    } else {
        return $Tree($w,selection)
    }
}

# Internal use only.
# Draw the tree on the canvas
proc ::poTree::Build { w } {
    variable Tree
    variable gStatic

    ::poLog::Callstack "::poTree::Build $w"

    $w delete all
    catch {unset Tree($w,buildpending)}
    set Tree($w,y) $gStatic(ystart)
    
    set dirList $gStatic(rootList)
    foreach dir $dirList {
        ::poTree::Buildlayer $w $dir $gStatic(xstart)
    }
    $w config -scrollregion [$w bbox all]
    ::poTree::Drawselection $w
    $w itemconfigure vline -fill $gStatic(vlinecolor)
    $w itemconfigure hline -fill $gStatic(hlinecolor)
}

proc ::poTree::CloseBranch { w v } {
    variable Tree

    ::poLog::Callstack "::poTree::CloseBranch $w $v"

    set Tree($w,$v,open) 0
    ::poTree::Build $w
}

proc ::poTree::OpenBranch { w v } {
    variable Tree

    ::poLog::Callstack "::poTree::OpenBranch($w $v)"
    set path ""
    foreach p [file split $v] {
	set path [file join $path $p]	
	if { ! [info exists Tree($w,$path,open)] || ! $Tree($w,$path,open) } {
	    ::poLog::Debug "OpenBranch: Calling Open ($path)"
	    if { [file isdirectory $path] } {
		::poTree::Open $w $path
	    }
	}
    }
 #   set Tree($w,$v,open) 1
 #   ::poTree::Open $w $v
}

proc ::poTree::DrawIconAndText { w inx iny fileName str } {
    variable Tree
    variable gStatic

    ::poLog::Callstack "::poTree::DrawIconAndText $w $inx $iny $fileName $str"

    $w create line $inx $iny [expr $inx+12] $iny -tags hline
    set icon [::poTree::DriveIcon $fileName]
    if { [llength $icon] != 0 } {
	set Tree($w,$fileName,icon) $icon
    } else {
	set Tree($w,$fileName,icon) $gStatic(closedfolder)
    }
    set icon $Tree($w,$fileName,icon)
    set taglist x
    foreach tag $Tree($w,$fileName,tags) {
	lappend taglist $tag
    }
    set x [expr $inx+12]
    if { [string length $icon] > 0 } {
	set k [$w create image $x $iny -image $icon -anchor w -tags $taglist]
        incr x 20
        set Tree($w,tag,$k) $fileName
    }
    set j [$w create text $x $iny -text $str -font $gStatic(font) \
                                  -anchor w -tags $taglist]
    set Tree($w,tag,$j) $fileName
    set Tree($w,$fileName,tag) $j

    if { [info exists Tree($w,$fileName,children)] && \
         [string length $Tree($w,$fileName,children)] } {
	if {$Tree($w,$fileName,open)} {
            set j [$w create image $inx $iny -image $gStatic(openbm)]
            $w bind $j <1> "::poTree::CloseBranch $w \"$fileName\""
        } else {
            set j [$w create image $inx $iny -image $gStatic(closedbm)]
            $w bind $j <1> "::poTree::OpenBranch $w \"$fileName\""
        }
    }
    set j [$w create line $inx [expr $gStatic(ystart)] \
			  $inx [expr $iny+1] -tags vline]
    $w lower $j
}

# Internal use only.
# Build a single layer of the tree on the canvas.  Indent by $in pixels
proc ::poTree::Buildlayer {w v in} {
    variable Tree
    variable gStatic

    ::poLog::Callstack "::poTree::Buildlayer $w $v $in"

    set dirList [list $v]
    set root 0
    set start [expr $Tree($w,y)-10] ; # Was 10
    foreach dir $gStatic(rootList) {
        if { [string compare $v $dir] == 0 } {
            set root 1
            set start [expr $Tree($w,y)-0] ; # Was 10
            incr in $gStatic(xinc)
            set dirList [list $v]
            break
        }
    }

    set y $Tree($w,y)
    foreach dir $dirList {
        if { $root } {
            ::poTree::DrawIconAndText $w $gStatic(xstart) $Tree($w,y) $dir $dir
            incr Tree($w,y) 17
	    if { ! [info exists Tree($w,$dir,open)] || \
	         ! $Tree($w,$dir,open) } {
	        # ::poLog::Debug "Breaking with continue"
	        continue
            }
        }
        foreach c [lsort -dictionary $Tree($w,$dir,children)] {
            set fileName [file join $dir $c]
            set y $Tree($w,y)
            incr Tree($w,y) 17
    
            $w create line $in $y [expr $in+12] $y -tags hline
            set icon $Tree($w,$fileName,icon)
            set taglist x
            foreach tag $Tree($w,$fileName,tags) {
                lappend taglist $tag
            }
            set x [expr $in+12]
            if {[string length $icon]>0} {
                set k [$w create image $x $y -image $icon -anchor w -tags $taglist]
                incr x 20
                set Tree($w,tag,$k) $fileName
            }
            set j [$w create text $x $y -text $c -font $gStatic(font) \
                                        -anchor w -tags $taglist]
            set Tree($w,tag,$j) $fileName
            set Tree($w,$fileName,tag) $j
            if {[string length $Tree($w,$fileName,children)]} {
                if {$Tree($w,$fileName,open)} {
                    set j [$w create image $in $y -image $gStatic(openbm)]
                    $w bind $j <1> "::poTree::CloseBranch $w \"$fileName\""
                    ::poTree::Buildlayer $w "$fileName" [expr $in+$gStatic(xinc)]
                } else {
                    set j [$w create image $in $y -image $gStatic(closedbm)]
                    $w bind $j <1> "::poTree::OpenBranch $w \"$fileName\""
                }
            }
        }
    }
    set j [$w create line $in $start $in [expr $y+1] -tags vline]
    $w lower $j
}

proc ::poTree::OpenBranchCB { w } {
    ::poLog::Callstack "::poTree::OpenBranchCB $w"
    ::poTree::OpenBranch $w [::poTree::Getselection $w 1]
}

proc ::poTree::CloseBranchCB { w } {
    ::poLog::Callstack "::poTree::CloseBranchCB $w"
    ::poTree::CloseBranch $w [::poTree::Getselection $w 1]
}

# Internal use only.
# Scan directory $v and insert all subdirectories into the tree. 

proc ::poTree::ScanDir { w v } {
    variable gStatic
    variable listboxId

    ::poLog::Info "::poTree::ScanDir $w $v"

    ::poTree::Newitem $w $v -image $gStatic(closedfolder)
    set dirCont [::poMisc::GetDirList $v 1 0 $gStatic(showHidden) $gStatic(showHidden)]
    #puts "dircont = <$dirCont>"
    set dirList  [lindex $dirCont 0]
    foreach dirName $dirList {
	::poTree::Newitem $w [string trimright $dirName /] \
			  -image $gStatic(closedfolder)

	if { $gStatic(useSubScan) } {
	    set subDirList [lindex [::poMisc::GetDirList $dirName 1 0 $gStatic(showHidden) $gStatic(showHidden)] 0]
	    foreach subDirName $subDirList {
		::poTree::Newitem $w [string trimright $subDirName /] \
				  -image $gStatic(closedfolder)
	    }
	}
    }
    ::poTree::Buildwhenidle $w
}

# Open a tree
#
proc ::poTree::Open {w v } {
    variable Tree

    ::poLog::Info "::poTree::Open $w $v"

    ::poTree::ScanDir $w $v
    ::poTree::Setselection $w $v
    if { [info exists Tree($w,$v,open)] && \
	 $Tree($w,$v,open) == 0 && \
         [info exists Tree($w,$v,children)] && \
         [string length $Tree($w,$v,children)] > 0 } {
	set Tree($w,$v,open) 1
	::poTree::Build $w
    }
}

proc ::poTree::Close {w v} {
    variable Tree

    ::poLog::Callstack "::poTree::Close $w $v"

    if {[info exists Tree($w,$v,open)] && $Tree($w,$v,open)==1} {
        set Tree($w,$v,open) 0
        ::poTree::Build $w
    }
}

# Internal use only.
# Draw the selection highlight
proc ::poTree::Drawselection { w { jump 0 } } {
    variable Tree
    variable gStatic

    ::poLog::Callstack "::poTree::Drawselection $w $jump"

    if {[string length $Tree($w,selidx)]} {
        foreach v $Tree($w,selidx) {
            $w delete $v
        }
    }
    foreach v $Tree($w,selection) {
        if {[string length $v]==0} return
        if {![info exists Tree($w,$v,tag)]} return
        set bbox [$w bbox $Tree($w,$v,tag)]
        if {[llength $bbox]==4} {
            set i [eval $w create rectangle $bbox \
			   -fill $gStatic(hilitecolor) -outline {{}}]
            if { $jump } {
	        set bY1 [lindex $bbox 1]
	        set bY2 [lindex $bbox 3]
	        set sY1 [lindex [$w cget -scrollregion] 1]
	        set sY2 [lindex [$w cget -scrollregion] 3]
		set moveTo [expr double($bY1 - $sY1) / ($sY1 + $sY2)]
	        $w yview moveto $moveTo
            }
            lappend Tree($w,selidx) $i
            $w lower $i
        } else {
            set Tree($w,selidx) {}
        }
    }
}

# Internal use only
# Call ::poTree::Build then next time we're idle

proc ::poTree::Buildwhenidle { w } {
    variable Tree

    ::poLog::Callstack "::poTree::Buildwhenidle $w"

    if {![info exists Tree($w,buildpending)]} {
        set Tree($w,buildpending) 1
        after idle "::poTree::Build $w"
    }
}

#
# Return the full pathname of the label for widget $w that is located
# at real coordinates $x, $y
#

proc ::poTree::Labelat {w x y} {
    variable Tree

    ::poLog::Callstack "::poTree::Labelat $w $x $y"

    set x [$w canvasx $x]
    set y [$w canvasy $y]
    foreach m [$w find overlapping $x $y $x $y] {
        if {[info exists Tree($w,tag,$m)]} {
            return $Tree($w,tag,$m)
        }
    }
    return ""
}

::poTree::Init
catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poWin.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poWin
#       Copyright:      Paul Obermeier 2000-2003 / paul@poSoft.de
#       Filename:       poWin.tcl
#
#       First Version:  2000 / 10 / 22
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#
############################################################################ 

package provide poTklib 1.0
package provide poWin 1.0

namespace eval ::poWin {
    namespace export GetFixedFont

    namespace export Raise
    namespace export IsToplevel

    namespace export CreateHelpWin
    namespace export CreateListSelWin
    namespace export CreateListConfirmWin

    namespace export CreateOneFileInfoWin
    namespace export CreateTwoFileInfoWin

    namespace export SetScrolledTitle
    namespace export CreateScrolledWidget
    namespace export CreateScrolledFrame
    namespace export CreateScrolledListbox
    namespace export CreateScrolledTablelist
    namespace export CreateScrolledText
    namespace export CreateScrolledCanvas
    namespace export CreateScrolledTable
    namespace export CreateScrolledTree

    namespace export SetSyncTitle
    namespace export CreateSyncWidget
    namespace export CreateSyncListbox
    namespace export CreateSyncText
    namespace export CreateSyncCanvas

    namespace export CanvasSeeItem

    namespace export EntryBox
    namespace export ShowEntryBox
    namespace export ShowLoginBox

    namespace export StartScreenSaver

    namespace export LoadFileToTextWidget

    variable syncEnabled
    variable entryBoxTemp
    variable login
    variable loginUser
    variable loginPassword
    variable infoWinNo 1
    variable xPosShowEntryBox -1
    variable yPosShowEntryBox -1
}

proc ::poWin::GetFixedFont {} {
    global tcl_platform

    if { $tcl_platform(platform) eq "windows" } {
	return [list -family Courier -size 10 -weight normal -underline 0 -slant roman -overstrike 0]
    }
    switch -glob $tcl_platform(os) {
	IRIX* {
	    return "Courier"
	}
	Darwin* {
	    return "Courier"
	}
	SunOS* {
	    return "Courier"
	}
	Linux* {
            return [list -family Courier -size 10 -weight normal -underline 0 -slant roman -overstrike 0]
	}
	default {
	    return "Courier"
	}
    }
}

proc ::poWin::IsToplevel { path } {
    string equal $path [winfo toplevel $path]
}

proc ::poWin::Raise { tw } {
    wm deiconify $tw
    update
    raise $tw
}

proc ::poWin::CreateHelpWin { helpStr } {

    set tw .poWin:HelpWin
    set title "Help Window"

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    toplevel $tw
    wm title $tw $title

    frame $tw.fr -relief raised -borderwidth 2

    set textWid [CreateScrolledText $tw.fr "" -wrap word]
    bind $textWid <KeyPress-Escape> "destroy $tw"
    button $tw.close -text "Close" -command "destroy $tw"
    pack $tw.close -expand 1 -fill x -side bottom
    pack $tw.fr -expand 1 -fill both

    $textWid insert end $helpStr
    $textWid configure -state disabled -cursor top_left_arrow
    focus $textWid
}

proc ::poWin::SelAllInList { listBox } {
    $listBox selection set 0 end
}

proc ::poWin::ListOkCmd {} {
    set ::poWin::listBoxFlag 1
}

proc ::poWin::ListCancelCmd {} {
    set ::poWin::listBoxFlag 0
}

proc ::poWin::CreateListSelWin { selList title subTitle } {

    set tw .poWin:ListWin

    if { [llength $selList] == 0 } {
	return {}
    }

    toplevel $tw
    wm title $tw "$title"
    wm resizable $tw true true

    frame $tw.listfr
    frame $tw.selfr
    frame $tw.okfr
    pack $tw.listfr $tw.selfr $tw.okfr -side top -fill x -expand 1

    set listBox [::poWin::CreateScrolledListbox $tw.listfr \
                 $subTitle -width 40 -selectmode extended \
		 -exportselection false -bg white]

    button $tw.selfr.b1 -text "Select all" \
			-command "::poWin::SelAllInList $listBox"
    pack $tw.selfr.b1 -side left -fill x -expand 1 -padx 2 -pady 2

    # Create Cancel and OK buttons
    button $tw.okfr.b1 -text "Cancel" -command "::poWin::ListCancelCmd"
    button $tw.okfr.b2 -text "OK" -default active \
	       -command "::poWin::ListOkCmd"
    pack $tw.okfr.b1 $tw.okfr.b2 -side left -fill x -padx 2 -expand 1

    bind $tw <KeyPress-Return> "::poWin::ListOkCmd"
    bind $tw <KeyPress-Escape> "::poWin::ListCancelCmd"

    # Now fill the listbox with the file names and select all.
    foreach f $selList {
	$listBox insert end $f
    }
    $listBox select set 0 end

    update

    set oldFocus [focus]
    set oldGrab [grab current $tw]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $tw
    focus $listBox

    tkwait variable ::poWin::listBoxFlag

    catch {focus $oldFocus}
    grab release $tw

    set indList [$listBox curselection]
    set retList {}
    if { $::poWin::listBoxFlag && [llength $indList] != 0 } {
	foreach ind $indList {
	    lappend retList [$listBox get $ind]
	}
    }

    destroy $tw
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

    return $retList
}

proc ::poWin::CreateListConfirmWin { selList title subTitle } {

    set tw .poWin:ListConfirmWin

    if { [llength $selList] == 0 } {
	return 0
    }

    toplevel $tw
    wm title $tw "$title"
    wm resizable $tw true true

    frame $tw.textfr
    frame $tw.selfr
    frame $tw.okfr
    pack $tw.textfr $tw.selfr $tw.okfr -side top -fill x -expand 1

    set textId [::poWin::CreateScrolledText $tw.textfr \
                $subTitle -wrap none -height 10 -width 60 -bg white]

    # Create Cancel and OK buttons
    button $tw.okfr.b1 -text "Cancel" -command "::poWin::ListCancelCmd"
    button $tw.okfr.b2 -text "OK" -default active \
	       -command "::poWin::ListOkCmd"
    pack $tw.okfr.b1 $tw.okfr.b2 -side left -fill x -padx 2 -expand 1

    bind $tw <KeyPress-Return> "::poWin::ListOkCmd"
    bind $tw <KeyPress-Escape> "::poWin::ListCancelCmd"

    # Now fill the listbox with the file names and select all.
    foreach f $selList {
	$textId insert end $f
	$textId insert end "\n"
    }
    $textId configure -state disabled -cursor top_left_arrow

    update

    set oldFocus [focus]
    set oldGrab [grab current $tw]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $tw
    focus $tw.okfr.b2

    tkwait variable ::poWin::listBoxFlag

    catch {focus $oldFocus}
    grab release $tw

    destroy $tw
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

    return $::poWin::listBoxFlag
}

proc ::poWin::DestroyOneFileInfoWin { w { phImg "" } } {
    catch {image delete $phImg}
    destroy $w
}

proc ::poWin::CreateOneFileInfoWin { fileName attrList \
                                     {phImg ""} {btnProc ""} } {
    variable infoWinNo

    set tw .poWin:InfoWin$infoWinNo
    incr infoWinNo
    catch { destroy $tw }

    toplevel $tw
    wm title $tw "Attributes of [file tail $fileName]"
    wm resizable $tw true false

    # If a thumbnail photo image has been supplied in phImg, show it.
    if { $phImg ne "" } {
	frame $tw.fr
	pack $tw.fr
	label $tw.fr.l -image $phImg
	pack $tw.fr.l -pady 2
    }
    # Generate left column with text labels.
    set row 0
    frame $tw.fr0 -relief sunken -borderwidth 1
    foreach listEntry $attrList {
	label $tw.fr0.k$row -text [format "%s:" [lindex $listEntry 0]]
	label $tw.fr0.v$row -text [lindex $listEntry 1]
        grid  $tw.fr0.k$row -row $row -column 0 -sticky nw
        grid  $tw.fr0.v$row -row $row -column 1 -sticky nw
	incr row
    }

    # Create Close and View button
    frame $tw.fr1 -relief sunken -borderwidth 1
    if { $btnProc ne "" } {
	button $tw.fr1.bView -text "View" -command [list $btnProc $fileName]
	pack $tw.fr1.bView -side left -fill x -padx 2 -expand 1
    }
    button $tw.fr1.bClose -text "Close" -default active \
           -command "::poWin::DestroyOneFileInfoWin $tw $phImg"
    pack $tw.fr1.bClose -side left -fill x -padx 2 -expand 1

    pack $tw.fr0 $tw.fr1 -side top -expand 1 -fill x

    bind $tw <Escape> "::poWin::DestroyOneFileInfoWin $tw $phImg"
    bind $tw <Return> "::poWin::DestroyOneFileInfoWin $tw $phImg"
    focus $tw
    return $tw
}

proc ::poWin::CreateTwoFileInfoWin { leftFile rightFile leftAttr rightAttr } {
    variable infoWinNo

    set tw .poWin:InfoWin$infoWinNo
    incr infoWinNo
    catch { destroy $tw }

    toplevel $tw
    wm title $tw "[file tail $leftFile] versus [file tail $rightFile]"
    wm resizable $tw true false

    # Generate left column with text labels.
    set row 0
    frame $tw.fr0 -relief sunken -borderwidth 1
    foreach leftEntry $leftAttr rightEntry $rightAttr {
	label $tw.fr0.kl$row -text [format "%s:" [lindex $leftEntry 0]]
	label $tw.fr0.vl$row -text [lindex $leftEntry 1]
	label $tw.fr0.vr$row -text [lindex $rightEntry 1]
        grid  $tw.fr0.kl$row -row $row -column 0 -sticky nw
        grid  $tw.fr0.vl$row -row $row -column 1 -sticky nw
        grid  $tw.fr0.vr$row -row $row -column 2 -sticky nw
	incr row
    }

    # Create OK button
    frame $tw.fr1 -relief sunken -borderwidth 1
    button $tw.fr1.b -text "OK" -command "destroy $tw" -default active
    pack $tw.fr1.b -side left -fill x -padx 2 -expand 1
    pack $tw.fr0 $tw.fr1 -side top -expand 1 -fill x

    bind $tw <Escape> "destroy $tw"
    bind $tw <Return> "destroy $tw"
    focus $tw
    return $tw
}

proc ::poWin::SetScrolledTitle { w titleStr { fgColor "black" } } {
    set pathList [split $w "."]
    # Index -3 is needed for CreateScrolledFrame.
    # Index -2 is needed for all other widget types.
    foreach ind { -2 -3 } {
	set parList  [lrange $pathList 0 [expr [llength $pathList] $ind]]
	set parPath  [join $parList "."]

	set labelPath $parPath
	append labelPath ".label"
	if { [winfo exists $labelPath] } {
	    $labelPath configure -text $titleStr -foreground $fgColor
	    break
	}
    }
}

proc ::poWin::CreateScrolledWidget { wType w titleStr args } {
    if { [winfo exists $w.par] } {
        destroy $w.par
    }
    frame $w.par
    if { $titleStr ne "" } {
        label $w.par.label -text "$titleStr"
    }
    eval { $wType $w.par.widget \
	    -xscrollcommand "$w.par.xscroll set" \
	    -yscrollcommand "$w.par.yscroll set" } $args
    scrollbar $w.par.xscroll -command "$w.par.widget xview" -orient horizontal
    scrollbar $w.par.yscroll -command "$w.par.widget yview" -orient vertical
    set rowNo 0
    if { $titleStr ne "" } {
	set rowNo 1
        grid $w.par.label -sticky ew -columnspan 2
    }
    grid $w.par.widget $w.par.yscroll -sticky news
    grid $w.par.xscroll               -sticky ew
    grid rowconfigure    $w.par $rowNo -weight 1
    grid columnconfigure $w.par 0      -weight 1
    pack $w.par -side top -fill both -expand 1
    return $w.par.widget
}

proc ::poWin::ScrolledFrameCfgCB {w width height} {
    set newSR [list 0 0 $width $height]
    if { ! [string equal [$w.canv cget -scrollregion] $newSR] } {
	$w.canv configure -scrollregion $newSR
    }
}

proc ::poWin::CreateScrolledFrame { w titleStr args } {
    frame $w.par
    pack $w.par -fill both -expand 1
    if { $titleStr ne "" } {
	label $w.par.label -text "$titleStr" -borderwidth 2 -relief raised
    }
    eval {canvas $w.par.canv -xscrollcommand [list $w.par.xscroll set] \
                             -yscrollcommand [list $w.par.yscroll set]} $args
    scrollbar $w.par.xscroll -orient horizontal -command "$w.par.canv xview"
    scrollbar $w.par.yscroll -orient vertical   -command "$w.par.canv yview"
    set fr [frame $w.par.canv.fr -borderwidth 0 -highlightthickness 0]
    $w.par.canv create window 0 0 -anchor nw -window $fr

    set rowNo 0
    if { $titleStr ne "" } {
	set rowNo 1
        grid $w.par.label -sticky ew -columnspan 2
    }
    grid $w.par.canv $w.par.yscroll -sticky news
    grid $w.par.xscroll             -sticky ew
    grid rowconfigure    $w.par $rowNo -weight 1
    grid columnconfigure $w.par 0      -weight 1
    # This binding makes the scroll-region of the canvas behave correctly as
    # you place more things in the content frame.
    bind $fr <Configure> [list ::poWin::ScrolledFrameCfgCB $w.par %w %h]
    $w.par.canv configure -borderwidth 0 -highlightthickness 0
    return $fr
}

proc ::poWin::CreateScrolledListbox { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget listbox $w $titleStr} $args ]
}

proc ::poWin::CreateScrolledTablelist { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget tablelist::tablelist $w $titleStr} $args ]
}

proc ::poWin::CreateScrolledText { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget text $w $titleStr} $args ]
}

proc ::poWin::CreateScrolledCanvas { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget canvas $w $titleStr} $args ]
}

proc ::poWin::CreateScrolledTable { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget table $w $titleStr} $args ]
}

proc ::poWin::CreateScrolledTree { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget ::poTree::Create \
						 $w $titleStr} $args ]
}

proc ::poWin::Xscroll { scrollWidget leftWidget rightWidget x1 x2 } {
    ::poLog::Callstack "::poWin::Xscroll $scrollWidget \
                        $leftWidget $rightWidget $x1 $x2"

    set size1 [expr {[lindex [$leftWidget xview] 1] - \
                     [lindex [$leftWidget xview] 0]}]
    set size2 [expr {[lindex [$rightWidget xview] 1] - \
                     [lindex [$rightWidget xview] 0]}]

    eval $scrollWidget set $x1 $x2
    eval $leftWidget   xview moveto $x1
    eval $rightWidget  xview moveto $x1
}

proc ::poWin::Yscroll { scrollWidget leftWidget rightWidget y1 y2 } {
    ::poLog::Callstack "::poWin::Yscroll $scrollWidget \
                        $leftWidget $rightWidget $y1 $y2"

    eval $scrollWidget set $y1 $y2
    eval $leftWidget   yview moveto $y1
    eval $rightWidget  yview moveto $y1
}

proc ::poWin::Xview { leftWidget rightWidget args } {
    ::poLog::Callstack "::poWin::Xview $leftWidget $rightWidget $args"
    eval $leftWidget  xview $args
    # eval $rightWidget xview $args
}

proc ::poWin::Yview { leftWidget rightWidget args } {
    ::poLog::Callstack "::poWin::Yview $leftWidget $rightWidget $args"
    eval $leftWidget  yview $args
    #eval $rightWidget yview $args
}

proc ::poWin::SetSyncTitle { w leftTitle rightTitle } {
    set pathList [split $w "."]
    set parList  [lrange $pathList 0 [expr [llength $pathList] -2]]
    set parPath  [join $parList "."]

    set leftLabelPath $parPath
    append leftLabelPath ".leftlabel"
    set rightLabelPath $parPath
    append rightLabelPath ".rightlabel"

    if { $leftTitle ne "" && \
	 [winfo exists $leftLabelPath] } {
	$leftLabelPath configure -text $leftTitle
    }
    if { $rightTitle ne "" && \
	 [winfo exists $rightLabelPath] } {
	$rightLabelPath configure -text $rightTitle
    }
}

proc ::poWin::CreateSyncWidget { wType w leftTitle rightTitle args } {
    frame $w.par
    if { $leftTitle ne "" } {
        label $w.par.leftlabel -text "$leftTitle"
    }
    if { $rightTitle ne "" } {
        label $w.par.rightlabel -text "$rightTitle"
    }

    eval { $wType $w.par.leftwidget \
	    -xscrollcommand "::poWin::Xscroll $w.par.xscroll \
	                     $w.par.leftwidget $w.par.rightwidget" \
	    -yscrollcommand "::poWin::Yscroll $w.par.yscroll \
	                     $w.par.leftwidget $w.par.rightwidget" } $args
    eval { $wType $w.par.rightwidget \
	    -xscrollcommand "::poWin::Xscroll $w.par.xscroll \
	                     $w.par.leftwidget $w.par.rightwidget" \
	    -yscrollcommand "::poWin::Yscroll $w.par.yscroll \
	                     $w.par.leftwidget $w.par.rightwidget" } $args

    scrollbar $w.par.xscroll -orient horizontal \
	      -command "::poWin::Xview $w.par.leftwidget $w.par.rightwidget"
    scrollbar $w.par.yscroll -orient vertical \
	      -command "::poWin::Yview $w.par.leftwidget $w.par.rightwidget"

    set rowNo 0
    if { $leftTitle ne "" || $rightTitle ne "" } {
        grid $w.par.leftlabel  -sticky ew -row 0 -column 0
        grid $w.par.rightlabel -sticky ew -row 0 -column 1 -columnspan 2
	set rowNo 1
    }
    grid $w.par.leftwidget  -sticky news -row 1 -column 0
    grid $w.par.rightwidget -sticky news -row 1 -column 1
    grid $w.par.xscroll -sticky ew   -row 2 -column 0 -columnspan 2
    grid $w.par.yscroll -sticky news -row 1 -column 2 -rowspan 1
    grid rowconfigure    $w.par $rowNo -weight 1
    grid columnconfigure $w.par 0 -weight 1
    grid columnconfigure $w.par 1 -weight 1
    pack $w.par -side top -fill both -expand 1
    return [list $w.par.leftwidget $w.par.rightwidget]
}

proc ::poWin::CreateSyncListbox { w leftTitle rightTitle args } {
    return [eval {::poWin::CreateSyncWidget listbox $w \
					     $leftTitle $rightTitle} $args ]
}

proc ::poWin::CreateSyncText { w leftTitle rightTitle args } {
    return [eval {::poWin::CreateSyncWidget text $w \
					     $leftTitle $rightTitle} $args ]
}

proc ::poWin::CreateSyncCanvas { w leftTitle rightTitle args } {
    return [eval {::poWin::CreateSyncWidget canvas $w \
					     $leftTitle $rightTitle} $args ]
}

proc ::poWin::CanvasSeeItem { canv item } {
    set box [$canv bbox $item]

    if { [string match {} $box] } { return }

    if { [string match {} [$canv cget -scrollregion]] } {
	# People really should set -scrollregion you know...
	foreach {x y x1 y1} $box {
	    set x [expr round(2.5 * ($x1+$x) / [winfo width  $canv])]
	    set y [expr round(2.5 * ($y1+$y) / [winfo height $canv])]
	}
	$canv xview moveto 0
	$canv yview moveto 0
	$canv xview scroll $x units
	$canv yview scroll $y units
    } else {
	# If -scrollregion is set properly, use this
	foreach {x y x1 y1} \
	    $box          {top btm} \
	    [$canv yview] {left right} \
	    [$canv xview] {p q xmax ymax} \
	    [$canv cget -scrollregion] \
	{
	    set xpos [expr (($x1+$x) / 2.0) / $xmax - ($right-$left) / 2.0]
	    set ypos [expr (($y1+$y) / 2.0) / $ymax - ($btm-$top)    / 2.0]
	}
	$canv xview moveto $xpos
	$canv yview moveto $ypos
    }
}

proc ::poWin::EvalCommand { cmd } {
    variable entryBoxTemp

    eval [list $cmd $entryBoxTemp]
    ::poWin::DestroyEntryBox
}

proc ::poWin::DestroyEntryBox {} {
    variable xPosShowEntryBox
    variable yPosShowEntryBox

    set xPosShowEntryBox [winfo rootx .poWin:EntryBox]
    set yPosShowEntryBox [winfo rooty .poWin:EntryBox]
    destroy .poWin:EntryBox
}

proc ::poWin::ShowEntryBox { cmd var title { msg "" } { noChars 30 } { fontName "" } } {
    variable entryBoxTemp
    variable xPosShowEntryBox
    variable yPosShowEntryBox

    set tw ".poWin:EntryBox"
    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    toplevel $tw
    wm title $tw $title
    wm resizable $tw false false
    if { $xPosShowEntryBox < 0 || $yPosShowEntryBox < 0 } {
        set xPosShowEntryBox [expr [winfo screenwidth .]  / 2]
        set yPosShowEntryBox [expr [winfo screenheight .] / 2]
    }
    wm geometry $tw [format "+%d+%d" $xPosShowEntryBox $yPosShowEntryBox]

    frame $tw.fr1
    frame $tw.fr2
    set entryBoxTemp $var
    if { $msg ne "" } {
        label $tw.fr1.l -text $msg
    }
    entry $tw.fr1.e -textvariable ::poWin::entryBoxTemp
    $tw.fr1.e configure -width $noChars
    if { $fontName ne "" } {
	$tw.fr1.e configure -font $fontName
    }

    $tw.fr1.e selection range 0 end

    bind $tw <KeyPress-Return> "::poWin::EvalCommand $cmd"
    bind $tw <KeyPress-Escape> "::poWin::DestroyEntryBox"
    if { $msg ne "" } {
        pack $tw.fr1.l -fill x -expand 1 -side top
    }
    pack $tw.fr1.e -fill x -expand 1 -side top

    button $tw.fr2.b1 -text "Cancel" -command "::poWin::DestroyEntryBox"
    button $tw.fr2.b2 -text "OK"     \
	   -command "::poWin::EvalCommand $cmd" -default active
    pack $tw.fr2.b1 -side left -fill x -padx 2 -expand 1
    pack $tw.fr2.b2 -side left -fill x -padx 2 -expand 1
    pack $tw.fr1 -side top -expand 1 -fill x
    pack $tw.fr2 -side top -expand 1 -fill x
    focus $tw.fr1.e
    grab $tw
}

proc ::poWin::LoginOkCmd {} {
    variable login

    set login 1
}

proc ::poWin::LoginCancelCmd {} {
    variable login

    set login 0
}

proc ::poWin::ShowLoginBox { title { user guest } { fontName "" } } {
    variable login
    variable loginUser
    variable loginPassword

    set tw ".poWin:LoginBox"
    if { [winfo exists $tw] } {
	destroy $tw
	set loginPassword ""
    }

    toplevel $tw
    wm title $tw $title
    wm resizable $tw false false

    frame $tw.fr1
    frame $tw.fr2
    set loginUser $user
    label $tw.fr1.l1 -text "Username:"
    label $tw.fr1.l2 -text "Password:"
    entry $tw.fr1.e1 -textvariable ::poWin::loginUser
    entry $tw.fr1.e2 -textvariable ::poWin::loginPassword -show "*"
    grid $tw.fr1.l1 -row 0 -column 0 -sticky nw
    grid $tw.fr1.l2 -row 1 -column 0 -sticky nw
    grid $tw.fr1.e1 -row 0 -column 1 -sticky nw
    grid $tw.fr1.e2 -row 1 -column 1 -sticky nw
    $tw.fr1.e1 configure -width 15
    $tw.fr1.e2 configure -width 15
    if { $fontName ne "" } {
	$tw.fr1.e1 configure -font $fontName
	$tw.fr1.e2 configure -font $fontName
    }

    bind $tw <KeyPress-Return> "::poWin::LoginOkCmd"
    bind $tw <KeyPress-Escape> "::poWin::LoginCancelCmd"
    wm protocol $tw WM_DELETE_WINDOW "::poWin::LoginCancelCmd"

    button $tw.fr2.b1 -text "Cancel" -command "::poWin::LoginCancelCmd"
    button $tw.fr2.b2 -text "OK"     \
	   -command "::poWin::LoginOkCmd" -default active
    pack $tw.fr2.b1 -side left -fill x -padx 2 -expand 1
    pack $tw.fr2.b2 -side left -fill x -padx 2 -expand 1
    pack $tw.fr1 -side top -expand 1 -fill x
    pack $tw.fr2 -side top -expand 1 -fill x
    update

    set oldFocus [focus]
    set oldGrab [grab current $tw]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $tw
    focus $tw.fr1.e1

    tkwait variable ::poWin::login

    catch {focus $oldFocus}
    grab release $tw
    wm withdraw $tw
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

    if { $login } {
	return [list $loginUser $loginPassword]
    } else {
	return {}
    }
}

proc ::poWin::EntryOkCmd {} {
    set ::poWin::entryBoxFlag 1
}

proc ::poWin::EntryCancelCmd {} {
    set ::poWin::entryBoxFlag 0
}

proc ::poWin::EntryBox { str x y { noChars 0 } { fontName "" } } {

    set tw ".poWin:EntryBox"
    if { [winfo exists $tw] } {
	destroy $tw
    }

    toplevel $tw
    wm overrideredirect $tw true
    wm geometry $tw [format "+%d+%d" $x [expr $y +10]]
 
    set ::poWin::entryBoxText $str
    frame $tw.fr -borderwidth 3 -relief raised
    entry $tw.fr.e -textvariable ::poWin::entryBoxText

    if { $noChars <= 0 } {
        set noChars [expr [string length $str] +1]
    }
    $tw.fr.e configure -width $noChars
    if { $fontName ne "" } {
	$tw.fr.e configure -font $fontName
    }
    $tw.fr.e selection range 0 end

    pack $tw.fr
    pack $tw.fr.e

    bind $tw <KeyPress-Return> "::poWin::EntryOkCmd"
    bind $tw <KeyPress-Escape> "::poWin::EntryCancelCmd"

    update

    set oldFocus [focus]
    set oldGrab [grab current $tw]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $tw
    focus $tw.fr.e

    tkwait variable ::poWin::entryBoxFlag

    catch {focus $oldFocus}
    grab release $tw
    destroy $tw
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

    if { $::poWin::entryBoxFlag } {
	return $::poWin::entryBoxText
    } else {
        return ""
    }
}

proc ::poWin::StartScreenSaver { master msg } {

    set tw .poWin:ScreenSaverWin
    catch { destroy $tw}

    toplevel $tw
    canvas $tw.img -bg black -borderwidth 0 -bg blue
    pack $tw.img -fill both -expand 1 -side left

    set h [winfo screenheight $master]
    set w [winfo screenwidth $master]

    wm minsize $master $w $h
    wm maxsize $master $w $h
    set fmtStr [format "%dx%d+0+0" $w $h]
    wm geometry $tw $fmtStr
    wm overrideredirect $tw 1

    bind $tw <KeyPress> "set ::poWin::stopit 1"
    bind $tw.img <KeyPress> "set ::poWin::stopit 1"
    bind $tw <Motion> "set ::poWin::stopit 1"
    focus -force $tw

    set xpos 0
    set ypos 0
    image create photo ph1 -data [::poImgData::poLogo100_text_flip]
    image create photo ph2 -data [::poImgData::poLogo100_text]
    set phWidth  [image width ph1]
    set phHeight [image height ph1]
    $tw.img create image -200 -200 -anchor nw -tag img1 -image ph1
    $tw.img create image $xpos $ypos -anchor nw -tag img2 -image ph2
    $tw.img create text -200 -200 -text $msg -tag msg
    $tw.img coords msg [expr $w/2] [expr $h/2]
    $tw.img raise img2
    update

    set xoff 1
    set yoff 1
    set i 2
    set updown 1

    set ::poWin::stopit 0
    while { $::poWin::stopit == 0 } {
	incr xpos $xoff
	$tw.img coords img$i $xpos $ypos
	update
	if { $xpos >= [expr $w - $phWidth] || $xpos < 0 } {
	    if { $xoff > 0 } {
		incr xoff $updown
		incr yoff
	    $tw.img create text $xpos [expr $ypos + $phHeight/2] -text $msg
	    }
	    set xoff [expr -1 * $xoff]
	    if { $ypos >= [expr $h - $phHeight] || $ypos < 0 } {
		set updown [expr -1 * $updown]
		set yoff [expr -1 * $yoff]
	    }
	    incr ypos $yoff
	    set i [expr $i % 2 + 1]
	    $tw.img raise img$i
	}
    }
    destroy $tw
}

proc ::poWin::LoadFileToTextWidget { w fileName { mode r } } {
    set retVal [catch {open $fileName r} fp]
    if { $retVal != 0 } {
        error "Could not open file $fileName for reading."
    }
    if { $mode eq "r" } {
        $w delete 1.0 end
    }
    while { ![eof $fp] } {
    	$w insert end [read $fp 2048]
    }
    close $fp
}

catch {puts "Loaded Package poTklib (Module [info script])"}


############################################################################
# Original file: poTklib/poWinAutoscroll.tcl
############################################################################

# poWinAutoscroll.tcl --
#
#       Package to create scroll bars that automatically appear when
#       a window is too small to display its content.
#
# Copyright (c) 2003    Kevin B Kenny <kennykb@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) autoscroll.tcl,v 1.8 2005/06/01 02:37:51 andreas_kupries Exp
#
# Slightly modified version by Paul Obermeier for poTklib library.

namespace eval ::poWinAutoscroll {
    namespace export autoscroll unautoscroll
    bind Autoscroll <Destroy> [namespace code [list destroyed %W]]
    bind Autoscroll <Map> [namespace code [list map %W]]
}

 #----------------------------------------------------------------------
 #
 # ::poWinAutoscroll::autoscroll --
 #
 #       Create a scroll bar that disappears when it is not needed, and
 #       reappears when it is.
 #
 # Parameters:
 #       w    -- Path name of the scroll bar, which should already exist
 #
 # Results:
 #       None.
 #
 # Side effects:
 #       The widget command is renamed, so that the 'set' command can
 #       be intercepted and determine whether the widget should appear.
 #       In addition, the 'Autoscroll' bind tag is added to the widget,
 #       so that the <Destroy> event can be intercepted.
 #
 #----------------------------------------------------------------------

proc ::poWinAutoscroll::autoscroll { w } {
    if { [info commands ::poWinAutoscroll::renamed$w] != "" } { return $w }
    rename $w ::poWinAutoscroll::renamed$w
    interp alias {} ::$w {} ::poWinAutoscroll::widgetCommand $w
    bindtags $w [linsert [bindtags $w] 1 Autoscroll]
    eval [list ::$w set] [renamed$w get]
    return $w
}

 #----------------------------------------------------------------------
 #
 # ::poWinAutoscroll::unautoscroll --
 #
 #       Return a scrollbar to its normal static behavior by removing
 #       it from the control of this package.
 #
 # Parameters:
 #       w    -- Path name of the scroll bar, which must have previously
 #               had ::poWinAutoscroll::autoscroll called on it.
 #
 # Results:
 #       None.
 #
 # Side effects:
 #       The widget command is renamed to its original name. The widget
 #       is mapped if it was not currently displayed. The widgets
 #       bindtags are returned to their original state. Internal memory
 #       is cleaned up.
 #
 #----------------------------------------------------------------------

proc ::poWinAutoscroll::unautoscroll { w } {
    if { [info commands ::poWinAutoscroll::renamed$w] != "" } {
        variable grid
        rename ::$w {}
        rename ::poWinAutoscroll::renamed$w ::$w
        if { [set i [lsearch -exact [bindtags $w] Autoscroll]] > -1 } {
            bindtags $w [lreplace [bindtags $w] $i $i]
        }
        if { [info exists grid($w)] } {
            eval [join $grid($w) \;]
            unset grid($w)
        }
    }
}

 #----------------------------------------------------------------------
 #
 # ::poWinAutoscroll::widgetCommand --
 #
 #       Widget command on an 'autoscroll' scrollbar
 #
 # Parameters:
 #       w       -- Path name of the scroll bar
 #       command -- Widget command being executed
 #       args    -- Arguments to the commane
 #
 # Results:
 #       Returns whatever the widget command returns
 #
 # Side effects:
 #       Has whatever side effects the widget command has.  In
 #       addition, the 'set' widget command is handled specially,
 #       by gridding/packing the scroll bar according to whether
 #       it is required.
 #
 #------------------------------------------------------------

proc ::poWinAutoscroll::widgetCommand { w command args } {
    variable grid
    if { $command == "set" } {
        foreach { min max } $args {}
        if { $min <= 0 && $max >= 1 } {
            switch -exact -- [winfo manager $w] {
                grid {
                    lappend grid($w) "[list grid $w] [grid info $w]"
                    grid forget $w
                }
                pack {
                    foreach x [pack slaves [winfo parent $w]] {
                        lappend grid($w) "[list pack $x] [pack info $x]"
                    }
                    pack forget $w
                }
            }
        } elseif { [info exists grid($w)] } {
            eval [join $grid($w) \;]
            unset grid($w)
        }
    }
    return [eval [list renamed$w $command] $args]
}


 #----------------------------------------------------------------------
 #
 # ::poWinAutoscroll::destroyed --
 #
 #       Callback executed when an automatic scroll bar is destroyed.
 #
 # Parameters:
 #       w -- Path name of the scroll bar
 #
 # Results:
 #       None.
 #
 # Side effects:
 #       Cleans up internal memory.
 #
 #----------------------------------------------------------------------

proc ::poWinAutoscroll::destroyed { w } {
    variable grid
    catch { unset grid($w) }
    rename ::$w {}
}


 #----------------------------------------------------------------------
 #
 # ::poWinAutoscroll::map --
 #
 #       Callback executed when an automatic scroll bar is mapped.
 #
 # Parameters:
 #       w -- Path name of the scroll bar.
 #
 # Results:
 #       None.
 #
 # Side effects:
 #       Geometry of the scroll bar's top-level window is constrained.
 #
 # This procedure keeps the top-level window associated with an
 # automatic scroll bar from being resized automatically after the
 # scroll bar is mapped.  This effect avoids a potential endless loop
 # in the case where the resize of the top-level window resizes the
 # widget being scrolled, causing the scroll bar no longer to be needed.
 #
 #----------------------------------------------------------------------

proc ::poWinAutoscroll::map { w } {
    wm geometry [winfo toplevel $w] [wm geometry [winfo toplevel $w]]
}

 #----------------------------------------------------------------------
 #
 # ::poWinAutoscroll::wrap --
 #
 #       Arrange for all new scrollbars to be automatically autoscrolled
 #
 # Parameters:
 #       None.
 #
 # Results:
 #       None.
 #
 # Side effects:
 #       ::scrollbar is overloaded to automatically autoscroll any new
 #          scrollbars.
 #
 #----------------------------------------------------------------------

proc ::poWinAutoscroll::wrap {} {
    if {[info commands ::poWinAutoscroll::_scrollbar] != ""} {return}
    rename ::scrollbar ::poWinAutoscroll::_scrollbar
    proc ::scrollbar {w args} {
        eval ::poWinAutoscroll::_scrollbar [list $w] $args
        ::poWinAutoscroll::autoscroll $w
        return $w
    }
}

 #----------------------------------------------------------------------
 #
 # ::poWinAutoscroll::unwrap --
 #
 #       Turns off automatic autoscrolling of new scrollbars. Does not
 #         effect existing scrollbars.
 #
 # Parameters:
 #       None.
 #
 # Results:
 #       None.
 #
 # Side effects:
 #       ::scrollbar is returned to its original state
 #
 #----------------------------------------------------------------------

proc ::poWinAutoscroll::unwrap {} {
    if {[info commands ::poWinAutoscroll::_scrollbar] == ""} {return}
    rename ::scrollbar {}
    rename ::poWinAutoscroll::_scrollbar ::scrollbar
}

############################################################################
# Original file: poTklib/poWinCapture.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poWinCapture
#       Copyright:      Paul Obermeier 2004 / paul@poSoft.de
#       Filename:       poWinCapture.tcl
#
#       First Version:  2004 / 10 / 19
#       Author:         Paul Obermeier
#
#       Description:	
#	                Additional poWin module file with functions for 
#                       capturing window contents into an image or file.	
#                       As this functionality requires the help of the Img
#                       extension, it is separated into a own file.
#
#       Additional documentation:
#
#			None.
#
#       Exported functions:
#    			::poWin::Windows2Img
#    			::poWin::Windows2File
#    			::poWin::Canvas2Img
#    			::poWin::Canvas2File
#
############################################################################

package provide poTklib 1.0
package provide poWinCapture 1.0

namespace eval ::poWin {
    namespace export Windows2Img
    namespace export Windows2File
    namespace export Canvas2Img
    namespace export Canvas2File
    namespace export Clipboard2Img
    namespace export Clipboard2File
    namespace export Img2Clipboard
}

proc ::poWin::InitCapture {} {
    variable poWinCapInt

    set retVal [catch {package require Img} poWinCapInt(Img,version)] 
    set poWinCapInt(Img,avail) [expr !$retVal]
    set retVal [catch {package require twapi} poWinCapInt(twapi,version)] 
    set poWinCapInt(twapi,avail) [expr !$retVal]
    set retVal [catch {package require base64} poWinCapInt(base64,version)] 
    set poWinCapInt(base64,avail) [expr !$retVal]
}

proc ::poWin::Windows2Img { win } {
    variable poWinCapInt

    regexp {([0-9]*)x([0-9]*)\+([0-9]*)\+([0-9]*)} \
            [winfo geometry $win] - w h x y

    if { !$poWinCapInt(Img,avail) } {
        set img [image create photo -width $h -height $h]
        $img blank
    } else {
        set img [image create photo -format window -data $win]

        foreach child [winfo children $win] {
            ::poWin::CaptureSubWindow $child $img 0 0
        }
    }
    return $img
}

proc ::poWin::CaptureSubWindow { win img px py } {
    if { ![winfo ismapped $win] } {
        return
    }

    regexp {([0-9]*)x([0-9]*)\+([-]*[0-9]*)\+([-]*[0-9]*)} \
        [winfo geometry $win] - w h x y

    if { $x < 0 || $y < 0 } {
        return
    }
    incr px $x
    incr py $y

    # Make an image from this widget
    set tmpImg [image create photo -format window -data $win]
 
    # Copy this image into place on the main image
    $img copy $tmpImg -to $px $py
    image delete $tmpImg

    foreach child [winfo children $win] {
        ::poWin::CaptureSubWindow $child $img $px $py
    }
}

proc ::poWin::Windows2File { win fileName } {
    set img [::poWin::Windows2Img $win]

    if { [string length $fileName] != 0 } {
        set fmtStr [::poImgtype::GetFmtByExt [file extension $fileName]] 
        set optStr [::poImgtype::GetOptByFmt $fmtStr "write"]
        $img write $fileName -format "$fmtStr $optStr"
        puts "Window written to file: $fileName"
    }
    image delete $img
}

proc ::poWin::Canvas2Img { canv } {
    variable poWinCapInt

    set region [$canv cget -scrollregion]
    set xsize [lindex $region 2]
    set ysize [lindex $region 3]
    set img [image create photo -width $xsize -height $ysize]
    if { !$poWinCapInt(Img,avail) } {
        $img blank
    } else {
        $canv xview moveto 0
        $canv yview moveto 0
        update
        set xr 0.0
        set yr 0.0
        set px 0
        set py 0
        while { $xr < 1.0 } {
            while { $yr < 1.0 } {
                set tmpImg [image create photo -format window -data $canv]
                $img copy $tmpImg -to $px $py
                image delete $tmpImg
                set yr [lindex [$canv yview] 1]
                $canv yview moveto $yr
                set py [expr round ($ysize * [lindex [$canv yview] 0])]
                update
            }
            $canv yview moveto 0
            set yr 0.0
            set py 0

            set xr [lindex [$canv xview] 1]
            $canv xview moveto $xr
            set px [expr round ($xsize * [lindex [$canv xview] 0])]
            update
        }
    }
    return $img
}

proc ::poWin::Canvas2File { canv fileName } {
    set img [::poWin::Canvas2Img $canv]

    if { [string length $fileName] != 0 } {
        set fmtStr [::poImgtype::GetFmtByExt [file extension $fileName]] 
        set optStr [::poImgtype::GetOptByFmt $fmtStr "write"]
        $img write $fileName -format "$fmtStr $optStr"
        puts "Canvas written to file: $fileName"
    }
    image delete $img
}

# Copy the contents of the Windows clipboard into a photo image.
# Return the photo image identifier.
proc ::poWin::Clipboard2Img {} {
    variable poWinCapInt

    if { !$poWinCapInt(twapi,avail) } {
        error "Twapi extension not available"
    }

    twapi::open_clipboard

    # Assume clipboard content is in format 8 (CF_DIB)
    set retVal [catch {twapi::read_clipboard 8} clipData]
    if { $retVal != 0 } {
        error "Invalid or no content in clipboard"
    }

    # First parse the bitmap data to collect header information
    binary scan $clipData "iiissiiiiii" \
           size width height planes bitcount compression sizeimage \
           xpelspermeter ypelspermeter clrused clrimportant

    # We only handle BITMAPINFOHEADER right now (size must be 40)
    if {$size != 40} {
        error "Unsupported bitmap format. Header size=$size"
    }

    # We need to figure out the offset to the actual bitmap data
    # from the start of the file header. For this we need to know the
    # size of the color table which directly follows the BITMAPINFOHEADER
    if {$bitcount == 0} {
        error "Unsupported format: implicit JPEG or PNG"
    } elseif {$bitcount == 1} {
        set color_table_size 2
    } elseif {$bitcount == 4} {
        # TBD - Not sure if this is the size or the max size
        set color_table_size 16
    } elseif {$bitcount == 8} {
        # TBD - Not sure if this is the size or the max size
        set color_table_size 256
    } elseif {$bitcount == 16 || $bitcount == 32} {
        if {$compression == 0} {
            # BI_RGB
            set color_table_size $clrused
        } elseif {$compression == 3} {
            # BI_BITFIELDS
            set color_table_size 3
        } else {
            error "Unsupported compression type '$compression' for bitcount value $bitcount"
        }
    } elseif {$bitcount == 24} {
        set color_table_size $clrused
    } else {
        error "Unsupported value '$bitcount' in bitmap bitcount field"
    }

    set phImg [image create photo]
    set filehdr_size 14                 ; # sizeof(BITMAPFILEHEADER)
    set bitmap_file_offset [expr {$filehdr_size+$size+($color_table_size*4)}]
    set filehdr [binary format "a2 i x2 x2 i" \
                 "BM" [expr {$filehdr_size + [string length $clipData]}] \
                 $bitmap_file_offset]

    append filehdr $clipData
    $phImg put $filehdr -format bmp

    twapi::close_clipboard
    return $phImg
}

# Copy the contents of the Windows clipboard into a photo image
# and save the image to file "fileName". The extension of the filename
# determines the image file format.
proc ::poWin::Clipboard2File { fileName } {
    set img [::poWin::Clipboard2Img]

    if { [string length $fileName] != 0 } {
        set fmtStr [::poImgtype::GetFmtByExt [file extension $fileName]] 
        set optStr [::poImgtype::GetOptByFmt $fmtStr "write"]
        $img write $fileName -format "$fmtStr $optStr"
    }
    image delete $img
}

# Copy photo image "phImg" into Windows clipboard.
proc ::poWin::Img2Clipboard { phImg } {
    variable poWinCapInt

    if { !$poWinCapInt(base64,avail) } {
        error "Base64 extension not available"
    }
    if { !$poWinCapInt(twapi,avail) } {
        error "Twapi extension not available"
    }
    # First 14 bytes are bitmapfileheader - get rid of this
    set data [string range [base64::decode [$phImg data -format bmp]] 14 end]
    twapi::open_clipboard
    twapi::empty_clipboard
    twapi::write_clipboard 8 $data
    twapi::close_clipboard
}

::poWin::InitCapture
catch {puts "Loaded Package poTklib (Module [info script])"}

############################################################################
# Original file: poTklib/poWinWithAutoscroll.tcl
############################################################################

############################################################################
#{@Tcl
#
#       Module:         poWin
#       Copyright:      Paul Obermeier 2000-2008 / paul@poSoft.de
#       Filename:       poWinWithAutoscroll.tcl
#
#       First Version:  2000 / 10 / 22
#       Author:         Paul Obermeier
#
#       Description:
#
#       Additional documentation:
#
#       Exported functions:
#
############################################################################ 

package provide poTklib 1.0
package provide poWin 1.0

namespace eval ::poWin {
    namespace export GetFixedFont

    namespace export Raise
    namespace export IsToplevel

    namespace export CreateHelpWin
    namespace export CreateListSelWin
    namespace export CreateListConfirmWin

    namespace export CreateOneFileInfoWin
    namespace export CreateTwoFileInfoWin

    namespace export SetScrolledTitle
    namespace export CreateScrolledWidget
    namespace export CreateScrolledFrame
    namespace export CreateScrolledListbox
    namespace export CreateScrolledText
    namespace export CreateScrolledCanvas
    namespace export CreateScrolledTable
    namespace export CreateScrolledTree

    namespace export SetSyncTitle
    namespace export CreateSyncWidget
    namespace export CreateSyncListbox
    namespace export CreateSyncText
    namespace export CreateSyncCanvas

    namespace export CanvasSeeItem

    namespace export EntryBox
    namespace export ShowEntryBox
    namespace export ShowLoginBox

    namespace export StartScreenSaver

    namespace export LoadFileToTextWidget

    variable syncEnabled
    variable entryBoxTemp
    variable login
    variable loginUser
    variable loginPassword
    variable infoWinNo 1
    variable xPosShowEntryBox -1
    variable yPosShowEntryBox -1
}

proc ::poWin::GetFixedFont {} {
    global tcl_platform

    if { [string compare $tcl_platform(platform) "windows"] == 0 } {
	return [list -family Courier -size 10 -weight normal -underline 0 -slant roman -overstrike 0]
    }
    switch -glob $tcl_platform(os) {
	IRIX* {
	    return "Courier"
	}
	SunOS* {
	    return "Courier"
	}
	Linux* {
	return [list -family Courier -size 10 -weight normal -underline 0 -slant roman -overstrike 0]
	}
	default {
	    return "Courier"
	}
    }
}

proc ::poWin::IsToplevel { path } {
    string equal $path [winfo toplevel $path]
}

proc ::poWin::Raise { tw } {
    wm deiconify $tw
    update
    raise $tw
}

proc ::poWin::CreateHelpWin { helpStr } {

    set tw .poWin:HelpWin
    set title "Help Window"

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    toplevel $tw
    wm title $tw $title

    frame $tw.fr -relief raised -borderwidth 2

    set textWid [CreateScrolledText $tw.fr "" -wrap word]
    bind $textWid <KeyPress-Escape> "destroy $tw"
    button $tw.close -text "Close" -command "destroy $tw"
    pack $tw.close -expand 1 -fill x -side bottom
    pack $tw.fr -expand 1 -fill both

    $textWid insert end $helpStr
    $textWid configure -state disabled -cursor top_left_arrow
    focus $textWid
}

proc ::poWin::SelAllInList { listBox } {
    $listBox selection set 0 end
}

proc ::poWin::ListOkCmd {} {
    set ::poWin::listBoxFlag 1
}

proc ::poWin::ListCancelCmd {} {
    set ::poWin::listBoxFlag 0
}

proc ::poWin::CreateListSelWin { selList title subTitle } {

    set tw .poWin:ListWin

    if { [llength $selList] == 0 } {
	return {}
    }

    toplevel $tw
    wm title $tw "$title"
    wm resizable $tw true true

    frame $tw.listfr
    frame $tw.selfr
    frame $tw.okfr
    pack $tw.listfr $tw.selfr $tw.okfr -side top -fill x -expand 1

    set listBox [::poWin::CreateScrolledListbox $tw.listfr \
                 $subTitle -width 40 -selectmode extended \
		 -exportselection false -bg white]

    button $tw.selfr.b1 -text "Select all" \
			-command "::poWin::SelAllInList $listBox"
    pack $tw.selfr.b1 -side left -fill x -expand 1 -padx 2 -pady 2

    # Create Cancel and OK buttons
    button $tw.okfr.b1 -text "Cancel" -command "::poWin::ListCancelCmd"
    button $tw.okfr.b2 -text "OK" -default active \
	       -command "::poWin::ListOkCmd"
    pack $tw.okfr.b1 $tw.okfr.b2 -side left -fill x -padx 2 -expand 1

    bind $tw <KeyPress-Return> "::poWin::ListOkCmd"
    bind $tw <KeyPress-Escape> "::poWin::ListCancelCmd"

    # Now fill the listbox with the file names and select all.
    foreach f $selList {
	$listBox insert end $f
    }
    $listBox select set 0 end

    update

    set oldFocus [focus]
    set oldGrab [grab current $tw]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $tw
    focus $listBox

    tkwait variable ::poWin::listBoxFlag

    catch {focus $oldFocus}
    grab release $tw

    set indList [$listBox curselection]
    set retList {}
    if { $::poWin::listBoxFlag && [llength $indList] != 0 } {
	foreach ind $indList {
	    lappend retList [$listBox get $ind]
	}
    }

    destroy $tw
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

    return $retList
}

proc ::poWin::CreateListConfirmWin { selList title subTitle } {

    set tw .poWin:ListConfirmWin

    if { [llength $selList] == 0 } {
	return 0
    }

    toplevel $tw
    wm title $tw "$title"
    wm resizable $tw true true

    frame $tw.textfr
    frame $tw.selfr
    frame $tw.okfr
    pack $tw.textfr $tw.selfr $tw.okfr -side top -fill x -expand 1

    set textId [::poWin::CreateScrolledText $tw.textfr \
                $subTitle -wrap none -height 10 -width 60 -bg white]

    # Create Cancel and OK buttons
    button $tw.okfr.b1 -text "Cancel" -command "::poWin::ListCancelCmd"
    button $tw.okfr.b2 -text "OK" -default active \
	       -command "::poWin::ListOkCmd"
    pack $tw.okfr.b1 $tw.okfr.b2 -side left -fill x -padx 2 -expand 1

    bind $tw <KeyPress-Return> "::poWin::ListOkCmd"
    bind $tw <KeyPress-Escape> "::poWin::ListCancelCmd"

    # Now fill the listbox with the file names and select all.
    foreach f $selList {
	$textId insert end $f
	$textId insert end "\n"
    }
    $textId configure -state disabled -cursor top_left_arrow

    update

    set oldFocus [focus]
    set oldGrab [grab current $tw]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $tw
    focus $tw.okfr.b2

    tkwait variable ::poWin::listBoxFlag

    catch {focus $oldFocus}
    grab release $tw

    destroy $tw
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

    return $::poWin::listBoxFlag
}

proc ::poWin::DestroyOneFileInfoWin { w { phImg "" } } {
    catch {image delete $phImg}
    destroy $w
}

proc ::poWin::CreateOneFileInfoWin { fileName attrList \
                                     {phImg ""} {btnProc ""} } {
    variable infoWinNo

    set tw .poWin:InfoWin$infoWinNo
    incr infoWinNo
    catch { destroy $tw }

    toplevel $tw
    wm title $tw "Attributes of [file tail $fileName]"
    wm resizable $tw true false

    # If a thumbnail photo image has been supplied in phImg, show it.
    if { [string compare $phImg ""] != 0 } {
	frame $tw.fr
	pack $tw.fr
	label $tw.fr.l -image $phImg
	pack $tw.fr.l -pady 2
    }
    # Generate left column with text labels.
    set row 0
    frame $tw.fr0 -relief sunken -borderwidth 1
    foreach listEntry $attrList {
	label $tw.fr0.k$row -text [format "%s:" [lindex $listEntry 0]]
	label $tw.fr0.v$row -text [lindex $listEntry 1]
        grid  $tw.fr0.k$row -row $row -column 0 -sticky nw
        grid  $tw.fr0.v$row -row $row -column 1 -sticky nw
	incr row
    }

    # Create Close and View button
    frame $tw.fr1 -relief sunken -borderwidth 1
    if { [string compare $btnProc ""] != 0 } {
	button $tw.fr1.bView -text "View" -command [list $btnProc $fileName]
	pack $tw.fr1.bView -side left -fill x -padx 2 -expand 1
    }
    button $tw.fr1.bClose -text "Close" -default active \
           -command "::poWin::DestroyOneFileInfoWin $tw $phImg"
    pack $tw.fr1.bClose -side left -fill x -padx 2 -expand 1

    pack $tw.fr0 $tw.fr1 -side top -expand 1 -fill x

    bind $tw <Escape> "::poWin::DestroyOneFileInfoWin $tw $phImg"
    bind $tw <Return> "::poWin::DestroyOneFileInfoWin $tw $phImg"
    focus $tw
    return $tw
}

proc ::poWin::CreateTwoFileInfoWin { leftFile rightFile leftAttr rightAttr } {
    variable infoWinNo

    set tw .poWin:InfoWin$infoWinNo
    incr infoWinNo
    catch { destroy $tw }

    toplevel $tw
    wm title $tw "[file tail $leftFile] versus [file tail $rightFile]"
    wm resizable $tw true false

    # Generate left column with text labels.
    set row 0
    frame $tw.fr0 -relief sunken -borderwidth 1
    foreach leftEntry $leftAttr rightEntry $rightAttr {
	label $tw.fr0.kl$row -text [format "%s:" [lindex $leftEntry 0]]
	label $tw.fr0.vl$row -text [lindex $leftEntry 1]
	label $tw.fr0.vr$row -text [lindex $rightEntry 1]
        grid  $tw.fr0.kl$row -row $row -column 0 -sticky nw
        grid  $tw.fr0.vl$row -row $row -column 1 -sticky nw
        grid  $tw.fr0.vr$row -row $row -column 2 -sticky nw
	incr row
    }

    # Create OK button
    frame $tw.fr1 -relief sunken -borderwidth 1
    button $tw.fr1.b -text "OK" -command "destroy $tw" -default active
    pack $tw.fr1.b -side left -fill x -padx 2 -expand 1
    pack $tw.fr0 $tw.fr1 -side top -expand 1 -fill x

    bind $tw <Escape> "destroy $tw"
    bind $tw <Return> "destroy $tw"
    focus $tw
    return $tw
}

proc ::poWin::SetScrolledTitle { w titleStr { fgColor "black" } } {
    set pathList [split $w "."]
    # Index -3 is needed for CreateScrolledFrame.
    # Index -2 is needed for all other widget types.
    foreach ind { -2 -3 } {
	set parList  [lrange $pathList 0 [expr [llength $pathList] $ind]]
	set parPath  [join $parList "."]

	set labelPath $parPath
	append labelPath ".label"
	if { [winfo exists $labelPath] } {
	    $labelPath configure -text $titleStr -foreground $fgColor
	    break
	}
    }
}

proc ::poWin::CreateScrolledWidget { wType w titleStr args } {
    if { [winfo exists $w.par] } {
        destroy $w.par
    }
    frame $w.par
    pack $w.par -side top -fill both -expand 1
    if { [string compare $titleStr ""] != 0 } {
        label $w.par.label -text "$titleStr"
    }
    eval { $wType $w.par.widget \
	    -xscrollcommand "$w.par.xscroll set" \
	    -yscrollcommand "$w.par.yscroll set" } $args
    scrollbar $w.par.xscroll -command "$w.par.widget xview" -orient horizontal
    scrollbar $w.par.yscroll -command "$w.par.widget yview" -orient vertical
    set rowNo 0
    if { [string compare $titleStr ""] != 0 } {
	set rowNo 1
        grid $w.par.label -sticky ew -columnspan 2
    }
    grid $w.par.widget $w.par.yscroll -sticky news
    grid $w.par.xscroll               -sticky ew
    grid rowconfigure    $w.par $rowNo -weight 1
    grid columnconfigure $w.par 0      -weight 1

    ::poWinAutoscroll::autoscroll $w.par.xscroll
    ::poWinAutoscroll::autoscroll $w.par.yscroll

    return $w.par.widget
}

proc ::poWin::ScrolledFrameCfgCB {w width height} {
    set newSR [list 0 0 $width $height]
    if { ! [string equal [$w.canv cget -scrollregion] $newSR] } {
	$w.canv configure -scrollregion $newSR
    }
}

proc ::poWin::CreateScrolledFrame { w titleStr args } {
    frame $w.par
    pack $w.par -fill both -expand 1
    if { [string compare $titleStr ""] != 0 } {
	label $w.par.label -text "$titleStr" -borderwidth 2 -relief raised
    }
    eval {canvas $w.par.canv -xscrollcommand [list $w.par.xscroll set] \
                             -yscrollcommand [list $w.par.yscroll set]} $args
    scrollbar $w.par.xscroll -orient horizontal -command "$w.par.canv xview"
    scrollbar $w.par.yscroll -orient vertical   -command "$w.par.canv yview"
    set fr [frame $w.par.canv.fr -borderwidth 0 -highlightthickness 0]
    $w.par.canv create window 0 0 -anchor nw -window $fr

    set rowNo 0
    if { [string compare $titleStr ""] != 0 } {
	set rowNo 1
        grid $w.par.label -sticky ew -columnspan 2
    }
    grid $w.par.canv $w.par.yscroll -sticky news
    grid $w.par.xscroll             -sticky ew
    grid rowconfigure    $w.par $rowNo -weight 1
    grid columnconfigure $w.par 0      -weight 1
    # This binding makes the scroll-region of the canvas behave correctly as
    # you place more things in the content frame.
    bind $fr <Configure> [list ::poWin::ScrolledFrameCfgCB $w.par %w %h]
    $w.par.canv configure -borderwidth 0 -highlightthickness 0
    return $fr
}

proc ::poWin::CreateScrolledListbox { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget listbox $w $titleStr} $args ]
}

proc ::poWin::CreateScrolledText { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget text $w $titleStr} $args ]
}

proc ::poWin::CreateScrolledCanvas { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget canvas $w $titleStr} $args ]
}

proc ::poWin::CreateScrolledTable { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget table $w $titleStr} $args ]
}

proc ::poWin::CreateScrolledTree { w titleStr args } {
    return [eval {::poWin::CreateScrolledWidget ::poTree::Create \
						 $w $titleStr} $args ]
}

proc ::poWin::Xscroll { scrollWidget leftWidget rightWidget x1 x2 } {
    ::poLog::Callstack "::poWin::Xscroll $scrollWidget \
                        $leftWidget $rightWidget $x1 $x2"

    set size1 [expr {[lindex [$leftWidget xview] 1] - \
                     [lindex [$leftWidget xview] 0]}]
    set size2 [expr {[lindex [$rightWidget xview] 1] - \
                     [lindex [$rightWidget xview] 0]}]

    eval $scrollWidget set $x1 $x2
    eval $leftWidget   xview moveto $x1
    eval $rightWidget  xview moveto $x1
}

proc ::poWin::Yscroll { scrollWidget leftWidget rightWidget y1 y2 } {
    ::poLog::Callstack "::poWin::Yscroll $scrollWidget \
                        $leftWidget $rightWidget $y1 $y2"

    eval $scrollWidget set $y1 $y2
    eval $leftWidget   yview moveto $y1
    eval $rightWidget  yview moveto $y1
}

proc ::poWin::Xview { leftWidget rightWidget args } {
    ::poLog::Callstack "::poWin::Xview $leftWidget $rightWidget $args"
    eval $leftWidget  xview $args
    # eval $rightWidget xview $args
}

proc ::poWin::Yview { leftWidget rightWidget args } {
    ::poLog::Callstack "::poWin::Yview $leftWidget $rightWidget $args"
    eval $leftWidget  yview $args
    #eval $rightWidget yview $args
}

proc ::poWin::SetSyncTitle { w leftTitle rightTitle } {
    set pathList [split $w "."]
    set parList  [lrange $pathList 0 [expr [llength $pathList] -2]]
    set parPath  [join $parList "."]

    set leftLabelPath $parPath
    append leftLabelPath ".leftlabel"
    set rightLabelPath $parPath
    append rightLabelPath ".rightlabel"

    if { [string compare $leftTitle ""] != 0 && \
	 [winfo exists $leftLabelPath] } {
	$leftLabelPath configure -text $leftTitle
    }
    if { [string compare $rightTitle ""] != 0 && \
	 [winfo exists $rightLabelPath] } {
	$rightLabelPath configure -text $rightTitle
    }
}

proc ::poWin::CreateSyncWidget { wType w leftTitle rightTitle args } {
    frame $w.par
    if { [string compare $leftTitle ""] != 0 } {
        label $w.par.leftlabel -text "$leftTitle"
    }
    if { [string compare $rightTitle ""] != 0 } {
        label $w.par.rightlabel -text "$rightTitle"
    }

    eval { $wType $w.par.leftwidget \
	    -xscrollcommand "::poWin::Xscroll $w.par.xscroll \
	                     $w.par.leftwidget $w.par.rightwidget" \
	    -yscrollcommand "::poWin::Yscroll $w.par.yscroll \
	                     $w.par.leftwidget $w.par.rightwidget" } $args
    eval { $wType $w.par.rightwidget \
	    -xscrollcommand "::poWin::Xscroll $w.par.xscroll \
	                     $w.par.leftwidget $w.par.rightwidget" \
	    -yscrollcommand "::poWin::Yscroll $w.par.yscroll \
	                     $w.par.leftwidget $w.par.rightwidget" } $args

    scrollbar $w.par.xscroll -orient horizontal \
	      -command "::poWin::Xview $w.par.leftwidget $w.par.rightwidget"
    scrollbar $w.par.yscroll -orient vertical \
	      -command "::poWin::Yview $w.par.leftwidget $w.par.rightwidget"

    set rowNo 0
    if { [string compare $leftTitle  ""] != 0 || \
         [string compare $rightTitle ""] != 0 } {
        grid $w.par.leftlabel  -sticky ew -row 0 -column 0
        grid $w.par.rightlabel -sticky ew -row 0 -column 1 -columnspan 2
	set rowNo 1
    }
    grid $w.par.leftwidget  -sticky news -row 1 -column 0
    grid $w.par.rightwidget -sticky news -row 1 -column 1
    grid $w.par.xscroll -sticky ew   -row 2 -column 0 -columnspan 2
    grid $w.par.yscroll -sticky news -row 1 -column 2 -rowspan 1
    grid rowconfigure    $w.par $rowNo -weight 1
    grid columnconfigure $w.par 0 -weight 1
    grid columnconfigure $w.par 1 -weight 1

    ::poWinAutoscroll::autoscroll $w.par.xscroll
    ::poWinAutoscroll::autoscroll $w.par.yscroll

    pack $w.par -side top -fill both -expand 1
    return [list $w.par.leftwidget $w.par.rightwidget]
}

proc ::poWin::CreateSyncListbox { w leftTitle rightTitle args } {
    return [eval {::poWin::CreateSyncWidget listbox $w \
					     $leftTitle $rightTitle} $args ]
}

proc ::poWin::CreateSyncText { w leftTitle rightTitle args } {
    return [eval {::poWin::CreateSyncWidget text $w \
					     $leftTitle $rightTitle} $args ]
}

proc ::poWin::CreateSyncCanvas { w leftTitle rightTitle args } {
    return [eval {::poWin::CreateSyncWidget canvas $w \
					     $leftTitle $rightTitle} $args ]
}

proc ::poWin::CanvasSeeItem { canv item } {
    set box [$canv bbox $item]

    if { [string match {} $box] } { return }

    if { [string match {} [$canv cget -scrollregion]] } {
	# People really should set -scrollregion you know...
	foreach {x y x1 y1} $box {
	    set x [expr round(2.5 * ($x1+$x) / [winfo width  $canv])]
	    set y [expr round(2.5 * ($y1+$y) / [winfo height $canv])]
	}
	$canv xview moveto 0
	$canv yview moveto 0
	$canv xview scroll $x units
	$canv yview scroll $y units
    } else {
	# If -scrollregion is set properly, use this
	foreach {x y x1 y1} \
	    $box          {top btm} \
	    [$canv yview] {left right} \
	    [$canv xview] {p q xmax ymax} \
	    [$canv cget -scrollregion] \
	{
	    set xpos [expr (($x1+$x) / 2.0) / $xmax - ($right-$left) / 2.0]
	    set ypos [expr (($y1+$y) / 2.0) / $ymax - ($btm-$top)    / 2.0]
	}
	$canv xview moveto $xpos
	$canv yview moveto $ypos
    }
}

proc ::poWin::EvalCommand { cmd } {
    variable entryBoxTemp

    eval [list $cmd $entryBoxTemp]
    ::poWin::DestroyEntryBox
}

proc ::poWin::DestroyEntryBox {} {
    variable xPosShowEntryBox
    variable yPosShowEntryBox

    set xPosShowEntryBox [winfo rootx .poWin:EntryBox]
    set yPosShowEntryBox [winfo rooty .poWin:EntryBox]
    destroy .poWin:EntryBox
}

proc ::poWin::ShowEntryBox { cmd var title { msg "" } { noChars 30 } { fontName "" } } {
    variable entryBoxTemp
    variable xPosShowEntryBox
    variable yPosShowEntryBox

    set tw ".poWin:EntryBox"
    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    toplevel $tw
    wm title $tw $title
    wm resizable $tw false false
    if { $xPosShowEntryBox < 0 || $yPosShowEntryBox < 0 } {
        set xPosShowEntryBox [expr [winfo screenwidth .]  / 2]
        set yPosShowEntryBox [expr [winfo screenheight .] / 2]
    }
    wm geometry $tw [format "+%d+%d" $xPosShowEntryBox $yPosShowEntryBox]

    frame $tw.fr1
    frame $tw.fr2
    set entryBoxTemp $var
    if { [string compare $msg ""] != 0 } {
        label $tw.fr1.l -text $msg
    }
    entry $tw.fr1.e -textvariable ::poWin::entryBoxTemp
    $tw.fr1.e configure -width $noChars
    if { [string compare $fontName ""] != 0 } {
	$tw.fr1.e configure -font $fontName
    }

    $tw.fr1.e selection range 0 end

    bind $tw <KeyPress-Return> "::poWin::EvalCommand $cmd"
    bind $tw <KeyPress-Escape> "::poWin::DestroyEntryBox"
    if { [string compare $msg ""] != 0 } {
        pack $tw.fr1.l -fill x -expand 1 -side top
    }
    pack $tw.fr1.e -fill x -expand 1 -side top

    button $tw.fr2.b1 -text "Cancel" -command "::poWin::DestroyEntryBox"
    button $tw.fr2.b2 -text "OK"     \
	   -command "::poWin::EvalCommand $cmd" -default active
    pack $tw.fr2.b1 -side left -fill x -padx 2 -expand 1
    pack $tw.fr2.b2 -side left -fill x -padx 2 -expand 1
    pack $tw.fr1 -side top -expand 1 -fill x
    pack $tw.fr2 -side top -expand 1 -fill x
    focus $tw.fr1.e
    grab $tw
}

proc ::poWin::LoginOkCmd {} {
    variable login

    set login 1
}

proc ::poWin::LoginCancelCmd {} {
    variable login

    set login 0
}

proc ::poWin::ShowLoginBox { title { user guest } { fontName "" } } {
    variable login
    variable loginUser
    variable loginPassword

    set tw ".poWin:LoginBox"
    if { [winfo exists $tw] } {
	destroy $tw
	set loginPassword ""
    }

    toplevel $tw
    wm title $tw $title
    wm resizable $tw false false

    frame $tw.fr1
    frame $tw.fr2
    set loginUser $user
    label $tw.fr1.l1 -text "Username:"
    label $tw.fr1.l2 -text "Password:"
    entry $tw.fr1.e1 -textvariable ::poWin::loginUser
    entry $tw.fr1.e2 -textvariable ::poWin::loginPassword -show "*"
    grid $tw.fr1.l1 -row 0 -column 0 -sticky nw
    grid $tw.fr1.l2 -row 1 -column 0 -sticky nw
    grid $tw.fr1.e1 -row 0 -column 1 -sticky nw
    grid $tw.fr1.e2 -row 1 -column 1 -sticky nw
    $tw.fr1.e1 configure -width 15
    $tw.fr1.e2 configure -width 15
    if { [string compare $fontName ""] != 0 } {
	$tw.fr1.e1 configure -font $fontName
	$tw.fr1.e2 configure -font $fontName
    }

    bind $tw <KeyPress-Return> "::poWin::LoginOkCmd"
    bind $tw <KeyPress-Escape> "::poWin::LoginCancelCmd"
    wm protocol $tw WM_DELETE_WINDOW "::poWin::LoginCancelCmd"

    button $tw.fr2.b1 -text "Cancel" -command "::poWin::LoginCancelCmd"
    button $tw.fr2.b2 -text "OK"     \
	   -command "::poWin::LoginOkCmd" -default active
    pack $tw.fr2.b1 -side left -fill x -padx 2 -expand 1
    pack $tw.fr2.b2 -side left -fill x -padx 2 -expand 1
    pack $tw.fr1 -side top -expand 1 -fill x
    pack $tw.fr2 -side top -expand 1 -fill x
    update

    set oldFocus [focus]
    set oldGrab [grab current $tw]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $tw
    focus $tw.fr1.e1

    tkwait variable ::poWin::login

    catch {focus $oldFocus}
    grab release $tw
    wm withdraw $tw
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

    if { $login } {
	return [list $loginUser $loginPassword]
    } else {
	return {}
    }
}

proc ::poWin::EntryOkCmd {} {
    set ::poWin::entryBoxFlag 1
}

proc ::poWin::EntryCancelCmd {} {
    set ::poWin::entryBoxFlag 0
}

proc ::poWin::EntryBox { str x y { noChars 0 } { fontName "" } } {

    set tw ".poWin:EntryBox"
    if { [winfo exists $tw] } {
	destroy $tw
    }

    toplevel $tw
    wm overrideredirect $tw true
    wm geometry $tw [format "+%d+%d" $x [expr $y +10]]
 
    set ::poWin::entryBoxText $str
    frame $tw.fr -borderwidth 3 -relief raised
    entry $tw.fr.e -textvariable ::poWin::entryBoxText

    if { $noChars <= 0 } {
        set noChars [expr [string length $str] +1]
    }
    $tw.fr.e configure -width $noChars
    if { [string compare $fontName ""] != 0 } {
	$tw.fr.e configure -font $fontName
    }
    $tw.fr.e selection range 0 end

    pack $tw.fr
    pack $tw.fr.e

    bind $tw <KeyPress-Return> "::poWin::EntryOkCmd"
    bind $tw <KeyPress-Escape> "::poWin::EntryCancelCmd"

    update

    set oldFocus [focus]
    set oldGrab [grab current $tw]
    if {$oldGrab != ""} {
	set grabStatus [grab status $oldGrab]
    }
    grab $tw
    focus $tw.fr.e

    tkwait variable ::poWin::entryBoxFlag

    catch {focus $oldFocus}
    grab release $tw
    destroy $tw
    if {$oldGrab != ""} {
	if {$grabStatus == "global"} {
	    grab -global $oldGrab
	} else {
	    grab $oldGrab
	}
    }

    if { $::poWin::entryBoxFlag } {
	return $::poWin::entryBoxText
    } else {
        return ""
    }
}

proc ::poWin::StartScreenSaver { master msg } {

    set tw .poWin:ScreenSaverWin
    catch { destroy $tw}

    toplevel $tw
    canvas $tw.img -bg black -borderwidth 0 -bg blue
    pack $tw.img -fill both -expand 1 -side left

    set h [winfo screenheight $master]
    set w [winfo screenwidth $master]

    wm minsize $master $w $h
    wm maxsize $master $w $h
    set fmtStr [format "%dx%d+0+0" $w $h]
    wm geometry $tw $fmtStr
    wm overrideredirect $tw 1

    bind $tw <KeyPress> "set ::poWin::stopit 1"
    bind $tw.img <KeyPress> "set ::poWin::stopit 1"
    bind $tw <Motion> "set ::poWin::stopit 1"
    focus -force $tw

    set xpos 0
    set ypos 0
    image create photo ph1 -data [::poImgData::poLogo100_text_flip]
    image create photo ph2 -data [::poImgData::poLogo100_text]
    set phWidth  [image width ph1]
    set phHeight [image height ph1]
    $tw.img create image -200 -200 -anchor nw -tag img1 -image ph1
    $tw.img create image $xpos $ypos -anchor nw -tag img2 -image ph2
    $tw.img create text -200 -200 -text $msg -tag msg
    $tw.img coords msg [expr $w/2] [expr $h/2]
    $tw.img raise img2
    update

    set xoff 1
    set yoff 1
    set i 2
    set updown 1

    set ::poWin::stopit 0
    while { $::poWin::stopit == 0 } {
	incr xpos $xoff
	$tw.img coords img$i $xpos $ypos
	update
	if { $xpos >= [expr $w - $phWidth] || $xpos < 0 } {
	    if { $xoff > 0 } {
		incr xoff $updown
		incr yoff
	    $tw.img create text $xpos [expr $ypos + $phHeight/2] -text $msg
	    }
	    set xoff [expr -1 * $xoff]
	    if { $ypos >= [expr $h - $phHeight] || $ypos < 0 } {
		set updown [expr -1 * $updown]
		set yoff [expr -1 * $yoff]
	    }
	    incr ypos $yoff
	    set i [expr $i % 2 + 1]
	    $tw.img raise img$i
	}
    }
    destroy $tw
}

proc ::poWin::LoadFileToTextWidget { w fileName { mode r } } {
    set retVal [catch {open $fileName r} fp]
    if { $retVal != 0 } {
        error "Could not open file $fileName for reading."
    }
    if { [string compare $mode "r"] == 0 } {
        $w delete 1.0 end
    }
    while { ![eof $fp] } {
    	$w insert end [read $fp 2048]
    }
    close $fp
}

catch {puts "Loaded Package poTklib (Module [info script])"}


############################################################################
# Original file: poImglib/imgtransform.tcl
############################################################################

package provide poImglib 1.0

proc OPIApplyTfm { x y } {
    global tfm

    set u [expr ($x * [lindex $tfm 0] + $y * [lindex $tfm 2] + [lindex $tfm 4])]
    set v [expr ($x * [lindex $tfm 1] + $y * [lindex $tfm 3] + [lindex $tfm 5])]
    return [list $u $v]
}

proc OPIApplyTfmDeriv { x y } {
    global tfm

    set ux [lindex $tfm 0]
    set uy [lindex $tfm 2]
    set vx [lindex $tfm 1]
    set vy [lindex $tfm 3]
    return [list $ux $uy $vx $vy]
}


###########################################################################
#[
#	Function Name:	OPI_TransformImg
#
#	Description:	Applys a transformation matrix to an image.
#
#	Usage:		image_TRM2D (srcimg, destimg, T, oor)
#
#			srcimg:		image
#			destimg:	image
#			T:		TRM2D
#			oor:		integer, optional (IMGFILL)
#
#			Image "srcimg" is transformed geometrically according
#			to transformation matrix "T".  The result is stored in
#			image "destimg":
#			Each pixel in destimg, at position "d", is filled with
#			the color at position "s" in "srcimg", where
#
#			    s = dT.
#
#			If "s" is not within the boundaries of the source
#			image, "oor" determines what color is assigned to the
#			pixel at position "d".  Acceptable values for "oor"
#			are IMGFILL, IMGCLIP and IMGWRAP; see the description
#			of the "warp" command for an explanation.
#
#			For "img_TRM2D", the x and y coordinates in "srcimg"
#			and "destimg" increase from left to right and from bot-
#			tom to top; the lower left corners are at (0.0, 0.0);
#			the upper right corners are at (1.0, 1.0).
#
#			Note that parts of "image_TRM2D" can run concurrently
#			on multiple processors; see the desciption of the
#			"set_numproc" command.
#
#	Return Value:	None.
#]
###########################################################################

proc OPI_TransformImg { srcimg destimg T { oor $IMGFILL } } {
    global tfm IMGFILL

    poVec tfmCopy2D $T, tfm;
    $srcimg img_desc w h
    set size [::poMisc::Max $w $h]
    $destimg warp $srcimg OPIApplyTfm OPIApplyTfmDeriv $size $oor
}



###########################################################################
#[
#	Function Name:	rotate_image
#
#	Description:	Rotate an image by an arbitray angle.
#
#	Usage:		rotate_image (srcimg, destimg, angle, xcen, ycen, oor)
#
#			srcimg:		image
#			destimg:	image
#			angle:		float
#			xcen, ycen:	float, optional (0.5, 0.5)
#			oor:		integer, optional (IMGFILL)
#
#			Image "srcimg" is rotated by counterclockwise by
#			"angle" around position (xcen, ycen).  The result
#			is stored in image "destimg".
#
#			"Oor" determines how pixels in "destimg", which are
#			not covered by the rotated version of "srcimg", are
#			treated.  Acceptable values for "oor" are IMGFILL,
#			IMGCLIP and IMGWRAP; see the description of the "warp"
#			command for an explanation.
#
#			The x and y coordinates in "srcimg" increase from
#			bottom to top; the lower left corner is at (0.0, 0.0);
#			the upper right corner is at (1.0, 1.0).
#
#			"Angle" is measured in radians.  Use the "deg_rad"
#			function to convert an angle given in degrees into
#			radians.
#
#			Note that parts of "rotate_image" can run concurrently
#			on multiple processors; see the desciption of the
#			"set_numproc" command.
#
#	Return Value:	None.
#]
###########################################################################

proc OPI_RotateImg { srcimg destimg angle {xcen 0.5} {ycen 0.5} {oor 0} } {

    # Get hold of the rotation center and of the out-of-range
    # pixel treatment mode; supply default values for data not
    # specified by the user.

    set center [list [expr (-1.0 * $xcen)] [expr (-1.0 * $ycen)]]

    # Build the transformation matrix to do the rotation:
    # First shift the image so that the intended center of rotation
    # coincides with the coordinate origin.

    poVec tfmBuildTrans2D $center tfmTrans1

    # Scale the image in y to compensate for the aspect ratio of the
    # destination image.

    $destimg img_desc w h aspect
    set scale [list 1.0 [expr (1.0 / $aspect)]]
    poVec tfmConcatScale2D $scale $tfmTrans1 tfmScale1

    # Rotate the image.

    set rot [expr (-1.0 * $angle)]
    poVec tfmConcatRot2D $rot $tfmScale1 tfmRot1

    # Scale the image in y a second time, to compensate for the aspect
    # ratio of the source image.

    $srcimg img_desc w h aspect
    set scale [list 1.0 $aspect]
    poVec tfmConcatScale2D $scale $tfmRot1 tfmScale2

    # Shift the image so that the center of rotation moves back to its
    # original position.

    poVec vecScale2D -1 $center center2
    poVec tfmConcatTrans2D $center2 $tfmScale2 tfmTrans2

    # Finally, rotate the source image according to the transformation
    # matrix.

    OPI_TransformImg $srcimg $destimg $tfmTrans2 $oor
}

catch {puts "Loaded Package poImglib (Module [info script])"}

############################################################################
# Original file: poImglib/imgutil.tcl
############################################################################

package provide poImglib 1.0
 
proc deleteimg { img } {
    rename $img {}
}

proc readimg { imgName } {
    set found 1
    set retVal [catch {poImage readsimple $imgName} img]
    if { $retVal != 0 } {
        set retVal [catch {image create photo tmpPhoto -file $imgName} errCode]
	if { $retVal != 0 } {
	    ::poLog::Warning "Can't read image $imgName ($errCode)"
	    set found 0
	} else {
            set img [poImage photo_img tmpPhoto]
            image delete tmpPhoto
	}
    }
    if { $found == 1 } {
        return $img
    } else {
	return {}
    }
}

proc RGB { } {
    global RED GREEN BLUE
    return [list $RED $GREEN $BLUE]
}

proc RGBA { } {
    global RED GREEN BLUE MATTE
    return [list $RED $GREEN $BLUE $MATTE]
}

proc drawcolor_chan { chan val } {
    poImageMode get_drawcolor tmpcolor
    set newcolor [lreplace $tmpcolor $chan $chan $val]
    poImageMode set_drawcolor $newcolor
}

proc drawcolor_rgb { r g b } {
    global RED BLUE
    poImageMode get_drawcolor tmpcolor
    set newcolor [lreplace $tmpcolor $RED $BLUE $r $g $b]
    poImageMode set_drawcolor $newcolor
}

proc drawcolor_rgba { r g b a } {
    global RED MATTE
    poImageMode get_drawcolor tmpcolor
    set newcolor [lreplace $tmpcolor $RED $MATTE $r $g $b $a]
    poImageMode set_drawcolor $newcolor
}

proc drawmask_chan { chan val } {
    poImageMode get_drawmask tmpmask
    set newmask [lreplace $tmpmask $chan $chan $val]
    poImageMode set_drawmask $newmask
}

proc drawmask_rgb { r g b } {
    global RED BLUE
    poImageMode get_drawmask tmpmask
    set newmask [lreplace $tmpmask $RED $BLUE $r $g $b]
    poImageMode set_drawmask $newmask
}

proc drawmask_rgba { r g b a } {
    global RED MATTE
    poImageMode get_drawmask tmpmask
    set newmask [lreplace $tmpmask $RED $MATTE $r $g $b $a]
    poImageMode set_drawmask $newmask
}

proc drawmode_chan { chan val } {
    poImageMode get_drawmode tmpmode
    set newmode [lreplace $tmpmode $chan $chan $val]
    poImageMode set_drawmode $newmode
}

proc drawmode_rgb { r g b } {
    global RED BLUE
    poImageMode get_drawmode tmpmode
    set newmode [lreplace $tmpmode $RED $BLUE $r $g $b]
    poImageMode set_drawmode $newmode
}

proc drawmode_rgba { r g b a } {
    global RED MATTE
    poImageMode get_drawmode tmpmode
    set newmode [lreplace $tmpmode $RED $MATTE $r $g $b $a]
    poImageMode set_drawmode $newmode
}

proc compression_chan { chan val } {
    poImageMode get_compression tmpcompr
    set newcompr [lreplace $tmpcompr $chan $chan $val]
    poImageMode set_compression $newcompr
}

proc compression_rgb { r g b } {
    global RED BLUE
    poImageMode get_compression tmpcompr
    set newcompr [lreplace $tmpcompr $RED $BLUE $r $g $b]
    poImageMode set_compression $newcompr
}

proc compression_rgba { r g b a } {
    global RED MATTE
    poImageMode get_compression tmpcompr
    set newcompr [lreplace $tmpcompr $RED $MATTE $r $g $b $a]
    poImageMode set_compression $newcompr
}

proc pixformat_chan { chan val } {
    poImageMode get_pixformat tmpfmt
    set newfmt [lreplace $tmpfmt $chan $chan $val]
    poImageMode set_pixformat $newfmt
}

proc pixformat_rgb { r g b } {
    global RED BLUE
    poImageMode get_pixformat tmpfmt
    set newfmt [lreplace $tmpfmt $RED $BLUE $r $g $b]
    poImageMode set_pixformat $newfmt
}

proc pixformat_rgba { r g b a } {
    global RED MATTE
    poImageMode get_pixformat tmpfmt
    set newfmt [lreplace $tmpfmt $RED $MATTE $r $g $b $a]
    poImageMode set_pixformat $newfmt
}

proc PrintCompression { compr } {
    global OFF RLE
    switch $compr 		\
	$OFF  { puts "OFF" }	\
	$RLE  { puts "RLE" }	\
	default	{ puts "Unknown compression method $compr" }
}

proc PrintFormat { fmt } {
    global OFF UBYTE FLOAT
    switch $fmt 			\
	$OFF    { puts "OFF" }		\
	$UBYTE  { puts "UBYTE" }	\
	$FLOAT  { puts "FLOAT" }	\
	default	{ puts "Unknown pixel format $fmt" }
}

proc PrintDrawmode { mode } {
    global REPLACE ADD SUB XOR
    switch $mode 			\
	$REPLACE { puts "REPLACE" }	\
	$ADD     { puts "ADD" }		\
	$SUB     { puts "SUB" }		\
	$XOR     { puts "XOR" }		\
	default	{ puts "Unknown drawmode $mode" }
}

proc PrintDrawmask { bool } {
    PrintBoolean $bool
}

proc PrintDrawcolor { float } {
    PrintFloat $float
}

proc PrintChans { chnlist type } {
    global BRIGHTNESS RED GREEN BLUE MATTE
    global REDMATTE GREENMATTE BLUEMATTE 
    global HNORMAL VNORMAL DEPTH TEMPERATURE RADIANCE
    global NUMCHAN

    puts -nonewline "BRIGHTNESS : " ; Print$type [lindex $chnlist $BRIGHTNESS]
    puts -nonewline "RED        : " ; Print$type [lindex $chnlist $RED]
    puts -nonewline "GREEN      : " ; Print$type [lindex $chnlist $GREEN]
    puts -nonewline "BLUE       : " ; Print$type [lindex $chnlist $BLUE]
    puts -nonewline "MATTE      : " ; Print$type [lindex $chnlist $MATTE]
    puts -nonewline "REDMATTE   : " ; Print$type [lindex $chnlist $REDMATTE]
    puts -nonewline "GREENMATTE : " ; Print$type [lindex $chnlist $GREENMATTE]
    puts -nonewline "BLUEMATTE  : " ; Print$type [lindex $chnlist $BLUEMATTE]
    puts -nonewline "HNORMAL    : " ; Print$type [lindex $chnlist $HNORMAL]
    puts -nonewline "VNORMAL    : " ; Print$type [lindex $chnlist $VNORMAL]
    puts -nonewline "DEPTH      : " ; Print$type [lindex $chnlist $DEPTH]
    puts -nonewline "TEMPERATURE: " ; Print$type [lindex $chnlist $TEMPERATURE]
    puts -nonewline "RADIANCE   : " ; Print$type [lindex $chnlist $RADIANCE]
    puts -nonewline "NUMCHAN    : " ; puts $NUMCHAN
}

proc PrintImgSize { w h a } {
    puts "Width : $w"
    puts "Height: $h"
    puts "Aspect: $a"
}

proc PrintImgFmt { chans } {
    PrintChans $chans Format
}

proc PrintImgDesc { w h a g } {
    PrintImgSize $w $h $a
    puts "Gamma    : $g"
}

proc PrintColorCorrection { g rx ry gx gy bx by wx wy } {
    puts "Gamma    : $g"
    puts "CIE Red  : $rx $ry"
    puts "CIE Green: $gx $gy"
    puts "CIE Blue : $bx $by"
    puts "CIE White: $wx $wy"
}

catch {puts "Loaded Package poImglib (Module [info script])"}

############################################################################
# Original file: poImglib/poVec.tcl
############################################################################

package provide poImglib 1.0

proc deleteswatch { sw } {
    rename $sw {}
}

proc PrintBoolean { bool } {
    global OFF ON
    switch $bool 		\
	$OFF { puts "OFF" }	\
	$ON  { puts "ON" }	\
	default	{ puts "Unknown boolean value format $bool" }
}

proc PrintInteger { num } {
    puts [format "%d" $num]
}

proc PrintFloat { num } {
    puts [format "%6.3f" $num]
}

proc PrintVec { vec } {
    if { [llength $vec] == 2 } {
	puts -nonewline [format "\n\t\[%6.3f, %6.3f\]" \
	     [lindex $vec 0] [lindex $vec 1]]
    } elseif { [llength $vec] == 3 } {
	puts -nonewline [format "\n\t\[%6.3f, %6.3f, %6.3f\]" \
	     [lindex $vec 0] [lindex $vec 1] [lindex $vec 2]]
    } else {
	puts "Length of vector ([llength $vec]) invalid"
    }
}

proc PrintTfm { tfm } {
    if { [llength $tfm] == 12 } {
	puts -nonewline \
             [format "\n\t\[%6.3f, %6.3f, %6.3f\]\n\t\[%6.3f, %6.3f, %6.3f\] \
                      \n\t\[%6.3f, %6.3f, %6.3f\]\n\t\[%6.3f, %6.3f, %6.3f\]" \
	     [lindex $tfm 0] [lindex $tfm 1]  [lindex $tfm 2] \
             [lindex $tfm 3] [lindex $tfm 4]  [lindex $tfm 5] \
	     [lindex $tfm 6] [lindex $tfm 7]  [lindex $tfm 8] \
             [lindex $tfm 9] [lindex $tfm 10] [lindex $tfm 11] ]
    } elseif { [llength $tfm] == 6 } {
	puts -nonewline \
             [format "\n\t\[%6.3f, %6.3f\] \
                      \n\t\[%6.3f, %6.3f\] \
                      \n\t\[%6.3f, %6.3f\]" \
	     [lindex $tfm 0] [lindex $tfm 1] [lindex $tfm 2] \
             [lindex $tfm 3] [lindex $tfm 4] [lindex $tfm 5] ]
    } elseif { [llength $tfm] == 3 } {
	puts -nonewline [format "\n\t\[%6.3f, %6.3f, %6.3f\]" \
	     [lindex $tfm 0] [lindex $tfm 1] [lindex $tfm 2]]
    } else {
	puts "Length of transformation matrix ([llength $tfm]) invalid"
    }
}

catch {puts "Loaded Package poImglib (Module [info script])"}

############################################################################
# Original file: poImgview.tcl
############################################################################

############################################################################
#{@Tcl
#
#	Program:	poImgview
#	Copyright:	Paul Obermeier 1999-2008
#	Filename:	poImgview.tcl
#
#	First Version:  1999 / 05 / 20
#	Author:		Paul Obermeier
#
#	Description:
#			A portable image viewer.
#
#	Additional documentation:
#
#	Exported functions:
#		 	None, standalone program.
#
############################################################################

set auto_path [linsert $auto_path 0 [file dirname [info script]]]
set auto_path [linsert $auto_path 0 [file dirname [info nameofexecutable]]]
if { [info exists ::env(LD_LIBRARY_PATH)] } {
    set auto_path [linsert $auto_path 0 $::env(LD_LIBRARY_PATH)]
}

proc InitPackages { args } {
    global gPo

    foreach pkg $args {
	set retVal [catch {package require $pkg} gPo(ext,$pkg,version)]
	set gPo(ext,$pkg,avail) [expr !$retVal]
    }
}

InitPackages Tk poTcllib poTklib poExtlib img::raw img::dted Img poImg poImglib Tktable

proc GetPackageInfo {} {
    global gPo

    set msgList {}
    foreach name [lsort [array names gPo "ext,*,avail"]] {
        set pkg [lindex [split $name ","] 1]
        lappend msgList [list $pkg $gPo(ext,$pkg,avail) $gPo(ext,$pkg,version)]
    }
    return $msgList
}

proc PkgInfo {} {
    set tw .po:PkgInfoWin
    catch { destroy $tw }

    toplevel $tw
    wm title $tw "Package Information"
    wm resizable $tw true true

    frame $tw.fr0 -relief sunken -borderwidth 1
    grid  $tw.fr0 -row 0 -column 0 -sticky nwse
    set textId [::poWin::CreateScrolledText $tw.fr0 "" -wrap word -height 6]
    foreach pkgInfo [GetPackageInfo] {
        set msgStr "Package [lindex $pkgInfo 0]: [lindex $pkgInfo 2]\n"
	if { [lindex $pkgInfo 1] == 1} {
	    set tag avail
        } else {
	    set tag unavail
        }
        $textId insert end $msgStr $tag
    }
    $textId tag configure avail   -background green
    $textId tag configure unavail -background red
    $textId configure -state disabled

    # Create OK button
    frame $tw.fr1 -relief sunken -borderwidth 1
    grid  $tw.fr1 -row 1 -column 0 -sticky nwse
    button $tw.fr1.b -text "OK" -command "destroy $tw" -default active
    bind $tw.fr1.b <KeyPress-Return> "destroy $tw"
    pack $tw.fr1.b -side left -fill x -padx 2 -expand 1

    grid columnconfigure $tw 0 -weight 1
    grid rowconfigure    $tw 0 -weight 1

    bind $tw <Escape> "destroy $tw"
    bind $tw <Return> "destroy $tw"
    focus $tw
}

array set gLangStr [list \
    Cancel             { "Cancel" "Abbrechen" } \
    Ok                 { "OK" "OK" } \
]

proc Str { key args } {
    global gPo gLangStr

    set langStr [lindex $gLangStr($key) $gPo(language)]
    return [eval {format $langStr} $args]
}

proc GenDefaultLogo {} {
    global gPo gLogo

    set gLogo(photo) [image create photo -data [::poImgData::pwrdLogo200]]
    set gLogo(file)  ""
    if { $gPo(ext,poImg,avail) } {
	set gLogo(poImg) [poImage photo_img $gLogo(photo)]
    }
}

proc AddMenuCmd { menu label acc cmd args } {
    eval {$menu add command -label $label -accelerator $acc -command $cmd} $args
}

proc AddMenuRadio { menu label acc var val cmd args } {
    eval {$menu add radiobutton -label $label -accelerator $acc \
				-variable $var -value $val -command $cmd} $args
}

proc AddMenuCheck { menu label acc var cmd args } {
    eval {$menu add checkbutton -label $label -accelerator $acc \
				-variable $var -command $cmd} $args
}

proc dummy {} {
}

proc ShowMedian {} {
    global gPo

    set gPo(showMedian) [expr 1 - $gPo(showMedian)]
}

proc ShowMainWin {title} {
    global tcl_platform
    global gPo gLogo gImg gConv

    # Try to generate a truecolor toplevel as our main window.
    if { [catch {toplevel .po -visual truecolor}] } {
	toplevel .po
    }
    wm withdraw .

    # Create the windows title.
    wm title .po $title
    wm minsize .po 300 200
    set sw [winfo screenwidth .po]
    set sh [winfo screenheight .po]
    wm maxsize .po [expr $sw -20] [expr $sh -40]
    wm geometry .po [format "%dx%d+%d+%d" $gPo(main,w) $gPo(main,h) \
    					  $gPo(main,x) $gPo(main,y)]

    # Create 4 frames: The menu frame on top, info frame beneath menu,
    # toolbar frame at the left and an image frame.
    frame .po.toolfr -relief sunken -borderwidth 1
    frame .po.workfr -relief sunken -borderwidth 1
    pack .po.toolfr -side top -fill x
    pack .po.workfr -side top -fill both -expand 1

    frame .po.workfr.convfr -relief raised -borderwidth 1
    frame .po.workfr.imgfr  -relief raised -borderwidth 1
    frame .po.workfr.infofr -relief sunken -borderwidth 1

    grid .po.workfr.convfr -row 0 -column 0 -sticky news
    grid .po.workfr.imgfr  -row 1 -column 0 -sticky news
    grid .po.workfr.infofr -row 2 -column 0 -sticky news
    grid rowconfigure    .po.workfr 1 -weight 1
    grid columnconfigure .po.workfr 0 -weight 1

    frame .po.workfr.imgfr.fr
    pack  .po.workfr.imgfr.fr -expand 1 -fill both
    set gPo(paneWin) .po.workfr.imgfr.fr.pane
    panedwindow $gPo(paneWin) -orient horizontal -sashpad 5 -sashwidth 2 \
                      -opaqueresize true
    pack $gPo(paneWin) -side top -expand 1 -fill both
    set lf .po.workfr.imgfr.fr.pane.lfr
    set rf .po.workfr.imgfr.fr.pane.rfr
    frame $lf
    frame $rf
    pack $lf -expand 1 -fill both -side left
    pack $rf -expand 1 -fill both -side left
    $gPo(paneWin) add $lf $rf
    update
    $gPo(paneWin) sash place 0 $gPo(sashX) $gPo(sashY)

    set gPo(thumbFr)  [::poWin::CreateScrolledFrame $lf "Thumbnails"]
    set gPo(mainCanv) [::poWin::CreateScrolledCanvas $rf "" \
                       -width $gPo(main,w) -height [expr $gPo(main,h) -50]]
    set gPo(canvasBackReset) [$gPo(mainCanv) cget -bg]
    if { [info exists gPo(canvasBackColor)] } {
        $gPo(mainCanv) configure -bg $gPo(canvasBackColor)
    } else {
        set gPo(canvasBackColor) $gPo(canvasBackReset)
    }
    $gPo(mainCanv) create line 0 0 1 1 \
    		   -fill $gLogo(color) -tags LogoLine -arrow last
    $gPo(mainCanv) create rectangle 0 0 1 1 \
    		   -outline $gLogo(color) -tags LogoRect
    $gPo(mainCanv) create text 0 0 \
    		   -fill $gLogo(color) -text Logo -tags LogoText
    $gPo(mainCanv) create image 0 0 -anchor nw -tags [list MyImage PrintPixel]
    NewMarker $gPo(mainCanv) "ZoomRect" "rectangle" $gPo(zoomRectColor) \
	      0 0 $gPo(zoomRectSize) $gPo(zoomRectSize)
    bind $gPo(mainCanv) <Double-1> "Open"

    # Create menus File, Edit, View, Settings and Help
    set hMenu .po.menufr
    menu $hMenu -borderwidth 2 -relief sunken
    $hMenu add cascade -menu $hMenu.file -label File      -underline 0
    $hMenu add cascade -menu $hMenu.edit -label Edit      -underline 0
    $hMenu add cascade -menu $hMenu.view -label View      -underline 0
    $hMenu add cascade -menu $hMenu.sett -label Settings  -underline 0
    # OPA $hMenu add cascade -menu $hMenu.ext  -label Externals -underline 1
    $hMenu add cascade -menu $hMenu.help -label Help      -underline 0

    set fileMenu $hMenu.file
    menu $fileMenu -tearoff 0

    AddMenuCmd $fileMenu "New ..."     "Ctrl+N" New
    AddMenuCmd $fileMenu "Open ..."    "Ctrl+O" Open
    AddMenuCmd $fileMenu "Browse ..."      "Ctrl+B" BrowseDir
    if { $gPo(useDtedExt) } {
        AddMenuCmd $fileMenu "Browse DTED ..." "Ctrl+D" BrowseDted
    }
    $fileMenu add separator
    $fileMenu add cascade -label "Reopen"  -menu $fileMenu.reopen
    menu $fileMenu.reopen -tearoff 0
    AddRecentFiles $fileMenu.reopen false
    set gPo(reopenMenu) $fileMenu.reopen
    $fileMenu add cascade -label "Rebrowse"  -menu $fileMenu.rebrowse
    menu $fileMenu.rebrowse -tearoff 0
    AddRecentDirs $fileMenu.rebrowse false
    set gPo(rebrowseMenu) $fileMenu.rebrowse
    $fileMenu add separator

    AddMenuCmd $fileMenu "Save As ..."        "Ctrl+S" SaveAs
    AddMenuCmd $fileMenu "Capture canvas ..." "c"      CaptureCanv
    AddMenuCmd $fileMenu "Capture window ..." "w"      CaptureWin
    $fileMenu add separator
    AddMenuCmd $fileMenu "Convert"         "Ctrl+E" Convert
    AddMenuCmd $fileMenu "Convert all"     ""       ConvertAll
    $fileMenu add separator
    AddMenuCmd $fileMenu "Quit"            "Ctrl+Q" ExitProg
    bind .po <Control-n>  New
    bind .po <Control-o>  Open
    bind .po <Control-b>  BrowseDir
    if { $gPo(useDtedExt) } {
        bind .po <Control-d>  BrowseDted
    }
    bind .po <Control-s>  SaveAs
    bind .po <c>          CaptureCanv
    bind .po <w>          CaptureWin
    bind .po <Control-e>  Convert
    bind .po <Control-q>  ExitProg
    if { [string compare $tcl_platform(os) "windows"] == 0 } {
        bind .po <Alt-F4>     ExitProg
    }
    wm protocol .po WM_DELETE_WINDOW "ExitProg"

    set editMenu $hMenu.edit
    menu $editMenu -tearoff 0
    AddMenuCmd $editMenu "Clear"      "F9"     DelImg
    AddMenuCmd $editMenu "Clear all"  "F12"    DelAll
    AddMenuCmd $editMenu "Add logo"   "Ctrl+L" Apply
    AddMenuCmd $editMenu "Add to all" "Ctrl+A" ApplyAll
    AddMenuCmd $editMenu "Tile ..."   "Ctrl+A" ShowTileWin
    bind .po <Control-l>  Apply
    bind .po <Control-a>  ApplyAll
    bind .po <Key-F9>     DelImg
    bind .po <Key-F12>    DelAll

    set viewMenu $hMenu.view
    set zoomMenu $viewMenu.zoom
    menu $viewMenu -tearoff 0
    $viewMenu add cascade -label "Zoom" -menu $viewMenu.zoom
    AddMenuCheck $viewMenu "Zoom rectangle" "Ctrl+Y" gPo(zoomRectExists) \
                                                     "ShowZoomRect"
    AddMenuCheck $viewMenu "Median color" "Ctrl+M" gPo(showMedian) "dummy"
    AddMenuCmd $viewMenu "Info"         "Ctrl+I" ImgInfo
    bind .po <Control-i>  ImgInfo
    bind .po <Control-y>  ShowZoomRect
    bind .po <Control-m>  ShowMedian
    bind .po <Key-plus>   "ChangeZoom 1"
    bind .po <Key-minus>  "ChangeZoom -1"

    menu $zoomMenu -tearoff 0
    AddMenuRadio $zoomMenu " 20%"  "" gPo(zoom) 0.20 {ShowImg $gImg(curNo)}
    AddMenuRadio $zoomMenu " 25%"  "" gPo(zoom) 0.25 {ShowImg $gImg(curNo)}
    AddMenuRadio $zoomMenu " 33%"  "" gPo(zoom) 0.33 {ShowImg $gImg(curNo)}
    AddMenuRadio $zoomMenu " 50%"  "" gPo(zoom) 0.50 {ShowImg $gImg(curNo)}
    AddMenuRadio $zoomMenu "100%"  "" gPo(zoom) 1.00 {ShowImg $gImg(curNo)}
    AddMenuRadio $zoomMenu "200%"  "" gPo(zoom) 2.00 {ShowImg $gImg(curNo)}
    AddMenuRadio $zoomMenu "300%"  "" gPo(zoom) 3.00 {ShowImg $gImg(curNo)}
    AddMenuRadio $zoomMenu "400%"  "" gPo(zoom) 4.00 {ShowImg $gImg(curNo)}
    AddMenuRadio $zoomMenu "500%"  "" gPo(zoom) 5.00 {ShowImg $gImg(curNo)}
    bind .po <Control-r> { set gPo(zoom) 1.00 ; ShowImg $gImg(curNo) }

    set settMenu $hMenu.sett
    menu $settMenu -tearoff 0
    AddMenuCmd   $settMenu "Logging ..."        "" ::poLogOpt::OpenWin
    AddMenuCmd   $settMenu "Misc ..."           "" ShowMiscSettWin
    AddMenuCmd   $settMenu "File types ..."     "" ::poFiletype::OpenWin
    AddMenuCmd   $settMenu "Image types ..."    "" ::poImgtype::OpenWin
    AddMenuCmd   $settMenu "Image browser ..."  "" ::poImgBrowse::OpenWin
    AddMenuCmd   $settMenu "Logo ..."           "" ShowLogoWin
    AddMenuCmd   $settMenu "Conversion ..."     "" ShowConvWin
    AddMenuCmd   $settMenu "Zoom rectangle ..." "" ZoomRectSettings
    if { $gPo(useDtedExt) } {
        AddMenuCmd   $settMenu "DTED ..."           "" ShowDtedSettWin
    }
    # OPA AddMenuCmd   $settMenu "License ..."       "" ShowLicenseWin
    $settMenu add separator
    AddMenuCheck $settMenu "Save on exit"      "" gPo(autosaveOnExit) ""
    AddMenuCmd   $settMenu "Save Settings"     "" SaveSettings

    set extMenu $hMenu.ext
    menu $extMenu -tearoff 0
    AddMenuCmd $extMenu "Open animated GIF ..." "" AskOpenAniGif
    AddMenuCmd $extMenu "Save animated GIF ..." "" AskSaveAniGif

    set helpMenu $hMenu.help
    menu $helpMenu -tearoff 0
    AddMenuCmd $helpMenu "Online help ..."         "F1" HelpCont
    AddMenuCmd $helpMenu "About $gPo(appName) ..." ""   HelpProg
    AddMenuCmd $helpMenu "About Tcl/Tk ..."        ""   HelpTcl
    AddMenuCmd $helpMenu "About packages ..."      ""   PkgInfo
    bind .po <Key-F1>  HelpCont

    .po configure -menu $hMenu

    # Add new toolbar group and associated buttons.
    set btnFrame [::poToolbar::AddGroup .po.toolfr]

    ::poToolbar::AddButton $btnFrame.newfile [::poBmpData::newfile] New \
		           "New image (Ctrl+N)" -activebackground white
    ::poToolbar::AddButton $btnFrame.open [::poBmpData::open] Open \
		           "Open image file (Ctrl+O)" -activebackground white
    ::poToolbar::AddButton $btnFrame.browse [::poBmpData::browse] BrowseDir \
		           "Browse directory (Ctrl+B)" -activebackground white
    ::poToolbar::AddButton $btnFrame.save [::poBmpData::save] SaveAs \
		           "Save current image (Ctrl+S)" -activebackground white

    # Add new toolbar group and associated buttons.
    set btnFrame [::poToolbar::AddGroup .po.toolfr]

    ::poToolbar::AddButton $btnFrame.stamp [::poBmpData::stamp] Apply \
		           "Add logo to current image (Ctrl+L)" \
                           -activebackground white
    ::poToolbar::AddButton $btnFrame.stampall [::poBmpData::stampall] \
	                   ApplyAll "Add logo to all images (Ctrl+A)" \
			   -activebackground white
    ::poToolbar::AddButton $btnFrame.clear [::poBmpData::clear] DelImg \
		           "Clear current image (F9)" \
                           -activebackground "#FC7070"
    ::poToolbar::AddButton $btnFrame.clearall [::poBmpData::clearall] \
			   DelAll "Clear all images (F12)" \
			   -activebackground "#FC3030"

    # Add new toolbar group and associated buttons.
    set btnFrame [::poToolbar::AddGroup .po.toolfr]

    ::poToolbar::AddButton $btnFrame.reset [::poBmpData::hundred] \
			   { set gPo(zoom) 1.00 ; ShowImg $gImg(curNo) } \
			   "Reset image zoom (Ctrl+R)" -activebackground white
    ::poToolbar::AddButton $btnFrame.info [::poBmpData::info] ImgInfo \
			   "Info about current image (Ctrl+I)" \
                           -activebackground white

    # Add new toolbar group and associated buttons.
    set btnFrame [::poToolbar::AddGroup .po.toolfr]

    ::poToolbar::AddButton $btnFrame.first [::poBmpData::first] ShowFirst \
		           "Show first image (Home)" -activebackground white
    ::poToolbar::AddButton $btnFrame.left [::poBmpData::left] ShowPrev \
		           "Show previous image (Page Down)" \
                           -activebackground white
    ::poToolbar::AddButton $btnFrame.right [::poBmpData::right] ShowNext \
		           "Show next image (Page Up)" \
                           -activebackground white
    ::poToolbar::AddButton $btnFrame.last [::poBmpData::last] ShowLast \
		           "Show last image (End)" -activebackground white
    ::poToolbar::AddButton $btnFrame.playrev [::poBmpData::playrev] \
		       "ShowPlay -1" "Play reverse (o)" -activebackground white
    ::poToolbar::AddButton $btnFrame.playfwd [::poBmpData::playfwd] \
		       "ShowPlay  1" "Play forward (p)" -activebackground white
    ::poToolbar::AddButton $btnFrame.stop [::poBmpData::stop] "ShowStop" \
                           "Stop playing (s)" -activebackground white

    label .po.workfr.convfr.nr  -text "Image:"
    label .po.workfr.convfr.in  -text "Input:"
    label .po.workfr.convfr.out -text "Output:"
    label .po.workfr.convfr.infile
    label .po.workfr.convfr.outfile
    pack  .po.workfr.convfr.nr .po.workfr.convfr.in .po.workfr.convfr.infile \
          .po.workfr.convfr.out .po.workfr.convfr.outfile \
	  -in .po.workfr.convfr -side left -anchor w

    label .po.workfr.infofr.label -text Status -anchor w
    pack  .po.workfr.infofr.label -fill x -in .po.workfr.infofr
 
    # Create bindings for this application.
    catch {bind .po <Key-Page_Up>   ShowNext}
    catch {bind .po <Key-Prior>     ShowNext}
    catch {bind .po <Key-Page_Down> ShowPrev}
    catch {bind .po <Key-Next>      ShowPrev}
    catch {bind .po <Key-Home>      ShowFirst}
    catch {bind .po <Key-End>       ShowLast}
    catch {bind .po <Key-s>         ShowStop}
    catch {bind .po <Key-p>         "ShowPlay  1"}
    catch {bind .po <Key-o>         "ShowPlay -1"}

    bind .po <KeyPress-Escape>      "StopJob"

    # Read in the image used as the logo.
    ReadIcon
    set logosize2 [expr [::poMisc::Max $gLogo(w) $gLogo(h)] * 0.5]
    $gPo(mainCanv) configure -closeenough $logosize2

    # Initialize rectangle for logo.
    set gLogo(show) 1
    SetLogoPos
    # Hide rectangle.
    set gLogo(show) 0
    SetLogoPos

    # Initialize global variables.
    set gImg(curNo)  -1
    set gImg(num)    0 
}

proc WriteInfoStr { str } {
    .po.workfr.infofr.label configure -text $str
}

proc ClearRecentFileList { menuId } {
    global gPo 

    set gPo(recentFileList) {}
    $menuId delete 0 end
}

proc AddRecentFiles { menuId delOldEntries } {
    global gPo

    if { $delOldEntries } {
	$menuId delete 0 end
    }
    for { set i 0 } { $i < [llength $gPo(recentFileList)] } { incr i } {
        set curFile [lindex $gPo(recentFileList) $i]
	AddMenuCmd $menuId $curFile "" [list ReadImg $curFile]
    }
}

proc ClearRecentDirList { menuId } {
    global gPo 

    set gPo(recentDirList) {}
    $menuId delete 0 end
}

proc AddRecentDirs { menuId delOldEntries } {
    global gPo

    if { $delOldEntries } {
	$menuId delete 0 end
    }
    for { set i 0 } { $i < [llength $gPo(recentDirList)] } { incr i } {
        set curDir [lindex $gPo(recentDirList) $i]
	AddMenuCmd $menuId $curDir "" \
	           [list ::poImgBrowse::OpenDir $curDir ::ReadImg]
    }
}

proc ImgInfo {} {
    global gPo gImg

    if { $gImg(num) <= 0 } {
	tk_messageBox -message "No images loaded." -title "Information" \
	              -type ok -icon info
	focus .po
	return
    }

    set attrList [::poMisc::FileInfo $gImg(name,$gImg(curNo))]

    lappend attrList [list "Width"  [image width  $gImg(photo,$gImg(curNo))]]
    lappend attrList [list "Height" [image height $gImg(photo,$gImg(curNo))]]

    ::poWin::CreateOneFileInfoWin $gImg(name,$gImg(curNo)) $attrList
}

proc ChangeZoom { dir } {
    global gPo gImg

    set zoomList [list 0.20 0.25 0.33 0.50 1.00 2.00 3.00 4.00 5.00]
    set curZoomInd [lsearch -exact $zoomList $gPo(zoom)]
    if { $curZoomInd < 0 } {
	set gPo(zoom) 1.00
    } else {
	incr curZoomInd $dir
	if { $curZoomInd < 0 } {
	    set curZoomInd 0
	} elseif { $curZoomInd >= [llength $zoomList] } {
	    set curZoomInd  [expr [llength $zoomList] -1]
	}
	set gPo(zoom) [lindex $zoomList $curZoomInd]
    }
    ShowImg $gImg(curNo)
}

proc Zoom { zoomValue } {
    global gPo gImg

    if { $gImg(num) <= 0 } {
	return
    }

    set gPo(zoom) $zoomValue
    if { $zoomValue == 1.0 } {
	if { [info exists gPo(zoomPhoto)] } {
	    image delete $gPo(zoomPhoto) 
	    unset gPo(zoomPhoto)
	}
    } else {
	set w [expr int ([image width  $gImg(photo,$gImg(curNo))] * $zoomValue)]
	set h [expr int ([image height $gImg(photo,$gImg(curNo))] * $zoomValue)]
        if { $zoomValue < 1.0 } {
	    set sc [expr int (1.0 / $zoomValue)]
	    set cmd "-subsample"
	} elseif { $zoomValue > 1.0 } {
	    set sc [expr int($zoomValue)]
	    set cmd "-zoom"
	}
	if { [info exists gPo(zoomPhoto)] } {
	    $gPo(zoomPhoto) configure -width $w -height $h
	} else {
	    set gPo(zoomPhoto) [image create photo -width $w -height $h]
	}
        $gPo(zoomPhoto) copy $gImg(photo,$gImg(curNo)) $cmd $sc $sc
    }
}

proc DisplayLogo {} {
    global gLogo

    set w $gLogo(w)
    set h $gLogo(h)

    if { $w > $h } {
	set ws [expr int ($gLogo(xIcon))]
	set hs [expr int ((double($h) / double ($w) ) * $gLogo(yIcon))]
    } else {
	set ws [expr int ((double($w) / double ($h) ) * $gLogo(xIcon))]
	set hs [expr int ($gLogo(yIcon))]
    }
    if { $w == $ws } {
    	set xsub 1
    } else {
	set xsub [expr ($w / $ws) + 1]
    }
    if { $h == $hs } {
    	set ysub 1
    } else {
	set ysub [expr ($h / $hs) + 1]
    }
    $gLogo(photoIcon) blank
    $gLogo(photoIcon) copy $gLogo(photo) -subsample $xsub $ysub -to 0 0
    if { [string compare $gLogo(file) ""] == 0 } {
        set bindStr "Default logo"
    } else {
        set bindStr $gLogo(file)
    }
    ::poToolhelp::AddBinding $gLogo(iconButton) $bindStr
}

proc DestroyLogoWin { tw } {
    global gLogo

    SetLogoBindings .po 0
    SetLogoBindings $tw 0
    set gLogo(show) 0
    SetLogoPosCB
    SetLogoColorCB
    if { ![string is integer -strict $gLogo(xoff)] } {
	set gLogo(xoff) 0
    }
    if { ![string is integer -strict $gLogo(yoff)] } {
	set gLogo(yoff) 0
    }
    destroy $tw
}

proc CancelLogoWin { tw args } {
    global gPo gLogo

    foreach pair $args {
	set var [lindex $pair 0]
	set val [lindex $pair 1]
	set cmd [format "set %s %s" $var $val]
	eval $cmd
    }
    set gPo(settChanged) false
    DestroyLogoWin $tw
}

proc SetLogoBindings { w onOff } {
    global gLogo gPo

    if { $onOff } {
	bind $w <Key-Left>  "SetLogoPosCB -1  0"
	bind $w <Key-Right> "SetLogoPosCB  1  0"
	bind $w <Key-Up>    "SetLogoPosCB  0  1"
	bind $w <Key-Down>  "SetLogoPosCB  0 -1"
	bind $w <Shift-Key-Left>  "SetLogoPosCB -10   0"
	bind $w <Shift-Key-Right> "SetLogoPosCB  10   0"
	bind $w <Shift-Key-Up>    "SetLogoPosCB   0  10"
	bind $w <Shift-Key-Down>  "SetLogoPosCB   0 -10"
	bind $w <Control-Key-Left>  {SetLogoPosCB [expr -1 * $gLogo(w)]   0}
	bind $w <Control-Key-Right> {SetLogoPosCB [expr  1 * $gLogo(w)]   0}
	bind $w <Control-Key-Up>    {SetLogoPosCB 0 [expr  1 * $gLogo(h)]}
	bind $w <Control-Key-Down>  {SetLogoPosCB 0 [expr -1 * $gLogo(h)]}
	bind $w <Control-l> Apply
	bind $w <Control-a> ApplyAll

	$gPo(mainCanv) bind PrintPixel <Motion> ""
	$gPo(mainCanv) bind ZoomRect   <Motion> ""
	$gPo(mainCanv) bind ZoomRect   <1>      ""
	$gPo(mainCanv) bind LogoText   <Button-1> { SetCurMousePos %x %y }
	$gPo(mainCanv) bind LogoRect   <Button-1> { SetCurMousePos %x %y }
	$gPo(mainCanv) bind LogoText   <B1-Motion> { MoveViewportRect %x %y }
	$gPo(mainCanv) bind LogoRect   <B1-Motion> { MoveViewportRect %x %y }
	set gPo(curCursor) "hand1"
    } else {
	bind $w <Key-Left>          ""
	bind $w <Key-Right>         ""
	bind $w <Key-Up>            ""
	bind $w <Key-Down>          ""
	bind $w <Shift-Key-Left>    ""
	bind $w <Shift-Key-Right>   ""
	bind $w <Shift-Key-Up>      ""
	bind $w <Shift-Key-Down>    ""
	bind $w <Control-Key-Left>  ""
	bind $w <Control-Key-Right> ""
	bind $w <Control-Key-Up>    ""
	bind $w <Control-Key-Down>  ""

	$gPo(mainCanv) bind LogoText <Button-1> ""
	$gPo(mainCanv) bind LogoRect <Button-1> ""
	$gPo(mainCanv) bind LogoText <B1-Motion> ""
	$gPo(mainCanv) bind LogoRect <B1-Motion> ""
	$gPo(mainCanv) bind PrintPixel <Motion> \
	               "PrintPixelValue $gPo(mainCanv) %x %y"
	$gPo(mainCanv) bind ZoomRect <Motion> \
	               "+UpdateZoomRect $gPo(mainCanv) %x %y %X %Y"
	$gPo(mainCanv) bind ZoomRect <1> \
	               "UpdateZoomRect  $gPo(mainCanv) %x %y %X %Y"
	set gPo(curCursor) "crosshair"
    }
    $gPo(mainCanv) configure -cursor $gPo(curCursor)
}

proc ShowLogoWin {} {
    global gPo gLogo

    set tw .poImgview:logoWin

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }
    # Create the bitmaps needed for this window and store them for later use.
    if { ![info exists gLogo(tlBmp)] } {
	set gLogo(tlBmp) [image create bitmap -data [::poBmpData::topleft]]
	set gLogo(trBmp) [image create bitmap -data [::poBmpData::topright]]
	set gLogo(blBmp) [image create bitmap -data [::poBmpData::bottomleft]]
	set gLogo(brBmp) [image create bitmap -data [::poBmpData::bottomright]]
	set gLogo(ceBmp) [image create bitmap -data [::poBmpData::center]]
	set gLogo(whBmp) [image create bitmap -data [::poBmpData::white]]
    }

    if { [catch {toplevel $tw -visual truecolor}] } {
        toplevel $tw
    }
    wm title $tw "Logo settings"
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $gLogo(x) $gLogo(y)]

    SetLogoBindings .po 1
    SetLogoBindings $tw 1

    # Generate left column with text labels.
    set row 0
    foreach labelStr { "Logo offset X:" \
		       "Logo offset Y:" \
		       "Logo position:" \
		       "Logo color:" \
		       "Logo image file:" } {
	label $tw.l$row -text $labelStr
        grid  $tw.l$row -row $row -column 0 -sticky nw
	incr row
    }

    # Generate right column with entries and buttons.
    # Row 0: Horizontal logo offset.
    set varList {}
    set row 0
    entry $tw.e$row -textvariable gLogo(xoff)
    bind  $tw.e$row <Any-KeyRelease> { SetLogoPosCB }
    grid  $tw.e$row -row $row -column 1 -sticky nwe
    set tmpList [list [list gLogo(xoff)] [list $gLogo(xoff)]]
    lappend varList $tmpList

    # Row 1: Vertical logo offset.
    incr row
    entry $tw.e$row -textvariable gLogo(yoff)
    bind  $tw.e$row <Any-KeyRelease> { SetLogoPosCB }
    grid  $tw.e$row -row $row -column 1 -sticky nwe
    set tmpList [list [list gLogo(yoff)] [list $gLogo(yoff)]]
    lappend varList $tmpList

    # Row 2: Logo position.
    incr row
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 1 -sticky nw -pady 3

    radiobutton $tw.fr$row.tl -image $gLogo(tlBmp) -indicatoron 0 \
		-variable gLogo(pos) -value tl -command SetLogoPosCB
    radiobutton $tw.fr$row.tr -image $gLogo(trBmp) -indicatoron 0 \
		-variable gLogo(pos) -value tr -command SetLogoPosCB
    radiobutton $tw.fr$row.bl -image $gLogo(blBmp) -indicatoron 0 \
		-variable gLogo(pos) -value bl -command SetLogoPosCB
    radiobutton $tw.fr$row.br -image $gLogo(brBmp) -indicatoron 0 \
		-variable gLogo(pos) -value br -command SetLogoPosCB
    radiobutton $tw.fr$row.ce -image $gLogo(ceBmp) -indicatoron 0 \
		-variable gLogo(pos) -value ce -command SetLogoPosCB
    pack $tw.fr$row.tl $tw.fr$row.tr $tw.fr$row.bl $tw.fr$row.br \
         $tw.fr$row.ce -in $tw.fr$row -side left -padx 2
    set tmpList [list [list gLogo(pos)] [list $gLogo(pos)]]
    lappend varList $tmpList

    # Row 3: Logo color.
    incr row
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 1 -sticky nw -pady 3

    set colorList [list White Black Red Green Blue]
    foreach color $colorList {
	radiobutton $tw.fr$row.rb$color -indicatoron 0 \
		    -selectcolor $color -background $color \
		    -activebackground $color -image $gLogo(whBmp) \
		    -variable gLogo(color) -value $color \
		    -relief sunken -command SetLogoColorCB
	if { [string compare $gLogo(color) $color] == 0 } {
	    $tw.fr$row.rb$color select
	}
	pack $tw.fr$row.rb$color -side left -in $tw.fr$row -fill x -padx 2
    }
    set tmpList [list [list gLogo(color)] [list $gLogo(color)]]
    lappend varList $tmpList

    # Row 4: Image file name used for logo.
    incr row
    set gLogo(photoIcon) $tw.p$row
    image create photo $gLogo(photoIcon) \
          -width $gLogo(xIcon) -height $gLogo(yIcon)
    button $tw.b$row -image $gLogo(photoIcon) -command OpenIcon
    grid   $tw.b$row -row $row -column 1 -sticky nw -pady 3
    set gLogo(iconButton) $tw.b$row

    DisplayLogo

    # Create Cancel and OK buttons
    incr row
    frame $tw.fr$row -relief sunken -borderwidth 2
    grid  $tw.fr$row -row $row -column 0 -columnspan 2 -sticky news

    button $tw.fr$row.b1 -text [Str Cancel] \
	    -command "CancelLogoWin $tw $varList"
    button $tw.fr$row.b2 -text [Str Ok] \
                         -command "DestroyLogoWin $tw"
    bind  $tw <KeyPress-Escape> "CancelLogoWin $tw $varList"
    pack $tw.fr$row.b1 $tw.fr$row.b2 -side left -fill x -padx 2 -expand 1

    set gLogo(show) 1
    $gPo(mainCanv) raise LogoText
    $gPo(mainCanv) raise LogoRect
    $gPo(mainCanv) raise LogoLine
    SetLogoPos
    focus $tw
}

proc TileImg {} {
    global gPo gImg

    set imgNo $gImg(curNo)
    set phImg $gImg(photo,$imgNo)

    set w [image width  $phImg]
    set h [image height $phImg]
    set w2 [expr $w * $gPo(tile,xrepeat)]
    set h2 [expr $h * $gPo(tile,yrepeat)]

    set tileImg [image create photo -width $w2 -height $h2]

    for { set x 0 } { $x < $gPo(tile,xrepeat) } { incr x } {
        for { set y 0 } { $y < $gPo(tile,yrepeat) } { incr y } {
            if { $gPo(tile,xmirror) || $gPo(tile,ymirror) } {
                set xsamp 1
                set ysamp 1
                if { $gPo(tile,xmirror) && [expr $x %2] == 1 } {
                    set xsamp -1
                }
                if { $gPo(tile,ymirror) && [expr $y %2] == 1 } {
                    set ysamp -1
                }
                set sampleCmd [format "-subsample %d %d" $xsamp $ysamp]
            } else {
                set sampleCmd ""
            }
            eval $tileImg copy $phImg -to [expr $x*$w] [expr $y*$h] $sampleCmd
        }
    }
    AddImg $tileImg "" "Tiled image" $gPo(mainCanv)
}

proc ShowTileWin {} {
    global gPo gLogo

    set tw .poImgview:tileWin

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    if { [catch {toplevel $tw -visual truecolor}] } {
        toplevel $tw
    }
    wm title $tw "Image tiling"
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $gLogo(x) $gLogo(y)]

    # Generate left column with text labels.
    set row 0
    foreach labelStr { "Repeat in X:" \
		       "Repeat in Y:" } {
        label $tw.l$row -text $labelStr
        grid  $tw.l$row -row $row -column 0 -sticky nw
	incr row
    }

    # Generate right column with entries and buttons.
    set varList {}
    set row 0
    set fr [frame $tw.fr$row]
    grid  $fr -row $row -column 1 -sticky news
    entry $fr.e -textvariable gPo(tile,xrepeat)
    checkbutton $fr.b -text "Mirror" -indicatoron 1 -variable gPo(tile,xmirror)
    pack $fr.e $fr.b -in $fr -side left -padx 2
    set tmpList [list [list gPo(tile,xrepeat)] [list $gPo(tile,xrepeat)]]
    lappend varList $tmpList

    incr row
    set fr [frame $tw.fr$row]
    grid  $fr -row $row -column 1 -sticky news
    entry $fr.e -textvariable gPo(tile,yrepeat)
    checkbutton $fr.b -text "Mirror" -indicatoron 1 -variable gPo(tile,ymirror)
    pack $fr.e $fr.b -in $fr -side left -padx 2
    set tmpList [list [list gPo(tile,yrepeat)] [list $gPo(tile,yrepeat)]]
    lappend varList $tmpList

    # Create Preview button
    incr row
    frame $tw.fr$row -relief sunken -borderwidth 2
    grid  $tw.fr$row -row $row -column 0 -columnspan 2 -sticky news
    button $tw.fr$row.b1 -text "Tile now" -command "TileImg"
    pack $tw.fr$row.b1 -side left -fill x -padx 2 -expand 1

    # Create Cancel and OK buttons
    incr row
    frame $tw.fr$row -relief sunken -borderwidth 2
    grid  $tw.fr$row -row $row -column 0 -columnspan 2 -sticky news

    button $tw.fr$row.b1 -text [Str Cancel] \
	    -command "CancelSettingsWin $tw $varList"
    button $tw.fr$row.b2 -text [Str Ok] -command "destroy $tw"
    bind  $tw <KeyPress-Escape> "CancelSettingsWin $tw $varList"
    pack $tw.fr$row.b1 $tw.fr$row.b2 -side left -fill x -padx 2 -expand 1

    focus $tw
}

proc CancelSettingsWin { tw args } {
    global gPo

    foreach pair $args {
	set var [lindex $pair 0]
	set val [lindex $pair 1]
	set cmd [format "set %s %s" $var $val]
	eval $cmd
    }
    destroy $tw
}

proc OKSettingsWin { tw args } {
    global gPo

    set gPo(settChanged) true
    destroy $tw
}

proc ShowMiscSettWin {} {
    global gPo

    set tw .poImgview:miscSettWin

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    toplevel $tw
    wm title $tw "Miscellaneous settings"
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $gPo(miscSett,x) $gPo(miscSett,y)]

    # Generate left column with text labels.
    set row 0
    foreach labelStr { "Mode:" \
                       "Canvas background color:" \
                       "Entries in Reopen menu:" \
                       "Entries in Rebrowse menu:" } {
	label $tw.l$row -text $labelStr
        grid  $tw.l$row -row $row -column 0 -sticky nw
	incr row
    }

    set varList {}
    # Generate right column with entries and buttons.
    # Part 1: Mode switches
    set row 0
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky news

    checkbutton $tw.fr$row.cb1 -text "Show splash screen" \
                               -variable gPo(showSplash)
    checkbutton $tw.fr$row.cb2 -text "Show thumbnails" \
                               -variable gPo(showThumbs)
    checkbutton $tw.fr$row.cb3 -text "Color values in hex" \
                               -variable gPo(hexColorValues)
    ::poToolhelp::AddBinding $tw.fr$row.cb2 \
                             "Clear all images after switching this value"
    pack $tw.fr$row.cb1 $tw.fr$row.cb2 $tw.fr$row.cb3 \
         -side top -anchor w -in $tw.fr$row -pady 2

    set tmpList [list [list gPo(showSplash)] [list $gPo(showSplash)]]
    lappend varList $tmpList
    set tmpList [list [list gPo(showThumbs)] [list $gPo(showThumbs)]]
    lappend varList $tmpList
    set tmpList [list [list gPo(hexColorValues)] [list $gPo(hexColorValues)]]
    lappend varList $tmpList

    # Row 2: Color of canvas background.
    incr row
    frame  $tw.fr$row
    grid   $tw.fr$row -row $row -column 1 -sticky news
    button $tw.fr$row.b1 -bg $gPo(canvasBackColor) -text "..." \
                        -command "GetCanvasBackColor $tw.fr$row.b1"
    button $tw.fr$row.b2 -text "Reset" \
                         -command "ResetCanvasBackColor $tw.fr$row.b1"
    ::poToolhelp::AddBinding $tw.fr$row.b1 "Select new canvas background color"
    ::poToolhelp::AddBinding $tw.fr$row.b2 "Reset to default background color"
    pack $tw.fr$row.b1 $tw.fr$row.b2 -side left -anchor w -padx 3 \
                                     -in $tw.fr$row -expand 1 -fill both
    set tmpList [list [list gPo(canvasBackColor)] [list $gPo(canvasBackColor)]]
    lappend varList $tmpList

    # Row 3: Number of entries in Reopen menu
    incr row
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky news

    entry $tw.fr$row.e -textvariable gPo(recentFileListLen) -width 3
    button $tw.fr$row.b -text "Clear list" \
                        -command "ClearRecentFileList $gPo(reopenMenu)"
    ::poToolhelp::AddBinding $tw.fr$row.b "This operation can not be canceled"

    pack  $tw.fr$row.e -side left -pady 2 -padx 5
    pack  $tw.fr$row.b -side left -pady 2 -fill x -expand 1

    set tmpList [list [list gPo(recentFileListLen)] \
                      [list $gPo(recentFileListLen)]]
    lappend varList $tmpList

    # Row 4: Number of entries in Rebrowse menu
    incr row
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky news

    entry $tw.fr$row.e -textvariable gPo(recentDirListLen) -width 3
    button $tw.fr$row.b -text "Clear list" \
                        -command "ClearRecentDirList $gPo(rebrowseMenu)"
    ::poToolhelp::AddBinding $tw.fr$row.b "This operation can not be canceled"
    pack  $tw.fr$row.e -side left -pady 2 -padx 5
    pack  $tw.fr$row.b -side left -pady 2 -fill x -expand 1

    set tmpList [list [list gPo(recentDirListLen)] \
                      [list $gPo(recentDirListLen)]]
    lappend varList $tmpList

    # Create Cancel and OK buttons
    incr row
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 0 -columnspan 2 -sticky news

    bind  $tw <KeyPress-Escape> "CancelSettingsWin $tw $varList"
    button $tw.fr$row.b1 -text "Cancel" \
                         -command "CancelSettingsWin $tw $varList"
    wm protocol $tw WM_DELETE_WINDOW "CancelSettingsWin $tw $varList"

    bind  $tw <KeyPress-Return> "OKSettingsWin $tw"
    button $tw.fr$row.b2 -text "OK" -command "OKSettingsWin $tw" \
			 -default active
    pack $tw.fr$row.b1 $tw.fr$row.b2 -side left -fill x -padx 2 -expand 1
    focus $tw
}

proc ShowDtedSettWin {} {
    global gPo

    set tw .poImgview:dtedSettWin

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    toplevel $tw
    wm title $tw "DTED settings"
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $gPo(dtedSett,x) $gPo(dtedSett,y)]

    # Generate left column with text labels.
    set row 0
    foreach labelStr { "DTED Level:" \
                       "Global min value:" \
		       "Global max value:" } {
	label $tw.l$row -text $labelStr
        grid  $tw.l$row -row $row -column 0 -sticky nw
	incr row
    }

    set varList {}
    # Generate right column with entries and buttons.
    # Row 0: DTED Level
    set row 0
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky nw

    entry $tw.fr$row.e -textvariable gPo(dted,level) -width 2
    pack  $tw.fr$row.e -side top -anchor w -in $tw.fr$row -pady 2 -ipadx 2

    set tmpList [list [list gPo(dted,level)] [list $gPo(dted,level)]]
    lappend varList $tmpList

    # Row 1: Minimum elevation value for all files.
    incr row
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky nw

    entry $tw.fr$row.e -textvariable gPo(dted,minVal) -width 6
    pack  $tw.fr$row.e -side top -anchor w -in $tw.fr$row -pady 2 -ipadx 2

    set tmpList [list [list gPo(dted,minVal)] [list $gPo(dted,minVal)]]
    lappend varList $tmpList

    # Row 2: Maximum elevation value for all files.
    incr row
    frame $tw.fr$row
    grid $tw.fr$row -row $row -column 1 -sticky nw

    entry $tw.fr$row.e -textvariable gPo(dted,maxVal) -width 6
    pack  $tw.fr$row.e -side top -anchor w -in $tw.fr$row -pady 2 -ipadx 2

    set tmpList [list [list gPo(dted,maxVal)] [list $gPo(dted,maxVal)]]
    lappend varList $tmpList

    # Create Cancel and OK buttons
    incr row
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 0 -columnspan 2 -sticky news

    bind  $tw <KeyPress-Escape> "CancelSettingsWin $tw $varList"
    button $tw.fr$row.b1 -text "Cancel" \
                         -command "CancelSettingsWin $tw $varList"
    wm protocol $tw WM_DELETE_WINDOW "CancelSettingsWin $tw $varList"

    bind  $tw <KeyPress-Return> "OKSettingsWin $tw"
    button $tw.fr$row.b2 -text "OK" -command "OKSettingsWin $tw" \
			 -default active
    pack $tw.fr$row.b1 $tw.fr$row.b2 -side left -fill x -padx 2 -expand 1
    focus $tw
}

# OPA >>>>>

proc DestroyZoomRect {} {
    global gPo

    if { [info exists gPo(zoomRect)] && [winfo exists $gPo(zoomRect)] } {
	destroy $gPo(zoomRect)
	set gPo(zoomRectExists) 0
    }
}

proc ShowZoomRect {} {
    global gPo gImg

    if { $gImg(num) <= 0 } {
	tk_messageBox -message "You must load an image first." \
		      -type ok -icon warning
	set gPo(zoomRectExists) 0
	focus .po
	return
    }

    set tw .poImgview:ZoomRect
    set gPo(zoomRect) $tw

    if { [winfo exists $tw] } {
    	DestroyZoomRect
	return
    }

    if { [catch {toplevel $tw -visual truecolor}] } {
        toplevel $tw
    }
    wm overrideredirect $tw true

    frame $tw.workfr -bg $gPo(zoomRectColor) -borderwidth 1
    pack $tw.workfr -side top -fill both -expand 1

    set w [expr 2 * $gPo(zoomRectSize) * $gPo(zoomRectFactor)]
    set h $w
    set canv [canvas $tw.workfr.canv -relief ridge -width $w -height $h]
    pack $canv -side left
    set phId [image create photo -width $w -height $h]
    $canv create image 0 0 -anchor nw -image $phId -tags $phId
    set gPo(zoomRectExists) 1
    set gPo(zoomRect,canv)  $canv
    set gPo(zoomRect,photo) $phId
    set mainGeom [winfo geometry .po]
    scan $mainGeom "%dx%d+%d+%d" mw mh mx my
    wm geometry $tw [format "+%d+%d" $mx $my]
    lower $tw
    update
}

proc UpdateZoomRect { canvasId cx cy sx sy } {
    global gPo gImg

    if { [info exists gPo(zoomRect)] && [winfo exists $gPo(zoomRect)] } {
	set px [expr int([$canvasId canvasx $cx] / $gPo(zoom))]
	set py [expr int([$canvasId canvasy $cy] / $gPo(zoom))]
	set src $gImg(photo,$gImg(curNo))
	set dst $gPo(zoomRect,photo)
	
	set x1 [expr ($px - $gPo(zoomRectSize))]
	set y1 [expr ($py - $gPo(zoomRectSize))]
	set x2 [expr ($px + $gPo(zoomRectSize))]
	set y2 [expr ($py + $gPo(zoomRectSize))]
	if { [catch {$dst copy $src -from $x1 $y1 $x2 $y2 -to 0 0 \
	                            -zoom $gPo(zoomRectFactor)}] } {
	    $dst blank
	    lower $gPo(zoomRect)
        } else {
	    set w [expr 2 * $gPo(zoomRectSize) * $gPo(zoomRectFactor)]
	    set h $w
	    wm geometry $gPo(zoomRect) \
		[format "+%d+%d" \
	        [expr $sx - $w/2] \
		[expr $sy - $h - int($gPo(zoomRectSize) * $gPo(zoom)) - 3]]
	    raise $gPo(zoomRect)
	}
        update
    }
}

proc ResetCanvasBackColor { buttonId } {
    global gPo

    set gPo(canvasBackColor) $gPo(canvasBackReset)
    $buttonId configure -bg $gPo(canvasBackReset)
    $gPo(mainCanv) configure -bg $gPo(canvasBackReset)
}

proc GetCanvasBackColor { buttonId } {
    global gPo

    set newColor [tk_chooseColor -initialcolor $gPo(canvasBackColor)]
    if { [string compare $newColor ""] != 0 } {
	set gPo(canvasBackColor) $newColor
	# Color settings window may have already been closed. So catch it.
	catch { $buttonId configure -bg $newColor }
	$gPo(mainCanv) configure -bg $newColor
    }
}

proc GetZoomRectColor { buttonId } {
    global gPo

    set newColor [tk_chooseColor -initialcolor $gPo(zoomRectColor)]
    if { [string compare $newColor ""] != 0 } {
	set gPo(zoomRectColor) $newColor
	# Color settings window may have already been closed. So catch it.
	catch { $buttonId configure -bg $newColor }
    }
}

proc CheckZoomRectSettings { entryId minVal maxVal { updEntry 1 } } {
    global gPo

    set tmpVal [$entryId get]
    set retVal [catch {set curVal [expr int ($tmpVal)] }]
    if { $retVal == 0 } {
        if { $curVal >= $minVal && $curVal <= $maxVal } {
	    if { $updEntry } {
		$entryId configure -bg green
	    }
	    return 1
	}
    }
    if { $updEntry } {
	$entryId configure -bg red
    }
    return 0
}

proc UpdZoomRectSettings { tw e1 e2 } {
    global gPo

    set e1Color [$e1 cget -bg]
    set e2Color [$e2 cget -bg]
    if { ($e1Color == "red") || ($e2Color == "red") } {
	tk_messageBox -message "Please correct the invalid red entries." \
		      -type ok -icon warning
	focus $tw
        return
    }
    $gPo(mainCanv) itemconfigure "ZoomRect" -outline $gPo(zoomRectColor)
    set gPo(settChanged) true
    destroy $tw
}

proc ZoomRectSettings {} {
    global gPo

    set tw .poImgview:ZoomRectSettings
    set gPo(zoomRectSett) $tw

    DestroyZoomRect
    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    toplevel $tw
    wm title $tw "Zoom Rectangle Settings"
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $gPo(zoomRectSett,x) $gPo(zoomRectSett,y)]

    # Generate left column with text labels.
    set row 0
    foreach labelStr [list \
	"Size of zoom rectangle (5-30):" \
	"Zoom factor (2-8):" \
	"Color of zoom rectangle:" ] {
	label $tw.l$row -text $labelStr
        grid  $tw.l$row -row $row -column 0 -sticky nw
	incr row
    }

    # Generate right column with entries and buttons.
    set varList {}
    set xpad 20
    set ypad 3

    # Row 0: Window size
    set row 0
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 1 -sticky nw
    entry $tw.fr$row.e -textvariable gPo(zoomRectSize) -width 5
    pack  $tw.fr$row.e -anchor w -in $tw.fr$row -padx $xpad -pady $ypad
    bind  $tw.fr$row.e <Any-KeyRelease> "CheckZoomRectSettings $tw.fr$row.e 5 30"
    set tmpList [list [list gPo(zoomRectSize)] [list $gPo(zoomRectSize)]]
    lappend varList $tmpList

    # Row 1: Zoom factor
    set row 1
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 1 -sticky nw
    entry $tw.fr$row.e -textvariable gPo(zoomRectFactor) -width 5
    pack  $tw.fr$row.e -anchor w -in $tw.fr$row -padx $xpad -pady $ypad
    bind  $tw.fr$row.e <Any-KeyRelease> "CheckZoomRectSettings $tw.fr$row.e 2 8"
    set tmpList [list [list gPo(zoomRectFactor)] [list $gPo(zoomRectFactor)]]
    lappend varList $tmpList

    # Row 2: Zoom rectangle color
    set row 2
    frame  $tw.fr$row
    grid   $tw.fr$row -row $row -column 1 -sticky we
    button $tw.fr$row.b -bg $gPo(zoomRectColor) -text "..." \
                        -command "GetZoomRectColor $tw.fr$row.b"
    pack   $tw.fr$row.b -anchor w -in $tw.fr$row \
                        -padx $xpad -pady $ypad -expand 1 -fill both
    set tmpList [list [list gPo(zoomRectColor)] [list $gPo(zoomRectColor)]]
    lappend varList $tmpList

    # Create Cancel and OK buttons
    incr row
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 0 -columnspan 2 -sticky news

    button $tw.fr$row.b1 -text "Cancel" \
	   -command "CancelSettingsWin $tw $varList"
    button $tw.fr$row.b2 -text "OK" \
	   -command "UpdZoomRectSettings $tw $tw.fr0.e $tw.fr1.e"
    bind  $tw <KeyPress-Escape> "CancelSettingsWin $tw $varList"
    bind  $tw <KeyPress-Return> "UpdZoomRectSettings $tw $tw.fr0.e $tw.fr1.e"
    pack $tw.fr$row.b1 $tw.fr$row.b2 -side left -fill x -padx 2 -expand 1
    wm protocol $tw WM_DELETE_WINDOW "CancelSettingsWin $tw $varList"
    focus $tw
}

# OPA <<<<<

proc CancelConvWin { tw args } {
    global gPo gConv

    foreach pair $args {
	set var [lindex $pair 0]
	set val [lindex $pair 1]
	set cmd [format "set %s %s" $var $val]
	eval $cmd
    }
    UpdateFileName
    set gPo(settChanged) false
    destroy $tw
}

proc ShowConvWin {} {
    global gLogo gConv

    set tw .poImgview:convWin

    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    toplevel $tw
    wm title $tw "Conversion settings"
    wm resizable $tw false false
    wm geometry $tw [format "+%d+%d" $gConv(x) $gConv(y)]

    # Generate left column with text labels.
    set row 0
    foreach labelStr { "Output format:" \
		       "Output prefix:" \
		       "Output directory:" } {
	label $tw.l$row -text $labelStr
        grid  $tw.l$row -row $row -column 0 -sticky nw
	incr row
    }

    # Generate right column with entries and buttons.

    # Row 0: Output format
    set row 0
    set varList {}
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 1 -sticky nwe -pady 3

    combobox::combobox $tw.fr$row.cb -editable 0 -relief sunken \
                       -command UpdFileTypeCB

    set fmtList [::poImgtype::GetFmtList]
    set fmtList [linsert $fmtList 0 "SameAsInput"]
    foreach fmt $fmtList {
	if { [string compare $fmt "SameAsInput"] == 0 } {
	    set fmtSuff "*"
	} else {
	    set fmtSuff [lindex [::poImgtype::GetExtList $fmt] 0]
	}
	set str [format "%s (%s)" $fmt $fmtSuff]
	$tw.fr$row.cb list insert end $str
	if { [string compare $fmt $gConv(outFmt)] == 0 } {
            $tw.fr$row.cb configure -value $str
        }
    }
    pack $tw.fr$row.cb -side top -anchor w -fill x -expand 1 -in $tw.fr$row
    set tmpList [list [list gConv(outFmt)] [list $gConv(outFmt)]]
    lappend varList $tmpList

    # Row 1: Output prefix
    incr row
    entry $tw.e$row -textvariable gConv(prefix)
    bind  $tw.e$row <Any-KeyRelease> { UpdFileNameCB }
    grid  $tw.e$row -row $row -column 1 -sticky nwe -pady 3
    set tmpList [list [list gConv(prefix)] [list $gConv(prefix)]]
    lappend varList $tmpList

    # Row 2: Output directory
    incr row
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 1 -sticky nwe -pady 3

    radiobutton $tw.fr$row.rb1 -text "Same as input directory" \
    	        -variable gConv(useOutDir) -value 0 -command UpdFileNameCB
    radiobutton $tw.fr$row.rb2 -text "Use this directory for all images:" \
		-variable gConv(useOutDir) -value 1 -command UpdFileNameCB
    entry $tw.fr$row.e -textvariable gConv(outDir)
    bind  $tw.fr$row.e <Any-KeyRelease> { UpdFileNameCB }
    pack $tw.fr$row.rb1 $tw.fr$row.rb2 \
	 -side top -anchor w -in $tw.fr$row -pady 0
    pack $tw.fr$row.e -side top -anchor w \
         -in $tw.fr$row -pady 0 -fill x -expand 1
    set tmpList [list [list gConv(useOutDir)] [list $gConv(useOutDir)]]
    lappend varList $tmpList

    # Create Cancel and OK buttons
    incr row
    frame $tw.fr$row -relief sunken -borderwidth 2
    grid  $tw.fr$row -row $row -column 0 -columnspan 2 -sticky news

    button $tw.fr$row.b1 -text [Str Cancel] \
	    -command "CancelConvWin $tw $varList"
    button $tw.fr$row.b2 -text [Str Ok] -command "destroy $tw"
    bind  $tw <KeyPress-Escape> "CancelConvWin $tw $varList"
    pack $tw.fr$row.b1 $tw.fr$row.b2 -side left -fill x -padx 2 -expand 1

    focus $tw
}

proc ShowLicenseWin {} {
    global gPo

    ::poWin::ShowEntryBox SaveLicense $gPo(license) \
			   "Enter License" "" 27 $gPo(fixedFont)
}

proc SaveLicense { val } {
    global gPo gImg

    set gPo(settChanged) true
    set gPo(license) $val
    UpdateMainTitle $gImg(num)
}

proc GetNewImgColor { buttonId } {
    global gPo

    set newColor [tk_chooseColor -initialcolor $gPo(new,c)]
    if { [string compare $newColor ""] != 0 } {
        set gPo(new,c) $newColor
        $buttonId configure -bg $newColor
    }
}

proc ShowNewImageWin { cmd title { noChars 20 } } {
    global gPo

    set tw ".po:newImageWin"
    if { [winfo exists $tw] } {
	::poWin::Raise $tw
	return
    }

    toplevel $tw
    wm title $tw $title
    wm resizable $tw false false

    set row 0
    foreach labelStr { "Width:" \
		       "Height:" \
                       "Color:" \
		       "Alpha:" } {
	label $tw.l$row -text $labelStr
        grid  $tw.l$row -row $row -column 0 -sticky nw
	incr row
    }

    # Generate right column with entries.
    set row 0
    entry $tw.e$row -textvariable gPo(new,w)
    $tw.e$row configure -width $noChars
    $tw.e$row selection range 0 end
    bind  $tw.e$row <KeyPress-Return> "$cmd"
    bind  $tw.e$row <KeyPress-Escape> DestroyNewImageWin
    grid  $tw.e$row -row $row -column 1 -sticky nwe

    incr row
    entry $tw.e$row -textvariable gPo(new,h)
    $tw.e$row configure -width $noChars
    bind  $tw.e$row <KeyPress-Return> "$cmd"
    bind  $tw.e$row <KeyPress-Escape> DestroyNewImageWin
    grid  $tw.e$row -row $row -column 1 -sticky nwe

    incr row
    button $tw.b$row -bg $gPo(new,c) -text "..." \
                     -command "GetNewImgColor $tw.b$row"
    grid  $tw.b$row -row $row -column 1 -sticky nwe

    incr row
    frame $tw.fr$row
    grid  $tw.fr$row -row $row -column 0 -columnspan 2 -sticky news

    button $tw.fr$row.b1 -text "Cancel" -command DestroyNewImageWin
    button $tw.fr$row.b2 -text "OK"     -command $cmd -default active
    pack $tw.fr$row.b1 $tw.fr$row.b2 -side left -expand 1 -fill x -padx 2

    focus $tw.e0
}

proc DestroyNewImageWin {} {
    destroy .po:newImageWin
}

proc LoadSettings {} {
    global gPo gLogo gConv

    set gPo(useDtedExt)        0
    set gPo(language)          0	; # Default language English
    set gPo(lastDir)           {}	; # Least recently used directory
    set gPo(lastDtedDir)       {}	; # Least recently used DTED directory
    set gPo(saveLastImgFmt)    1
    set gPo(lastImgFmt)        ""
    set gPo(recentFileList)    {}	; # List of recently used files
    set gPo(recentFileListLen) 10	; # Length of above list
    set gPo(recentDirList)     {}	; # List of recently used directories
    set gPo(recentDirListLen)  10	; # Length of above list
    set gPo(showSplash)        1	; # Show splash screen
    set gPo(showThumbs)        1	; # Show thumbnail images

    set gPo(dted,level)        0	; # Default: DTED level 0
    set gPo(dted,minVal)       ""	; # Default: File specific mapping
    set gPo(dted,maxVal)       ""	; # Default: File specific mapping

    set gPo(sashX)             150
    set gPo(sashY)               0
    set gLogo(color) White		; # Default logo color
    set gLogo(pos)   tl			; # Default logo position
    set gLogo(xoff)  25 		; # Default logo horizontal offset
    set gLogo(yoff)  25 		; # Default logo vertical offset
    set gLogo(xtxt)  25 		; # Default logo text horizontal offset
    set gLogo(ytxt)  25			; # Default logo text vertical offset 
    set gLogo(file)  ""			; # Default logo file name
    set gLogo(x)      0			; # Default logo window x position
    set gLogo(y)     25			; # Default logo window y position
    set gLogo(xIcon) 100		; # Default logo icon width
    set gLogo(yIcon) 100		; # Default logo icon height
    set gLogo(show)  0			; # Show logo rectangle in canvas

    set gConv(prefix)    "Logo_"	; # Default prefix for outfile name
    set gConv(useOutDir) 0		; # Use the default output directory
    set gConv(outDir)    ""		; # Name of default output directory
    set gConv(outFmt)    "SameAsInput"	; # Default image format for output
    set gConv(x)          0		; # Default save window x position
    set gConv(y)         25		; # Default save window y position

    set gPo(main,w)   640		; # Default main window width
    set gPo(main,h)   480		; # Default main window height
    set gPo(main,x)     0		; # Default main window x position
    set gPo(main,y)    25		; # Default main window y position

    set gPo(miscSett,x) 100		; # Default settings window x position
    set gPo(miscSett,y)  50		; # Default settings window y position

    set gPo(dtedSett,x) 120		; # Default DTED window x position
    set gPo(dtedSett,y)  70		; # Default DTED window y position

    set gPo(new,w)   256		; # Default width of new image
    set gPo(new,h)   256		; # Default height of new image
    set gPo(new,c)   "#000000"		; # Default color of new image (black)

    set gPo(tile,xrepeat)   2
    set gPo(tile,yrepeat)   2
    set gPo(tile,xmirror)   0 
    set gPo(tile,ymirror)   0

    set gPo(showMedian)     1
    set gPo(hexColorValues) 0

    set gPo(zoomRectSize)   10
    set gPo(zoomRectColor)  "red"
    set gPo(zoomRectFactor)  4
    set gPo(zoomRectSett,x) 10
    set gPo(zoomRectSett,y) 30

    set gPo(license)        "POEVAL-BX3320-FY0432-DR7537" ; # Demo license
    set gPo(autosaveOnExit) 1
    set gPo(settChanged)    false
    set gPo(curCursor)      "crosshair"

    set cfgFile [::poMisc::GetCfgFile $gPo(appName) $gPo(optCfgDir)]
    if { [file readable $cfgFile] } {
	set gPo(initStr) "Configuration loaded from file $cfgFile"
	source $cfgFile
    } else {
	set gPo(initStr) "No configuration file found. Using default values."
    }
    ::poFiletype::LoadFromFile
    ::poImgtype::LoadFromFile
    ::poImgBrowse::LoadFromFile
}

proc SaveSettings {} {
    global gPo gLogo gConv

    set cfgFile [::poMisc::GetCfgFile $gPo(appName) $gPo(optCfgDir)]
    set retVal [catch {open $cfgFile w} fp]
    if { $retVal == 0 } {
	puts $fp "# Settings which can be set via GUI"
	puts $fp "set gLogo(color) \{$gLogo(color)\}"
	puts $fp "set gLogo(pos)   \{$gLogo(pos)\}"
	puts $fp "set gLogo(xoff)  \{$gLogo(xoff)\}"
	puts $fp "set gLogo(yoff)  \{$gLogo(yoff)\}"
	puts $fp "set gLogo(file)  \{$gLogo(file)\}"

	puts $fp "set gPo(dted,level)  \{$gPo(dted,level)\}"
	puts $fp "set gPo(dted,minVal) \{$gPo(dted,minVal)\}"
	puts $fp "set gPo(dted,maxVal) \{$gPo(dted,maxVal)\}"

	puts $fp "set gConv(prefix)    \{$gConv(prefix)\}"
	puts $fp "set gConv(useOutDir) \{$gConv(useOutDir)\}"
	puts $fp "set gConv(outDir)    \{$gConv(outDir)\}"
	puts $fp "set gConv(outFmt)    \{$gConv(outFmt)\}"

	puts $fp "set gPo(license)        \{$gPo(license)\}"
	puts $fp "set gPo(showSplash)     \{$gPo(showSplash)\}"
	puts $fp "set gPo(showThumbs)     \{$gPo(showThumbs)\}"
	puts $fp "set gPo(autosaveOnExit) \{$gPo(autosaveOnExit)\}"

	puts $fp "# New image options: Width, height, color"
	puts $fp "set gPo(new,w)   \{$gPo(new,w)\} ; # Width in pixel"
	puts $fp "set gPo(new,h)   \{$gPo(new,h)\} ; # Height in pixel"
	puts $fp "set gPo(new,c)   \{$gPo(new,c)\} ; # Color in #RRGGBB"

        set gPo(sashX) [lindex [$gPo(paneWin) sash coord 0] 0]
        set gPo(sashY) [lindex [$gPo(paneWin) sash coord 0] 1]
	puts $fp "set gPo(sashX)   \{$gPo(sashX)\}"
	puts $fp "set gPo(sashY)   \{$gPo(sashY)\}"

	puts $fp "::poLog::ShowConsole \{[::poLog::GetConsoleMode]\}"
	set levels [::poLog::GetDebugLevels]
	puts $fp "::poLog::SetDebugLevels \{$levels\}"

	puts $fp "set gPo(canvasBackColor)  \{$gPo(canvasBackColor)\}"

	puts $fp "set gPo(tile,xrepeat)   \{$gPo(tile,xrepeat)\}"
	puts $fp "set gPo(tile,yrepeat)   \{$gPo(tile,yrepeat)\}"
	puts $fp "set gPo(tile,xmirror)   \{$gPo(tile,xmirror)\}"
	puts $fp "set gPo(tile,ymirror)   \{$gPo(tile,ymirror)\}"

	puts $fp "set gPo(showMedian)     \{$gPo(showMedian)\}"
	puts $fp "set gPo(hexColorValues) \{$gPo(hexColorValues)\}"

	puts $fp "set gPo(zoomRectColor)  \{$gPo(zoomRectColor)\}"
	puts $fp "set gPo(zoomRectSize)   \{$gPo(zoomRectSize)\}"
	puts $fp "set gPo(zoomRectFactor) \{$gPo(zoomRectFactor)\}"

	puts $fp "# Settings for window geometry"
	if { [info exists gPo(zoomRectSett)] && \
	     [winfo exists $gPo(zoomRectSett)] } {
	    puts $fp "set gPo(zoomRectSett,x) \{[winfo x $gPo(zoomRectSett)]\}"
	    puts $fp "set gPo(zoomRectSett,y) \{[winfo y $gPo(zoomRectSett)]\}"
	} else {
	    puts $fp "set gPo(zoomRectSett,x) \{$gPo(zoomRectSett,x)\}"
	    puts $fp "set gPo(zoomRectSett,y) \{$gPo(zoomRectSett,y)\}"
	}
	if { [winfo exists .poImgview:logoWin] } {
	    puts $fp "set gLogo(x)    \{[winfo x .poImgview:logoWin]\}"
	    puts $fp "set gLogo(y)    \{[winfo y .poImgview:logoWin]\}"
	} else {
	    puts $fp "set gLogo(x)    \{$gLogo(x)\}"
	    puts $fp "set gLogo(y)    \{$gLogo(y)\}"
	}
	if { [winfo exists .poImgview:convWin] } {
	    puts $fp "set gConv(x)    \{[winfo x .poImgview:convWin]\}"
	    puts $fp "set gConv(y)    \{[winfo y .poImgview:convWin]\}"
	} else {
	    puts $fp "set gConv(x)    \{$gConv(x)\}"
	    puts $fp "set gConv(y)    \{$gConv(y)\}"
	}
	if { [winfo exists .poImgview:miscSettWin] } {
	    puts $fp "set gPo(miscSett,x) \{[winfo x .poImgview:miscSettWin]\}"
	    puts $fp "set gPo(miscSett,y) \{[winfo y .poImgview:miscSettWin]\}"
	} else {
	    puts $fp "set gPo(miscSett,x) \{$gPo(miscSett,x)\}"
	    puts $fp "set gPo(miscSett,y) \{$gPo(miscSett,y)\}"
	}
	if { [winfo exists .poImgview:dtedSettWin] } {
	    puts $fp "set gPo(dtedSett,x) \{[winfo x .poImgview:dtedSettWin]\}"
	    puts $fp "set gPo(dtedSett,y) \{[winfo y .poImgview:dtedSettWin]\}"
	} else {
	    puts $fp "set gPo(dtedSett,x) \{$gPo(dtedSett,x)\}"
	    puts $fp "set gPo(dtedSett,y) \{$gPo(dtedSett,y)\}"
	}

	puts $fp "set gPo(main,w)    \{[winfo width .po]\}"
	puts $fp "set gPo(main,h)    \{[winfo height .po]\}"
	puts $fp "set gPo(main,x)    \{[::poMisc::Max [winfo x .po] 0]\}"
	puts $fp "set gPo(main,y)    \{[::poMisc::Max [winfo y .po] 0]\}"

	puts $fp "# Settings not editable from GUI"
	puts $fp "set gLogo(xtxt)  \{$gLogo(xtxt)\}"
	puts $fp "set gLogo(ytxt)  \{$gLogo(ytxt)\}"
	puts $fp "set gLogo(xIcon) \{$gLogo(xIcon)\}"
	puts $fp "set gLogo(yIcon) \{$gLogo(yIcon)\}"

	puts $fp "set gPo(language)       \{$gPo(language)\}"
	puts $fp "set gPo(lastDir)        \{$gPo(lastDir)\}"
	puts $fp "set gPo(lastDtedDir)    \{$gPo(lastDtedDir)\}"
	puts $fp "set gPo(saveLastImgFmt) \{$gPo(saveLastImgFmt)\}"
	puts $fp "set gPo(lastImgFmt)     \{$gPo(lastImgFmt)\}"
	puts $fp "set gPo(recentFileListLen) \{$gPo(recentFileListLen)\}"
	puts $fp "set gPo(recentFileList)    \{[lrange $gPo(recentFileList) 0 \
					  [expr $gPo(recentFileListLen) -1]]\}"
	puts $fp "set gPo(recentDirListLen) \{$gPo(recentDirListLen)\}"
	puts $fp "set gPo(recentDirList)    \{[lrange $gPo(recentDirList) 0 \
					  [expr $gPo(recentDirListLen) -1]]\}"

	close $fp
	set gPo(settChanged) false

	::poImgtype::SaveToFile
	::poFiletype::SaveToFile
	::poImgBrowse::SaveToFile
	WriteInfoStr "Configuration stored in file $cfgFile"
	return
    }
    ::poFiletype::SaveToFile
    ::poImgtype::SaveToFile
    ::poImgBrowse::SaveToFile
    tk_messageBox -message "Could not save configuration to file $cfgFile." \
		  -title "Warning" -type ok -icon warning
    focus .po
}

proc ShowImg { imgNo } {
    global gPo gLogo gImg

    if { $imgNo < 0 } {
	.po.workfr.convfr.nr      configure -text "Image:"
	.po.workfr.convfr.infile  configure -text {}
	.po.workfr.convfr.outfile configure -text {}
    } else {
	if { $gImg(num) <= 0 } {
	    return
	}

	Zoom $gPo(zoom)
	if { $gPo(zoom) == 1.00 } {
	    $gPo(mainCanv) itemconfigure MyImage -image $gImg(photo,$imgNo)
	    set iw [image width  $gImg(photo,$imgNo)]
	    set ih [image height $gImg(photo,$imgNo)]
	    set gPo(main,w) $iw
	    set gPo(main,h) $ih
	} else {
	    $gPo(mainCanv) itemconfigure MyImage -image $gPo(zoomPhoto)
	    set iw [image width  $gPo(zoomPhoto)]
	    set ih [image height $gPo(zoomPhoto)]
	    set gPo(main,w) [image width  $gImg(photo,$imgNo)] 
	    set gPo(main,h) [image height $gImg(photo,$imgNo)]
	}
 	set sw [winfo screenwidth .po]
 	set sh [winfo screenheight .po]
	$gPo(mainCanv) configure -width  [::poMisc::Min $iw $sw] \
	                         -height [::poMisc::Min $ih $sh]
	$gPo(mainCanv) configure -scrollregion "0 0 $iw $ih"
	SetLogoPos
	$gPo(mainCanv) raise LogoText
	$gPo(mainCanv) raise LogoRect
	$gPo(mainCanv) raise LogoLine
	set gImg(thumbSelected) $gImg(photo,$imgNo)
        UpdateFileName
    }
    update
}

proc UpdFileTypeCB { args } {
    global gPo gConv

    set gPo(settChanged) true
    set fmtString [lindex $args 1]
    set ret [regexp -nocase {([^\(]*)\((\.*[^\)]*)\)} $fmtString \
            total fmtName fmtSuff]
    set gConv(outFmt) [string trim $fmtName]
    UpdateFileName
}

proc UpdFileNameCB {} {
    global gPo

    set gPo(settChanged) true
    UpdateFileName
}

proc UpdateFileName {} {
    global gConv gImg

    if { $gImg(curNo) < 0 } {
    	return
    }

     set curImgNo [expr $gImg(curNo) +1]
    .po.workfr.convfr.nr configure -text "Image: $curImgNo"
    .po.workfr.convfr.infile configure \
                             -text [file tail $gImg(name,$gImg(curNo))]
    if { $gConv(useOutDir) == 1 } {
	set dirName $gConv(outDir)
    } else {
	set dirName [file dirname $gImg(name,$gImg(curNo))]
    }
    set fileName $gConv(prefix)
    set tmpName [file tail $gImg(name,$gImg(curNo))]
    if { [string compare $gConv(outFmt) "SameAsInput"] != 0 } {
	append fileName [file rootname $tmpName] \
	                [lindex [::poImgtype::GetExtList $gConv(outFmt)] 0]
    }  else {
	append fileName $tmpName
    }
    set pathName [file join $dirName $fileName]
    .po.workfr.convfr.outfile configure -text [file join $pathName]
}

proc AddImg { phImg poImg imgName canvasId } {
    global gImg gPo

    if { $gPo(showThumbs) } {
	set thumbFile [::poImgBrowse::GetThumbFile $imgName]
	set thumbInfo [::poImgBrowse::ReadThumbFile $thumbFile]
	set thumbImg  [lindex $thumbInfo 0]
	if { [string compare $thumbImg "None"] == 0 } {
	    # No thumb file. Create thumb on the fly.
	    set thumbImg [::poImgBrowse::CreateThumbImg $phImg]
	}
	set btnName [format "%s.b_%s" $gPo(thumbFr) $phImg]
	radiobutton $btnName -image $thumbImg \
                    -selectcolor green -bg $gPo(canvasBackColor) \
	            -indicatoron false -variable gImg(thumbSelected) \
		    -value $phImg -command "ShowImgByName $phImg"
	pack $btnName -side top
	set gImg(thumb,$gImg(num)) $thumbImg
	set gImg(thumbBtn,$gImg(num)) $btnName
    }
    set gImg(photo,$gImg(num)) $phImg
    if { [string compare $poImg ""] != 0 } {
	set gImg(poImg,$gImg(num)) $poImg
    }
    set gImg(name,$gImg(num)) $imgName

    $canvasId itemconfigure MyImage -image $gImg(photo,$gImg(num))

    set gImg(curNo) $gImg(num)
    incr gImg(num)
    ShowImg [expr $gImg(num) -1]
    UpdateMainTitle $gImg(num)
}

proc UpdateMainTitle { noImgs } {
    global gPo

    if { $gPo(ext,poImg,avail) } {
	if { ! [poCheckLicense $gPo(license)] } {
	    set evalStr "Luxus evaluation edition"
	} else {
	    set evalStr "Luxus edition"
	}
    } else {
	set evalStr "Standard edition"
    }
    # OPA
    set evalStr "Standard edition"

    wm title .po [format "%s (%d image%s loaded) %s" \
	       $gPo(appName) $noImgs [::poMisc::Plural $noImgs] $evalStr]
}

proc DelImg { } {
    global gPo gImg

    if { $gImg(num) > 0 } {
        image delete $gImg(photo,$gImg(curNo))
	if { [info exists gImg(thumb,$gImg(curNo))] } {
	    image delete $gImg(thumb,$gImg(curNo))
	    destroy $gImg(thumbBtn,$gImg(curNo))
	}
	if { [info exists gImg(poImg,$gImg(curNo))] } {
	    deleteimg $gImg(poImg,$gImg(curNo))   
	    unset gImg(poImg,$gImg(curNo))
	}
	for { set i $gImg(curNo) } { $i < $gImg(num) -1 } { incr i } {
	    set j [expr ($i + 1)]
	    set gImg(photo,$i) $gImg(photo,$j)
	    set gImg(name,$i)  $gImg(name,$j)
	    if { [info exists gImg(thumb,$j)] } {
		set gImg(thumb,$i) $gImg(thumb,$j)
		set gImg(thumbBtn,$i) $gImg(thumbBtn,$j)
	    }
	    if { [info exists gImg(poImg,$j)] } {
		set gImg(poImg,$i) $gImg(poImg,$j)
	    }
	}
	incr gImg(num) -1
        ShowImg -1
	if { $gImg(curNo) > 0 } {
	    ShowPrev
	} else {
	    if { $gImg(num) > 0 } {
	       ShowImg $gImg(curNo)
	    }
        }
	if { $gImg(num) <= 0 && [info exists gPo(zoomPhoto)] } {
	    image delete $gPo(zoomPhoto)
	    unset gPo(zoomPhoto)
	}
    }
    UpdateMainTitle $gImg(num)
}

proc ShowImgByName { phImg } {
    global gImg

    for { set i 0 } { $i < $gImg(num) } { incr i } {
        if { [string compare $phImg $gImg(photo,$i)] == 0 } {
	    set gImg(curNo) $i
	    ShowImg $i
	}
    }
}

proc ShowFirst {} {
    global gImg

    if { $gImg(num) > 0 } {
        set gImg(curNo) 0
        ShowImg $gImg(curNo)
    }
}

proc ShowLast {} {
    global gImg

    if { $gImg(num) > 0 } {
        set gImg(curNo) [expr ($gImg(num) -1)]
        ShowImg $gImg(curNo)
    }
}

proc ShowPrev {} {
    global gImg

    if { $gImg(num) > 0 && $gImg(curNo) > 0 } {
	incr gImg(curNo) -1
    	ShowImg $gImg(curNo)
    }
}

proc ShowNext {} {
    global gImg

    if { $gImg(num) > 0 } {
        if { $gImg(curNo) < [expr ($gImg(num) -1)] } {
    	    incr gImg(curNo) 1
    	    ShowImg $gImg(curNo)
        }
    }
}

proc ShowPlay { { dir 1 } } {
    global gImg

    if { $gImg(num) < 0 } {
	return
    }
    set gImg(stopPlay) 0
    if { $dir == 1 } {
	while { $gImg(curNo) < [expr ($gImg(num) -1)] && !$gImg(stopPlay) } {
	    incr gImg(curNo) 1
	    ShowImg $gImg(curNo)
	}
    } else {
	while { $gImg(curNo) > 0 && !$gImg(stopPlay) } {
	    incr gImg(curNo) -1
	    ShowImg $gImg(curNo)
	}
    }
}

proc ShowStop {} {
    global gImg
    
    set gImg(stopPlay) 1
}

proc SetLogoColorCB {} {
    global gPo gLogo

    set gPo(settChanged) true
    SetLogoColor
}

proc SetLogoColor {} {
    global gLogo
    global gPo
    
    $gPo(mainCanv) itemconfigure LogoText -fill    $gLogo(color)
    $gPo(mainCanv) itemconfigure LogoRect -outline $gLogo(color)
    $gPo(mainCanv) itemconfigure LogoLine -fill    $gLogo(color)
}

proc SetLogoPosCB { { xoff 0 } { yoff 0 } } {
    global gPo gLogo

    if { [string is integer -strict $gLogo(xoff)] } {
	incr gLogo(xoff) $xoff
    }
    if { [string is integer -strict $gLogo(yoff)] } {
	incr gLogo(yoff) $yoff
    }
    set gPo(settChanged) true
    SetLogoPos
}

proc SetLogoPos {} {
    global gPo gLogo

    if { $gLogo(show) == 0 } {
	$gPo(mainCanv) coords LogoRect -100 -100 -90 -90
	$gPo(mainCanv) coords LogoText -100 -100
	$gPo(mainCanv) coords LogoLine -100 -100 -90 -90
        return
    }

    set retVal [catch {set xoff [expr int ($gLogo(xoff))] }]
    if { $retVal != 0 } {
	set xoff 0
    }
    set retVal [catch {set yoff [expr int ($gLogo(yoff))] }]
    if { $retVal != 0 } {
	set yoff 0
    }
    
    switch $gLogo(pos) {
	tl { set x $xoff 
             set y $yoff
	     set xscroll 0
	     set yscroll 0
	   }
	tr { set x [expr $gPo(main,w) - $xoff - $gLogo(w)] 
             set y $yoff 
	     set xscroll 1
	     set yscroll 0
           }
	bl { set x $xoff
	     set y [expr $gPo(main,h) - $yoff - $gLogo(h)] 
	     set xscroll 0
	     set yscroll 1
           }
	br { set x [expr $gPo(main,w) - $xoff - $gLogo(w)] 
	     set y [expr $gPo(main,h) - $yoff - $gLogo(h)] 
	     set xscroll 1
	     set yscroll 1
	   }
	ce { set x [expr int(($gPo(main,w) - $gLogo(w)) / 2) - $xoff]
             set y [expr int(($gPo(main,h) - $gLogo(h)) / 2) - $yoff]
	     set xscroll 1
	     set yscroll 1
	   }
    }
    Xview moveto $xscroll
    Yview moveto $yscroll
    $gPo(mainCanv) coords LogoRect \
	[expr $x * $gPo(zoom)] [expr $y * $gPo(zoom)] \
        [expr ($x + $gLogo(w)) * $gPo(zoom)] \
        [expr ($y + $gLogo(h)) * $gPo(zoom)]
    $gPo(mainCanv) coords LogoText [expr ($x + $gLogo(xtxt)) * $gPo(zoom)] \
				   [expr ($y + $gLogo(ytxt)) * $gPo(zoom)]
    set gLogo(rect) [$gPo(mainCanv) coords LogoRect]
}

proc Apply {} {
    global RED GREEN BLUE UBYTE ON
    global gPo gLogo gImg

    if { $gImg(num) <= 0 } {
	return
    }
    $gPo(mainCanv) config -cursor watch
    update

    if { [string compare $gLogo(color) White] == 0 } {
	set sr 1.0 ; set sg 1.0 ; set sb 1.0
    } elseif { [string compare $gLogo(color) Black] == 0 } {
	set sr 0.0 ; set sg 0.0 ; set sb 0.0
    } elseif { [string compare $gLogo(color) Red] == 0 } {
	set sr 1.0 ; set sg 0.0 ; set sb 0.0
    } elseif { [string compare $gLogo(color) Green] == 0 } {
	set sr 0.0 ; set sg 1.0 ; set sb 0.0
    } elseif { [string compare $gLogo(color) Blue] == 0 } {
	set sr 0.0 ; set sg 0.0 ; set sb 1.0
    }

    set ic $gLogo(rect)
    set ix1 [expr int ([lindex $ic 0] / $gPo(zoom))]
    set iy1 [expr int ([lindex $ic 1] / $gPo(zoom))]
    set ix2 [expr int ([lindex $ic 2] / $gPo(zoom))]
    set iy2 [expr int ([lindex $ic 3] / $gPo(zoom))]

    set cur $gImg(curNo)
    if { $gPo(ext,poImg,avail) } {
	if { ! [info exists gImg(poImg,$cur)] } {
	    set gImg(poImg,$cur) [poImage photo_img $gImg(photo,$cur)]
	}
	set img $gImg(poImg,$cur)
	$img ApplyLogo $gLogo(poImg) $ix1 $iy1 $sr $sg $sb $gPo(license)
	$img img_photo $gImg(photo,$cur)
    } else {
	set phImg $gImg(photo,$cur)
	$phImg copy $gLogo(photo) -to $ix1 $iy1
    }
    ShowImg $cur
    $gPo(mainCanv) config -cursor $gPo(curCursor)
}

proc ApplyAll {} {
    global gImg

    ShowFirst
    for { set i 0 } { $i < $gImg(num) } { incr i } {
	Apply
	ShowNext	
    }
}

proc DelAll {} {
    global gPo gImg

    for { set i [expr $gImg(num) -1] } { $i >= 0 } { incr i -1 } {
        image delete $gImg(photo,$i)
	if { [info exists gImg(thumb,$i)] } {
	    image delete $gImg(thumb,$i)   
	    destroy $gImg(thumbBtn,$i)   
	    unset gImg(thumb,$i)
	    unset gImg(thumbBtn,$i)
	}
	if { $gPo(ext,poImg,avail) && [info exists gImg(poImg,$i)] } {
	    deleteimg $gImg(poImg,$i)   
	    unset gImg(poImg,$i)
	}
	unset gImg(photo,$i)
	unset gImg(name,$i)
    }
    if { [info exists gPo(zoomPhoto)] } {
	image delete $gPo(zoomPhoto)
	unset gPo(zoomPhoto)
    }
    set gImg(num) 0
    set gImg(curNo) 0
    ShowImg -1
    UpdateMainTitle $gImg(num)
}

proc ExitProg {} {
    global gPo gLogo

    if { $gPo(autosaveOnExit) } {
        SaveSettings
    } elseif { $gPo(settChanged) } {
        set retVal [tk_messageBox \
          -title "Save settings" \
          -message "Settings have been changed. Save new values?" \
          -type yesnocancel -default yes -icon question]
        if { [string compare $retVal "yes"] == 0 } {
	    SaveSettings
	} elseif { [string compare $retVal "cancel"] == 0 } {
	    focus .po
	    return
	}
    }
    DelAll

    catch { image delete $gLogo(photo) }
    if { $gPo(ext,poImg,avail) && [info exists gLogo(poImg)] } {
	deleteimg $gLogo(poImg)
    }
    destroy .po

    catch {puts "Number of images left: [llength [image names]]"}
    catch {puts "poImages left: [info commands poImage*]"}

    if { $gPo(ext,poImg,avail) } {
	memcheck
    }
    exit
}

proc StoreLastFmtOpened { imgName } {
    global gPo

    if { $gPo(saveLastImgFmt) } {
	set gPo(lastImgFmt) [::poImgtype::GetFmtByExt [file extension $imgName]]
    }
}

proc GetFileName { mode { initFile "" } } {
    global gPo

    set fileTypes [::poImgtype::GetSelBoxTypes $gPo(lastImgFmt)]
    if { ! [file isdirectory $gPo(lastDir)] } {
        set gPo(lastDir) [pwd]
    }
    if { $mode == "save" } {
        set imgName [tk_getSaveFile -filetypes $fileTypes \
                     -initialfile $initFile -initialdir $gPo(lastDir)]
    } else {
        set imgName [tk_getOpenFile -filetypes $fileTypes \
                     -initialdir $gPo(lastDir)]
    }
    if { $imgName != "" } {
	StoreLastFmtOpened $imgName
        set gPo(lastDir) [file dirname $imgName]
    }
    return $imgName
}

proc AskOpenAniGif {} {
    set imgName [GetFileName "open"]
    if { $imgName != "" } {
	ReadAniGif $imgName 1
    }
}

proc AskSaveAniGif {} {
    set imgName [GetFileName "save"]
    if { $imgName != "" } {
	WriteAniGif $imgName
    }
}

proc ReadAniGif { imgName { saveImgsToFile 0 } } {
    global gPo

    # OPA TODO: ShroudVal und AddRecentFiles
    set gPo(stopJob) 0

    set canvasId $gPo(mainCanv)
    $canvasId config -cursor watch
    update

    ::poWatch::Reset a
    ::poWatch::Start a
    set retVal 0
    set poImg ""
    set ind 0
    set showDialog 1
    while { $retVal == 0 } {
	set retVal [catch {set phImg [image create photo -file $imgName \
				      -format "GIF -index $ind"]} err1]
	if { $retVal == 0 } {
	    # We suceeded in reading an image from the AniGif file.
	    set saveTime [::poWatch::Lookup a]
	    ::poLog::Info "$saveTime sec: Read $imgName into photo image"

	    set prefix [file rootname $imgName]
	    set frameName [format "%s%03d.gif" $prefix [expr $ind +1]]
	    AddImg $phImg $poImg $frameName $canvasId
	    if { $saveImgsToFile } {
		set choice 0
		if { [file exists $frameName] && $showDialog } {
		    set choice [tk_dialog .readAniGif "Confirmation" \
		      "File $frameName exists. Overwrite ?" question 2 \
		      "Yes" "Yes to all" "No" "Cancel"]
		}
		if { $choice <= 1 } {
		    $phImg write $frameName -format "GIF"
		    if { $choice == 1 } {
			set showDialog 0
		    }
		} elseif { $choice == 3 || $choice < 0 } {
		    break
		}
	    }
	    incr ind
	    if { $gPo(stopJob) } {
		WriteInfoStr "GIF's not completely loaded"
	        break
	    }
	}
    }
    $canvasId config -cursor $gPo(curCursor)
}

proc WriteAniGif { imgName } {
    global gImg

    set curDir [pwd]
    cd [file dirname $gImg(name,0)]

    ShowFirst
    set cmdStr "gifsicle"
    for { set i 0 } { $i < $gImg(num) } { incr i } {
	append cmdStr " "
	append cmdStr [file tail $gImg(name,$i)]
	ShowNext
    }
    append cmdStr " -o $imgName"
    ::poLog::Info "Executing: $cmdStr"
    eval exec $cmdStr
    cd $curDir
}

proc ReadImg { imgName { showInCanvas 1 } } {
    global gPo

    set canvasId $gPo(mainCanv)

    set ext [file extension $imgName]
    set fmtStr [::poImgtype::GetFmtByExt $ext]
    if { [string compare $fmtStr ""] == 0 } {
	tk_messageBox -message "Extension \"$ext\" not supported." \
			       -title "Warning" -type ok -icon warning
	focus .po
	return
    }
    set optStr [::poImgtype::GetOptByFmt $fmtStr "read"]

    if { [string compare $fmtStr "GIF"] == 0 } {
	if { [::poImgtype::CheckAniGifIndex $imgName 1] } {
	    # We suceeded in reading an image from the AniGif file.
	    ::poLog::Debug "This seems to be an animated GIF"
	}
    }

    $canvasId config -cursor watch
    update

    set found 1
    ::poWatch::Reset a
    ::poWatch::Start a
    # Try to read an image from file. 
    # 1. If the shroud option is set, try using the appr. shroud program.
    # 2. If this fails (user tries to read an unshrouded file (a) or
    #    has specified the wrong shroud value (b)) try to read it with
    #    standard Tk image procs or by using the Img extension.
    # 3. If we did not succeed until now, try using the poImg extension, if it
    #    exists.
    set retVal 1
    set poImg ""
    set shroudVal [::poImgtype::GetShroudVal]
    if { $shroudVal } {
	# Case (1)
	::poLog::Info "Reading shrouded image"
	set fp [open "|poShroud $shroudVal $imgName" r]
	fconfigure $fp -translation binary
	set dat [read -nonewline $fp]
	close $fp
	set phImg [image create photo]
	set retVal [catch {$phImg put $dat -format "$fmtStr $optStr"}]
    }
    if { $retVal != 0 } {
	# Case (2)
	set retVal [catch {set phImg [image create photo -file $imgName \
	                              -format "$fmtStr $optStr"]} err1]
    }
    if { $retVal != 0 } {
	# Case (3)
        if { $gPo(ext,poImg,avail) } {
	    set retVal [catch {set poImg [poImage readsimple $imgName]} err2]
	    if { $retVal != 0 } {
		::poLog::Warning "Can't read image $imgName with poImg ($err1 $err2)"
		tk_messageBox -message "Can't read image \"$imgName\"" \
			      -type ok -icon warning
		set found 0
	    } else {
		::poLog::Debug "Reading $imgName with poImage"
		set phImg [image create photo]
	 	# Check stored channels in poImage.
		$poImg img_fmt fmtList
		set chanMap [list $::RED $::GREEN $::BLUE]
		set minVal 0
		set maxVal 255
		if { [lindex $fmtList $::RED]   || \
                     [lindex $fmtList $::GREEN] || \
		     [lindex $fmtList $::BLUE] } {
		     if { [lindex $fmtList $::MATTE] } {
			::poLog::Debug "Reading $imgName as RGB image with matte"
			set chanMap [list $::RED $::GREEN $::BLUE $::MATTE]
		    } else {
			::poLog::Debug "Reading $imgName as RGB image"
			set chanMap [list $::RED $::GREEN $::BLUE]
		    }
		} elseif { [lindex $fmtList $::MATTE] && \
		           [lindex $fmtList $::BRIGHTNESS] } {
		    ::poLog::Debug "Reading $imgName as gray-scale image with matte"
		    set chanMap [list $::BRIGHTNESS $::BRIGHTNESS $::BRIGHTNESS $::MATTE]
		} elseif { [lindex $fmtList $::BRIGHTNESS] } {
		    ::poLog::Debug "Reading $imgName as gray-scale image"
		    set chanMap [list $::BRIGHTNESS $::BRIGHTNESS $::BRIGHTNESS]
		} elseif { [lindex $fmtList $::DEPTH] } {
		    ::poLog::Debug "Reading $imgName as depth image"
		    # Note: The following reverse order of minVal and maxVal is
		    # correct, as depth values are stored as reciprocal values.
		    $poImg depth_range maxVal minVal
		    set minVal [expr 1.0 / $minVal]
		    set maxVal [expr 1.0 / $maxVal]
		    set chanMap [list $::DEPTH $::DEPTH $::DEPTH]
		} elseif { [lindex $fmtList $::TEMPERATURE] } {
		    ::poLog::Debug "Reading $imgName as temperature image"
		    $poImg temperature_range minVal maxVal
		    set chanMap [list $::TEMPERATURE $::TEMPERATURE $::TEMPERATURE]
		} elseif { [lindex $fmtList $::RADIANCE] } {
		    ::poLog::Debug "Reading $imgName as radiance image"
		    $poImg radiance_range minVal maxVal
		    set chanMap [list $::RADIANCE $::RADIANCE $::RADIANCE]
		} elseif { [lindex $fmtList $::MATTE] } {
		    ::poLog::Debug "Reading $imgName as gray-scale image"
		    set chanMap [list $::MATTE $::MATTE $::MATTE]
		}
		# OPA TODO Gamma and min/max values must be user selectable
		$poImg img_photo $phImg $chanMap 1.0 $minVal $maxVal
	    }
	} else {
	    ::poLog::Warning "Can't read image $imgName with tkimg ($err1)"
	    tk_messageBox -message "Can't read image \"$imgName\"" \
			  -type ok -icon warning
	    set found 0
	}
    } else {
	::poLog::Debug "Reading $imgName with Img extension"
    }

    set retList {}
    if { $found == 1 } {
	# We suceeded in reading an image from file.
        set saveTime [::poWatch::Lookup a]
        ::poLog::Info "$saveTime sec: Read $imgName into photo image"

	if { $showInCanvas } {
	    AddImg $phImg $poImg $imgName $canvasId
	}
	::poLog::Info "[expr [::poWatch::Lookup a] - $saveTime] sec: Displaying"
	set retList [list $phImg $poImg]

	set curFile [::poMisc::FileSlashName $imgName]
        if { [lsearch -exact $gPo(recentFileList) $curFile] < 0 } {
            set gPo(recentFileList) [linsert $gPo(recentFileList) 0 $curFile]
	    set gPo(recentFileList) [lrange $gPo(recentFileList) 0 \
				      [expr $gPo(recentFileListLen) -1]]
	}
	AddRecentFiles $gPo(reopenMenu) true
    }
    $canvasId config -cursor $gPo(curCursor)
    return $retList
}

proc ReadIcon {} {
    global gPo gLogo

    set logoName $gLogo(file)
    if { ! [file exists $logoName] } {
	::poLog::Warning "Logo image does not exist: Generating default icon"
	GenDefaultLogo
    } else {
	if { $gPo(ext,poImg,avail) && [info exists gLogo(poImg)] } {
	    deleteimg $gLogo(poImg)
	}
	if { [info exists gLogo(photo)] } {
	    image delete $gLogo(photo)
	}
	set imgList [ReadImg $logoName 0]
	if { [llength $imgList] == 0 } {
	    ::poLog::Warning "Unknown image format: Generating default icon"
	    GenDefaultLogo
	} else {
	    set gLogo(photo) [lindex $imgList 0]
	    set gLogo(poImg) [lindex $imgList 1]
	    if { $gPo(ext,poImg,avail) && \
	         [string compare $gLogo(poImg) ""] == 0 } {
		set gLogo(poImg) [poImage photo_img $gLogo(photo)]
	    }
	}
    }
    set gLogo(w) [image width  $gLogo(photo)]
    set gLogo(h) [image height $gLogo(photo)]
}

proc OpenIcon {} {
    global gPo gLogo

    if { [string compare $gLogo(file) ""] == 0 } {
	set pathName [file join [pwd] logo]
    } else {
	set pathName $gLogo(file)
    }
    set logoDir  [file dirname $pathName]
    if { ! [file isdirectory $logoDir] } {
	set logoDir [pwd]
    }
    set logoFile [file tail    $pathName]
    set fileTypes [::poImgtype::GetSelBoxTypes $gPo(lastImgFmt)]
    set imgName  [tk_getOpenFile -filetypes $fileTypes \
                  -title "Choose logo image" \
                  -initialdir $logoDir -initialfile $logoFile]
    if { $imgName != "" } {
    	set gLogo(file) $imgName
	StoreLastFmtOpened $imgName
	ReadIcon
	DisplayLogo
	SetLogoPos
	set gPo(settChanged) true
    }
}

proc Open {} {
    set imgName [GetFileName "open"]
    if { $imgName != "" } {
	ReadImg $imgName
    }
}

proc CreateNewImage {} {
    global UBYTE OFF
    global gPo

    set w $gPo(new,w)
    set h $gPo(new,h)
    set c $gPo(new,c)

    set phImg [image create photo -width $w -height $h]
    set poImg ""

    if { $gPo(ext,poImg,avail) } {
	set rgb [::poMisc::RgbToDec $c]
	set r [expr [lindex $rgb 0] / 255.0]
	set g [expr [lindex $rgb 1] / 255.0]
	set b [expr [lindex $rgb 2] / 255.0]
	pixformat_rgba $UBYTE $UBYTE $UBYTE $OFF
	drawcolor_rgb $r $g $b
	set poImg [poImage allocimage $w $h]
	$poImg draw_rectangle 0 0 $w $h
	$poImg img_photo $phImg
    } else {
	set scanline {}
	for { set x 0 } { $x < $w } { incr x } {
	    lappend scanline $c
	}
	set data {}
	lappend data $scanline
	for { set y 0 } { $y < $h } { incr y } {
	    $phImg put $data -to 0 $y
	}
    }
    AddImg $phImg $poImg "New image" $gPo(mainCanv)
    DestroyNewImageWin
}

proc New {} {
    ShowNewImageWin CreateNewImage "New image"
}

proc BrowseDir {} {
    global gPo

    if { !$gPo(ext,Tktable,avail) || !$gPo(ext,Img,avail) } {
        tk_messageBox -title "Information" -type ok -icon info \
	    -message "Image browsing needs the following extensions:\
	              Tktable and Img.\n\
	              See Help->About Tcl/Tk for download address."
	focus .po
        return
    }

    set tmpDir [::poTree::GetDir -initialdir $gPo(lastDir) -showfiles 1 \
                                 -title "Select image directory"]
    if { [string compare $tmpDir ""] != 0 && \
         [file isdirectory $tmpDir] } {
	set curDir [::poMisc::FileSlashName $tmpDir]
	set gPo(lastDir) $curDir
	::poImgBrowse::OpenDir "$curDir" ::ReadImg
        if { [lsearch -exact $gPo(recentDirList) $curDir] < 0 } {
            set gPo(recentDirList) [linsert $gPo(recentDirList) 0 $curDir]
	    set gPo(recentDirList) [lrange $gPo(recentDirList) 0 \
			            [expr $gPo(recentDirListLen) -1]]
	}
	AddRecentDirs $gPo(rebrowseMenu) true
    }
}

proc SwitchOnDtedCell { btn ew ns } {
    global gDted

    if { $gDted($ew,$ns) == 0 } {
	incr gDted(cellsSelected) 1
    }
    set gDted($ew,$ns) 1
    $btn configure -bg green
}

proc SwitchOffDtedCell { btn ew ns } {
    global gDted

    if { $gDted($ew,$ns) == 1 } {
	incr gDted(cellsSelected) -1
    }
    set gDted($ew,$ns) 0
    $btn configure -bg white
}

proc RangeSelDtedCell { msg ew ns onOff } {
    global gDted

    set ewMin [::poMisc::Min $ew $gDted(ewLastSel)]
    set ewMax [::poMisc::Max $ew $gDted(ewLastSel)]
    set nsMin [::poMisc::Min $ns $gDted(nsLastSel)]
    set nsMax [::poMisc::Max $ns $gDted(nsLastSel)]
    for { set i $ewMin } { $i <= $ewMax } { incr i } {
	for { set j $nsMin } { $j <= $nsMax } { incr j } {
	    if { [info exists gDted($i,$j)] } {
		if { $onOff } {
		    SwitchOnDtedCell  $gDted(btn,$i,$j) $i $j
		} else {
		    SwitchOffDtedCell $gDted(btn,$i,$j) $i $j
		}
	    }
	}
    }
    $msg configure -text "Available cells: $gDted(cellsAvailable) \
                         ($gDted(cellsSelected) selected)"
}

proc ToggleDtedCell { msg btn ew ns } {
    global gDted
    
    if { $gDted($ew,$ns) == 0 } {
	SwitchOnDtedCell $btn $ew $ns
    } else {
	SwitchOffDtedCell $btn $ew $ns
    }
    set gDted(ewLastSel) $ew
    set gDted(nsLastSel) $ns
    $msg configure -text "Available cells: $gDted(cellsAvailable) \
                         ($gDted(cellsSelected) selected)"
}

proc LoadDtedFiles { tw } {
    global gPo gDted

    set gPo(stopJob) 0
    for { set ew $gDted(ewMin) } { $ew <= $gDted(ewMax) } { incr ew } {
	for { set ns $gDted(nsMin) } { $ns <= $gDted(nsMax) } { incr ns } {
	    if { [info exists gDted($ew,$ns)] && $gDted($ew,$ns) == 1 } {
		update
		if { $gPo(stopJob) } {
		    WriteInfoStr "DTED loading stopped by user."
		    break
		}
	   	ReadImg $gDted($ew,$ns,filename)
	    }
	}
	if { $gPo(stopJob) } {
	    break
	}
    }
}

proc ShowDtedSelWin { ewMin ewMax nsMin nsMax } {
    global gPo gDted

    # puts "Drawing cells. EW: $ewMin $ewMax  NS: $nsMin $nsMax"
    set tw .poImgview:dtedSelWin

    catch { destroy $tw }

    toplevel $tw
    wm title $tw "DTED selection window"
    wm resizable $tw true true

    frame $tw.fr1
    frame $tw.fr2
    frame $tw.fr3
    pack $tw.fr1 -expand 1 -fill both
    pack $tw.fr2 -expand 1 -fill x
    pack $tw.fr3 -expand 1 -fill x

    set msg $tw.fr2.l
    set cellBmp [image create bitmap -data [::poBmpData::cell]]
    set col 1
    for { set ew $ewMin } { $ew <= $ewMax } { incr ew } {
	label $tw.fr1.lew_$ew -text [format "%03d" [::poMisc::Abs $ew]]
	grid  $tw.fr1.lew_$ew -row 0 -column $col -sticky nw
	set row 1
	for { set ns $nsMax } { $ns >= $nsMin } { incr ns -1 } {
	    if { $ew == $ewMin } {
		label $tw.fr1.lns_$ns -text [format "%02d" [::poMisc::Abs $ns]]
		grid  $tw.fr1.lns_$ns -row $row -column 0 -sticky nw
	    }
	    set bName [format "%d_%d" $ew $ns]
	    set btn $tw.fr1.b_$bName
	    set gDted(btn,$ew,$ns) $btn
	    if { [info exists gDted($ew,$ns)] } {
		button $btn -image $cellBmp -relief flat -bg white
		bind $btn <ButtonRelease-1> \
                          "ToggleDtedCell $msg $btn $ew $ns"
		bind $btn <Shift-ButtonRelease-1> \
                          "RangeSelDtedCell $msg $ew $ns 1"
		bind $btn <Control-ButtonRelease-1> \
                          "RangeSelDtedCell $msg $ew $ns 0"
	    } else {
		button $btn -image $cellBmp -relief flat -bg red \
                       -state disabled
	    }
	    grid $btn -row $row -column $col -sticky news
	    incr row
	}
	incr col
      }

    # Create message label
    label $msg -text "Available cells: $gDted(cellsAvailable)"
    pack  $msg -expand 1 -fill x

    # Create Cancel and OK buttons
    bind  $tw <KeyPress-Escape> "destroy $tw"
    button $tw.fr3.b1 -text "Cancel" -command "destroy $tw"
    wm protocol $tw WM_DELETE_WINDOW "destroy $tw"

    bind  $tw <KeyPress-Return> "LoadDtedFiles $tw"
    button $tw.fr3.b2 -text "OK" -command "LoadDtedFiles $tw" \
			 -default active
    pack $tw.fr3.b1 $tw.fr3.b2 -side left -fill x -padx 2 -expand 1
    focus $tw
}

proc ScanDtedRoot { dtedRoot } {
    global gPo gDted
 
    # OPA set fileList {}
    catch {unset gDted}
    set gDted(cellsAvailable) 0
    set gDted(cellsSelected)  0
    set gDted(ewMin) 180 ; set gDted(ewMax) -180
    set gDted(nsMin)  90 ; set gDted(nsMax)  -90

    # OPA !!! This has to be changed, if using non-standard DTED directories.
    set dtedCont [::poMisc::GetDirList $dtedRoot 1 0 0 0 * "e??? E??? w??? W???"]
    set dtedDirs [lindex $dtedCont 0]
    set matchStr [format "*.dt%d *.DT%d" $gPo(dted,level) $gPo(dted,level)]
    foreach dir $dtedDirs {
	set dirList [::poMisc::GetDirList $dir 0 1 0 0 * $matchStr]
	set dtedFiles [lindex $dirList 1]
	if { [llength $dtedFiles] > 0 } {
	    # Subdirectories specify East-West directions. Store cell number in
	    # appr. array.
	    set shortDirName [file tail $dir]
	    scan $shortDirName "%1s%3d" ew ewNum
	    if { [string compare -nocase -length 1 "w" $ew] == 0 } {
		set ewNum [expr -1 * $ewNum]
	    }
	    if { $ewNum > $gDted(ewMax) } { set gDted(ewMax) $ewNum }
	    if { $ewNum < $gDted(ewMin) } { set gDted(ewMin) $ewNum }
	    # Scan each file and extract cell numbers as we did for directories.
	    foreach fName $dtedFiles {
		# OPA lappend fileList [file join $dir $fName]
	        scan $fName "%1s%2d" ns nsNum
		if { [string compare -nocase -length 1 "s" $ns] == 0 } {
		    set nsNum [expr -1 * $nsNum]
		}
		set gDted($ewNum,$nsNum) 0
		set gDted($ewNum,$nsNum,filename) [file join $dir $fName]
		incr gDted(cellsAvailable)
		if { $nsNum > $gDted(nsMax) } { set gDted(nsMax) $nsNum }
		if { $nsNum < $gDted(nsMin) } { set gDted(nsMin) $nsNum }
	    }
	}
    }
    ShowDtedSelWin $gDted(ewMin) $gDted(ewMax) $gDted(nsMin) $gDted(nsMax)
}

proc BrowseDted {} {
    global gPo

    if { !$gPo(ext,Img,avail) } {
        tk_messageBox -title "Information" -type ok -icon info \
	    -message "Dted browsing needs the Img extension.\n\
	              See Help->About Tcl/Tk for download address."
	focus .po
        return
    }

    set tmpDir [::poTree::GetDir -initialdir $gPo(lastDtedDir) -showfiles 1 \
                                 -title "Select DTED root directory"]
    if { [string compare $tmpDir ""] != 0 && \
         [file isdirectory $tmpDir] } {
	set gPo(lastDtedDir) $tmpDir
	ScanDtedRoot $tmpDir
    }
}

proc SaveImg { imgName } {
    global gPo gImg

    set ext    [file extension $imgName]
    set fmtStr [::poImgtype::GetFmtByExt $ext]
    if { [string compare $fmtStr ""] == 0 } {
        tk_messageBox -message "Extension $ext not supported." \
                      -title "Warning" -type ok -icon warning
	focus .po
        return
    }

    $gPo(mainCanv) config -cursor watch
    update

    set optStr [::poImgtype::GetOptByFmt $fmtStr "write"]
    $gImg(photo,$gImg(curNo)) write $imgName -format "$fmtStr $optStr"
    $gPo(mainCanv) config -cursor $gPo(curCursor)
}

proc CaptureWin {} {
    global gImg gPo

    set defName "poImgview.png" 
    set imgName [GetFileName "save" $defName]
    if { $imgName != "" } {
	$gPo(mainCanv) config -cursor watch
        ::poWin::Windows2File .po $imgName
	$gPo(mainCanv) config -cursor $gPo(curCursor)
    }
}

proc CaptureCanv {} {
    global gImg gPo

    if { $gImg(num) <= 0 } {
        set defName "capture.png" 
    } else {
        set defName [file tail $gImg(name,$gImg(curNo))]
    }
    set imgName [GetFileName "save" $defName]
    if { $imgName != "" } {
	$gPo(mainCanv) config -cursor watch
        ::poWin::Canvas2File $gPo(mainCanv) $imgName
	$gPo(mainCanv) config -cursor $gPo(curCursor)
    }
}

proc SaveAs {} {
    global gImg

    if { $gImg(num) <= 0 } {
        return
    }
    set imgName [GetFileName "save" [file tail $gImg(name,$gImg(curNo))]]
    if { $imgName != "" } {
	SaveImg $imgName
    }
}

proc Convert { { overwrite 0 } } {
    global gImg

    set imgName [.po.workfr.convfr.outfile cget -text]
    set dirName [file dirname $imgName]
    if { ! [file isdirectory $dirName] } {
	set retVal [tk_messageBox \
	    -message "Directory \"$dirName\" does not exist." \
	    -title "Error" -type ok -icon error]
        return 0
    }
    if { $imgName != "" } {
	set retVal yes
	if { ! $overwrite } {
	    if { [file exists $imgName] } {
		set retVal [tk_messageBox \
		  -message "File \"$imgName\" already exists.\n\
		            Do you want to overwrite it?" \
		  -title "Confirmation" -type yesno -default no -icon info]
	    }
	}
	if { [string compare $retVal "yes"] == 0 } {
	    SaveImg $imgName
	}
	focus .po
    }
    return 1
}

proc ConvertAll {} {
    global gImg

    ShowFirst
    for { set i 0 } { $i < $gImg(num) } { incr i } {
	if { ! [Convert] } {
	    break
	}
	ShowNext	
    }
}

proc SetCurMousePos { x y } {
    global gPo
    set gPo(mouse,x) $x
    set gPo(mouse,y) $y
}

proc MoveViewportRect { x y } {
    global gPo gLogo

    $gPo(mainCanv) move LogoRect \
	           [expr $x - $gPo(mouse,x)] \
	           [expr $y - $gPo(mouse,y)]
    $gPo(mainCanv) move LogoText \
	           [expr $x - $gPo(mouse,x)] \
	           [expr $y - $gPo(mouse,y)]
    set gPo(mouse,x) $x
    set gPo(mouse,y) $y

    set gLogo(rect) [$gPo(mainCanv) coords LogoRect]
    set gLogo(xoff) [expr int ([lindex $gLogo(rect) 0])]
    set gLogo(yoff) [expr int ([lindex $gLogo(rect) 1])]
}

proc View { dir args } {
    global gPo

    if { $dir == "x" } {
	eval {$gPo(mainCanv) xview} $args
    } else {
	eval {$gPo(mainCanv) yview} $args
    }
}

proc Xview { args } {
    eval View x $args
}

proc Yview { args } {
    eval View y $args
}

proc NewMarker { w name type color {x1 0} {y1 0} {x2 0} {y2 0} } {
    switch $type {
	"rectangle" {
	    $w create rectangle $x1 $y1 $x2 $y2 -outline $color \
	                        -tags [list PrintPixel $name]
	}
    }
}

proc DrawMarker { w name x y {zoom 1.0} {size 1} } {
    $w raise $name
    set x1 [expr ($x - $size) * $zoom]
    set y1 [expr ($y - $size) * $zoom]
    set x2 [expr ($x + $size) * $zoom]
    set y2 [expr ($y + $size) * $zoom]
    $w coords $name $x1 $y1 $x2 $y2
}

proc FormatColorVal { r g b } {
    global gPo

    if { $gPo(hexColorValues) } {
        return [format "#%02X%02X%02X" $r $g $b]
    } else {
        return [format "(%d, %d, %d)" $r $g $b]
    }
}

proc PrintPixelValue { canvasId x y } {
    global gPo gImg

    set cx [expr int([$canvasId canvasx $x])]
    set cy [expr int([$canvasId canvasy $y])]
    set px [expr int([$canvasId canvasx $x] / $gPo(zoom))]
    set py [expr int([$canvasId canvasy $y] / $gPo(zoom))]
    DrawMarker $canvasId "ZoomRect" $px $py $gPo(zoom) $gPo(zoomRectSize)

    if { $gImg(num) > 0 } {
	set srcImg $gImg(photo,$gImg(curNo))
	set rgbStr "Position ($px,$py): "
	set retVal [catch {set rgb [$srcImg get $px $py] }]
	if { $retVal == 0 } {
	    append rgbStr [FormatColorVal \
                          [lindex $rgb 0] [lindex $rgb 1] [lindex $rgb 2]]
	}
	set x1 [expr ($px - $gPo(zoomRectSize))]
	set y1 [expr ($py - $gPo(zoomRectSize))]
	set x2 [expr ($px + $gPo(zoomRectSize))]
	set y2 [expr ($py + $gPo(zoomRectSize))]
        if { $gPo(showMedian) } {
            set count    0
            set sumRed   0
            set sumGreen 0
            set sumBlue  0
            for { set x $x1 } { $x < $x2 } { incr x } {
                for { set y $y1 } { $y < $y2 } { incr y } {
                    set retVal [catch {set rgb [$srcImg get $x $y] }]
                    if { $retVal == 0 } {
                        incr count
                        set sumRed   [expr {$sumRed   + [lindex $rgb 0]}]
                        set sumGreen [expr {$sumGreen + [lindex $rgb 1]}]
                        set sumBlue  [expr {$sumBlue  + [lindex $rgb 2]}]
                    }
                }
            }
            if { $count > 0 } {
                set medRed   [expr round (double ($sumRed)   / double ($count))]
                set medGreen [expr round (double ($sumGreen) / double ($count))]
                set medBlue  [expr round (double ($sumBlue)  / double ($count))]
                append rgbStr " Median of $count pixels: "
                append rgbStr [FormatColorVal $medRed $medGreen $medBlue]
            }
        }

	WriteInfoStr $rgbStr
    }
}

proc HelpCont {} {
    tk_messageBox -message "Sorry, no online help available yet." \
			   -type ok -icon info -title "Online Help"
    focus .po
}

proc HelpProg { {splashWin ""} } {
    global gPo

    ::poSoftLogo::ShowLogo \
    	"$gPo(appName) Version 0.3" \
	"Copyright 1999-2008 Paul Obermeier" \
	$splashWin
    if { [string compare $splashWin ""] != 0 } {
        ::poSoftLogo::DestroyLogo
    }
}

proc HelpTcl {} {
    ::poSoftLogo::ShowTclLogo 0 Tk Img Tktable combobox
}

proc StopJob {} {
    global gPo

    set gPo(stopJob) 1
}

# 
# Start of program
#

# The following variables must be set, before reading parameters and
# before calling LoadSettings.
set gPo(optBatch)     0
set gPo(optVerbose)   0
set gPo(optOverwrite) 0
set gPo(optLogo) false
set gPo(optCfgDir) ""		; # Default: Read from user's home directory.
set gPo(appName)   "poImgview"	; # Name of application.

set curArg 0
if { $argc >= 1 } {
    while { $curArg < $argc } {
	set curParam [lindex $argv $curArg]
	if { [string compare -length 1 $curParam "-"] == 0 } {
	    if { [string compare $curParam "-batch"] == 0 } {
		set gPo(optBatch) 1
	    } elseif {[string compare $curParam "-logo"] == 0} {
		set gPo(optLogo) 1
	    } elseif {[string compare $curParam "-overwrite"] == 0} {
		set gPo(optOverwrite) 1
	    } elseif {[string compare $curParam "-verbose"] == 0} {
		set gPo(optVerbose) 1
	    } elseif { [string compare $curParam "-config"] == 0 } {
		incr curArg
		set tmpDir [lindex $argv $curArg]
		if { ![file isdirectory $tmpDir] } {
		    tk_messageBox -title "Error" -icon error \
		    -message "Configuration directory \"$tmpDir\" not existent."
		    exit 1
		}
		set gPo(optCfgDir) $tmpDir
	    } elseif { [string first "-psn" $curParam] == 0 } {
                # Ignore this option. This parameter is supplied automatically
                # by OS X, when using this program as a starpack in a Mac APP.
	    } else {
		tk_messageBox -title "Error" -icon error \
		              -message "Unknown command line option: $curParam."
		exit 1
	    }
	} else {
	    break
	}
	incr curArg
    }
}

# Try to load settings file.
LoadSettings

set gPo(zoom)          1.00
set gPo(stopJob) 0

# Determine machine dependent fixed font.
set gPo(fixedFont) [::poWin::GetFixedFont]

::poToolhelp::Init .po:toolhelp "#FFFFB5" black

# Open main window.
if { $gPo(showSplash) } {
    HelpProg ".po"
}

ShowMainWin $gPo(appName)
SetLogoBindings .po 0

# If arguments are given, try to load the corresponding image files.
if { $curArg < $argc } {
    set fileOrDirName [lindex $argv $curArg]
    if { [file isdirectory $fileOrDirName] } {
	set curDir [::poMisc::FileSlashName $fileOrDirName]
	::poImgBrowse::OpenDir $curDir ::ReadImg
        if { [lsearch -exact $gPo(recentDirList) $curDir] < 0 } {
            set gPo(recentDirList) [linsert $gPo(recentDirList) 0 $curDir]
	    set gPo(recentDirList) [lrange $gPo(recentDirList) 0 \
			            [expr $gPo(recentDirListLen) -1]]
	}
	AddRecentDirs $gPo(rebrowseMenu) true
    } else {
	$gPo(mainCanv) config -cursor watch
	set startInd $curArg
	set noImgs 0
	for { set curArg $startInd } { $curArg < $argc } { incr curArg } {
	    set fileName [::poMisc::FileSlashName [lindex $argv $curArg]]
	    ReadImg $fileName
	    if { $gPo(optBatch) } {
		if { $gPo(optLogo) } {
		    Apply
		}
		if { ! [Convert $gPo(optOverwrite)] } {
		    break
		}
		DelImg
	    }
	    incr noImgs
	    update
	    if { $gPo(stopJob) } {
		WriteInfoStr "Image loading stopped by user."
	        break
	    }
	}
	$gPo(mainCanv) config -cursor $gPo(curCursor)
	set imgStr [format "image%s" [::poMisc::Plural $noImgs]]
	if { $gPo(optBatch) } {
	    if { $gPo(optVerbose) } {
		tk_messageBox -message "$noImgs $imgStr processed." \
			      -type ok -icon info -title "Information"
	    }
	    ExitProg
	} else {
	    if { $gPo(optVerbose) } {
		WriteInfoStr "$noImgs $imgStr loaded."
	    }
	}
    }
}

UpdateMainTitle $gImg(num)
WriteInfoStr $gPo(initStr)

# The next statement is needed, because the combobox triggers the command
set gPo(settChanged) false

tk appname $gPo(appName)

# Now we are in the Tk event loop.

