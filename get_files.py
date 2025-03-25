#!/usr/bin/env python3

import smbc
import sys
import time
import os

def get_filename_date(filename):
	return filename.split('_')[-1].split('.')[0]

def copy_remote_file(dest,f):
	file = ctx.open (f)
	with  open(dest,'wb') as filedest:
		filedest.write(file.read())

def purge_folder(dir,files):
	for f in files:
		file_path = os.path.join(dir, f)
		os.unlink(file_path)


obj=sys.argv[1]
destdir=sys.argv[2]
nr_latest=int(sys.argv[3])

subs=[]

try:
	ctx = smbc.Context()
	smbpath="smb://seestar/EMMC Images/MyWorks/"+obj+"_sub"
	entries = ctx.opendir (smbpath).getdents ()
	subs=[ent.name for ent in entries if ent.smbc_type==8 and ent.name.startswith('Light_') and ent.name.endswith('.fit') ]
	subs.sort(reverse=True,key=get_filename_date)
except:
	print("Error connecting to seestar or obs data not yet ready ")
	sys.exit(2)

prev_files=[f for f in  os.listdir(destdir) if f.startswith('Light_')]
prev_files.sort(reverse=True,key=get_filename_date)


youngest_prev_file= "" if  (len(prev_files) == 0) else   prev_files[0]

new_files=subs[0:nr_latest]

# exit if the previously youngest file is still part of this list
if youngest_prev_file in new_files or len(new_files) != nr_latest:
	print('not enough new files yet, waiting for more to be available')
	sys.exit(1)

# wait some time as file might still be busy
time.sleep(5)

#remove old files or they will be included in the stacking!
purge_folder(destdir,prev_files)

#download newest files to now empty directory
for f in new_files:
	copy_remote_file(os.path.join(destdir,f),smbpath+"/"+f)





