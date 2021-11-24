/// Tool for generation and checks of passwords
Class caretdev.Passwords
{

/// List of numbers
Parameter NUMBER = 0123456789;

/// List of lower case letters
Parameter LOWER = "abcdefghijklmnopqrstuvwxyz";

/// List of upper case letters
Parameter UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

/// List of Symbols
Parameter SYMBOL = "!'.,:;?&-"" @#$%^*(){}[]><~`_+=|/\";

/// Generate secure password
/// <br>
/// Parameters
/// <ul>
/// <li>Length - the length of desired password, with default value as 12
/// <li>IncludeUpperLetter - Include Upper case ASCII letters, 2 if required, default 1
/// <li>IncludeLowerLetter - Include Lower case ASCII letters, 2 if required, default 2
/// <li>IncludeNumber - Include numbers, 2 if required, default 1
/// <li>IncludeSymbol - Include symbols, 2 if required, default 1
ClassMethod Generate(Length As %Integer = 12, IncludeUpperLetter As %Boolean = 1, IncludeLowerLetter As %Boolean = 2, IncludeNumber As %Boolean = 1, IncludeSymbol As %Boolean = 1) As %String
{
  Set charset = ""
  If (IncludeLowerLetter)  Set charset = charset _ ..#LOWER
  If (IncludeUpperLetter)  Set charset = charset _ ..#UPPER
  If (IncludeNumber)       Set charset = charset _ ..#NUMBER
  If (IncludeSymbol)       Set charset = charset _ ..#SYMBOL

  If (Length < 6) {
    Throw ##class(%Exception.General).%New("Too short, should be at least 6 symbols")
  }

  If (charset = "") {
    Throw ##class(%Exception.General).%New("Should include at least anything")
  }

  Set attempts = 0
  If IncludeLowerLetter,IncludeUpperLetter,(IncludeNumber||IncludeSymbol) {
    Set attempts = Length * 10
  }
  Set attempts = Length * 10
  For n = 1:1:attempts {
    Set password = ""

    Set rand = $System.Encryption.GenCryptRand(Length * 2)

    Set charsetSize = $Length(charset)
    Set rand = $System.Encryption.GenCryptRand(Length)
    For i = 1:1:Length {
      Set char = $Ascii(rand, i) / 256 * charsetSize
      Set password = password _ $Extract(charset, char)
    }
    #; required rules 
    Continue:'..CheckRules(password, IncludeUpperLetter - 1, IncludeLowerLetter - 1, IncludeNumber - 1, IncludeSymbol - 1)

    Set entropy = ..Entropy(password, 10)
    Set best(entropy) = password
  } 

  Set bestEntropy = $Order(best(""), -1, password)
  If (bestEntropy = "") {
    Throw ##class(%Exception.General).%New("Not generated, check the parameters")
  }
  
  Return password
}

/// Check if password fits the rules
ClassMethod CheckRules(Password As %String, IncludeUpperLetter As %Boolean = 0, IncludeLowerLetter As %Boolean = 0, IncludeNumber As %Boolean = 0, IncludeSymbol As %Boolean = 0) As %Boolean
{
  If (IncludeUpperLetter>0 && ($Translate(Password, ..#UPPER) = Password)) Return 0
  If (IncludeLowerLetter>0 && ($Translate(Password, ..#LOWER) = Password)) Return 0
  If (IncludeNumber>0 && ($Translate(Password, ..#NUMBER) = Password)) Return 0
  If (IncludeSymbol>0 && ($Translate(Password, ..#SYMBOL) = Password)) Return 0
  Return 1
}

/// Calculates the NIST score
/// <ul>
/// <li> The entropy of the first character is four bits;</ii>
/// <li> The entropy of the next seven characters are two bits per
///      character;</ii>
/// <li> The ninth through the twentieth character has 1.5 bits of
///      entropy per character;</ii>
/// <li> Characters 21 and above have one bit of entropy per character.</ii>
/// <li> A "bonus" of six bits is added if both upper case letters and
///      non-alphabetic characters are used.</ii>
/// <li> A "bonus" of six bits is added for passwords of length 1 through
///      19 characters following an extensive dictionary check to ensure
///      the password is not contained within a large dictionary.
///      Passwords of 20 characters or more do not receive this bonus
///      because it is assumed they are pass-phrases consisting of
///      multiple dictionary words.</ii>
/// <ul>
ClassMethod NISTScore(Password As %String = "") As %Numeric
{
  Set score = 0
  Set len = $Length(Password)

  If (len > 20) {
    Set score = score + (len - 20)
    Set len = 20
  }

  If (len > 8) {
    Set score = score + (1.5 * (len - 8))
    Set len = 8
  }

  If (len > 1) {
    Set score = score + (2 * (len - 1))
    Set len = 1
  }

  If (len) {
    Set score = score + 4
  }

  If ($Locate(Password, "[A-Z]") && $Locate(Password, "[^A-Za-z]")) {
    Set score = score + 6
  }

  Return score
}

/// Calculate the Entropy value of a password.
/// <pre>
/// Entropy Formula
/// L = Password Length; Number of symbols in the password
/// 
/// S = Size of the pool of unique possible symbols (character set).
/// 
/// For example:
/// 
/// Numbers (0-9): 10
/// Lower Case Latin Alphabet (a-z): 26
/// Lower Case & Upper Case Latin Alphabet (a-z, A-Z): 52
/// ASCII Printable Character Set (a-z, A-Z, symbols, space): 95
/// 
/// Number of Possible Combinations = S**L
/// 
/// Entropy = log2(Number of Possible Combinations)
/// </pre>
/// <br><br>
/// <a href="https://en.wikipedia.org/wiki/Password_strength#Entropy_as_a_measure_of_password_strength" target="_blank">
/// https://en.wikipedia.org/wiki/Password_strength#Entropy_as_a_measure_of_password_strength
/// </a>
ClassMethod Entropy(Password As %String = "", decimal = 2) As %Numeric
{
  If (Password = "") {
    Return 0
  }

  Set size = ..CharsetSize(Password)
  Try {
    Set combinations = size ** $Length(Password)
  } Catch {
    #; <MAXNUMBER>
    Set combinations = 1e308
  }
  
  #; logarithm base 2 
  Set score = $ZLog(combinations) / $ZLog(2)

  Return $Number(score, decimal)
}

/// Calculate the Shannon Entropy value of a password./// 
/// <br><br>
/// <a href="https://en.wikipedia.org/wiki/Entropy_(information_theory)" target="_blank">
/// https://en.wikipedia.org/wiki/Entropy_(information_theory)</a>
ClassMethod ShannonScore(Password As %String = "", decimal = 2) As %Numeric
{
  For i = 1:1:$Length(Password) {
    Set char = $Extract(Password, i)
    Set freq(char) = $Get(freq(char)) + 1
  }
  Set length = $Length(Password)
  Set summ = 0
  Set char = ""
  For {
    Set char = $Order(freq(char), 1, val)
    Quit:(char="")
    Set score = val / length
    Set score = score * ($ZLog(score) / $ZLog(2))
    Set summ = summ - score
  }
  
  Return $Number(summ * length, decimal)
}

/// Count the size of all characater sets used
ClassMethod CharsetSize(Password As %String) As %Integer [ Internal ]
{
  Set tPassword = Password
  Set size = 0
  For charset = ..#NUMBER, ..#LOWER, ..#UPPER, ..#SYMBOL {
    If ($Translate(tPassword, charset) '= tPassword) {
      Set size = size + $Length(charset)
    }    
    Set tPassword = $Translate(tPassword, charset)
  }
  If (tPassword '="" ) {
    Set size = size + $Length(tPassword)
  }
  
  Return size
}

/// Return the strength of the password based on <Method>Entropy</Method>
ClassMethod DetermineStrength(Password As %String = "") As %String
{
  Set entropy = ..Entropy(Password)
  Set strength = $Select(
    entropy <= 32: "VERY_WEAK",
    entropy <= 48: "WEAK",
    entropy <= 64: "REASONABLE",
    entropy <= 80: "STRONG",
    1: "VERY_STRONG "
  )
  Return strength
}

}
