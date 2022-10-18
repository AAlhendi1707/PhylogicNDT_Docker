args <- commandArgs(TRUE)
path <- as.character(args[1])
input.mut.ccfs <-as.character(args[2])

##Read files names
files <- list.files(path=path, pattern="*.snv.indel.txt")
print(sprintf("## Files to be merged are: ##"))
print(files)
print(paste0("############################"))
 
# using perl to manpulate file names by trimming file extension
labs <- paste("", gsub("\\.snv.indel.txt", "", files, perl=TRUE), sep="")
 
library(dplyr);library(data.table)

cov <- list()
for (i in labs) {
filepath <- file.path(path,paste(i,".snv.indel.txt",sep=""))
datat <- fread(filepath)
datat <- c(Barcode=i, datat)
cov[[i]] <- datat
}

 
## construct one data frame from list of data.frames using reduce function
df1 <- rbindlist(cov, use.names=TRUE, fill=TRUE, idcol=FALSE)
fwrite(df1, "combined.snv.indel.maf", sep="\t")

# reading mut ccf 
df2 <- fread(input.mut.ccfs)

## capture the columns order in origional mutations file
mutation.columns <- colnames(df2)

## creating mutation id
df1$mutation_id <- paste(df1$Chromosome, df1$Start_position, df1$Reference_Allele, df1$Tumor_Seq_Allele2, sep=":")
df1 <- df1 %>% select(mutation_id, Protein_change) %>% rename(aachange=Protein_change) %>% unique()
df2$mutation_id <- paste(df2$Chromosome, df2$Start_position, df2$Reference_Allele, df2$Tumor_Seq_Allele, sep=":")

## adding protein annotation by merge df1 and df2
dftemp <- merge(df2, df1, by.x="mutation_id", by.y="mutation_id", all.x=TRUE)
dftemp$Protein_change <- dftemp$aachange
df.final <- dftemp %>% select(mutation.columns)

## writing updated version
fwrite(df.final, input.mut.ccfs, sep="\t")
