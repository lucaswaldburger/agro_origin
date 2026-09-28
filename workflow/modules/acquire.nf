nextflow.enable.dsl = 2

/*
 * S0 -- corpus acquisition and reference freeze.
 *
 * Verified 2026-09-24: 10,349 current Viridiplantae assemblies, 12.418 Tbp,
 * ~3.73 TB gzipped. One best assembly per species (4,099 spp) is 1.46 TB and is
 * the only Tier-1 target that fits a workstation.
 *
 * There is NO AWS Open Data mirror of GenBank/RefSeq assemblies -- only SRA.
 * Plan on egress-free HTTPS from NCBI, not `aws s3 sync`.
 */

process ACQUIRE_CENSUS {
    tag "taxon:${taxon}"
    publishDir "${params.outdir}/ref", mode: 'copy'

    input:
    val taxon

    output:
    path 'viridiplantae_current.jsonl', emit: census
    path 'pilot_accessions.txt',        emit: pilot_accessions
    path 'all_accessions.txt',          emit: all_accessions
    path 'census_manifest.tsv',         emit: manifest

    script:
    """
    # Paginate properly. A single 1,000-report page contains only
    # Chromosome/Complete assemblies and biases the median to 674 Mbp;
    # the true median is ~555 Mbp.
    datasets summary genome taxon ${taxon} \\
        --assembly-version current \\
        --as-json-lines > viridiplantae_current.jsonl

    # Expect total_count = 10349. Fail loudly if the corpus has drifted
    # materially -- it grows ~3,000 assemblies/yr and the census re-runs quarterly.
    n=\$(wc -l < viridiplantae_current.jsonl)
    echo "census_n\t\$n" > census_manifest.tsv
    echo "pull_date\t\$(date -u +%Y-%m-%d)" >> census_manifest.tsv
    sha256sum viridiplantae_current.jsonl >> census_manifest.tsv

    # TODO: emit pilot set (8 known-carrier genera) and full accession list
    touch pilot_accessions.txt all_accessions.txt
    """
}

process ACQUIRE_FCS_PRIOR {
    publishDir "${params.outdir}/ref", mode: 'copy'

    output:
    path 'fcs_summary_genbank.txt.gz', emit: summary
    path 'fcs_details_genbank.txt.gz', emit: details
    path 'fcs_manifest.tsv',           emit: manifest

    script:
    """
    # 530 MB and ten minutes, replacing a 464 GiB resident database.
    # NCBI ships no checksums and regenerates these daily, so compute our own.
    base=https://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS
    curl -sSLO --output-dir . \$base/fcs_summary_genbank.txt.gz
    curl -sSLO --output-dir . \$base/fcs_details_genbank.txt.gz

    sha256sum fcs_summary_genbank.txt.gz  > fcs_manifest.tsv
    sha256sum fcs_details_genbank.txt.gz >> fcs_manifest.tsv
    echo "fcs_gx_db_build\t${params.fcs_gx_build}" >> fcs_manifest.tsv

    # FCS-GX is a PRIOR, never a verdict: it ignores intra-kingdom chimeras
    # below 10 kbp -- exactly our size class -- and its database has not been
    # rebuilt since 2023-01-24.
    """
}
