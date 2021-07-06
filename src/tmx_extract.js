const fs = require('fs');
const XmlStream = require('xml-stream');

var myArgs = process.argv.slice(2);
if (myArgs.length < 2) { console.log(`Syntax: node TMXExtract.js sourceLang targetLang
example:

node TMXExtract.js en fr`); return }

/**
 * Extract source and target from Translation Memories for MT training
 * 1 TM segment => 1 plain text line in each file (source and target)
 */
var dirNameToExtract = 'data_to_extract/tmx/';
var dirNameAfterExtraction = 'extracted_data/';
var sourceLanguage = myArgs[0]
var targetLanguage = myArgs[1]
var tmxFileList;

// return
tmxFileList = fs.readdirSync(dirNameToExtract); 
console.log(tmxFileList);

// Create directory:
if (!fs.existsSync(dirNameAfterExtraction)){
  fs.mkdirSync(dirNameAfterExtraction);
}

// Keep hash to check for duplicates, which should be avoided in NMT
let record = {};

tmxFileList.forEach(fileName => {

  if (!fileName.endsWith('.tmx')) {console.log('Files needs to end with .tmx'); return}
  fileNameWithoutExtension = fileName.substring(0, fileName.length - 4)

  var stream = fs.createReadStream( dirNameToExtract + fileNameWithoutExtension + '.tmx');
  var xml = new XmlStream(stream);
  xml.collect('tuv');

  var endFilePath = dirNameAfterExtraction + fileNameWithoutExtension.match(/(?!.*\/)(.*)/)[0];
  
  fs.writeFile(endFilePath + '.' + sourceLanguage, '', () => {})
  fs.writeFile(endFilePath + '.' + targetLanguage, '', () => {})

  let stream1 = fs.createWriteStream(endFilePath + '.' + sourceLanguage, {flags: 'a'})
  let stream2 = fs.createWriteStream(endFilePath + '.' + targetLanguage, {flags: 'a'})
  let i = 0

  xml.on('endElement: tu', function(item) {
    var efp = endFilePath
    // Language check
    if (item.tuv[0].$['xml:lang'].substring(0,2) == sourceLanguage && item.tuv[1].$['xml:lang'].substring(0,2) == targetLanguage) {
      let sourceSegment = item.tuv[0].seg.$text || item.tuv[0].seg;
      if (typeof sourceSegment === 'object') {
        if (sourceSegment.it) sourceSegment = sourceSegment.it; else return;
      }
      let targetSegment = item.tuv[1].seg.$text || item.tuv[1].seg;
      if (typeof targetSegment === 'object') {
        if (targetSegment.it) targetSegment = targetSegment.it; else return;
      }
      // Check for duplicates
      if (record[sourceSegment.hashCode()]) return;
      i++
      stream1.write(sourceSegment + '\n');
      stream2.write(targetSegment + '\n');
      record[sourceSegment.hashCode()] = 1;
    }
    
    if (i%100 === 0) {
      if (process.stdout.clearLine) {
        process.stdout.clearLine();
        process.stdout.cursorTo(0);
        process.stdout.write(i + ' lines extracted in ' + efp+'.'+sourceLanguage +' and .'+targetLanguage);
      }
    }
  });
  // xml.on('end', (item) => {
  //   // clearLine may cause problems in a docker container
  //   if (process.stdout.clearLine) {
  //     process.stdout.clearLine();
  //     process.stdout.cursorTo(0);
  //     process.stdout.write(i + ' lines extracted in ' + endFilePath+'.'+sourceLanguage +' and .'+targetLanguage);
  //     process.stdout.write("\n")
  //   }
  // });
  xml.on('error', function (err) {
    console.log(err);
  });
})

String.prototype.hashCode = function() {
  var hash = 0, i, chr;
  if (this.length === 0) return hash;
  for (i = 0; i < this.length; i++) {
    chr   = this.charCodeAt(i);
    hash  = ((hash << 5) - hash) + chr;
    hash |= 0; // Convert to 32bit integer
  }
  return hash;
};