#!/usr/bin/perl -I../lib 

use CGI::Carp 'fatalsToBrowser';
use CGI;   # standard package for easy CGI scripting
use DBI;   # standard package for Database access
use def; # home-made package for defines
use tools; # home-made package for tools
# use migcrender;
# use Data::Dumper;

$cgi = new CGI;
$sw = get_quoted('sw') || "";
my $extlink = get_quoted('extlink');
$config{current_language} = get_quoted('lg') || 1;


my $lg=get_quoted('lg') || "1";
my $self = "cgi-bin/data_stats.pl?";

my @fcts = qw(
    make_stats
    );
    
if (is_in(@fcts,$sw)) 
{ 
    &$sw();
}


  
sub make_stats
{
    my %result=();
    my $sf=15;
    my $table = "data_search_cache";
    
    $stmt = "UPDATE $table SET sem = 1 WHERE DAY(date)>= 1 AND DAY(date) <=7";
    execstmt($dbh,$stmt);
    $stmt = "UPDATE $table SET sem = 2 WHERE DAY(date)>= 8 AND DAY(date) <=14";
    execstmt($dbh,$stmt);
    $stmt = "UPDATE $table SET sem = 3 WHERE DAY(date)>= 15 AND DAY(date) <=21";
    execstmt($dbh,$stmt);
    $stmt = "UPDATE $table SET sem = 4 WHERE DAY(date)>= 22 AND DAY(date) <=28";
    execstmt($dbh,$stmt);
    $stmt = "UPDATE $table SET sem = 5 WHERE DAY(date)> 28";
    execstmt($dbh,$stmt);
    
    my @source = get_table($dbh,$table,"","sf='$sf' order by date asc",'','','',0);
    foreach $source_rec (@source)  
    {
        my %source = %{$source_rec};
        my ($year,$month,$day) = split (/-/,$source{date});
        foreach $ordby (1 .. 10)
        {
            my $key1 = 's'.$ordby;
            my $value = $source{$key1};
            my $count = int($result{$year}{$month}{$source{sem}}{$key1}{$value});
            $count++;
            $result{$year}{$month}{$source{sem}}{$key1}{$value} = $count;
        }
    }
    
    see();
    foreach $year (sort keys %result)
    {
       foreach $month (sort keys %{$result{$year}})
       {
          foreach $sem (sort keys %{$result{$year}{$month}})
          {
             foreach $key1 (sort keys %{$result{$year}{$month}{$sem}})
             {
                 foreach $value (sort keys %{$result{$year}{$month}{$sem}{$key1}})
                 {
#                       print "<br /> $year : $month : $sem : $key1 : $value : $result{$year}{$month}{$sem}{$key1}{$value}";
                      $value =~ s/\'//g;
                      
                      my %new_stat = (
                          annee=>$year,
                          mois=>$month,
                          num_sem=>$sem,
                          sf=>$sf,
                          s_ordby=>$key1,
                          value=>$value,
                          count=>$result{$year}{$month}{$sem}{$key1}{$value}
                      );
                      inserth_db($dbh,"data_stats",\%new_stat);
#                       $stmt = "delete FROM $table WHERE date = '$id' ";
#                       execstmt($dbh,$stmt);
                 }
             }
          }      
       }     
    }
    
    see(\%result);
}