# PGUnicodeCharacters

This command line tool counts the occurrences of unique Unicode characters from text files.

NB:

* The tool *does not* check if the input text files are actually in the assumed UTF-8 format, so there may be issues.
* When processing lots of and very large files, running the tool takes a long time, depending on your computer setup.

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

USAGE: pg-unicode-characters <books> <output> [--format <format>] [--order <order>] [--normalize <normalize>]

ARGUMENTS:
  <books>                 Directory where the PG books are.
  <output>                Output file with path and file extension.

OPTIONS:
  --format <format>       Output file format, either html or text. (default: text)
  --order <order>         Either charsAscending or countDescending; prints results by chars ascending or count descending (default: countDescending)
  --normalize <normalize> String normalization options (none, formC, formD, formKC, formKD) (default: none)
  -h, --help              Show help information.
```

Both arguments must be given. If the output file extension is not included in the `output` argument, either `.txt` or `.html` is added by the tool, depending on the `--format` option value.

Options have default values, so if you give no options, the defaults are used. Options are:

* output format for the results, either html or plain text file.
* order of the output, results are sorted either in (ascending) character order, or descending count of occurrence order.
* [Unicode normalization](https://en.wikipedia.org/wiki/Unicode_equivalence#Normalization) done to the input string files. Note that selecting other than `none` slows down the processing considerably.
 
An example run with real Project Gutenberg dataset, 62 316 book files:

```console
$ .build/release/PGUnicodeCharacters ~/Downloads/cache/epub/ ~/Downloads/unicode-by-char.html --format html --order charsAscending
```

Output:
``` 
29.5.2025 klo 21.32.17 UTC+3
Starting to process files in /Users/juustila/Downloads/cache/epub/...

Handled 62316 files.
Sorting chars in ascending order
Collected 35628 unique codepoints
Time taken: 179 seconds
Opening the file /Users/juustila/Downloads/unicode-by-char.html for writing results...
See results from /Users/juustila/Downloads/unicode-by-char.html
```

This took 179 seconds, to handle the 62 316 book files (on Apple Mac Mini M1 with 16GB RAM). 

The result are stored in a file (view full [text file, by count](https://juustila.com/pgunicode/unicode-by-count.txt) and [html file, by char order](https://juustila.com/pgunicode/unicode-by-char.html) from the run above), looking like this (yes, bare & ascetic, but shows the data):

An example, this time from the text output file:

```
Generated 2025-05-29T08:56:16Z in 589 seconds.
35 628 unique characters in dataset.
23 847 518 672 characters in total.
From 62 316 files.
Unicode normalization used: none

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

> Note that when you view the output text file, depending on what you view it with, some lines are in right-to-left order, count of occurrences on left and the actual character on the right side, probably since that is the default order for that character (right to left instead of left to right). It may also be that a character that changes the writing direction, is written to the output. It looks like this (see the actual tiny characters on the right side, when it should be on the left side of the row):

```
י              102417 U+05D9 otherLetter
ו              101240 U+05D5 otherLetter
```
In html output, this does not happen since layout is done in html and chars are in their own separate html element.

## Dependencies

The tool uses the Swift Argument Parser.

## Contributing

I am not actually an Unicode expert, so if you find something to fix, please let me know (or provide a pull request).


## License

* (c) Antti Juustila, 2025
* MIT License
* See the included LICENSE file for details.
