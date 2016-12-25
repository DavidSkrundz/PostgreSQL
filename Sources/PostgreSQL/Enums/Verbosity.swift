//
//  Verbosity.swift
//  PostgreSQL
//

import CLibPQ

public enum Verbosity {
	case Terse
	case Default
	case Verbose
	
	public init(verbosity: PGVerbosity) {
		switch verbosity {
			case PQERRORS_TERSE:   self = .Terse
			case PQERRORS_DEFAULT: self = .Default
			case PQERRORS_VERBOSE: self = .Verbose
			
			default:
				fatalError("Unrecognized PGVerbosity: \(verbosity)")
		}
	}
}
