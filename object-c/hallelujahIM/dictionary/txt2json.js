var fs = require('fs');

var lines = fs.readFileSync('count_1w.txt','utf-8').split('\n');
var hash = {};
lines.forEach(function(l){
    l = l.trim();
    if(l){
        var arr = l.split('\t');
        hash[arr[0]] = arr[1];
    }
});

fs.writeFileSync('google_333333_words.json', JSON.stringify(hash));