#!/usr/bin/python
from sys import stderr,exit
from re import match,compile
from urllib import quote,unquote
from feedparser import parse
base_rss_url = "http://sourceforge.net/api/file/index/project-id/114505/mtime/desc/rss?path=%2F"
base_download_url = "http://downloads.sourceforge.net/project/devkitpro"

sources = [
    ['libnds','.*libnds-[0-9\\.]*\\.tar\\.bz2'],
    ['devkitARM','.*devkitARM_r[0-9]*-i686-linux\\.tar\\.bz2'],
    ['devkitARM','.*devkitARM_r[0-9]*-x86_64-linux\\.tar\\.bz2'],
    ['filesystem','.*libfilesystem-[0-9\\.]*\\.tar\\.bz2'],
    ['default%20arm7','.*default_arm7-[0-9\\.]*\\.tar\\.bz2'],
    ['examples%2Fnds','.*nds-examples-[0-9]*\\.tar\\.bz2'],
    ['libfat','.*libfat-nds-[0-9\\.]*\\.tar\\.bz2'],
    ['dswifi','.*dswifi-[0-9\\.]*\\.tar\\.bz2'],
    ['maxmod','.*maxmod-nds-[0-9\\.]*\\.tar\\.bz2']
]


feeds = ([source[0], [parse(base_rss_url + source[0]),source[1]]] for source in sources)

def grep(string,list):
    expr = compile(string)
    return filter(expr.search,list)

def main():
    out_of_date_count = 0

    for source,feed in feeds:
        latest = "ERROR"
        for entry in feed[0].entries:
            if latest != "ERROR":
                break
            #print feed[1] + " : " + entry.summary
            if match(feed[1],entry.summary):
                latest = base_download_url+quote(entry.summary)
            
        if latest == "ERROR":
            print "Source: " + unquote(source)
            print "ERROR"
            print
        else:
            lines = (line for line in open('devkitpro.sh','r'))
            g = grep(latest,lines)
            if len(g) == 0:
                out_of_date_count += 1
                stderr.write(unquote(source) + " is out of date.\n")
                stderr.write("Latest: " + latest + "\n")
                stderr.write("\n") 
            else:
                print unquote(source) + " is up to date."

    return out_of_date_count

if __name__ == "__main__":
    exit(main())
