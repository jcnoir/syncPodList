#! /usr/bin/env python

APPNAME = 'sync-pod-list'
PROG_NAME = 'sync-pod-list'
VERSION = '0..01'

top = '.'
out = 'build'

def options(opt):
    opt.load('compiler_c')

def configure(conf):
    conf.load('compiler_c vala')

    conf.check_cfg(package='gee-1.0', uselib_store='GEE', atleast_version='0', args='--cflags --libs')
    conf.check_cfg(package='libgpod-1.0', uselib_store='GPOD', atleast_version='0', args='--cflags --libs')

    conf.define('PACKAGE', APPNAME)
    conf.define('VERSION', VERSION)

def build(bld):
    bld.recurse ('src')
