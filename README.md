<br>

```Jamie.FitzGerald -a- MTU.ie```
<img src="vis/mtu.png" width="150" align="right" />    

---

<br>

## Species-level 16S databases for Kraken2 

Big fan of `Kraken2`(+`Bracken`!), but the existing `Silva 138` database creates issues with assignment to **species** level (`Silva` gives each species the `taxid` from it's parent genus - so `Kraken2` can only go as far as genus). `GreenGenes2` requires an even larger degree of wriggling in order to parse the database.

<br> 

Here we work around those issues for anyone working on 16S assignment:

### GreenGenes2 16S species-level database for Kraken2:

  - [__`code` & walkthrough:__](https://handibles.github.io/documents/k2db_from_gg2.html) approach and code for for making __species-level__ Kraken2 databases (v2024.09).
  - [download __subset K2 db__:](https://zenodo.org/records/17674218?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImY2NDBmM2FlLWMxYjYtNGNmMS04NGNiLTczMjAyYmE1Y2Q4OCIsImRhdGEiOnt9LCJyYW5kb20iOiI1MjlhYWYwNjNmMTg4N2U4MTI5Zjk4Y2FhMWVjNGEwNSJ9.Ulg9pB-PM9q8WQ4ie_7I9geXDFz3qtvL2sHOZbENml00II47PrRam75JuLuFNBxEZ71N4e0BPeuDl7vNKJxePw) 1.3-1.65kbp subset (331K seqs, 170MB)
  - [download __complete K2 db__:](https://zenodo.org/records/17702026?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImY1MTFjNTcwLTYyZGItNGJhZC05NzY5LWE3MGM2Y2JjNDQ4MiIsImRhdGEiOnt9LCJyYW5kb20iOiI2MGI2MDcwMzlmM2FjYTFiNmYwODYxZTVjZjY2M2FjMSJ9.qoBo92vjMaVLUDhLyHMRDoAjm1aO_VLJq_3jPrl_NCGph2L6f7klG6YZR8ejZRQvVzwFs7Go9bkBhsQ_XHtSpw) complete (21M seqs, 1.3GB)
 

### Silva 16S species-level database for Kraken2:

  - [__`code` only:__](https://handibles.github.io/documents/k2db_from_silva138.2.html) sparse code for making __species-level__ Kraken2 databases (v138.2).
  - ~~[download __complete K2 db__:]()~~ ...not yet you dont

<br> 

__NB:__ both `Silva` and `Greengenes2` use `taxid`s that __do not match NCBI `taxid`s__. The taxonomies (names!) are fine, and if you are not using `taxid`s, this should not matter to you at all. For `Silva 138.2`, we assign new (fake) `taxid`s to all ranks below genus (i.e. species, strains, subspecies, submarines, substrains). With `Greengenes`, this code assigns completely new (fake) `taxid`s. 

See also a list of [other possible issues](https://handibles.github.io/documents/k2db_from_gg2.html#Appendix##Considerations) with this approach, and [feel free to list your own](https://github.com/handibles/handibles.github.io/issues).


---

## `CLI`, `M`icro`b`ial `E`cology, and `R` - `CLIMBER` guide to Microbial Ecology

Some basic steps in microbial ecology, focusing on the processing of `2ndGen` Illumina `fastq` data, into either `amplicon` (e.g. 16S) or `metagenomic` (e.g. shotgun) datasets, followed by ecology-based analysis of the communities and patterns we find in that data. Now with less emojis.

> check out [`climber`](https://handibles.github.io/documents/shotgun_assembly.html)

---

## \#thing3 
Did and with the place of not yet although with and also  -  making presentation un up

---

## \#thing4
It's not any sheer to put underneath with an unless  -  see with and folder

---
