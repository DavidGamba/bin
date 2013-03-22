#!/usr/bin/perl -w
use strict;
use diagnostics;
use Pod::Usage;
use Env qw( HOME );
use Getopt::Long
    qw( :config bundling no_ignore_case );
use Data::Dumper;
use File::Copy qw(move);

my ($opt_help, $opt_man, $next, $search, $debug);
GetOptions(
        'h|help|?' => \$opt_help,
        'man'      => \$opt_man,
        'next'     => \$next,
        'search|s' => \$search,
        'debug'    => \$debug,
);

pod2usage(-verbose => 0) if ($opt_help);
pod2usage(-verbose => 2) if ($opt_man);

# Music Library location
my $Music_lib  = "$HOME/Music";
my $tmp_dir    = "$HOME/tmp";
my $search_php = "http://goear.com/search.php?q=";
my $base_url   = "http://www.goear.com/";
my $xml_url    = "http://www.goear.com/tracker758.php?f=";
main();
exit 0;

sub main
{
    my $file = "$tmp_dir/goear_html";
    my $xml = "$tmp_dir/goear_xml";
    my $title = get_title(@ARGV);
    if($search)
    {
        get_page("$search_php$title", $file);
    }
    my $songs = get_songs($file);
    my $opt = get_opt($songs);
    if($opt eq "next")
    {
        get_page("$base_url$$songs{next}", $file);
    }
    else
    {
        get_page("$xml_url$$songs{$opt}{id}", $xml);
        my $song = extract_song($xml);
        get_page("$$song{url}",
            "$tmp_dir/$$song{title}-$$song{artist}.mp3");
        move_song("$$song{title}-$$song{artist}.mp3", $$song{artist});
    }
}

sub move_song
{
    my $song = shift;
    my $artist = shift;
    mkdir "$Music_lib/$artist" unless -d "$Music_lib/$artist";
    my $ret = move("$tmp_dir/$song", "$Music_lib/$artist/$song")
        unless -e "$Music_lib/$artist/$song";
    print "moved song to: $Music_lib/$artist/$song\n" unless !$ret;
}

sub extract_song
{
    my $file = shift;
    open IN, $file or die "Can't read $file $!\n";
    my %song;
    while(<IN>)
    {
        next unless /\.mp3/;
        s{path="([^"]*)}{};
        $song{url} = $1;
        s{artist="([^"]*)}{};
        $song{artist} = $1;
        s{title="([^"]*)}{};
        $song{title} = $1;
    }
    close IN;
    print "SONG: $song{title}-$song{artist}.mp3\n";
    print "Do you want to change the name of the song? (y/n)\n";
    my $input = <STDIN>;
    if($input =~ /y/i)
    {
        print "song name\n";
        $input = <STDIN>;
        chomp $input;
        $song{title} = $input;
        print "artist name\n";
        $input = <STDIN>;
        chomp $input;
        $song{artist} = $input;
        print "SONG: $song{title}-$song{artist}.mp3\n";
    }
    return \%song;
}

sub get_opt
{
    my $songs = shift;
    foreach my $number (sort keys %$songs)
    {
        print "$number: $$songs{$number}{name}\n" unless $number eq "next";
    }
    print "next\n" if $$songs{next};
    print "Tell me what. next or number\n";
    my $opt = <STDIN>;
    chomp $opt;
    return $opt;
}

sub get_title
{
    my $title;
    if($#_ > 0)
    {
        $title = "@_";
    }
    else
    {
        print "Introduce el título de la canción o del artista:\n";
        $title = <STDIN>;
        chomp $title;
    }
    return $title;
}

sub get_songs
{
    print "getting songs\n";
#Buscamos la linea que tiene los enlaces para escuchar
    my $file = shift;
    open IN, $file or die "Can't read $file $!\n";
    my %songs;
    while(<IN>)
    {
        next unless m{href="listen} or m{class="next"};
        if(m{href="listen})
        {
            my $count = 0;
            while (/href="listen/)
            {
                $count++;
                s{href="listen/([^/]*)/[^"]*}{};
                $songs{$count}{id} = $1;
                s{<a title="Escuchar([^"]*)}{};
                $songs{$count}{name} = $1;
#               print "$count: $songs{$count}{id} - $songs{$count}{name}\n";
            }
        }
        elsif(m{class="next"} and m{href="([^"]*)})
        {
            $songs{next} = $1;
            print "Next = $1\n";
        }
    }
    close IN;
    return \%songs;
}

sub get_page
{
    my $url = shift;
    my $tmp_file = shift;
    my $ret = system('wget', '-O', $tmp_file, $url);
    die "failed getting $url\n" if $ret;
}

__END__

=pod

=head1 goear.pl

downloads a song

=head1 todo

Bulk download

=cut
