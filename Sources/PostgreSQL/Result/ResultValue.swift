//
//  ResultValue.swift
//  PostgreSQL
//

import Foundation
import Util

public enum ResultValue {
	case Null
	
	case Bool(Swift.Bool)
	
	case Int16(Swift.Int16)
	case Int32(Swift.Int32)
	case Int64(Swift.Int64)
	
	case Numeric(Swift.String)
	
	case Float(Swift.Float)
	case Double(Swift.Double)
	
	case String(Swift.String)
	
	case Bytes([Swift.UInt8])
}

extension ResultValue {
	internal init(connection: Connection,
	              oid: ObjectID,
	              value: UnsafeMutablePointer<Int8>,
	              length: Int32) {
		switch oid {
			case .Unknown:
				self = .Null
			case .SmallInt:
				self = .Int16(Swift.Int16(Swift.String(cString: value))!)
			case .Int:
				self = .Int32(Swift.Int32(Swift.String(cString: value))!)
			case .BigInt:
				self = .Int64(Swift.Int64(Swift.String(cString: value))!)
			case .Numeric:
				self = .Numeric(Swift.String(cString: value))
			case .Real:
				self = .Float(Swift.Float(Swift.String(cString: value))!)
			case .Double:
				self = .Double(Swift.Double(Swift.String(cString: value))!)
			case .Money:
				self = .String(Swift.String(cString: value))
			case .VarChar, .Char, .Text:
				self = .String(Swift.String(cString: value))
			case .ByteArray:
				let valueString = Swift.String(cString: value)
				guard valueString.startsWith("\\x") else {
					fatalError("Unsupported bytea format: \(valueString)")
				}
				let bytes = valueString
					.chunksOf(2)
					.dropFirst()
					.map { $0.map { "\($0)" }.joined() }
					.map { UInt8($0, radix: 16)! }
				self = .Bytes(bytes)
			case .Timestamp, .TimestampWithTimezone, .Date, .Time,
			     .TimeWithTimezone, .TimeInterval:
				self = .String(Swift.String(cString: value))
			case .Boolean:
				self = .Bool(Swift.String(cString: value) == "t")
			case .Point, .Line, .LineSegment, .Box, .Path, .Polygon, .Circle:
				self = .String(Swift.String(cString: value))
			case .Network, .IPAddress, .MACAddress:
				self = .String(Swift.String(cString: value))
			case .BitString:
				self = .String(Swift.String(cString: value))
			case .TextSearchVector, .TextSearchQuery:
				self = .String(Swift.String(cString: value))
			case .UUID:
				self = .String(Swift.String(cString: value))
			case .XML, .JSON, .JSONB:
				self = .String(Swift.String(cString: value))
			case .Int32Range, .Int64Range, .NumericRange:
				self = .String(Swift.String(cString: value))
			case .TimestampRange, .TimeRange, .DateRange:
				self = .String(Swift.String(cString: value))
			case .oid, .regproc, .regprocedure, .regoper, .regoperator,
			     .regclass, .regtype, .regrole, .regnamespace, .regconfig,
			     .regdictionary:
				self = .String(Swift.String(cString: value))
			case .LogSequenceNumber:
				self = .String(Swift.String(cString: value))
			case .CustomType:
				self = .String(Swift.String(cString: value))
			case .SmallIntArray, .IntArray, .BigIntArray,
			     .NumericArray,
			     .RealArray, .DoubleArray,
			     .MoneyArray,
			     .VarCharArray, .CharArray, .TextArray,
			     .ByteArrayArray,
			     .TimestampArray, .TimestampWithTimezoneArray, .DateArray,
			     .TimeArray, .TimeWithTimezoneArray, .TimeIntervalArray,
			     .BooleanArray,
			     .PointArray, .LineArray, .LineSegmentArray, .BoxArray,
			     .PathArray, .PolygonArray, .CircleArray,
			     .NetworkArray, .IPAddressArray, .MACAddressArray,
			     .BitStringArray,
			     .TextSearchVectorArray, .TextSearchQueryArray,
			     .UUIDArray,
			     .XMLArray, .JSONArray, .JSONBArray,
			     .Int32RangeArray, .Int64RangeArray,
			     .NumericRangeArray,
			     .TimestampRangeArray, .TimeRangeArray, .DateRangeArray,
			     .oidArray, .regprocArray, .regprocedureArray, .regoperArray,
			     .regoperatorArray, .regclassArray, .regtypeArray,
			     .regroleArray, .regnamespaceArray, .regconfigArray,
			     .regdictionaryArray,
			     .LogSequenceNumberArray:
				self = .String(Swift.String(cString: value))
		}
	}
}
