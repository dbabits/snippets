#/bin/bash

#remove \t and \n:
sed 's/\\[tn]//g'
tr -d '\n\t'

#remove first 10 lines:
sed 1,10d

strip_non_printables() {
     sed 's/[^[:print:]]//g'
}

#print all lines after pattern (useful in self-executing templates, e.g. jils)
echo '
1
2
pattern
3
4
' | sed  '1,/pattern/d'

3
4


#print everything before pattern, not including pattern
echo '
1
2
pattern
3
4
' | sed '/pattern/Q'

1
2

#print everything before pattern, including pattern
echo '
1
2
pattern
3
4
' | sed '/pattern/q'

1
2
pattern
