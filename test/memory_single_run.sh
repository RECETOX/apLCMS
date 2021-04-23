#!/bin/bash

cores=1
out=/dev/stdout
err=/dev/stderr

default_image=recetox/aplcms:6.6.6-recetox2
image=$default_image

while getopts c:o:e:i: opt; do case $opt in
	c) cores=$OPTARG;;
	o) out="$OPTARG";;
	e) err="$OPTARG";;
	i) image=$OPTARG;;
	*) cat >&2 <<EOF
usage: $0 options input_files...

print apLCMS exit code (\$?), memory usage (bytes) and time to execute (seconds)

-c cores 	how many cores to use (default 1)
-o file		redirect apLCMS stdout to file
-e file		redirect apLCMS stderr to file
-i image	docker image to use (default $default_image)

input paths must reside in the current working directory 

EOF
exit 1
	;;
esac; done

shift $(($OPTIND - 1))

files="'$1'"
shift
for f in "$@"; do
	files="$files,'$f'"
done

id=$(docker run -u $(id -u) -d -v $PWD:/work -w /work $image sleep 9876543210)

start=$(date +%s)
docker exec -u $(id -u) -ti $id bash -c "Rscript -e \"x <- apLCMS::unsupervised(files=c($files),min_exp = 2, min_pres = 0.5, min_run = 12.0, mz_tol = 1e-05, baseline_correct = 0.0, baseline_correct_noise_percentile = 0.05, intensity_weighted = FALSE, shape_model = 'bi-Gaussian', BIC_factor = 2.0, peak_estim_method = 'moment', min_bandwidth = , max_bandwidth = , sd_cut = c(0.01, 500.0), sigma_ratio_lim = c(0.01, 100.0), component_eliminate = 0.01, moment_power = 1.0, align_chr_tol = , align_mz_tol = , max_align_mz_diff = 0.01, recover_mz_range = , recover_chr_range = , use_observed_range = TRUE, recover_min_count = 3, cluster = as.integer('$cores') )\"" >$out 2>$err
ret=$?
end=$(date +%s)
time=$(($end - $start))
mem=$(cat /sys/fs/cgroup/memory/docker/$id/memory.max_usage_in_bytes)

docker rm -f $id >/dev/null

echo $ret $mem $time
