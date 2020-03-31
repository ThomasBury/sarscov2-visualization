<img src="pics/bender_hex.png" style="position:absolute;top:0px;right:0px;" width="120px" align="right" />


Geo-mapping the evolution of sars-cov-2
================
Human Bender
2020-03-30


Introduction
============
A small Rscript to fetch and plot the sars-cov-2 data on maps, both for Europe and worlwide
The script might take some time to run and generate the GIFs

Output
======================================

Static charts 
----------------
highlighting the countries counting the largest numbers of case, healed and deaths
 
![static charts](/pics/countries.png)

Animated charts
------------------

![eu_cases](/pics/eu_cases.gif)
![eu_deaths](/pics/deaths_cases.gif)
![eu_healed](/pics/healed_cases.gif)
![w_cases](/pics/world_cases.gif)
![w_deaths](/pics/world_deaths_cases.gif)
![w_healed](/pics/world_healed_cases.gif)


Session info
=================

```r
> sessionInfo()
R version 3.6.3 (2020-02-29)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows >= 8 x64 (build 9200)

Matrix products: default

Random number generation:
 RNG:     Mersenne-Twister 
 Normal:  Inversion 
 Sample:  Rounding 
 
locale:
[1] LC_COLLATE=French_Belgium.1252  LC_CTYPE=French_Belgium.1252    LC_MONETARY=French_Belgium.1252
[4] LC_NUMERIC=C                    LC_TIME=French_Belgium.1252    

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] purrr_0.3.3         extrafont_0.17      ggthemes_4.2.0      gifski_0.8.6        gganimate_1.0.5    
 [6] ggmap_3.0.0         scico_1.1.0         st_1.2.5            sda_1.3.7           fdrtool_1.2.15     
[11] corpcor_1.6.9       entropy_1.2.1       tmap_2.3-2          sf_0.9-0            rnaturalearth_0.1.0
[16] maps_3.3.0          cowplot_1.0.0       paletteer_1.1.0     gghighlight_0.2.0   viridis_0.5.1      
[21] viridisLite_0.3.0   nCov2019_0.3.4      shadowtext_0.0.7    ggplot2_3.3.0       dplyr_0.8.5        

loaded via a namespace (and not attached):
 [1] bitops_1.0-6        RColorBrewer_1.1-2  progress_1.2.2      httr_1.4.1          tools_3.6.3        
 [6] utf8_1.1.4          rgdal_1.4-8         R6_2.4.1            KernSmooth_2.23-16  rgeos_0.5-2        
[11] DBI_1.1.0           colorspace_1.4-1    raster_3.0-12       withr_2.1.2         sp_1.4-1           
[16] tidyselect_1.0.0    gridExtra_2.3       prettyunits_1.1.1   leaflet_2.0.3       extrafontdb_1.0    
[21] compiler_3.6.3      cli_2.0.2           prismatic_0.2.0     labeling_0.3        jcolors_0.0.4      
[26] scales_1.1.0        classInt_0.4-2      stringr_1.4.0       digest_0.6.25       dichromat_2.0-0    
[31] jpeg_0.1-8.1        pkgconfig_2.0.3     htmltools_0.4.0     oompaBase_3.2.9     palr_0.2.0         
[36] htmlwidgets_1.5.1   rlang_0.4.5         pals_1.6            rstudioapi_0.11     farver_2.0.3       
[41] jsonlite_1.6.1      crosstalk_1.1.0.1   magrittr_1.5        Rcpp_1.0.4          munsell_0.5.0      
[46] fansi_0.4.1         lifecycle_0.2.0     stringi_1.4.6       leafsync_0.1.0      yaml_2.2.1         
[51] tmaptools_2.0-2     plyr_1.8.6          grid_3.6.3          crayon_1.3.4        lattice_0.20-38    
[56] transformr_0.1.1    mapproj_1.2.7       hms_0.5.3           pillar_1.4.3        rjson_0.2.20       
[61] lpSolve_5.6.15      codetools_0.2-16    XML_3.99-0.3        glue_1.3.2          downloader_0.4     
[66] vctrs_0.2.4         png_0.1-7           tweenr_1.0.1        Rttf2pt1_1.3.8      RgoogleMaps_1.4.5.3
[71] gtable_0.3.0        tidyr_1.0.2         rematch2_2.1.1      assertthat_0.2.1    lwgeom_0.2-1       
[76] e1071_1.7-3         class_7.3-15        tibble_2.1.3        units_0.6-6         cluster_2.1.0      
[81] ellipsis_0.3.0     
```