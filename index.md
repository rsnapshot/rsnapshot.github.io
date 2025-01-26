---
layout: page
title: rsnapshot
hide: true
permalink: /
---

rsnapshot is a filesystem snapshot utility based on rsync. rsnapshot makes it easy to make periodic snapshots of local machines, and remote machines over ssh. The code makes extensive use of hard links whenever possible, to greatly reduce the disk space required.

Depending on your configuration, it is quite possible to set up in just a few minutes. Files can be restored by the users who own them, without the root user getting involved.

There are no tapes to change, so once it's set up, your backups can happen automatically untouched by human hands. And because rsnapshot only keeps a fixed (but configurable) number of snapshots, the amount of disk space used will not continuously grow.

It is written entirely in perl with no module dependencies, and has been tested with versions 5.12 through 5.40. It should work on any reasonably modern UNIX compatible OS.

rsnapshot was originally based on an article called [Easy Automated Snapshot-Style Backups with Linux and Rsync](http://www.mikerubel.org/computers/rsync_snapshots/), by Mike Rubel.

For details on downloading, installing, and configuring rsnapshot, see the [rsnapshot Github repository](https://github.com/rsnapshot/rsnapshot).

rsnapshot comes with ABSOLUTELY NO WARRANTY.  This is free software, and you are welcome to redistribute it under certain conditions. See the GNU General Public Licence for details.
