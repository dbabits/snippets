#!/bin/bash

#see max memory usage for process:
$ alias ps3='ps -Ao pid,user,start_time,etime,pcpu,vsize,rss,comm,args --sort=-rss'
$ while true; do ps3|grep FsShell|grep -v grep; sleep 1; done 2>&1 |tee /tmp/tmp.log
$ awk '{print $6"|"$7}' /tmp/tmp.log| sort -t '|' -k2 -n |less

redirect_io(){
 exec 3>&1 # link file descriptor 3 w stdout.Save stdout
 exec 4>&2 # same for stderr
 exec >>$logfile 2>&1 # redirect both stdout and stderr to file
}
restore_io(){
 exec 1>&3
 exec 2>&4
}
trap "restore_io;ls -l $logfile" EXIT

#make colors only if stderr is connected to term(stdout has been redirected
#Otherwise, control chars appear if puoed through or redirected to file
#Also, dont make these fns screw any caller return code-must return 0 always
#Otherwise code like >/tmp/foo 2>&1 wilredirect_io(){
 exec 3>&1 # link file descriptor 3 w stdout.Save stdout
 exec 4>&2 # same for stderr
 exec >>$logfile 2>&1 # redirect both stdout and stderr to file
}
restore_io(){
 exec 1>&3
 exec 2>&4
}
trap "restore_io;ls -l $logfile" EXIT

#make colors only if stderr is connected to term(stdout has been redirected
#Otherwise, control chars appear if puoed through or redirected to file
#Also, dont make these fns screw any caller return code-must return 0 always
#Otherwise code like >/tmp/foo 2>&1 will not behave same as >/tmp/foo
red()     { [[ -t 2 ]] && tput setaf 1; return 0; }
green()   { [[ -t 2 ]] && tput setaf 2; return 0; }
yellow()  { [[ -t 2 ]] && tput setaf 3; return 0; }
blue()    { [[ -t 2 ]] && tput setaf 4; return 0; }
magenta() { [[ -t 2 ]] && tput setaf 5; return 0; }
cyan()    { [[ -t 2 ]] && tput setaf 6; return 0; }
reset()   { [[ -t 2 ]] && tput sgr0;    return 0; }



# Conditional pipeline. https://unix.stackexchange.com/questions/38310/conditional-pipeline
| ([[ "$var" > "0" ]] && sed 1d || cat) |
| if [[ "$var" > "0" ]]; then  sed 1d; else cat; fi |

strip_non_printables() {
     sed 's/[^[:print:]]//g'
}
#see https://access.redhat.com/solutions/1136493 
#Non printable chars sent by mailx result in email arriving as binary attachment.
#Non printable chars can happen when you copy-paste from an Outlook email into your code.This is how to resolve it
echo "text pasted from outlook" | dos2unix | strip_non_printables | mailx -s

#rolling log pattern: (.log, .log.1,...)
# https://stackoverflow.com/questions/21792385/how-to-use-ls-to-list-out-files-that-end-in-numbers
shopt -s extglob
ls stream.log*(.)*([0-9])

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
cat a b | sort | uniq       #a union b
cat a b | sort | uniq -d    #a intersect b
cat a b | sort | uniq -u    #diff a and b
cat a b b | sort | uniq -u  #set difference a - b
cat a a b | sort | uniq -u  #set difference b - a

dima@LAPTOP-MA6OEPO9:~/development/utils$ cat a
line 1
line 2
line 3
dima@LAPTOP-MA6OEPO9:~/development/utils$ cat b
line 1
line 4
dima@LAPTOP-MA6OEPO9:~/development/utils$ cat a b |sort|uniq -d
line 1
dima@LAPTOP-MA6OEPO9:~/development/utils$ cat a b |sort|uniq -u
line 2
line 3
line 4
dima@LAPTOP-MA6OEPO9:~/development/utils$ cat a b b |sort|uniq -u
line 2
line 3
dima@LAPTOP-MA6OEPO9:~/development/utils$ cat a a b |sort|uniq -u
line 4

#Close, but slightly different: comm [-123]
$ comm  <(sort a) <(sort b)
                line 1
line 2
line 3
        line 4

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
>retcode=12345; if [[ "$retcode" > "2346" ]]; then echo true;else echo false;fi
false          <<BAD
> retcode=12345; if [[ $retcode > 2346 ]]; then echo true;else echo false;fi
false          <<BAD
> retcode=12345; if [[ $retcode -gt 2346 ]]; then echo true;else echo false;fi
true
> retcode=12345; if [ "$retcode" > "2346" ]; then echo true;else echo false;fi
true
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

