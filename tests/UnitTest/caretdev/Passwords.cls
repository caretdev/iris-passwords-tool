Class UnitTest.caretdev.Passwords Extends %UnitTest.TestCase
{

Method TestGenerate()
{
  Do $$$AssertEquals($Length(##class(caretdev.Passwords).Generate()), 12, "Default generation is 12 chars long")
  Do $$$AssertEquals($Length(##class(caretdev.Passwords).Generate(16)), 16, "16 chars long")
  #; All charsets are required
  Set password = ##class(caretdev.Passwords).Generate(16, 2, 2, 2, 2)
  Do $$$AssertTrue($Translate(password, ##class(caretdev.Passwords).#UPPER)'=password, "Requires upper case")
  Do $$$AssertTrue($Translate(password, ##class(caretdev.Passwords).#LOWER)'=password, "Requires lower case")
  Do $$$AssertTrue($Translate(password, ##class(caretdev.Passwords).#NUMBER)'=password, "Requires number")
  Do $$$AssertTrue($Translate(password, ##class(caretdev.Passwords).#SYMBOL)'=password, "Requires extra symbol")
}

Method TestNISTScore()
{
  Do $$$AssertEquals(##class(caretdev.Passwords).NISTScore(""), 0, "scores an empty string")
  Do $$$AssertEquals(##class(caretdev.Passwords).NISTScore("."), 4, "scores a single character")
  Do $$$AssertEquals(##class(caretdev.Passwords).NISTScore(".!"), 6, "scores a second character")
  Do $$$AssertEquals(##class(caretdev.Passwords).NISTScore(".A"), 12, "applies a bonus")
  Do $$$AssertEquals(##class(caretdev.Passwords).NISTScore("123456789"), 19.5, "scores a ninth character")
  Do $$$AssertEquals(##class(caretdev.Passwords).NISTScore("123456789012345678901"), 37, "scores a long passphrase")
}

Method TestEntropy()
{
  Do $$$AssertEquals(##class(caretdev.Passwords).Entropy(""), 0, "an empty string")
  Do $$$AssertEquals(##class(caretdev.Passwords).Entropy("abcd"), 18.80, "length 4, same case letters")
  Do $$$AssertEquals(##class(caretdev.Passwords).Entropy("aAbBcCdD"), 45.60, "length 8, upper and lower case letters")
  Do $$$AssertEquals(##class(caretdev.Passwords).Entropy("aAbBcC12"), 47.63, "length 8, 8upper and lower case letters, numbers")
}

Method TestShannonScores()
{
  Do $$$AssertEquals(##class(caretdev.Passwords).ShannonScore(""), 0, "an empty string")
  Do $$$AssertEquals(##class(caretdev.Passwords).ShannonScore("aaaaaa"), 0, "Same letters, any length")
  Do $$$AssertEquals(##class(caretdev.Passwords).ShannonScore("1223334444"), 18.46, "Different frequency 1")
  Do $$$AssertEquals(##class(caretdev.Passwords).ShannonScore("AAAAABBCDE"), 19.61, "Different frequency 2")
  Do $$$AssertEquals(##class(caretdev.Passwords).ShannonScore("abcd1234"), 24, "8 unique")
}

}
