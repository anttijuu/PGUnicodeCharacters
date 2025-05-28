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
28.5.2025 klo 13.17.16 UTC+3
Starting to process files in /Users/anttijuustila/Downloads/cache/epub/...

Handled 62316 files.
Sorting chars in descending order by count of usage
Collected 35628 unique codepoints
Time taken: 258 seconds
Opening the file output.txt for writing results...
See results from output.txt
```

This took 258 seconds, to handle the 62 316 book files (on Apple Mac Mini M1 with 16GB RAM). 

The result are stored in a html file (view full [text, by count](https://juustila.com/pgunicode/unicode-by-count.txt) and [html, by char order](https://juustila.com/pgunicode/unicode-by-char.html) from the run above), looking like this (yes, bare & ascetic, but shows the data):

Example from the text output file:

```
Generated 2025-05-28T10:21:35Z in 258 seconds.
35 628 unique characters in dataset.
23 847 518 672 characters in total.
From 62 316 files.

Char  Unicode scalars          Count
SPACE U+0020                   4019333792
e     U+0065                   2270275893
t     U+0074                   1529701052
a     U+0061                   1409609619
o     U+006F                   1304455369
n     U+006E                   1263434718
i     U+0069                   1214211647
s     U+0073                   1109421997
r     U+0072                   1084602235
...
```

> Note that if you download the text file and view it in macOS TeXtEdit, some lines are in right-to-left order, count of occurrences on left and the actual character on the right side, probably since that is the default reading order for that character.

## Dependencies

The tool uses the Swift Argument Parser.

## Contributing

I am not an actual Unicode expert, so if you find something to fix, please let me know (or provide a pull request).


## License

* (c) Antti Juustila, 2025
* MIT License
* See the included LICENSE file for details.
