#! /usr/bin/env python
# encoding: utf-8
# WARNING! Do not edit! http://waf.googlecode.com/git/docs/wafbook/single.html#_obtaining_the_waf_file

from waflib import TaskGen
TaskGen.declare_chain(name='erlc',rule='${ERLC} ${ERLC_FLAGS} ${SRC[0].abspath()} -o ${TGT[0].name}',ext_in='.erl',ext_out='.beam')
def configure(conf):
	conf.find_program('erlc',var='ERLC')
	conf.env.ERLC_FLAGS=[]
