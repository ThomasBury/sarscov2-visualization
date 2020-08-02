Loading the data
================

The data are collected from the Johns Hopkins University Center for Systems Science and Engineering and cleaned by datahub (see [This repo](https://github.com/datasets/covid-19)). In order to normalize the time axis, I filtered the data to retain the data since the 100th case has been reported. I filter out small countries (population less than 10000) and countries which are not in the world SF file, for convenience.

As the number of cases, deaths and healed are not measured/recorded each day, I need to expand the data set for each possible combination (country, time). If I don't do so, some countries will have missing records for some dates and the resulting charts and GIF will be "blinking". Hopefully, tidyr makes that easy with the function complete (equivalent to expand and join) and with fill (filling NA with the previous non-NA value). I'll use log scales, so better to avoid zero values.

    ## although coordinates are longitude/latitude, st_intersection assumes that they are planar

How large is the pandemic?
==========================

First of all, a sensible question to ask is what is the magnitude order of the pandemic. Because, there is a very sensitive trade-off between impacting the whole population of a country, at the risk that some households would go bankrupt and all the consequences that it would have, and save lives. Even if life has no value, induced poverty could affect a much more important part of the population and have long term consequences which could be even worst than the immediate effect of the virus.

Moreover, by digging deeper, the consequences of the virus could have been mitigated. Taking Belgium as an example, where 70% of the deaths are Patients from rest houses, whereas the death rate per capita in Sweden is much lower while they didn't lock-down the country. Of course, there are a lot of factors, but we might ask: did the politics act rationally, and did they protect the population correctly while preserving the well being of the rest of the population, especially those struggling for the day to day living? Obviously the answer is no, for Belgium at least. Is the forthcoming boom of the unemployment rate worth the price? What would be the benefit of the actual virus management? All those questions are delicate and deserve a profound reflection. I'll not dare to answer but I'll just provide the magnitude order so far of the virus compared to the overall yearly mortality for some countries.

Raw ranking
-----------

The issue is that there is no common definition of what is a "covid death". Therefore the absolute numbers cannot really be related (excepted if two countries share the same definition) however, the resulting ranking can still make sense.

<img src="covid19_files/figure-markdown_github/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

Excess mortality
----------------

One can remove the bias of the definition by using the excess mortality however, we cannot rule out other causes (or deaths indirectly caused by covid such as the saturation of hospital capacity). The zero baseline represents the average of deaths, all causes.

### Absolute numbers per million inhabitants

<img src="covid19_files/figure-markdown_github/unnamed-chunk-10-1.png" style="display: block; margin: auto;" />

### Excess in percentage of expected number of deaths

#### Monthly

A better way to quantify is to express the excess in the percentage of the expected number of deaths, to quantify the increase relative to the historical expectation.

<img src="covid19_files/figure-markdown_github/unnamed-chunk-11-1.png" style="display: block; margin: auto;" />

#### Weekly

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="covid19_files/figure-markdown_github/unnamed-chunk-12-1.png" style="display: block; margin: auto;" />

### Are excess and covid deaths matching?

The excess mortality is not necessarily due *only* to the covid, some other causes might exist (indirect deaths due to the lack of hospital capacity or any other cause, which can be specific to a country). However, we might expect the excess and covid deaths to match if the definition of "covid death" set by the authorities is consistent.

In the following illustrations, the area stands for the reported covid deaths, the line for the excess death and the zero value for the average of deaths (all causes).

<img src="covid19_files/figure-markdown_github/unnamed-chunk-13-1.png" style="display: block; margin: auto;" />

<img src="covid19_files/figure-markdown_github/unnamed-chunk-14-1.png" style="display: block; margin: auto;" />

Top 5 countries, aggregate figures - Worldwide and in EU
========================================================

Top 5 countries, absolute and per million of inhabitants figures Absolute numbers illustrate that the larger the country the more cases (not necessarily following the population ranking). The relative numbers (per million of inhabitants) illustrate how the country is globally dealing with the crisis (of course, density and other parameters make the fight harder, but mostly the policy, how quick we react and analytics usage are involved). BE is part of the 5 worst countries, using relative numbers. Especially for the number of deaths per million. This is mainly due to inefficient policies, especially regarding the rest houses (accounting for 50% of the deaths in BE)

Worldwide
---------

    ## label_key: country
    ## label_key: country
    ## label_key: country
    ## label_key: country
    ## label_key: country
    ## label_key: country

<img src="covid19_files/figure-markdown_github/unnamed-chunk-15-1.png" style="display: block; margin: auto;" /><img src="covid19_files/figure-markdown_github/unnamed-chunk-15-2.png" style="display: block; margin: auto;" /><img src="covid19_files/figure-markdown_github/unnamed-chunk-15-3.png" style="display: block; margin: auto;" />

Europe
------

Highlighting the most impacted countries in EU.

    ## label_key: country
    ## label_key: country
    ## label_key: country
    ## label_key: country
    ## label_key: country
    ## label_key: country

<img src="covid19_files/figure-markdown_github/unnamed-chunk-16-1.png" style="display: block; margin: auto;" /><img src="covid19_files/figure-markdown_github/unnamed-chunk-16-2.png" style="display: block; margin: auto;" /><img src="covid19_files/figure-markdown_github/unnamed-chunk-16-3.png" style="display: block; margin: auto;" />

Some countries without national lockdown
----------------------------------------

The case of Sweden, for instance, is a bit particular since they didn't apply a national lockdown while most of the other EU countries did. Did it work? Apparently, this decision was pretty armful for the population.

    ## label_key: country
    ## label_key: country
    ## label_key: country
    ## label_key: country
    ## label_key: country
    ## label_key: country

<img src="covid19_files/figure-markdown_github/unnamed-chunk-17-1.png" style="display: block; margin: auto;" /><img src="covid19_files/figure-markdown_github/unnamed-chunk-17-2.png" style="display: block; margin: auto;" /><img src="covid19_files/figure-markdown_github/unnamed-chunk-17-3.png" style="display: block; margin: auto;" />

Weekly new cases
================

Worldwide 16 top countries
--------------------------

<img src="covid19_files/figure-markdown_github/unnamed-chunk-18-1.png" style="display: block; margin: auto;" />

Europe - 16 countries randomly chosen
-------------------------------------

<img src="covid19_files/figure-markdown_github/unnamed-chunk-19-1.png" style="display: block; margin: auto;" />

Geomapping
==========

EU
--

### Observations of the last full week

<img src="covid19_files/figure-markdown_github/unnamed-chunk-21-1.png" style="display: block; margin: auto;" />

### Animation by week since the 100th case

<img src="covid19_files/figure-markdown_github/unnamed-chunk-22-1.gif" style="display: block; margin: auto;" />

or if you don't like GIFs, using facet:

<img src="covid19_files/figure-markdown_github/unnamed-chunk-23-1.png" style="display: block; margin: auto;" />

World
-----

    ## although coordinates are longitude/latitude, st_intersection assumes that they are planar

### Observations of the last full week

<img src="covid19_files/figure-markdown_github/unnamed-chunk-25-1.png" style="display: block; margin: auto;" />

### Animation by week since the 100th case

<img src="covid19_files/figure-markdown_github/unnamed-chunk-26-1.gif" style="display: block; margin: auto;" />

USA - regional data
===================

The regional US data are fetch from the NY Times github [NY Times github](https://github.com/nytimes/covid-19-data)

Last observations
-----------------

<img src="covid19_files/figure-markdown_github/unnamed-chunk-28-1.png" style="display: block; margin: auto;" />

Evolution over time
-------------------

Using GIF

<img src="covid19_files/figure-markdown_github/unnamed-chunk-29-1.gif" style="display: block; margin: auto;" />

or facet plot

<img src="covid19_files/figure-markdown_github/unnamed-chunk-30-1.png" style="display: block; margin: auto;" />

Evolution per State
-------------------

    ## label_key: state
    ## label_key: state

<img src="covid19_files/figure-markdown_github/unnamed-chunk-32-1.png" style="display: block; margin: auto;" />
