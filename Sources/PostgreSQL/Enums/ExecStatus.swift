//
//  ExecStatus.swift
//  PostgreSQL
//

import CLibPQ

public enum ExecStatus {
	case EmptyQuery
	case CommandOK
	case TuplesOK
	case CopyOut
	case CopyIn
	case BadResponse
	case NonFatalError
	case FatalError
	case CopyBoth
	case SingleTupe
	
	public init(status: ExecStatusType) {
		switch status {
			case PGRES_EMPTY_QUERY:    self = .EmptyQuery
			case PGRES_COMMAND_OK:     self = .CommandOK
			case PGRES_TUPLES_OK:      self = .TuplesOK
			case PGRES_COPY_OUT:       self = .CopyOut
			case PGRES_COPY_IN:        self = .CopyIn
			case PGRES_BAD_RESPONSE:   self = .BadResponse
			case PGRES_NONFATAL_ERROR: self = .NonFatalError
			case PGRES_FATAL_ERROR:    self = .FatalError
			case PGRES_COPY_BOTH:      self = .CopyBoth
			case PGRES_SINGLE_TUPLE:   self = .SingleTupe
			
			default:
				fatalError("Unrecognized ExecStatusType: \(status)")
		}
	}
}
