# datamovies

SAS code for producing data movies.

This program contains instructions and code to produce various types of data movies in SAS. Data movies can be used to investigate trends in the epidemiology of disease (e.g. case counts, risks, rates) across multiple population characteristics at once (e.g. age, sex, race, geographic region).

A separate macro is provided for each type of data movie. All macros require inputting a dataset with one row per time interval, per cross-classification of all stratification variables. Detailed instructions are provided in the code.

  1. %histogram: Produces movies in histogram format. Requires an integer response, continuous time interval, and one continuous and two additional binary or categorical stratification variables.
  2. %line: Produces movies in line or band plot format. Requires a continuous response, continuous time interval, and one continuous and two additional binary or categorical stratification variables.
  3. %butterfly: Produces movies in butterfly plot format. Requires an integer response, continuous time interval, and one binary and two additional binary or categorical stratification variables.
