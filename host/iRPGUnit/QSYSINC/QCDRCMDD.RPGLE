**free
/if not defined(QCDRCMDD)
/define QCDRCMDD

// Retrieve Command Definition (QCDRCMDD) API
dcl-pr QCDRCMDD extpgm('QCDRCMDD');
  i_qCmd        char(20) const;
  i_destInf     char(65535) const options(*varsize);
  i_destFmt     char(8) const;
  o_rcvVar      char(65535) options(*varsize);
  i_rcvFmt      char(8) const;
  io_errCode    char(65535) options(*varsize);
end-pr;

// Destination information: receiver variable
dcl-ds dest0100_t qualified template;
  lenRcvVar       int(10);
end-ds;

// Command definition. The CDML source follows the header and is
// encoded in UTF-8 (CCSID 1208). 'Bytes returned' does not include
// the header.
dcl-ds cmdd0100_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
end-ds;

/endif
