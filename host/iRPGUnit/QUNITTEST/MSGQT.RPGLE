**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test Message Queue.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
//   >>CMD<<     CRTSRVPGM SRVPGM(&LI/&OB) MODULE(&LI/&OB) +
//                 EXPORT(*ALL) BNDDIR(&LI/IRPGUNIT);
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,PGMMSG
/copy qinclude,TESTUTILS
/copy qinclude,TYPES_H

//----------------------------------------------------------------------
//   Global Constants
//----------------------------------------------------------------------

dcl-c MSG_QUEUE_QNM 'QTEMP/MSGQT';
dcl-c MSG_QUEUE_NM 'MSGQT';
dcl-c MSG_QUEUE_LB 'QTEMP';

// Message file with a message, that has a defined help text
dcl-c MSG_FILE_QNM 'QTEMP/MSGQTF';
dcl-c MSG_FILE_API 'MSGQTF    QTEMP';
dcl-c MSG_WITH_HELP 'MSG0001';
dcl-c MSG_WITH_LONG_HELP 'MSG0002';
dcl-c LONG_HELP_END_MARKER 'END-OF-LONG-HELP';

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

dcl-s testStartTime timestamp;
dcl-s assertCntBefore int(10);
dcl-s assertCntAfter int(10);

//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  testStartTime = getFullTimeStamp();
  clear assertCntBefore;
  clear assertCntAfter;

  monitor;
     runCmd('DLTMSGQ MSGQ(' + MSG_QUEUE_QNM + ')');
  on-error;
     // Ignore errors
  endmon;

  runCmd('CRTMSGQ MSGQ(' + MSG_QUEUE_QNM + ') +
          TEXT(''IRPGUnit SelfTest - Tet Message Queue.'')');

end-proc;


dcl-proc tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  runCmd('DLTMSGQ MSGQ(' + MSG_QUEUE_QNM + ')');

  monitor;
     runCmd('DLTMSGF MSGF(' + MSG_FILE_QNM + ')');
  on-error;
     // Ignore errors, the message file exists for some tests only
  endmon;

end-proc;


dcl-proc testNoMsgInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);


  // Setup.

  assertCntBefore = getAssertCalled();

  // Run.

  monitor;
     assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
       *omit: 'MSGQUEUET*': *omit: testStartTime);
     fail('assertMessageQueueContains(...) should have raised a failure.');
  on-error;
     // Exception message, as expected.
     assertFailEvt = getAssertFailEvt();
     assertCntAfter = getAssertCalled();
  endmon;

  // Check.

  iEqual(assertCntBefore + 1 : assertCntAfter);
  aEqual('Message not found in message queue.': assertFailEvt.msg);

  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    '*EMPTY': *omit: *omit: testStartTime);

end-proc;


dcl-proc testMsgInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit' + '.1');
  assertCntBefore = getAssertCalled();

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit' + '.2');
  assertCntBefore = getAssertCalled();

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit' + '.3');
  assertCntBefore = getAssertCalled();

  // Run.

  // exact match
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: 'MSGQT - iRPGUnit.1': *omit: testStartTime);

  // any message starting with 'MSGQT'
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: 'MSGQT*': *omit: testStartTime);

  // any message starting containing 'iRPGUnit'
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: '*iRPGUnit*': *omit: testStartTime);

  // message ending with '.2'
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: '*.2': *omit: testStartTime);

  // Check.

  assertCntAfter = getAssertCalled();
  iEqual(assertCntBefore + 4: assertCntAfter);

end-proc;


dcl-proc testMsgTooOldInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);

  // Setup.

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit - too old');

  // Ensure message is in queue
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: 'MSGQT - iRPGUnit - too old': *omit: testStartTime);

  // Set new start time
  testStartTime = getFullTimeStamp();

  // Add a valid message
  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - iRPGUnit - new');

  assertCntBefore = getAssertCalled();

  // Run.

  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: 'MSGQT - iRPGUnit - new': *omit: testStartTime);

  monitor;
     assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
       *omit: 'MSGQT - iRPGUnit - too old': *omit: testStartTime);
     fail('testMsgTooOldInMessageQueue(..) should have raised a failure.');
  on-error;
     // Exception message, as expected.
     assertFailEvt = getAssertFailEvt();
     assertCntAfter = getAssertCalled();
  endmon;

  // Check.

  iEqual(assertCntBefore + 2: assertCntAfter);
  aEqual('Message not found in message queue.': assertFailEvt.msg );

end-proc;


dcl-proc testSpecialValueEmpty export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);
  dcl-ds msgInfo likeds(MsgInfo_t);

  // Setup.

  assertCntBefore = getAssertCalled();
  setLowMessageKey(getHighestMsgKey());

  // Run.

  monitor;
     assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
       '*EMPTY': 'MSGQUEUET*': *omit: testStartTime);
     fail('Other parameters must be omitted when msgId = *EMPTY');
  on-error;
     // Exception message, as expected.
     assertFailEvt = getAssertFailEvt();
     assertCntAfter = getAssertCalled();
     msgInfo = getMonitoredMessage();
  endmon;

  // Check.

  iEqual(assertCntBefore: assertCntAfter);
  aEqual('' : assertFailEvt.msg);
  aEqual('All other selection parameters must be omitted, when msgId is set to ''*EMPTY'''
         : msgInfo.txt);

  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    '*EMPTY': *omit: *omit: testStartTime);

end-proc;


dcl-proc testMsgIdNotInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);

  // Setup.

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - message without ID');
  assertCntBefore = getAssertCalled();

  // Run.

  monitor;
     assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
       'CPF9897': *omit: *omit: testStartTime);
     fail('assertMessageQueueContains(...) should have raised a failure.');
  on-error;
     // Exception message, as expected.
     assertFailEvt = getAssertFailEvt();
     assertCntAfter = getAssertCalled();
  endmon;

  // Check.

  iEqual(assertCntBefore + 1 : assertCntAfter);
  aEqual('Message not found in message queue.': assertFailEvt.msg);

end-proc;


dcl-proc testMsgIdInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  sndQueueMsgWithId(MSG_QUEUE_NM: MSG_QUEUE_LB: 'CPF9897': 'MSGQT - message with ID');
  assertCntBefore = getAssertCalled();

  // Run.

  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    'CPF9897': *omit: *omit: testStartTime);

  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    'CPF9897': 'MSGQT - message with ID': *omit: testStartTime);

  // Check.

  assertCntAfter = getAssertCalled();
  iEqual(assertCntBefore + 2: assertCntAfter);

end-proc;


dcl-proc testMsgIdAndTextOfOlderMessage export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  sndQueueMsgWithId(MSG_QUEUE_NM: MSG_QUEUE_LB: 'CPF9897': 'MSGQT - older message with ID');
  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - newer message without ID');

  // Run.

  // The older message matches both criteria, the newer message none.
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    'CPF9897': 'MSGQT - older message with ID': *omit: testStartTime);

end-proc;


dcl-proc testMsgIdAndTextInDiffMessages export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);

  // Setup.

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - older message without ID');
  sndQueueMsgWithId(MSG_QUEUE_NM: MSG_QUEUE_LB: 'CPF9897': 'MSGQT - newer message with ID');

  // Run.

  // Each message matches one criterion only.
  monitor;
     assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
       'CPF9897': 'MSGQT - older message without ID': *omit: testStartTime);
     fail('assertMessageQueueContains(...) should have raised a failure.');
  on-error;
     // Exception message, as expected.
     assertFailEvt = getAssertFailEvt();
  endmon;

  // Check.

  aEqual('Message not found in message queue.': assertFailEvt.msg);

end-proc;


dcl-proc testEmptyWithNewMessage export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);

  // Setup.

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - message sent since start time');

  // Run.

  monitor;
     assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
       '*EMPTY': *omit: *omit: testStartTime);
     fail('assertMessageQueueContains(...) should have raised a failure.');
  on-error;
     // Exception message, as expected.
     assertFailEvt = getAssertFailEvt();
  endmon;

  // Check.

  aEqual('Message queue is not empty.': assertFailEvt.msg);

end-proc;


dcl-proc testEmptyWithOldMessage export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - message sent before start time');

  // Set new start time
  testStartTime = getFullTimeStamp();

  // Run.

  // No message has been sent since the new start time.
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    '*EMPTY': *omit: *omit: testStartTime);

end-proc;


dcl-proc testMsgHelpInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  crtMsgFileWithHelp();
  sndQueueMsgWithId(MSG_QUEUE_NM: MSG_QUEUE_LB: MSG_WITH_HELP: '': MSG_FILE_API);
  assertCntBefore = getAssertCalled();

  // Run.

  // exact match of the help text
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: *omit: 'MSGQT - help text of the message': testStartTime);

  // any help text containing 'help text'
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: *omit: '*help text*': testStartTime);

  // message ID and help text
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    MSG_WITH_HELP: *omit: '*help text*': testStartTime);

  // Check.

  assertCntAfter = getAssertCalled();
  iEqual(assertCntBefore + 3: assertCntAfter);

end-proc;


dcl-proc testLongMsgHelp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  crtMsgFileWithHelp();
  sndQueueMsgWithId(MSG_QUEUE_NM: MSG_QUEUE_LB: MSG_WITH_LONG_HELP: '': MSG_FILE_API);

  // Run.

  // The end marker is at the end of a help text of 2876 characters.
  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: *omit: '*' + LONG_HELP_END_MARKER + '*': testStartTime);

end-proc;


dcl-proc testManyMessagesInMessageQueue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s i int(10);

  // Setup.

  // More messages than fit into the receiver of the list API.
  sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - oldest message');
  for i = 1 to 299;
    sndQueueMsg(MSG_QUEUE_NM: MSG_QUEUE_LB: 'MSGQT - newer message ' + %char(i));
  endfor;

  // Run.

  assertMessageQueueContains(MSG_QUEUE_NM: MSG_QUEUE_LB:
    *omit: 'MSGQT - oldest message': *omit: testStartTime);

end-proc;


//----------------------------------------------------------------------
//   Private Helper Procedures
//----------------------------------------------------------------------

dcl-proc crtMsgFileWithHelp;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s longHelp varchar(3000);
  dcl-s i int(10);

  monitor;
     runCmd('DLTMSGF MSGF(' + MSG_FILE_QNM + ')');
  on-error;
     // Ignore errors
  endmon;

  runCmd('CRTMSGF MSGF(' + MSG_FILE_QNM + ') +
          TEXT(''iRPGUnit SelfTest - Test Message File.'')');

  runCmd('ADDMSGD MSGID(' + MSG_WITH_HELP + ') MSGF(' + MSG_FILE_QNM + ') +
          MSG(''MSGQT - message with help'') +
          SECLVL(''MSGQT - help text of the message'')');

  // Help text of 2876 characters (SECLVL allows 3000)
  longHelp = '';
  for i = 1 to 130;
    longHelp += 'MSGQT long help text. ';
  endfor;
  longHelp += LONG_HELP_END_MARKER;

  runCmd('ADDMSGD MSGID(' + MSG_WITH_LONG_HELP + ') MSGF(' + MSG_FILE_QNM + ') +
          MSG(''MSGQT - message with long help'') +
          SECLVL(''' + longHelp + ''')');

end-proc;


dcl-proc sndQueueMsgWithId;
  dcl-pi *n extproc(*dclcase);
    queueNm   char(10) const;
    queueLb   char(10) const;
    msgId     char(7) const;
    msgData   varchar(256) const;
    qMsgF     char(20) options(*nopass) const;
  end-pi;

  // Send Nonprogram Message (SNDPGMMSG cannot be run by QCMDEXC)
  dcl-pr qmhsndm extpgm('QMHSNDM');
    msgId      char(7) const;
    qMsgF      char(20) const;
    msgData    char(256) const options(*varsize);
    lenMsgData int(10) const;
    msgType    char(10) const;
    qMsgQ      char(20) const;
    numMsgQ    int(10) const;
    qRpyMsgQ   char(20) const;
    msgKey     char(4);
    errorCode  char(8);
  end-pr;

  dcl-s msgKey char(4);
  dcl-s msgFile char(20) inz('QCPFMSG   *LIBL');
  dcl-ds errCode qualified;
    bytPrv int(10) inz(0);
    bytAvl int(10) inz(0);
  end-ds;

  if (%parms() >= %parmnum(qMsgF));
    msgFile = qMsgF;
  endif;

  qmhsndm(msgId: msgFile: msgData: %len(msgData): '*INFO'
          : queueNm + queueLb: 1: '': msgKey: errCode);

end-proc;


dcl-proc sndQueueMsg;
  dcl-pi *n extproc(*dclcase);
    queueNm   char(10) const;
    queueLb   char(10) const;
    text      varchar(256) const;
  end-pi;

  dcl-s cmd varchar(1024);

  cmd = 'SNDMSG MSG(''' + %trim(text) + ''') +
           TOMSGQ(' + %trim(queueLb) + '/' + %trim(queueNm) + ') +
           MSGTYPE(*INFO)';

  runCmd(cmd);

end-proc;
