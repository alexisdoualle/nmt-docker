const fs = require('fs');
const XmlStream = require('xml-stream');

var myArgs = process.argv.slice(2);
if (myArgs.length < 2) { console.log(`Syntax: node TMXExtract.js sourceLang targetLang
example:

node TMXExtract.js MF en fr data/tmx/`); return }

/**
 * Extract source and target from Translation Memories for MT training
 * 1 TM segment => 1 plain text line in each file (source and target)
 */
var dirName = 'data'
var sourceLanguage = myArgs[0]
var targetLanguage = myArgs[1]
var tmxFileList;

tmxFileList = fs.readdirSync('data/tmx/'); 
console.log(tmxFileList);

// Create directory:
if (!fs.existsSync('data/txt/' )){
  fs.mkdirSync('data/txt');
}


tmxFileList.forEach(fileName => {

  if (!fileName.endsWith('.tmx')) {console.log('Files needs to end with .tmx'); return}
  fileNameWithoutExtension = fileName.substring(0, fileName.length - 4)

  var stream = fs.createReadStream( dirName+'/tmx/'+ fileNameWithoutExtension + '.tmx');
  var xml = new XmlStream(stream);
  xml.collect('tuv');

  var endFilePath = dirName+'/txt/'+ fileNameWithoutExtension.match(/(?!.*\/)(.*)/)[0];
  
  fs.writeFile(endFilePath + '.' + sourceLanguage, '', () => {})
  fs.writeFile(endFilePath + '.' + targetLanguage, '', () => {})

  let stream1 = fs.createWriteStream(endFilePath + '.' + sourceLanguage, {flags: 'a'})
  let stream2 = fs.createWriteStream(endFilePath + '.' + targetLanguage, {flags: 'a'})
  let i = 0

  xml.on('endElement: tu', function(item) {
    var efp = endFilePath
    // Language check
    if (item.tuv[0].$['xml:lang'].substring(0,2) == sourceLanguage && item.tuv[1].$['xml:lang'].substring(0,2) == targetLanguage) {
      if (typeof item.tuv[0].seg == 'string') {
        stream1.write(item.tuv[0].seg + '\n');
        stream2.write(item.tuv[1].seg + '\n');
      } else {
        // TU contains bpt, get $text value
        stream1.write(item.tuv[0].seg.$text + '\n');
        stream2.write(item.tuv[1].seg.$text + '\n');
      }
    }
    
    i++
    if (i%1000 === 0) {
      process.stdout.clearLine();
      process.stdout.cursorTo(0);
      process.stdout.write(i + ' lines extracted in ' + efp+'.'+sourceLanguage +' and .'+targetLanguage);
    }
  });
  xml.on('end', (item) => {
    process.stdout.clearLine();
    process.stdout.cursorTo(0);
    process.stdout.write(i + ' lines extracted in ' + endFilePath+'.'+sourceLanguage +' and .'+targetLanguage);
    process.stdout.write("\n")
  })
})
