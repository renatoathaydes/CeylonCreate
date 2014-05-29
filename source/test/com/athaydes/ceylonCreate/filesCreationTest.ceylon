import ceylon.file {
    current,
    Path,
    Nil,
    Directory,
    Visitor,
    File,
    Reader,
    lines
}
import ceylon.test {
    test,
    beforeTest,
    afterTest,
    assertTrue,
    assertEquals,
    assertNull
}

import com.athaydes.ceylonCreate {
    createAllFiles,
    localResource,
    interpolate
}

shared class FilesCreationTest() {
    
    Path mockFilesRoot = current.childPath("temp");
    
    shared beforeTest void createMockFilesRoot() {
        assert(is Nil res = mockFilesRoot.resource);
        res.createDirectory();
        createAllFiles("myProject", {"simpleModule", "test.simpleModule"}, true, mockFilesRoot.absolutePath.string);
    }
    
    shared afterTest void removeMockFilesRoot() {
        if (is Directory res = mockFilesRoot.resource) {
            mockFilesRoot.visit(fileShredder);
            mockFilesRoot.visit(dirShredder);
        }
    }
    
    shared test void createsProjectDirectories() {
        assertTrue(mockFilesRoot.childPath("myProject").resource is Directory);
        assertTrue(mockFilesRoot.childPath("myProject/source").resource is Directory);
        assertTrue(mockFilesRoot.childPath("myProject/resource").resource is Directory);
    }
    
    shared test void createsModuleDirectories() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule").resource is Directory);
        assertTrue(mockFilesRoot.childPath("myProject/source/test").resource is Directory);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/simpleModule").resource is Directory);
    }
    
    shared test void createsRunFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/run.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/simpleModule/testRun.ceylon").resource is File);
    }
    
    shared test void createsModuleFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/module.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/simpleModule/module.ceylon").resource is File);
    }
    
    shared test void createsPackageFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/package.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/simpleModule/package.ceylon").resource is Nil);
    }
    
    shared test void testContentsOfSimpleModuleFile() {
        assert(is File moduleFile = mockFilesRoot.childPath("myProject/source/simpleModule/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module simpleModule \"1.0.0\" {}");
        assertNull(firstNonEmptyLine(moduleReader));
    }

    shared test void testContentsOfTestModuleFile() {
        assert(is File moduleFile = mockFilesRoot.childPath("myProject/source/test/simpleModule/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module test.simpleModule \"1.0.0\" {");
        assertEquals(firstNonEmptyLine(moduleReader), "    import ceylon.test \"1.1.0\";");
        assertEquals(firstNonEmptyLine(moduleReader), "    import simpleModule \"1.0.0\";");
        assertEquals(firstNonEmptyLine(moduleReader), "}");
        assertNull(firstNonEmptyLine(moduleReader));
    }
    
    shared test void testContentsOfRunFileForSimpleModule() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("myProject/source/simpleModule/run.ceylon"),
            localResource("snippets/hello"), "moduleName" -> "simpleModule");
    }
    
    shared test void testContentsOfRunFileForTestModule() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("myProject/source/test/simpleModule/testRun.ceylon"),
            localResource("snippets/testHello"), "moduleName" -> "simpleModule");
    }
    
    shared test void testContentsOfEclipseProjectFile() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("myProject/.project"),
            localResource("eclipse/project"), "projectName" -> "myProject");
    }
    
    shared test void testContentsOfEclipseClassPathFile() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("myProject/.classpath"),
            localResource("eclipse/classpath"));
    }
    
    shared test void testContentsOfEclipsePreferencesFile() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("myProject/.settings/org.eclipse.core.resources.prefs"),
            localResource("eclipse/settings/org.eclipse.core.resources.prefs"));
    }

}

shared class MultipleModulesCreationTest() {
    
    Path mockFilesRoot = current.childPath("temp");
    
    shared beforeTest void createMockFilesRoot() {
        assert(is Nil res = mockFilesRoot.resource);
        res.createDirectory();
        createAllFiles("theProject", {"common.path.mod1", "common.path.yet.another.mod2", "one.more"},
            true, mockFilesRoot.absolutePath.string);
    }
    
    shared afterTest void removeMockFilesRoot() {
        if (is Directory res = mockFilesRoot.resource) {
            mockFilesRoot.visit(fileShredder);
            mockFilesRoot.visit(dirShredder);
        }
    }
    
    shared test void createsProjectDirectories() {
        assertTrue(mockFilesRoot.childPath("theProject").resource is Directory);
        assertTrue(mockFilesRoot.childPath("theProject/source").resource is Directory);
        assertTrue(mockFilesRoot.childPath("theProject/resource").resource is Directory);
    }
    
    shared test void createsModuleDirectories() {
        assertTrue(mockFilesRoot.childPath("theProject/source/common").resource is Directory);
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path").resource is Directory);
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/mod1").resource is Directory);
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/yet").resource is Directory);
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/yet/another").resource is Directory);
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/yet/another/mod2").resource is Directory);
        assertTrue(mockFilesRoot.childPath("theProject/source/one").resource is Directory);
        assertTrue(mockFilesRoot.childPath("theProject/source/one/more").resource is Directory);
    }
    
    shared test void createsRunFiles() {
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/mod1/run.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/yet/another/mod2/run.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("theProject/source/one/more/run.ceylon").resource is File);
    }
    
    shared test void createsModuleFiles() {
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/mod1/module.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/yet/another/mod2/module.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("theProject/source/one/more/module.ceylon").resource is File);
    }
    
    shared test void createsPackageFiles() {
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/mod1/package.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("theProject/source/common/path/yet/another/mod2/package.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("theProject/source/one/more/package.ceylon").resource is File);
    }
    
    shared test void testContentsOfMod1File() {
        assert(is File moduleFile = mockFilesRoot.childPath("theProject/source/common/path/mod1/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module common.path.mod1 \"1.0.0\" {}");
        assertNull(firstNonEmptyLine(moduleReader));
    }
    
    shared test void testContentsOfMod2File() {
        assert(is File moduleFile = mockFilesRoot.childPath("theProject/source/common/path/yet/another/mod2/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module common.path.yet.another.mod2 \"1.0.0\" {}");
        assertNull(firstNonEmptyLine(moduleReader));
    }
    
    shared test void testContentsOfOneMoreFile() {
        assert(is File moduleFile = mockFilesRoot.childPath("theProject/source/one/more/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module one.more \"1.0.0\" {}");
        assertNull(firstNonEmptyLine(moduleReader));
    }
    
    shared test void testContentsOfRunFileForMod1() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("theProject/source/common/path/mod1/run.ceylon"),
            localResource("snippets/hello"), "moduleName" -> "common.path.mod1");
    }
    
    shared test void testContentsOfRunFileForMod2() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("theProject/source/common/path/yet/another/mod2/run.ceylon"),
            localResource("snippets/hello"), "moduleName" -> "common.path.yet.another.mod2");
    }
    
    shared test void testContentsOfRunFileForOneMore() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("theProject/source/one/more/run.ceylon"),
            localResource("snippets/hello"), "moduleName" -> "one.more");
    }
    
    shared test void testContentsOfEclipseProjectFile() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("theProject/.project"),
            localResource("eclipse/project"), "projectName" -> "theProject");
    }
    
    shared test void testContentsOfEclipseClassPathFile() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("theProject/.classpath"),
            localResource("eclipse/classpath"));
    }
    
    shared test void testContentsOfEclipsePreferencesFile() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("theProject/.settings/org.eclipse.core.resources.prefs"),
            localResource("eclipse/settings/org.eclipse.core.resources.prefs"));
    }
    
}

shared class FilesCreationTestWithNoEclipse() {
    
    Path mockFilesRoot = current.childPath("temp");
    
    shared beforeTest void createMockFilesRoot() {
        assert(is Nil res = mockFilesRoot.resource);
        res.createDirectory();
        createAllFiles("myProject", {"simpleModule"}, false, mockFilesRoot.absolutePath.string);
    }
    
    shared afterTest void removeMockFilesRoot() {
        if (is Directory res = mockFilesRoot.resource) {
            mockFilesRoot.visit(fileShredder);
            mockFilesRoot.visit(dirShredder);
        }
    }
    
    shared test void createsProjectDirectories() {
        assertTrue(mockFilesRoot.childPath("myProject").resource is Directory);
        assertTrue(mockFilesRoot.childPath("myProject/source").resource is Directory);
        assertTrue(mockFilesRoot.childPath("myProject/resource").resource is Directory);
    }
    
    shared test void createsModuleDirectories() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule").resource is Directory);
    }
    
    shared test void createsRunFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/run.ceylon").resource is File);
    }
    
    shared test void createsModuleFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/module.ceylon").resource is File);
    }
    
    shared test void createsPackageFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/package.ceylon").resource is File);
    }
    
    shared test void testContentsOfSimpleModuleFile() {
        assert(is File moduleFile = mockFilesRoot.childPath("myProject/source/simpleModule/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module simpleModule \"1.0.0\" {}");
        assertNull(firstNonEmptyLine(moduleReader));
    }
    
    shared test void testContentsOfRunFileForSimpleModule() {
        assertContentsAreTheSame(
            mockFilesRoot.childPath("myProject/source/simpleModule/run.ceylon"),
            localResource("snippets/hello"), "moduleName" -> "simpleModule");
    }
    
    shared test void ensureNoEclipseProjectFile() {
        assert (is Nil rs = mockFilesRoot.childPath("myProject/.project").resource);
    }
    
    shared test void ensureNoEclipseClassPathFile() {
        assert (is Nil rs = mockFilesRoot.childPath("myProject/.classpath").resource);
    }
    
    shared test void ensureNoEclipsePreferencesFile() {
        assert (is Nil dir = mockFilesRoot.childPath("myProject/.settings").resource);
        assert (is Nil rs = mockFilesRoot.childPath("myProject/.settings/org.eclipse.core.resources.prefs").resource);
    }
    
}


object fileShredder extends Visitor() {
    shared actual void file(File file) => file.delete();
}
object dirShredder extends Visitor() {
    shared actual void afterDirectory(Directory dir) => dir.delete();
}

void assertContentsAreTheSame(Path actual, Resource? expected, <String->String>* expectedReplacements) {
    assert (is File file = actual.resource);
    assert (exists actualText = text(file));
    assert (exists expectedText = expected?.textContent(), !expectedText.empty);
    assertEquals(actualText + "\n", interpolate(expectedText, *expectedReplacements));
}

String? firstNonEmptyLine(Reader reader) {
    while (exists line = reader.readLine()) {
        if (!line.trimmed.empty) {
            return line;
        }
    }
    return null;
}

String? text(File file) => lines(file).reduce((String partial, String line) => partial + "\n" + line);
