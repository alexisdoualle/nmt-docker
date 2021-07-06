/**
 * From one file containing on each line the source and target translation, separated by a tab,
 * create two files for source and target respectively
 */

const fs = require('fs');
const readline = require('readline');

var myArgs = process.argv.slice(2);
if (myArgs.length < 2) { console.log(`Syntax: node filename.js sourceLang targetLang
example:

node extract_tab_separated.js en fr`); return }

var dirNameToExtract = 'data_to_extract/txt/';
var dirNameAfterExtraction = 'extracted_data/';
var sourceLanguage = myArgs[0]
var targetLanguage = myArgs[1]
var txtFileList;

tmxFileList = fs.readdirSync(dirNameToExtract); 
console.log(tmxFileList);

if (!fs.existsSync(dirNameAfterExtraction)){
    fs.mkdirSync(dirNameAfterExtraction);
}


tmxFileList.forEach(fileName => {

    const readInterface = readline.createInterface({
        input: fs.createReadStream(dirNameToExtract+fileName),
        console: false
    });

    fileNameWithoutExtension = fileName.substring(0, fileName.length - 4)
  
    var endFilePath = dirNameAfterExtraction + fileNameWithoutExtension.match(/(?!.*\/)(.*)/)[0];

    fs.writeFile(endFilePath + '.' + sourceLanguage, '', () => {})
    fs.writeFile(endFilePath + '.' + targetLanguage, '', () => {})
  
    let stream1 = fs.createWriteStream(endFilePath + '.' + sourceLanguage, {flags: 'a'})
    let stream2 = fs.createWriteStream(endFilePath + '.' + targetLanguage, {flags: 'a'})
    let i = 0

    readInterface.on('line', function(line) {
        let split = line.split(/\t/)
        stream1.write(split[0] + '\n');
        stream2.write(split[1] + '\n');
    });

})