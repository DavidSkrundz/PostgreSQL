//
//  Package.swift
//  PostgreSQL
//

import PackageDescription

let package = Package(
    name: "PostgreSQL",
    dependencies: [
		.Package(url: "https://github.com/DavidSkrundz/CLibPQ.git", versions: Version(1,0,0)..<Version(1,1,0)),
		.Package(url: "https://github.com/DavidSkrundz/Util.git", versions: Version(1,0,0)..<Version(1,1,0)),
	]
)
