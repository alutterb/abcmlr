# Installing abcmlr
1. Type `install.packages("devtools")` in the R console
2. Type `library(devtools)` in the R console
3. Type `devtools::install_github("alutterb/abcmlr")` in the R console
4. Download both `Translator.exe` and `abcml` found in this repository.
5. Place the `abcml` file in your `PATH` (see below on how to find your `PATH` for windows), and place `Translator.exe` in the same directory as your data
6. Download [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) 

# Using abcmlr
1. Ensure that your working directory is the same location as your data and `Translator.exe` (check with `getwd()`). You can change the working directory using `setwd()`, i.e: `setwd(C:/Users/name/library)` (make sure to use FORWARD slashes, R does not read backslahes)
2. Load `abcmlr` with `library("abcmlr")` then using `abcml_tcltk()` or by typing `abcmlr::abcml_tcltk()` in the R console
3. In the GUI, type the name of your data file (must be .CSV in a similar form as HazdaConfigurationFiles.csv) 
4. Command line uses commands specific to Rogers' program. See documentation below. Before typing your commands, specify the nth agent of deposition as "agentn.cfg". Separate by spaces only. 

Example of command line input (no quotes): "agent1.cfg agent2.cfg -a"
(This states that there are two agents of deposition recognized in the data, and we want to estimate attrition.)

Rogers' Documentation: http://content.csbs.utah.edu/~rogers/abcml/doc/main.html

# Finding your PATH

type `env` in windows search, go to advanced tab, then click on environment variable. Under system variables, look for `Path`. Double click on it and you will get a list of directories. Placing abcml in any of these will work.
