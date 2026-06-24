
##   + + +    c l i m b e r    v 0 . 4    24.06.2026.jfg   ======================


## 0 setup and configure  ======================================================

# start (or reconnect to) a stable screen session called "femmebio"
screen -RD femmebio
# to disconnect, press Ctrl+A, and then D (or just close the window)


## folders   -------------------------------------------------------------------

# should match your ID on HPC/server/garrison
self=cleverusername

# pick a fancyname
proj=fancy__games_dot_com

# use $self from above to define your working directory
basepath=/home/$self

# check them - if the $var doesnt exist they'll print empty
echo $self $proj $basepath $thisdoesntexist

# beware of undefined (empty) vars, and vars assigned to typos/nonsense/outdated data
# computer doesn't know the difference. yet.


# using basepath from above
raw=$basepath/raws/${proj}__raw
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
mkdir -p $raw $wrk $qc $filt $host $krak $mat
mkdir -p $qc/${proj}_raw $qc/${proj}_filt $qc/${proj}_raw_multi $qc/${proj}_filt_multi


## programmes etc.   -----------------------------------------------------------

# folder for your programmes - adapt as best suits you
b_path=~/bin  
mkdir -p $b_path ; cd $b_path

# first, get mamba (miniforge) and run through installation
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh

# install tools needed into fresh environments using mamba. or dont.
mamba create -n mgx -c bioconda -c conda-forge trimmomatic fastqc multiqc bowtie2 samtools hostile deacon -y   # 346MB
mamba create -n k2 -c bioconda bracken kraken2 krakentools parallel -y # >300MB

# while here, get KrakenTools for later
git clone https://github.com/jenniferlu717/KrakenTools.git

# catcher to correct missed samples

catcher (){
  local DirCheck=$1
  comm -23 \
    <( sort $mat/${proj}__samples.txt ) \
    <( ls $DirCheck | sed -E 's/_(S[0-9]*).*/_\1/g' | sort  -u)
}


## references 

# filtering & trimming - trimmomatic standard reference sequences to be removed
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


# recall we defined a $db var for databases etc.
lk $db

# decontamination - Download validated 3GB human pangenome index (version 0.13.0 or later)
deacon index fetch panhuman-1 -o $db/deacon_db

## assignment - kraken2 / Bracken
cd $db
wget https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_20260226.tar.gz

## -Xtract Ze Vucking Files (extract, gzipped, verbose, file-destination: )
tar -xzvf $db/kraken2_plusPF__langmead $db/k2_pluspf_20260226.tar.gz


## basespace   -----------------------------------------------------------------

bs=$b_path/bs

## if you don't have it, download the basepspace programme (aka bs) to $bs :
wget "https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs" -O $bs ; chmod 775 $bs

# follow instructions to complete setup:
$bs auth
# more info if you like: (press Q to exit)
$bs download -h


## activate   -----------------------------------------------------------------

mamba activate mgx


## 1 download and check  =======================================================

# follow link sent to you, and login
https://basespace.illumina.com/s/abcdefghijkl      # not a real link!

# project ID for download is in that page's URL address
# e.g. https://basespace.illumina.com/projects/123456789/about, "123456789" is the project ID.

# save your real project ID here
projectID=123456789

## download FASTQ to the folder we chose/created above - will take a while to finish (screen will protect us)
$bs download project --id $projectID --output $raw --log=$f_path/fdl.log & 


## have a lük: red = compressed
ls $raw/*/*gz
# use that to pull a sample list for constant re-use. always worth doublechecking.
ls $raw/*/*gz | sed -r 's/.*\/(.*)_L00._R._001.fastq.gz/\1/g' | sort -u > $mat/${proj}__samples.txt
  
##  tidy up - join lanes (L001, L002) and remove _L00*_R*_001 from name. 
time parallel -j 16 "cat $raw/*/{}_L00*_R1_001.fastq.gz >  ${join}/{}_R1.fastq.gz ; cat $raw/*/{}_L00*_R2_001.fastq.gz >  ${join}/{}_R2.fastq.gz" :::: $mat/${proj}__samples.txt

  
## F / M Q C    ----------------------------------------------------------------

fastqc -t 20 $raw/*fastq.gz -o $qc/${proj}_raw
multiqc $qc/${proj}_raw -o $qc/${proj}_raw_multi


# XXX.YYY.34.1 is the address for the HPC (replace XXX.YYY with our real prefix) - we use -o ProxyJump to send the request through garrison.ucc.ie

# run this command on the server (to get the correct paths etc.), then copy and paste on your local (UNIX) machine
echo "scp -o ProxyJump=${self}@garrison.ucc.ie ${self}@XXX.YYY.34.1:$qc/${proj}_raw_multi/multiqc_report.html ./Desktop/"

# in your browser, open the `multiqc_report.html` that has appeared on your desktop 


## pick a tester  ----------------------

# grep looks for the pattern "23-V" in $mat/${proj}__samples.txt and returns those lines, we send it to a new file with ">"
grep "23-V" $mat/${proj}__samples.txt > $mat/${proj}__tester.txt

# have a little lük, its just the sample IDs
head $mat/${proj}__tester.txt


## 2 trim and filter  ==========================================================

##--< ! >   MAKE SURE you check F+MQC  to set your parameters below     < ! >--

# use ILLUMINACLIP before CROP to maximise space for pattern recognition
cat $mat/${proj}__tester.txt | parallel -j 4 "trimmomatic PE \
  $raw/{}_R1.fastq.gz \
  $raw/{}_R2.fastq.gz \
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

# run FQC-MQC on the trimmed, paired data only
fastqc -t 12 $filt/*_trimm.fastq.gz -o $qc/${proj}_filt ; multiqc $qc/${proj}_filt -o $qc/${proj}_filt_multi


## 3 remove host sequences  ==========================================================
  
## tester set:
# time cat $mat/${proj}__tester.txt | parallel -j 8 "deacon filter -d \

# ~15mins
time cat $mat/${proj}__samples.txt | parallel -j 8 "deacon filter -d \
  $db/deacon_db/panhuman-1.k31w15.idx \
  $filt/{}_R1_trimm.fastq.gz \
  $filt/{}_R2_trimm.fastq.gz \
  -o $host/{}_R1_deco.fastq.gz \
  -O $host/{}_R2_deco.fastq.gz \
  --threads 4 > $host/{}_hostless.log 2>&1"
  
# need to see how that looks for the sequences  - FQC/ MQC, or grep -h "Retained" $host/*log 
sbatch $mat/${proj}__slurm__fqc20.sh $host $qc/host 20


## 4 identify  =================================================================

# activate the conda env with kraken2 and bracken installed
mamba activate k2

## check variables:
kr_db=$db/kraken2_plusPF_langmead
kr_threads=5
br_r=100      # $br_leng = match the post-host length
br_l=S
br_t=50   # counts of microbes! not threads


##  Kraken 2  -------------------------------------------------------------

for test in $(cat $mat/${proj}__tester.txt | head -n 1 );
do
  echo " + + +   Kraken2 on ${test} -  conf 0.1, min-hits 5, min-qual 20; Bracken read:100bp, count:50"
  kraken2 --db $kr_db \
      $host/${test}_R1_deco.fastq.gz \
      $host/${test}_R2_deco.fastq.gz \
      --paired \
      --threads $kr_threads \
      --confidence 0.1 \
      --gzip-compressed \
      --report-zero-counts \
      --minimum-hit-groups 5 \
      --minimum-base-quality 20 \
      --report $krak/${test}_kraken2_report \
      --unclassified-out $krak/${test}_kraken_unclass# \
      --output $krak/${test}_kraken_output  
      
      kr_stat=$?
      if [ ! $kr_stat -eq 0 ];
      then 
        echo " < ! >    sample ${test} failed Kraken2 :: $kr_stat"
      else 
        bracken -d $kr_db/ -i $krak/${test}_kraken2_report -o $krak/${test}.bracken -r $br_r -l $br_l -t $br_t &&
        echo " + + +   sample ${test} completed Kraken2/Bracken"
      fi
      
done


## combine outputs  ---   < ! >   this part unclear!   < ! >  - - -  < ! >  - - -  < ! >  - - -  < ! >  - - -  < ! >  - - -   

## combine
# -?- $b_path/KrakenTools/combine_bracken_outputs.py --files $krak/*.bracken -o $krak/${proj}__kraken2_plusPF_abundances.tsv >> $krak/${proj}_krak2_bracken.log                    
# -?- $b_path/KrakenTools/combine_kreports.py - -  definitely not what we want!

## for the taxonomy file, we first convert to MPA format (its just useful)
$b_path/KrakenTools kreport2mpa.py -r $krak/${test}_kraken_report -o $krak/${proj}__${test}_kraken_mpa
grep -h '|s_' $krak/${proj}__${test}_kraken_mpa | cut -f 1 |   sort | uniq | sed 's/|/\t/g' > $krak/${proj}__kraken2_plusPF_taxonomy.tsv


## - Exit stage   ==============================================================  
  
mkdir $mat/${proj}_output
cp $krak/${proj}__krakenStnd_abundances.tsv ${KRAK}*/${proj}__krakenStnd_taxonomy.tsv $mat/${proj}_output/

# compress all that to a single gzipped archive file
tar -czvf ${mat}/${proj}_output.tar.gz ${mat}/${proj}_output

# run:
echo "scp -i .ssh/id_file -oProxyJump=${self}@garrison.ucc.ie ${self}@XXX.YYY.34.1:${mat}/${proj}_output.tar.gz ~/Desktop/"

## now, copy, paste, and run the command printed out above! 
## follow the instructions it gives you, or record the message if something goes wrong. 

## NB: you might need to replace $proj with the fancyname you picked for your project at the beginning
## as you might not have assigned that local variable on your local machine

# should be here (or just check your desktop)
~/Desktop/${proj}.tar.gz

# uncompress it again - first go to whereever the file is located :
cd ~/Desktop
tar -xzvf ~/Desktop/${proj}.tar.gz

# if its there, you could probably also double click it...
  
