#!/bin/bash
# Usage:
#   evaluate_language.sh <corpus> <lang-code> <translation system>
#
# e.g.,
# ../scripts/evaluate_language.sh ../data/agg/en.txt es google

set -e

# Parse parameters
dataset=$1
lang=$2
trans_sys=$3
genders=$4
prefix=en-$lang

# Prepare files for translation
cut -f3 $dataset > ./tmp.in            # Extract sentences
mkdir -p ../translations/$trans_sys/
mkdir -p ../data/human/$lang

# Translate
trans_fn=../translations/$trans_sys/$prefix.txt
echo "!!! $trans_fn"
if [ ! -f $trans_fn ]; then
    python translate.py --trans=$trans_sys --in=./tmp.in --src=en --tgt=$2 --out=$trans_fn
else
    echo "Not translating since translation file exists: $trans_fn"
fi

# Align
align_fn=forward.$prefix.align
$FAST_ALIGN_BASE/build/fast_align -i $trans_fn  -d -o -v > $align_fn

# Evaluate
mkdir -p ../data/human/$trans_sys/$lang/
out_fn=../data/human/$trans_sys/$lang/${lang}.pred.csv
if [ -z "$genders" ]; then
    python load_alignments.py --ds=$dataset  --bi=$trans_fn --align=$align_fn --lang=$lang --out=$out_fn
else
    python load_alignments.py --ds=$dataset  --bi=$trans_fn --align=$align_fn --lang=$lang --out=$out_fn --genders=$genders
fi

# Prepare files for human annots
# human_fn=../data/human/$trans_sys/$lang/${lang}.in.csv
# python human_annots.py --ds=$dataset --bi=$trans_fn --out=$human_fn
