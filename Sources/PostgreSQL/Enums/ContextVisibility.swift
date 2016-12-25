//
//  ContextVisibility.swift
//  PostgreSQL
//

import CLibPQ

public enum ContextVisibility {
	case Never
	case Errors
	case Always
	
	public init(visibility: PGContextVisibility) {
		switch visibility {
			case PQSHOW_CONTEXT_NEVER:  self = .Never
			case PQSHOW_CONTEXT_ERRORS: self = .Errors
			case PQSHOW_CONTEXT_ALWAYS: self = .Always
			
			default:
				fatalError("Unrecognized PGVerbosity: \(visibility)")
		}
	}
}
