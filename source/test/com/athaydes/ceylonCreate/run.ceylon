import ceylon.test {
    test,
    assertTrue,
    assertFalse,
    assertEquals,
    assertNull
}

import com.athaydes.ceylonCreate {
    acceptYesOrNoAnswer,
    acceptValidAnswer,
    validateProjectName,
    validateModuleName,
    moduleNameFromValidProjectName
}

test shared void testAcceptYesOrNoAnswer() {
    assertTrue(acceptYesOrNoAnswer(false, "", () => "Yes", "n"));
    assertTrue(acceptYesOrNoAnswer(false, "", () => "yes", "n"));
    assertTrue(acceptYesOrNoAnswer(false, "", () => "y", "n"));
    assertTrue(acceptYesOrNoAnswer(false, "", () => "Y", "n"));
    assertFalse(acceptYesOrNoAnswer(false, "", () => "NO", "y"));
    assertFalse(acceptYesOrNoAnswer(false, "", () => "No", "y"));
    assertFalse(acceptYesOrNoAnswer(false, "", () => "no", "y"));
    assertFalse(acceptYesOrNoAnswer(false, "", () => "N", "y"));
}

test shared void testAcceptYesOrNoAnswerUsesDefault() {
    assertTrue(acceptYesOrNoAnswer(false, "", () => "", "y"));
    assertFalse(acceptYesOrNoAnswer(false, "", () => "  ", "n"));
    
    // when quiet, always use the default
    assertTrue(acceptYesOrNoAnswer(true, "", () => "n", "y"));
    assertFalse(acceptYesOrNoAnswer(true, "", () => " y ", "n"));
}

test shared void testAcceptValidAnswer() {
    // valid answer
    assertEquals(acceptValidAnswer(false, () => "A", (String a) => a, "", "", 1, () => "B"), "A");
    // invalid answer
    assertEquals(acceptValidAnswer(false, () => "A", (String a) => null, "", "", 1, () => "B"), "B");
    // a few tries
    variable [String?*] answers = [null, null, "V"]; 
    function response(String s) {
        value head = answers.first;
        answers = answers.rest;
        return head;
    }
    assertEquals(acceptValidAnswer(false, () => "A", response, "", "", 3, () => "B"), "V");
    assertTrue(answers.empty);
}

test shared void testValidateProjectName() {
    // invalid project names
    assertNull(validateProjectName(""));
    assertNull(validateProjectName("!"));
    assertNull(validateProjectName("%"));
    assertNull(validateProjectName("@^&project"));
    assertNull(validateProjectName("-="));
    assertNull(validateProjectName("+++"));
    assertNull(validateProjectName("a\\b"));
    assertNull(validateProjectName("a/b"));
    assertNull(validateProjectName("A$B"));
    
    // valid project names
    assertEquals(validateProjectName("_"), "_");
    assertEquals(validateProjectName("a"), "a");
    assertEquals(validateProjectName("A"), "A");
    assertEquals(validateProjectName("_1"), "_1");
    assertEquals(validateProjectName("()"), "()");
    assertEquals(validateProjectName("My Project"), "My Project");
    assertEquals(validateProjectName("Myproject"), "Myproject");
    assertEquals(validateProjectName("1"), "1");
    assertEquals(validateProjectName("1_2"), "1_2");
    assertEquals(validateProjectName("A-B"), "A-B");
    assertEquals(validateProjectName("A (B)"), "A (B)");
    assertEquals(validateProjectName("A-1_000-1"), "A-1_000-1");
    assertEquals(validateProjectName("Ax1"), "Ax1");
    assertEquals(validateProjectName("v0"), "v0");
}

test shared void testValidateModuleName() {
    // invalid project names
    assertNull(validateModuleName(""));
    assertNull(validateModuleName("!"));
    assertNull(validateModuleName("%"));
    assertNull(validateModuleName("@^&Module"));
    assertNull(validateModuleName("-="));
    assertNull(validateModuleName("+++"));
    assertNull(validateModuleName("a\\b"));
    assertNull(validateModuleName("a/b"));
    assertNull(validateModuleName("A$B"));
    assertNull(validateModuleName("()"));
    assertNull(validateModuleName("1"));
    assertNull(validateModuleName("1a"));
    assertNull(validateModuleName("My Module"));
    assertNull(validateModuleName("1_2"));
    assertNull(validateModuleName("A"));
    assertNull(validateModuleName("A-B"));
    assertNull(validateModuleName("A (B)"));
    assertNull(validateModuleName("A-1_000-1"));
    assertNull(validateModuleName("MyModule"));
    assertNull(validateModuleName("Ax1"));
    assertNull(validateModuleName(".Ax1"));
    assertNull(validateModuleName(".ax.e"));
    assertNull(validateModuleName("a..e"));
    assertNull(validateModuleName("ax.ed."));
    
    // valid Module names
    assertEquals(validateModuleName("_"), "_");
    assertEquals(validateModuleName("a"), "a");
    assertEquals(validateModuleName("_1"), "_1");
    assertEquals(validateModuleName("_a"), "_a");
    assertEquals(validateModuleName("myModule"), "myModule");
    assertEquals(validateModuleName("my.Mod.ul.e"), "my.Mod.ul.e");
    assertEquals(validateModuleName("myModuleWhichIsReallyCool"), "myModuleWhichIsReallyCool");
    assertEquals(validateModuleName("v0"), "v0");
}

test shared void testModuleNameFromValidProjectName() {
    assertEquals(moduleNameFromValidProjectName("a"), "a");
    assertEquals(moduleNameFromValidProjectName("_1"), "_1");
    assertEquals(moduleNameFromValidProjectName("_a"), "_a");
    assertEquals(moduleNameFromValidProjectName("myModuleWhichIsReallyCool"), "myModuleWhichIsReallyCool");
    assertEquals(moduleNameFromValidProjectName("v0"), "v0");
    assertEquals(moduleNameFromValidProjectName("A"), "a");
    assertEquals(moduleNameFromValidProjectName("My Project"), "my_Project");
    assertEquals(moduleNameFromValidProjectName("Myproject"), "myproject");
    assertEquals(moduleNameFromValidProjectName("1_2"), "__2");
    assertEquals(moduleNameFromValidProjectName("A-B"), "a_B");
    assertEquals(moduleNameFromValidProjectName("A (B)"), "a__B_");
    assertEquals(moduleNameFromValidProjectName("A-1_000-1"), "a_1_000_1");
    assertEquals(moduleNameFromValidProjectName("Ax1"), "ax1");
    assertEquals(moduleNameFromValidProjectName("v0"), "v0");
    
    // names which would usually result in just underscores should be replaced with a default module name
    assertEquals(moduleNameFromValidProjectName("_"), "myModule");
    assertEquals(moduleNameFromValidProjectName("()"), "myModule");
    assertEquals(moduleNameFromValidProjectName("1"), "myModule");
}
