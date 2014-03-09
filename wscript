#! /usr/bin/env python
# encoding: utf-8

APPNAME = 'sync-pod-list'
PROG_NAME = 'sync-pod-list'
VERSION = '0.0.1'

top = '.'
out = 'build'

def options(opt):
    opt.load('compiler_cc')
    opt.load('vala')
    # Add a command line option to compile with debug infos : --debug=True
    opt.add_option('--debug', action='store', default=False, help='Add debug informations during compilation')

def configure(conf):
    conf.load('compiler_cc vala')
    conf.check_cfg(package='libgpod-1.0', uselib_store='GPOD', atleast_version='0.8.2', args='--cflags --libs')
    conf.check_cfg(package='libtaginfo_c', uselib_store='TAGINFO', atleast_version='0.1.3', args='--cflags --libs')
    conf.check_cfg(package='gio-2.0', uselib_store='GIO', atleast_version='2.34.3', args='--cflags --libs')
    conf.check_cfg(package='sqlheavy-0.2', uselib_store='SQLHEAVY', atleast_version=' 0.1.1', args='--cflags --libs')
    conf.check_cfg(package='gee-0.8', uselib_store='GEE',atleast_version='0.6.7', args='--cflags --libs')

    conf.define('PACKAGE', APPNAME)
    conf.define('VERSION', VERSION)


def build(bld):

    if bld.options.debug:
        print("Compilation debug enabled.")
        #Debug Mode
        bld.env.VALAFLAGS.append('--debug')
        bld.env.CFLAGS = ['-g', '-Wall']

    bld.recurse ('src/collection')
