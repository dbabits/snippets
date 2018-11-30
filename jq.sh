#replace characters in value:
#See: https://stackoverflow.com/questions/40321035/remove-escape-sequence-characters-like-newline-tab-and-carriage-return-from-jso
#Can simplify without grouping if | is last: [.level,.logger_name, .content | gsub("[\\n\\t]"; "")  ]
#Alternatively: walk(if type == "string" then gsub("\\p{Cc}"; " ") else . end) |[.level,.content, .logger_name]
#  \p{Cc} is a Unicode category specifier: http://www.regular-expressions.info/unicode.html 
# [0:20] truncates to first 20 chars
cat<<EOF| jq -r '[.level,(.content | gsub("[\\n\\t]"; " ")[0:20] ), .logger_name]'
{
"HOSTNAME":"server1.example",
"level":"WARN",
"level_value":30000,
"logger_name":"server1.example.adapter",
"content":"ERROR LALALLA\nERROR INFO NANANAN\tSOME MORE ERROR INFO"
}
EOF

# https://github.com/stedolan/jq/wiki/Cookbook
# https://github.com/stedolan/jq/wiki/For-JSONPath-users
# https://jqplay.org/s/M5Ky1KJd-C
echo '{ "store": {
    "book": [ 
      { "category": "reference",
        "author": "Nigel Rees",
        "title": "Sayings of the Century",
        "price": 8.95
      },
      { "category": "fiction",
        "author": "Evelyn Waugh",
        "title": "Sword of Honour",
        "price": 12.99
      },
      { "category": "fiction",
        "author": "Herman Melville",
        "title": "Moby Dick",
        "isbn": "0-553-21311-3",
        "price": 8.99
      },
      { "category": "fiction",
        "author": "J. R. R. Tolkien",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99
      }
    ],
    "bicycle": {
      "color": "red",
      "price": 19.95
    }
  }
} ' \
| jq '.store.book[] | select(.category=="fiction" ) | select(.price > 10).author  '
"Evelyn Waugh"
"J. R. R. Tolkien"

jq 'recurse(.[]?) | objects | select(has("foo"))'
{
  "foo": "bar",
  "whatever": "......"
}
| jq '..|.foo?'

#################
json=$(cat <<EOF
{
  "first_name": "John",
  "last_name": "Smith",
  "things_carried": [
    "apples",
    "hat",
    "harmonica",
    {
        "foo":"bar",
        "moo":"zoo"
    } 
  ],
  "children": [
    {
      "first_name": "Bobby Sue",
      "last_name": "Smith"
    },
    {
      "first_name": "John Jr",
      "last_name": "Smith"
    },
    {
      "grand_children":[
         {
         "first_name":"dima"
         }
      ]
    }
  ]
}
EOF
)

$ echo "$json"|jq '..|(.first_name +"-"+.last_name)?'
"John-Smith"
"-"
"Bobby Sue-Smith"
"John Jr-Smith"

$ echo "$json" | jq '..|select(.first_name != null and .last_name !=null)?|[.first_name,.last_name]?|join("-")'
"John-Smith"
"Bobby Sue-Smith"
"John Jr-Smith"

#see https://github.com/stedolan/jq/wiki/Cookbook#delete-elements-from-objects-recursively
#If your jq does not have walk/1, then you can copy its definition from https://github.com/stedolan/jq/blob/master/src/builtin.jq
walk(if type == "object" and .first_name and .last_name then .full_name=.first_name+"-"+.last_name else . end)
walk(if type == "object" and .first_name and .last_name then .first_name=.first_name+"-"+.last_name |.last_name=.first_name+"-"+.last_name else . end)


#Combine attributes at different levels of hierarchy, and make an csv(see also sqlite/pivot table):
cat <<EOF
{"jobCounters":{"id":"job_1540515215370_2592","counterGroup":[{"counterGroupName":"org.apache.hadoop.mapreduce.FileSystemCounter","counter":[{"name":"FILE_BYTES_READ","totalCounterValue":0,"mapCounterValue":0,"reduceCounterValue":0},{"name":"FILE_BYTES_WRITTEN","totalCounterValue":1138885635,"mapCounterValue":1138616773,"reduceCounterValue":268862},{"name":"FILE_READ_OPS","totalCounterValue":0,"mapCounterValue":0,"reduceCounterValue":0},{"name":"FILE_LARGE_READ_OPS","totalCounterValue":0,"mapCounterValue":0,"reduceCounterValue":0},{"name":"FILE_WRITE_OPS","totalCounterValue":0,"mapCounterValue":0,"reduceCounterValue":0},{"name":"HDFS_BYTES_READ","totalCounterValue":2642139400,"mapCounterValue":2642139400,"reduceCounterValue":0},{"name":"HDFS_BYTES_WRITTEN","totalCounterValue":0,"mapCounterValue":0,"reduceCounterValue":0},{"name":"HDFS_READ_OPS","totalCounterValue":21090,"mapCounterValue":21090,"reduceCounterValue":0},{"name":"HDFS_LARGE_READ_OPS","totalCounterValue":0,"mapCounterValue":0,"reduceCounterValue":0},{"name":"HDFS_WRITE_OPS","totalCounterValue":0,"mapCounterValue":0,"reduceCounterValue":0}]},{"counterGroupName":"org.apache.hadoop.mapreduce.JobCounter","counter":[{"name":"NUM_KILLED_MAPS","totalCounterValue":3800,"mapCounterValue":0,"reduceCounterValue":0},{"name":"TOTAL_LAUNCHED_MAPS","totalCounterValue":8028,"mapCounterValue":0,"reduceCounterValue":0},{"name":"TOTAL_LAUNCHED_REDUCES","totalCounterValue":1,"mapCounterValue":0,"reduceCounterValue":0},{"name":"DATA_LOCAL_MAPS","totalCounterValue":5954,"mapCounterValue":0,"reduceCounterValue":0},{"name":"RACK_LOCAL_MAPS","totalCounterValue":2074,"mapCounterValue":0,"reduceCounterValue":0},{"name":"SLOTS_MILLIS_MAPS","totalCounterValue":156885471756,"mapCounterValue":0,"reduceCounterValue":0},{"name":"MILLIS_MAPS","totalCounterValue":13073789313,"mapCounterValue":0,"reduceCounterValue":0},{"name":"VCORES_MILLIS_MAPS","totalCounterValue":13073789313,"mapCounterValue":0,"reduceCounterValue":0},{"name":"MB_MILLIS_MAPS","totalCounterValue":160650723078144,"mapCounterValue":0,"reduceCounterValue":0}]}]}}
EOF

#WRONG:
{ id: .jobCounters.id, name: .jobCounters.counterGroup[].counter[].name, mapCounterValue: .jobCounters.counterGroup[].counter[].mapCounterValue, reduceCounterValue: .jobCounters.counterGroup[].counter[].reduceCounterValue, total: .jobCounters.counterGroup[].counter[].totalCounterValue}  | [.id, .name, .mapCounterValue,.reduceCounterValue,.total] |@csv
"job_1540515215370_2592","FILE_BYTES_READ",0,0,0
"job_1540515215370_2592","FILE_BYTES_READ",0,0,1138885635

#RIGHT:
 .jobCounters.counterGroup[].counter[]  | [.name, .mapCounterValue, .reduceCounterValue, .totalCounterValue] | @csv
"FILE_BYTES_READ",0,0,0
"FILE_BYTES_WRITTEN",1138616773,268862,1138885635
"FILE_READ_OPS",0,0,0
