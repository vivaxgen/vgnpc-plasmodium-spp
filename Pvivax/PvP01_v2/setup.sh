#!/usr/bin/env bash

if [[ -z ${NGSENV_BASEDIR:-} ]]; then
	echo "This script needs to be run under vivaxGEN NGS-Pipeline active environment"
	exit 1
fi

echo "Entering directory: ${NGSENV_BASEDIR}"
cd ${NGSENV_BASEDIR}

LABEL=PvP01_v2
REF=PlasmoDB-68_PvivaxP01
SRCDIR=Pvivax/${LABEL}
PLASMODBURL=https://plasmodb.org/common/downloads/release-68/PvivaxP01

SRC_URL=https://raw.githubusercontent.com/vivaxgen/vgnpc-plasmodium-spp/main/${SRCDIR}
REFDIR=configs/refs/${LABEL}
HOSTREF=GCF_000001405.40_GRCh38.p14

(	
	echo "Downloading ${REF} from PlasmoDB..."
	mkdir -p ${REFDIR}
	cd ${REFDIR}
	curl -z ${REF}_Genome.fasta        -O ${PLASMODBURL}/fasta/data/${REF}_Genome.fasta
	curl -z ${REF}_AnnotatedCDSs.fasta -O ${PLASMODBURL}/fasta/data/${REF}_AnnotatedCDSs.fasta
	curl -z ${REF}.gff                 -O ${PLASMODBURL}/gff/data/${REF}.gff
	ln -sr ${REF}_Genome.fasta ${LABEL}.fasta
	ln -sr ${REF}.gff ${LABEL}.gff
	ln -sr ${REF}_AnnotatedCDSs.fasta ${LABEL}_AnnotatedCDSs.fasta
)

(
	echo "Downloading host ${HOSTREF} from NCBI FTP site..."
	cd ${REFDIR}
	curl -z ${HOSTREF}_genomic.fna -O https://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Homo_sapiens/latest_assembly_versions/${HOSTREF}/${HOSTREF}_genomic.fna.gz
	echo "Decompressing host reference sequences..."
	gunzip -fk ${HOSTREF}_genomic.fna.gz
	echo "Generating YAML region file..."
	ngs-pl setup-references -n -k contaminant_regions -o contaminants.yaml -f ${HOSTREF}_genomic.fna --pattern "NC_.*" --outfasta contaminants.fasta
	rm ${HOSTREF}_genomic.fna
)

(
	echo "Concatenating parasite and host sequences..."
	cd ${REFDIR}
	cat ${REF}_Genome.fasta contaminants.fasta > ${LABEL}-GRCh38.p14.fasta
	rm contaminants.fasta
)

(
	echo "Downloading config file"
	cd configs
	curl -O ${SRC_URL}/${LABEL}-all.yaml

	echo "Appending contaminant regions..."
	cat refs/${LABEL}/contaminants.yaml >> ${LABEL}-all.yaml
)

(
	echo "Downloading and preparing known variant from Pv4 dataset..."
	cd ${REFDIR}
	curl -O ${SRC_URL}/known-variants.bed.gz
	mkdir known-variants
	python3 -c "import yaml; [open(f'known-variants/{reg}.bed', 'w') for reg in yaml.safe_load(open('../../${LABEL}-all.yaml'))['regions']]"
	zcat known-variants.bed.gz | awk '{print > "known-variants/" $1 ".bed"}'
	for fn in known-variants/*.bed; do echo "Processing ${fn}"; bgzip -f ${fn}; tabix ${fn}.gz; done
)

(
	echo "Downloading snpEff config file and preparing files for snpEff database"
	cd ${REFDIR}
	curl -O ${SRC_URL}/snpEff.config
	mkdir -p snpEff_data/${LABEL}
	ln -sr ${LABEL}.gff snpEff_data/${LABEL}/genes.gff
	ln -sr ${LABEL}.fasta snpEff_data/${LABEL}/sequences.fa
)

echo "Linking config.yaml..."
ln -srf configs/${LABEL}-all.yaml configs/config.yaml

echo "Preparing snpEff database"
ngs-pl initialize --target snpEff_db

echo "Indexing reference sequence"
ngs-pl initialize --target wgs

echo "Finish setting up environment"

# EOF
