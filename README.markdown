# PGUnicodeCharacters

This command line tool counts the occurrences of unique Unicode characters from text files.

NB: 

* The tool *does not* check if the file is actually in the assumed UTF-8 format, so there may be issues.
* When processing lots of and very large book files, running the tool takes a long time, depending on your computer setup.

## Building

Build using Swift package manager:

```console
$ swift build --configuration release
```

## Usage

And then run (without necessary parameters) to see the usage instructions:

```console
$ .build/release/PGUnicodeCharacters
```

Output:
```                                                               
Error: Missing expected argument '<books>'

USAGE: pg-unicode-characters <books> <output> [--format <format>] [--order <order>]

ARGUMENTS:
  <books>                 Directory where the PG books are.
  <output>                Output file with path and file extension.

OPTIONS:
  --format <format>       Output file format, either html or text. (default: text)
  --order <order>         Print results by char ascending or count descending (default: countDescending)
  -h, --help              Show help information.
```

As you can see, options `--format` and `--order` have default values of `text` and `countDescending`, most often used chars first.
 
An example run with real Project Gutenberg dataset, 62 316 book files:

```console
$ .build/release/PGUnicodeCharacters ~/Downloads/cache/epub/ ~/Downloads/unicode.txt --format text
```

Output:
``` 
29.5.2025 klo 11.46.27 UTC+3
Starting to process files in /Users/juustila/Downloads/cache/epub/...

Handled 62316 files.
Sorting chars in descending order by count of usage
Collected 35628 unique codepoints
Time taken: 589 seconds
Opening the file /Users/juustila/Downloads/unicode.txt for writing results...
See results from /Users/juustila/Downloads/unicode.txt
```

This took 258 seconds, to handle the 62 316 book files (on Apple Mac Mini M1 with 16GB RAM). 

The result are stored in a html file (view full [text, by count](https://juustila.com/pgunicode/unicode-by-count.txt) and [html, by char order](https://juustila.com/pgunicode/unicode-by-char.html) from the run above), looking like this (yes, bare & ascetic, but shows the data):

Example from the text output file:

```
Generated 2025-05-29T08:56:16Z in 589 seconds.
35 628 unique characters in dataset.
23 847 518 672 characters in total.
From 62 316 files.

Char            Count Unicode scalars
SPACE      4019333792 U+0020 spaceSeparator
e          2270275893 U+0065 lowercaseLetter
t          1529701052 U+0074 lowercaseLetter
a          1409609619 U+0061 lowercaseLetter
o          1304455369 U+006F lowercaseLetter
n          1263434718 U+006E lowercaseLetter
i          1214211647 U+0069 lowercaseLetter
s          1109421997 U+0073 lowercaseLetter
r          1084602235 U+0072 lowercaseLetter
h           927948923 U+0068 lowercaseLetter
l           734394053 U+006C lowercaseLetter
d           720346321 U+0064 lowercaseLetter
u           549953927 U+0075 lowercaseLetter
CRLF        484919941 U+000D control U+000A control
c           465452115 U+0063 lowercaseLetter
m           429209133 U+006D lowercaseLetter...
```

> Note that if you download the text file and view it in macOS TeXtEdit, some lines are in right-to-left order, count of occurrences on left and the actual character on the right side, probably since that is the default reading order for that character. This may happen also elsewhere when viewer acknowledges the writing direction. It may also be that a character that changes the writing direction, is written to the output. It looks like this:

```
前              102791 U+524D otherLetter
י              102417 

ו              101240 

兩              100881 U+5169 otherLetter
```

## Dependencies

The tool uses the Swift Argument Parser.

## Contributing

I am not actually any Unicode expert, so if you find something to fix, please let me know (or provide a pull request).


## License

* (c) Antti Juustila, 2025
* MIT License
* See the included LICENSE file for details.
