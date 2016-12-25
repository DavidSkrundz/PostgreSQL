//
//  ObjectIDTests.swift
//  PostgreSQL
//

@testable import PostgreSQL
import XCTest

class ObjectIDTests: XCTestCase {
	static let database = {
		return Database()
			.withHost("localhost")
			.withDatabaseName("test")
			.withUser("postgres")
			.withConnectTimeout(10)
			.withApplicationName("TestApplication")
	}()
	
	override func setUp() {
		super.setUp()
		
		do {
			let connection = try ObjectIDTests.database.connect()
			_ = connection.execute("DROP TABLE test.test;")
			_ = connection.execute("DROP TYPE complex;")
			_ = connection.execute("DROP TYPE mood;")
			_ = connection.execute("DROP FUNCTION testfunc ();")
			_ = connection.execute("DROP FUNCTION add(integer, integer);")
			_ = connection.execute("DROP OPERATOR test.===(integer, integer);")
			_ = connection.execute("DROP FUNCTION add(integer, integer);")
			_ = connection.execute("DROP ROLE testrole;")
			_ = connection.execute("DROP SCHEMA test;")
			
			_ = connection.execute("CREATE SCHEMA test;")
		} catch let error {
			print("⚠️ Postgres Not Configured ⚠️")
			print("Error: \(error)")
			print()
			print("Postgres should be configured for:")
			print("  Host: localhost")
			print("  Database: test")
			print("  Username: postgres")
			
			XCTFail("Postgres Not Configured")
			fatalError()
		}
	}
	
	override func tearDown() {
		super.tearDown()
		
		let connection = try? ObjectIDTests.database.connect()
		_ = connection?.execute("DROP TABLE test.test;")
		_ = connection?.execute("DROP SCHEMA test;")
	}
	
	private func connect(_ type: String,
	                     _ value: String) throws -> ResultEntry {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.unsafeExecute("CREATE TABLE test.test (a \(type));")
		_ = connection.unsafeExecute("INSERT INTO test.test (a) values (\(value));")
		let results = connection.execute("SELECT * from test.test;")!
		return results.results[0][0]
	}
	
	func test_smallint() throws {
		let result = try self.connect("smallint", "2")
		
		XCTAssertEqual(result.type, .SmallInt)
		guard case let ResultValue.Int16(x) = result.value else {
			XCTFail("Expecting '.Int16', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, 2)
	}
	
	func test_integer() throws {
		let result = try self.connect("integer", "2")
		
		XCTAssertEqual(result.type, .Int)
		guard case let ResultValue.Int32(x) = result.value else {
			XCTFail("Expecting '.Int32', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, 2)
	}
	
	func test_bigint() throws {
		let result = try self.connect("bigint", "2")
		
		XCTAssertEqual(result.type, .BigInt)
		guard case let ResultValue.Int64(x) = result.value else {
			XCTFail("Expecting '.Int64', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, 2)
	}
	
	func test_numeric() throws {
		let result = try self.connect("numeric", "2")
		
		XCTAssertEqual(result.type, .Numeric)
		guard case let ResultValue.Numeric(x) = result.value else {
			XCTFail("Expecting '.Numeric', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "2")
	}
	
	func test_real() throws {
		let result = try self.connect("real", "2.2")
		
		XCTAssertEqual(result.type, .Real)
		guard case let ResultValue.Float(x) = result.value else {
			XCTFail("Expecting '.Float', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, 2.2)
	}
	
	func test_double_precision() throws {
		let result = try self.connect("double precision", "2.2")
		
		XCTAssertEqual(result.type, .Double)
		guard case let ResultValue.Double(x) = result.value else {
			XCTFail("Expecting '.Double', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, 2.2)
	}
	
	func test_money() throws {
		let result = try self.connect("money", "2")
		
		XCTAssertEqual(result.type, .Money)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "$2.00")
	}
	
	func test_varchar() throws {
		let result = try self.connect("varchar(10)", "'abc'")
		
		XCTAssertEqual(result.type, .VarChar)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "abc")
	}
	
	func test_char() throws {
		let result = try self.connect("char(10)", "'abc'")
		
		XCTAssertEqual(result.type, .Char)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "abc       ")
	}
	
	func test_text() throws {
		let result = try self.connect("text", "'abcde'")
		
		XCTAssertEqual(result.type, .Text)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "abcde")
	}
	
	func test_bytea() throws {
		let result = try self.connect("bytea", "'\\x010203'")
		
		XCTAssertEqual(result.type, .ByteArray)
		guard case let ResultValue.Bytes(x) = result.value else {
			XCTFail("Expecting '.Bytes', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, [1,2,3])
	}
	
	func test_timestamp() throws {
		let result = try self.connect("timestamp", "'2004-10-19 10:23:54'")
		
		XCTAssertEqual(result.type, .Timestamp)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "2004-10-19 10:23:54")
	}
	
	func test_timestamptz() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE TABLE test.test (a timestamptz);")
		_ = connection.execute("begin;")
		_ = connection.execute("set local timezone to 'EST5EDT';")
		_ = connection.execute("INSERT INTO test.test (a) values ('2004-10-19 07:23:54');")
		let results = connection.execute("SELECT * from test.test;")!
		_ = connection.execute("end;")
		let result = results.results[0][0]
		
		XCTAssertEqual(result.type, .TimestampWithTimezone)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "2004-10-19 07:23:54-04")
	}
	
	func test_date() throws {
		let result = try self.connect("date", "'08-Jan-1999'")
		
		XCTAssertEqual(result.type, .Date)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "1999-01-08")
	}
	
	func test_time() throws {
		let result = try self.connect("time", "'10:23:54'")
		
		XCTAssertEqual(result.type, .Time)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "10:23:54")
	}
	
	func test_timetz() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE TABLE test.test (a timetz);")
		_ = connection.execute("begin;")
		_ = connection.execute("set local timezone to 'EST5EDT';")
		_ = connection.execute("INSERT INTO test.test (a) values ('07:23:54');")
		let results = connection.execute("SELECT * from test.test;")!
		_ = connection.execute("end;")
		let result = results.results[0][0]
		
		XCTAssertEqual(result.type, .TimeWithTimezone)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "07:23:54-05")
	}
	
	func test_interval() throws {
		let result = try self.connect("interval", "'3 4:05:06'")
		
		XCTAssertEqual(result.type, .TimeInterval)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "3 days 04:05:06")
	}
	
	func test_boolean() throws {
		let result = try self.connect("boolean", "'y'")
		
		XCTAssertEqual(result.type, .Boolean)
		guard case let ResultValue.Bool(x) = result.value else {
			XCTFail("Expecting '.Bool', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, true)
	}
	
	func test_CREATE_TYPE_AS_ENUM() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');")
		let result = try self.connect("mood", "'sad'")
		
		XCTAssertEqual(result.type, .CustomType)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "sad")
		
		_ = connection.execute("DROP TYPE mood;")
	}
	
	func test_point() throws {
		let result = try self.connect("point", "'(1,2)'")
		
		XCTAssertEqual(result.type, .Point)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "(1,2)")
	}
	
	func test_line() throws {
		let result = try self.connect("line", "'{1,2,3}'")
		
		XCTAssertEqual(result.type, .Line)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{1,2,3}")
	}
	
	func test_lseg() throws {
		let result = try self.connect("lseg", "'[(1,2),(3,4)]'")
		
		XCTAssertEqual(result.type, .LineSegment)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "[(1,2),(3,4)]")
	}
	
	func test_box() throws {
		let result = try self.connect("box", "'((1,2),(3,4))'")
		
		XCTAssertEqual(result.type, .Box)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "(3,4),(1,2)")
	}
	
	func test_path() throws {
		let result = try self.connect("path", "'((1,2),(3,4))'")
		
		XCTAssertEqual(result.type, .Path)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "((1,2),(3,4))")
	}
	
	func test_path_open() throws {
		let result = try self.connect("path", "'[(1,2),(3,4)]'")
		
		XCTAssertEqual(result.type, .Path)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "[(1,2),(3,4)]")
	}
	
	func test_polygon() throws {
		let result = try self.connect("polygon", "'((1,2),(3,4))'")
		
		XCTAssertEqual(result.type, .Polygon)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "((1,2),(3,4))")
	}
	
	func test_circle() throws {
		let result = try self.connect("circle", "'<(1,2),3>'")
		
		XCTAssertEqual(result.type, .Circle)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "<(1,2),3>")
	}
	
	func test_cidr() throws {
		let result = try self.connect("cidr", "'128.1'")
		
		XCTAssertEqual(result.type, .Network)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "128.1.0.0/16")
	}
	
	func test_inet() throws {
		let result = try self.connect("inet", "'192.168.100.128'")
		
		XCTAssertEqual(result.type, .IPAddress)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "192.168.100.128")
	}
	
	func test_macaddr() throws {
		let result = try self.connect("macaddr", "'08002b-010203'")
		
		XCTAssertEqual(result.type, .MACAddress)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "08:00:2b:01:02:03")
	}
	
	func test_bit() throws {
		let result = try self.connect("bit(3)", "B'101'")
		
		XCTAssertEqual(result.type, .BitString)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "101")
	}
	
	func test_tsvector() throws {
		let result = try self.connect("tsvector", "'a fat cat sat on a mat and ate a fat rat'::tsvector")
		
		XCTAssertEqual(result.type, .TextSearchVector)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "'a' 'and' 'ate' 'cat' 'fat' 'mat' 'on' 'rat' 'sat'")
	}
	
	func test_tsquery() throws {
		let result = try self.connect("tsquery", "'fat:ab & cat'::tsquery")
		
		XCTAssertEqual(result.type, .TextSearchQuery)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "'fat':AB & 'cat'")
	}
	
	func test_uuid() throws {
		let result = try self.connect("uuid", "'a0eebc999c0b4ef8bb6d6bb9bd380a11'")
		
		XCTAssertEqual(result.type, .UUID)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11")
	}
	
	func test_xml() throws {
		let result = try self.connect("xml", "xml'<foo>bar</foo>'")
		
		XCTAssertEqual(result.type, .XML)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "<foo>bar</foo>")
	}
	
	func test_json() throws {
		let result = try self.connect("json", "'{\"foo\": [true, \"bar\"], \"tags\": {\"a\": 1, \"b\": null}}'")
		
		XCTAssertEqual(result.type, .JSON)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{\"foo\": [true, \"bar\"], \"tags\": {\"a\": 1, \"b\": null}}")
	}
	
	func test_jsonb() throws {
		let result = try self.connect("jsonb", "'{\"foo\": {\"bar\": \"baz\"}}'::jsonb")
		
		XCTAssertEqual(result.type, .JSONB)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{\"foo\": {\"bar\": \"baz\"}}")
	}
	
	func test_CREATE_TYPE_AS() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE TYPE complex AS (r double precision, i double precision);")
		let result = try self.connect("complex", "'(1.2,2.3)'")
		
		XCTAssertEqual(result.type, .CustomType)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "(1.2,2.3)")
		
		_ = connection.execute("DROP TYPE complex;")
	}
	
	func test_int4range() throws {
		let result = try self.connect("int4range", "int4range(10, 20)")
		
		XCTAssertEqual(result.type, .Int32Range)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "[10,20)")
	}
	
	func test_int8range() throws {
		let result = try self.connect("int8range", "int8range(10, 20)")
		
		XCTAssertEqual(result.type, .Int64Range)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "[10,20)")
	}
	
	func test_numrange() throws {
		let result = try self.connect("numrange", "numrange(10, 20)")
		
		XCTAssertEqual(result.type, .NumericRange)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "[10,20)")
	}
	
	func test_tsrange() throws {
		let result = try self.connect("tsrange", "'[2010-01-01 14:30, 2010-01-01 15:30)'")
		
		XCTAssertEqual(result.type, .TimestampRange)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "[\"2010-01-01 14:30:00\",\"2010-01-01 15:30:00\")")
	}
	
	func test_tstzrange() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE TABLE test.test (a tstzrange);")
		_ = connection.execute("begin;")
		_ = connection.execute("set local timezone to 'EST5EDT';")
		_ = connection.execute("INSERT INTO test.test (a) values ('[2010-01-01 14:30+01, 2010-01-01 15:30+01)');")
		let results = connection.execute("SELECT * from test.test;")!
		_ = connection.execute("end;")
		let result = results.results[0][0]
		
		XCTAssertEqual(result.type, .TimeRange)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "[\"2010-01-01 08:30:00-05\",\"2010-01-01 09:30:00-05\")")
	}
	
	func test_daterange() throws {
		let result = try self.connect("daterange", "'[2010-01-01, 2010-02-01)'")
		
		XCTAssertEqual(result.type, .DateRange)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "[2010-01-01,2010-02-01)")
	}
	
	func test_oid() throws {
		let result = try self.connect("oid", "564182")
		
		XCTAssertEqual(result.type, .oid)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "564182")
	}
	
	func test_regproc() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE FUNCTION testfunc () RETURNS integer AS $number$ declare number integer; BEGIN SELECT '123'::integer into number; RETURN number; END; $number$ LANGUAGE plpgsql;")
		let result = try self.connect("regproc", "'testfunc'")
		
		XCTAssertEqual(result.type, .regproc)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "testfunc")
		
		_ = connection.execute("DROP FUNCTION testfunc ();")
	}
	
	func test_regprocedure() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE FUNCTION add(integer, integer) RETURNS integer AS 'select $1 + $2;' LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;")
		let result = try self.connect("regprocedure", "'add(integer,integer)'")
		
		XCTAssertEqual(result.type, .regprocedure)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "add(integer,integer)")
		
		_ = connection.execute("DROP FUNCTION add(integer, integer);")
	}
	
	func test_regoper() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE FUNCTION add(integer, integer) RETURNS integer AS 'select $1 + $2;' LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;")
		_ = connection.execute("CREATE OPERATOR test.===(PROCEDURE = add, LEFTARG = integer, RIGHTARG = integer);")
		let result = try self.connect("regoper", "'test.==='")
		
		XCTAssertEqual(result.type, .regoper)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "test.===")
		
		_ = connection.execute("DROP OPERATOR test.===(integer, integer);")
		_ = connection.execute("DROP FUNCTION add(integer, integer);")
	}
	
	func test_regoperator() throws {
		let result = try self.connect("regoperator", "'*(integer,integer)'")
		
		XCTAssertEqual(result.type, .regoperator)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "*(integer,integer)")
	}
	
	func test_regclass() throws {
		let result = try self.connect("regclass", "'pg_type'")
		
		XCTAssertEqual(result.type, .regclass)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "pg_type")
	}
	
	func test_regtype() throws {
		let result = try self.connect("regtype", "'integer'")
		
		XCTAssertEqual(result.type, .regtype)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "integer")
	}
	
	func test_regrole() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE ROLE testrole;")
		let result = try self.connect("regrole", "'testrole'")
		
		XCTAssertEqual(result.type, .regrole)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "testrole")
		
		_ = connection.execute("DROP ROLE testrole;")
	}
	
	func test_regnamespace() throws {
		let result = try self.connect("regnamespace", "'pg_catalog'")
		
		XCTAssertEqual(result.type, .regnamespace)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "pg_catalog")
	}
	
	func test_regconfig() throws {
		let result = try self.connect("regconfig", "'english'")
		
		XCTAssertEqual(result.type, .regconfig)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "english")
	}
	
	func test_regdictionary() throws {
		let result = try self.connect("regdictionary", "'simple'")
		
		XCTAssertEqual(result.type, .regdictionary)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "simple")
	}
	
	func test_pg_lsn() throws {
		let result = try self.connect("pg_lsn", "'16/B374D848'")
		
		XCTAssertEqual(result.type, .LogSequenceNumber)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "16/B374D848")
	}
	
	func test_smallint_array() throws {
		let result = try self.connect("smallint[]", "'{}'")
		
		XCTAssertEqual(result.type, .SmallIntArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_integer_array() throws {
		let result = try self.connect("integer[]", "'{}'")
		
		XCTAssertEqual(result.type, .IntArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_bigint_array() throws {
		let result = try self.connect("bigint[]", "'{}'")
		
		XCTAssertEqual(result.type, .BigIntArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_numeric_array() throws {
		let result = try self.connect("numeric[]", "'{}'")
		
		XCTAssertEqual(result.type, .NumericArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_real_array() throws {
		let result = try self.connect("real[]", "'{}'")
		
		XCTAssertEqual(result.type, .RealArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_double_precision_array() throws {
		let result = try self.connect("double precision[]", "'{}'")
		
		XCTAssertEqual(result.type, .DoubleArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_money_array() throws {
		let result = try self.connect("money[]", "'{}'")
		
		XCTAssertEqual(result.type, .MoneyArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_varchar_array() throws {
		let result = try self.connect("varchar(10)[]", "'{}'")
		
		XCTAssertEqual(result.type, .VarCharArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_char_array() throws {
		let result = try self.connect("char(10)[]", "'{}'")
		
		XCTAssertEqual(result.type, .CharArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_text_array() throws {
		let result = try self.connect("text[]", "'{}'")
		
		XCTAssertEqual(result.type, .TextArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_bytea_array() throws {
		let result = try self.connect("bytea[]", "'{}'")
		
		XCTAssertEqual(result.type, .ByteArrayArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_timestamp_array() throws {
		let result = try self.connect("timestamp[]", "'{}'")
		
		XCTAssertEqual(result.type, .TimestampArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_timestamptz_array() throws {
		let result = try self.connect("timestamptz[]", "'{}'")
		
		XCTAssertEqual(result.type, .TimestampWithTimezoneArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_date_array() throws {
		let result = try self.connect("date[]", "'{}'")
		
		XCTAssertEqual(result.type, .DateArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_time_array() throws {
		let result = try self.connect("time[]", "'{}'")
		
		XCTAssertEqual(result.type, .TimeArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_timetz_array() throws {
		let result = try self.connect("timetz[]", "'{}'")
		
		XCTAssertEqual(result.type, .TimeWithTimezoneArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_interval_array() throws {
		let result = try self.connect("interval[]", "'{}'")
		
		XCTAssertEqual(result.type, .TimeIntervalArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_boolean_array() throws {
		let result = try self.connect("boolean[]", "'{}'")
		
		XCTAssertEqual(result.type, .BooleanArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_CREATE_TYPE_AS_ENUM_array() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');")
		let result = try self.connect("mood[]", "'{}'")
		
		XCTAssertEqual(result.type, .CustomType)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
		
		_ = connection.execute("DROP TYPE mood;")
	}
	
	func test_point_array() throws {
		let result = try self.connect("point[]", "'{}'")
		
		XCTAssertEqual(result.type, .PointArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_line_array() throws {
		let result = try self.connect("line[]", "'{}'")
		
		XCTAssertEqual(result.type, .LineArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_lseg_array() throws {
		let result = try self.connect("lseg[]", "'{}'")
		
		XCTAssertEqual(result.type, .LineSegmentArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_box_array() throws {
		let result = try self.connect("box[]", "'{}'")
		
		XCTAssertEqual(result.type, .BoxArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_path_array() throws {
		let result = try self.connect("path[]", "'{}'")
		
		XCTAssertEqual(result.type, .PathArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_polygon_array() throws {
		let result = try self.connect("polygon[]", "'{}'")
		
		XCTAssertEqual(result.type, .PolygonArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_circle_array() throws {
		let result = try self.connect("circle[]", "'{}'")
		
		XCTAssertEqual(result.type, .CircleArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_cidr_array() throws {
		let result = try self.connect("cidr[]", "'{}'")
		
		XCTAssertEqual(result.type, .NetworkArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_inet_array() throws {
		let result = try self.connect("inet[]", "'{}'")
		
		XCTAssertEqual(result.type, .IPAddressArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_macaddr_array() throws {
		let result = try self.connect("macaddr[]", "'{}'")
		
		XCTAssertEqual(result.type, .MACAddressArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_bit_array() throws {
		let result = try self.connect("bit(3)[]", "'{}'")
		
		XCTAssertEqual(result.type, .BitStringArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_tsvector_array() throws {
		let result = try self.connect("tsvector[]", "'{}'")
		
		XCTAssertEqual(result.type, .TextSearchVectorArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_tsquery_array() throws {
		let result = try self.connect("tsquery[]", "'{}'")
		
		XCTAssertEqual(result.type, .TextSearchQueryArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_uuid_array() throws {
		let result = try self.connect("uuid[]", "'{}'")
		
		XCTAssertEqual(result.type, .UUIDArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_xml_array() throws {
		let result = try self.connect("xml[]", "'{}'")
		
		XCTAssertEqual(result.type, .XMLArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_json_array() throws {
		let result = try self.connect("json[]", "'{}'")
		
		XCTAssertEqual(result.type, .JSONArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_jsonb_array() throws {
		let result = try self.connect("jsonb[]", "'{}'")
		
		XCTAssertEqual(result.type, .JSONBArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_CREATE_TYPE_AS_array() throws {
		let connection = try ObjectIDTests.database.connect()
		_ = connection.execute("CREATE TYPE complex AS (r double precision, i double precision);")
		let result = try self.connect("complex[]", "'{}'")
		
		XCTAssertEqual(result.type, .CustomType)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
		
		_ = connection.execute("DROP TYPE complex;")
	}
	
	func test_int4range_array() throws {
		let result = try self.connect("int4range[]", "'{}'")
		
		XCTAssertEqual(result.type, .Int32RangeArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_int8range_array() throws {
		let result = try self.connect("int8range[]", "'{}'")
		
		XCTAssertEqual(result.type, .Int64RangeArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_numrange_array() throws {
		let result = try self.connect("numrange[]", "'{}'")
		
		XCTAssertEqual(result.type, .NumericRangeArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_tsrange_array() throws {
		let result = try self.connect("tsrange[]", "'{}'")
		
		XCTAssertEqual(result.type, .TimestampRangeArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_tstzrange_array() throws {
		let result = try self.connect("tstzrange[]", "'{}'")
		
		XCTAssertEqual(result.type, .TimeRangeArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_daterange_array() throws {
		let result = try self.connect("daterange[]", "'{}'")
		
		XCTAssertEqual(result.type, .DateRangeArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_oid_array() throws {
		let result = try self.connect("oid[]", "'{}'")
		
		XCTAssertEqual(result.type, .oidArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regproc_array() throws {
		let result = try self.connect("regproc[]", "'{}'")
		
		XCTAssertEqual(result.type, .regprocArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regprocedure_array() throws {
		let result = try self.connect("regprocedure[]", "'{}'")
		
		XCTAssertEqual(result.type, .regprocedureArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regoper_array() throws {
		let result = try self.connect("regoper[]", "'{}'")
		
		XCTAssertEqual(result.type, .regoperArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regoperator_array() throws {
		let result = try self.connect("regoperator[]", "'{}'")
		
		XCTAssertEqual(result.type, .regoperatorArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regclass_array() throws {
		let result = try self.connect("regclass[]", "'{}'")
		
		XCTAssertEqual(result.type, .regclassArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regtype_array() throws {
		let result = try self.connect("regtype[]", "'{}'")
		
		XCTAssertEqual(result.type, .regtypeArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regrole_array() throws {
		let result = try self.connect("regrole[]", "'{}'")
		
		XCTAssertEqual(result.type, .regroleArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regnamespace_array() throws {
		let result = try self.connect("regnamespace[]", "'{}'")
		
		XCTAssertEqual(result.type, .regnamespaceArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regconfig_array() throws {
		let result = try self.connect("regconfig[]", "'{}'")
		
		XCTAssertEqual(result.type, .regconfigArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_regdictionary_array() throws {
		let result = try self.connect("regdictionary[]", "'{}'")
		
		XCTAssertEqual(result.type, .regdictionaryArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	func test_pg_lsn_array() throws {
		let result = try self.connect("pg_lsn[]", "'{}'")
		
		XCTAssertEqual(result.type, .LogSequenceNumberArray)
		guard case let ResultValue.String(x) = result.value else {
			XCTFail("Expecting '.String', found '\(result.value)'")
			return
		}
		XCTAssertEqual(x, "{}")
	}
	
	static var allTests = [
		("test_smallint", test_smallint),
		("test_integer", test_integer),
		("test_bigint", test_bigint),
		("test_numeric", test_numeric),
		("test_real", test_real),
		("test_double_precision", test_double_precision),
		("test_money", test_money),
		("test_varchar", test_varchar),
		("test_char", test_char),
		("test_text", test_text),
		("test_bytea", test_bytea),
		("test_timestamp", test_timestamp),
		("test_timestamptz", test_timestamptz),
		("test_date", test_date),
		("test_time", test_time),
		("test_timetz", test_timetz),
		("test_interval", test_interval),
		("test_boolean", test_boolean),
		("test_CREATE_TYPE_AS_ENUM", test_CREATE_TYPE_AS_ENUM),
		("test_point", test_point),
		("test_line", test_line),
		("test_lseg", test_lseg),
		("test_box", test_box),
		("test_path", test_path),
		("test_path_open", test_path_open),
		("test_polygon", test_polygon),
		("test_circle", test_circle),
		("test_cidr", test_cidr),
		("test_inet", test_inet),
		("test_macaddr", test_macaddr),
		("test_bit", test_bit),
		("test_tsvector", test_tsvector),
		("test_tsquery", test_tsquery),
		("test_uuid", test_uuid),
		("test_xml", test_xml),
		("test_json", test_json),
		("test_jsonb", test_jsonb),
		("test_CREATE_TYPE_AS", test_CREATE_TYPE_AS),
		("test_int4range", test_int4range),
		("test_int8range", test_int8range),
		("test_numrange", test_numrange),
		("test_tsrange", test_tsrange),
		("test_tstzrange", test_tstzrange),
		("test_daterange", test_daterange),
		("test_oid", test_oid),
		("test_regproc", test_regproc),
		("test_regprocedure", test_regprocedure),
		("test_regoper", test_regoper),
		("test_regoperator", test_regoperator),
		("test_regclass", test_regclass),
		("test_regtype", test_regtype),
		("test_regrole", test_regrole),
		("test_regnamespace", test_regnamespace),
		("test_regconfig", test_regconfig),
		("test_regdictionary", test_regdictionary),
		("test_pg_lsn", test_pg_lsn),
		
		("test_smallint_array", test_smallint_array),
		("test_integer_array", test_integer_array),
		("test_bigint_array", test_bigint_array),
		("test_numeric_array", test_numeric_array),
		("test_real_array", test_real_array),
		("test_double_precision_array", test_double_precision_array),
		("test_money_array", test_money_array),
		("test_varchar_array", test_varchar_array),
		("test_char_array", test_char_array),
		("test_text_array", test_text_array),
		("test_bytea_array", test_bytea_array),
		("test_timestamp_array", test_timestamp_array),
		("test_timestamptz_array", test_timestamptz_array),
		("test_date_array", test_date_array),
		("test_time_array", test_time_array),
		("test_timetz_array", test_timetz_array),
		("test_interval_array", test_interval_array),
		("test_boolean_array", test_boolean_array),
		("test_CREATE_TYPE_AS_ENUM_array", test_CREATE_TYPE_AS_ENUM_array),
		("test_point_array", test_point_array),
		("test_line_array", test_line_array),
		("test_lseg_array", test_lseg_array),
		("test_box_array", test_box_array),
		("test_path_array", test_path_array),
		("test_polygon_array", test_polygon_array),
		("test_circle_array", test_circle_array),
		("test_cidr_array", test_cidr_array),
		("test_inet_array", test_inet_array),
		("test_macaddr_array", test_macaddr_array),
		("test_bit_array", test_bit_array),
		("test_tsvector_array", test_tsvector_array),
		("test_tsquery_array", test_tsquery_array),
		("test_uuid_array", test_uuid_array),
		("test_xml_array", test_xml_array),
		("test_json_array", test_json_array),
		("test_jsonb_array", test_jsonb_array),
		("test_CREATE_TYPE_AS_array", test_CREATE_TYPE_AS_array),
		("test_int4range_array", test_int4range_array),
		("test_int8range_array", test_int8range_array),
		("test_numrange_array", test_numrange_array),
		("test_tsrange_array", test_tsrange_array),
		("test_tstzrange_array", test_tstzrange_array),
		("test_daterange_array", test_daterange_array),
		("test_oid_array", test_oid_array),
		("test_regproc_array", test_regproc_array),
		("test_regprocedure_array", test_regprocedure_array),
		("test_regoper_array", test_regoper_array),
		("test_regoperator_array", test_regoperator_array),
		("test_regclass_array", test_regclass_array),
		("test_regtype_array", test_regtype_array),
		("test_regrole_array", test_regrole_array),
		("test_regnamespace_array", test_regnamespace_array),
		("test_regconfig_array", test_regconfig_array),
		("test_regdictionary_array", test_regdictionary_array),
		("test_pg_lsn_array", test_pg_lsn_array),
	]
}
