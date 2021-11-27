iris-passwords-tool
====

Generating secure passwords and check strength of passwords

Install with ZPM

```ObjectScript
zpm "install passwords-tool"
```

Generate password
---

```ObjectScript
Set password = ##class(caretdev.Passwords).Generate()
```

Will generate the password, with default parammaters 12 characters long, all characters, and required lowercase with the best entropy.

Accepted parameters

* Length - the length of desired password
* IncludeUpperCase - Include `ABCDEFGHIJKLMNOPQRSTUVWXYZ`
* IncludeLowerCase - Include `abcdefghijklmnopqrstuvwxyz`
* IncludeNumber - Include `0123456789`
* IncludeSymbol - Include ``!'.,:;?&-"" @#$%^*(){}[]><~`_+=|/\``

Include* parameters behavior, by its value

* 0 - do not attempt to add
* 1 - just attempt to add characters from charset
* 2 - requires it in the result

Password entropy
---

Password entropy predicts how difficult a given password would be to crack through guessing, brute force cracking, dictionary attacks or other common methods. Entropy essentially measures how many guesses an attacker will need to make to guess your password.

```ObjectScript
Set entropy = ##class(caretdev.Passwords).Entropy("Pas$W0rD")
```

Strength
---

```ObjectScript
Set strengt = ##class(caretdev.Passwords).DetermineStrength("Pas$W0rD")
```

Returns one of the following values, depends on Entropy value for the password

* VERY_WEAK - Entropy <= 32
* WEAK - Entropy <= 48
* REASONABLE - Entropy <= 64
* STRONG - Entropy <= 80
* VERY_STRONG - Entropy > 80

NIST Score
---

```ObjectScript
Set entropy = ##class(caretdev.Passwords).NISTScore("Pas$W0rD")
```

* The entropy of the first character is four bits;
* The entropy of the next seven characters are two bits per
  character;
* The ninth through the twentieth character has 1.5 bits of
  entropy per character;
* Characters 21 and above have one bit of entropy per character.
* A "bonus" of six bits is added if both upper case letters and
  non-alphabetic characters are used.
* A "bonus" of six bits is added for passwords of length 1 through
  19 characters following an extensive dictionary check to ensure
  the password is not contained within a large dictionary.
  Passwords of 20 characters or more do not receive this bonus
  because it is assumed they are pass-phrases consisting of
  multiple dictionary words.

Shannon Entropy
---

Some another alhorithm of entropy calculation.
[Wikipedia](https://en.wikipedia.org/wiki/Entropy_(information_theory))

```ObjectScript
Set entropy = ##class(caretdev.Passwords).ShannonScore("Pas$W0rD")
```

## Docker installation
### Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.
### Installation 
Clone/git pull the repo into any local directory
```
$ git clonehttps://github.com/caretdev/iris-passwords-tool.git
```
Open the terminal in this directory and run:
```
$ set DOCKER_BUILDKIT=1
$ docker compose build
```
Run the IRIS container with your project:
```
$ docker-compose up -d
```
### How to Test it
Open IRIS terminal:
```ObjectScript
$ docker-compose exec iris iris session iris
USER>Set password = ##class(caretdev.Passwords).Generate()
USER>
```
