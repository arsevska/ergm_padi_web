# This script use a stepwise bidirectional approach to select the most parsimonious model for the network of sources and outbreaks of African swine fever collected from PADI-web

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
load("asf_network.rda")

# Node source attributes
load("asf_source.rda")

# Node outbreak attributes
load("asf_outbreak.rda")


########################################
##### Create the bipartite network #####
########################################

# We keep only the links between source and event
asf_network <- asf_network[,c("id_outbreak", "source")]
asf_network <- unique(asf_network)


# Create the network object with the package
asf_net <- as.network(asf_network,
                  bipartite = T,
                  matrix.type="bipartite")


# Set the two type of nodes

# Number of nodes
n_outbreak <- asf_network$id_outbreak %>% unique %>% length
n_nodes <- asf_network$source %>% unique %>% length %>% add(n_outbreak)

asf_net %v% "is.outbreak" <- as.integer(1 : n_nodes <= n_outbreak)
asf_net %v% "is.source" <- as.integer(1 : n_nodes > n_outbreak)

n_sources <- sum(network::get.vertex.attribute(asf_net, attrname = "is.source"))
sources <- which(network::get.vertex.attribute(asf_net, attrname = "is.source") %>% as.logical)
sources_names <- network::get.vertex.attribute(asf_net, attrname = "vertex.names")[sources]

n_outbreak <- sum(network::get.vertex.attribute(asf_net, attrname = "is.outbreak"))
outbreak <- which(network::get.vertex.attribute(asf_net, attrname = "is.outbreak") %>% as.logical)
outbreak_names <- network::get.vertex.attribute(asf_net, attrname = "vertex.names")[outbreak]


##############################
##### Add the attributes #####
##############################

## Source ##

# Type_source
network::set.vertex.attribute(asf_net,
                              attrname = "type_source",
                              value = asf_source$type_source[match(sources_names, asf_source$source)],
                              v = sources)
# Specialization
network::set.vertex.attribute(asf_net,
                              attrname = "specialization",
                              value = asf_source$specialization[match(sources_names, asf_source$source)],
                              v = sources)
# Geographical_focus
network::set.vertex.attribute(asf_net,
                              attrname = "geographical_focus",
                              value = asf_source$geographical_focus[match(sources_names, asf_source$source)],
                              v = sources)

## Outbreak ##

# Type of host
network::set.vertex.attribute(asf_net,
                              attrname = "type_host",
                              value = asf_outbreak$type_host[match(outbreak_names, asf_outbreak$id_outbreak)],
                              v = outbreak)

# Reason of notification
network::set.vertex.attribute(asf_net,
                              attrname = "reason of notification",
                              value = asf_outbreak$`reason of notification`[match(outbreak_names, asf_outbreak$id_outbreak)],
                              v = outbreak)

# Surveillance capacity
network::set.vertex.attribute(asf_net,
                              attrname = "surveillance (SPAR)",
                              value = asf_outbreak$`surveillance (SPAR)`[match(outbreak_names, asf_outbreak$id_outbreak)],
                              v = outbreak)

# Political stability
network::set.vertex.attribute(asf_net,
                              attrname = "political_stability",
                              value = asf_outbreak$political_stability[match(outbreak_names, asf_outbreak$id_outbreak)],
                              v = outbreak)

# GDP (Gross domestic product)
network::set.vertex.attribute(asf_net,
                              attrname = "gdp_per_capita",
                              value = asf_outbreak$gdp_per_capita[match(outbreak_names, asf_outbreak$id_outbreak)],
                              v = outbreak)

# HDI (Human development index)
network::set.vertex.attribute(asf_net,
                              attrname = "hdi",
                              value = asf_outbreak$hdi[match(outbreak_names, asf_outbreak$id_outbreak)],
                              v = outbreak)

# Internet use
network::set.vertex.attribute(asf_net,
                              attrname = "internet",
                              value = asf_outbreak$internet[match(outbreak_names, asf_outbreak$id_outbreak)],
                              v = outbreak)

# English official language
network::set.vertex.attribute(asf_net,
                              attrname = "english",
                              value = asf_outbreak$english[match(outbreak_names, asf_outbreak$id_outbreak)],
                              v = outbreak)

# PFI (Press freedom index)
network::set.vertex.attribute(asf_net,
                              attrname = "pfi",
                              value = asf_outbreak$pfi[match(outbreak_names, asf_outbreak$id_outbreak)],
                              v = outbreak)
# Region
network::set.vertex.attribute(asf_net,
                              attrname = "region",
                              value = asf_outbreak$region[match(outbreak_names, asf_outbreak$id_outbreak)],
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
              'b2factor("specialization")',
              'b1cov("pfi")')

# Provide the directory (dir) name (i.e sub dir) that you want to create under main dir
output_dir <- dir.create(file.path(getwd(), "output"))

# First clean the file output (delete all the files output)
delete_files <- list.files("output_dir/ASF_ERGM")
for (file in delete_files) {
  file_path <- file.path("output_dir/ASF_ERGM", file)
  file.remove(file_path)
}
cat("All files have been deleted from the folder.", "output_dir/ASF_ERGM", "\n")


# Stepwise bidirectional
SwineNet::stepwise4ERGM(base.formula = "g ~ edges",  #string
                        nbworkers = 4, #integer
                        elements = elements, # list
                        network.name = "ASF_ERGM", # string
                        results.path = "output_dir/",
                        maxduration = 60*60*10, # integer in seconds
                        g = asf_net,
                        distMatrix = NA,
                        mode = "bidirectional", # string "forward" or "backward" or "bidirectional"
                        stepwise.summary = list(),
                        baseline.aic = NA,
                        predict.limit = FALSE, # TRUE
                        verbose = T
)


#####################
##### ASF Model #####
#####################

# This is the most parsimonious model obtain by stepwise bidirectional approach

# 6 var
#
# [1] "ergm::ergm(g ~edges+b2factor(\"type_source\")+b2factor(\"geographical_focus\")+b1cov(\"internet\")+b1cov(\"pib_par_hab\")+b1factor(\"region\")+b1cov(\"pfi\"))"
#
# $min.aic
# [1] 11788.73
#
# $time
# [1] "2024-02-22 13:46:31 CET"

asf_model_global <- ergm(asf_net ~edges
                         +b2factor("type_source", levels = -4) # levels to use online news as the reference
                         +b2factor("geographical_focus", levels = -2) # levels to use local focus as the reference
                         +b1cov("internet")
                         +b1cov("gdp_per_capita")
                         +b1factor("region")
                         +b1cov("pfi"))

summary(asf_model_global)


############################
###### Goodness of fit #####
############################


gof_asf_global <- ergm::gof(asf_model_global)

plot(gof_asf_global)
