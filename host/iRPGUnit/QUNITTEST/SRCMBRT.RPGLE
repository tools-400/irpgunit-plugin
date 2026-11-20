**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test JOB.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  COPTION(*EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,TYPES_H
/copy qinclude,OBJECT
/copy qinclude,SRCMBR
/copy qinclude,SDS
/copy qsysinc,QCMDEXC

//----------------------------------------------------------------------
//   Setup & Teardown
//----------------------------------------------------------------------

dcl-c TEMP_LIB  'QTEMP';
dcl-c TEMP_FILE 'RU_TEMP';

dcl-proc setUpSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s cmd varchar(512);
  dcl-s pgmLib varchar(10);

  pgmLib = %trim(sds.pgmLib);

  dltTempFiles();

  cmd = 'CRTPF FILE(' + TEMP_LIB + '/' + TEMP_FILE + ') RCDLEN(10)';
  qcmdexc(cmd: %len(cmd));

end-proc;

dcl-proc tearDownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dltTempFiles();

end-proc;

dcl-proc dltTempFiles;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s cmd varchar(512);
  dcl-s pgmLib varchar(10);
  dcl-ds qFile likeds(object_t) inz;

  pgmLib = %trim(sds.pgmLib);

  monitor;
    qFile.nm = TEMP_FILE;
    qFile.lib = TEMP_LIB;
    if (Object_exists(qFile: '*FILE'));
      cmd = 'DLTF FILE(' + TEMP_LIB + '/' + TEMP_FILE + ')';
      qcmdexc(cmd: %len(cmd));
    endif;
  on-error;
  endmon;

end-proc;

//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc testGetCcsid_noSrcFile export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s ccsid like(ccsid_t);
  dcl-ds qSrcFile likeds(object_t) inz;

  monitor;
    qSrcFile.nm = TEMP_FILE;
    qSrcFile.lib = TEMP_LIB;
    ccsid = SrcMbr_getCcsid(qSrcFile);
    fail('Expected ''SrcMbr_getCcsid()'' to send an escape message');
  on-error;
    // exception seen
  endmon;

end-proc;

dcl-proc testGetCcsid_srcFile export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s ccsid like(ccsid_t);
  dcl-ds qSrcFile likeds(object_t) inz;

  qSrcFile.nm = 'QUNITTEST';
  qSrcFile.lib = sds.pgmLib;
  ccsid = SrcMbr_getCcsid(qSrcFile);

  assertEqual(273: ccsid);

end-proc;

//----------------------------------------------------------------------
// Finds the source of a module, that is not the first module of a
// service program. The entries of the module list have variable
// length.
//----------------------------------------------------------------------
dcl-proc testGetModSrc_laterModule export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds qSrvPgm likeds(object_t) inz;
  dcl-ds qMod likeds(object_t) inz;
  dcl-ds srcInf likeds(srcInf_t) inz;

  // RUTESTCASE is created from modules ASSERT, ASSERTV2, TESTUTILS,
  // VERSION and the modules of binding directory IRPGUNIT.
  qSrvPgm.nm = 'RUTESTCASE';
  qSrvPgm.lib = sds.pgmLib;
  qMod.nm = 'VERSION';
  qMod.lib = '*LIBL';

  SrcMbr_initialize();
  srcInf = SrcMbr_getModSrc(qSrvPgm: qMod);

  assertEqual(TYPE_MEMBER: srcInf.type);
  assertEqual('QSRC': srcInf.mbr.file);
  assertEqual('VERSION': srcInf.mbr.mbr);

end-proc;

