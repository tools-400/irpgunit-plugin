**free
// ==========================================================================
//  iRPGUnit SelfTest - Test CRTTSTT.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  BNDSRVPGM(&LI/RUMEMMGR);
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  COPTION(*EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain option(*srcstmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,IFSIO_H
/copy qinclude,LIBC_H
/copy qinclude,LIBL
/copy qinclude,CRTTST
/copy qinclude,OBJECT
/copy qinclude,TYPES_H

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// No debugging view given by user.
dcl-c noDbgView *blank;
// RPG preprocessor options.
dcl-c rpgPpOptLvl2 '*LVL2';
// No export option.
dcl-c noExport *blank;
// No text.
dcl-c noText *blank;

dcl-c TEMP_DIR '/temp/';
dcl-c STMF_RPGLE 'temp_irpgunit1.rpgle';
dcl-c STMF_SQLRPGLE 'temp_irpgunit1.sqlrpgle';
dcl-c STMF_SQLCBLLE 'temp_irpgunit1.sqlcblle';

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// No source file.
dcl-ds noSrcFile likeds(Object_t);
// No source member.
dcl-s noSrcMbr like(SrcMbr_t.mbr);
// No source stream file.
dcl-s noSrcStmf like(ifsStmf_t);
// No compile option.
dcl-ds noCOption likeds(Options_t);
// No SQL pre-compiler option.
dcl-ds noPOption likeds(Options_t);
// No service program to bind.
dcl-ds noBndSrvPgm likeds(ObjectArray_t);
// No binding directory.
dcl-ds noBndDir likeds(ObjectArray_t);
// No binding option.
dcl-ds noBOption likeds(Options_t);
// No modules.
dcl-ds noModule likeds(ObjectArray_t);
// No SQL pre-compiler compile option.
dcl-s noCompileOpt varchar(1);
// No compiler parameters.
dcl-s noCompilerParams varchar(1);
// No linker parameters.
dcl-s noLinkerParams varchar(1);
// No activation group.
dcl-s noActGrp varchar(10);
// No target release
dcl-s noTargetRls like(TargetRelease_t);
// No condition names
dcl-ds noDefine likeds(defines_t);
// No include directories.
dcl-ds noIncDir likeds(incDir_t);
// No target CCSID.
dcl-s noTgtCcsid like(tgtCcsid_t);
// No conversion CCSID.
dcl-s noCvtCcsid like(cvtCcsid_t);

// Command to create an RPG module.
dcl-s crtRpgModCmd char(256);
// Command to create a Cobol module.
dcl-s crtCblModCmd char(256);
// Command to create a Service Program object.
dcl-s crtSrvPgmCmd char(256);

dcl-ds liblList likeds(LiblData_t);
dcl-ds newLiblList likeds(LiblData_t);

//---------------------------------------------------------------------
//   Program Status Data Structure
//---------------------------------------------------------------------

/copy qinclude,SDS

//----------------------------------------------------------------------
//   Test Procedures
//----------------------------------------------------------------------

dcl-proc setup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  clear crtCblModCmd;

  clear crtRpgModCmd;

  clear noSrcFile;
  noSrcFile.nm = '';
  noSrcFile.lib = '*LIBL';

  clear noCOption;
  noCOption.size = 0;

  clear noPOption;
  noPOption.size = 0;

  clear noBndSrvPgm;
  noBndSrvPgm.size = 0;

  clear noBndDir;
  noBndDir.size = 0;

  clear noBOption;
  noBOption.size = 0;

  clear noModule;
  noModule.size = 0;

  clear noDefine;
  noDefine.size = 0;

  clear noIncDir;
  noIncDir.size = 1;
  noIncDir.path(1) = '*NONE';

  liblList = getLibl();
  newLiblList = liblList;
  newLiblList.curLib = sds.pgmLib;
  restoreLibl(newLiblList);

  crtStmf(STMF_RPGLE);
  crtStmf(STMF_SQLRPGLE);
  crtStmf(STMF_SQLCBLLE);

end-proc;

dcl-proc tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dltStmf(STMF_RPGLE);
  dltStmf(STMF_SQLRPGLE);
  dltStmf(STMF_SQLCBLLE);

  restoreLibl(liblList);

end-proc;


dcl-proc testSrcFile export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES':
                                 noSrcStmf:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 noTgtCcsid:
                                 noCvtCcsid);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
  SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES)': crtRpgModCmd);

end-proc;


dcl-proc testSrcStmfRpgle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds incDir likeds(incDir_t) inz;

  clear incDir;
  incDir.size = 2;
  incDir.path(1) = '/home/dev/dir1';
  incDir.path(2) = '/home/dev/dir2';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_RPGLE:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 noTgtCcsid:
                                 noCvtCcsid);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_RPGLE + ''') +
          INCDIR(''/home/dev/dir1'' ''/home/dev/dir2'') ': crtRpgModCmd);

end-proc;


dcl-proc testSrcMbrRpgleIncDir export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds incDir likeds(incDir_t) inz;

  clear incDir;
  incDir.size = 1;
  incDir.path(1) = '/home/dev/dir1';

  // INCDIR is added for a source member too, because CRTRPGMOD
  // searches it for /COPY files in the IFS, that are not found
  // in the QSYS file system.
  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES':
                                 noSrcStmf:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 noTgtCcsid:
                                 noCvtCcsid);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) +
          INCDIR(''/home/dev/dir1'') ': crtRpgModCmd);

end-proc;


dcl-proc testSrcSrcStmfIncDirIgnored export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds incDir likeds(incDir_t) inz;

  clear incDir;
  incDir.size = 1;
  incDir.path(1) = '/home/dev/dir1';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 noSrcMbr:
                                 STMF_RPGLE:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 noTgtCcsid:
                                 noCvtCcsid);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_RPGLE + ''') +
          INCDIR(''/home/dev/dir1'') ': crtRpgModCmd);

end-proc;


dcl-proc testSrcStmfSqlrpgle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds incDir likeds(incDir_t) inz;

  clear incDir;
  incDir.size = 1;
  incDir.path(1) = '/home/dev/dir1';

  // Parameter TGTCCSID is added to COMPILEOPT, because
  // TGTCCSID is not specified in COMPILEOPT
  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -1:   // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(*JOB) +
          COMPILEOPT(''TGTCCSID(*JOB) INCDIR(''''/home/dev/dir1'''')'') ': crtRpgModCmd);

  // Parameter TGTCCSID is taken from COMPILEOPT, because
  // COMPILEOPT overrides it.
  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 'TGTCCSID(*SRC)':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -1:   // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(*JOB) +
          COMPILEOPT(''TGTCCSID(*SRC) INCDIR(''''/home/dev/dir1'''')'') ': crtRpgModCmd);

  // Parameter TGTCCSID is taken from source file.
  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 'TGTCCSID(*SRC)':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -2:   // -2 = *SRC
                                 273); // source file CCSID
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(273) +
          COMPILEOPT(''TGTCCSID(*SRC) INCDIR(''''/home/dev/dir1'''')'') ': crtRpgModCmd);

end-proc;


dcl-proc testSrcStmfSqlcblle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds incDir likeds(incDir_t) inz;

  clear incDir;
  incDir.size = 1;
  incDir.path(1) = '/home/dev/dir1';

  // Parameter TGTCCSID is added to COMPILEOPT, because
  // TGTCCSID is not specified in COMPILEOPT
  crtRpgModCmd = getCrtCblModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLCBLLE:
                                 noCOption:
                                 noDbgView:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -1:   // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLCBLI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLCBLLE + ''') +
          OBJTYPE(*MODULE) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(*JOB) +
          COMPILEOPT(''TGTCCSID(*JOB) INCDIR(''''/home/dev/dir1'''')'') ': crtRpgModCmd);

  // Parameter TGTCCSID is taken from COMPILEOPT, because
  // COMPILEOPT overrides it.
  crtRpgModCmd = getCrtCblModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLCBLLE:
                                 noCOption:
                                 noDbgView:
                                 noPOption:
                                 'TGTCCSID(*SRC)':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -1:   // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLCBLI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLCBLLE + ''') +
          OBJTYPE(*MODULE) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(*JOB) +
          COMPILEOPT(''TGTCCSID(*SRC) INCDIR(''''/home/dev/dir1'''')'') ': crtRpgModCmd);

  // Parameter TGTCCSID is taken from source file.
  crtRpgModCmd = getCrtCblModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLCBLLE:
                                 noCOption:
                                 noDbgView:
                                 noPOption:
                                 'TGTCCSID(*SRC)':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -2:   // -2 = *SRC
                                 273); // source file CCSID
  aEqual('CRTSQLCBLI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLCBLLE + ''') +
          OBJTYPE(*MODULE) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(273) +
          COMPILEOPT(''TGTCCSID(*SRC) INCDIR(''''/home/dev/dir1'''')'') ': crtRpgModCmd);

end-proc;


dcl-proc testSrcStmfSqlrpgleTwoIncDirs export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds incDir likeds(incDir_t) inz;

  clear incDir;
  incDir.size = 2;
  incDir.path(1) = '/home/dev/dir1';
  incDir.path(2) = '/home/dev/dir2';

  // INCDIR of CRTSQLRPGI accepts only one directory: it gets the
  // first one, the compiler gets all of them with COMPILEOPT.
  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -1:   // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(*JOB) +
          COMPILEOPT(''TGTCCSID(*JOB) +
          INCDIR(''''/home/dev/dir1'''' ''''/home/dev/dir2'''')'') ': crtRpgModCmd);

end-proc;


dcl-proc testSrcStmfSqlcblleTwoIncDirs export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds incDir likeds(incDir_t) inz;

  clear incDir;
  incDir.size = 2;
  incDir.path(1) = '/home/dev/dir1';
  incDir.path(2) = '/home/dev/dir2';

  // INCDIR of CRTSQLCBLI accepts only one directory: it gets the
  // first one, the compiler gets all of them with COMPILEOPT.
  crtCblModCmd = getCrtCblModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLCBLLE:
                                 noCOption:
                                 noDbgView:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -1:   // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLCBLI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLCBLLE + ''') +
          OBJTYPE(*MODULE) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(*JOB) +
          COMPILEOPT(''TGTCCSID(*JOB) +
          INCDIR(''''/home/dev/dir1'''' ''''/home/dev/dir2'''')'') ': crtCblModCmd);

end-proc;


//----------------------------------------------------------------------
// INCDIR of COMPILEOPT overrides INCDIR for the compiler. INCDIR
// is still passed to CRTSQLRPGI for SQL INCLUDE statements.
//----------------------------------------------------------------------
dcl-proc testSqlrpgleCompileOptIncDir export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds incDir likeds(incDir_t) inz;

  clear incDir;
  incDir.size = 1;
  incDir.path(1) = '/home/dev/dir1';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 'INCDIR(''/home/dev/dir3'')':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -1:   // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(*JOB) +
          COMPILEOPT(''INCDIR(''''/home/dev/dir3'''') TGTCCSID(*JOB)'') ': crtRpgModCmd);

end-proc;


//----------------------------------------------------------------------
// The same for CRTSQLCBLI.
//----------------------------------------------------------------------
dcl-proc testSqlcblleCompileOptIncDir export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds incDir likeds(incDir_t) inz;

  clear incDir;
  incDir.size = 1;
  incDir.path(1) = '/home/dev/dir1';

  crtCblModCmd = getCrtCblModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLCBLLE:
                                 noCOption:
                                 noDbgView:
                                 noPOption:
                                 'INCDIR(''/home/dev/dir3'')':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 incDir:
                                 -1:   // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLCBLI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLCBLLE + ''') +
          OBJTYPE(*MODULE) +
          INCDIR(''/home/dev/dir1'') +
          CVTCCSID(*JOB) +
          COMPILEOPT(''INCDIR(''''/home/dev/dir3'''') TGTCCSID(*JOB)'') ': crtCblModCmd);

end-proc;


//----------------------------------------------------------------------
// With INCDIR in COMPILEOPT, the directories 2-n of INCDIR would get
// lost, because CRTSQLRPGI accepts only one directory. RUCRTRPG must
// reject that.
//----------------------------------------------------------------------
dcl-proc testSqlrpgleIncDirConflict export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds msgInfo likeds(MsgInfo_t) inz;
  dcl-s isError ind inz(*off);

  // Run.

  monitor;
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM01) +
            SRCSTMF(''' + TEMP_DIR + STMF_SQLRPGLE + ''') +
            INCDIR(''/home/dev/dir1'' ''/home/dev/dir2'') +
            COMPILEOPT(''INCDIR(''''/home/dev/dir3'''')'')');
  on-error;
    isError = *on;
    msgInfo = getMonitoredMessage(*on);
  endmon;

  // Check.

  assert(isError: 'RUCRTRPG must reject several INCDIR with INCDIR in COMPILEOPT.');
  assert(%scan('Only one directory is allowed for INCDIR': msgInfo.txt) > 0
         : 'Unexpected message: ' + %trimr(msgInfo.txt));

end-proc;


//----------------------------------------------------------------------
// The same for CRTSQLCBLI.
//----------------------------------------------------------------------
dcl-proc testSqlcblleIncDirConflict export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds msgInfo likeds(MsgInfo_t) inz;
  dcl-s isError ind inz(*off);

  // Run.

  monitor;
    runCmd('RUCRTCBL TSTPGM(QTEMP/TESTPGM01) +
            SRCSTMF(''' + TEMP_DIR + STMF_SQLCBLLE + ''') +
            INCDIR(''/home/dev/dir1'' ''/home/dev/dir2'') +
            COMPILEOPT(''INCDIR(''''/home/dev/dir3'''')'')');
  on-error;
    isError = *on;
    msgInfo = getMonitoredMessage(*on);
  endmon;

  // Check.

  assert(isError: 'RUCRTCBL must reject several INCDIR with INCDIR in COMPILEOPT.');
  assert(%scan('Only one directory is allowed for INCDIR': msgInfo.txt) > 0
         : 'Unexpected message: ' + %trimr(msgInfo.txt));

end-proc;


dcl-proc testOneCompileOption export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds oneCOption likeds(Options_t);

  oneCOption.size = 1;
  oneCOption.option(1) = '*SRCSTMT';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES' :
                                 noSrcStmf:
                                 oneCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 noTgtCcsid:
                                 noCvtCcsid);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) +
          OPTION(*SRCSTMT)': crtRpgModCmd);

end-proc;


dcl-proc testTwoCompileOptions export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds twoCOptions likeds(Options_t);


  twoCOptions.size = 2;
  twoCOptions.option(1) = '*SRCSTMT';
  twoCOptions.option(2) = '*NODEBUGIO';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES':
                                 noSrcStmf:
                                 twoCOptions:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 noTgtCcsid:
                                 noCvtCcsid);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) +
          OPTION(*SRCSTMT *NODEBUGIO)': crtRpgModCmd);

end-proc;


dcl-proc testDbgView export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES':
                                 noSrcStmf:
                                 noCOption:
                                 '*LIST':
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 noTgtCcsid:
                                 noCvtCcsid);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) +
          DBGVIEW(*LIST)': crtRpgModCmd);

end-proc;

dcl-proc testModTargetRls export;
  dcl-pi *n extproc(*dclcase);
  end-pi;


  // Use members stored in library QSYSINC for testing
  // purposes. Members SYSTYPES and SQLUDF must exist
  // as we need to retrieve their source types.

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 'QRPGLESRC QSYSINC   ':
                                 'SYSTYPES':
                                 noSrcStmf:
                                 noCOption:
                                 '*LIST':
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 '*CURRENT':
                                 noDefine:
                                 noIncDir:
                                 -2:  // -2 = *SRC
                                 273);
  aEqual('CRTRPGMOD MODULE(*CURLIB/SYSTYPES) +
          SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) +
          DBGVIEW(*LIST) TGTRLS(*CURRENT) TGTCCSID(*SRC)': crtRpgModCmd);

  crtCblModCmd = getCrtCblModCmd('SQLUDF    *CURLIB   ':
                                 'QCBLLESRC QSYSINC   ':
                                 'SQLUDF':
                                 noSrcStmf:
                                 noCOption:
                                 '*LIST':
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 '*CURRENT':
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTCBLMOD MODULE(*PGMID) +
          SRCFILE(QSYSINC/QCBLLESRC) SRCMBR(SQLUDF) +
          DBGVIEW(*LIST) TGTRLS(*CURRENT) TGTCCSID(*JOB)': crtCblModCmd);

end-proc;

//----------------------------------------------------------------------
// CRTCBLMOD creates the module in the library of the test suite, not
// in the current library.
//----------------------------------------------------------------------
dcl-proc testCblModuleInTstPgmLib export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  crtCblModCmd = getCrtCblModCmd('SQLUDF    QTEMP     ':
                                 'QCBLLESRC QSYSINC   ':
                                 'SQLUDF':
                                 noSrcStmf:
                                 noCOption:
                                 '*LIST':
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 '*CURRENT':
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTCBLMOD MODULE(QTEMP/*PGMID) +
          SRCFILE(QSYSINC/QCBLLESRC) SRCMBR(SQLUDF) +
          DBGVIEW(*LIST) TGTRLS(*CURRENT) TGTCCSID(*JOB)': crtCblModCmd);

end-proc;

dcl-proc testOneBndSrvPgm export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Binding one Service Program.
  dcl-ds oneBndSrvPgm likeds(ObjectArray_t);


  // Setup.

  oneBndSrvPgm.size = 1;
  oneBndSrvPgm.object(1).nm = 'SRVPGM_NM';
  oneBndSrvPgm.object(1).lib = 'SRVPGM_LIB';

  // Execution.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 oneBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noLinkerParams:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          BNDSRVPGM((SRVPGM_LIB/SRVPGM_NM)) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testTwoBndSrvPgm export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Binding two Service Programs.
  dcl-ds twoBndSrvPgm likeds(ObjectArray_t);


  // Setup.

  twoBndSrvPgm.size = 2;
  twoBndSrvPgm.object(1).nm = 'SRVPGM_NM';
  twoBndSrvPgm.object(1).lib = 'SRVPGM_LIB';
  twoBndSrvPgm.object(2).nm = 'SRVPGM_NM2';
  twoBndSrvPgm.object(2).lib = 'SRVPGM_LB2';

  // Execution.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 twoBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noLinkerParams:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          BNDSRVPGM((SRVPGM_LIB/SRVPGM_NM) (SRVPGM_LB2/SRVPGM_NM2)) +
          DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testOneBndDir export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // One binding directory.
  dcl-ds oneBndDir likeds(ObjectArray_t);


  // Setup.

  oneBndDir.size = 1;
  oneBndDir.object(1).nm = 'BNDDIR_NM';
  oneBndDir.object(1).lib = 'BNDDIR_LIB';

  // Execution.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 oneBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noLinkerParams:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          BNDDIR(BNDDIR_LIB/BNDDIR_NM) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testBndDirWithoutLibrary export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // One binding directory.
  dcl-ds oneBndDir likeds(ObjectArray_t);


  // Setup.

  oneBndDir.size = 1;
  oneBndDir.object(1).nm = 'BNDDIR_NM';
  oneBndDir.object(1).lib = *blank;

  // Execution.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 oneBndDir:
                                 noModule:
                                 noBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noLinkerParams:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          BNDDIR(BNDDIR_NM) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testOneBindingOption export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // One Binding Option.
  dcl-ds oneBOption likeds(Options_t);


  // Setup.

  oneBOption.size = 1;
  oneBOption.option(1) = '*DUPPROC';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
                                 noBndSrvPgm:
                                 noBndDir:
                                 noModule:
                                 oneBOption:
                                 noExport:
                                 noActGrp:
                                 noText:
                                 noLinkerParams:
                                 noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          OPTION(*DUPPROC) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testExport export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Export option.
  dcl-s export char(10);


  // Setup.

  export = '*ALL';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
  noBndSrvPgm:
  noBndDir:
  noModule:
  noBOption:
  export:
  noActGrp:
  noText:
  noLinkerParams:
  noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          EXPORT(*ALL) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testActGrp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Export option.
  dcl-s actGrp char(10);


  // Setup.

  actGrp = 'QTEST';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
  noBndSrvPgm:
  noBndDir:
  noModule:
  noBOption:
  noExport:
  actGrp:
  noText:
  noLinkerParams:
  noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          ACTGRP(QTEST) DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;

dcl-proc testTargetRls export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Export option.
  dcl-s targetRls like(TargetRelease_t);


  // Setup.

  targetRls = '*CURRENT';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
  noBndSrvPgm:
  noBndDir:
  noModule:
  noBOption:
  noExport:
  noActGrp:
  noText:
  noLinkerParams:
  targetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          DETAIL(''*BASIC'') TGTRLS(*CURRENT)': crtSrvPgmCmd);

end-proc;

dcl-proc testText export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Export option.
  dcl-s text char(50);


  // Setup.

  text = 'Object ''description'' text';

  // Execute.

  crtSrvPgmCmd = getCrtSrvPgmCmd('PGM_NAME  *CURLIB   ':
  noBndSrvPgm:
  noBndDir:
  noModule:
  noBOption:
  noExport:
  noActGrp:
  text:
  noLinkerParams:
  noTargetRls);

  // Control.

  aEqual('CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) +
          TEXT(''Object ''''description'''' text'') DETAIL(''*BASIC'')': crtSrvPgmCmd);

end-proc;


dcl-proc testSerializeObjectNameWithLibrary export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // An object name.
  dcl-ds object likeds(Object_t);

  // Setup.

  object.nm = 'OBJNAME';
  object.lib = 'OBJLIB';

  // Execute and control.

  aEqual('OBJLIB/OBJNAME': serializeObjectName(object));

end-proc;


dcl-proc testSerializeObjectNameWithoutLibrary export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // An object name.
  dcl-ds object likeds(Object_t);

  // Setup.

  object.nm = 'OBJNAME';
  object.lib = *blank;

  // Execute and control.

  aEqual('OBJNAME': serializeObjectName(object));

end-proc;


dcl-proc testCOptionSqlRpgle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds oneCOption likeds(Options_t);

  oneCOption.size = 1;
  oneCOption.option(1) = '*SRCSTMT';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 oneCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''TGTCCSID(*JOB) OPTION(*SRCSTMT)'') ': crtRpgModCmd);

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 oneCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 'DBGVIEW(*LIST)':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''DBGVIEW(*LIST) TGTCCSID(*JOB) OPTION(*SRCSTMT)'') ': crtRpgModCmd);

end-proc;


dcl-proc testCOptionSqlCblle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds oneCOption likeds(Options_t);

  oneCOption.size = 1;
  oneCOption.option(1) = '*NOMONOPRC';

  crtCblModCmd = getCrtCblModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLCBLLE:
                                 oneCOption:
                                 noDbgView:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLCBLI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLCBLLE + ''') +
          OBJTYPE(*MODULE) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''TGTCCSID(*JOB) OPTION(*NOMONOPRC)'') ': crtCblModCmd);

  crtCblModCmd = getCrtCblModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLCBLLE:
                                 oneCOption:
                                 noDbgView:
                                 noPOption:
                                 'DBGVIEW(*LIST)':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLCBLI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLCBLLE + ''') +
          OBJTYPE(*MODULE) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''DBGVIEW(*LIST) TGTCCSID(*JOB) OPTION(*NOMONOPRC)'') ': crtCblModCmd);

end-proc;


//----------------------------------------------------------------------
// OPTION() of COMPILEOPT overrides COPTION, like DEFINE(), TGTCCSID()
// and INCDIR() do.
//----------------------------------------------------------------------
dcl-proc testOptionInCompileOptSqlRpgle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds oneCOption likeds(Options_t);

  oneCOption.size = 1;
  oneCOption.option(1) = '*SRCSTMT';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 oneCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 'OPTION(*NOUNREF)':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''OPTION(*NOUNREF) TGTCCSID(*JOB)'') ': crtRpgModCmd);

end-proc;


dcl-proc testOptionInCompileOptSqlCblle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds oneCOption likeds(Options_t);

  oneCOption.size = 1;
  oneCOption.option(1) = '*NOMONOPRC';

  crtCblModCmd = getCrtCblModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLCBLLE:
                                 oneCOption:
                                 noDbgView:
                                 noPOption:
                                 'OPTION(*NOSTDTRUNC)':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLCBLI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLCBLLE + ''') +
          OBJTYPE(*MODULE) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''OPTION(*NOSTDTRUNC) TGTCCSID(*JOB)'') ': crtCblModCmd);

end-proc;


//----------------------------------------------------------------------
// DEFINE() of COMPILEOPT overrides DEFINE.
//----------------------------------------------------------------------
dcl-proc testDefineInCompileOptSqlRpgle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds oneDefine likeds(defines_t) inz;

  oneDefine.size = 1;
  oneDefine.define(1) = 'FROM_PARM';

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 'DEFINE(FROM_OPT)':
                                 noCompilerParams:
                                 noTargetRls:
                                 oneDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''DEFINE(FROM_OPT) TGTCCSID(*JOB)'') ': crtRpgModCmd);

end-proc;


dcl-proc testDefineInCompileOptSqlCblle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds oneDefine likeds(defines_t) inz;

  oneDefine.size = 1;
  oneDefine.define(1) = 'FROM_PARM';

  crtCblModCmd = getCrtCblModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLCBLLE:
                                 noCOption:
                                 noDbgView:
                                 noPOption:
                                 'DEFINE(FROM_OPT)':
                                 noCompilerParams:
                                 noTargetRls:
                                 oneDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLCBLI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLCBLLE + ''') +
          OBJTYPE(*MODULE) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''DEFINE(FROM_OPT) TGTCCSID(*JOB)'') ': crtCblModCmd);

end-proc;


//----------------------------------------------------------------------
// The parameters of COMPILEOPT are recognized in lower case too.
//----------------------------------------------------------------------
dcl-proc testLowerCaseCompileOptSqlRpgle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 noCOption:
                                 noDbgView:
                                 rpgPpOptLvl2:
                                 noPOption:
                                 'tgtccsid(*src)':
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''tgtccsid(*src)'') ': crtRpgModCmd);

end-proc;


//----------------------------------------------------------------------
// COPTION(*EVENTF) does not work with SRCMBR(*TSTPGM) in RDi and
// must be rejected.
//----------------------------------------------------------------------
dcl-proc testEventfWithSrcMbrTstPgm export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds msgInfo likeds(MsgInfo_t) inz;
  dcl-s isError ind inz(*off);

  // Run.

  monitor;
    runCmd('RUCRTRPG TSTPGM(QTEMP/TESTPGM01) SRCFILE(QTESTCASES) +
            SRCMBR(*TSTPGM) COPTION(*EVENTF) DLTSPLF(*YES)');
  on-error;
    isError = *on;
    msgInfo = getMonitoredMessage(*on);
  endmon;

  // Check.

  assert(isError: 'RUCRTRPG must reject COPTION(*EVENTF) with SRCMBR(*TSTPGM).');
  assert(%scan('Compile option *EVENTF is not allowed': msgInfo.txt) > 0
         : 'Unexpected message: ' + %trimr(msgInfo.txt));

end-proc;


dcl-proc testDbgViewSqlRpgle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  crtRpgModCmd = getCrtRpgModCmd('SYSTYPES  *CURLIB   ':
                                 noSrcFile:
                                 noSrcMbr:
                                 STMF_SQLRPGLE:
                                 noCOption:
                                 '*LIST':
                                 rpgPpOptLvl2:
                                 noPOption:
                                 noCompileOpt:
                                 noCompilerParams:
                                 noTargetRls:
                                 noDefine:
                                 noIncDir:
                                 -1:  // -1 = *JOB
                                 noCvtCcsid);
  aEqual('CRTSQLRPGI OBJ(*CURLIB/SYSTYPES) +
          SRCSTMF(''' + STMF_SQLRPGLE + ''') +
          OBJTYPE(*MODULE) RPGPPOPT(*LVL2) +
          DBGVIEW(*LIST) +
          CVTCCSID(*JOB) +
          COMPILEOPT(''TGTCCSID(*JOB)'') ': crtRpgModCmd);

end-proc;


//----------------------------------------------------------------------
// A module that cannot be deleted does not keep the other modules.
//----------------------------------------------------------------------
dcl-proc testDltModAfterDltModError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testPgm likeds(object_t);
  dcl-ds modules likeds(objectArray_t);

  // Setup.

  clear testPgm;
  clear modules;
  modules.size = 2;
  modules.object(1).nm = 'RUNOTEXIST';
  modules.object(1).lib = 'QTEMP';
  modules.object(2).nm = 'RUDLTMOD';
  modules.object(2).lib = 'QTEMP';

  system('DLTMOD MODULE(QTEMP/RUDLTMOD)');
  system('CRTDUPOBJ OBJ(CRTTST) FROMLIB(*LIBL) OBJTYPE(*MODULE) +
          TOLIB(QTEMP) NEWOBJ(RUDLTMOD)');
  assert(Object_exists(modules.object(2): '*MODULE')
         : 'Module QTEMP/RUDLTMOD has not been created.');

  // Run.

  monitor;
    deleteModulesAndSpooledFiles(*off: *on: %timestamp(): testPgm: modules);
  on-error;
    // Checked below: the second module must be deleted anyway.
  endmon;

  // Check.

  assert(not Object_exists(modules.object(2): '*MODULE')
         : 'Module QTEMP/RUDLTMOD has not been deleted.');

end-proc;


dcl-proc crtStmf export;
  dcl-pi *n extproc(*dclcase);
    stmf like(ifsStmf_t) value;
  end-pi;

  dcl-s fd int(10);
  dcl-s errorNbr int(10) based(pErrorNbr);
  dcl-s errorText char(256);

  monitor;
    stmf = TEMP_DIR + stmf;
    fd = open(stmf: O_EXCL + O_CREAT + O_RDWR + O_SHARE_NONE + O_CCSID
              : S_IRUSR + S_IWUSR + S_IRGRP + S_IROTH: 819);
    if (fd <> -1);
      callp close(fd);
    else;
      pErrorNbr = errno();
      errorText = %str(strerror(errorNbr));
    endif;
  on-error;
  endmon;

end-proc;


dcl-proc dltStmf export;
  dcl-pi *n extproc(*dclcase);
    stmf like(ifsStmf_t) value;
  end-pi;

  dcl-s rc int(10);
  dcl-s errorNbr int(10) based(pErrorNbr);
  dcl-s errorText char(256);

  monitor;
    stmf = TEMP_DIR + stmf;
    rc = unlink(stmf);
    if (rc = -1);
      pErrorNbr = errno();
      errorText = %str(strerror(errorNbr));
    endif;
  on-error;
  endmon;

end-proc;
