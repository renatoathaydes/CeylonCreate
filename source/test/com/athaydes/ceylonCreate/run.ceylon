import ceylon.test {
    test,
    assertTrue,
    assertFalse,
    assertEquals
}

import com.athaydes.ceylonCreate {
    acceptYesOrNoAnswer,
    acceptValidAnswer
}

test shared void testAcceptYesOrNoAnswer() {
    assertTrue(acceptYesOrNoAnswer("", () => "Yes", "n"));
    assertTrue(acceptYesOrNoAnswer("", () => "yes", "n"));
    assertTrue(acceptYesOrNoAnswer("", () => "y", "n"));
    assertTrue(acceptYesOrNoAnswer("", () => "Y", "n"));
    assertFalse(acceptYesOrNoAnswer("", () => "NO", "y"));
    assertFalse(acceptYesOrNoAnswer("", () => "No", "y"));
    assertFalse(acceptYesOrNoAnswer("", () => "no", "y"));
    assertFalse(acceptYesOrNoAnswer("", () => "N", "y"));
}

test shared void testAcceptYesOrNoAnswerUsesDefault() {
    assertTrue(acceptYesOrNoAnswer("", () => "", "y"));
    assertFalse(acceptYesOrNoAnswer("", () => "  ", "n"));
}

test shared void testAcceptValidAnswer() {
    // valid answer
    assertEquals(acceptValidAnswer(() => "A", (String a) => a, "", null, 1, () => "B"), "A");
    // invalid answer
    assertEquals(acceptValidAnswer(() => "A", (String a) => null, "", null, 1, () => "B"), "B");
    // a few tries
    variable [String?*] answers = [null, null, "V"]; 
    function response(String s) {
        value head = answers.first;
        answers = answers.rest;
        return head;
    }
    assertEquals(acceptValidAnswer(() => "A", response, "", null, 3, () => "B"), "V");
    assertTrue(answers.empty);
}
