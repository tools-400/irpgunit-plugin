**FREE
// ==========================================================================
//  iRPGUnit Fixture - Backslash in stream file paths in CCSID 37.
//  ACPTSTT compiles it with BNDDIR(IRPGUNIT) and runs it in a job with
//  CCSID 37.
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
//        >>PARM<< BNDDIR(&LI/IRPGUNIT);
//        >>PARM<< BOPTION(*DUPPROC *DUPVAR);
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
/include qinclude,STMF

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// Backslash in CCSID 37.
dcl-c BACK_SLASH_37 x'E0';

//----------------------------------------------------------------------
//   Test 'Success' in a job with CCSID 37.
//----------------------------------------------------------------------
dcl-proc testBackslash export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual('/a/b': Stmf_resolvePath('/a' + BACK_SLASH_37 + 'b'));

end-proc;
