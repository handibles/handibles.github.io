---
title: "MGX speed run"
subtitle: "climber `v0.4`, `r format(Sys.time(), '%b %Y')` - [`jfg`](mailto:jamie.fitzgerald@ucc.ie)"
output:
  powerpoint_presentation:

knit: (function(inputFile, encoding) { rmarkdown::render(inputFile, encoding=encoding, output_file='../documents/climber.pptx') })
---
<!-- theme: beam -->
<!-- paginate: true -->
<!-- _class: lead -->
  
  # MGX Speed Run
  
  ## A shotgun short-read metagenomics pipeline (climber v0.4, Jun 2026)
  
  ### download → trim → decontaminate → identify
  
  ---
  
  # The Pipeline at a Glance
  
  | Step | Tool(s) | Purpose |
  |---|---|---|
  | 0. Setup | `screen`, `mamba` | Stable sessions, install tools & databases |
  | 1. Download | `bs` (BaseSpace) + `FastQC`/`MultiQC` | Get raw FASTQs & check quality |
  | 2. Trim & filter | `Trimmomatic` | Remove adapters, crop bad bases, check again |
  | 3. Decontaminate | `Deacon` | Remove host (human) DNA, check again |
  | 4. Identify | `Kraken2` + `Bracken` | Classify reads → abundance table |
  
  **Golden rule:** *check your output after every step.*
  
  ---
  
  # Step 0a — Work in a `screen` Session
  
  ```bash
screen -RD femmebio   # start or reconnect
# Ctrl+A then D to detach
```

- Keeps your job running even if you disconnect or crash
- Return to the same window anytime and continue

---
  
  # Step 0b — Local Variables Keep Things Tidy
  
  Assign short nicknames to long paths; update once, use everywhere:
  
  ```bash
self=cleverusername          # your HPC ID
proj=fancy__games_dot_com     # project name
basepath=/home/$self

raw=$basepath/raws/${proj}__raw     qc=$wrk/1__qc
join=$basepath/raws/${proj}__join   filt=$wrk/2__filt
wrk=$basepath/work/$proj            host=$wrk/3__deacon
mat=$wrk/Materials                  krak=$wrk/4__krak2
db=$basepath/db

mkdir -p $raw $join $wrk $qc $filt $host $krak $mat
```

- Refer to them as `$self`, `$proj`, `$basepath`...
- Beware: undefined or misspelled variables are silently empty — always `echo` to check

---
  
  # Step 0c — Install Tools & Databases
  
  `mamba` (fast `conda`) creates isolated environments:
  
  ```bash
mamba create -n mgx -c bioconda -c conda-forge trimmomatic fastqc multiqc deacon -y
mamba create -n k2 -c bioconda bracken kraken2 krakentools parallel -y
git clone https://github.com/jenniferlu717/KrakenTools.git
```

One-time downloads (stored in `$db`):
  
  - **Deacon index:** validated ~3 GB human pangenome — `deacon index fetch panhuman-1`
- **Kraken2/Bracken DB:** pre-built PlusPF (125 bp) from the Langmead group — 100+ GB, slow download
- **Adapter reference file** (TruSeq/Nextera transposase + PCR primer sequences) for Trimmomatic

Activate before use: `mamba activate mgx` — or tools appear "not installed".

---
  
  # Step 0d — Write Your Own Checker: `catcher`
  
  Compares a folder's samples against your sample list and reports missing ones:

```bash
catcher (){
  comm -23 \
    <( sort $mat/${proj}__samples.txt ) \
    <( ls $1 | sed -E 's/_(S[0-9]*).*/_\1/g' | sort -u )
}
catcher $join   # downloads complete? should return nothing
catcher $filt   # filter failures? rerun just these samples
```

Use it after every step to find and re-submit failures.

---

# Step 1a — Download from BaseSpace

- Follow the sequencing run link → the **project ID is in the page URL**
- Download with the `bs` CLI, then merge lanes per sample:

```bash
$bs download project --id $projectID --output $raw --log=fdl.log &

# build the reusable sample list
ls $raw/*/*gz | sed -r 's/.*\/(.*)_L00._R._001.fastq.gz/\1/g' \
  | sort -u > $mat/${proj}__samples.txt

# join lanes (L001, L002...) into single R1/R2 per sample
parallel -j 16 "cat $raw/*/{}_L00*_R1_001.fastq.gz > ${join}/{}_R1.fastq.gz ;
               cat $raw/*/{}_L00*_R2_001.fastq.gz > ${join}/{}_R2.fastq.gz" \
  :::: $mat/${proj}__samples.txt
```

---

# Step 1b — Quality Check: FastQC + MultiQC

```bash
fastqc -t 15 $join/*fastq.gz -o $qc/${proj}_join
multiqc $qc/${proj}_join -o $qc/${proj}_join_multi
```

- `FastQC` = one report per sample; `MultiQC` combines them all
- Copy `multiqc_report.html` to your desktop to view
- **Focus on "Per Base Sequence Content"** across several samples

---

# Step 1c — Reading the QC Plots

**Healthy sample:** smooth, separated lines
- Balanced community DNA sampling separates by GC content (~40–60%) — good!
- But reads always **degrade at the very start and end** → we always trim both

**Jagged/erratic lines:**
- Too few reads to sample all positions evenly
- The 5′ end is dominated by the **synthetic adapter** (identical bases at the same position)

**Negative controls *should* look like this** — the less DNA, the better!

**Adapter Content plot:** adapters appear from ~30 bp (short inserts) or ~100 bp (longer inserts) — this is exactly what Trimmomatic must remove.

---

# Step 1d — Pick Test Samples First

Don't test on 300+ samples. Choose a representative subset:
  
  ```bash
grep "23-V" $mat/${proj}__samples.txt > $mat/${proj}__tester.txt
test=$( head -n 1 $mat/${proj}__tester.txt )
```

- Here: volunteer 23 (vaginal + faecal, 2 timepoints) = 4 IDs = 8 FASTQ files
- Iterate fast on the subset, then scale up to the full sample list

---
  
  # Step 2a — Trim & Filter with Trimmomatic
  
  ```bash
trimmomatic PE R1 R2 out_R1 out_R1_unpaired out_R2 out_R2_unpaired \
ILLUMINACLIP:fqc_trimmo_ill_ref.fa:2:30:10:5 \
SLIDINGWINDOW:6:15 \
CROP:105 \
HEADCROP:19 \
MINLEN:50 \
-threads 4
```

- `ILLUMINACLIP` — remove adapter sequences (set parameters from your QC!)
- `SLIDINGWINDOW:6:15` — rolling quality filter
- `CROP` / `HEADCROP` — cut fixed ends (here ~19 bp from 5′, crop to 105 bp)
- `MINLEN:50` — discard reads that get too short
- This throws away >⅓ of the data before you even start — brave face

---
  
  # Step 2b — Check the Trimming (Always)
  
  Rerun the same FastQC/MultiQC workflow on trimmed files:
  
  - **Per-base composition:** should now be stable, homogeneous grey
- **Adapter content:** should be absent
- **Read counts per sample:** compare with raw counts
- Separate sample types (faecal vs vaginal) may warrant different trim parameters

```bash
catcher $qc/${proj}_filt   # find failures, rerun just those:
for rr in $( catcher $qc/${proj}_filt ); do
sbatch ${proj}__slurm__trimmo4.sh $rr $join $filt
done
```

Keep solving until clean.

---
  
  # Step 3 — Remove Host DNA with Deacon
  
  - `Deacon` uses **minimisers** (rare k-mer-derived patterns) to rapidly detect and filter host DNA
- Runs on the pre-built human pangenome index (~15 min for this dataset)

```bash
deacon filter -d $db/deacon_db/panhuman-1.k31w15.idx \
${sample}_R1_trimm.fastq.gz ${sample}_R2_trimm.fastq.gz \
-o ${sample}_R1_deco.fastq.gz -O ${sample}_R2_deco.fastq.gz \
--threads 4
```

**Check the result:**
  
  ```bash
grep -h "Retained" $host/*log
```

- Typical: keep ~95% of gut reads, but only **3–5% of vaginal reads** (< 1M reads/sample)
- Massive host removal can expose problems in the remaining microbial data — QC again
- Consider validating with a second, alignment-based method (e.g. `bowtie2`)

---
  
  # Step 4a — Identify Taxa: Kraken2 + Bracken
  
  **Design question first:** do you care about genomes, communities (metagenomes), or genes/pathways? Here we assume **metagenomics**.

- `Kraken2`: matches **k-mers** in each read against a microbial database → a "best match" per read. Very fast (3–10 min/sample), but only best-match
- `Bracken`: statistically estimates the **true community composition** from Kraken2's report — abundance table of taxa × samples

Key parameters:

```bash
kraken2 --db $kr_db --paired --threads 5 \
  --confidence 0.1 --memory-mapping --gzip-compressed \
  --report-zero-counts --minimum-hit-groups 5 --minimum-base-quality 20 \
  --report ${sample}_kraken2_report

bracken -d $kr_db/ -i ${sample}_kraken2_report -o ${sample}.bracken \
  -r 100 -l S -t 50    # read length must match post-trim length
```

DB is 100+ GB — use `--memory-mapping` (and `vmtouch`) to avoid out-of-memory errors.

---

# Step 4b — Combine into a Feature Table

Use `KrakenTools` (Jennifer Lu) to merge per-sample outputs:

```bash
# abundance table: taxa x samples
combine_kreports.py -r $krak/*_bracken_species \
  -o ${proj}__kraken2_plusPF_abundances.tsv

# taxonomy table for easier exploration
kreport2mpa.py -r abundances.tsv -o kraken2_mpa
grep -h '|s_' kraken2_mpa | cut -f1 | sort | uniq | sed 's/|/\t/g' \
  > ${proj}__kraken2_plusPF_taxonomy.tsv
```

Output = one abundance table + one taxonomy table, ready for `R`, Excel, or GraphPad.

---

# Exit Stage Left — Get Results Home

```bash
tar -czvf ${proj}_output.tar.gz ${proj}_output
```

Copy to your local machine with `scp`:

```text
scp  -i .ssh/id_file  -oProxyJump=user@garrison.ucc.ie \
     user@XXX.YYY.34.1:/path/to/${proj}_output.tar.gz  ~/Desktop/
```

1. `scp` = secure copy (ssh + cp)
2. `-i` — your authentication key (not always needed)
3. `-oProxyJump` — route through the gateway server for security
4. user + IP + path of the file being sent
5. destination (run this on your **local** computer)

Then `tar -xzvf ${proj}_output.tar.gz` and analyse.

---

# Key Takeaways

1. **`screen` everything** — protect long jobs from disconnects
2. **Local variables** for tidy, updatable paths
3. **Download → trim → decontaminate → identify** — each with a check
4. **QC after every step** — FastQC/MultiQC + `catcher` for missing samples
5. **Test on a subset** before scaling to all samples
6. Trimmomatic parameters are **chosen from your QC plots**, not guessed
7. Expect to lose most vaginal reads to host DNA removal — that's normal
8. Kraken2 finds best matches; **Bracken estimates the community**