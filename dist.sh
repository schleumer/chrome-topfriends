#!/bin/sh

gulp dist-only

rm -Rfv topfriends-dist.zip

zip -r -9 topfriends-dist.zip dist/
