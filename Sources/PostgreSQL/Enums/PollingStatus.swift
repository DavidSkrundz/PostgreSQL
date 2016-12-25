//
//  PollingStatus.swift
//  PostgreSQL
//

import CLibPQ

public enum PollingStatus {
	case Failed
	case Reading
	case Writing
	case OK
	case Active
	
	public init(status: PostgresPollingStatusType) {
		switch status {
			case PGRES_POLLING_FAILED:  self = .Failed
			case PGRES_POLLING_READING: self = .Reading
			case PGRES_POLLING_WRITING: self = .Writing
			case PGRES_POLLING_OK:      self = .OK
			case PGRES_POLLING_ACTIVE:  self = .Active
			
			default:
				fatalError("Unrecognized PostgresPollingStatusType: \(status)")
		}
	}
}
