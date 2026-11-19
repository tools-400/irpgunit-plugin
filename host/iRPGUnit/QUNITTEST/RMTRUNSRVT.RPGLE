**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test RMTRUNSRV.
// ==========================================================================
//  Copyright (c) 2026 iRPGUnit Project Team
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

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,CALLSTACK
/copy qinclude,CMDRUNSRV
/copy qinclude,MEMMGR
/copy qinclude,RMTRUNSRV
/copy qinclude,TYPES_H
/copy qinclude,USRSPC
/copy qllist,llist_h

//----------------------------------------------------------------------
//   Type Templates
//----------------------------------------------------------------------

// Layout of the user space, version 6, as written by RMTRUNSRV and
// read by RPGUnitTestRunner.retrieveTestCasesV6() of the plug-in.

dcl-ds header_t len(256) qualified template;
  length            int(10);
  version           int(10);
  testSuite         likeds(object_t);
  numRuns           int(10);
  numAsserts        int(10);
  numFailures       int(10);
  numErrors         int(10);
  offsFirstTestCase int(10);
  numTestCases      int(10);
  system            char(10);
  splf_name         char(10);
  splf_nbr          int(10);
  job_name          char(10);
  job_user          char(10);
  job_nbr           char(6);
  qSrcMbr           likeds(srcMbr_t);
  numTestCasesRtn   int(10);
end-ds;

dcl-ds testCase_t len(38) qualified template;
  offsNextEntry          int(10);
  seqNbr                 int(10);
  lenEntry               int(5);
  outcome                char(1);
  reserved_1             char(1);
  numAsserts             int(10);
  execTimeMSecs          int(20);
  offsTestCaseText       int(10);
  lenTestCaseText        int(5);
  numTestCaseEvents      int(10);
  offsFirstTestCaseEvent int(10);
end-ds;

dcl-ds testCaseEvent_t len(46) qualified template;
  outcome          char(1);
  reserved_2       char(1);
  lenEntry         int(5);
  offsNextEntry    int(10);
  offsAssertProcNm int(10);
  lenAssertProcNm  int(5);
  offsExcpMsg      int(10);
  lenExcpMsg       int(5);
  offsSndInf       int(10);
  lenSndInf        int(5);
  offsRcvInf       int(10);
  lenRcvInf        int(5);
  offsCallStkE     int(10);
  numCallStkE      int(5);
  offsExpected     int(10);
  offsActual       int(10);
end-ds;

dcl-ds sender_t len(58) qualified template;
  lenEntry         int(5);
  qPgm             likeds(object_t);
  qMod             likeds(object_t);
  specNb           char(10);
  offsProcNm       int(10);
  lenProcNm        int(5);
end-ds;

//----------------------------------------------------------------------
//   Global Constants
//----------------------------------------------------------------------

dcl-c SENDER_PROC_NAME 'senderProcedureWithAVeryLongName';
dcl-c RECEIVER_PROC_NAME 'receiverProcedureWithAVeryLongName';

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

dcl-ds g_usrSpc likeds(object_t) inz;
dcl-s g_pUsrSpc pointer;

// Test suite, test suite name and result passed to fillUserSpace().
dcl-ds g_testSuite likeds(testSuite_t) inz;
dcl-ds g_testSuiteName likeds(object_t) inz;
dcl-ds g_testSuiteResult likeds(testSuiteResult_t) inz;

// Test case result added to g_testSuite.
dcl-ds g_testCaseResult likeds(testCaseResult_t) inz;

//----------------------------------------------------------------------
//   Setup & Tear Down
//----------------------------------------------------------------------

dcl-proc setup export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  g_usrSpc.nm = 'RMTRUNSRVT';
  g_usrSpc.lib = 'QTEMP';
  g_pUsrSpc = crtUsrSpc(g_usrSpc: 'iRPGUnit SelfTest - User Space of RMTRUNSRVT');

  clear g_testSuite;
  g_testSuite.testResults = MemMgr_createList('g_testSuite.testResults');

  g_testSuiteName.nm = 'RMTRUNSRVT';
  g_testSuiteName.lib = '*LIBL';

  clear g_testSuiteResult;
  clear g_testCaseResult;

end-proc;


dcl-proc teardown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  if (g_testCaseResult.hTestEvents <> *null);
    disposeTestResult(g_testCaseResult);
  endif;

  MemMgr_disposeList(g_testSuite.testResults: 'g_testSuite.testResults');

  monitor;
    runCmd('DLTUSRSPC USRSPC(' + %trim(g_usrSpc.lib) + '/' + %trim(g_usrSpc.nm) + ')');
  on-error;
    // Ignore errors
  endmon;

end-proc;

//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// The procedure names of sender and receiver of an error event are
// written completely, also if the message text is shorter.
//----------------------------------------------------------------------
dcl-proc test_errorEventProcedureNames export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds errorEvent likeds(runtimeErrorEvent_t) inz;

  dcl-ds testCaseEvent likeds(testCaseEvent_t) based(pTestCaseEvent);
  dcl-ds sender likeds(sender_t) based(pSender);
  dcl-ds receiver likeds(sender_t) based(pReceiver);

  // Setup.

  g_testCaseResult = initTestResult(TEST_CASE_ERROR: 'test_withError');

  clear errorEvent;
  errorEvent.outcome = TEST_CASE_ERROR;
  errorEvent.msg.id = 'CPF9898';
  errorEvent.msg.txt = 'X';
  errorEvent.msg.qSndStmt.procNm = SENDER_PROC_NAME;
  errorEvent.msg.qRcvStmt.procNm = RECEIVER_PROC_NAME;
  g_testCaseResult.lastErrorEvent =
    addErrorTestEvent(g_testCaseResult.hTestEvents: errorEvent);

  list_add(g_testSuite.testResults: %addr(g_testCaseResult): %size(g_testCaseResult));

  // Run.

  fillUserSpace(g_usrSpc: g_testSuite: g_testSuiteName: g_testSuiteResult: *on);

  // Check.

  pTestCaseEvent = getFirstTestCaseEvent(1);

  aEqual(TEST_CASE_ERROR: testCaseEvent.outcome);
  aEqual('X': getUsrSpcString(testCaseEvent.offsExcpMsg: testCaseEvent.lenExcpMsg));

  pSender = g_pUsrSpc + testCaseEvent.offsSndInf;
  aEqual(SENDER_PROC_NAME: getUsrSpcString(sender.offsProcNm: sender.lenProcNm));

  pReceiver = g_pUsrSpc + testCaseEvent.offsRcvInf;
  aEqual(RECEIVER_PROC_NAME: getUsrSpcString(receiver.offsProcNm: receiver.lenProcNm));

end-proc;


//----------------------------------------------------------------------
// All events of a test case are written, regardless of an earlier,
// aborted iteration of the event list (e.g. by writeTestReport()).
//----------------------------------------------------------------------
dcl-proc test_allEventsAfterAbortedIteration export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds successEvent likeds(testSuccessEvent_t) inz;
  dcl-ds testCase likeds(testCase_t) based(pTestCase);
  dcl-ds header likeds(header_t) based(pHeader);
  dcl-s pHeader pointer;
  dcl-s i int(10);

  // Setup: successful test case with 3 success events (no JUnit style).

  g_testCaseResult = initTestResult(TEST_CASE_SUCCESS: 'test_withSuccess');

  for i = 1 to 3;
    clear successEvent;
    successEvent.outcome = TEST_CASE_SUCCESS;
    successEvent.assertProc = 'aEqual';
    successEvent.logExpected.type = DT_STRING;
    successEvent.logExpected.value = 'a';
    successEvent.logExpected.length = 1;
    successEvent.logExpected.originalLength = 1;
    successEvent.logActual = successEvent.logExpected;
    successEvent.pCallstk = Callstack_alloc(0: 'successEvent.pCallstk');
    addSuccessTestEvent(g_testCaseResult.hTestEvents: successEvent);
  endfor;
  g_testCaseResult.assertCnt = 3;

  list_add(g_testSuite.testResults: %addr(g_testCaseResult): %size(g_testCaseResult));

  // Aborted iteration, as done by writeTestReport() for a successful
  // test case in non-JUnit style.
  list_resetIteration(g_testCaseResult.hTestEvents);
  list_getNext(g_testCaseResult.hTestEvents);
  list_getNext(g_testCaseResult.hTestEvents);

  // Run.

  fillUserSpace(g_usrSpc: g_testSuite: g_testSuiteName: g_testSuiteResult: *off);

  // Check.

  pHeader = g_pUsrSpc;
  iEqual(1: header.numTestCasesRtn);
  pTestCase = g_pUsrSpc + header.offsFirstTestCase;
  aEqual(TEST_CASE_SUCCESS: testCase.outcome);
  iEqual(3: testCase.numTestCaseEvents);

end-proc;

//----------------------------------------------------------------------
//   Helper Procedures
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Returns a pointer to the first event of the n-th test case.
//----------------------------------------------------------------------
dcl-proc getFirstTestCaseEvent;
  dcl-pi *n pointer extproc(*dclcase);
    testCaseNbr int(10) const;
  end-pi;

  dcl-ds header likeds(header_t) based(pHeader);
  dcl-s pHeader pointer;
  dcl-ds testCase likeds(testCase_t) based(pTestCase);
  dcl-s i int(10);

  pHeader = g_pUsrSpc;
  assert(header.numTestCasesRtn >= testCaseNbr: 'Test case not found in user space.');

  pTestCase = g_pUsrSpc + header.offsFirstTestCase;
  for i = 2 to testCaseNbr;
    pTestCase = g_pUsrSpc + testCase.offsNextEntry;
  endfor;

  assert(testCase.numTestCaseEvents > 0: 'Test case has no events.');

  return g_pUsrSpc + testCase.offsFirstTestCaseEvent;

end-proc;


//----------------------------------------------------------------------
// Returns a string of the user space.
//----------------------------------------------------------------------
dcl-proc getUsrSpcString;
  dcl-pi *n varchar(1024) extproc(*dclcase);
    offset int(10) const;
    length int(10) const;
  end-pi;

  dcl-s data char(1024) based(pData);

  if (offset <= 0 or length <= 0);
    return '';
  endif;

  pData = g_pUsrSpc + offset;

  return %subst(data: 1: length);

end-proc;
