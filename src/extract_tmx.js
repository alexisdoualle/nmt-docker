const fs = require('fs');
const XmlStream = require('xml-stream');
​
var myArgs = process.argv.slice(2);
if (myArgs.length < 4) { console.log(`Syntax: node TMXExtract.js projectDirName sourceLang TargetLang tmxPath [... other tmx files]
example:
​
node TMXExtract.js MF en fr TMs/studio.tmx Tms/otherTM.tmx`); return }
console.log(myArgs);
​
​
/**
 * Extract source and target from Translation Memories for MT training
 * 1 TM segment => 1 plain text line in each file (source and target)
 */
​
var dirName = myArgs[0]
var sourceLanguage = myArgs[1]
var targetLanguage = myArgs[2]
​
var tmxFileList = myArgs.slice(3)
tmxFileList.forEach(file => {
​
  var tmxFilePath = file
  
  if (!tmxFilePath.endsWith('.tmx')) {console.log('Files needs to end with .tmx'); return}
  tmxFilePath = tmxFilePath.substring(0, tmxFilePath.length - 4)
​
  // Create directory:
  if (!fs.existsSync('./' + dirName)){
    fs.mkdirSync('./' + dirName);
  }
​
  var stream = fs.createReadStream(tmxFilePath + '.tmx');
  var xml = new XmlStream(stream);
  xml.collect('tuv');
​
  var endFilePath = dirName+'/'+ tmxFilePath.match(/(?!.*\/)(.*)/)[0];
​
  fs.writeFile(endFilePath + '.' + sourceLanguage, 'w', () => {})
  fs.writeFile(endFilePath + '.' + targetLanguage, 'w', () => {})
​
  let stream1 = fs.createWriteStream(endFilePath + '.' + sourceLanguage, {flags: 'a'})
  let stream2 = fs.createWriteStream(endFilePath + '.' + targetLanguage, {flags: 'a'})
  let i = 0
​
  xml.on('endElement: tu', function(item) {
    var efp = endFilePath
    stream1.write(item.tuv[0].seg + '\n');
    stream2.write(item.tuv[1].seg + '\n');
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
​
// Dior Example:
// <?xml version="1.0" encoding="utf-8"?>
// <tmx version="1.4">
//   <header creationtool="SDL Language Platform" creationtoolversion="8.0" o-tmf="SDL TM8 Format" datatype="xml" segtype="sentence" adminlang="fr-FR" srclang="fr-FR" creationdate="20140903T145309Z" creationid="irina">
//     <prop type="x-Status:MultiplePicklist">Approved,New,Read Only</prop>
//     <prop type="x-Text Field:MultipleString"></prop>
//     <prop type="x-Recognizers">RecognizeAll</prop>
//     <prop type="x-TMName">DIOR_FR_UK</prop>
//     <prop type="x-TokenizerFlags">DefaultFlags</prop>
//     <prop type="x-WordCountFlags">AllFlags, BreakOnApostrophe</prop>
//   </header>
//   <body>
//     <tu creationdate="20100730T095222Z" creationid="NICHOLAS" changedate="20100929T143902Z" changeid="DATASIA\iboukhtoiarova" lastusagedate="20101227T181136Z" usagecount="5">
//       <prop type="x-Context">0, 0</prop>
//       <prop type="x-Origin">TM</prop>
//       <prop type="x-OriginalFormat">TradosTranslatorsWorkbench</prop>
//       <tuv xml:lang="fr-FR">
//         <seg>Timepieces</seg>
//       </tuv>
//       <tuv xml:lang="en-GB">
//         <seg>Timepieces</seg>
//       </tuv>
//     </tu>
//     <tu creationdate="20100129T100053Z" creationid="JENNIFER_K" changedate="20100129T100053Z" changeid="JENNIFER_K" lastusagedate="20100129T100053Z">
//       <prop type="x-Origin">TM</prop>
//       <prop type="x-OriginalFormat">TradosTranslatorsWorkbench</prop>
//       <tuv xml:lang="fr-FR">
//         <seg>MS0APUL1 001</seg>
//       </tuv>
//       <tuv xml:lang="en-GB">
//         <seg>MS0APUL1 001</seg>
//       </tuv>
//     </tu>
​
​
// MF Example:
// <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
// <tmx>
//     <header/>
//     <body>
//         <tu usagecount="2" lastusagedate="20160816T155715Z" creationdate="20160807T152804Z" creationid="DATASIA\agrasset" changedate="20160816T155715Z" changeid="DATASIA\agrasset">
//             <prop type="x-ConfirmationLevel">ApprovedTranslation</prop>
//             <tuv xml:lang="en-GB">
//                 <seg>Try it with a leather biker jacket and skinny jeans on weekends.</seg>
//             </tuv>
//             <tuv xml:lang="fr-FR">
//                 <seg>Associez-le à une veste motard en cuir et un jean skinny le week-end.</seg>
//             </tuv>
//         </tu>
//         <tu usagecount="2" lastusagedate="20160823T083223Z" creationdate="20160807T153102Z" creationid="DATASIA\agrasset" changedate="20160823T083223Z" changeid="aurore grasset">
//             <prop type="x-ConfirmationLevel">ApprovedTranslation</prop>
//             <tuv xml:lang="en-GB">
//                 <seg>Model is 5ft 10in/ 1.78m, and wears a size 3.</seg>
//             </tuv>
//             <tuv xml:lang="fr-FR">
//                 <seg>Le mannequin mesure 1,78 m et porte une taille 3.</seg>
//             </tuv>
//         </tu>