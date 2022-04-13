# Changelog

## 0-α1.3
- Updated documentation.
- Removed versioning from config.
- Added `list_bans`.
- Graceful JSON failure in `report`.
- Added ability to delete entries from `report`.
- Added IP queue in `monitor` for JSON failure handling.
- Dealt with some inconsistencies in how various ASN's list their information.
- Added "provider" field to each table.
- Reduced the information overload on `list_bans`.

## 0-α1.2
- Fixed log regex for monitor script.
- Added a case for where punishment is issued for a prefix has a ton of bad IPs that do not have their ban expirations timeout.
- Fixed DB query column typo.
- When an IP network range is added, on duplicate key it now adds ban expiration.
- Added variation of `spam` to the keywords monitor looks for.
- Fixed issue where script couldn't find the config file.
- Fixed bug where script would die if it encountered a JASON error when doing a BGP Info Query.

## 0-α1.1
- Fixed bug where config file cannot be found if script is not run from the directory it's located in.

## 0-α1
- Created the project.
