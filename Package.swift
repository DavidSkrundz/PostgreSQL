//
//  Package.swift
//  PostgreSQL
//

import PackageDescription

let package = Package(
    name: "PostgreSQL",
    dependencies: [
		.Package(url: "https://github.com/DavidSkrundz/CLibPQ.git", majorVersion: 1, minor: 0),
		.Package(url: "https://github.com/DavidSkrundz/Util.git", majorVersion: 1, minor: 0),
	]
)
