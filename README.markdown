#PGUnicodeCharacters

The name of this command line tool comes from the discussion in [Project Gutenberg tools](https://github.com/gutenbergtools/ebookmaker) issue. The issue (Need census of Unicode characters in PG texts #276) proposes a tool that you could use to see which Unicode characters are used in Project Gutenberg books.

This tool counts the usage of unique Unicode characters from text files.

NB: The tool *does not* check if the file is actually in the assumed UTF-8 format, so there may be issues.

Running the tool takes *very long* time (tens of minutes) when processing lots of large book files. While processing, the tool prints a dot for each file in the console, so you should be able to see some progress.

## Building

Build using Swift package manager:

```console
swift build --configuration relese
```

## Usage

And then run (without parameters) to see the usage instructions:

```console
$ .build/release/PGUnicodeCharacters                                                               
Error: Missing expected argument '<books>'

USAGE: pg-unicode-characters <books> <output> --format <format>

ARGUMENTS:
  <books>                 Directory where the PG books are.
  <output>                Output file with path and file extension.

OPTIONS:
  --format <format>       Output file format, either html or tsv.
  -h, --help              Show help information.
```
 
An example run with real Project Gutenberg dataset:

```console
$ .build/release/PGUnicodeCharacters ~/Downloads/cache/epub ~/Downloads/unicode.html --format html 
Opening the html file /Users/juustila/Downloads/unicode.html for writing results...
Starting to process files in /Users/juustila/Downloads/cache/epub/...
.................................
Handled 62317 files.
Sorting by count of usage, descending...
Collected 35628 unique codepoints
Time taken: 1343.1186800003052 seconds
See results from /Users/juustila/Downloads/unicode.html
```

And then wait for the results. As you can see, this took 1343 seconds, almost 23 minutes, on MacBook Pro M2. The result are stored in a html file, looking like this:

![Screenshot of the partial html page](html-screenshot.png)

Which Unicode characters you see properly, depends on the Unicode support of your environment.

To save the data to a tsv file instead:

```console
$ .build/release/PGUnicodeCharacters ~/Downloads/cache/test/ ~/Downloads/unicode.tsv --format tsv
```
And the tsv file then contains the data items, tab separated:

```
Character	Unicode scalars	Count
 	32 	3088
e	101 	1732
a	97 	1596
t	116 	1398
o	111 	1330
r	114 	1243
i	105 	1227
n	110 	1181
k	107 	163
:tab:	9 	162
,	44 	154
```
As you can see, the actual tab characters used in the book files is replaced with `:tab:` since the file is -- well, tab separated...


# License

* (c) Antti Juustila, 2025
* MIT License
* See the included LICENSE file for details.
