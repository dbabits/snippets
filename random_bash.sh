#!/bin/bash
#capture both the output and the retcode
output=$( bash <<'EOF'
echo 'foo moo' 2>&1 |grep -v bar|awk '{print $2}'
echo retcode=${PIPESTATUS[0]}
EOF
)

#get string between tokens, using grep
> echo "Here is a string is a string" | grep -o -P '(?<=Here).*(?=string)'
is a string is a

> echo "Here is a string is a string" | grep -o -P '(?<=Here).*?(?=string)'
is a

#Sort, except header:
echo '
header
line2
line1
'|awk 'NR<3{print $0;next}{print $0| "sort "}'

header

line1
line2
