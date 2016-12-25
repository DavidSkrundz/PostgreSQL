//
//  TransactionStatus.swift
//  PostgreSQL
//

import CLibPQ

public enum TransactionStatus {
	case Idle
	case Active
	case InTransaction
	case InError
	case Unknown
	
	public init(status: PGTransactionStatusType) {
		switch status {
			case PQTRANS_IDLE:    self = .Idle
			case PQTRANS_ACTIVE:  self = .Active
			case PQTRANS_INTRANS: self = .InTransaction
			case PQTRANS_INERROR: self = .InError
			case PQTRANS_UNKNOWN: self = .Unknown
			
			default:
				fatalError("Unrecognized PGTransactionStatusType: \(status)")
		}
	}
}
