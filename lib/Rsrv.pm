package Rsrv;

no warnings qw(redefine misc);

eval 'sub __RSRV_H__ () {1;}' unless defined(&__RSRV_H__);
eval 'sub RSRV_VER () {0x606;}' unless defined(&RSRV_VER);
eval 'sub default_Rsrv_port () {6311;}' unless defined(&default_Rsrv_port);
eval 'sub PAR_TYPE {
	my($X) = @_;
	eval q((($X) & 255));
}' unless defined(&PAR_TYPE);
eval 'sub PAR_LEN {
	my($X) = @_;
	eval q(((($X)) >> 8));
}' unless defined(&PAR_LEN);
eval 'sub PAR_LENGTH () { &PAR_LEN;}' unless defined(&PAR_LENGTH);
eval 'sub SET_PAR {
	my($TY,$LEN) = @_;
	eval q(((( ($LEN) & 0xffffff) << 8) | (($TY) & 255)));
}' unless defined(&SET_PAR);
eval 'sub CMD_STAT {
	my($X) = @_;
	eval q(((($X) >> 24)&127));
}' unless defined(&CMD_STAT);
eval 'sub SET_STAT {
	my($X,$s) = @_;
	eval q((($X) | ((($s) & 127) << 24)));
}' unless defined(&SET_STAT);
eval 'sub CMD_RESP () {0x10000;}' unless defined(&CMD_RESP);
eval 'sub RESP_OK () {( &CMD_RESP|0x1);}' unless defined(&RESP_OK);
eval 'sub RESP_ERR () {( &CMD_RESP|0x2);}' unless defined(&RESP_ERR);
eval 'sub ERR_auth_failed () {0x41;}' unless defined(&ERR_auth_failed);
eval 'sub ERR_conn_broken () {0x42;}' unless defined(&ERR_conn_broken);
eval 'sub ERR_inv_cmd () {0x43;}' unless defined(&ERR_inv_cmd);
eval 'sub ERR_inv_par () {0x44;}' unless defined(&ERR_inv_par);
eval 'sub ERR_Rerror () {0x45;}' unless defined(&ERR_Rerror);
eval 'sub ERR_IOerror () {0x46;}' unless defined(&ERR_IOerror);
eval 'sub ERR_notOpen () {0x47;}' unless defined(&ERR_notOpen);
eval 'sub ERR_accessDenied () {0x48;}' unless defined(&ERR_accessDenied);
eval 'sub ERR_unsupportedCmd () {0x49;}' unless defined(&ERR_unsupportedCmd);
eval 'sub ERR_unknownCmd () {0x4a;}' unless defined(&ERR_unknownCmd);
eval 'sub ERR_data_overflow () {0x4b;}' unless defined(&ERR_data_overflow);
eval 'sub ERR_object_too_big () {0x4c;}' unless defined(&ERR_object_too_big);
eval 'sub ERR_out_of_mem () {0x4d;}' unless defined(&ERR_out_of_mem);
eval 'sub ERR_ctrl_closed () {0x4e;}' unless defined(&ERR_ctrl_closed);
eval 'sub ERR_session_busy () {0x50;}' unless defined(&ERR_session_busy);
eval 'sub ERR_detach_failed () {0x51;}' unless defined(&ERR_detach_failed);
eval 'sub CMD_login () {0x1;}' unless defined(&CMD_login);
eval 'sub CMD_voidEval () {0x2;}' unless defined(&CMD_voidEval);
eval 'sub CMD_eval () {0x3;}' unless defined(&CMD_eval);
eval 'sub CMD_shutdown () {0x4;}' unless defined(&CMD_shutdown);
eval 'sub CMD_openFile () {0x10;}' unless defined(&CMD_openFile);
eval 'sub CMD_createFile () {0x11;}' unless defined(&CMD_createFile);
eval 'sub CMD_closeFile () {0x12;}' unless defined(&CMD_closeFile);
eval 'sub CMD_readFile () {0x13;}' unless defined(&CMD_readFile);
eval 'sub CMD_writeFile () {0x14;}' unless defined(&CMD_writeFile);
eval 'sub CMD_removeFile () {0x15;}' unless defined(&CMD_removeFile);
eval 'sub CMD_setSEXP () {0x20;}' unless defined(&CMD_setSEXP);
eval 'sub CMD_assignSEXP () {0x21;}' unless defined(&CMD_assignSEXP);
eval 'sub CMD_detachSession () {0x30;}' unless defined(&CMD_detachSession);
eval 'sub CMD_detachedVoidEval () {0x31;}' unless defined(&CMD_detachedVoidEval);
eval 'sub CMD_attachSession () {0x32;}' unless defined(&CMD_attachSession);
eval 'sub CMD_ctrl () {0x40;}' unless defined(&CMD_ctrl);
eval 'sub CMD_ctrlEval () {0x42;}' unless defined(&CMD_ctrlEval);
eval 'sub CMD_ctrlSource () {0x45;}' unless defined(&CMD_ctrlSource);
eval 'sub CMD_ctrlShutdown () {0x44;}' unless defined(&CMD_ctrlShutdown);
eval 'sub CMD_setBufferSize () {0x81;}' unless defined(&CMD_setBufferSize);
eval 'sub CMD_setEncoding () {0x82;}' unless defined(&CMD_setEncoding);
eval 'sub CMD_SPECIAL_MASK () {0xf0;}' unless defined(&CMD_SPECIAL_MASK);
eval 'sub CMD_serEval () {0xf5;}' unless defined(&CMD_serEval);
eval 'sub CMD_serAssign () {0xf6;}' unless defined(&CMD_serAssign);
eval 'sub CMD_serEEval () {0xf7;}' unless defined(&CMD_serEEval);
eval 'sub DT_INT () {1;}' unless defined(&DT_INT);
eval 'sub DT_CHAR () {2;}' unless defined(&DT_CHAR);
eval 'sub DT_DOUBLE () {3;}' unless defined(&DT_DOUBLE);
eval 'sub DT_STRING () {4;}' unless defined(&DT_STRING);
eval 'sub DT_BYTESTREAM () {5;}' unless defined(&DT_BYTESTREAM);
eval 'sub DT_SEXP () {10;}' unless defined(&DT_SEXP);
eval 'sub DT_ARRAY () {11;}' unless defined(&DT_ARRAY);
eval 'sub DT_LARGE () {64;}' unless defined(&DT_LARGE);
eval 'sub XT_NULL () {0;}' unless defined(&XT_NULL);
eval 'sub XT_INT () {1;}' unless defined(&XT_INT);
eval 'sub XT_DOUBLE () {2;}' unless defined(&XT_DOUBLE);
eval 'sub XT_STR () {3;}' unless defined(&XT_STR);
eval 'sub XT_LANG () {4;}' unless defined(&XT_LANG);
eval 'sub XT_SYM () {5;}' unless defined(&XT_SYM);
eval 'sub XT_BOOL () {6;}' unless defined(&XT_BOOL);
eval 'sub XT_S4 () {7;}' unless defined(&XT_S4);
eval 'sub XT_VECTOR () {16;}' unless defined(&XT_VECTOR);
eval 'sub XT_LIST () {17;}' unless defined(&XT_LIST);
eval 'sub XT_CLOS () {18;}' unless defined(&XT_CLOS);
eval 'sub XT_SYMNAME () {19;}' unless defined(&XT_SYMNAME);
eval 'sub XT_LIST_NOTAG () {20;}' unless defined(&XT_LIST_NOTAG);
eval 'sub XT_LIST_TAG () {21;}' unless defined(&XT_LIST_TAG);
eval 'sub XT_LANG_NOTAG () {22;}' unless defined(&XT_LANG_NOTAG);
eval 'sub XT_LANG_TAG () {23;}' unless defined(&XT_LANG_TAG);
eval 'sub XT_VECTOR_EXP () {26;}' unless defined(&XT_VECTOR_EXP);
eval 'sub XT_VECTOR_STR () {27;}' unless defined(&XT_VECTOR_STR);
eval 'sub XT_ARRAY_INT () {32;}' unless defined(&XT_ARRAY_INT);
eval 'sub XT_ARRAY_DOUBLE () {33;}' unless defined(&XT_ARRAY_DOUBLE);
eval 'sub XT_ARRAY_STR () {34;}' unless defined(&XT_ARRAY_STR);
eval 'sub XT_ARRAY_BOOL_UA () {35;}' unless defined(&XT_ARRAY_BOOL_UA);
eval 'sub XT_ARRAY_BOOL () {36;}' unless defined(&XT_ARRAY_BOOL);
eval 'sub XT_RAW () {37;}' unless defined(&XT_RAW);
eval 'sub XT_ARRAY_CPLX () {38;}' unless defined(&XT_ARRAY_CPLX);
eval 'sub XT_UNKNOWN () {48;}' unless defined(&XT_UNKNOWN);
eval 'sub XT_LARGE () {64;}' unless defined(&XT_LARGE);
eval 'sub XT_HAS_ATTR () {128;}' unless defined(&XT_HAS_ATTR);
eval 'sub BOOL_TRUE () {1;}' unless defined(&BOOL_TRUE);
eval 'sub BOOL_FALSE () {0;}' unless defined(&BOOL_FALSE);
eval 'sub BOOL_NA () {2;}' unless defined(&BOOL_NA);
eval 'sub GET_XT {
	my($X) = @_;
	eval q((($X)&63));
}' unless defined(&GET_XT);
eval 'sub GET_DT {
	my($X) = @_;
	eval q((($X)&63));
}' unless defined(&GET_DT);
eval 'sub HAS_ATTR {
	my($X) = @_;
	eval q(((($X) &XT_HAS_ATTR)>0));
}' unless defined(&HAS_ATTR);
eval 'sub IS_LARGE {
	my($X) = @_;
	eval q(((($X) &XT_LARGE)>0));
}' unless defined(&IS_LARGE);
if(defined (defined(&sun) ? &sun : undef)  && ! defined (defined(&ALIGN_DOUBLES) ? &ALIGN_DOUBLES : undef)) {
eval 'sub ALIGN_DOUBLES () {1;}' unless defined(&ALIGN_DOUBLES);
}

sub __BIG_ENDIAN__ () { unpack("h*", pack("s", 1)) =~ /01/; }
sub __LITTLE_ENDIAN__ () { unpack("h*", pack("s", 1)) =~ /^1/; }

if(defined (defined(&__BIG_ENDIAN__) ? &__BIG_ENDIAN__ : undef) || defined (defined(&_BIG_ENDIAN_) ? &_BIG_ENDIAN_ : undef)) {
eval 'sub SWAPEND () {1;}' unless defined(&SWAPEND);
}
elsif(defined (defined(&__LITTLE_ENDIAN__) ? &__LITTLE_ENDIAN__ : undef) || defined (defined(&_LITTLE_ENDIAN_) ? &_LITTLE_ENDIAN_ : undef) || defined (defined(&BS_LITTLE_ENDIAN) ? &BS_LITTLE_ENDIAN : undef)) {
}
elsif(defined (defined(&BS_BIG_ENDIAN) ? &BS_BIG_ENDIAN : undef)) {
eval 'sub SWAPEND () {1;}' unless defined(&SWAPEND);
}
elsif((defined(&__ia64__) ? &__ia64__ : undef) || (defined(&__i386__) ? &__i386__ : undef) || (defined(&__x86_64__) ? &__x86_64__ : undef) ) {
eval 'sub __LITTLE_ENDIAN__ () {1;}' unless defined(&__LITTLE_ENDIAN__);
}
elsif((defined(&__ppc__) ? &__ppc__ : undef) || (defined(&__ppc64__) ? &__ppc64__ : undef) ) {
eval 'sub __BIG_ENDIAN__ () {1;}' unless defined(&__BIG_ENDIAN__);
eval 'sub SWAPEND () {1;}' unless defined(&SWAPEND);
}
elsif(! defined (defined(&Win32) ? &Win32 : undef) ) {
die("Cannot determine endianness. Make sure config.h is included or __{BIG|LITTLE}_ENDIAN__ is defined .");
}

if(defined(&SWAPEND)) {
if(defined(&MAIN)) {
} else {
}
eval 'sub ptoi {
	my($X) = @_;
		eval q( &itop($X));
}' unless defined(&ptoi);
eval 'sub ptod {
	my($X) = @_;
		eval q( &dtop($X));
}' unless defined(&ptod);
} else {
eval 'sub itop {
	my($X) = @_;
		eval q(($X));
}' unless defined(&itop);
eval 'sub ptoi {
	my($X) = @_;
		eval q(($X));
}' unless defined(&ptoi);
eval 'sub dtop {
	my($X) = @_;
		eval q(($X));
}' unless defined(&dtop);
eval 'sub ptod {
	my($X) = @_;
		eval q(($X));
}' unless defined(&ptod);
eval 'sub fixdcpy {
	my($T,$S) = @_;
		eval q(()[0]=(($S))[0];);
}' unless defined(&fixdcpy);
}
unless(defined(&HAVE_CONFIG_H)) {
if(defined(&MAIN)) {
} else {
}
} else {
eval 'sub isByteSexOk () {1;}' unless defined(&isByteSexOk);
}

1;

