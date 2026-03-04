<br>

```Jamie.FitzGerald -a- MTU.ie```
<img src="vis/mtu.png" width="150" align="right" />    

---

<br>

## :: Species-level 16S databases for Kraken2:

Big fan of `Kraken2`(+`Bracken`!), but the existing `Silva 138` database creates issues with assignment to **species** level (`Silva` gives each species the `taxid` from it's parent genus - so `Kraken2` can only go as far as genus). `GreenGenes2` requires an even larger degree of wriggling in order to parse the database.

<br> 

Here we work around those issues for anyone working on 16S assignment:

### GreenGenes2 16S species-level database for Kraken2:

  - [__`code` & walkthrough:__](https://handibles.github.io/documents/k2db_from_gg2.html) approach and code for for making __species-level__ Kraken2 databases (v2024.09).
  - [download __subset K2 db__:](https://zenodo.org/records/17674218?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImY2NDBmM2FlLWMxYjYtNGNmMS04NGNiLTczMjAyYmE1Y2Q4OCIsImRhdGEiOnt9LCJyYW5kb20iOiI1MjlhYWYwNjNmMTg4N2U4MTI5Zjk4Y2FhMWVjNGEwNSJ9.Ulg9pB-PM9q8WQ4ie_7I9geXDFz3qtvL2sHOZbENml00II47PrRam75JuLuFNBxEZ71N4e0BPeuDl7vNKJxePw) 1.3-1.65kbp subset (331K seqs, 170MB)
  - [download __complete K2 db__:](https://zenodo.org/records/17702026?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImY1MTFjNTcwLTYyZGItNGJhZC05NzY5LWE3MGM2Y2JjNDQ4MiIsImRhdGEiOnt9LCJyYW5kb20iOiI2MGI2MDcwMzlmM2FjYTFiNmYwODYxZTVjZjY2M2FjMSJ9.qoBo92vjMaVLUDhLyHMRDoAjm1aO_VLJq_3jPrl_NCGph2L6f7klG6YZR8ejZRQvVzwFs7Go9bkBhsQ_XHtSpw) complete (21M seqs, 1.3GB)
 


### Silva 16S species-level database for Kraken2:

  - [__`code` only:__](https://handibles.github.io/documents/k2db_from_silva138.2.html) sparse code for making __species-level__ Kraken2 databases (v138.2).
  - [download __complete K2 db__:](https://zenodo.org/records/17738675?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImM4NmViOGIzLTQzNzAtNGRjMi1iNTlmLWM0MmYzNDU1YWNjMCIsImRhdGEiOnt9LCJyYW5kb20iOiI2OGM2NmU1OWEwYjg0NmUxMGMzOTg2ZWViZjRhM2M0OCJ9.rSOPiIiK8rl8Jn1t5qp_UhL0zUhO9JJqnGZ5gL1oJvNLY34Mq937KTekQtTPz7Kw7O22Z8EkgLIoOYCLXDyTVA)

<br> 

__NB:__ both `Silva` and `Greengenes2` use `taxid`s that __do not match NCBI `taxid`s__. The taxonomies (names!) are fine, and if you are not using `taxid`s, this should not matter to you at all. For `Silva 138.2`, we assign new (fake) `taxid`s to all ranks below genus (i.e. species, strains, subspecies, submarines, substrains). With `Greengenes`, this code assigns completely new (fake) `taxid`s to all ranks. 

See also a list of [other possible issues](https://handibles.github.io/documents/k2db_from_gg2.html#Appendix##Considerations) with this approach, and [feel free to list your own](https://github.com/handibles/handibles.github.io/issues), like [my concern about reference length...](...)

---

<br> 

## :: `CLI`, `M`icro`b`ial `E`cology, and `R` - `CLIMBER` guide to Microbial Ecology

Some basic steps in microbial ecology, focusing on the processing of `2ndGen` Illumina `fastq` data, into either `amplicon` (e.g. 16S) or `metagenomic` (e.g. shotgun) datasets, followed by ecology-based analysis of the communities and patterns we find in that data. Now with less emojis.

> check out [`climber`](https://handibles.github.io/documents/shotgun_assembly.html)

---

<br>

## :: [Own work](https://orcid.org/0000-0003-1060-816X)

You'd think this would be the first thing to go in, but no.

---

<br> 

### :: things to finish writing up 

#### the Centre Log-Ratio transform:

  - subsetting ALDEx2 datasets (expanded - see [here](https://github.com/ggloor/ALDEx_bioc/issues/30#issuecomment-3998022251))
  - CLR transform and pathways (_many_ one-to-many relationships)
  - ALR transform and pathways (a _single_ set of one-to-many relationships)
  - effect of Multiplicative Replacement (`zCompositions::cMultRepl`) in the CLR transform
  - effect of sequencing depth on residuals of linear modelling of CLR values
  - effect of sequencing depth on residuals - employ Lasso on CLR values?


#### Microbial Diversity:

- all the promised `R` ecology stuff
- how to choose 40 colours and live
-	subsetting databases to sequence length


#### Ecological Diversity:

- personal walkthrough of [Willis' class stuff on rethinking alpha diversity](https://www.frontiersin.org/journals/microbiology/articles/10.3389/fmicb.2019.02407/full)
-	Bray-Curtis on transformed data
-	Alpha diversity omnibus testing (KW, F, W)
-	Dirichlet Multinomial Modelling (DMM) and diversity
-	how much does Bracken affect ecological diversity? (not a huge amount)
-	toy diversity in data
-	filtering features: k & A 
-	singleton effects in diversity


#### `CLI:`

-	downloading files from RefSeq/Gene/NCBI/`entrez-direct`
-	downloading files from ENA
-	downloading files from illumina
-	renaming accessions for KMA/CCMetagen
-	hashing over dictionaries in bash for building databases (KMA/CCMetagen)
-	PLS-DA-Kfold.R

---

<br>
 
### \#thing4
It's not any sheer to put underneath with an unless  -  see with and folder. But, did and with the place of not yet although with and also?  -  making presentation un up

---
