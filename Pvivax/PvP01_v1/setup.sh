#!/usr/bin/env bash

if [[ -z ${NGSENV_BASEDIR:-} ]]; then
	echo "This script needs to be run under vivaxGEN NGS-Pipeline active environment"
	exit 1
fi

echo "Entering directory: ${NGSENV_BASEDIR}"
cd ${NGSENV_BASEDIR}

LABEL=PvP01_v1
REF=PlasmoDB-50_PvivaxP01
HOSTREF=GCF_000001405.40_GRCh38.p14
REFDIR=configs/refs/${LABEL}
(	
	echo "Downloading ${REF} from PlasmoDB..."
	mkdir -p ${REFDIR}
	cd ${REFDIR}
	curl -z ${HOSTREF}_genomic.fna -O https://plasmodb.org/common/downloads/release-50/PvivaxP01/fasta/data/${REF}_Genome.fasta
)

(
	echo "Downloading host ${HOSTREF} from NCBI FTP site..."
	cd ${REFDIR}
    curl -z ${HOSTREF}_genomic.fna -O https://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Homo_sapiens/latest_assembly_versions/${HOSTREF}/${HOSTREF}_genomic.fna.gz
    echo "Decompressing host reference sequences..."
    gunzip -fk ${HOSTREF}_genomic.fna.gz
    echo "Generating YAML region file..."
    ngs-pl setup-references -n -k contaminant_regions -o contaminants.yaml -f ${HOSTREF}_genomic.fna --pattern "NC_.*" --outfasta contaminants.fasta
)

(
    echo "Concatenating parasite and host sequences..."
    cd ${REFDIR}
    cat ${REF}_Genome.fasta contaminants.fasta > ${LABEL}-GRCh38.p14.fasta
)

(
	echo "Downloading config file"
	cd configs
	curl -O https://raw.githubusercontent.com/vivaxgen/vgnpc-plasmodium-spp/main/Pvivax/${LABEL}/${LABEL}-all.yaml

	echo "Appending contaminant regions..."
	cat refs/${LABEL}/contaminants.yaml >> ${LABEL}-all.yaml
)

(
	echo "Downloading and preparing known variant from Pv4 dataset..."
	cd ${REFDIR}
	curl -O https://raw.githubusercontent.com/vivaxgen/vgnpc-plasmodium-spp/main/Pvivax/${LABEL}/known-variants.bed.gz
	mkdir known-variants
	python3 -c "import yaml; [open(f'known-variants/{reg}.bed', 'w') for reg in yaml.safe_load(open('../../${LABEL}-all.yaml'))['regions']]"
	zcat known-variants.bed.gz | awk '{print > "known-variants/" $1 ".bed"}'
	for fn in known-variants/*.bed; do echo "Processing ${fn}"; bgzip -f ${fn}; tabix ${fn}.gz; done
)

echo "Linking config.yaml..."
ln -srf configs/${LABEL}-all.yaml configs/config.yaml

echo "Indexing reference sequence"
ngs-pl initialize --target wgs

echo "Finish setting up environment"

# EOF
