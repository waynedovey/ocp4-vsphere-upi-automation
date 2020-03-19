#! /usr/bin/perl

package test;
use strict;

open(READ, "<$ARGV[0]") || die "couldn't open $ARGV[0]" && usage();
open(WRITEM, ">/tmp/mapping-flat.txt") || die "couldn't open output";
open(WRITES, ">/tmp/mapping-skopeo.txt") || die "couldn't open output";
open(WRITEI, ">/tmp/imageContentSourcePolicy-flat.yaml") || die "couldn't open output";

print WRITEI "apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  name: redhat-operators
spec:
  repositoryDigestMirrors:
";

foreach my $line (<READ>) {
    my ($source, $dest) = split('=', $line);
    my ($dbase, $dnest, $dimage) = $dest =~ m/^(.*)\/(.*)\/(.*)$/;
    my ($sbase, $snest, $simage) = $source =~ m/^(.*)\/(.*)\/(.*)$/;
    #print "$dbase : $dnest : $dimage\n";
    my ($dimagenov) = $dimage =~ m/^([\w-]*).*$/;
    my ($sourcenov, $version) = $simage =~ m/^([\w-]*)(.*)$/;
    if ($version =~ /sha256/) {
        ($version) = $version =~ m/\@sha256:(\w{8}).*/;
    } elsif ($version =~ /:/) {
        ($version) = $version =~ m/:([\w-\.]*).*/;
    } else {
        $version = "latest";
    }
    print WRITEM "$source=$dbase/$dimagenov:$version\n";
    print WRITES "docker://$source docker://$dbase/$dimagenov:$version\n";
    print WRITEI "  - mirrors:
    - $dbase/$dimagenov
    source: $sbase/$snest/$sourcenov\n";
}
close READ;
close WRITEM;
close WRITES;
close WRITEI;

print STDERR <<'EOF';

Wrote:

    /tmp/mapping-flat.txt
    /tmp/mapping-skopeo.txt    
    /tmp/imageContentSourcePolicy-flat.yaml

Now Run:

    while read line; do oc image mirror $line; done < /tmp/mapping-flat.txt
    
    OR if using skopeo

    while read line; do echo $line && skopeo copy --all $line; done < /tmp/mapping-skopeo.txt

    THEN 

    oc apply -f /tmp/imageContentSourcePolicy-flat.yaml

EOF

sub usage {
    print STDERR <<EOF;
usage:  perl $0 mapping.txt

    Flattens mapping.txt file so can be imported into Registry that does not support Nesting repositories. Outputs to:

    /tmp/mapping-flat.txt
    /tmp/mapping-skopeo.txt
    /tmp/imageContentSourcePolicy-flat.yaml

EOF
    exit 1;
}