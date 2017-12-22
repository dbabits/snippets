#!/bin/bash
#capture both the output and the retcode
output=$( bash <<'EOF'
echo 'foo moo' 2>&1 |grep -v bar|awk '{print $2}'
echo retcode=${PIPESTATUS[0]}
EOF
)
echo "$output"

#or
output=$(
echo 'foo moo' 2>&1 |grep -v bar|awk '{print $2}'
echo retcode=${PIPESTATUS[0]}
)
echo "$output"


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

#xargs gems
echo "Here is a string is a string
Here is a string is a string2
" \
| grep -o -P '(?<=Here).*?(?=string)'  \
|xargs -n 1 --delimiter='\n' -I{}  sh -c 'echo {} ' 

> retcode=1; if [[ $retcode -eq 0 ]]; then echo true;else echo false;fi
false
> retcode=1; if [[ $retcode == 0 ]]; then echo true;else echo false;fi
false
> unset retcode; if [[ $retcode == 0 ]]; then echo true;else echo false;fi
false
> unset retcode; if [[ $retcode -eq 0 ]]; then echo true;else echo false;fi
true                <<Bad
> unset retcode; if [[ $retcode -eq 1 ]]; then echo true;else echo false;fi
false               <<???
> unset retcode; if [ $retcode -eq 0 ]; then echo true;else echo false;fi
-bash: [: -eq: unary operator expected
false
> unset retcode; if [ "$retcode" == "0" ]; then echo true;else echo false;fi
false
> unset retcode; if [[ "$retcode" == "0" ]]; then echo true;else echo false;fi
false
> retcode=12345; if [[ "$retcode" > "12346" ]]; then echo true;else echo false;fi
false
>  retcode=123456; if [ "$retcode" > "12346" ]; then echo true;else echo false;fi
true
> retcode=123456; if [[ "$retcode" > "12346" ]]; then echo true;else echo false;fi
false
> retcode=123456; if [[ $retcode > 12346 ]]; then echo true;else echo false;fi
false
> retcode=123456; if [ $retcode > 12346 ]; then echo true;else echo false;fi
true
> retcode=123456; if [[ $retcode -gt 12346 ]]; then echo true;else echo false;fi
true

