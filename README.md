This README file was generated on 2024-12-24 by Elena Arsevska, CIRAD.
Date creation: 2024-03-12.
First update: 2024-12-24 (added two datasets, ai_rports.rda and as_reports.rda)
 
# GENERAL INFORMATION
 
## Dataset title: Data and code for analysis of a bi-mode network of sources and outbreaks of Avian influenza and African swine fever, identified by the PADI-web media monitoring tool

## Dataset and code overview: This repository contains the data and code for analysis of a bi-mode network of sources and outbreaks of Avian influenza and African swine fever identified in the news by the PADI-web media monitoring tool (https://padi-web.cirad.fr/en/) worldwide between 2018 and 2019. More precisely, for each disease, we provide the data on all sources communicating about a given outbreak identified in the online news, the data on the outbreaks communicated in the news and the network of both sources and outbreaks (bi-mode network). We further provide the Exponential random graph Model (ERGM model) code to analyse the bi-mode networks on the two diseases, respectively. The datasets and code can be useful for network modelling in epidemiology and information /communication science.
 
## DOI: https://doi.org/10.18167/DVN1/W858OB
 
## Contact email: Elena Arsevska, elena.arsevska@cirad.fr
 
# METHODOLOGICAL INFORMATION 
 
## Description of sources and methods used to collect and generate data:

### News reports. 
For this work, we used the news reports collected by PADI-web from online news reports between July 1, 2018, and June 30, 2019, that documented one or more AI and ASF outbreaks, respectively (436 news reports for AI and 594 for ASF). These news reports were collected using the search queries "Avian influenza" and "African swine fever" in English. We selected a one-year study period to capture the spatiotemporal epidemiological aspects of the two disease epidemics worldwide. The raw database of the news reports (texts) is available upon request from the authors Sarah Valentin and Elena Arsevska. 

### Outbreaks
We further created a database of all outbreaks based on the disease case(s) or pathogen found at a specific date, place, and host, which were communicated in the news reports. Each outbreak communicated in the news was further linked to the corresponding officially reported outbreak by the country's competent authorities to the WOAH (World Organisation for Animal Health, WAHIS database). Unmatched outbreaks, i.e., outbreaks from the news that could not be linked to the WOAH outbreaks, were discarded from the analysis as we could not verify their truthfulness (31 outbreaks for AI and 69 for ASF; these outbreaks are not part of the current dataset). Thus, for the network analysis, we used 199 matched outbreaks for AI (ai_outbreak.rda) and 277 for ASF (asf_outbreak.rda), respectively. 

### Sources
To obtain the sources that communicated on outbreaks, we manually traced the dissemination pathways of all outbreaks mentioned in the news reports, as described in Valentin et al., 2023 (https://doi.org/10.1371/journal.pone.0285341). More precisely, in the news dissemination pathway, the first node was the primary source (i.e., the earliest emitter source), the last node was the final source (i.e. the online news), and the remaining nodes, if any, were intermediary sources. 
Each source was consequently connected to the outbreak for which he communicated information. The database of sources used for our modelling comprised sources regardless of whether they were primary, intermediary, or final. Thus, we used 212 sources for the network analysis for AI (ai_source.rda) and 204 for ASF (asf_source.rda), respectively. 

### Network
We further created a network of the links between each source communicating on an outbreak for AI (ai_network.rda) and ASF (asf_network.rda), respectively. 

## Quality assurance procedures performed on the data: 

EA, SV, and BB did manual curation and database creation for the sources and outbreaks identified in the news reports. Covariates associated to outbreaks were obtained by SR. See details in the metadata file at: https://doi.org/10.18167/DVN1/W858OB
 
## Other contextual information:

Inspiration for this work comes from the work of Valentin et al., 2023 (https://doi.org/10.1371/journal.pone.0285341)
 
# DATA & FILE OVERVIEW
 
## Code AI_ERGM.R and ASF_ERGM.R
 
### Code information for AI_ERGM.R and ASF_ERGM.R
 
These scripts use a stepwise bidirectional approach to select the best covariates and the ERGM model for the network of sources and outbreaks of Avian influenza and African swine fever, respectively.
 
## Data ai_network.rda and asf_network.rda
 
### Data information for: ai_network.rda and asf_network.rda
 
This dataset consists of the links (edges) between outbreaks and sources identified in the news reports of the PADI-web media monitoring tool worldwide between 2018 and 2019 for Avian influenza and Africa swine fever, respectively. 
Variables:
-- id_outbreak is the id number of each outbreak; 
-- the source is the name of the source of information that communicated about an outbreak; 
-- no_edge is the place that a given source occupies in the news information flow on a given outbreak; 
-- id_path is the information flow on a given outbreak; 
-- date_edge is the date when a source talked about a given outbreak (it can be the date of publication of news, date of lab confirmation, or date of observation of clinical signs - use with prudence this column); 
-- reporting_date is the date of official notification of the given outbreak to the World Organisation for Animal Health (WOAH); 
-- diff_days is the difference between the date_edge and reporting_date in days.

## Data: ai_outbreak.rda and asf_outbreak.rda
 
### Data information for: ai_outbreak.rda and asf_outbreak.rda
 
This dataset contains Avian influenza and African swine fever outbreaks, respectively and their attributes for each year and country of the outbreak, where available.
Variables:
-- id_outbreak is the id number of each outbreak; 
-- the country is the place where the outbreak occurred according to the World Organisation for Animal Health database (WOAH); 
-- observation_date is the date when symptoms were observed according to WOAH; 
-- reporting_date is the date of official notification of the given outbreak to WOAH; 
-- type_host (domestic/wild/environmental) sent to WOAH; 
-- reason_notification sent to WOAH; 
-- Surveillance is a self-assessment indicator of a country's surveillance system (public health); 
-- political_stability; 
-- GDP_per_captia is the Gross Dometic Product per capita; 
-- HDI is the Human development index; 
-- Internet usage; 
-- English as an official language in the country; 
-- PFI is the Press Freedom Indicator; 
-- region of the outbreaks.

## Data: ai_source.rda and asf_source.rda
 
### Data information for: ai_source.rda and asf_source.rda
 
This dataset contains the sources communicating on Avian influenza and African swine fever outbreaks, respectively and their attributes.
Variables:
-- name of the source;
-- type_source (international organisation (e.g., WOAH), company/association (e.g., National Pig Association), laboratory (e.g., Bulgarian National Reference Laboratory), official authority (e.g., customs), veterinary authority  (e.g., Ministry of Agriculture), online news (e.g., The New York Post), press agency (e.g., Reuters), radio/TV  (e.g., Belstav.tv), social platform (e.g., Twitter), research organisation (e.g., CIDRAP)); 
-- geographical_focus (local/national/international); 
-- specialisation (specialised vs generalist)

## Missing data codes: NA

## Data: ai_reports.rda and asf_reports.rda
 
### Data information for: ai_reports.rda and asf_reports.rda
 
This dataset contains the metadata of the news reports to build the Avian influenza and African swine fever networks.
Variables:
-- id_path;
-- id_article;
-- title of the news; 
-- ulr of the news; 
-- source name; 
-- publication date.

## Missing data codes: NA