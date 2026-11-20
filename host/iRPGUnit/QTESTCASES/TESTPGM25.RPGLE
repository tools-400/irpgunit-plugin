**FREE
// ==========================================================================
//  iRPGUnit Fixture - Long values and quotes in XML output files.
//  Each test is called with its own RUCALLTST TSTPRC(...) by XMLSTMFT.
// ==========================================================================
//  Copyright (c) 2026 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
//    >>PRE-COMPILER<<
//      >>CRTCMD<<  RUCRTRPG    TSTPGM(&LI/&OB) +
//                              SRCFILE(&SL/&SF) SRCMBR(&SM);
//      >>IMPORTANT<<
//        >>PARM<< COPTION(*SRCSTMT *EVENTF);
//        >>PARM<< DBGVIEW(*LIST);
//      >>END-IMPORTANT<<
//      >>EXECUTE<<
//    >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,TESTCASE

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// End of the value of testLongValue().
dcl-c END_OF_LONG_VALUE 'END_OF_LONG_VALUE';

//----------------------------------------------------------------------
//   Test 'Success': value of 597 characters without characters, that
//   must be escaped in XML.
//----------------------------------------------------------------------
dcl-proc testLongValue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s value varchar(600);
  dcl-s i int(10);

  value = '';
  for i = 1 to 58;
    value += 'abcdefghij';
  endfor;
  value += END_OF_LONG_VALUE;

  assertEqual(value: value);

end-proc;

//----------------------------------------------------------------------
//   Test 'Success': JSON value of 2000 characters, half of them quotes.
//----------------------------------------------------------------------
dcl-proc testQuotedValue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s json varchar(2048);

  json = jsonOf(2000);

  assertEqual(json: json);

end-proc;

//----------------------------------------------------------------------
//   Test 'Failure': message of 1024 characters, half of them quotes.
//----------------------------------------------------------------------
dcl-proc testQuotedMessage export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s json1 varchar(2048);
  dcl-s json2 varchar(2048);

  json1 = jsonOf(1000);
  json2 = %subst(json1: 1: %len(json1) - 1) + 'X';

  assertEqual(json1: json2);

end-proc;

//----------------------------------------------------------------------
//   Returns a JSON string of about 'len' characters.
//----------------------------------------------------------------------
dcl-proc jsonOf;
  dcl-pi *n varchar(2048) extproc(*dclcase);
    len int(10) const;
  end-pi;

  dcl-s json varchar(2048);

  json = '{';
  dow (%len(json) + 8 + 6 <= len);
    json += '"a":"b",';
  enddo;
  json += '"z":1}';

  return json;

end-proc;
