CeylonCreate
============

A Ceylon tool to easily create new Ceylon project and modules

###   Usage:
       ceylon run com.athaydes.ceylonCreate/1.0.0 [option]
   
###   Options:
       help          - display this help and exit 
       quiet         - do not ask questions, use defaults or passed arguments
       projectName   - project name
       moduleName    - module name
       noTest        - do not create test modules
       noEclipse     - do not create Eclipse files
       output        - output directory (defaults to current directory)

###   Examples:
     
   - Create a project called 'Good Times', asking iteractively about other settings:
       
```
ceylon run com.athaydes.ceylonCreate/1.0.0 --projectName="Good Times"
```
    
   - Create a project using all the default values:

```
ceylon run com.athaydes.ceylonCreate/1.0.0 --quiet
```   

Once you've created a project, you can import it into Eclipse by following the instructions on:

http://help.eclipse.org/helios/index.jsp?topic=%2Forg.eclipse.platform.doc.user%2Ftasks%2Ftasks-importproject.htm


To provide feedback or report bugs, visit <https://github.com/renatoathaydes/CeylonCreate/>


