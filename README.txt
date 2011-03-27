

# Make sure that genes without version numbers are not represented in the new gff
awk -F ',' '$4 == "" {print $3}' essentialmaster_RS.csv | tr -d "\"" | ruby -pe '$_["SNOG"] = "" if $_.match(/SNOG/)' > genes_without_version.txt

# Then remove all blank lines (I know, I know, but the one-liner was already ridiculous).

# Look for those (presumably) deleted genes in our gff:

grep -f genes_without_version.txt sn15_all_v3_genes.gff3

# Turns up two lines:
#scaffold_11	Annotation_v3	mRNA	409196	410407	.	+	.	ID=SNOR_07473.3;Name=SNOG_07473.3;Parent=SNOG_07473.3;Protein_accession=EAT84939.2;Locus_tag=SNOG_07473;Old_locus_tag=SNOG_07474;
#scaffold_6	Annotation_v3	mRNA	908719	912235	.	+	.	ID=SNOR_04517.3;Name=SNOG_04517.3;Parent=SNOG_04517.3;Protein_accession=EAT88277.2;Locus_tag=SNOG_04517;Old_locus_tag=SNOG_04518;

# Hmm... mRNA without a gene. These need to go. 

grep -vf genes_without_version.txt sn15_all_v3_genes.gff3 > tmp
mv tmp sn15_all_v3_genes.gff3

# git commit. SHA = 1312b1ddf401a3661f0fd6092d38b9d9dbae2299


# Fix up the version numbers
ruby fix_version_numbers.rb gene_names_all.txt sn15_all_v3_genes.gff3 > tmp
mv tmp sn15_all_v3_genes.gff3


