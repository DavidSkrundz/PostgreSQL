//
//  ConnectionStatus.swift
//  PostgreSQL
//

import CLibPQ

public enum ConnectionStatus {
	case OK
	case Bad
	case Started
	case Made
	case AwaitingResponse
	case AuthOK
	case SetEnv
	case SSLStartup
	case Needed
	
	public init(status: ConnStatusType) {
		switch status {
			case CONNECTION_OK:                self = .OK
			case CONNECTION_BAD:               self = .Bad
			case CONNECTION_STARTED:           self = .Started
			case CONNECTION_MADE:              self = .Made
			case CONNECTION_AWAITING_RESPONSE: self = .AwaitingResponse
			case CONNECTION_AUTH_OK:           self = .AuthOK
			case CONNECTION_SETENV:            self = .SetEnv
			case CONNECTION_SSL_STARTUP:       self = .SSLStartup
			case CONNECTION_NEEDED:            self = .Needed
			
			default:
				fatalError("Unrecognized ConnStatusType: \(status)")
		}
	}
}
