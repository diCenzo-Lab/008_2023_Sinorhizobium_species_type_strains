# Make directories
mkdir Genome_files/
mkdir Genome_files_input/
mkdir Reannotate_genomes/
mkdir FastANI_output/
mkdir Phylogeny/

# Download genomes
perl Scripts/parseGenomeList.pl Input_files/Sinorhizobium_Ensifer_type_strains.txt # Parse the NCBI genome table to get info to download genomes
perl Scripts/downloadGenomes.pl Input_files/genomeList.txt # Download the genomes of interest
cat Input_files/genomeList.txt Input_files/new_genomes.txt > temp.txt
mv temp.txt Input_files/genomeList.txt
sort -u Input_files/genomeList.txt > temp.txt
mv temp.txt Input_files/genomeList.txt
cp ../Sinorhizobium_garamanticum_LMG_24692/pgap_annotation/output/annot.fna Genome_files/Sinorhizobium_garamanticum_LMG_24692.fna
cp ../Sinorhizobium_numidicum_CIP_109850/pgap_annotation/output/annot.fna Genome_files/Sinorhizobium_numidicum_CIP_109850.fna
cp ../Sinorhizobium_numidicum_LMG_27396/pgap_annotation/output/annot.fna Genome_files/Sinorhizobium_numidicum_LMG_27396.fna

# Calculate ANI
find Genome_files/*.fna > Input_files/genomePaths.txt # Get the genome paths
fastANI -q Genome_files/Sinorhizobium_garamanticum_LMG_24692.fna --rl Input_files/genomePaths.txt -o FastANI_output/Sinorhizobium_garamanticum_LMG_24692_fastani_output.txt
fastANI -q Genome_files/Sinorhizobium_numidicum_CIP_109850.fna --rl Input_files/genomePaths.txt -o FastANI_output/Sinorhizobium_numidicum_CIP_109850_fastani_output.txt
fastANI -q Genome_files/Sinorhizobium_numidicum_LMG_27396.fna --rl Input_files/genomePaths.txt -o FastANI_output/Sinorhizobium_numidicum_LMG_27396_fastani_output.txt

# Reannotate genomes
mv Genome_files/* Genome_files_input/
perl Scripts/runProkka.pl Input_files/genomeList.txt # Run prokka to annotate the genomes
perl Scripts/moveGenomes.pl Input_files/genomeList.txt # Collect important reannotated genome files

# Create phylogeny
roary -p 16 -f Roary_output -e -i 80 -g 150000 Genome_files/*.gff # Run roary
trimal -in Roary_output/core_gene_alignment.aln -out core_gene_alignment_trimmed.aln -fasta -automated1 # Trim the alignment made by Roary
mv core_gene_alignment_trimmed.aln Phylogeny/
cd Phylogeny/
raxmlHPC-HYBRID-AVX2 -T 16 -s core_gene_alignment_trimmed.aln -N 100 -n core_gene_phylogeny -f a -p 12345 -x 12345 -m GTRCAT
cd ../

# Calculate AAI
mkdir tmp/ # Make directory
comparem aai_wf -e 1e-12 -p 40.0 -a 70.0 --sensitive --tmp_dir tmp/ --file_ext fna -c 16 Genome_files_input/ CompareM_output/ # Run comparem
