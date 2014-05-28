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
        createAllFiles("myProject", {"simpleModule", "test.hi.complexModule"}, mockFilesRoot.absolutePath.string);
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
        assertTrue(mockFilesRoot.childPath("myProject/source/test/hi/complexModule").resource is Directory);
    }
    
    shared test void createsRunFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/run.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/hi/complexModule/run.ceylon").resource is File);
    }
    
    shared test void createsModuleFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/module.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/hi/complexModule/module.ceylon").resource is File);
    }
    
    shared test void createsPackageFiles() {
        assertTrue(mockFilesRoot.childPath("myProject/source/simpleModule/package.ceylon").resource is File);
        assertTrue(mockFilesRoot.childPath("myProject/source/test/hi/complexModule/package.ceylon").resource is File);
    }
    
    shared test void testContentsOfSimpleModuleFile() {
        assert(is File moduleFile = mockFilesRoot.childPath("myProject/source/simpleModule/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module simpleModule \"1.0.0\" {}");
        assertNull(firstNonEmptyLine(moduleReader));
    }

    shared test void testContentsOfComplexModuleFile() {
        assert(is File moduleFile = mockFilesRoot.childPath("myProject/source/test/hi/complexModule/module.ceylon").resource);
        
        value moduleReader = moduleFile.Reader();
        assertEquals(firstNonEmptyLine(moduleReader), "module test.hi.complexModule \"1.0.0\" {}");
        assertNull(firstNonEmptyLine(moduleReader));
    }
    
    shared test void testContentsOfRunFilesForSimpleModule() {
        assert(is File runFile = mockFilesRoot.childPath("myProject/source/simpleModule/run.ceylon").resource);
        
        value runFileReader = runFile.Reader();
        assertEquals(firstNonEmptyLine(runFileReader), "\"Run the module `simpleModule`.\"");
        assertRunFunctionAsExpected(runFileReader);
    }
    
    shared test void testContentsOfRunFilesForComplexModule() {
        assert(is File runFile = mockFilesRoot.childPath("myProject/source/test/hi/complexModule/run.ceylon").resource);
        
        value runFileReader = runFile.Reader();
        assertEquals(firstNonEmptyLine(runFileReader), "\"Run the module `test.hi.complexModule`.\"");
        assertRunFunctionAsExpected(runFileReader);
    }
    
    void assertRunFunctionAsExpected(Reader runFileReader) {
        assertEquals(firstNonEmptyLine(runFileReader), "shared void run() {");
        assertEquals(firstNonEmptyLine(runFileReader), """    print("Hello ``process.propertyValue("user.home") else "Ceylon user"``");""");
        assertEquals(firstNonEmptyLine(runFileReader), "}");
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
