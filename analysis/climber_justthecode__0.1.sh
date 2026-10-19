

##   + + +    c l i m b e r    v 0 . 4    25.06.2026.jfg   ======================


    ##   n o t e   ::   these chunks don't use SLURM - approach is general


## 0 setup and congifure     ===================================================

# start (or reconnect to) a stable screen session called "femmebio"
screen -RD femmebio

# to disconnect, press Ctrl+A, and then D (or just close the window)


## shortcuts and set up folders    ---------------------------------------------

# should match your ID on HPC/server/garrison
self=cleverusername

# pick a fancyname
proj=fancy__games_dot_com

# use $self from above to define your working directory
basepath=/home/$self

# check them - if the $var doesnt exist they'll print empty
echo $self $proj $basepath $thisdoesntexist


# using basepath from above
raw=$basepath/raws/${proj}__raw
join=$basepath/raws/${proj}__join
wrk=$basepath/work/$proj

# for storing metadata etc.
mat=$wrk/Materials

# assumed location, update as necess
db=$basepath/db   

qc=$wrk/1__qc

filt=$wrk/2__filt
host=$wrk/3__deacon
krak=$wrk/4__krak2

## make folders from vars
mkdir -p $raw $join $wrk $qc $filt $host $krak $mat
mkdir -p $qc/${proj}_join $qc/${proj}_filt  $qc/${proj}_host $qc/${proj}_join_multi $qc/${proj}_filt_multi $qc/${proj}_host_multi


## install mamba & environments   ----------------------------------------------

# folder for your programmes - adapt as best suits you
b_path=~/bin  
mkdir -p $b_path ; cd $b_path

# first, get mamba (miniforge) and run through installation
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh

# install tools needed into fresh environments using mamba. or dont.
mamba create -n mgx -c bioconda -c conda-forge trimmomatic fastqc multiqc deacon parallel -y   # 346MB
mamba create -n k2 -c bioconda bracken kraken2 krakentools parallel -y # >300MB

# while here, get KrakenTools for later
git clone https://github.com/jenniferlu717/KrakenTools.git


## define a quick function to check whether all samples processed 

catcher (){
  local DirCheck=$1
  comm -23 \
  <( sort $mat/${proj}__samples.txt ) \
  <( ls $DirCheck | sed -E 's/_(S[0-9]*).*/_\1/g' | sort  -u)
}

# e.g. check samples downloaded (should return nothing!)
catcher $join

# e.g. check samples filtered (might return something...)
catcher $filt


## reference data & databases --------------------------------------------------

# filtering & trimming - trimmomatic   -----------------------------------------

# standard reference sequences to be removed

echo '>Ampli_Tru_Seq_adapter__MOST_IMPORTANT_FEEEL_ME
CTGTCTCTTATACACATCT
>Transposase_Adap__for_tagmentation_1
TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG
>Transposase_Adap__for_tagmentation_2
GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG
>PCR_primer_index_1
CAAGCAGAAGACGGCATACGAGATNNNNNNNGTCTCGTGGGCTCGG
>PCR_primer_index_2
AATGATACGGCGACCACCGAGATCTACACNNNNNTCGTCGGCAGCGTC
>TruSeq_single_index_LT_CD_HT__1
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
>TruSeq_single_index_LT_CD_HT__2
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
>PCR-Free_Prep__Tagm__additional_seq
ATGTGTATAAGAGACA
>Ampli_Tru_Seq_adapter__MOST_IMPORTANT_FEEEL_ME__mate_RC
AGATGTGTATAAGAGACAG
>Transposase_Adap__for_tagmentation_1.RC:
CTGTCTCTTATACACATCTGACGCTGCCGACGA
>Transposase_Adap__for_tagmentation_2.RC:
CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
>PCR_primer_index_1_RC:
CCGAGCCCACGAGACNNNNNNNATCTCGTATGCCGTCTTCTGCTTG
>PCR_primer_index_2_RC:
GACGCTGCCGACGANNNNNGTGTAGATCTCGGTGGTCGCCGTATCATT
>TruSeq_single_index_LT_CD_HT__1_RC:
TGACTGGAGTTCAGACGTGTGCTCTTCCGATCT
>TruSeq_single_index_LT_CD_HT__2_RC:
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>PCR-Free_Prep__Tagm__additional_seq_RC:
TGTCTCTTATACACAT
>polG_just_from_PCF_concerns
GGGGGGGGGGGGGGGGGGGGGGGG
>polA_just_from_PCF_concerns
AAAAAAAAAAAAAAAAAAAAAAAA'> $mat/fqc_trimmo_ill_ref.fa


## more commonly, programmes need databases: recall we defined a $db var for this.
lk $db

# decontamination - deacon -----------------------------------------------------

# Download validated 3GB human pangenome index (version 0.13.0 or later)
deacon index fetch panhuman-1 -o $db/deacon_db


## assignment - kraken2 / Bracken  ---------------------------------------------
cd $db
wget https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_20260226.tar.gz

## -Xtract Ze Vucking Files (extract, gzipped, verbose, file-destination: )
tar -xzvf $db/kraken2_plusPF__langmead $db/k2_pluspf_20260226.tar.gz
## look
ls -lsh $db/kraken2_plusPF__langmead


## fastq data - basespace   ----------------------------------------------------
bs=$b_path/bs

## if you don't have it, download the basepspace programme (aka bs) to $bs :
wget "https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs" -O $bs ; chmod 775 $bs

# follow instructions to complete setup:
$bs auth
# more info if you like: (press Q to exit)
$bs download -h


##   1   download sequence data   ==============================================

# save your real project ID here
projectID=123456789

## download FASTQ to the folder we chose/created above - will take a while to finish (screen will protect us)
$bs download project --id $projectID --output $raw --log=$f_path/fdl.log & 
  
## have a lük: red = compressed
ls $raw/*/*gz
# use that to pull a sample list for constant re-use. always worth doublechecking.
ls $raw/*/*gz | sed -r 's/.*\/(.*)_L00._R._001.fastq.gz/\1/g' | sort -u > $mat/${proj}__samples.txt
head -n 10 $mat/${proj}__samples.txt

##  tidy up - join lanes (L001, L002) and remove _L00*_R*_001 from name. 
time parallel -j 16 "cat $raw/*/{}_L00*_R1_001.fastq.gz >  ${join}/{}_R1.fastq.gz ; cat $raw/*/{}_L00*_R2_001.fastq.gz >  ${join}/{}_R2.fastq.gz" :::: $mat/${proj}__samples.txt

fastqc -t 15 $join/*fastq.gz -o $qc/${proj}_join
multiqc $qc/${proj}_join -o $qc/${proj}_join_multi

# XXX.YYY.34.1 is the address for the HPC (replace XXX.YYY with our real prefix) - we use -o ProxyJump to send the request through garrison.ucc.ie
# run this command on the server (to get the correct paths etc.), then copy and paste on your local (UNIX) machine
echo "scp -o ProxyJump=${self}@garrison.ucc.ie ${self}@XXX.YYY.34.1:$qc/${proj}_join_multi/multiqc_report.html ./Desktop/"
# in your browser, open the `multiqc_report.html` that has appeared on your desktop 


## tester samples   ------------------------------------------------------------

# grep looks for the pattern "23-V" in $mat/${proj}__samples.txt and returns those lines, we send it to a new file with ">"
grep "23-V" $mat/${proj}__samples.txt > $mat/${proj}__tester.txt

# have a little lük, its just the sample IDs
head $mat/${proj}__tester.txt

# and a test sample (just take the first one)
test=$( head -n 1 $mat/${proj}__tester.txt)


##   2   trim and filter - trimmmomatic   ======================================

  ##--< ! >   MAKE SURE you check F+MQC  to set your parameters below     < ! >--

# use ILLUMINACLIP before CROP to maximise space for pattern recognition
cat $mat/${proj}__tester.txt | parallel -j 4 "trimmomatic PE \
  $join/{}_R1.fastq.gz \
  $join/{}_R2.fastq.gz \
  $filt/{}_R1_trimm.fastq.gz \
  $filt/{}_R1_trimm_unpaired.fastq.gz \
  $filt/{}_R2_trimm.fastq.gz \
  $filt/{}_R2_trimm_unpaired.fastq.gz \
  ILLUMINACLIP:$mat/fqc_trimmo_ill_ref.fa:2:30:10:5 \
  SLIDINGWINDOW:6:15 \
  CROP:105 \
  HEADCROP:19 \
  MINLEN:50 \
  -threads 4 > $filt/{}_trim.log 2>&1"

# remove unpaired stuff
mkdir $filt/unpaired ; mv $filt/*unpaired* $filt/unpaired/
fastqc -t 16 $filt/*_trimm.fastq.gz -o $qc/${proj}_filt ; multiqc $qc/${proj}_filt -o $qc/${proj}_filt_multi


##   3   remove host sequences - Deacon   ======================================

# ~15mins
time cat $mat/${proj}__samples.txt | parallel -j 8 "deacon filter -d \
  $db/deacon_db/panhuman-1.k31w15.idx \
  $filt/{}_R1_trimm.fastq.gz \
  $filt/{}_R2_trimm.fastq.gz \
  -o $host/{}_R1_deco.fastq.gz \
  -O $host/{}_R2_deco.fastq.gz \
  --threads 4 > $host/{}_hostless.log 2>&1"

# very quick check of outputs
grep -h "Retained" $host/*log

fastqc -t 16 $host/*_deco.fastq.gz -o $qc/${proj}_host ; multiqc $qc/${proj}_host -o  $qc/${proj}_host_multi

# recall - make sure to fix the XXX.YYY
echo "scp -o ProxyJump=${self}@garrison.ucc.ie ${self}@XXX.YYY.34.1:$qc/${proj}_host_multi/multiqc_report.html ./Desktop/"


##   4   identify - Kraken2 + Bracken   ========================================

mamba activate k2

## check variables:
kr_db=$db/kraken2_plusPF_langmead
kr_threads=5
br_r=100      # $br_leng = match the post-host length
br_l=S
br_t=50   # counts of microbes! not threads

## for use with --memory-mapping, to avoid OOM
vmtouch -t  $kr_db/*.k2d


##  Kraken2  -------------------------------------------------------------------

time for test in $(cat $mat/${proj}__samples.txt );
do
  
  echo " + + +   Kraken2 on ${test} -  conf 0.1, min-hits 5, min-qual 20 (mem-mapp)"
  kraken2 --db $kr_db \
  $host/${test}_R1_deco.fastq.gz \
  $host/${test}_R2_deco.fastq.gz \
  --paired \
  --threads $kr_threads \
  --confidence 0.1 \
  --memory-mapping \
  --gzip-compressed \
  --report-zero-counts \
  --minimum-hit-groups 5 \
  --minimum-base-quality 20 \
  --report $krak/${test}_kraken2_report \
  
done > $krak/k2__all_memmap.log 2>&1


##  Bracken  -------------------------------------------------------------

parallel -j $kr_threads bracken -d $kr_db/ -i {} -o {}.bracken -r $br_r -l $br_l -t $br_t  ::: $krak/*kraken2_report > $krak/k2_br.log 2>&1 

# tidy - scraunch if necessary
parallel -j $kr_threads gzip {} ::: $krak/${test}* 
  

## combine outputs, taxonomy   -------------------------------------------------

# abundances
$b_path/KrakenTools/combine_kreports.py -r $krak/*_bracken_species -o $krak/${proj}__kraken2_plusPF_abundances.tsv

# taxonomic hierarchy
$b_path/KrakenTools/kreport2mpa.py -r $krak/${proj}__kraken2_plusPF_abundances.tsv -o $krak/${proj}__${test}_kraken2_mpa
grep -h '|s_' $krak/${proj}__${test}_kraken2_mpa | cut -f 1 |   sort | uniq | sed 's/|/\t/g' > $krak/${proj}__kraken2_plusPF_taxonomy.tsv

## use "less -S $yourfile" to have a closer lük - press Q to quit
head -n 20 $krak/*tsv

  
##   exit stage left    ========================================================

# compress & send 
mkdir $mat/${proj}_output
cp $krak/${proj}__kraken2_plusPF_abundances.tsv ${KRAK}*/${proj}__kraken2_plusPF_taxonomy.tsv $mat/${proj}_output/
tar -czvf ${mat}/${proj}_output.tar.gz ${mat}/${proj}_output
echo "scp -oProxyJump=${self}@garrison.ucc.ie ${self}@XXX.YYY.34.1:${mat}/${proj}_output.tar.gz ~/Desktop/"

# explore on your computer
tar -xzvf ~/Desktop/${proj}.tar.gz


## end of the beginning