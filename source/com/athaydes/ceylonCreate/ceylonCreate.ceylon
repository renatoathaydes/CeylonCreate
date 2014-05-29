
shared String defaultProjectName = "myProject";
shared String defaultModuleName = "myModule";
shared String prompt = ">";
String invalidProjectNameErrorMessage =
        """Please enter a valid project name.
           A valid project name must contain only letters and digits, and must start with a letter.""";
String invalidModuleNameErrorMessage =
        """Please enter a valid project name.
           A valid project name must contain only letters and digits, and must start with a letter.""";

Character[] validProjectNameSpecialChars = ['_', '-', '(', ')', '[', ']', '{', '}', ',', ' '];

void ceylonCreate(Boolean quiet) {
    value write = quiet then (void(String s) {}) else process.writeLine; 
    
    write(
        """******* Welcome to CeylonCreate! *******
           
           To create your new project/module(s), you just need to answer a few questions first!
           If you are unsure about a question, just hit 'Enter' to use the default values shown inside [].
           
           What will be the name of your project?""");
    value projectName = acceptValidAnswer(quiet, process.readLine,
        validateProjectName, invalidProjectNameErrorMessage, defaultProjectName);
    
    write("""A project must contain at least one module.
             What would you like to call your module?""");
    
    variable {String*} allModules = {};
    
    value moduleName = acceptValidAnswer(quiet, process.readLine,
        validateModuleName, invalidModuleNameErrorMessage, moduleNameFromValidProjectName(projectName));
    allModules = allModules.chain { moduleName };
    
    allModules = askAboutTestModule(quiet, moduleName, allModules);
    
    while (acceptYesOrNoAnswer(quiet, "Would you like to create another module?", process.readLine, "no")) {
        write("Please enter the module name.");
        value extraModule = acceptValidAnswer(quiet, process.readLine,
            validateModuleName, invalidModuleNameErrorMessage);
        allModules = allModules.chain { extraModule };
        allModules = askAboutTestModule(quiet, extraModule, allModules);
    }
    
    value createEclipseFiles = acceptYesOrNoAnswer(quiet,
        """Creating Eclipse files will allow you to easily import your project into the Eclipse IDE.
           Do you want to create Eclipse files?""", process.readLine, "yes");
    
    try {
        createAllFiles(projectName, allModules.sequence, createEclipseFiles);
        
        print("Created project ``projectName``");
        for (modName in allModules.sequence) {
            print("Created module ``modName``");
        }
    } catch(Throwable e) {
        value message = e.message.trimmed.empty then e.string else e.message;
        print("ERROR: ``message``");
    }
    
}

{String*} askAboutTestModule(Boolean quiet, String moduleName, {String*} allModules) {
    value createTestModule = acceptYesOrNoAnswer(quiet,
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
    return null;
}

Boolean validModuleNameFirstChar(Character c) => c.lowercase || c == '_';

shared String? validateModuleName(String name) {
    value trimmedName = name.trimmed;
    function validModuleNameChar(Character c) => c.letter || c.digit || c in ['_', '.' ];
    if (!trimmedName.empty,
        validModuleNameFirstChar(trimmedName.first else 'X'),
        trimmedName.every(validModuleNameChar),
        !trimmedName.contains(".."),
        !trimmedName.endsWith(".")) {
        return trimmedName;
    }
    return null;
}

shared String? validateTestModuleName(String name) {
    if (exists moduleName = validateModuleName(name),
        testModuleName(moduleName)) {
        return moduleName;
    } else {
        return null;
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
                                Integer maxTries = 3, String() onTooManyInvalidAnswers = exit) {
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
    return onTooManyInvalidAnswers();
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
        return exit();
    }
}

Nothing exit() {
    print("""Too many invalid answers! No project or module created.
             Please try again.""");
    process.exit(1);
    throw;
}
