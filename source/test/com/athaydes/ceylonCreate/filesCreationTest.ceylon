import ceylon.file {
    current,
    Path,
    Nil,
    Directory,
    Visitor,
    File,
    Reader
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
    createAllFiles
}

shared class FilesCreationTest() {
    
    Path mockFilesRoot = current.childPath("temp");
    
    shared beforeTest void createMockFilesRoot() {
        assert(is Nil res = mockFilesRoot.resource);
        res.createDirectory();
        createAllFiles("myProject", {"simpleModule", "test.hi.testModule"}, mockFilesRoot.absolutePath.string);
    }
    
    shared afterTest void removeMockFilesRoot() {
        object fileShredder extends Visitor() {
            shared actual void file(File file) => file.delete();
        }
        object dirShredder extends Visitor() {
            shared actual void afterDirectory(Directory dir) => dir.delete();
        }
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
        assertTrue(mockFilesRoot.childPath("myProject/source/test/hi").resource is Directory);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/hi/testModule").resource is Directory);
    }
    
    shared test void createsRunFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/run.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/hi/testModule/run.ceylon").resource is File);
    }
    
    shared test void createsModuleFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/module.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/hi/testModule/module.ceylon").resource is File);
    }
    
    shared test void createsPackageFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/package.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/hi/testModule/package.ceylon").resource is File);
    }
    
    shared test void testContentsOfSimpleModuleFile() {
        assert(is File moduleFile = mockFilesRoot.childPath("myProject/source/simpleModule/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module simpleModule \"1.0.0\" {}");
        assertNull(firstNonEmptyLine(moduleReader));
    }

    shared test void testContentsOfTestModuleFile() {
        assert(is File moduleFile = mockFilesRoot.childPath("myProject/source/test/hi/testModule/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module test.hi.testModule \"1.0.0\" {}");
        assertNull(firstNonEmptyLine(moduleReader));
    }
    
    shared test void testContentsOfRunFilesForSimpleModule() {
        assert(is File runFile = mockFilesRoot.childPath("myProject/source/simpleModule/run.ceylon").resource);
        
        value runFileReader = runFile.Reader();
        assertRunFunctionAsExpected(runFileReader);
    }
    
    shared test void testContentsOfRunFilesForTestModule() {
        assert(is File runFile = mockFilesRoot.childPath("myProject/source/test/hi/testModule/run.ceylon").resource);
        
        value runFileReader = runFile.Reader();
        assertRunFunctionAsExpected(runFileReader);
    }
    
    void assertRunFunctionAsExpected(Reader runFileReader) {
        assertEquals(firstNonEmptyLine(runFileReader), "shared void run() {");
        assertEquals(firstNonEmptyLine(runFileReader), """    print(greeting(process.propertyValue));""");
        assertEquals(firstNonEmptyLine(runFileReader), "}");
        assertEquals(firstNonEmptyLine(runFileReader), "shared String greeting(String?(String) getProperty)");
        assertEquals(firstNonEmptyLine(runFileReader), """    => "Hello ``getProperty("user.name") else "Ceylon user"``!";""");
        assertNull(firstNonEmptyLine(runFileReader));
    }

    String? firstNonEmptyLine(Reader reader) {
        while (exists line = reader.readLine()) {
            if (!line.trimmed.empty) {
                return line;
            }
        }
        return null;
    }
    
}
