    #!/bin/bash
    
    ref=$1
    mask=$2

    touch chunk01__unmasked__1-8340.fasta
    touch chunk02__unmasked__8341-10165.fasta
    touch chunk03__unmasked__10166-10396.fasta
    touch chunk04__unmasked__10397-12379.fasta
    touch chunk05__unmasked__12380-72655.fasta
    touch chunk06__unmasked__72656-73837.fasta
    touch chunk07__unmasked__73838-134910.fasta
    touch chunk08__unmasked__134911-136757.fasta
    touch chunk09__unmasked__136758-148293.fasta
    touch chunk10__unmasked__148294-159777.fasta
    touch chunk11__unmasked__159778-186876.fasta
    touch chunk12__unmasked__186877-187677.fasta
    touch chunk13__unmasked__187678-197821.fasta
    touch chunk14__unmasked__197822-199705.fasta
    touch chunk15__unmasked__199706-231216.fasta
    touch chunk16__unmasked__231217-236252.fasta
    touch chunk17__unmasked__236253-279651.fasta
    touch chunk18__unmasked__279652-284697.fasta
    touch chunk19__unmasked__284698-329136.fasta
    touch chunk20__unmasked__329137-335905.fasta
    touch chunk21__unmasked__335906-345521.fasta
    touch chunk22__unmasked__345522-348035.fasta
    touch chunk23__unmasked__348036-461727.fasta
    touch chunk24__unmasked__461728-463542.fasta
    touch chunk25__unmasked__463543-492557.fasta
    touch chunk26__unmasked__492558-493832.fasta
    touch chunk27__unmasked__493833-498767.fasta
    touch chunk28__unmasked__498768-499709.fasta
    touch chunk29__unmasked__499710-513972.fasta
    touch chunk30__unmasked__513973-515184.fasta
    touch chunk31__unmasked__515185-522323.fasta
    touch chunk32__unmasked__522324-524861.fasta
    touch chunk33__unmasked__524862-554788.fasta
    touch chunk34__unmasked__554789-557764.fasta
    touch chunk35__unmasked__557765-593140.fasta
    touch chunk36__unmasked__593141-594457.fasta
    touch chunk37__unmasked__594458-605640.fasta
    touch chunk38__unmasked__605641-606549.fasta
    touch chunk39__unmasked__606550-628275.fasta
    touch chunk40__unmasked__628276-630120.fasta
    touch chunk41__unmasked__630121-662727.fasta
    touch chunk42__unmasked__662728-664809.fasta
    touch chunk43__unmasked__664810-670941.fasta
    touch chunk44__unmasked__670942-676749.fasta
    touch chunk45__unmasked__676750-772312.fasta
    touch chunk46__unmasked__772313-774967.fasta
    #touch chunk47__unmasked__774968-934604.fasta
    touch chunk47a__unmasked__774968-810523.fasta
    touch chunk47b__unmasked__810524-854802.fasta
    touch chunk47c__unmasked__854803-892869.fasta
    touch chunk47d__unmasked__892870-934604.fasta
    touch chunk48__unmasked__934605-938683.fasta
    touch chunk49__unmasked__938684-944846.fasta
    touch chunk50__unmasked__944847-946289.fasta
    touch chunk51__unmasked__946290-975796.fasta
    touch chunk52__unmasked__975797-977377.fasta
    touch chunk53__unmasked__977378-1049084.fasta
    touch chunk54__unmasked__1049085-1055473.fasta
    touch chunk55__unmasked__1055474-1125501.fasta
    touch chunk56__unmasked__1125502-1127456.fasta
    touch chunk57__unmasked__1127457-1139569.fasta

    touch chunk02__phylomasked__8341-10165.fasta
    touch chunk04__phylomasked__10397-12379.fasta
    touch chunk06__phylomasked__72656-73837.fasta
    touch chunk08__phylomasked__134911-136757.fasta
    touch chunk10__phylomasked__148294-159777.fasta
    touch chunk12__phylomasked__186877-187677.fasta
    touch chunk14__phylomasked__197822-199705.fasta
    touch chunk16__phylomasked__231217-236252.fasta
    touch chunk18__phylomasked__279652-284697.fasta
    touch chunk20__phylomasked__329137-335905.fasta
    touch chunk22__phylomasked__345522-348035.fasta
    touch chunk24__phylomasked__461728-463542.fasta
    touch chunk26__phylomasked__492558-493832.fasta
    touch chunk28__phylomasked__498768-499709.fasta
    touch chunk30__phylomasked__513973-515184.fasta
    touch chunk32__phylomasked__522324-524861.fasta
    touch chunk34__phylomasked__554789-557764.fasta
    touch chunk36__phylomasked__593141-594457.fasta
    touch chunk38__phylomasked__605641-606549.fasta
    touch chunk40__phylomasked__628276-630120.fasta
    touch chunk42__phylomasked__662728-664809.fasta
    touch chunk44__phylomasked__670942-676749.fasta
    touch chunk46__phylomasked__772313-774967.fasta
    touch chunk48__phylomasked__934605-938683.fasta
    touch chunk50__phylomasked__944847-946289.fasta
    touch chunk52__phylomasked__975797-977377.fasta
    touch chunk54__phylomasked__1049085-1055473.fasta
    touch chunk56__phylomasked__1125502-1127456.fasta

    for i in *_split.vcf.gz
    do
    base=$(basename $i _split.vcf.gz)

    tabix -p vcf ${base}_split.vcf.gz
    samtools faidx $ref NC_021508:1-8340 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk01__unmasked__1-8340.fasta
    samtools faidx $ref NC_021508:8341-10165 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk02__unmasked__8341-10165.fasta
    samtools faidx $ref NC_021508:10166-10396 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk03__unmasked__10166-10396.fasta
    samtools faidx $ref NC_021508:10397-12379 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk04__unmasked__10397-12379.fasta
    samtools faidx $ref NC_021508:12380-72655 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk05__unmasked__12380-72655.fasta
    samtools faidx $ref NC_021508:72656-73837 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk06__unmasked__72656-73837.fasta
    samtools faidx $ref NC_021508:73838-134910 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk07__unmasked__73838-134910.fasta
    samtools faidx $ref NC_021508:134911-136757 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk08__unmasked__134911-136757.fasta
    samtools faidx $ref NC_021508:136758-148293 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk09__unmasked__136758-148293.fasta
    samtools faidx $ref NC_021508:148294-159777 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk10__unmasked__148294-159777.fasta
    samtools faidx $ref NC_021508:159778-186876 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk11__unmasked__159778-186876.fasta
    samtools faidx $ref NC_021508:186877-187677 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk12__unmasked__186877-187677.fasta
    samtools faidx $ref NC_021508:187678-197821 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk13__unmasked__187678-197821.fasta
    samtools faidx $ref NC_021508:197822-199705 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk14__unmasked__197822-199705.fasta
    samtools faidx $ref NC_021508:199706-231216 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk15__unmasked__199706-231216.fasta
    samtools faidx $ref NC_021508:231217-236252 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk16__unmasked__231217-236252.fasta
    samtools faidx $ref NC_021508:236253-279651 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk17__unmasked__236253-279651.fasta
    samtools faidx $ref NC_021508:279652-284697 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk18__unmasked__279652-284697.fasta
    samtools faidx $ref NC_021508:284698-329136 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk19__unmasked__284698-329136.fasta
    samtools faidx $ref NC_021508:329137-335905 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk20__unmasked__329137-335905.fasta
    samtools faidx $ref NC_021508:335906-345521 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk21__unmasked__335906-345521.fasta
    samtools faidx $ref NC_021508:345522-348035 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk22__unmasked__345522-348035.fasta
    samtools faidx $ref NC_021508:348036-461727 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk23__unmasked__348036-461727.fasta
    samtools faidx $ref NC_021508:461728-463542 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk24__unmasked__461728-463542.fasta
    samtools faidx $ref NC_021508:463543-492557 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk25__unmasked__463543-492557.fasta
    samtools faidx $ref NC_021508:492558-493832 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk26__unmasked__492558-493832.fasta
    samtools faidx $ref NC_021508:493833-498767 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk27__unmasked__493833-498767.fasta
    samtools faidx $ref NC_021508:498768-499709 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk28__unmasked__498768-499709.fasta
    samtools faidx $ref NC_021508:499710-513972 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk29__unmasked__499710-513972.fasta
    samtools faidx $ref NC_021508:513973-515184 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk30__unmasked__513973-515184.fasta
    samtools faidx $ref NC_021508:515185-522323 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk31__unmasked__515185-522323.fasta
    samtools faidx $ref NC_021508:522324-524861 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk32__unmasked__522324-524861.fasta
    samtools faidx $ref NC_021508:524862-554788 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk33__unmasked__524862-554788.fasta
    samtools faidx $ref NC_021508:554789-557764 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk34__unmasked__554789-557764.fasta
    samtools faidx $ref NC_021508:557765-593140 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk35__unmasked__557765-593140.fasta
    samtools faidx $ref NC_021508:593141-594457 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk36__unmasked__593141-594457.fasta
    samtools faidx $ref NC_021508:594458-605640 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk37__unmasked__594458-605640.fasta
    samtools faidx $ref NC_021508:605641-606549 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk38__unmasked__605641-606549.fasta
    samtools faidx $ref NC_021508:606550-628275 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk39__unmasked__606550-628275.fasta
    samtools faidx $ref NC_021508:628276-630120 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk40__unmasked__628276-630120.fasta
    samtools faidx $ref NC_021508:630121-662727 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk41__unmasked__630121-662727.fasta
    samtools faidx $ref NC_021508:662728-664809 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk42__unmasked__662728-664809.fasta
    samtools faidx $ref NC_021508:664810-670941 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk43__unmasked__664810-670941.fasta
    samtools faidx $ref NC_021508:670942-676749 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk44__unmasked__670942-676749.fasta
    samtools faidx $ref NC_021508:676750-772312 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk45__unmasked__676750-772312.fasta
    samtools faidx $ref NC_021508:772313-774967 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk46__unmasked__772313-774967.fasta
    #samtools faidx $ref NC_021508:774968-934604 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk47__unmasked__774968-934604.fasta
    samtools faidx $ref NC_021508:774968-810523 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk47a__unmasked__774968-810523.fasta
    samtools faidx $ref NC_021508:810524-854802 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk47b__unmasked__810524-854802.fasta
    samtools faidx $ref NC_021508:854803-892869 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk47c__unmasked__854803-892869.fasta
    samtools faidx $ref NC_021508:892870-934604 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk47d__unmasked__892870-934604.fasta
    samtools faidx $ref NC_021508:934605-938683 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk48__unmasked__934605-938683.fasta
    samtools faidx $ref NC_021508:938684-944846 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk49__unmasked__938684-944846.fasta
    samtools faidx $ref NC_021508:944847-946289 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk50__unmasked__944847-946289.fasta
    samtools faidx $ref NC_021508:946290-975796 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk51__unmasked__946290-975796.fasta
    samtools faidx $ref NC_021508:975797-977377 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk52__unmasked__975797-977377.fasta
    samtools faidx $ref NC_021508:977378-1049084 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk53__unmasked__977378-1049084.fasta
    samtools faidx $ref NC_021508:1049085-1055473 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk54__unmasked__1049085-1055473.fasta
    samtools faidx $ref NC_021508:1055474-1125501 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk55__unmasked__1055474-1125501.fasta
    samtools faidx $ref NC_021508:1125502-1127456 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk56__unmasked__1125502-1127456.fasta
    samtools faidx $ref NC_021508:1127457-1139569 | bcftools consensus -p ${base}__unfiltered__ --mark-del '-' -H I ${base}_split.vcf.gz -M N >> chunk57__unmasked__1127457-1139569.fasta

    samtools faidx $ref NC_021508:8341-10165 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk02__phylomasked__8341-10165.fasta
    samtools faidx $ref NC_021508:10397-12379 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk04__phylomasked__10397-12379.fasta
    samtools faidx $ref NC_021508:72656-73837 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk06__phylomasked__72656-73837.fasta
    samtools faidx $ref NC_021508:134911-136757 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk08__phylomasked__134911-136757.fasta
    samtools faidx $ref NC_021508:148294-159777 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk10__phylomasked__148294-159777.fasta
    samtools faidx $ref NC_021508:186877-187677 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk12__phylomasked__186877-187677.fasta
    samtools faidx $ref NC_021508:197822-199705 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk14__phylomasked__197822-199705.fasta
    samtools faidx $ref NC_021508:231217-236252 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk16__phylomasked__231217-236252.fasta
    samtools faidx $ref NC_021508:279652-284697 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk18__phylomasked__279652-284697.fasta
    samtools faidx $ref NC_021508:329137-335905 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk20__phylomasked__329137-335905.fasta
    samtools faidx $ref NC_021508:345522-348035 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk22__phylomasked__345522-348035.fasta
    samtools faidx $ref NC_021508:461728-463542 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk24__phylomasked__461728-463542.fasta
    samtools faidx $ref NC_021508:492558-493832 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk26__phylomasked__492558-493832.fasta
    samtools faidx $ref NC_021508:498768-499709 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk28__phylomasked__498768-499709.fasta
    samtools faidx $ref NC_021508:513973-515184 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk30__phylomasked__513973-515184.fasta
    samtools faidx $ref NC_021508:522324-524861 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk32__phylomasked__522324-524861.fasta
    samtools faidx $ref NC_021508:554789-557764 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk34__phylomasked__554789-557764.fasta
    samtools faidx $ref NC_021508:593141-594457 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk36__phylomasked__593141-594457.fasta
    samtools faidx $ref NC_021508:605641-606549 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk38__phylomasked__605641-606549.fasta
    samtools faidx $ref NC_021508:628276-630120 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk40__phylomasked__628276-630120.fasta
    samtools faidx $ref NC_021508:662728-664809 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk42__phylomasked__662728-664809.fasta
    samtools faidx $ref NC_021508:670942-676749 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk44__phylomasked__670942-676749.fasta
    samtools faidx $ref NC_021508:772313-774967 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk46__phylomasked__772313-774967.fasta
    samtools faidx $ref NC_021508:934605-938683 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk48__phylomasked__934605-938683.fasta
    samtools faidx $ref NC_021508:944847-946289 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk50__phylomasked__944847-946289.fasta
    samtools faidx $ref NC_021508:975797-977377 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk52__phylomasked__975797-977377.fasta
    samtools faidx $ref NC_021508:1049085-1055473 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk54__phylomasked__1049085-1055473.fasta
    samtools faidx $ref NC_021508:1125502-1127456 | bcftools consensus -p ${base}__phylomasked__ --mark-del '-' -H I ${base}_split.vcf.gz -M N -m $mask >> chunk56__phylomasked__1125502-1127456.fasta
    done