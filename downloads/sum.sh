#!/bin/bash
md5sum "$1" > "$1".md5
sha1sum "$1" > "$1".sha1
sha256sum  "$1" > "$1".sha256
