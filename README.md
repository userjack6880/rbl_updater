# RBL Updater Suite

This is the RBL Updater Suite version 0 alpha-1 (0-α1) by John Bradley (john@systemanomaly.com). The RBL Updater Suite is an Open Source suite of tools to be used in conjunction with rpsamd to help autogenerate a local realtime block list (RBL) not reliant on any external lists, such as spamhaus and the like.

This software is extremely experimental and may cause collateral damage on deliverability. USE AT YOUR OWN RISK.

# Principle of Operation

The script assumes that you have configured postfix in a way that it blocks misconfigured hosts attempting to connect to your mail server, already is blocking messages, and has rspamd installed and running.

Whenever an IP address gets blocked in the mail logs, the monitor script will flag the IP and increase the time it is banned. The ban gets more agressive the more the IP is flagged, ultimately ended up in prefix and asn bans as the issue worsens.

- On first infraction, the IP is given a 1 hour ban.
- On second infraction, the IP is given a 6 hour ban.
- On third infraction, the IP is given a 12 hour ban.
- After the third infraction, the IP is permanently banned, and the network prefix is flagged.

Bans are cumulative, and infractions are permanently recorded.

For network prefixes, infractions and bans are given based on the number of individual IP bans within the prefix.

- Up to 2 IP permabans do not result on a prefix ban.
- On the third IP permaban, the prefix receives a 1 day ban.
- Every additional IP permaban after the third results in a 1 week ban.
- On the twenty-fifth (25th) IP permaban, the prefix is permanently banned.

Bans are cumulative, and infractions are permanently recorded.

Usually at this point, no further actions are needed, but a particularly bad ISP will end up with a ton of bad prefixes. At this point, the ASN gets penalized.

- Up to 50% of prefixes can be permanently banned before ASN penalties are applied.
- First penalty is a 1 week ASN ban.
- Second penalty is a 1 month ASN ban.
- Third penalty is a permanent ASN ban.

Bans are cumulative, and infractions are permanently recorded.

This is agressive, and possibly hostile, but for the most part, it should never get as far as an ASN ban.

# Dependencies

## Required
- Perl 5 (Tested 5.32.1)
- mySQL 15.1 or Equivalent (Tested MariaDB 10.5.12)

Perl Packages Used
- DBI
- File::Tail
- File::Basename
- Getopt::Std
- JSON
- LWP::UserAgent
- LWP::Protocol::https

# Installation

Needless to say, this is most useful with rspamd, but it can be used to generate a rbl for any email suite - at the end of the day, it simply generates an IPv4/IPv4 Net and ASN list in plain-text format.

## mySQL

Use the included .sql file.

## Perl

Untested on any other OS, but it's highly recommended on a linux machine to install cpanm first, and then install the perl packages through that. Use your OS's recommended methods to install Perl 5 and your choice of mySQL or equivalent.

## Scripts

Install anywhere you want. Probably will want to run it as a privleged user, or at least one that can access the files specified in the config. Be sure to fill out the config file and remove the .pub extension.

# Latest Changes

## 0-α1

- Created the project.

# Planned Features

- Make Monitor a Deamon with an install script.
- Create an automated install script...
- Add the ability to remove bans/infractions (you can do that within mySQL if you need to right now).

# License

The RBL Updater Suite is released under GNU GPLv3. See LICENSE.
