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
    }
  ]
}
EOF
)
..|(.first_name +"-"+.last_name)?

#see https://github.com/stedolan/jq/wiki/Cookbook#delete-elements-from-objects-recursively
#If your jq does not have walk/1, then you can copy its definition from https://github.com/stedolan/jq/blob/master/src/builtin.jq
walk(if type == "object" and .first_name then .full_name=.first_name+"-"+.last_name else . end)
