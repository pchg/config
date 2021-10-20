#!/usr/bin/perl

# diff2html.pl - the Perl script version of html2diff.
#
# Copyright (C) 2007 Ryohei Morita
#
# The original 'html2diff' was written in Python,
# by Yves Bailly and MandrakeSoft S.A.
#
# Copyright (C) 2001 Yves Bailly <diff2html@tuxfamily.org>
#           (C) 2001 MandrakeSoft S.A.
#
# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA, or look at the website 
# http://www.gnu.org/copyleft/gpl.html

use strict;
use warnings;

my $default_css = <<END_OF_CSS;
TABLE { border-collapse: collapse; border-spacing: 0px; }
TD.linenum { color: #909090; 
             text-align: right;
             vertical-align: top;
             font-weight: bold;
             border-right: 1px solid black;
             border-left: 1px solid black; }
TD.added { background-color: #DDDDFF; }
TD.modified { background-color: #BBFFBB; }
TD.removed { background-color: #FFCCCC; }
TD.normal { background-color: #FFFFE1; }
END_OF_CSS

sub print_usage {
    print <<END_OF_USAGE;
diff2html.pl - Formats diff(1) output to an HTML page on stdout
http://diff2html.tuxfamily.org

Usage: diff2html.pl [--help|-?] [--only-changes] [--style-sheet file.css]
                    [diff options] file1 file2

--help                  This message
--only-changes          Do not display lines that have not changed
--style-sheet file.css  Use an alternate style sheet, linked to the given file
diff options            All other options are passed to diff(1)

Example:
# Basic use
diff2html.pl file1.txt file2.txt > differences.html
# Treat all files as text and compare  them  line-by-line, even if they do 
# not seem to be text.
diff2html.pl -a file1 file2 > differences.html
# The same, but use the alternate style sheet contained in diff_style.css
diff2html.pl --style-sheet diff_style.css -a file1 file2 > differences.html

The default, hard-coded style sheet is the following:
$default_css
Note 1: if you give invalid additionnal options to diff(1), diff2html.pl will
        silently ignore this, but the resulting HTML page will be incorrect;
Note 2: for now, diff2html.pl can not be used with standard input, so the
        diff(1) '-' option can not be used.
        
diff2html.pl is released under the GNU GPL.
Feel free to submit bugs or ideas to <diff2html\@tuxfamily.org>.
END_OF_USAGE
}

sub str2html {
    my $s = shift;
    return '' unless(defined $s);
    $s =~ s/[\r\n]*$//g;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/ /&nbsp;/g;
    return $s;
}

# main

    # Processes command-line options
    my $cmd_line = join ' ', $0, @ARGV;
    
    # First, look for "--help"
    if ( @ARGV < 2 ) {
        &print_usage();
        exit(1);
    }
    for my $opt (@ARGV) {
        if ( $opt eq '--help' or $opt eq '-?' ) {
            &print_usage();
            exit(0);
        }
    }

    my $external_css = '';
    my $ind_css = -1;
    my $ind_chg = -1;
    my $only_changes = 0;
    my $css_inline = 0;
    for my $ind_opt (0..$#ARGV) {
        if ( $ARGV[$ind_opt] eq '--style-sheet' ) {
            $ind_css = $ind_opt;
            $external_css = $ARGV[$ind_css+1];
        }
        if ( $ARGV[$ind_opt] eq '--style-sheet-inline' ) {
            $ind_css = $ind_opt;
            $external_css = $ARGV[$ind_css+1];
            $css_inline = 1;
        }
        if ( $ARGV[$ind_opt] eq '--only-changes' ) {
            $ind_chg = $ind_opt;
            $only_changes = 1;
        }
    }

    # Remove diff2html.pl options diff command does not want
    my @diff_opts = map {$ARGV[$_]} grep { $ind_css >= 0 ? $_ != $ind_css && $_ != $ind_css+1 : 1 }
                                    grep { $ind_chg >= 0 ? $_ != $ind_chg : 1 } (0..$#ARGV);

    # Check if both files exists
    my $file1 = $diff_opts[-2];
    my $file2 = $diff_opts[-1];
    unless (-f $file1 && -r $file1) {
        printf 'File %s does not exist or is not readable, aborting.', $file1;
        exit(1);
    }
    unless (-f $file2 && -r $file1) {
        printf 'File %s does not exist or is not readable, aborting.', $file2;
        exit(1);
    }

    # Invokes "diff"
    local *DIFF_STDOUT;
    open(DIFF_STDOUT, '-|', 'diff '.join(' ',@diff_opts));
    my @diff_output = <DIFF_STDOUT>;
    close(DIFF_STDOUT);

    # Maps to store the reported differences
    my %changed = ();
    my %deleted = ();
    my %added = ();
    # Magic regular expression
    my $diff_re = qr/^(\d+)(?:,(\d+))?([acd])(\d+)(?:,(\d+))?/msx;
    # Now parse the output from "diff"
    for my $diff_line (@diff_output) {
        # If the line doesn't match, it's useless for us
        if ($diff_line =~ /$diff_re/) {
            my ($f1_start, $f1_end, $diff, $f2_start, $f2_end);
            # Retrieving informations about the differences : 
            # starting and ending lines (may be the same)
            $f1_start = int($1);
            if ( defined($2) ) {
                $f1_end = int($2);
            } else {
                $f1_end = $f1_start;
            }
            $f2_start = int($4);
            if ( defined($5) ) {
                $f2_end = int($5);
            } else {
                $f2_end = $f2_start;
            }
            my $f1_nb = ($f1_end - $f1_start) + 1;
            my $f2_nb = ($f2_end - $f2_start) + 1;
            $diff = $3;
            # Is it a changed (modified) line ?
            if ( $diff eq 'c' ) {
                # We have to handle the way "diff" reports lines merged
                # or splitted
                if ( $f2_nb < $f1_nb ) {
                    # Lines merged : missing lines are marqued "deleted"
                    for my $lf1 ($f1_start .. $f1_start+$f2_nb-1) {
                        $changed{$lf1} = 1;
                    }
                    for my $lf1 ($f1_start+$f2_nb .. $f1_end) {
                        $deleted{$lf1} = 1;
                    }
                } elsif ( $f1_nb < $f2_nb ) {
                    # Lines splitted : extra lines are marqued "added"
                    for my $lf1 ($f1_start .. $f1_end) {
                        $changed{$lf1} = 1;
                    }
                    for my $lf2 ($f2_start+$f1_nb .. $f2_end) {
                        $added{$lf2} = 1;
                    }
                } else {
                    # Lines simply modified !
                    for my $lf1 ($f1_start .. $f1_end) {
                        $changed{$lf1} = 1;
                    }
                }
            # Is it an added line ?
            } elsif ( $diff eq 'a' ) {
                for my $lf2 ($f2_start .. $f2_end) {
                    $added{$lf2} = 1;
                }
            } else {
            # OK, so it's a deleted line
                for my $lf1 ($f1_start .. $f1_end) {
                    $deleted{$lf1} = 1;
                }
            }
        }
    }

    # Storing the two compared files, to produce the HTML output
    local *FHIN;
    open(FHIN, '<', $file1);
    my @f1_lines = <FHIN>;
    close(FHIN);
    open(FHIN, '<', $file2);
    my @f2_lines = <FHIN>;
    close(FHIN);
    
    # Finding some infos about the files
    my @f1_stat = stat($file1);
    my @f2_stat = stat($file2);

    # Printing the HTML header, and various known informations
    
    # Preparing the links to changes
    my $changed_lnks;
    if ( keys(%changed) == 0 ) {
        $changed_lnks = 'None';
    } else {
        $changed_lnks = '';
        for my $key ( sort {$a<=>$b} keys %changed ) {
            $changed_lnks .= "<a href=\"#F1_$key\">$key</a>, ";
        }
        chop $changed_lnks;
        chop $changed_lnks;
    }
    my $added_lnks;
    if ( keys(%added) == 0 ) {
        $added_lnks = 'None';
    } else {
        $added_lnks = '';
        for my $key ( sort {$a<=>$b} keys %added ) {
            $added_lnks .= "<a href=\"#F2_$key\">$key</a>, ";
        }
        chop $added_lnks;
        chop $added_lnks;
    }
    my $deleted_lnks;
    if ( keys(%deleted) == 0 ) {
        $deleted_lnks = 'None';
    } else {
        $deleted_lnks = '';
        for my $key ( sort {$a<=>$b} keys %deleted ) {
            $deleted_lnks .= "<a href=\"#F1_$key\">$key</a>, ";
        }
        chop $deleted_lnks;
        chop $deleted_lnks;
    }

    print <<END_OF_HEADER_PART1;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"
 "http://www.w3.org/TR/REC-html40/loose.dtd">
<html>
<head>
    <title>Differences between $file1 and $file2</title>
END_OF_HEADER_PART1

    if ( $external_css eq '' ) {
        print "    <style type=\"text/css\"><!--\n$default_css\n--></style>\n";
    } else {
        if ($css_inline) {
            print "    <style type=\"text/css\"><!--\n";
            print @{&slurp_lines($external_css)};
            print "\n--></style>\n";
        } else {
            print "    <link rel=\"stylesheet\" href=\"$external_css\" type=\"text/css\">\n"
        }
    }

    printf <<'END_OF_HEADER_PART2', $changed_lnks, $added_lnks, $deleted_lnks, $file1, $file2, scalar(@f1_lines), $f1_stat[7], scalar(localtime($f1_stat[9])), scalar(@f2_lines), $f2_stat[7], scalar(localtime($f2_stat[9]));
</head>
<body>
<table>
<tr><td width="50%%">
<table>
    <tr>
        <td class="modified">Modified lines:&nbsp;</td>
        <td class="modified">%s</td>
    </tr>
    <tr>
        <td class="added">Added line:&nbsp;</td>
        <td class="added">%s</td>
    </tr>
    <tr>
        <td class="removed">Removed line:&nbsp;</td>
        <td class="removed">%s</td>
    </tr>
</table>
</td>
<td width="50%%">
<i>Generated by <a href="http://diff2html.tuxfamily.org"><b>diff2html.pl</b></a><br/>
&copy; Yves Bailly, MandrakeSoft S.A. 2001, Ryohei Morita 2007<br/>
<b>diff2html.pl</b> is licensed under the <a 
href="http://www.gnu.org/copyleft/gpl.html">GNU GPL</a>.</i>
</td></tr>
</table>
<hr/>
<table>
    <tr>
        <th>&nbsp;</th>
        <th width="45%%"><strong><big>%s</big></strong></th>
        <th>&nbsp;</th>
        <th>&nbsp;</th>
        <th width="45%%"><strong><big>%s</big></strong></th>
    </tr>
    <tr>
        <td width="16">&nbsp;</td>
        <td>
        %d lines<br/>
        %d bytes<br/>
        Last modified : %s<br/>
        <hr/>
        </td>
        <td width="16">&nbsp;</td>
        <td width="16">&nbsp;</td>
        <td>
        %d lines<br/>
        %d bytes<br/>
        Last modified : %s<br/>
        <hr/>
        </td>
    </tr>
END_OF_HEADER_PART2
    
    # Running through the differences...
    my $nl1 = 0;
    my $nl2 = 0;
    while (not ( ($nl1 >= @f1_lines) and ($nl2 >= @f2_lines) ) ) {
        if ( $added{$nl2+1} ) {
      # This is an added line
            printf <<'END_OF_HTML_CHUNK', $nl2+1, $nl2+1, &str2html($f2_lines[$nl2]);
    <tr>
        <td class="linenum">&nbsp;</td>
        <td class="added">&nbsp;</td>
        <td width="16">&nbsp;</td>
        <td class="linenum"><a name="F2_%d">%d</a></td>
        <td class="added">%s</td>
    </tr>
END_OF_HTML_CHUNK
            $nl2 += 1;
        } elsif ( $deleted{$nl1+1} ) {
      # This is a deleted line
            printf <<'END_OF_HTML_CHUNK', $nl1+1, $nl1+1, &str2html($f1_lines[$nl1]);
    <tr>
        <td class="linenum"><a name="F1_%d">%d</a></td>
        <td class="removed">%s</td>
        <td width="16">&nbsp;</td>
        <td class="linenum">&nbsp;</td>
        <td class="removed">&nbsp;</td>
    </tr>
END_OF_HTML_CHUNK
            $nl1 += 1;
        } elsif ( $changed{$nl1+1} ) {
      # This is a changed (modified) line
            printf <<'END_OF_HTML_CHUNK', $nl1+1, $nl1+1, &str2html($f1_lines[$nl1]), $nl2+1, &str2html($f2_lines[$nl2]);
    <tr>
        <td class="linenum"><a name="F1_%d">%d</a></td>
        <td class="modified">%s</td>
        <td width="16">&nbsp;</td>
        <td class="linenum">%d</td>
        <td class="modified">%s</td>
    </tr>
END_OF_HTML_CHUNK
            $nl1 += 1;
            $nl2 += 1;
        } else {
      # These lines have nothing special
            if ( not $only_changes ) {
                printf <<'END_OF_HTML_CHUNK', $nl1+1, &str2html($f1_lines[$nl1]), $nl2+1, &str2html($f2_lines[$nl2]);
    <tr>
        <td class="linenum">%d</td>
        <td class="normal">%s</td>
        <td width="16">&nbsp;</td>
        <td class="linenum">%d</td>
        <td class="normal">%s</td>
    </tr>
END_OF_HTML_CHUNK
            }
            $nl1 += 1;
            $nl2 += 1;
        }
    }
    # And finally, the end of the HTML
    printf <<'END_OF_FOOTER', scalar(localtime(time())), $cmd_line;
</table>
<hr/>
<i>Generated by <b>diff2html.pl</b> on %s<br/>
Command-line:</i> <tt>%s</tt>

</body>
</html>
END_OF_FOOTER
