# ntp_timestamp_sanifier
NTP logs are terrible.  This is a typical entry from a peerstats log:

57844 27156.724 127.0.0.1 9014 0.005995526 0.032311653 3.937740536 0.002301804

This script focuses on the first two fields: "day [since epoch]" and "second [since start of day]"
http://www.ntp.org/ntpfaq/NTP-s-trouble.htm#Q-TRB-MON-STATFIL

It will attempt to parse the timestamp and replace it with something a bit more human-readable, creating a "inputfile.converted" file for each inputfile

Usage:
```
# one file
./ntp_timestamp_sanifier.rb peers

# multiple files?!
./ntp_timestamp_sanifier.rb peers peers-20170401 peers-20170402
```