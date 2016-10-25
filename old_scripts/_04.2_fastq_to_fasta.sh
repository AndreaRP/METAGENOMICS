#!/bin/bash
sed -n '1~4s/^@/>/p;2~4p' 148/148.extendedFrags.fastq > 148/148.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' 215/215.extendedFrags.fastq > 215/215.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' 294/294.extendedFrags.fastq > 294/294.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' 296/296.extendedFrags.fastq > 296/296.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' 376/376.extendedFrags.fastq > 376/376.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' 380/380.extendedFrags.fastq > 380/380.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' 489/489.extendedFrags.fastq > 489/489.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' 566/566.extendedFrags.fastq > 566/566.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' A/A.extendedFrags.fastq > A/A.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' cs-t5/cs-t5.extendedFrags.fastq > cs-t5/cs-t5.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' has/has.extendedFrags.fastq > has/has.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' S16/S16.extendedFrags.fastq > S16/S16.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' S9/S9.extendedFrags.fastq > S9/S9.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' sbw-t5/sbw-t5.extendedFrags.fastq > sbw-t5/sbw-t5.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' scea-t5/scea-t5.extendedFrags.fastq > scea-t5/scea-t5.extendedFrags.fasta
sed -n '1~4s/^@/>/p;2~4p' SL10/SL10.extendedFrags.fastq > SL10/SL10.extendedFrags.fasta
bash fastq2fasta.sh 148
bash fastq2fasta.sh 215
bash fastq2fasta.sh 294
bash fastq2fasta.sh 296
bash fastq2fasta.sh 376
bash fastq2fasta.sh 380
bash fastq2fasta.sh 489
bash fastq2fasta.sh 566
bash fastq2fasta.sh A
bash fastq2fasta.sh cs-t5
bash fastq2fasta.sh has
bash fastq2fasta.sh S16
bash fastq2fasta.sh S9
bash fastq2fasta.sh sbw-t5
bash fastq2fasta.sh scea-t5
bash fastq2fasta.sh SL10
