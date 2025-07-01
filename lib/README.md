This directory contains local library scripts (scripts containing helper functions)

`common.R` is the startup script loaded when using `workspace::launch()` (it loads all files listed in .Rworkspace)

Other files are functions used for specific topic.

To avoid path problem, it's better to load these files using `share.lib()` function, available once workspace is loaded. 

For example, to load the describe.R file use

```R
share.lib('describe')
```

This allows to run scripts if the working directory is the root directory of the project or if it's in a sub directory of it. 
It wont work if the working directory of R is outside the project. Path of files are inferred from the root of the project.