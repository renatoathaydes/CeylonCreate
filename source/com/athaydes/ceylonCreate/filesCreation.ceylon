import ceylon.file {
    current,
    Nil,
    Directory,
    parsePath,
    File
}

shared void createAllFiles(String projectName, {String*} moduleNames,
    String root = current.absolutePath.string) {
    value projectPath = parsePath(root).childPath(projectName);
    
    "There is already a directory at the target project location. Cannot create project."
    assert(is Nil projectResource = projectPath.resource);
    
    value projectDir = projectResource.createDirectory();
    value sourcePath = projectDir.path.childPath("source");
    value resourcePath = projectDir.path.childPath("resource");
    assert(is Nil sourceRs = sourcePath.resource, is Nil resourceRs = resourcePath.resource);
    
    resourceRs.createDirectory();
    value sourceDirectory = sourceRs.createDirectory();
    
    for (moduleName in moduleNames) {
        createDirectories(sourceDirectory, moduleName);
        createFiles(sourceDirectory, moduleName);
    }

}

void createDirectories(Directory sourceDirectory, String moduleName) {
    variable value currentPath = sourceDirectory.path;
    for (namePart in moduleName.split('.'.equals)) {
        value rs = currentPath.childPath(namePart).resource;
        assert(is Nil rs);
        rs.createDirectory();
        currentPath = rs.path;
    }
}

void createFiles(Directory sourceDirectory, String moduleName) {
    value modulePath = sourceDirectory.path.childPath(moduleName.replace(".", "/"));
    assert(is Directory moduleDir = modulePath.resource);
    createModuleFile(moduleDir, moduleName);
    createPackageFile(moduleDir, moduleName);
    createRunFile(moduleDir, moduleName);
}

void createModuleFile(Directory moduleDirectory, String moduleName) {
    assert(is Nil moduleFilePath = moduleDirectory.path.childPath("module.ceylon").resource);
    tryWrite(moduleFilePath.createFile(), "module ``moduleName`` \"1.0.0\" {}");
}

void createPackageFile(Directory moduleDirectory, String moduleName) {
    assert(is Nil packageFilePath = moduleDirectory.path.childPath("package.ceylon").resource);
    tryWrite(packageFilePath.createFile(), "shared package ``moduleName``;");
}

void createRunFile(Directory moduleDirectory, String moduleName) {
    assert(is Nil runFilePath = moduleDirectory.path.childPath("run.ceylon").resource);
    process.propertyValue("");
    tryWrite(runFilePath.createFile(),
        """
           "Run the module `""" + moduleName +
        """`."
           shared void run() {
               print("Hello ``process.propertyValue("user.home") else "Ceylon user"``");
           }
           """);
}

void tryWrite(File file, String text) {
    try (writer = file.Overwriter("utf8")) {
        writer.write(text);
    } catch (e) {
        print("There was a problem writing to file ``file.path.absolutePath``! Do you have access to write to this location?");
        print("Error: ``e``");
    }
}
