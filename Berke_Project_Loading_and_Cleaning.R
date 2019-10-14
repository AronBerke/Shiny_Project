

setwd("/Users/aronberke/Desktop/R_materials/Data/vaers_data")
library(tidyverse)
library(data.table)

# develop helper function to clean the data

clean = function(vrs, vrs_vax, vrs_symp){
  
  #transform vrs_vax (vaccine information) and vrs_symp (symptom information) for merger with vrs18 (vaers log)
  
  #pull relevant subset of v and create unique identifier for vaccines within each VAE
  v = select(vrs_vax, VAERS_ID, VAX_NAME, VAX_TYPE, VAX_MANU)
  v$ROW_ID = rowid(v$VAERS_ID, prefix = 'VAX')
  x = length(unique(v$ROW_ID))
  
  ##at this step, retrieve ids that match scheduled, brand name, non-flu vaccines and store as x for later filtration
  
  sched = c('DTAP + IPV + HIB (PENTACEL)','ROTAVIRUS (ROTARIX)','ZOSTER (SHINGRIX)',
            'MEASLES + MUMPS + RUBELLA (MMR II)','TDAP (ADACEL)', 'PNEUMO (PNEUMOVAX)', 
            'MENINGOCOCCAL B (BEXSERO)','TDAP (BOOSTRIX)','HEP A (VAQTA)','VARICELLA (VARIVAX)',
            'MEASLES + MUMPS + RUBELLA + VARICELLA (PROQUAD)','HPV (GARDASIL 9)','HEP A (HAVRIX)',
            'MENINGOCOCCAL CONJUGATE (MENVEO)', 'HEP B (ENGERIX-B)','HEP B (RECOMBIVAX HB)',
            'PNEUMO (PREVNAR13)','ROTAVIRUS (ROTATEQ)','DTAP + HEPB + IPV (PEDIARIX)', 
            'MENINGOCOCCAL CONJUGATE (MENACTRA)','MENINGOCOCCAL B (TRUMENBA)','DTAP (INFANRIX)',
            'HIB (PEDVAXHIB)','HIB (ACTHIB)','HPV (GARDASIL)','DTAP + IPV (KINRIX)',
            'POLIO VIRUS, INACT. (IPOL)','HIB (HIBERIX)','DTAP (DAPTACEL)','HEP A + HEP B (TWINRIX)',
            'MENINGOCOCCAL (MENOMUNE)','DTAP + IPV (QUADRACEL)','PNEUMO (PREVNAR)','TETANUS TOXOID (TEVAX)', 
            'HEP B (GENHEVAC B)','MENINGOCOCCAL C & Y + HIB (MENHIBRIX)','POLIO VIRUS, INACT. (POLIOVAX)',
            'PNEUMO (SYNFLORIX)','HPV (CERVARIX)','HIB (PROHIBIT)','MENINGOCOCCAL CONJUGATE + HIB (MENITORIX)',
            'HEP B (HEPLISAV-B)','DTAP + IPV (INFANRIX TETRA)','PNEUMO (PNU-IMUNE)','DTAP (TRIPEDIA)')
  
  sched_id = filter(v, VAX_NAME %in% sched) %>% 
    .[,"VAERS_ID"]
  sched_id = unique(sched_id)
  
  #Collapse name, type, and manu into single column, remove duplicate information generated in the process,
  #then spread where the key is row id and then spread
  v = mutate(v, VAX_ALL=paste(VAX_NAME, VAX_TYPE, VAX_MANU, sep=':')) %>% 
    select(., VAERS_ID, ROW_ID, VAX_ALL) %>% 
    spread(., ROW_ID, VAX_ALL) 
  
  #loop through to separate name, type, and manu data in each vax number column
  v2 = data.frame(v$VAERS_ID)
  
  for(i in 1:x){
    temp = separate(v, paste0('VAX',i), c(paste0('vax_name',i), paste0('vax_type',i), paste0('vax_manu',i)), sep=':')
    temp = select(temp, paste0('vax_name',i), paste0('vax_type',i), paste0('vax_manu',i))
    v2 = cbind(v2,temp)
  }
  
  colnames(v2)[colnames(v2) == 'v.VAERS_ID'] = 'VAERS_ID'
  
  #merge vrs18 with short form vax names (v2)
  
  vrs = inner_join(vrs, v2, by='VAERS_ID')
  
  #prune symptoms dataset (remove unnecessary columns, limit symptoms to first 5 listed), 
  #concatenate symptoms into single columns
  
  s = group_by(vrs_symp, VAERS_ID) %>% 
    slice(1) %>% 
    select(., VAERS_ID, SYMPTOM1, SYMPTOM2, SYMPTOM3, SYMPTOM4, SYMPTOM5)
  
  #merge vrs18 with short form top 5 symptoms (s)
  
  vrs = inner_join(vrs, s, by='VAERS_ID')
  
  #prune vrs18 of unnecessary columns and limit rows to age <= 18, write to new file in shiny proj folder
  
  vrs = select(vrs, -CAGE_YR, -CAGE_MO, -RPT_DATE, -SYMPTOM_TEXT, -DATEDIED, -HOSPDAYS, 
               -X_STAY, -VAX_DATE,-ONSET_DATE, -NUMDAYS, - ALLERGIES, -LAB_DATA, -V_FUNDBY, 
               -OTHER_MEDS, -CUR_ILL, -HISTORY, -PRIOR_VAX, -SPLTTYPE, -FORM_VERS, -TODAYS_DATE, -ALLERGIES)
  
  vrs = filter(vrs, AGE_YRS <=18)
  
  #change col_names to lower
  
  colnames(vrs) <- tolower(colnames(vrs))
  
  #remove all AEs related to product usage error
  
  prod_err = c('No adverse event', 'Product storage error', 'Drug administered to patient of inappropriate age',
               'Product administered to patient of inappropriate age', 'Expired product administered', 'Incorrect dose administered',
               'Wrong product administered', 'Wrong drug administered', 'Inappropriate schedule of drug administration', 
               'Inappropriate schedule of product administration', 'Product preparation error', 
               'Incorrect route of product administration', 'Incorrect route of drug administration', 
               'Incorrect product formulation administered', 'Incomplete course of vaccination', 'Vaccination error')
  
  #filter out rows of non-scheduled vaccines
  
  vrs = filter(vrs, !symptom1 %in%  prod_err,
               !symptom2 %in% prod_err,
               !symptom3 %in% prod_err,
               !symptom4 %in% prod_err,
               !symptom5 %in% prod_err)
  
  #standardize injection site and vaccination terms in symptoms
  
  vrs = filter(vrs, vaers_id %in% sched_id)
  
  return(vrs)
  
}

#generate separate files lists for each file type by year
symp_files = paste0(as.character(2014:2018),"VAERSSYMPTOMS.csv")
vax_files = paste0(as.character(2014:2018),"VAERSVAX.csv")
vrs_files = paste0(as.character(2014:2018),"VAERSDATA.csv")

#load in symptoms tables
for(i in 1:5){
  path = paste0("./", symp_files[i])
  assign(paste0('symp',i),read.csv(path, stringsAsFactors = F, na.strings=c("", " ")))
}

#load in vaccine info tables
for(i in 1:5){
  path = paste0("./", vax_files[i])
  assign(paste0('vax',i),read.csv(path, stringsAsFactors = F, na.strings=c("", " ")))
}

#load in adverse events data tables
for(i in 1:5){
  path = paste0("./", vrs_files[i])
  assign(paste0('vrs',i),read.csv(path, stringsAsFactors = F, na.strings=c("", " ")))
}

#apply clean function to clean and combine tables for each year
dvrs1 = clean(vrs1, vax1, symp1)
dvrs2 = clean(vrs2, vax2, symp2)
dvrs3 = clean(vrs3, vax3, symp3)
dvrs4 = clean(vrs4, vax4, symp4)
dvrs5 = clean(vrs5, vax5, symp5)

#combine all years
vrs_all = bind_rows(dvrs1, dvrs2, dvrs3, dvrs4, dvrs5)


vrs_all = read.csv("/Users/aronberke/Desktop/R_materials/Data/vaers_data/VAERS14-19.csv", 
                   stringsAsFactors = F)

vrs_all$year = substr(vrs_all$recvdate, 7, 10)

vrs_all$died[is.na(vrs_all$died)] = 'N'
vrs_all$l_threat[is.na(vrs_all$l_threat)] = 'N'
vrs_all$disable[is.na(vrs_all$disable)] = 'N'
vrs_all$hospital[is.na(vrs_all$hospital)] = 'N'
vrs_all$er_visit[is.na(vrs_all$er_visit)] = 'N'

vrs_all = mutate(vrs_all, severity = case_when(
  died == 'Y' ~ 'died',
  disable == 'Y' ~ 'disabled',
  l_threat == 'Y' ~ 'life_threatening',
  hospital =='Y' ~ 'hospitalized',
  er_visit =='Y' ~ 'er_visit'
))

vrs_all$severity[is.na(vrs_all$severity)] = 'non-serious'

#standardize symptom language

vrs_all = gather(vrs_all, key = 'symptom_num', value = "symptom", symptom1:symptom5)
vrs_all$symptom = gsub("Vaccination site", "Injection site", vrs_all$symptom)
vrs_all$symptom = gsub("Autism spectrum disorder", "Autism", vrs_all$symptom)
vrs_all = spread(vrs_all,symptom_num, symptom)



#write out combined dataset
write.csv(vrs_all, "VAERS14-19.csv", row.names = FALSE)




