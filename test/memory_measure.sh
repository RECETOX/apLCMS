#!/bin/bash

maxcores=1
out=

while getopts o:c: opt; do case $opt in
	c) maxcores=$OPTARG ;;
	o) out=$OPTARG ;;
	*) cat - >&2 <<EOF
usage: $0 options files...

-c cores	max. number of cores
-o prefix	where to write output
EOF
	exit 1 ;;
esac; done

shift $(($OPTIND - 1))

[ -z "$out" ] && { echo -- -o is mandatory >&2; exit 1; }

files=("$@")

numf=${#files[@]}
[ $numf -lt 4 ] && { echo At least 4 files are required >&2; exit 1; }

nf=(4 6 8 10 15 20 25 30)
n=40
while [ $n -le 100 ]; do
	nf+=($n)
	n=$((n+10))
done

nc=(1 2 4 8 12 16 20)
n=24
while [ $n -le 64 ]; do
	nc+=($n)
	n=$((n+8))
done
n=80
while [ $n -le 128 ]; do
	nc+=($n)
	n=$((n+16))
done

echo -n '	' >$out-ret.tsv
echo ${nc[@]} | tr ' ' '	' >>$out-ret.tsv

echo -n '	' >$out-mem.tsv
echo ${nc[@]} | tr ' ' '	' >>$out-mem.tsv

echo -n '	' >$out-time.tsv
echo ${nc[@]} | tr ' ' '	' >>$out-time.tsv


for f in ${nf[@]}; do
	[ $f -gt $numf ] && break

	echo -n "$f" >>$out-ret.tsv
	echo -n "$f" >>$out-mem.tsv
	echo -n "$f" >>$out-time.tsv

	for c in ${nc[@]}; do
		if [ \( $c -lt  $((f / 4)) -a $c -lt $((maxcores / 2)) \) -o $c -gt $maxcores -o $c -gt $f ]; then
			echo -n '	nan' >>$out-ret.tsv
			echo -n '	nan' >>$out-mem.tsv
			echo -n '	nan' >>$out-time.tsv
			continue
		fi
		echo $(dirname $0)/memory_single_run.sh -c $c -o $out-${f}_$c.out -e $out-${f}_$c.err ${files[@]:0:$f}
		res=(-1 -2 -3)
		res=($($(dirname $0)/memory_single_run.sh -c $c -o $out-${f}_$c.out -e $out-${f}_$c.err ${files[@]:0:$f}))
		echo -n "	${res[0]}" >>$out-ret.tsv
		echo -n "	${res[1]}" >>$out-mem.tsv
		echo -n "	${res[2]}" >>$out-time.tsv
	done
	echo >>$out-ret.tsv
	echo >>$out-mem.tsv
	echo >>$out-time.tsv
done
