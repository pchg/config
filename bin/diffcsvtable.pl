=pod

A CSV Table Diff Utility

copyright 2004, Jeff Zucker, all rights reserved

May be freely modified and distributed under the same terms as Perl itself.

Input
* the names & primary keys of any two CSV tables that have
  the same column structure

Output
* a CSV table containing a unique set of rows from both
  tables with an additional column "diff_status" marking each
  row as "same" | "deleted" | "added" | "modified"

Notes
* 30 lines of code
* never holds more than the key fields + 2 rows at a time in memory
* doesn't do *any* field by field comparisons except on the FK field

=cut

#!perl -w
use strict;
use DBI;
my %v = (t1=>'t1.csv',t2=>'t2.csv',t3=>'diff.csv',key=>'id');
my $dbh=DBI->connect("dbi:CSV(RaiseError=>1):csv_eol=\012");
$dbh->{csv_tables}->{'t'.$_}->{file} = $v{'t'.$_} for (1,2,3);
my $tmp  = $dbh->prepare("SELECT * FROM t1 WHERE 1=0");
$tmp->execute;
my @cols = @{$tmp->{NAME}};
for (1,2) {
    $v{'ids'.$_} = $dbh->selectcol_arrayref("SELECT $v{key} FROM t$_");
    %{$v{'is_id'.$_}} = map { $_=>1 } @{$v{'ids'.$_}};
    $v{'query'.$_} = $dbh->prepare(
        "SELECT ".join(',',@cols)." FROM t$_ WHERE $v{key} = ?");
}
@cols = ( @cols, 'diff_status' );
my $insert = $dbh->prepare(
    "INSERT INTO t3 VALUES(". join(',',split'','?'x@cols) .")"
);
my($colstr,%seen) = ( join(' TEXT,',@cols).' TEXT', () );
$dbh->do( "DROP TABLE IF EXISTS t3" );
$dbh->do( "CREATE TABLE t3 ($colstr)" );
my %is_del   = map{$_=>1}grep(!defined $v{is_id2}->{$_},@{$v{ids1}});
my %is_add   = map{$_=>1}grep(!defined $v{is_id1}->{$_},@{$v{ids2}});
for my $id( grep(!$seen{$_}++,@{$v{ids1}}, @{$v{ids2}}) ) {
    $v{'query'.$_}->execute($id) for (1,2);
    $is_del{$id} &&  $insert->execute(
        $v{query1}->fetchrow_array,'deleted') && next;
    $is_add{$id} &&  $insert->execute(
        $v{query2}->fetchrow_array,'added') && next;
    my @r1 = map {defined $_ ? $_ : '' } $v{query1}->fetchrow_array;
    my @r2 = map {defined $_ ? $_ : '' } $v{query2}->fetchrow_array;
    my $type = ("@r1" eq "@r2") ? "same" : "modified";
    $insert->execute( @r2, $type );
}
__END__
