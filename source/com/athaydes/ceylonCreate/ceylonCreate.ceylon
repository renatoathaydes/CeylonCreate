
shared String defaultProjectName = "myProject";
shared String defaultModuleName = "myModule";
shared String prompt = ">";

String invalidProjectNameErrorMessage =
        """Please enter a valid project name.
           A valid project name must contain only characters which are generally acceptable in file names.""";

String invalidModuleNameErrorMessage =
        """Please enter a valid module name.
           A valid module name must:
               - contain only letters and digits.
               - not contain any keywords.
               - start with a lower-cased letter.""";

Character[] validProjectNameSpecialChars = ['_', '-', '(', ')', '[', ']', '{', '}', ',', ' '];

[String+] ceylonKeywords = [ "assembly", "module", "package", "import", "alias", "class", "interface", "object",
        "given", "value", "assign", "void", "function", "new", "of", "extends", "satisfies", 
        "abstracts", "in", "out", "return", "break", "continue", "throw", "assert", "dynamic",
        "if",  "else",  "switch",  "case",  "for", "while", "try", "catch", "finally", "then",
        "let",  "this",  "outer",  "super",  "is",  "exists",  "nonempty" ];
        
alias Invalid => Null;
Invalid invalid = null;

void ceylonCreate(Options options) {
    value write = options.quiet then (void(String s) {}) else process.writeLine; 
    
    write(
        """
           ******* Welcome to CeylonCreate! *******
           
           To create your new project/module(s), you just need to answer a few questions first!
           If you are unsure about a question, just hit 'Enter' to use the default values shown inside [].
           """);
    
    if (exists projectName = options.projectName) {
        if (validateProjectName(projectName) is Invalid) {
            throw Exception(invalidProjectNameErrorMessage);
        }
        write("Creating project '``projectName``'");
    } else {
        write("What will be the name of your project?");
    }
    value projectName = options.projectName else acceptValidAnswer(options.quiet, process.readLine,
        validateProjectName, invalidProjectNameErrorMessage, defaultProjectName);
    
    if (exists moduleName = options.moduleName) {
        if (validateModuleName(moduleName) is Invalid) {
            throw Exception(invalidModuleNameErrorMessage);
        }
        write("Creating module '``moduleName``'");
    } else {
        write("""A project must contain at least one module.
                 What would you like to call your module?""");
    }
    value moduleName = options.moduleName else acceptValidAnswer(options.quiet, process.readLine,
        validateModuleName, invalidModuleNameErrorMessage, moduleNameFromValidProjectName(projectName));
    variable {String+} allModules = { moduleName };

    allModules = askAboutTestModule(options, moduleName, allModules);
    
    if (options.moduleName is Null) {
        while (acceptYesOrNoAnswer(options.quiet, "Would you like to create another module?", process.readLine, "no")) {
            write("Please enter the module name.");
            value extraModule = acceptValidAnswer(options.quiet, process.readLine,
                validateModuleName, invalidModuleNameErrorMessage);
            allModules = allModules.chain { extraModule };
            allModules = askAboutTestModule(options, extraModule, allModules);
        }    
    }
    
    value createEclipseFiles = options.noEclipse then false else acceptYesOrNoAnswer(options.quiet,
        """Creating Eclipse files will allow you to easily import your project into the Eclipse IDE.
           Do you want to create Eclipse files?""", process.readLine, "yes");
    
    createAllFiles(projectName, allModules.sequence, createEclipseFiles);
    printReport(projectName, allModules, createEclipseFiles, write);
}

{String+} askAboutTestModule(Options options, String moduleName, {String+} allModules) {
    value createTestModule = options.noTest then false else acceptYesOrNoAnswer(options.quiet,
        "Would you like to create a test module for ``moduleName``?",
        process.readLine, "yes");
    
    if (createTestModule) {
        return allModules.chain { "test.``moduleName``" };
    } else {
        return allModules;
    }
}

shared String? validateProjectName(String name) {
    value trimmedName = name.trimmed;
    function validProjectNameChar(Character c) => c.letter ||
            c.digit || c in validProjectNameSpecialChars;
    if (!trimmedName.empty,
        trimmedName.every(validProjectNameChar)) {
        return trimmedName;
    }
    return invalid;
}

Boolean validModuleNameFirstChar(Character c) => c.lowercase || c == '_';

shared String? validateModuleName(String name) {
    value trimmedName = name.trimmed;
    function validModuleNameChar(Character c) => c.letter || c.digit || c in ['_', '.' ];
    if (!trimmedName.empty,
        validModuleNameFirstChar(trimmedName.first else 'X'),
        trimmedName.every(validModuleNameChar),
        !(trimmedName.split('.'.equals, true, false)).containsAny(ceylonKeywords.chain {""})) {
        return trimmedName;
    }
    return invalid;
}

shared String? validateTestModuleName(String name) {
    if (exists moduleName = validateModuleName(name),
        testModuleName(moduleName)) {
        return moduleName;
    } else {
        return invalid;
    }
}

shared Boolean testModuleName(String moduleName) => moduleName.startsWith("test.");

Character ensureValidModuleNameFirstChar(Character? first) {
    assert(exists first);
    if (validModuleNameFirstChar(first)) {
        return first;
    } else if (first.letter) {
        return first.lowercased;
    } else {
        return '_';
    }
}

shared String moduleNameFromValidProjectName(String name) {
    function needsReplacement(Character c) => !c.digit && !c.letter;
    String candidateName = String {
        for (c in { ensureValidModuleNameFirstChar(name.first) }.chain(name.rest))
        needsReplacement(c) then '_' else c
    };
    if (candidateName.every((Character c) => c == '_')) {
        return defaultModuleName;
    } else {
        return candidateName;
    }
}

shared String acceptValidAnswer(Boolean quiet, String?() ask, String?(String) validate,
                                String errorMessage, String? default = null,
                                Integer maxTries = 3, String(String) onTooManyInvalidAnswers = exit) {
    if (quiet) {
        assert(exists default);
        return default;
    }
    process.write("[``default else ""``]" + prompt);
    variable value tries = maxTries;
    while (exists answer = ask()) {
        if (exists default, answer.trimmed.empty) {
            return default;
        }
        else if (exists validAnswer = validate(answer)) {
            return validAnswer;
        }
        else {
            if (--tries <= 0) {
                break;
            }
            print(errorMessage);
            process.write("[``default else ""``]" + prompt);
        }
    }
    return onTooManyInvalidAnswers("""Too many invalid answers! No project or module created.
                                      Please try again.""");
}

shared Boolean acceptYesOrNoAnswer(Boolean quiet, String question, String?() ask, String default) {
    String validAnswer;
    if (!quiet) {
        print(question);
        function validateYesOrNo(String answer) {
            if (answer.trimmed.lowercased in ["y", "yes", "n", "no"]) {
                return answer.trimmed.lowercased;
            } else {
                return null;
            }
        }
        validAnswer = acceptValidAnswer(false, ask, validateYesOrNo, "Enter yes/y or no/n", default);    
    } else {
        validAnswer = default;
    }
    
    switch(validAnswer)
    case ("yes", "y") {
        return true;
    }
    case ("no", "n") {
        return false;
    }
    else {
        return exit("""Too many invalid answers! No project or module created.
                       Please try again.""");
    }
}

void printReport(String projectName, {String+} allModules, Boolean createEclipseFiles, void write(String s)) {
    print("Created project ``projectName``");
    for (modName in allModules.sequence) {
        print("Created module ``modName``");
    }
    if (createEclipseFiles) {
        write("""
                 To import your project into Eclipse, follow the instructions on:
                 <http://help.eclipse.org/helios/index.jsp?topic=%2Forg.eclipse.platform.doc.user%2Ftasks%2Ftasks-importproject.htm>""");
    }
    write("");
    write("Change to your project's root directory by typing:");
    write("    cd \"``projectName``\"");
    write("You can then compile your modules with, for example:");
    write("    ceylon compile ``allModules.first``");
    write("After compiling, you can run the module:");
    write("    ceylon run ``allModules.first``/1.0.0");
    write("");
}

Nothing exit(String message) {
    throw Exception(message);
}
