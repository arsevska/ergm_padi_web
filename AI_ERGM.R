# This script use a stepwise bidirectional approach to select the most parsimonious model for the network of sources and outbreaks of avian influenza collected by PADI-web.

####################
##### Packages #####
####################

# Install packages if necessary

# install.packages('ergm')
# install.packages('network')
# remotes::install_github("Pachka/SwineNet")

# Charge library

library('ergm') # analyze and simulate networks based on exponential-family random graph models (ERGMs)
library('network') # package to create and modify network objects
library("SwineNet") # package for automatic selection by stepwise


#########################
##### Load the data #####
#########################

# Set the main directory
main_dir <- setwd("path/files")

# Links of the network
load("ai_network.rda")

# Node source attributes
load("ai_source.rda")

# Node outbreak attributes
load("ai_outbreak.rda")


########################################
##### Create the bipartite network #####
########################################

# We keep only the links between source and event
ai_network <- ai_network[,c("id_outbreak", "source")]
ai_network <- unique(ai_network)


ai_net <- as.network(ai_network,
                      bipartite = T,
                      matrix.type="bipartite")


# Set the two type of nodes

# Number of nodes
n_outbreak <- ai_network$id_outbreak %>% unique %>% length
n_nodes <- ai_network$source %>% unique %>% length %>% add(n_outbreak)

ai_net %v% "is.outbreak" <- as.integer(1 : n_nodes <= n_outbreak)
ai_net %v% "is.source" <- as.integer(1 : n_nodes > n_outbreak)

n_sources <- sum(network::get.vertex.attribute(ai_net, attrname = "is.source"))
sources <- which(network::get.vertex.attribute(ai_net, attrname = "is.source") %>% as.logical)
sources_names <- network::get.vertex.attribute(ai_net, attrname = "vertex.names")[sources]

n_outbreak <- sum(network::get.vertex.attribute(ai_net, attrname = "is.outbreak"))
outbreak <- which(network::get.vertex.attribute(ai_net, attrname = "is.outbreak") %>% as.logical)
outbreak_names <- network::get.vertex.attribute(ai_net, attrname = "vertex.names")[outbreak]


##############################
##### Add the attributes #####
##############################

## Source ##

# Type_source
network::set.vertex.attribute(ai_net,
                              attrname = "type_source",
                              value = ai_source$type_source[match(sources_names, ai_source$source)],
                              v = sources)
# Specialisation
network::set.vertex.attribute(ai_net,
                              attrname = "specialisation",
                              value = ai_source$specialisation[match(sources_names, ai_source$source)],
                              v = sources)
# Geographical_focus
network::set.vertex.attribute(ai_net,
                              attrname = "geographical_focus",
                              value = ai_source$geographical_focus[match(sources_names, ai_source$source)],
                              v = sources)

## Outbreak ##

# Type of host
network::set.vertex.attribute(ai_net,
                              attrname = "type_host",
                              value = ai_outbreak$type_host[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)
# Reason of notification
network::set.vertex.attribute(ai_net,
                              attrname = "reason of notification",
                              value = ai_outbreak$`reason of notification`[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)

# Surveillance capacity
network::set.vertex.attribute(ai_net,
                              attrname = "surveillance (SPAR)",
                              value = ai_outbreak$`surveillance (SPAR)`[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)
# Political stability
network::set.vertex.attribute(ai_net,
                              attrname = "political_stability",
                              value = ai_outbreak$political_stability[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)

# GDP (Gross Domestic Product)
network::set.vertex.attribute(ai_net,
                              attrname = "gdp_per_capita",
                              value = ai_outbreak$gdp_per_capita[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)

# HDI (Human development index)
network::set.vertex.attribute(ai_net,
                              attrname = "hdi",
                              value = ai_outbreak$hdi[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)
# Internet use
network::set.vertex.attribute(ai_net,
                              attrname = "internet",
                              value = ai_outbreak$internet[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)
# English official language
network::set.vertex.attribute(ai_net,
                              attrname = "english",
                              value = ai_outbreak$english[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)
# PFI (Press freedom index)
network::set.vertex.attribute(ai_net,
                              attrname = "pfi",
                              value = ai_outbreak$pfi[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)
# Region
network::set.vertex.attribute(ai_net,
                              attrname = "region",
                              value = ai_outbreak$region[match(outbreak_names, ai_outbreak$id_outbreak)],
                              v = outbreak)


##############################################################################
##### Select the parsimonious model by a stepwise bidirectional approach #####
##############################################################################

elements <- c('b1factor("type_host")',
              'b1factor ("reason of notification")',
              'b1cov("surveillance (SPAR)")',
              'b1cov("political_stability")',
              'b1cov("gdp_per_capita")',
              'b1cov("hdi")',
              'b1cov("internet")',
              'b1factor("english")',
              'b1nodematch("region")',
              'b2factor("type_source")',
              'b2factor("geographical_focus")',
              'b1factor("region")',
              'b2factor("specialisation")',
              'b1cov("pfi")')

# Provide the directory (dir) name (i.e sub dir) that you want to create under main dir
output_dir <- dir.create(file.path(getwd(), "output"))

# First clean the file output (delete all the output)
delete_files <- list.files("output_dir/AI_ERGM")
for (file in delete_files) {
  file_path <- file.path("output_dir/AI_ERGM", file)
  file.remove(file_path)
}
cat("All files have been deleted from the folder.", "output_dir/AI_ERGM", "\n")


# Stepwise bidirectional
SwineNet::stepwise4ERGM(base.formula = "g ~ edges",  #string
                        nbworkers = 4, #integer
                        elements = elements, # list
                        network.name = "AI_ERGM", # string
                        results.path = "output_dir/",
                        maxduration = 60*60*10, # integer in seconds
                        g = ai_net,
                        distMatrix = NA,
                        mode = "bidirectional",
                        stepwise.summary = list(),
                        baseline.aic = NA,
                        predict.limit = FALSE, # TRUE
                        verbose = T
)


#####################
##### AI Model #####
#####################

# This is the most parsimonious model obtain by stepwise bidirectional approach

# 11 var

# [1] "ergm::ergm(g ~edges+b2factor(\"type_source\")+b2factor(\"geographical_focus\")+b1nodematch(\"region\")+b1factor(\"region\")+b2factor(\"specialisation\")+b1factor(\"type_host\")+b1factor(\"anglais\")+b1cov(\"stabilite_politique\")+b1cov(\"pfi\")+b1cov(\"pib_par_hab\")+b1cov(\"internet\"))"
#
# $min.aic
# [1] 7168.955


ai_model_global <- ergm(ai_net ~edges
                        +b2factor("type_source", levels = -4) # levels to use online news as the reference
                        +b2factor("geographical_focus", levels = -2) # levels to use local focus as the reference
                        +b1nodematch("region")
                        +b1factor("region")
                        +b2factor("specialisation")
                        +b1factor("type_host")
                        +b1factor("english")
                        +b1cov("political_stability")
                        +b1cov("pfi")
                        +b1cov("gdp_per_capita")
                        +b1cov("internet"))

summary(ai_model_global)


############################
###### Goodness of fit #####
############################


gof_ai_global <- ergm::gof(ai_model_global)

plot(gof_ai_global)

