#!/bin/bash


https://github.com/adamdrake/the-art-of-command-line/blob/master/README.md#system-debugging

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


#get string between tokens, using grep. See lookahead assertions: https://www.regular-expressions.info/completelines.html
> echo "Here is a string is a string" | grep -o -P '(?<=Here).*(?=string)'
is a string is a

> echo "Here is a string is a string" | grep -o -P '(?<=Here).*?(?=string)'
is a

substr_between() {
 grep -o -P "(?<=$1).*?(?=$2)"
}
> echo "foo bar baz" | substr_between 'foo' 'baz'
 bar
> echo "foo bar baz" | substr_between 'bar' '$'
 baz
> echo "foo bar baz" | substr_between '^' 'bar'
foo


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

# union/intersect/difference
cat a b | sort | uniq > c   # c is a union b
cat a b | sort | uniq -d > c   # c is a intersect b
cat a b b | sort | uniq -u > c   # c is set difference a - b
      
#IF headaches:
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

.gitconfig:
  1 [alias]
  2 l = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
  3 ll= !git l --oneline | fzf --multi --preview 'git show {+2}'

