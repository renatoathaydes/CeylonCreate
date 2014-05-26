
String defaultProjectName = "myProject";
String prompt = ">";
String invalidProjectNameErrorMessage =
        """Please enter a valid project name.
           A valid project name must contain only letters and digits, and must start with a letter.""";
String invalidModuleNameErrorMessage =
        """Please enter a valid project name.
           A valid project name must contain only letters and digits, and must start with a letter.""";

void ceylonCreate() {
    print(
        """Welcome to CeylonCreate!
           To create your new project/module(s), you just need to answer a few questions first!
           If you want, you can just hit 'Enter' to use the suggested default values shown inside [].
           
           What will be the name of your project?""");
    value projectName = acceptValidAnswer(process.readLine,
        validateProjectName, invalidProjectNameErrorMessage, defaultProjectName);
    
    print("""A project must contain at least one module.
             What would you like to call your module?""");
    
    value allModules = SequenceBuilder<String>();
    
    value moduleName = acceptValidAnswer(process.readLine,
        validateModuleName, invalidModuleNameErrorMessage, projectName);
    allModules.append(moduleName);
    
    value createTestModule = acceptYesOrNoAnswer("Would you like to create a test module?", process.readLine, "yes");
    if (createTestModule) {
        print("Please give a name to your test module. Its name must start with 'test.'.");
        value defaultTestModuleName = "test.``moduleName``";
        value testModuleName = acceptValidAnswer(process.readLine, validateTestModuleName,
            invalidModuleNameErrorMessage + "\nIt must also start with 'test.'", defaultTestModuleName);
        allModules.append(testModuleName);
    }
    
    while (acceptYesOrNoAnswer("Would you like to create another module?", process.readLine, "no")) {
        print("Please enter the module name.");
        value extraModule = acceptValidAnswer(process.readLine,
            validateModuleName, invalidModuleNameErrorMessage);
        allModules.append(extraModule);
    }
    
    print("Creating project ``projectName``");
    for (modName in allModules.sequence) {
        print("Creating module ``modName``");
    }
    
}

shared String? validateProjectName(String name) {
    if (!name.trimmed.empty) {
        //TODO actual validation
        return name.trimmed;
    } else {
        return null;
    }
}

shared String? validateModuleName(String name) {
    if (!name.trimmed.empty) {
        //TODO actual validation
        return name.trimmed;
    } else {
        return null;
    }
}

shared String? validateTestModuleName(String name) {
    if (exists moduleName = validateModuleName(name), moduleName.startsWith("test.")) {
        return moduleName;
    } else {
        return null;
    }
}

shared String acceptValidAnswer(String?() ask, String?(String) validate,
                                String errorMessage, String? default = null,
                                Integer maxTries = 3, String() onTooManyInvalidAnswers = exit) {
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

shared Boolean acceptYesOrNoAnswer(String question, String?() ask, String default) {
    print(question);
    function validateYesOrNo(String answer) {
        if (answer.trimmed.lowercased in ["y", "yes", "n", "no"]) {
            return answer.trimmed.lowercased;
        } else {
            return null;
        }
    }
    value validAnswer = acceptValidAnswer(ask, validateYesOrNo, "Enter yes/y or no/n", default);
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
