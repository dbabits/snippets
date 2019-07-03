#undef in numerical op =0!
#must NOT include -l in -ane, or get a lot of empty space
local foo=$(printf 'Call: took 2ms\Call: took 3ms'|perl -w -F"Call\:.*took\s+(\d+)ms" -ane 'END {if (defined $x){print $x}} if (defined $F[1]) {$x +=$F[1]}'
