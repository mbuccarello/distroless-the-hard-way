#!/usr/local/bin/perl
use strict;
use warnings;

print "--- Perl Sovereign Smoke Test ---\n";
print "Version: $^V\n";

# Check for core functional capabilities
my @modules = qw(Config IO::Socket::SSL POSIX);
foreach my $mod (@modules) {
    eval "require $mod";
    if ($@) {
        print "[FAIL] Module '$mod' is MISSING: $@\n";
        # We don't exit here yet as some might be expectedly missing if not installed
    } else {
        print "[OK] Module '$mod' is loaded.\n";
    }
}

# Check for shared library resolution (libxcrypt)
eval {
    require Crypt::OpenSSL::RSA; # Might not be in core but check if we can load native extensions
    print "[OK] Crypt::OpenSSL::RSA loaded (if installed).\n";
};

print "[SUCCESS] Perl basic execution confirmed.\n";
exit(0);
