```Jamie.FitzGerald -a- MTU.ie```
<img src="vis/mtu.png" width="150" align="center" />    

---

<br>

## Species-level 16S databases for Kraken2 

Big fan of Kraken2, but native application to 16S sequences has issues with assignment to **species** level (due to issues with the `taxid` being discarded at the species level when processed). Additionally, GG2 requires further wriggling in order to parse the database for use with it. Download database here  / follow along with the code. 

Please note [the possible issues](https://handibles.github.io/documents/k2db_from_gg2.html#Appendix##Considerations) with this approach. In particular, the taxonomies (names!) are fine, but this work uses __fake `taxid`s that do not match NCBI `taxid`s__. If you are not using `taxid`s, this should not matter at all.

GreenGenes2 and Silva are processed using similar code (GG2 has more detail):


#### built from GreenGenes2 2024.09:

  - [`code` & walkthrough:](https://handibles.github.io/documents/k2db_from_gg2.html) approach and code for for making __species-level__ Kraken2 databases.
  - [download __subset K2 db__:](https://zenodo.org/records/17674218?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImY2NDBmM2FlLWMxYjYtNGNmMS04NGNiLTczMjAyYmE1Y2Q4OCIsImRhdGEiOnt9LCJyYW5kb20iOiI1MjlhYWYwNjNmMTg4N2U4MTI5Zjk4Y2FhMWVjNGEwNSJ9.Ulg9pB-PM9q8WQ4ie_7I9geXDFz3qtvL2sHOZbENml00II47PrRam75JuLuFNBxEZ71N4e0BPeuDl7vNKJxePw) 1.3-1.65kbp subset (331K seqs, 170MB)
  - [download __complete K2 db__:](https://zenodo.org/records/17702026?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImY1MTFjNTcwLTYyZGItNGJhZC05NzY5LWE3MGM2Y2JjNDQ4MiIsImRhdGEiOnt9LCJyYW5kb20iOiI2MGI2MDcwMzlmM2FjYTFiNmYwODYxZTVjZjY2M2FjMSJ9.qoBo92vjMaVLUDhLyHMRDoAjm1aO_VLJq_3jPrl_NCGph2L6f7klG6YZR8ejZRQvVzwFs7Go9bkBhsQ_XHtSpw) complete (21M seqs, 1.3GB)
 

#### ~~built from Silva 138.2~~:

    Not yet we dont!

  - [__`code` only:__](https://handibles.github.io/documents/k2db_from_gg2.html) minimal documented code for for making __species-level__ Kraken2 databases.
  - [download __subset K2 db__:] ...
  - [download __complete K2 db__:] ...




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
