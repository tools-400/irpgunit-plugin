**FREE
// ==========================================================================
//  iRPGUnit Fixture - Exported procedure with a name of more than 256
//  characters.
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
//   Test 'Success'
//----------------------------------------------------------------------
dcl-proc testSuccess export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assert(*on: 'Success');

end-proc;

//----------------------------------------------------------------------
//   Exported procedure with a name of 300 characters. It is not a
//   test case.
//----------------------------------------------------------------------
dcl-proc longName export;
  dcl-pi *n extproc('LONG_EXPORT_NAME_0123456789_0123456789_0123456789+
_0123456789_0123456789_0123456789_0123456789_0123456789_0123456789+
_0123456789_0123456789_0123456789_0123456789_0123456789_0123456789+
_0123456789_0123456789_0123456789_0123456789_0123456789_0123456789+
_0123456789_0123456789_0123456789_0123456789_0123456789_0123456789');
  end-pi;
end-proc;
