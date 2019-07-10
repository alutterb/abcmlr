# Installing abcmlr
1. Type `devtools::install_github("alutterb/abcmlr")` in the R console
2. Download both `Translator.exe` and `abcml` found in this repository.
3. Place `abcml` in your `PATH` (see below on how to find your `PATH` for windows, putting it in system32 is usually a safe bet), and place `Translator.exe` in the same directory as your data
4. Download [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) 

# Using abcmlr
1. Ensure that your working directory is the same location as your data and `Translator.exe` (check with `getwd()`)
2. Load `abcmlr` with `library("abcmlr")` then using `abcml_tcltk()` or by typing `abcmlr::abcml_tcltk()` in the R console
3. In the GUI, type the name of your data file (MUST BE .CSV), i.e: data.csv
4. Command line uses commands specific to Rogers' program. See documentation below. -a is a good one to use.

Rogers' Documentation: http://content.csbs.utah.edu/~rogers/abcml/doc/main.html

# Finding your PATH

type `env` in windows search, go to advanced tab, then click on environment variable. Under system variables, look for `Path`. Double click on it and you will get a list of directories. Placing abcml in any of these will work.
