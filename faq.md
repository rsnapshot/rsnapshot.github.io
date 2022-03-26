---
layout: page
title: FAQ
---
### How do I restore files with rsnapshot?

If you have super-user access on the rsnapshot server, you can just copy the files from the snapshot root (eg: /.snapshots/daily.0/server/directory/file). The daily backups will be more recent than the weeklys, and the weekly more recent than the monthlys, etc. Your system administrator may have set up a **read-only** copy of the snapshot root (eg: with read-only NFS or read-only Samba). If so, it is better (safer and possibly more convenient) to copy files from this read-only copy of the snapshot root.

### I have a snapshot root or backup point with a space (or other special character) in it and this is not working at all with rsnapshot 1.3.1. Why?

rsnapshot version 1.3.1 has an issue where the rsync command is interpreted by a shell rather than directly executed by rsnapshot. This bug is expected to be fixed in rsnapshot CVS on 24 March 2009, and so should appear an a forth-coming release (probably version 1.3.2). This bug was not present in rsnapshot 1.3.0.

### I have `sync_first` enabled and `link_dest` enabled and multiple backup lines in my rsnapshot.conf file, and I am finding the --link-dest option is not being passed to rsync for the second and subsequent backups, so a lot of files are being duplicated in my snapshot_root without being hard linked. What's going on?

rsnapshot versions 1.2.9 and 1.3.0 have a bug where --link-dest is omitted in these circumstances for any backup where the .sync directory exists when the backup is started. This bug was fixed in rsnapshot version 1.3.1. With older versions of rsnapshot, please take care to avoid this combination, for example by disabling link_dest or sync_first.

### Why aren't sync_first and include_conf documented in the rsnapshot HOWTO?

That's a good question. `sync_first` and `include_conf` were new features added between rsnapshot 1.2.3 and 1.2.9. Unfortunately the maintainers have been short of time and haven't found time to update the HOWTO. If updating the HOWTO is something you can help with, please tell the rsnapshot-discuss list. At least you can find some documentation for these features in the rsnapshot man page.

### Where do I report a bug in rsnapshot?

You can report bugs, request features and submit patches to the [Github issue tracker](https://github.com/rsnapshot/rsnapshot/issues).

### How do I backup from Windows machines to Linux?

You can run rsnapshot on a Linux machine (where the backups will be stored) and run a `ssh` and `rsync` server on the Windows machine.

#### [cwRsync](https://itefix.net/cwrsync) Server on Windows

An option is to run [cwRsync](https://itefix.net/cwrsync) Server on the Windows machines so that you can connect to them with ssh protocol or rsyncd protocol. Many people have reported backups hanging in the middle of a backup if they use ssh protocol to Windows machines. You should be able to avoid these hangs by using `rsync://user@host/dir` (rsyncd protocol) in your backup line rather than `user@host:/dir` (rsync over ssh protocol).
But bear in mind that rsyncd protocol is unencrypted, in case you are transferring over an untrusted network (like the Internet). There is a suggestion [secure connections between linux rsync clients and cwRsync servers](http://www.itefix.no/i2/node/11317) in the cwrsync faq, but it would need to be adapted for rsnapshot and customised for your environment.

#### Windows 10 native OpenSSH server and WSL2

For Windows 10 (1809+) machines, another option is to use the native OpenSSH server now available in Windows 10 1809 and WSL2. By using the native ssh server, WSL does not have to be running for the backup to occur.
 
* Install the native [OpenSSH server in powershell](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse).
* Key based access is still required and setup can be a bit strange, see the following [StackOverflow post answer](https://stackoverflow.com/a/50502015) for what configuration steps are required.
* Install WSL2 and your Linux distribution of choice. Make sure `rsync` is installed and available in that distribution.
* Use WSL2's `rsync` by including `rsync_long_args='--rsync-path=wsl rsync'` in the `backup` command. Take care with the single quote placement so the configuration will be executed correctly. By providing `wsl rsync`, this executes the `rsync` command in WSL instead of trying to execute it via Windows.

##### Example `backup` command configuration for Windows machines
 
This assumes that key based access for John Doe is properly configured on the remote system. (And that tabs are used between the fields)
 
    backup    192.168.1.2:/mnt/c/users/John\ Doe/    johndoe/    rsync_long_args='--rsync-path=wsl rsync',ssh_args=-l 'John Doe'

### When backing up a Windows machine via `ssh`, how do you use a username with a space in it?

If a username has a space in it, for example 'John Doe', use the `ssh_args` argument in the `backup` command instead of the username being inline with the address. E.g. `ssh_args=-l 'John Doe'`. `rsnapshot` does not currently allow for parsing spaces _before_ the `@` on a backup target. By proving the username via the `-l` argument, we do an end run around the parser. Note, this should be the last argument on the line as there could be some issues parsing the argument with partial quotes.

### When backing up Windows paths, how do I overcome spaces in the path?

To deal with a space in the path, you can simply escape them in the `backup` command. To continue with example user "John Doe", to backup their home directory in Windows use the path `/mnt/c/users/John\ Doe/`. If you're curious why escaping the space works here but not for the username, it's because the path is sent to the remote system and _then_ parsed.

### I run rsnapshot for the first time, but nothing happens. Why?

rsnapshot does two major things - actual backup (with rsync) and rotation (moving snapshots around). Before it can do rotations, it needs to have at least one actual backup. So you need to understand which rsnapshot invocation will make an actual backup.

For example, if you have `sync_first` enabled, then you need to run `rsnapshot sync` (which makes a backup) before you can do a rotation like `rsnapshot hourly` or `rsnapshot daily`. With sync_first enabled, all intervals (hourly, daily, etc) just do rotation.

If you do not have `sync_first` (it is disabled by default), then the backup is made by the *lowest* interval (that is, the first one that you listed in your rsnapshot.conf). The other (higher) intervals do rotation.
For example, if you have intervals `hourly`, `daily`, `weekly` and `monthly`, then you need to run `rsnapshot hourly` to do a backup before the other intervals (daily, weekly and monthly which do rotations) will do anything.

In fact, you need a complete set of hourly backups before a `rsnapshot daily` will do anything. Similarly, you need a complete set of daily backups (usually 7) before `rsnapshot weekly` will do anything.

### I get warnings like `Could not lchown() symlink`. Help?

You should be able to fix the warnings by installing the perl Lchown module. Get it from the [CPAN module-page](http://search.cpan.org/~ncleaton/Lchown-1.01/lib/Lchown.pm). Or if you don't care about symlinks having the wrong ownership in your snapshots, then you could ignore the warnings.

### How do I exclude files/directories with **spaces** in their names, like `Documents and Settings`?

You can make use of the wildcard matching and replace the space with a `?`, for example: `exclude=Documents?and?Settings/`

### My rsnapshot setup seems to eat the processor on the machines I'm backing up from. How can I prevent this?

rsnapshot itself is a low-overhead program, but rsync can drive processor utilization uncomfortably high. To address this, tell your rsync to run with high nice and ionice values, like 10 and -c3 respectively.

Depending on how rsync was packaged for your system, your installation may have an /etc/default/rsync file. If it does, set RSYNC_NICE and RSYNC_IONICE as recommended. Then restart the rsync daemon. You should notice a difference immediately.

Thanks to Eric Raymond for writing this entry!

### I'm trying to backup up Windows machines onto a Linux box using rsnapshot (on Linux) and cwrsync as a daemon (on Windows). When I back things up, though, it doesn't seem to delete files in the backup that were deleted in the source, so my backups keep getting bigger and bigger. How can I fix this?

The simple-but-dangerous approach is to add --ignore-errors to your rsync_long_opts line in your rsnapshot configuration file. The tedious-and-fragile-but-probably-safer approach is to find out where the I/O errors are occurring in the backup and exclude those files from the backup set. It seems that not all cwrsync and rsync versions handshake well on some Windows filenames, such as "Shortcut to 3½ Drive" (chokes on the ½ character), some URLs held in Internet Explorer's cache (chokes on length?), some entries in the Recycle Bin (chokes on the curly braces?). If there's **any** I/O error, it seems that rsync elects not to honor the --delete that rsnapshot passes in, unless you also say --ignore-errors, which could get you in trouble when **real** errors occur.

Thanks to Mark Murphy for writing this entry!

### Can I set the `snapshot_root` to a remote SSH path? I want to push my backups to a remote server, rather than pull them from a remote server.

Rsnapshot does **not** support a remote snapshot root via SSH.
However you should be able to use a remote snapshot root that is NFS mounted
on the machine that runs rsnapshot but hosted on another machine (NFS server).

If you are running rsnapshot as user root (which is the normal case),
make sure that the NFS server allows root access for that NFS mount to
the rsnapshot machine as an NFS client.
For a solaris NFS server, see root= in share_nfs(1).
For a Linux NFS server, see no_root_squash in exports(5).
Otherwise you might get errors about chown, removing directories/files, etc
if permissions on the NFS server are mapped from "root" to "nobody".

For advanced users, Matt McCutchen suggested the following alternative.
What you can do instead is put the rsnapshot configuration file
on the destination server (with a local snapshot root),
allocate a "staging" area on that server,
and define it as the sole backup point.
To make a snapshot, execute an ordinary rsync push to the staging area and then
invoke rsnapshot on that server to incorporate the new data into a snapshot.
To do this conveniently over SSH, create the following script
`rsync-and-kick-rsnapshot` on the destination server:

    #!/bin/bash
    rsync "$@" && rsnapshot $interval

And then pass

    `--rsync-path=*/path/to/*rsync-and-kick-rsnapshot`.

With an rsync daemon, create this script `kick-rsnapshot`:

    #!/bin/bash
    if [ "$RSYNC_EXIT_STATUS" == "0" ]; then
			rsnapshot $interval
    fi

And specify it as the `post-xfer exec` command
for the module containing the staging area.

If multiple machines need to be backed up, instead of trying to coordinate their pushes and rotations, the easiest thing to do is to make a completely separate rsnapshot configuration file and snapshot root for each. Some more hints, including two approaches to avoid the use of double the disk space on the destination server, may be found in [this message](http://lists.samba.org/archive/rsync/2007-December/019470.html) and [this message](http://lists.samba.org/archive/rsync/2008-January/019607.html).

### I'm backing up to a firewire or USB external drive. When the drive isn't mounted, rsnapshot writes all the backups to the /mnt/ directory on the local hard drive, filling up the disk. How can I prevent this?

Set the `no_create_root` option to `1` in the config-file.

### How do I set up public keys for ssh so that rsnapshot can run from cron?

Run commands like these on your rsnapshot server as root (or whichever user you run rsnapshot as from cron) :-

    rsnapshotserver# ssh-keygen -N "" -f ~/.ssh/rsnapshot_dsa
    rsnapshotserver# ssh-copy-id -i ~/.ssh/rsnapshot_dsa.pub root@<I>client1</I>
    rsnapshotserver# ssh-copy-id -i ~/.ssh/rsnapshot_dsa.pub root@<I>client2</I>

To make rsnapshot use this DSA key, add

    ssh_args	-i /root/.ssh/rsnapshot_dsa

to your config-file (assuming you don't have `ssh_args` currently).

### After I've taken a few snapshots, why do they all show up the same size in df? I thought rsnapshot was meant to only take one full snapshot and then a bunch of incrementals?

You thought right, and it does! It looks like you've got a bunch of full snapshots because any file which hasn't changed between two consecutive snapshots will be a [hard link](http://en.wikipedia.org/wiki/Hard_link), so potentially several directory entries in consecutive snapshots may actually point at the same data on disk, so the only space taken up by a snapshot is whatever is different between it and the previous one.

The `du` utility can detect hard-links and count them correctly only
if the all the directories containing the hard-links are counted at
the same time (that is: all given on the same command line to `du`).

In the following example, assume `hourly.0` contains 500GB worth of files,
and `hourly.1/2` contain *only* hardlinks. Compare running `du` on each
directory separately versus counting them all at once:

    $ ls
    hourly.0
    hourly.1
    hourly.2

    $ du -sh hourly.0
    500G    hourly.0

    $ du -sh hourly.1
    500G    hourly.1

    $ du -sh hourly.2
    500G    hourly.2

    $ du -sh *
    500G    hourly.0
    442K    hourly.1
    442K    hourly.2

`du` keeps a list of all files internally and if a second hardlink to
a file is found it is not counted again. This is of course not
possible when counting each directory separately. The 442K size in the
example above is the additional space hardlinks consume on the
filesystem (large number of files will increase this value).

Using the `-c` option (=print total) will also print the correct amount
of consumed disk space:

    $ du -shc
    500G    .
    500G    total

Alternatively, the `rsnapshot-diff` can be used to show differences between snapshots.
