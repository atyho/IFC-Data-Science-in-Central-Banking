rm(list = ls())
require(dplyr)
require(tidyr)
require(DescTools)
require(doBy)
require(ggplot2)
require(Cairo)

# Load data
dist_data <- read.csv(file = 'dist_data.csv', stringsAsFactors = FALSE)

# Create frequency weight
dist_data <- dist_data %>% mutate(wgt = 100*N_active/sum(N_active))

# Categorize the distance to nearest local branch
dist_data$dist_range <- cut(dist_data$distance_min,
                            breaks = c(0, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0, 10, Inf),
                            labels = c("<0.5","0.5-1","1-1.5","1.5-2","2-3","3-5","5-10",">=10"),
                            right  = FALSE, ordered_result = TRUE)

# Regroup and factorize Statistical Area Classification (SAC) data
dist_data$sac_grp[dist_data$sactype == "Census metropolitan area"]          <- "CMA"
dist_data$sac_grp[dist_data$sactype == "Tracted census agglomeration"]      <- "CA"
dist_data$sac_grp[dist_data$sactype == "Non-tracted census agglomeration"]  <- "CA"
dist_data$sac_grp[dist_data$sactype == "Strongly influenced zone"]          <- "Strong MIZ"
dist_data$sac_grp[dist_data$sactype == "Moderately influenced zone"]        <- "Moderate MIZ"
dist_data$sac_grp[dist_data$sactype == "Weakly influenced zone"]            <- "Weak MIZ"
dist_data$sac_grp[dist_data$sactype == "Not influenced zone"]               <- "No MIZ"

dist_data$sac_grp <- ordered(dist_data$sac_grp, 
                             levels = c("CMA", "CA", "Strong MIZ", "Moderate MIZ", "Weak MIZ","No MIZ") )

dist_data$inc_range <- CutQ(dist_data$hinc_avg, breaks=5)

dist_data$pop_range <- CutQ(dist_data$pop_den, breaks=5)

# Weighted plot for nation-wide distance to nearest local branch
dist_data_test <- dist_data %>% 
  summaryBy(formula = wgt ~ dist_range, FUN = c(sum)) %>%
  drop_na()

plot_overall <- ggplot(dist_data_test, aes(x = dist_range, y = wgt.sum)) +
  stat_summary(geom = "bar", fun = sum) +
  xlab("Distance (km)") + ylab("Percentage Points") + #ylim(0, 35) +
  theme_bw()

plot_overall

cairo_ps(filename = "plot_overall.eps", width=6, height=4, 
         pointsize=10, fallback_resolution=300)
print(plot_overall)
dev.off()

# Stacked + percent by sac type
dist_data_test <- dist_data %>% 
  summaryBy(formula = wgt ~ sac_grp + dist_range, FUN = c(sum)) %>%
  drop_na()

plot_sactype_prct <- ggplot(dist_data_test, aes(fill = dist_range, y = wgt.sum, x = sac_grp)) + 
  geom_bar(position="fill", stat="identity") +
  xlab("") + ylab("Shares") +
  theme(legend.title = element_blank(),
        legend.position="bottom")

plot_sactype_prct

cairo_ps(filename = "plot_sactype_prct.eps", width=6, height=4, 
         pointsize=10, fallback_resolution=300)
print(plot_sactype_prct)
dev.off()

# Stacked + percent by income quantile
dist_data_test <- dist_data %>% 
  summaryBy(formula = wgt ~ dist_range + inc_range, FUN = c(sum)) %>%
  drop_na()

plot_inc_prct <- ggplot(dist_data_test, aes(fill = dist_range, y = wgt.sum, x = inc_range)) + 
  geom_bar(position="fill", stat="identity") +
  xlab("Income Quantile") + ylab("Shares") +
  theme(legend.title = element_blank(),
        legend.position="bottom")

plot_inc_prct

cairo_ps(filename = "plot_inc_prct.eps", width=6, height=4, 
         pointsize=10, fallback_resolution=300)
print(plot_inc_prct)
dev.off()

# Stacked + percent by income quantile
dist_data_test <- dist_data %>% 
  summaryBy(formula = wgt ~ dist_range + pop_range, FUN = c(sum)) %>%
  drop_na()

plot_pop_prct <- ggplot(dist_data_test, aes(fill = dist_range, y = wgt.sum, x = pop_range)) + 
  geom_bar(position="fill", stat="identity") +
  xlab("Density Quantile") + ylab("Shares") +
  theme(legend.title = element_blank(),
        legend.position="bottom")

plot_pop_prct

cairo_ps(filename = "plot_pop_prct.eps", width=6, height=4, 
         pointsize=10, fallback_resolution=300)
print(plot_pop_prct)
dev.off()

# Stacked + percent by sac type
dist_data_test <- dist_data %>% 
  summaryBy(formula = wgt ~ uaratype + dist_range, FUN = c(sum)) %>%
  drop_na()

plot_uaratype_prct <- ggplot(dist_data_test, aes(fill = dist_range, y = wgt.sum, x = uaratype)) + 
  geom_bar(position="fill", stat="identity") +
  xlab("") + ylab("Shares") +
  theme(legend.title = element_blank(),
        legend.position="bottom")

plot_uaratype_prct

cairo_ps(filename = "plot_uaratype_prct.eps", width=6, height=4, 
         pointsize=10, fallback_resolution=300)
print(plot_uaratype_prct)
dev.off()
