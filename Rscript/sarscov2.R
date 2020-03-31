##### Illustrating and Geo-mapping the SARS-CoV-2 #####

# graphics, charts, colours and animation
require(ggplot2)
require(shadowtext)
require(viridis)
require(gghighlight)
require(paletteer)
require(ggmap)
require(scico)
require(gganimate)
require(gifski)
require(ggthemes)
require(cowplot)

# Data sources
require(nCov2019)
require(rnaturalearth)
require(maps)

# Data manipulation and simple features
require(dplyr)
require(sf)
require(tmap)
require(st)


#####
# This script needs a rewriting and deserves at least a loop
#####

# load the global data set (last update)
d = load_nCov2019()

# Select the measures, filter the rows for which the number of cases is larger than 100
# Filter out China since the outbreak took place after a couple of weeks after first cases in China
dd = d['global'] %>% 
  as_tibble %>%
  rename(confirm=cum_confirm, heal=cum_heal, dead=cum_dead) %>%
  filter(confirm > 100 & country != "China") %>%
  group_by(country) %>%
  mutate(days_since_100 = as.numeric(time - min(time))) %>%
  ungroup %>% 
  tidyr::complete(time = seq.Date(min(time), max(time), by="day"))  %>% group_by(country) %>% 
  tidyr::fill(confirm, dead, heal) %>% ungroup

# Select the countries with population larger than 10 000
world = rnaturalearth::countries110 %>% st_as_sf
world_countries = world %>% 
  filter(region_un %in% c('Africa', 'Americas', 'Asia', 'Europe', 'Ocieania') & pop_est > 10000) %>% 
  select(name) %>% pull(name)

# Subset the world simple feature df
world_sf = world %>% 
  dplyr::filter(name %in% world_countries) %>% 
  select(name, geometry, region_un)

# Europe simple features
# Load the map and filter the countries
suppressPackageStartupMessages(library(sf))
#world = st_as_sf(rnaturalearth::countries110)
europe = world_sf %>% dplyr::filter(region_un=="Europe" & name!='Russia') %>% select(name, geometry)
# A bounding box for continental Europe.
europe.bbox = st_polygon(list(matrix(c(-25,29,45,29,45,75,-25,75,-25,29),byrow = T,ncol = 2)))
europe.clipped = suppressWarnings(st_intersection(europe, st_sfc(europe.bbox, crs=st_crs(europe))))
eu_countries = europe.clipped %>% dplyr::distinct(name) %>% pull(name)


# Rem: as the number of cases, deaths and healed are not measured/recorded each day, 
# I need to expand the data set for each possible combination (coutry, time). 
# If I don't do so, some countries will have missing records for some dates
# and the resulting GIF will be "blinking". Hopefuly, tidyr makes that easy with the function
# complete (equivalent to expand and join) and with fill (filling NA with the previous non-NA value).
# I'll use log scales, so better to avoid zero values
world_df = d['global'] %>% as_tibble %>% rename(confirm=cum_confirm) %>%
  filter(confirm >= 1 & country %in% world_countries) %>%  arrange(country, time) %>%
  tidyr::complete(country, time) %>% group_by(country) %>% 
  tidyr::fill(confirm, cum_dead, cum_heal) %>% ungroup %>% arrange(country, time)

world_df_dead = d['global'] %>% as_tibble %>% filter(cum_dead >= 1) %>% arrange(country, time) %>%
  tidyr::complete(country, time) %>% group_by(country) %>% 
  tidyr::fill(cum_confirm, cum_dead, cum_heal) %>% ungroup %>% arrange(country, time)

world_df_heal = d['global'] %>% as_tibble  %>% filter(cum_heal >= 1) %>% arrange(country, time) %>%
  tidyr::complete(country, time) %>% group_by(country) %>% 
  tidyr::fill(cum_confirm, cum_dead, cum_heal) %>% ungroup %>% arrange(country, time)

# date of the first case in Europe
eu_date_fc = world_df %>% dplyr::filter(country %in% eu_countries) %>% group_by(country) %>% 
  slice(which.min(confirm)) %>% ungroup %>% select(time) %>% pull(time) %>% min %>% as.Date()


# Plotting evolution overtime since the 100th case
breaks=c(1, 10, 100, 500, 1000, 5000, 10000, 20000)
dead = ggplot(dd, aes(days_since_100, dead, color = country)) +
  geom_line(size = 0.8) +
  geom_point(pch = 21, size = 1) +
  scale_y_log10(expand = expansion(add = c(0,0.5)), breaks = breaks, labels = breaks) +
  scale_x_continuous(expand = expansion(add = c(0,1.25))) +
  theme_fivethirtyeight() +
  geom_shadowtext(aes(label = paste0(" ",country)), hjust=0, vjust = 0, 
                  data = . %>% group_by(country) %>% top_n(1, days_since_100), bg.color = "white") +
  labs(x = "Number of days since 100th case", y = "", subtitle = "Total number of deaths (highlight > 1000)") + 
  theme(legend.position = "none") +
  #viridis::scale_colour_viridis(discrete = T) +
  scale_color_paletteer_d("ggthemes::gdoc") +
  gghighlight(max(dead) > 1000, use_direct_label = FALSE)

breaks=c(1, 10, 100, 500, 1000, 5000, 10000, 20000)
healed <- ggplot(dd, aes(days_since_100, heal, color = country)) +
  geom_line(size = 0.8) +
  geom_point(pch = 21, size = 1) +
  scale_y_log10(expand = expansion(add = c(0,0.5)), breaks = breaks, labels = breaks) +
  scale_x_continuous(expand = expansion(add = c(0,1.25))) +
  theme_fivethirtyeight() +
  geom_shadowtext(aes(label = paste0(" ",country)), hjust=0, vjust = 0, 
                  data = . %>% group_by(country) %>% top_n(1, days_since_100), bg.color = "white") +
  labs(x = "Number of days since 100th case", y = "", subtitle = "Total number of healed (highlight > 1000)") + 
  theme(legend.position = "none") +
  #viridis::scale_colour_viridis(discrete = T) +
  scale_color_paletteer_d("ggthemes::gdoc") +
  gghighlight(max(heal) > 1000, use_direct_label = FALSE)


breaks=c(1, 10, 100, 500, 1000, 5000, 10000, 50000, 100000)
confirmed <- ggplot(dd, aes(days_since_100, confirm, color = country)) +
  geom_line(size = 0.8) +
  geom_point(pch = 21, size = 1) +
  scale_y_log10(expand = expansion(add = c(0,0.5)), breaks = breaks, labels = breaks) +
  scale_x_continuous(expand = expansion(add = c(0,1.25))) +
  theme_fivethirtyeight() +
  geom_shadowtext(aes(label = paste0(" ",country)), hjust=0, vjust = 0, 
                  data = . %>% group_by(country) %>% top_n(1, days_since_100), bg.color = "white") +
  labs(x = "Number of days since 100th case", y = "", subtitle = "Total number of confirmed cases (highlight > 50 000)") + 
  theme(legend.position = "none") +
  scale_color_paletteer_d("ggthemes::gdoc") +
  gghighlight(max(confirm) > 50000, use_direct_label = FALSE)


# Arrange them on a grid, or save them separately 
cowplot::plot_grid(dead, healed, confirmed)



#########################
#                       #
#   EU - Geo-mapping    #
#                       #
#########################





# Plot the choropleth
## cases
### Filter the sarscov2 data 
last_df = world_df %>% group_by(country) %>% slice(which.max(time)) %>% dplyr::filter(country %in% eu_countries)
d_eu = world_df %>% dplyr::filter(country %in% eu_countries & time > eu_date_fc)
cov_eu_ts = left_join(d_eu, europe.clipped, by = c("country" = "name") )
cov_eu_ts = cov_eu_ts %>% arrange(country, time)
cov_eu_ts = st_as_sf(cov_eu_ts)
### Join with the geometry
cov_eu = left_join(last_df, europe.clipped, by = c("country" = "name") )
cov_eu = st_as_sf(cov_eu)
cov_fr = cov_eu_ts %>% dplyr::filter(country %in% c('France'))

### Static, last observation recorded
cases_eu = ggplot(data = cov_eu, aes(fill=confirm)) + geom_sf() + theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10") + 
  #scale_fill_viridis(option = 'plasma') +
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10") +
  ggtitle(label = 'Last observation') +
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50"))
### Animation
cases_eu_anim = ggplot() + geom_sf(data = europe.clipped) + 
  geom_sf(data = cov_eu_ts, aes(fill=confirm, group=country)) + 
  theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10") + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10") +
  transition_time(time) + 
  labs(title = "Tot. confimed cases \n date:  {frame_time}") + 
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50"))

animate(cases_eu_anim, fps = 3, renderer = gifski_renderer())
anim_save("eu_cases.gif")

## deaths
### Filter the sarscov2 data 
last_df = world_df_dead %>% group_by(country) %>% slice(which.max(time)) %>% dplyr::filter(country %in% eu_countries)
d_eu = world_df_dead %>% dplyr::filter(country %in% eu_countries & time > eu_date_fc)
cov_eu_ts = left_join(d_eu, europe.clipped, by = c("country" = "name") )
cov_eu_ts = cov_eu_ts %>% arrange(country, time)
cov_eu_ts = st_as_sf(cov_eu_ts)
### Join with the geometry
cov_eu = left_join(last_df, europe.clipped, by = c("country" = "name") )
cov_eu = st_as_sf(cov_eu)
cov_fr = cov_eu_ts %>% dplyr::filter(country %in% c('France'))
### Static, last observation
deaths_eu = ggplot(data = cov_eu, aes(fill=cum_dead)) + geom_sf() + theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10") + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10") +
  ggtitle(label = 'Last observation') +
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50"))
### Animation and gif
deaths_eu_anim = ggplot() + geom_sf(data = europe.clipped) +geom_sf(data = cov_eu_ts, aes(fill=cum_dead, group=country)) + theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10") + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10") +
  transition_time(time) + 
  labs(title = "Tot. deaths \n date: {frame_time}") + 
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50"))

animate(deaths_eu_anim, fps = 3, renderer = gifski_renderer())
anim_save("deaths_cases.gif", renderer = gifski_renderer())

## healed
### Filter the sarscov2 data 
last_df = world_df_heal %>% group_by(country) %>% slice(which.max(time)) %>% dplyr::filter(country %in% eu_countries)
d_eu = world_df_heal %>% dplyr::filter(country %in% eu_countries & time > eu_date_fc)
cov_eu_ts = left_join(d_eu, europe.clipped, by = c("country" = "name") )
cov_eu_ts = cov_eu_ts %>% arrange(country, time)
cov_eu_ts = st_as_sf(cov_eu_ts)
### Join with the geometry
cov_eu = left_join(last_df, europe.clipped, by = c("country" = "name") )
cov_eu = st_as_sf(cov_eu)
cov_fr = cov_eu_ts %>% dplyr::filter(country %in% c('France'))
### Static, last observation
healed_eu = ggplot(data = cov_eu, aes(fill=cum_healed)) + geom_sf() + theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10") + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10") +
  ggtitle(label = 'Last observation') +
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50"))
### Animation and gif
healed_eu_anim = ggplot() + geom_sf(data = europe.clipped) +geom_sf(data = cov_eu_ts, aes(fill=cum_heal, group=country)) + theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10") + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10") +
  transition_time(time) + 
  labs(title = "Tot. healed \n date: {frame_time}") + theme(plot.title = element_text(color="gray50", size=14))

animate(healed_eu_anim, fps = 3, renderer = gifski_renderer())
anim_save("healed_cases.gif")




#########################
#                       #
#  World - Geo-mapping  #
#                       #
#########################

# Clipping for better rendering
world.bbox = st_polygon(list(
  matrix(c(-170,-55, 170, -55, 170, 85,-170, 85, -170, -55),byrow = T,ncol = 2)))
world_sf = suppressWarnings(st_intersection(world_sf, st_sfc(world.bbox, crs=st_crs(world))))


# Plot the choropleth
## cases
### Filter the sarscov2 data 
last_df = world_df %>% group_by(country) %>% slice(which.max(time))
cov_world_ts = left_join(world_df, world_sf, by = c("country" = "name") )
cov_world_ts = cov_world_ts %>% arrange(country, time)
cov_world_ts = st_as_sf(cov_world_ts)
### Join with the geometry
cov_world = left_join(last_df, world_sf, by = c("country" = "name") )
cov_world = st_as_sf(cov_world)
### Static
cases_world = ggplot(data = cov_world, aes(fill=confirm)) + geom_sf() + theme_map() +
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50")) +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10", labels = scales::comma) + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10", labels = scales::comma) +
  ggtitle(label = paste0('Last observation, on ', cov_world$time[1])) 
# Animation and gif
cases_world_anim = ggplot() + geom_sf(data = world_sf) + 
  geom_sf(data = cov_world_ts, aes(fill=confirm, group=country)) +  theme_map() +
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50")) + 
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10", labels = scales::comma) + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10", labels = scales::comma) +
  transition_time(time) + labs(title = "Tot. confimed cases \n date:  {frame_time}") 
  
animate(cases_world_anim, fps = 3, renderer = gifski_renderer(), height = 400, width = 860)
anim_save("world_cases.gif")

## deaths
### Filter the sarscov2 data 
last_df = world_df_dead %>% group_by(country) %>% slice(which.max(time))
cov_world_ts = left_join(world_df_dead, world_sf, by = c("country" = "name") )
cov_world_ts = cov_world_ts %>% arrange(country, time)
cov_world_ts = st_as_sf(cov_world_ts)
### Join with the geometry
cov_world = left_join(last_df, world_sf, by = c("country" = "name") )
cov_world = st_as_sf(cov_world)
### Static
deaths_world = ggplot(data = cov_world, aes(fill=cum_dead)) + geom_sf() + theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10", labels = scales::comma) + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10", labels = scales::comma) +
  ggtitle(label = 'Last observation') +
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50"))
### Animation and gif
deaths_world_anim = ggplot() + geom_sf(data = world_sf) + 
  geom_sf(data = cov_world_ts, aes(fill=cum_dead, group=country)) + theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10", labels = scales::comma) + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10", labels = scales::comma) +
  transition_time(time) + 
  labs(title = "Tot. deaths \n date: {frame_time}") + 
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50"))

animate(deaths_world_anim, fps = 3, renderer = gifski_renderer(), height = 400, width = 860)
anim_save("world_deaths_cases.gif")

## healed
### Filter the sarscov2 data 
last_df = world_df %>% group_by(country) %>% slice(which.max(time))
cov_world_ts = left_join(world_df, world_sf, by = c("country" = "name") )
cov_world_ts = cov_world_ts %>% arrange(country, time)
cov_world_ts = st_as_sf(cov_world_ts)
### Join with the geometry
cov_world = left_join(last_df, world_sf, by = c("country" = "name") )
cov_world = st_as_sf(cov_world)
### Static
healed_world = ggplot(data = cov_world, aes(fill=cum_heal)) + geom_sf() + theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10", labels = scales::comma) +
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10", labels = scales::comma) +
  ggtitle(label = 'Last observation') +
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50"))
### Animation and gif
healed_world_anim = ggplot() + geom_sf(data = world_sf) + 
  geom_sf(data = cov_world_ts, aes(fill=cum_heal, group=country)) + theme_map() +
  #scico::scale_fill_scico(palette = 'batlow', trans = "log10", labels = scales::comma) + 
  scale_fill_gradientn(colours = pals::kovesi.rainbow(100), trans = "log10", labels = scales::comma) +
  transition_time(time) + 
  labs(title = "Tot. healed \n date: {frame_time}") + 
  theme(plot.title = element_text(color="gray50", size=14), legend.title = element_text(color="gray50"))

animate(healed_world_anim, fps = 3, renderer = gifski_renderer(), height = 400, width = 860)
anim_save("world_healed_cases.gif")