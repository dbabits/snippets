import pandas as pd
import subprocess
import sys
import io
import json

'''
dbabits@penguin:~/dev$ sudo apt-get install python3-distutils
dbabits@penguin:~/dev$ python3 get-pip.py 
sudo apt-get install sysstat
Successfully installed pip-20.3.1 setuptools-50.3.2 wheel-0.36.1

dbabits@penguin:~/dev$ ll /home/dbabits/.local/bin
total 24
drwxr-xr-x 1 dbabits dbabits  92 Dec  5 23:39 ./
drwxr-xr-x 1 dbabits dbabits  22 Dec  5 23:39 ../
-rwxr-xr-x 1 dbabits dbabits 230 Dec  5 23:39 easy_install*
-rwxr-xr-x 1 dbabits dbabits 230 Dec  5 23:39 easy_install-3.7*
-rwxr-xr-x 1 dbabits dbabits 221 Dec  5 23:39 pip*
-rwxr-xr-x 1 dbabits dbabits 221 Dec  5 23:39 pip3*
-rwxr-xr-x 1 dbabits dbabits 221 Dec  5 23:39 pip3.7*
-rwxr-xr-x 1 dbabits dbabits 208 Dec  5 23:39 wheel*
'''

print(sys.version)
output = subprocess.run("iostat | sed -ne '/Device/,$ p' | column -t",stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True,universal_newlines=True)
print("stdout:\n%s" % output.stdout)
df = pd.read_csv(filepath_or_buffer = io.StringIO(output.stdout), sep='\s+',header = 0,index_col=0,skipinitialspace = True)
print("df:\n%s" % df)
print("tolist:\n%s" % df.values.flatten().tolist())
print("to_csv:\n%s" % df.to_csv())
print("to_json,column-orient:\n%s" % df.to_json(double_precision=0,orient="columns"))
print("to_json,row-orient:\n%s" % df.to_json(double_precision=1,orient="index"))
print("to_dict,column-orient:\n%s" % df.to_dict(orient="dict"))
print("to_dict,row-orient:\n%s" % df.to_dict(orient="index"))

json_o = json.loads(df.to_json(double_precision=1,orient="index"))
print("json_o:\n%s" % json_o) 

for key in json_o:
    value = json_o[key]
    print("The key and value are ({}) = ({})".format(key, value))

for col, rows in df.to_dict(orient="dict").items():
  for row, value in rows.items():
    print("%s - %s - %s" %(col,row,value))

for (index_label, row_series) in df.iterrows():
   print('Row Index label : ', index_label)
   print('Row Content as Series : ', row_series.values)

print("Iterate column-wise:")
for col, rows in df.items():
  for v in rows.values():
    print("%s - %s" %(col,v))