#! /usr/bin/env python

APPNAME = 'sync-pod-list'
PROG_NAME = 'sync-pod-list'
VERSION = '0.0.1'

top = '.'
out = 'build'

def options(opt):
    print('options ...')
    opt.load('compiler_cc')
    opt.load('vala')

def configure(conf):
    print('configure ...')
    conf.load('compiler_cc vala')
    conf.check_cfg(package='libgpod-1.0', uselib_store='GPOD', atleast_version='0.8.2', args='--cflags --libs')
    conf.check_cfg(package='libtaginfo_c', uselib_store='TAGINFO', atleast_version='0.1.3', args='--cflags --libs')
    conf.check_cfg(package='gio-2.0', uselib_store='GIO', atleast_version='2.34.3', args='--cflags --libs')
    conf.define('PACKAGE', APPNAME)
    conf.define('VERSION', VERSION)

def build(bld):
    print('build ...')
    bld.recurse ('src/collection src/ipod')
