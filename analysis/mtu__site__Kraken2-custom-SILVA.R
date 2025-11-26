

    ## we probably should use SILVA_138.2_SSURef_tax_silva.fasta.gz and not the NR99 version
    # - thinking is that we can use the additional info for better classification
    # - BUT benjjneb and co. use NR99 for their NB-RDP method. should we follow suit?
    # - - prob NO, as we are not proposing a two-step solution. 
    # - - use the full set 
    # - - though note that these are not aligned


## here, download to /dl/path BEFORE R
      # 
      #     # # cd /dl/path
      #     sdb=/mnt/workspace2/jamie/ref/k2__silva138.2
      #     # mkdir -p $sdb $sdb/taxonomy $sdb/library ; cd $sdb
      #     # 
      #     # ## from https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/README.txt:
      #     # wget https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_138.2_SSURef_tax_silva.fasta.gz
      #     # 
      #     #       # "mapping of each entry in the SILVA database to a taxonomic path. Different
      #     #       # rRNA regions of the same INSDC entry (genome) may be assigned to multiple
      #     #       # paths (contaminations or micro diversity among the rRNA sequences)."
      #     # 
      #     # wget https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/taxonomy/taxmap_slv_ssu_ref_138.2.txt.gz
      #     # 
      #     #       # "Multi FASTA files of the SSU/LSU databases including the SILVA taxonomy for
      #     #       # Bacteria, Archaea and Eukaryotes in the header.
      #     #       # 
      #     #       # REMARK: The sequences in the files are NOT truncated to the effective LSU or
      #     #       # SSU genes. They contain the full entries as they have been deposited in the
      #     #       # public repositories (ENA/GenBank/DDBJ). 
      #     #       # 
      #     #       # Fasta header:
      #     #       # >accession_number.start_position.stop_position taxonomic path organism name"
      #     # 
      #     # wget https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/taxonomy/tax_slv_ssu_138.2.txt.gz
      #     # 
      #     # mv ./{SILVA,taxmap}* /mnt/workspace2/jamie/ref/k2__silva138.2/
      #     # # subset tests
      #     # gzip -cd /mnt/workspace2/jamie/ref/k2__silva138.2/SILVA_138.2_SSURef_tax_silva.fasta.gz | grep -c ">"
      #     # gzip -cd /mnt/workspace2/jamie/ref/k2__silva138.2/SILVA_138.2_SSURef_tax_silva.fasta.gz | head -50000 | gzip > /mnt/workspace2/jamie/ref/k2__silva138.2/SILVA_138.2_SSURef_tax_silva__sub50k.fasta.gz
      #     # gzip -cd ~/Downloads/SILVA_138.2_SSURef_tax_silva.fasta.gz | head -50000 | gzip > Downloads/SILVA_138.2_SSURef_tax_silva__sub50k.fasta.gz
      # 
      #     ## dataset filtering 
      #     # - benjjneb & co. eschew use of the euk stuff - so probably can do this also and remove the non-prok accessions? 
      #     # - makes a massive difference to processing Euk taxonomy if can simply drop it
      #     # - best way to subset by accession? 
      #     zgrep "Bacteria" $sdb/taxmap_slv_ssu_ref_138.2.txt.gz | gzip > $sdb/s138.2_tax.tsv.gz        # 1,982,812
      # 
      #     #faster to build with Euks? Only approx 10% saved
      #     
      #     zcat $sdb/s138.2_tax.tsv.gz | cut -f 1 | sort -u > $sdb/silva138.2_prokIDS.txt
      #     less $sdb/silva138.2_prokIDS.txt
      #     less $sdb/SILVA_138.2_SSURef_tax_silva.fasta.gz
      #     
      #       ## impossssssibly slow
      #         # parallel --keep-order -j 15 "zgrep {} $sdb/SILVA_138.2_SSURef_tax_silva.fasta.gz | sed 's/>//g' >> $sdb/silva138.2_prokACC.txt" :::: $sdb/silva138.2_prokIDS.txt
      #         # seqtk subseq \
      #         #   $sdb/SILVA_138.2_SSURef_tax_silva.fasta.gz \
      #         #   $sdb/silva138.2_prokACC.txt \
      #         #     > $sdb/silva138.2_prokIDS.fna.gz
      #         
      #         # ## not fast either!  
      #         # time seqkit grep -nrf \
      #         #   $sdb/silva138.2_prokIDS.txt \
      #         #   $sdb/SILVA_138.2_SSURef_tax_silva.fasta.gz \
      #         #     > $sdb/silva138.2_prokACC.fna.gz
      #     
    


##   get sequences   =========================================================

rm(list=ls()) ; gc() 

# attributes, names, length, hist etc. for DNA work
library("Biostrings")
library("parallel")
# n_cores <- 15
# path <- "/dl/path"
# path <- "/mnt/workspace2/jamie/ref/k2__silva138.2"
# length(seqs <- readDNAStringSet( filepath = paste0(path, "/SILVA_138.2_SSURef_tax_silva.fasta.gz" )))  #   2,224,690
n_cores <- 6
path <- "~/Downloads"
length(seqs <- DNAStringSet( readRNAStringSet( filepath = paste0(path, "/SILVA_138.2_SSURef_tax_silva__sub50k.fasta.gz" ))) )  # 2437...   
head(tax <- read.table(paste0( path, "/taxmap_slv_ssu_ref_138.2.txt.gz"), header = TRUE, sep = "\t", nrows = 10000, quote = ""))   # 2,224,691 lines

# silva has an existing taxon-rank map. 
ranks <- read.table(paste0( path, "/tax_slv_ssu_138.2.txt.gz"), header = FALSE, sep = "\t", quote = "")   # 2,224,691 lines
colnames(ranks) <- c("taxon", "taxid", "rank", "comment", "release")
head(ranks)


##   make taxonomy   =========================================================

# rank_is <- c( "d__" = "domain", "p__" = "phylum", 
#               "c__" = "class", "o__" = "order", 
#               "f__" = "family", "g__" = "genus",
#               "s__" = "species")      
rank_is <- c( "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10","V11",
              "V12", "V13","V14","V15","V16","V17","V18","V19","V20","V21")
names(rank_is) <- rank_is

# 12! ~~3~ taxonomic dummy levels added here for fun
# possibly thing to do is subset to prokarya, but...
tax_dummies <- 14  
taxs <- as.data.frame(do.call("rbind", mclapply( tax$path, function(aa){  # aa <- "Eukaryota;SAR;Alveolata;Apicomplexa;Aconoidasida;Haemosporoidia;Plasmodium;"
  bb <- unlist(strsplit( aa, split = "\\;"))[1:(7+tax_dummies)]
  bb
}, mc.cores = n_cores, mc.cleanup = TRUE)), stringsAsFactors = FALSE)

# colnames(taxs) <- rank_is          # # ????? 

taxs$V7 <- gsub( " ", "_", tax$organism_name )
taxs$taxid <- tax$taxid
taxs$header <- tax$primaryAccession
# rownames(taxs) <- taxs$header       ## this not working either, as accessions duplicated

head(taxs)


## crucial - accession - taxon map. That said, SILVA provides this out the gate with primaryAccession
taxs$effective_taxon <- unlist( mclapply( 1:nrow(taxs), function(aa){      # aa <- 40
  bb <- taxs[ aa, 1:(7+tax_dummies) ]
  bb[ max(which( !( grepl("__$", bb, perl = TRUE) | is.na(bb) ) ))  ]
},  mc.cores = n_cores, mc.cleanup = TRUE))

uniq_tax <- apply( taxs[, 1:(7+tax_dummies)], 2, function(aa){
  bb <- aa[ !( is.na(aa) ) ]
  sort(unique(unlist(bb)))
})
dim(uniq_tax)


str(taxs)
str(uniq_tax)


## subset to seqs in 1.0-1.3kbp range    ====================================

s_widths <- width(seqs)    #  subset :: 569 - 1180 - 2260
# 2363... 
length(seqs_w <- seqs[ s_widths > 1000 & s_widths < 1650 ])
# save the names before replacing
attributes(seqs_w)$orig_name <- names(seqs_w)
names(seqs_w) <- unname( sapply( names(seqs_w), function(aa){ strsplit(aa, "\\.")[[1]][[1]] }))
length( usable_seqs <- seqs_w[ names(seqs_w) %in% taxs$header ] )


## taxid proto   -----------------------------------------------------------

## root is 1, so floop/domains start from 2...
floop <- 13370000    

      ## hereditary GG2 version
          # ## counter with universal assignment to var. no counting in parallel!
          # taxid_proto <- lapply( names(uniq_tax)[ 
          #   sapply( uniq_tax, function(aa){ !identical( aa, character(0)) })
          # ], function(aa){   
          #   # if( aa == "domain"){ floop <<- 1 }   # ?? 
          #   bb <- uniq_tax[ aa ][[1]]
          #   cc <- (floop+1):(floop+length(bb))    #  stringr::str_pad( (floop+1):(floop+length(bb)), width = 7, pad = "0" )
          #   floop <<- floop + length(cc)
          #   list( "name_txt" = bb, "taxid" = cc)
          # })

## counter with universal assignment to var. no counting in parallel!
taxid_proto <- lapply( names(uniq_tax)[
  sapply( uniq_tax, function(aa){ !identical( aa, character(0)) })   ## aa <- "V1"
], function(aa){
  # if( aa == "domain"){ floop <<- 1 }   # ??
  bb <- uniq_tax[ aa ][[1]]
  # essentially same idea, we just copy-assign everything available first. 
  # would be nice to be more efficient, but cant see how given lack of structure in taxs
  # cc <- taxs[ sapply( bb, function(aaa){ match(aaa, uniq[ , aa ]) }) , "taxid" ] 
  cc <- taxs[ sapply( bb, function(aaa){ ranks[ grep( paste0(bb, ";$"), ranks$taxon, perl = TRUE ) , 2] }) , "taxid" ]

  cc_flooplength <- floop+sum(is.na( cc))
  if( cc_flooplength > 0 ){
    cc[ !(sapply( cc, is.numeric)) ] <- (floop+1):cc_flooplength
    floop <<- cc_flooplength
  }
  list( "name_txt" = bb, "taxid" = cc)
})
names(taxid_proto) <- rank_is


    ## we have misunderstodd - they have ALREADY been mapped to overlapping taxids. that is, each bacterial entry should now have the samne value twice

    ## that said, ERROR :: the taxids are COMPLETLEY WRONG!



## no mult lookups - decide rank ahead of time, use rank_is & grep through that alone (e.g. based on prefix)
              # identify <- function(aa){
              #   bb_rank <- rank_is[ gsub("__.*", "__", aa )]                           # aa <- "g__GWA2-37-10"
              #   if( aa %in% taxid_proto[[bb_rank]][[1]] ){
              #     taxid_proto[[bb_rank]][[2]][ match(aa, taxid_proto[[bb_rank]][[1]] ) ]
              #   }else{
              #     print(paste0("taxon ", aa, " wasn't in the taxid map"))
              #   }
              # }
identify <- function(aa){
  
  aa %in% taxid_proto        # aa <- "Plasmodium_malariae"
  
  if( aa %in% taxid_proto[[bb_rank]][[1]] ){
    taxid_proto[[bb_rank]][[2]][ match(aa, taxid_proto[[bb_rank]][[1]] ) ]
  }else{
    print(paste0("taxon ", aa, " wasn't in the taxid map"))
  }
}

identify_parent <- function(aa){   # aa <- "g__UBA6532"         aa <- "s__"
  if( grepl("d__", aa)){
    "1"                      # snoonos get unos
  }else{
    bb_rank <- rank_is[ gsub("__.*", "__", aa) ]
    cc <- taxs[ match(aa, taxs[ , bb_rank ]) , ( which( names(taxs) == bb_rank) -1) ] 
    identify( cc )
  }   
}


## names proto   -----------------------------------------------------------

names_proto <- data.frame(
  "tax_id" = unlist( mclapply( unlist( uniq_tax), identify, mc.cores = n_cores, mc.cleanup = TRUE )),
  "name_txt" = unlist( uniq_tax),
  "unique name" = "",                   # safety net ignored.
  "name class" = "scientific name",     # synonym, common name, ... lower case!
  stringsAsFactors = FALSE
)


## proto nodes   -----------------------------------------------------------

nodes_proto <- data.frame(
  "tax_id" = unlist(mclapply( names_proto$name_txt, identify, mc.cores = n_cores, mc.cleanup = TRUE )),                                           ## parallel
  "parent tax_id" = unlist( mclapply( names_proto$name_txt, identify_parent, mc.cores = n_cores, mc.cleanup = TRUE )),                             ## parallel
  "rank" = rank_is[ unlist( mclapply( names_proto$name_txt, function(aa){ gsub("(^\\w__).*", "\\1", aa) }, mc.cores = n_cores, mc.cleanup = TRUE )) ] ,     ## parallel
  "embl code" = "",                  # no one seems to know about this one
  "division id" = 0,                  # 0 = Bacteria (but also apparently Archaea...)
  "inherited div flag" = 1,                            
  "genetic code id" = 11,				      # 11 = Bact/Arch/plastid
  "inherited GC" = 1,             		# 1 if node inherits genetic code from parent
  "mitochondrial genetic code" = 0,		# see gencode.dmp file
  "inherited MGC" = 1,                # 1 if node inherits mitochondrial gencode from parent
  "GenBank hidden" = 0,               # 1 if name is suppressed in GenBank entry lineage
  "hidden subtree root" = 0,          # 1 if this subtree has no sequence data yet
  "comments" = "")


## rooting the tree - must be appended to :
# - nodes.dmp (note 8,0,1, instead of 11,1,0)
nodes_proto <- rbind( 
  c( "1","1","no rank","","8","0","1","0","0","0","0","0",""),
  nodes_proto
)
# - and names.dmp
names_proto <- rbind( 
  c( "1", "all", "all", "synonym"),
  c( "1", "root", "root", "scientific name"),
  names_proto
)


## modify the seq headers    =================================================

names(usable_seqs) <- paste0(
  names(usable_seqs), 
  "|kraken:taxid|", 
  unlist( mclapply( taxs[ names(usable_seqs) , "effective_taxon"], identify, mc.cores = n_cores, mc.cleanup = TRUE )
  )
)


##   out that!   ---------------------------------------------------------------

# head( nodes_proto )
# head( names_proto )
# head( usable_seqs )

## note sep for nodes & names
writeXStringSet( usable_seqs, filepath = paste0( path, "/gg2_2024.09__FullLength313k__seqs.fna"), 
                 compress = FALSE, format = "fasta" )

write.table(names_proto, file = paste0( path, "/gg2_2024.09__FullLength313k__names.dmp"), 
            sep = '\t|\t', col.names = FALSE, row.names = FALSE, quote = FALSE)
write.table(nodes_proto, file = paste0( path, "/gg2_2024.09__FullLength313k__nodes.dmp"), 
            sep = '\t|\t', col.names = FALSE, row.names = FALSE, quote = FALSE)
