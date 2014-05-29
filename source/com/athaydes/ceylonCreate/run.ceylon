"Run the module `com.athaydes.ceylonCreate`."
shared void run() {
    if (process.namedArgumentPresent("help")) {
        printHelp();
    } else {
        try {
            ceylonCreate(Options {
                quiet =       process.namedArgumentPresent("quiet");
                projectName = process.namedArgumentValue("projectName");
                moduleName =  process.namedArgumentValue("moduleName");
                noTest =      process.namedArgumentPresent("noTest");
                noEclipse =   process.namedArgumentPresent("noEclipse");
            });
        } catch(Throwable e) {
            print("ERROR: ``e``");
        }
    }
}

void printHelp() {
    value version = `module com.athaydes.ceylonCreate`.version;
    print(interpolate(
        """
           ************** ceylonCreate **************
           Creates new Ceylon projects and modules.
             
           Usage:
               ceylon run com.athaydes.ceylonCreate/``version`` [option]
           
           Options:
               help          - displays this help and exit 
               quiet         - do not ask questions, use defaults or passed arguments
               projectName   - project name
               moduleName    - module name
               noTest        - do not create test modules
               noEclipse     - do not create Eclipse files
             
           Examples:
             
           - Create a project called 'Good Times', asking iteractively about other settings:
               ceylon run com.athaydes.ceylonCreate/``version`` --projectName="Good Times"
               
           - Create a project using all the default values:
               ceylon run com.athaydes.ceylonCreate/``version`` --quiet
           
           To provide feedback or report bugs, visit <https://github.com/renatoathaydes/CeylonCreate/>
           """, "version" -> version));
}

shared class Options(
    shared Boolean quiet,
    shared String? projectName,
    shared String? moduleName,
    shared Boolean noTest,
    shared Boolean noEclipse) {}
