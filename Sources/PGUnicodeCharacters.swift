// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@available(macOS 13.0, *)
@main
struct PGUnicodeCharacters: ParsableCommand {
	
	@Argument(help: "Directory where the PG books are.")
	private var books: String

	@Argument(help: "Output file with path and file extension.")
	private var output: String

	enum Format: String, ExpressibleByArgument {
		 case html
		 case tsv
	}
	
	@Option(help: "Output file format, either html or tsv.")
	var format: Format
	
	mutating func run() throws {
		process()
	}
	
	mutating func process() {
		print("Opening the file \(output) for writing results...")
		guard let outFileHandle: FileHandle = start(to: URL(filePath: output), with: format) else {
			print("Error, could not open \(output)")
			return
		}

		let fileManager = FileManager.default
		if !books.hasSuffix("/") {
			books.append("/")
		}

		print("Starting to process files in \(books)...")
		var codePointsUsage: [Character: Int] = [:]
		let start = Date.now
		var fileCounter = 1
		do {
			if let enumerator = fileManager.enumerator(atPath: books) {
				while let file = enumerator.nextObject() as? String {
					if file.hasSuffix(".txt") {
						print(".", terminator: "")
						let fullPath = books + file
						let fileContents = try String(contentsOf: URL(fileURLWithPath: fullPath), encoding: .utf8)
						for character in fileContents {
							codePointsUsage[character, default: 0] += 1
						}
						fileCounter += 1
					}
				}
			}
		} catch {
			print("\nError reading files: \(error)")
			return
		}
		print("\nHandled \(fileCounter) files.") // Print empty line after not printing line ends in progress.
		print("Sorting by count of usage, descending...")
		let sortedByCount = codePointsUsage.sorted{ $0.value > $1.value }
		print("Collected \(sortedByCount.count) unique codepoints")
		print("Time taken: \(Date.now.timeIntervalSince(start)) seconds")
		for (key, value) in sortedByCount {
			switch format {
			case .html:
				outFileHandle.write("<tr><td>\(String(key).escape())</td><td>\(uniCodeScalars(key))</td><td>\(value.formatted())</td></tr>\n".data(using: .utf8)!)
			case .tsv:
				if key == "\t" {
					outFileHandle.write(":tab:\t\(uniCodeScalars(key))\t\(value)\n".data(using: .utf8)!)
				} else {
					outFileHandle.write("\(key)\t\(uniCodeScalars(key))\t\(value)\n".data(using: .utf8)!)
				}
			}
		}
		finish(fileHandle: outFileHandle, with: format)
		print("See results from \(output)")
	}

	func uniCodeScalars(_ character: Character) -> String {
		var string = ""
		for scalar in character.unicodeScalars {
			string += String(scalar.value) + " "
		}
		return string
	}

	func start(to file: URL, with format: Format) -> FileHandle? {
		var fileHandle: FileHandle? = nil
		do {
			try "".data(using: .utf8)?.write(to: file)
			if let handle = try? FileHandle(forWritingTo: file) {
				fileHandle = handle
				switch format {
				case .html:
					fileHandle!.write("<!DOCTYPE html>\n".data(using: .utf8)!)
					fileHandle!.write("<head><meta charset=\"utf-8\">\n".data(using: .utf8)!)
					fileHandle!.write("<title>Unicode characters in files</title></head>\n".data(using: .utf8)!)
					fileHandle!.write("<body><table><tr><th>Character</th><th>Unicode scalars</th><th>Count</th></tr>\n".data(using: .utf8)!)
				case .tsv:
					fileHandle!.write("Character\tUnicode scalars\tCount\n".data(using: .utf8)!)
				}
			}
		} catch {
			fatalError("Error in creating html file, aborting \(error)")
		}
		return fileHandle
	}

	func finish(fileHandle: FileHandle?, with format: Format) {
		precondition(fileHandle != nil, "fileHandle is nil, call start() first with valid file name")
		do {
			switch format {
			case .html:
				fileHandle!.write("</table></body></html>\n".data(using: .utf8)!)
			case .tsv:
				fileHandle!.write("\n".data(using: .utf8)!)
			}
			try fileHandle!.close()
		} catch {
			fatalError("Error in writing html file, aborting \(error)")
		}
	}

}
