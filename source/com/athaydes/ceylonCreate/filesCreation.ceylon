import ceylon.file {
    current,
    Nil,
    parsePath,
    Directory,
    File,
    lines
}

shared void createAllFiles(String projectName, {String*} moduleNames,
    Boolean createEclipseFiles,
    String root = current.absolutePath.string) {
    value projectPath = parsePath(root).childPath(projectName);
    
    "There is already a directory at the target project location. Cannot create project."
    assert (is Nil projectResource = projectPath.resource);
    
    value projectDir = projectResource.createDirectory();
    value sourcePath = projectDir.path.childPath("source");
    value resourcePath = projectDir.path.childPath("resource");
    assert (is Nil sourceRs = sourcePath.resource, is Nil resourceRs = resourcePath.resource);
    
    resourceRs.createDirectory();
    value sourceDirectory = sourceRs.createDirectory();
    
    for (moduleName in moduleNames) {
        createDirectories(sourceDirectory, moduleName);
        createFiles(sourceDirectory, moduleName);
    }
    
    if (createEclipseFiles) {
        createEclipseResources(projectDir, projectName);
    }
}

void createDirectories(Directory sourceDirectory, String moduleName) {
    variable value currentPath = sourceDirectory.path;
    for (namePart in moduleName.split('.'.equals)) {
        value rs = currentPath.childPath(namePart).resource;
        if (is Nil rs) {
            rs.createDirectory();    
        }
        currentPath = rs.path;
    }
}

void createFiles(Directory sourceDirectory, String moduleName) {
    value modulePath = sourceDirectory.path.childPath(moduleName.replace(".", "/"));
    assert (is Directory moduleDir = modulePath.resource);
    createModuleFile(moduleDir, moduleName);
    createPackageFile(moduleDir, moduleName);
    if (testModuleName(moduleName)) {
        createTestFile(moduleDir, moduleName);
    } else {
        createRunFile(moduleDir, moduleName);
    }
}

void createModuleFile(Directory moduleDirectory, String moduleName) {
    assert (is Nil moduleFilePath = moduleDirectory.path.childPath("module.ceylon").resource);
    tryWrite(moduleFilePath.createFile(), "module ``moduleName`` \"1.0.0\" {``testModuleFileImports(moduleName)``}");
}

String testModuleFileImports(String moduleName) {
    if (testModuleName(moduleName)) {
        return """
                      import ceylon.test "1.1.0";
                      import """ + moduleName[5...] +
               """ "1.0.0";
                  """;    
    } else {
        return "";
    }
    
}

void createPackageFile(Directory moduleDirectory, String moduleName) {
    if (testModuleName(moduleName)) {
        return;
    }
    assert (is Nil packageFilePath = moduleDirectory.path.childPath("package.ceylon").resource);
    tryWrite(packageFilePath.createFile(), "shared package ``moduleName``;");
}

void createRunFile(Directory moduleDirectory, String moduleName) {
    assert (is Nil runFilePath = moduleDirectory.path.childPath("run.ceylon").resource);
    value helloRs = localResource("snippets/hello");
    assert (exists helloRs);
    tryWrite(runFilePath.createFile(), interpolate(helloRs.textContent(), "moduleName" -> moduleName));
}

void createTestFile(Directory moduleDirectory, String moduleName) {
    assert (is Nil runFilePath = moduleDirectory.path.childPath("testRun.ceylon").resource);
    value testHelloRs = localResource("snippets/testHello");
    assert (exists testHelloRs);
    tryWrite(runFilePath.createFile(), interpolate(testHelloRs.textContent(), "moduleName" -> moduleName[5...]));
}

void createEclipseResources(Directory projectDirectory, String projectName) {
    value sourceClassPathRs = localResource("eclipse/classpath");
    value sourceProjectRs = localResource("eclipse/project");
    value sourcePreferencesRs = localResource("eclipse/settings/org.eclipse.core.resources.prefs");
    assert (exists sourceClassPathRs, exists sourceProjectRs, exists sourcePreferencesRs);
    
    assert (is Nil classPathRs = projectDirectory.path.childPath(".classpath").resource);
    tryWrite(classPathRs.createFile(), sourceClassPathRs.textContent());
    
    assert (is Nil projectRs = projectDirectory.path.childPath(".project").resource);
    tryWrite(projectRs.createFile(), sourceProjectRs.textContent()
        .replace("""``projectName``""", projectName));
    
    assert (is Nil settingsRs = projectDirectory.path.childPath(".settings").resource);
    value preferencesPath = settingsRs.createDirectory().path.childPath("org.eclipse.core.resources.prefs");
    assert (is Nil preferencesRs = preferencesPath.resource);
    tryWrite(preferencesRs.createFile(), sourcePreferencesRs.textContent());
}

void tryWrite(File file, String text) {
    try (writer = file.Overwriter("utf8")) {
        writer.write(text);
    } catch (e) {
        print("There was a problem writing to file ``file.path.absolutePath``! Do you have access to write to this location?");
        print("Error: ``e``");
    }
}

shared Resource? localResource(String path) => `module com.athaydes.ceylonCreate`.resourceByPath("com/athaydes/ceylonCreate/``path``");

String? text(File file) => lines(file).reduce((String partial, String line) => partial + "\n" + line);

shared String interpolate(String text, <String->String>* replacements) {
    if (exists replacement = replacements.first) {
        return interpolate(text.replace("\`\```replacement.key``\`\`", replacement.item), *replacements.rest);    
    } else {
        return text;
    }
}
