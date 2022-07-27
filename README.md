# RBL Updater Suite

This is the RBL Updater Suite Version 1 Feature Complete (1-fc) by John Bradley (john@systemanomaly.com). The RBL Updater Suite is an Open Source suite of tools to be used in conjunction with rpsamd to help autogenerate a local realtime block list (RBL) not reliant on any external lists, such as spamhaus and the like.

This software is extremely experimental and may cause collateral damage on deliverability. USE AT YOUR OWN RISK.

# Suite Components

## `monitor`

This is the script that monitors your mail log for a `NOQUEUE: reject` message or a `milter-reject` message containing additional keywords `BLOCKLIST`, `spam`, or `Spam`. When it does that, it flags the IP address associated with the message, and performs a number of actions outlined under the Principle of Operation section of this Readme.

```
        Options:
                -c [confpath]   Load Config File
                -v              Verbose Mode
                -i [logpath]    Import Log
                -s              Start Tail at Beginning
```

## `report`

This script is used to manually report an IP address or range. Regardless of previous infractions, it will always issue a 1-day ban based on the current time. This can inadvertantly shorten a ban if you are not careful.

```
        Options:
                -c      [confpath]      Load Config File
                -i      [IPv4 Address]  Adds a single IP address
                -n      [CIDR Notation] Adds a CIDR notation network range
                -p      Makes either IP address or network range permabanned
                -d      Delete either IP address or network range provided
```

## `generate_list`

This script will create a plaintext file with the IP addresses and network ranges, deliminated by newlines, at the location specified in the config file.

```
        Options:
                -c      [confpath]      Load Config File
```

## `list_bans`

This script will list all current bans and all ASN entries.

```
        Options:
                -c      [confpath]      Load Config File
                -l      [number]        limit output of banned IPs
```

## `update_asn_info`

This is only used to update SQL tables prior to Version 0 Alpha 1.3 to include new provider field in each table, and add ASN info to entries that had that column added.

# Principle of Operation

The `monitor` script assumes that you have configured postfix in a way that it blocks misconfigured hosts attempting to connect to your mail server, already is blocking messages, and has rspamd installed and running.

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
- Exception: if more than 5 IP addresses within a prefix have concurrent temporary bans at the same time, the prefix is issued a ban.

Bans are cumulative, and infractions are permanently recorded.

Usually at this point, no further actions are needed, but a particularly bad ISP will end up with a ton of bad prefixes. At this point, the ASN gets penalized.

- Up to 50% of prefixes can be permanently banned before ASN penalties are applied.
- First penalty is a 1 week ASN ban.
- Second penalty is a 1 month ASN ban.
- Third penalty is a permanent ASN ban.

Bans are cumulative, and infractions are permanently recorded.

This is agressive, and possibly hostile, but for the most part, it should never get as far as an ASN ban.

# Requirements

- Perl 5 (Tested 5.32.1)
- mySQL 15.1 or Equivalent (Tested MariaDB 10.5.12)

# Dependencies

- DBI
- File::Tail
- File::Basename
- Getopt::Std
- JSON
- LWP::UserAgent
- LWP::Protocol::https
- Text::Table

# Installation

Needless to say, this is most useful with rspamd, but it can be used to generate a rbl for any email suite - at the end of the day, it simply generates an IPv4/IPv4 Net and ASN list in plain-text format. The output of this file can be adjusted in `config.conf`.

## mySQL

Use the included .sql file.

```
mysql -u username -p database < tables.sql
```

## Perl

Untested on any other OS, but it's highly recommended on a linux machine to install cpanm first, and then install the perl packages through that. Use your OS's recommended methods to install Perl 5 and your choice of mySQL or equivalent.

Using cpanm, the following can be used to install all the required modules.

```
cpanm DBI File::Tail File::Basename Getopt::Std JSON LWP::UserAgent LWP::Protocol::https Text::Table
```

## Scripts

Install anywhere you want. Probably will want to run it as a privleged user, or at least one that can access the files specified in the config. Be sure to fill 
out the config file and remove the .pub extension.

Suggestion: install symlinks under `/sbin` for the 4 scripts.

```
/etc/rbl_generate -> generate_list
/etc/rbl_list     -> list_bans
/etc/rbl_monitor  -> monitor
/etc/rbl_report   -> report
```

# Configuration Options
**rspamd Blocklists**
```
$asnlist = '/etc/rspamd/local.d/maps/blockasn.map';
$iplist  = '/etc/rspamd/local.d/maps/blockip.map';
```

`$asnlist` is where your rspamd will reference the blocklist map for ASNs. `$iplist` is the same, but for individual IP addresses and IP networks. All IPs are in IPv4 format.

**Mail Log Settings**
```
$log     = '/var/log/mail.log';
```

This is where your MTA stores mail logs. This needs to be readable by the user running the script, like the rspamd blocklists.

**Database Settings**
```
$dbname  = '';
$dbhost  = '';
$dbport  = 3306;
$dbuser  = '';
$dbpass  = '';
```

## Monitor Daemon

Included is a service file that lets you run rbl_updater's `monitor` script as a daemon. Once a symlink for `monitor` is created under `/sbin`, and a symlink to `config.conf` is created under `/etc/rblupdater.conf`, you can copy `systemd/rbl-updater.service` to where your systemd instance stores these (such as `/etc/systemd/system/rbl-updater.service`). Once doing so, you simply need to run the following commands:

```
systemctl deamon-reload
systemctl enable rbl-updater
systemctl start rbl-updater
```

The monitor script should be running and logging in `/var/log/rbl_updater.log` or wherever you specified under `config.conf`.

## Install Script

Included is also an install script. As of this current version, it's not well tested, and may not perform correctly. Use at your own risk. It's interactive, so you'll need to sit with it while it runs. Run it out of the directory that the script is located in.

# Latest Changes

## Version 1 Feature Complete
- Updated documentation.
- Feature complete release.

# Tested System Configuration

| OS        | rspamd | MTA           | SQL             | Perl   |
| --------- | ------ | ------------- | --------------- | ------ |
| Debian 11 | 3.1    | Postfix 3.5.6 | MariaDB 10.5.12 | 5.32.1 |

# Release Cycle and Versioning

This project regular release cycle is not yet determined. Versioning is under the Anomaly Versioning Scheme (2022), as outlined in `VERSIONING` under `docs`.

# Support

| Version                             | Support Level    | Released       | End of Support | End of Life   |
| ----------------------------------- | ---------------- | -------------- | -------------- | ------------- |
| Version 1 Feature Complete          | Full Support     | 27 July 2022   | TBD            | TBD           |
| Version 0 Alpha 1.3                 | Critical Support | 2 May 2022     | 27 July 2022   | TBD           |
| Version 0 Alpha 1.2                 | End of Life      | 20 March 2022  | 6 April 2022   | 27 July 2022  |

# Contributing

Public contributions are encouraged. Please review `CONTRIBUTING` under `docs` for contributing procedures. Additionally, please take a look at our `CODE_OF_CONDUCT`. By participating in this project you agree to abide by the Code of Conduct.

# Contributors

Primary Contributors

- John Bradley - Initial Work

Thanks to [all who contributed](https://github.com/userjack6880/rbl_updater/graphs/contributors) and [have given feedback](https://github.com/userjack6880/rbl_updater/issues?q=is%3Aissue).

# Licenses and Copyrights

Copyright © 2022 John Bradley (userjack6880). The RBL Updater Suite is released under GNU GPLv3. See `LICENSE`.
