#!/bin/bash

#make sqlite-compatible datetime format
echo '2018-01-31T10:57:29.631-0500' | awk '{print gensub (/-0([0-9])00$/, "-0\\1:00" ,1,$1) }'
2018-01-31T10:57:29.631-05:00
