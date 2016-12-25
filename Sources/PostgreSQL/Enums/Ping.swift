//
//  Ping.swift
//  PostgreSQL
//

import CLibPQ

public enum Ping {
	case OK
	case Reject
	case NoResponse
	case NoAttempt
	
	public init(ping: PGPing) {
		switch ping {
			case PQPING_OK:          self = .OK
			case PQPING_REJECT:      self = .Reject
			case PQPING_NO_RESPONSE: self = .NoResponse
			case PQPING_NO_ATTEMPT:  self = .NoAttempt
			
			default:
				fatalError("Unrecognized PGPing: \(ping)")
		}
	}
}
