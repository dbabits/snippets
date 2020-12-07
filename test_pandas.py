import pandas as pd
import subprocess
import sys
import io
import json
import time
import platform
import re

hostname = platform.node()


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
df = pd.read_csv(filepath_or_buffer = io.StringIO(output.stdout), sep=r'\s+',header = 0,index_col=0,skipinitialspace = True)
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

print("Iterate row-wise:")
for (rowname, columns) in df.iterrows():
  print('Row: %s - %s -%s' % (rowname, columns, columns.values))
   
  for col in columns.items():                 #col is a tuple
    print ("col name:%s value:%s type(col): %s" % (col[0],col[1],type(col)))
   
  for col_name,col_value in columns.items():  #another way to do it
    print ("col name:%s value:%s" % (col_name,col_value)) 

  print("max col for row %s:%s" % (rowname,columns.max()))
    

def sanitize(string):
  return re.sub(r'[^a-zA-Z0-9-_./\n]', "_", string) # |tr -cs '[a-zA-Z0-9-_./\n]' '_'
  
print("Iterate column-wise:")
for colname, rows in df.items():
  #print ("col:%s rows:\n%s" %(colname,rows))
  
  colname = sanitize(colname)
  metric_raw = 'node.iostat.'+colname
  metric_sum = metric_raw + '_sum'
  metric_max = metric_raw + '_max'

  print(json.dumps(
    {'domain':'dba','timestamp':int(time.time()),'metric':metric_sum,'asset':hostname+'-'+metric_sum, 'value':float(rows.sum()),'tags':{'hostname':hostname} }
  ))  

  print(json.dumps(
    {'domain':'dba','timestamp':int(time.time()),'metric':metric_sum,'asset':hostname+'-'+metric_max, 'value':float(rows.max()),'tags':{'hostname':hostname} }
  ))  

  for row_name,value in rows.items():
    #print ("row:%s, value:%s" %(row_name,value))
    row_name = sanitize(row_name)
    print(json.dumps(
      {'domain':'dba','timestamp':int(time.time()),'metric':metric_raw,'asset':hostname+'-'+metric_raw, 'value':value,'tags':{'device':row_name,'hostname':hostname} }
    ))
  
  #print("for col %s:max=%s; sum=%s" % (colname,rows.max(),rows.sum()))