export SINGULARITYENV_PREPEND_PATH=/appl/soft/bio/samtools/gcc_9.1.0/0.1.19

##cram to bam, assuming each cram is placed in its own directory eg: sample/sample.cram
cd ${sample}
samtools view -bh -@10 -T UU_Cfam_GSD_1.0_ROSY.fa ${sample}.cram chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chr30 chr31 chr32 chr33 chr34 chr35 chr36 chr37 chr38 chrX chrM chrY_NC_051844.1 chrY_unplaced_NW_024010443.1 chrY_unplaced_NW_024010444.1 > ${sample}.bam 
samtools index ${sample}.bam

##config manta
/path/to/manta-1.6.0/bin/configManta.py --bam ${sample}.bam --referenceFasta UU_Cfam_GSD_1.0_ROSY.fa --runDir `pwd` --callRegions /path/to/manta.bed.gz

###create commands to execute in parallel on one sample
echo "/path/to/delly/src/delly call -t ALL -g UU_Cfam_GSD_1.0_ROSY.fa -o ${sample}_S11.bcf ${sample}.bam" >> ${sample}_parallel_commands_list.sh
echo "singularity_wrapper exec --bind /appl/soft:/appl/soft /path/to/tjbsve.sif /software/SVE/scripts/variant_processor.py -v -r UU_Cfam_GSD_1.0_ROSY.svedb.fa -b ${sample}.bam  -o ${sample} -L 151 -D 25 -s hydra" >> ${sample}_parallel_commands_list.sh
echo "singularity_wrapper exec --bind /appl/soft:/appl/soft /path/to/tjbsve.sif /software/SVE/scripts/variant_processor.py -v -r UU_Cfam_GSD_1.0_ROSY.svedb.fa -b ${sample}.bam  -o ${sample} -L 151 -D 25 -s lumpy" >> ${sample}_parallel_commands_list.sh
echo "singularity_wrapper exec --bind /appl/soft:/appl/soft /path/to/tjbsve.sif /software/SVE/scripts/variant_processor.py -v -r UU_Cfam_GSD_1.0_ROSY.svedb.fa -b ${sample}.bam  -o ${sample} -L 151 -D 25 -s cnvnator" >> ${sample}_parallel_commands_list.sh
echo "singularity_wrapper exec --bind /appl/soft:/appl/soft /path/to/tjbsve.sif /software/SVE/scripts/variant_processor.py -v -r UU_Cfam_GSD_1.0_ROSY.svedb.fa -b ${sample}.bam  -o ${sample} -L 151 -D 25 -s breakdancer" >> ${sample}_parallel_commands_list.sh
echo "runWorkflow.py -j 5" >> ${sample}_parallel_commands_list.sh

##run sv calling in parallel
parallel --jobs 10 < ${sample}_parallel_commands_list.sh


